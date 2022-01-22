#!/usr/bin/env python

"""This module contains code to convert STASH metadata into XML files
   to be used by XIOS
"""

import re
import glob
import os
import sys
import copy
import xml.etree.cElementTree as ET
import csv
from operator import itemgetter
from optparse import OptionParser

import rose.macro
from rose.opt_parse import RoseOptionParser
from rose.resource import ResourceLocator

OPT_ENS_NAME = "ens"
RE_ENS_OPT_CONFIG_FILE = "rose-.*?-" + OPT_ENS_NAME + "([0-9]*).conf$"

IS_STASH = re.compile(r'namelist:('
                       'umstash_streq\(\d{5}_[0-9a-f]+\)'
                       '|umstash_ens\(\w+_[0-9a-f]+\)'
                       '|umstash_use\(\w+_[0-9a-f]+\)'
                       '|umstash_domain\(\w+_[0-9a-f]+\)'
                       '|umstash_time\(\w+_[0-9a-f]+\)'
                       '|xios_streams\(\w+\)'
                       ')')
IS_STASH_STREQ = re.compile(r'namelist:umstash_streq\(\d{5}_[0-9a-f]+\)')
IS_STASH_ENS = re.compile(r'namelist:umstash_ens\(\w+_[0-9a-f]+\)')
IS_STASH_USAGE = re.compile(r'namelist:umstash_use\([-.\w]+_[0-9a-f]+\)')
IS_STASH_DOMAIN = re.compile(r'namelist:umstash_domain\([-.\w]+_[0-9a-f]+\)')
IS_STASH_TIME = re.compile(r'namelist:umstash_time\([-.\w]+_[0-9a-f]+\)')
IS_UM_XIOS_STREAM = re.compile(r'namelist:xios_streams\(\w+\)')
IS_UM_XIOS_OPTIONS = re.compile(r'namelist:xios_output_options')
IS_XIOS_OPTIONS = re.compile(r'xios_options')
IS_XIOS_CONTEXTS = re.compile(r'.*xios_contexts')

verbosity = 1
prefix = 'um-atmos'
ens_prefix = "_ens"
ens_mem_prefix = "_ens_mem{0}"
all_grids = ('grid_t', 'grid_cu', 'grid_cv', 'grid_uv', 'grid_r')
halo_types = ('none', 'single', 'extended')
halo_name = dict(zip(halo_types, ('', '_halo_single', '_halo_extended')))
xios_units = dict(zip(range(5), ('', 'h', 'd', 'ts', 'mo')))
xios_operation = dict(zip(range(7), ('', 'instant', 'accumulate', 'average',
                                     '', 'maximum', 'minimum')))

def parse_args(argv=None):
    """Parse options/arguments"""
    opt_parser = RoseOptionParser()
    options = ["meta_path", "no_warn"]
    opt_parser.add_my_options(*options)
    if argv is None:
        opts, args = opt_parser.parse_args()
    else:
        opts, args = opt_parser.parse_args(argv)

    return opts, args

def get_data_from_opts(opts):
    """Returns config data for an app or suite provided as opts.conf_dir."""
    sys.path.append(os.getenv("ROSE_HOME"))
    rose.macro.add_opt_meta_paths(opts.meta_path)
    config_name = os.path.basename(opts.conf_dir)
    config_file_path = os.path.join(opts.conf_dir,
                                    rose.SUB_CONFIG_NAME)
    dir_type = None
    if (os.path.exists(config_file_path) or
            os.path.isfile(config_file_path)):
        dir_type = rose.SUB_CONFIG_NAME
    else:
        config_file_path = os.path.join(opts.conf_dir, rose.TOP_CONFIG_NAME)
        if (os.path.exists(config_file_path) or
                os.path.isfile(config_file_path)):
            dir_type = rose.TOP_CONFIG_NAME
        else:
            rose.reporter.Reporter()(
                rose.macro.ERROR_LOAD_CONFIG_DIR.format(opts.conf_dir),
                kind=rose.reporter.Reporter.KIND_ERR,
                level=rose.reporter.Reporter.FAIL)
            return None

    conf_data = load_conf_from_file(opts, config_file_path, config_name,
                                    mode="macro")
    if conf_data is not None:
        return conf_data + (dir_type,)
    else:
        return None

def load_conf_from_file(opts, config_file_path, config_name, mode="macro"):
    """Loads config data from the file config_file_path."""
    optional_keys = []
    optional_dir = os.path.join(opts.conf_dir, rose.config.OPT_CONFIG_DIR)
    optional_glob = os.path.join(optional_dir, rose.GLOB_OPT_CONFIG_FILE)
    for path in glob.glob(optional_glob):
        filename = os.path.basename(path)
        # filename is a null string if path is to a directory.
        #result = re.match(rose.RE_OPT_CONFIG_FILE, filename)
        # Only load optional config data for ensemble members
        result = re.match(RE_ENS_OPT_CONFIG_FILE, filename)
        if not result:
            continue
        optional_keys.append(OPT_ENS_NAME + result.group(1))

    # Sort optional_keys in ensemble member order
    optional_keys.sort(key=lambda opt : int(opt[len(OPT_ENS_NAME):]))
    # Load the configuration and the metadata macros.
    config_loader = rose.config.ConfigLoader()
    app_config, config_map = config_loader.load_with_opts(
        config_file_path, more_keys=optional_keys,
        return_config_map=True)
    rose.macro.standard_format_config(app_config)
    for conf_key, config in config_map.items():
        rose.macro.standard_format_config(config)

    return app_config, config_map, config_name

def load_extra_modules(config, opts):

    global stash
    global widget
    global META_DIR

    meta_path, warning = rose.macro.load_meta_path(config, opts.conf_dir, no_warn=opts.no_warn)

    if meta_path is None:
       text = rose.macro.ERROR_LOAD_METADATA.format("")
       if warning:
           text = warning
       rose.reporter.Reporter()(text,
                                kind=rose.reporter.Reporter.KIND_ERR,
                                level=rose.reporter.Reporter.FAIL)
       sys.exit(1)
    #elif warning:
    #    rose.reporter.Reporter()(
    #        warning,
    #        kind=rose.reporter.Reporter.KIND_ERR,
    #        level=rose.reporter.Reporter.FAIL)


    # Save meta directory to find STASH_to_CF.txt file
    META_DIR = meta_path

    meta_path = os.path.join(meta_path,"lib","python")
    sys.path.insert(0, meta_path)

    # For some reason "import macros.stash_handling_funcs as stash" gives error
    # "ImportError: No module named macros.stash_handling_funcs"
    # But this ways works???
    meta_path = os.path.join(meta_path,"macros")
    sys.path.insert(0, meta_path)

    try:
        import stash_handling_funcs as stash
        import widget.stash_parse
        import widget.stash
    except ImportError as e:
        rose.reporter.Reporter()(
            "ImportError: {0}".format(e),
            kind=rose.reporter.Reporter.KIND_ERR,
            level=rose.reporter.Reporter.FAIL)
        rose.reporter.Reporter()(
            "Module loading failed, is app for the UM? Meta-data PATH = {0}".format(META_DIR),
            kind=rose.reporter.Reporter.KIND_ERR,
            level=rose.reporter.Reporter.FAIL)
        sys.exit(1)

    # Remove paths added to sys.path
    sys.path.pop(0)
    sys.path.pop(0)

def create_iodef_xml(ens_size, contexts, options, dirname):
    """ create parent XIOS XML file"""

    filename = os.path.join(dirname,"iodef.xml")
    if (verbosity > 0):
        print "Writing XML file",filename

    sim = ET.Element("simulation")
  
    # Write any extra model contexts
  
    for val in contexts.values():
        context = ET.SubElement(sim, "context")
        context.set("id", val['id'])
        context.set("src", expandvars(val['src']))
  
    # Write UM atmos context(s)
  
    for ens_mem in range(ens_size+1):
  
        prefix2 = ""
        if (ens_size > 0):
            if (ens_mem == ens_size):
                prefix1 = ens_prefix
                prefix2 = ens_prefix
            else:
                prefix1 = ens_mem_prefix.format(ens_mem)
        else:
            prefix1 = ""
  
        context = ET.SubElement(sim, "context")
        context.set("id", prefix+prefix1)
  
        domain_def = ET.SubElement(context, "domain_definition")
        domain_def.set("src", os.path.join(dirname,prefix+"-domain_def.xml"))
  
        axis_def = ET.SubElement(context, "axis_definition")
        axis_def.set("src", os.path.join(dirname,prefix+"-axis_def.xml"))
  
        grid_def = ET.SubElement(context, "grid_definition")
        grid_def.set("src", os.path.join(dirname,prefix+"-grid"+prefix2+"_def.xml"))
  
        field_def = ET.SubElement(context, "field_definition")
        field_def.set("src", os.path.join(dirname,prefix+"-field"+prefix2+"_def.xml"))
  
        file_def = ET.SubElement(context, "file_definition")
        file_def.set("src", os.path.join(dirname,prefix+"-file"+prefix1+"_def.xml"))
  
    # Write XIOS options context
  
    context = ET.SubElement(sim, "context")
    context.set("id", "xios")
  
    var_def = ET.SubElement(context, "variable_definition")
  
    write_xml_var(var_def,options,'using_server','bool')
  
    use_oasis = write_xml_var(var_def,options,'using_oasis','bool',onlyIf='true')
    if (use_oasis):
        write_xml_var(var_def,options,'oasis_codes_id','string')
        write_xml_var(var_def,options,'call_oasis_enddef','bool',onlyIf='false')
  
    use_server2 = write_xml_var(var_def,options,'using_server2','bool',onlyIf='true')
    if use_server2:
        write_xml_var(var_def,options,'ratio_server2','int')
        write_xml_var(var_def,options,'number_pools_server2','int',onlyIfNot='0')
        server2_dist_file_memory = write_xml_var(var_def,options,'server2_dist_file_memory','bool',onlyIf='true')
        if server2_dist_file_memory:
            write_xml_var(var_def,options,'server2_dist_file_memory_ratio','double')
  
    write_xml_var(var_def,options,'optimal_buffer_size','string')
    write_xml_var(var_def,options,'buffer_size_factor','double')
    write_xml_var(var_def,options,'min_buffer_size','int')
  
    write_xml_var(var_def,options,'info_level','int')
    write_xml_var(var_def,options,'print_file','bool',onlyIf='true')
  
    indent(sim)
    ET.dump(sim)
    tree = ET.ElementTree(sim)
    try:
        tree.write(filename, xml_declaration=True)
    except TypeError:
        tree.write(filename)

def create_domain_xml(domains_dict, um_xios_options_dict, 
                      stash_reqs_dict, stash_master_dict, 
                      grid_refs, dirname, ens_size=None):
    """create XIOS xml files from the contents of a
       STASH domain profile list"""

    # Only write fixed domains (iopa==1-8) once for each grid and halo type
    write_grid = Vividict()
    for iopa in ('1','2','3','4','5','6','7','8'):
        for halo_type in halo_types:
            for grid_type in all_grids:
                write_grid[iopa][halo_type][grid_type] = True

    # Domain name suffix for fixed domain areas
    domain_suffix = {}
    domain_suffix['1'] = ''
    domain_suffix['2'] = '_90N_0'
    domain_suffix['3'] = '_0_90S'
    domain_suffix['4'] = '_90N_30N'
    domain_suffix['5'] = '_30S_90S'
    domain_suffix['6'] = '_30N_0'
    domain_suffix['7'] = '_0_30S'
    domain_suffix['8'] = '_30N_30S'

    do_ens = ens_size is not None and ens_size > 0
    l_regrid = 'l_regrid' in um_xios_options_dict and um_xios_options_dict['l_regrid'] == '.true.'

    # Initialise domain, axis and grid definition xml files
    domain_def = ET.Element("domain_definition")
    axis_def = ET.Element("axis_definition")
    grid_def = ET.Element("grid_definition")
    if (do_ens):
        grid_ens_def = ET.Element("grid_definition")

    # Write out all base domains (iopa ='1') for each halo type
    for halo_type in halo_types:
        for grid_name in all_grids:
            # Create domain xml file
            domain_id = prefix + '_' + grid_name + \
                halo_name[halo_type]
            domain = ET.SubElement(domain_def, "domain")
            domain.set("id", domain_id)
            domain.set("name", grid_name)
            write_grid['1'][halo_type][grid_name] = False

    if l_regrid:
        domain = ET.SubElement(domain_def, "domain")
        domain.set("id", prefix+"_regrid")
        domain.set("name", "regrid")

    #print '---- um_xios_options_dict = ',um_xios_options_dict
    #print '---- grid_refs = ',grid_refs
    #print '---- domains_dict = ',domains_dict.keys()
    for dom_name in domains_dict:
        #print '\n----', dom_name, domains_dict[dom_name]

        # Get unique grid types for this domain
        grids = set()
        for isec in stash_reqs_dict:
            for item in stash_reqs_dict[isec]:
                for stash_req in stash_reqs_dict[isec][item]:
                    #print '---- isec,item,dom_name,grid_type = ', \
                    #    isec,item,stash_req["dom_name"], \
                    #    stash_master_dict[isec][item]["grid_type"]
                    if (stash_req["dom_name"] == dom_name):
                        grids.add(stash_master_dict[isec][item]["grid_type"])

        # Get vertical levels info
        nlev,levs = get_vert_levels(domains_dict[dom_name])

        iopa = domains_dict[dom_name]["iopa"]
        iopl = domains_dict[dom_name]["iopl"]

        if (iopa == "9" or iopa == "10"):
           domain_suffix[iopa] = '_' + dom_name

        # If vertical levels defined create axis xml file
        if (iopl != '5'):
            axis = ET.SubElement(axis_def, "axis")
            axis_id = prefix + '_' + dom_name
            axis.set("id", axis_id)
            axis.set("n_glo",str(nlev))
            axis.set("value",levs)
            axis.set("name", dom_name)

            set_axis_metadata(iopl,axis)

        if not grids:
            continue
        #print '---- halo_types = ',halo_types
        #print '---- grids = ',grids
        for halo_type in halo_types:
            #print '---- halo_type = ',halo_type
            for grid_name in grids:
                # Check if this grid is being used
                grid_id = prefix + '_' + grid_name + \
                    halo_name[halo_type] + '_' + dom_name
                #print '---- grid_id = ',grid_id
                if (grid_id not in grid_refs):
                    continue
                #print '-------- ',dom_name,halo_type,grid_name

                # Create domain xml file
                domain_id = prefix + '_' + grid_name + \
                    halo_name[halo_type] + domain_suffix[iopa]
                if ((iopa >= "1" and iopa <= "8" and 
                     write_grid[iopa][halo_type][grid_name]) or
                     iopa == "9" or iopa == "10"):
                    domain = ET.SubElement(domain_def, "domain")
                    domain.set("id", domain_id)
                    domain.set("name", grid_name + domain_suffix[iopa])
                    write_grid[iopa][halo_type][grid_name] = False

                # Create grid xml file
                grid = ET.SubElement(grid_def, "grid")
                grid.set("id", grid_id)

                # Reference domain
                domain = ET.SubElement(grid, "domain")
                domain.set("domain_ref", domain_id)

                # If vertical level defined reference axis
                if (iopl != '5'):
                    axis = ET.SubElement(grid, "axis")
                    axis.set("axis_ref", axis_id)

                # Do the same for ensemble context grid xml file
                if (do_ens):
                    grid = ET.SubElement(grid_ens_def, "grid")
                    grid.set("id", grid_id)

                    # Reference domain
                    domain = ET.SubElement(grid, "domain")
                    domain.set("domain_ref", domain_id)

                    # If vertical level defined reference axis
                    if (iopl != '5'):
                        axis = ET.SubElement(grid, "axis")
                        axis.set("axis_ref", axis_id)

                    # Add reference to ensemble axis
                    axis = ET.SubElement(grid, "axis")
                    axis.set("axis_ref", "ensemble")

        if (l_regrid):
            halo_type = 'none'
            grid_name = 'regrid'
            # Check if this grid is being used
            grid_id = prefix + '_' + grid_name + \
                halo_name[halo_type] + '_' + dom_name
            #print '---- grid_id = ',grid_id
            if (grid_id not in grid_refs):
                continue
            #print '-------- ',dom_name,halo_type,grid_name

            # Create domain xml file
            domain_id = prefix + '_' + grid_name + \
                halo_name[halo_type] + domain_suffix[iopa]
            if ((iopa >= "1" and iopa <= "8" and 
                 write_grid[iopa][halo_type][grid_name]) or
                 iopa == "9" or iopa == "10"):
                domain = ET.SubElement(domain_def, "domain")
                domain.set("id", domain_id)
                domain.set("name", grid_name + domain_suffix[iopa])
                write_grid[iopa][halo_type][grid_name] = False

            # Create grid xml file
            grid = ET.SubElement(grid_def, "grid")
            grid.set("id", grid_id)

            # Reference domain
            domain = ET.SubElement(grid, "domain")
            domain.set("domain_ref", domain_id)
            interp = ET.SubElement(domain, "interpolate_domain")
            interp.set("order", um_xios_options_dict['interp_order'])

            # If vertical level defined reference axis
            if (iopl != '5'):
                axis = ET.SubElement(grid, "axis")
                axis.set("axis_ref", axis_id)

            # Do the same for ensemble context grid xml file
            if (do_ens):
                grid = ET.SubElement(grid_ens_def, "grid")
                grid.set("id", grid_id)

                # Reference domain
                domain = ET.SubElement(grid, "domain")
                domain.set("domain_ref", domain_id)

                # If vertical level defined reference axis
                if (iopl != '5'):
                    axis = ET.SubElement(grid, "axis")
                    axis.set("axis_ref", axis_id)

                # Add reference to ensemble axis
                axis = ET.SubElement(grid, "axis")
                axis.set("axis_ref", "ensemble")

    # Define ensemble axis (Rest of definition done in UM)
    if (do_ens):
        axis = ET.SubElement(axis_def, "axis")
        axis.set("id", "ensemble")

    # Write out domain xml file.
    # Valid for all ensembles members contexts and ensemble context

    indent(domain_def)
    #ET.dump(domain_def)
    tree = ET.ElementTree(domain_def)
    filename = os.path.join(dirname,prefix+"-domain_def.xml")
    if (verbosity > 0):
        print "Writing XML file",filename
    tree.write(filename)

    # Write out axis and grid xml files.
    # Valid for all ensembles members contexts

    indent(axis_def)
    #ET.dump(axis_def)
    tree = ET.ElementTree(axis_def)
    filename = os.path.join(dirname,prefix+"-axis_def.xml")
    if (verbosity > 0):
        print "Writing XML file",filename
    tree.write(filename)

    indent(grid_def)
    #ET.dump(grid_def)
    tree = ET.ElementTree(grid_def)
    filename = os.path.join(dirname,prefix+"-grid_def.xml")
    if (verbosity > 0):
        print "Writing XML file",filename
    tree.write(filename)

    if (do_ens):

        # Write grid xml files.
        # Valid for ensemble context only

        indent(grid_ens_def)
        #ET.dump(grid_ens_def)
        tree = ET.ElementTree(grid_ens_def)
        filename = os.path.join(dirname,prefix+"-grid_ens_def.xml")
        if (verbosity > 0):
            print "Writing XML file",filename
        tree.write(filename)

def create_streq_xml(stash_reqs_dict, stash_master_dict, cf_dict, um_xios_options_dict, 
                     dirname, ens_size = None):
    """create XIOS xml file from the contents of a STASH list"""

    do_ens = ens_size is not None and ens_size > 0
    l_regrid = 'l_regrid' in um_xios_options_dict and um_xios_options_dict['l_regrid'] == '.true.'

    field_def = ET.Element("field_definition")
    field_def.set("prec", um_xios_options_dict['prec'])
    rmdi = -32768.0*32768.0
    field_def.set("default_value", str(rmdi))

    grid_refs = set()
    for isec in sorted(stash_reqs_dict,key=int):
        for item in sorted(stash_reqs_dict[isec],key=int):
            for stash_req in sorted(stash_reqs_dict[isec][item],
                    key=itemgetter('id')):
                dup = stash_req["dup"]
                # Don't include duplicates in field definition
                if (dup is not None):
                    continue
                dom_name = stash_req["dom_name"]
                included = stash_req["included"]
                id = stash_req["id"]
                stash_name = stash_master_dict[isec][item]["name"]
                grid_type = stash_master_dict[isec][item]["grid_type"]
                halo_type = stash_master_dict[isec][item]["halo_type"]

                grid_ref = prefix + '_' + grid_type + \
                    halo_name[halo_type] + '_' + dom_name
                grid_refs.add(grid_ref)
                enabled = (".TRUE." if included == "Yes" else ".FALSE.")

                field = ET.SubElement(field_def, "field")
                field.set("id", id)
                field.set("grid_ref", grid_ref)
                field.set("long_name", stash_name)
                field.set("enabled", enabled)
                try:
                    standard_name = cf_dict[isec][item]["standard_name"]
                    if (len(standard_name) > 0):
                        field.set("standard_name", standard_name)
                    units = cf_dict[isec][item]["units"]
                    if (len(units) > 0):
                        field.set("unit", units)
                except KeyError:
                    pass

                if l_regrid:

                    regrid_id = id + '_regrid'
                    regrid_ref = prefix + '_regrid_' + dom_name
                    grid_refs.add(regrid_ref)

                    field = ET.SubElement(field_def, "field")
                    field.set("field_ref", id)
                    field.set("grid_ref", regrid_ref)
                    field.set("id", regrid_id)
                    field.set("enabled", enabled)

    indent(field_def)
    #ET.dump(field_def)
    tree = ET.ElementTree(field_def)
    filename = os.path.join(dirname,prefix+"-field_def.xml")
    if (verbosity > 0):
        print "Writing XML file",filename
    tree.write(filename)

    if (do_ens):

        # Write field xml files.
        # Valid for ensemble context only

        indent(field_def)
        #ET.dump(field_def)
        tree = ET.ElementTree(field_def)
        filename = os.path.join(dirname,prefix+"-field_ens_def.xml")
        if (verbosity > 0):
            print "Writing XML file",filename
        tree.write(filename)

    return grid_refs

def write_xml_var(var_def,dict,id,type,onlyIf=None,onlyIfNot=None):

    write = id in dict  and (onlyIf is None or dict[id] == onlyIf) \
                        and (onlyIfNot is None or dict[id] != onlyIfNot)
    if write:
        var = ET.SubElement(var_def, "variable")
        var.set("id", id)
        var.set("type", type)
        var.text = dict[id]

    return write

def create_file_xml(stash_reqs_dict, output_streams_dict, usage_dict,
                    times_dict, um_xios_options_dict, dirname, 
                    ens_size = None, ens_mem = None):
    """create XIOS xml file for the output files"""

    file_def = ET.Element("file_definition")
    if (um_xios_options_dict['file_type'] == '1'):
        file_def.set("type", "one_file")
    elif (um_xios_options_dict['file_type'] == '2'):
        file_def.set("type", "multiple_file")
    if (um_xios_options_dict['format'] == '1'):
        file_def.set("format", "netcdf4")
    elif (um_xios_options_dict['format'] == '2'):
        file_def.set("format", "netcdf4_classic")
    #file_def.set("sync_freq", "3h")
    #file_def.set("min_digits", "4")
    #file_def.set("time_counter", "record")
    file_def.set("time_counter", "instant")

    #file_grp = ET.SubElement(file_def,"file_group")
    #file_grp.set("id", "3h")
    #file_grp.set("output_freq", "3h")
    #file_grp.set("split_freq", "1d")

    l_regrid = 'l_regrid' in um_xios_options_dict and um_xios_options_dict['l_regrid'] == '.true.'
    file = {}

    for file_id in sorted(output_streams_dict):

        #file = ET.SubElement(file_grp,"file")
        file[file_id] = ET.SubElement(file_def,"file")
        if l_regrid:
            file_id_regrid = file_id + '_regrid'
            file[file_id_regrid] = ET.SubElement(file_def,"file")

        output_stream = output_streams_dict[file_id]
        output_freq = output_stream["output_freq_value"] + \
            xios_units[int(output_stream["output_freq_unit"])]
        compression_level = output_stream["compression_level"]
        l_reinit = output_stream["l_reinit"]

        if l_reinit == ".false.":
            filename = output_stream["filename"]
            filename = expandvars(filename)
        else:
            filename = output_stream["filename_base"]
            filename = expandvars(filename)
            try:
                split_freq_format = filename[filename.index('%'):]
            except ValueError:
                pass
            else:
                #file.set("split_freq_format", split_freq_format)
                filename = filename[:filename.index('%')]

            split_freq = output_stream["reinit_step"] + \
                xios_units[int(output_stream["reinit_unit"])]
            file[file_id].set("split_freq", split_freq)

        file[file_id].set("id", file_id)
        file[file_id].set("name", filename)
        file[file_id].set("description", "UM output")
        file[file_id].set("output_freq", output_freq)
        if int(compression_level) > 0:
            file[file_id].set("compression_level", compression_level)

        if l_regrid:
            file[file_id_regrid].set("id", file_id_regrid)
            file[file_id_regrid].set("name", filename + '_regrid')
            file[file_id_regrid].set("description", "UM output")
            file[file_id_regrid].set("output_freq", output_freq)
            if l_reinit == ".true.":
                file[file_id_regrid].set("split_freq", split_freq)
            if int(compression_level) > 0:
                file[file_id_regrid].set("compression_level", compression_level)

    for isec in sorted(stash_reqs_dict,key=int):
        for item in sorted(stash_reqs_dict[isec],key=int):
            for stash_req in sorted(stash_reqs_dict[isec][item],
                    key=itemgetter('id')):
                included = stash_req["included"]
                if (included == "Yes"):
                    dup = stash_req["dup"]
                    use_name = stash_req["use_name"]
                    tim_name = stash_req["tim_name"]
                    if (dup is None):
                        id = stash_req["id"]
                    else:
                        id = stash_req["dup"]
                    name = stash_req["id"]
                    file_id = usage_dict[use_name]["file_id"]
                    ityp = int(times_dict[tim_name]["ityp"])

                    field = ET.SubElement(file[file_id], "field")
                    field.set("field_ref", id)
                    field.set("name", name)
                    field.set("operation", xios_operation[ityp])

                    if l_regrid:

                        regrid_id = id + '_regrid'
                        regrid_name = name + '_regrid'

                        field = ET.SubElement(file[file_id_regrid], "field")
                        field.set("field_ref", regrid_id)
                        field.set("name", regrid_name)
                        field.set("operation", xios_operation[ityp])

    indent(file_def)
    #ET.dump(file_def)
    tree = ET.ElementTree(file_def)

    if (ens_size is None or ens_size <= 0):
        filename = os.path.join(dirname,prefix+"-file_def.xml")
    elif (ens_mem is not None and ens_mem >= 0):
        filename = os.path.join(dirname,prefix+"-file_ens_mem{0}_def.xml".format(ens_mem))
    else:
        filename = os.path.join(dirname,prefix+"-file_ens_def.xml")
    if (verbosity > 0):
        print "Writing XML file",filename
    tree.write(filename)

def set_axis_metadata(iopl, axis):
    """Add metadata for vertical axis"""

    if (iopl == '1'):
        # Model rho levels
        axis.set("standard_name", "model_level_number")
        axis.set("long_name", "model rho levels (Charney-Phillips grid)")
        axis.set("unit", "1")
        axis.set("positive", "up")
    elif (iopl == '2'):
        # Model theta levels
        axis.set("standard_name", "model_level_number")
        axis.set("long_name", "model theta levels (Charney-Phillips grid)")
        axis.set("unit", "1")
        axis.set("positive", "up")
    elif (iopl == '3'):
        # Pressure levels (hPa)
        axis.set("standard_name", "air_pressure")
        axis.set("long_name", "pressure levels")
        axis.set("unit", "hPa")
        axis.set("positive", "down")
    elif (iopl == '4'):
        # Geometric height levels
        axis.set("standard_name", "altitude")
        axis.set("long_name", "geometric height levels")
        axis.set("unit", "m")
        axis.set("positive", "up")
    elif (iopl == '6'):
        # Model soil levels
        axis.set("standard_name", "model_level_number")
        axis.set("long_name", "soil model level number")
        axis.set("unit", "1")
        axis.set("positive", "down")
    elif (iopl == '7'):
        # Constant theta surfaces (K)
        axis.set("standard_name", "air_potential_temperature")
        axis.set("long_name", "constant theta surfaces")
        axis.set("unit", "K")
        axis.set("positive", "down")
    elif (iopl == '8'):
        # Potential vorticity levels
        axis.set("standard_name", "ertel_potential_vorticity")
        axis.set("long_name", "potential vorticity levels")
        axis.set("unit", "K m2 kg-1 s-1")
        axis.set("positive", "up")
    elif (iopl == '9'):
        # Cloud threshold levels
        #axis.set("standard_name", "")
        axis.set("long_name", "cloud threshold levels")
        #axis.set("unit", "")
        #axis.set("positive", "")

def get_vert_levels (domain):

    iopl = domain["iopl"]
    nlevs = 1
    levs = None
    if (iopl == '1' or iopl == '2' or iopl == '6'):
        ilevs = domain["ilevs"]
        if (ilevs == "1"):
            # Top and bottom level numbers given
            levb =  int(domain["levb"])
            levt =  int(domain["levt"])
            vert_list = range(levb,levt+1)
        elif (ilevs == "2"):
            # Level numbers specified in levlst
            vert_list = domain["levlst"].split(',')
    elif (iopl == '3' or iopl == '4' or iopl == '7' or 
          iopl == '8' or iopl == '9'):
        # Vertical level values specified in rlevlst
        vert_list = domain["rlevlst"].split(',')
    else:
        # either iopl=5 or something has gone wrong
        return nlevs, levs

    nlevs = len(vert_list)
    levs = '(0,' + str(nlevs-1) + ')['
    for val in vert_list:
        levs += str(val) + ' '
    levs = levs[:-1] + ']'

    return nlevs, levs

def get_item_value(node, key, handle_exception=False):
    """Get the value for a given key in a config node object providing a
       safe value if the rose-app config file is malformed when 
       handle_exception is True"""

    if (handle_exception):
        try:
            value = node.get([key]).value.strip(" '")
        except:
            value = "! missing !"
    else:
        value = node.get([key]).value.strip(" '")

    return value

# in-place prettyprint formatter for ElementTree
def indent(elem, level=0):
  i = "\n" + level*"  "
  if len(elem):
    if not elem.text or not elem.text.strip():
      elem.text = i + "  "
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
    for elem in elem:
      indent(elem, level+1)
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
  else:
    if level and (not elem.tail or not elem.tail.strip()):
      elem.tail = i

# Initialise nested dictionaries with this
class Vividict(dict):
    def __missing__(self, key):
        value = self[key] = type(self)()
        return value

def set_env(stuff_to_find, config):
    """Set environment variables from the [env] section of config"""

    messages, env_config = stash.filter_on_match(stuff_to_find, config)

    for node_key, node in env_config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored environment variables
        if node.state is not "":
            continue

        if (verbosity > 2): print "\nSetting environment variables:\n"

        for key,node1 in node.walk(no_ignore=False):

            # Not interested in ignored environment variables
            if node1.state is not "":
                continue

            value = expandvars(get_item_value(node1,None))
            if (verbosity > 2): print key[1],value
            os.environ[key[1]] = value

        if (verbosity > 2): print "\n"

def get_stash_domains(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a STASH domain profile namelist"""

    domains_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored streams
        if node.state is not "":
            continue

        try:
            dom_name = get_item_value(node, "dom_name")
        except:
            print "Error trying to handle domain data from node:"
            stash.debug_print_node(node, node_key, "get_stash_domains")
            raise

        domains_dict[dom_name] = {}

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    domains_dict[dom_name][key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle domain data from node:"
                    stash.debug_print_node(node, node_key, "get_stash_domains")
                    raise

    return domains_dict

def get_stash_times(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a STASH time profile namelist"""

    times_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored streams
        if node.state is not "":
            continue

        try:
            tim_name = get_item_value(node, "tim_name")
        except:
            print "Error trying to handle time data from node:"
            stash.debug_print_node(node, node_key, "get_stash_times")
            raise

        times_dict[tim_name] = {}

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    times_dict[tim_name][key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle time data from node:"
                    stash.debug_print_node(node, node_key, "get_stash_times")
                    raise

    return times_dict

def get_stash_usage(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a STASH usage profile namelist"""

    usage_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored streams
        if node.state is not "":
            continue

        try:
            use_name = get_item_value(node, "use_name")
        except:
            print "Error trying to handle usage data from node:"
            stash.debug_print_node(node, node_key, "get_stash_usage")
            raise

        usage_dict[use_name] = {}

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    usage_dict[use_name][key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle usage data from node:"
                    stash.debug_print_node(node, node_key, "get_stash_usage")
                    raise

    return usage_dict

def get_stash_ens(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a STASH ensemble profile namelist"""

    ens_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored streams
        if node.state is not "":
            continue

        try:
            ens_name = get_item_value(node, "ens_name")
        except:
            print "Error trying to handle ensemble data from node:"
            stash.debug_print_node(node, node_key, "get_stash_ens")
            raise

        ens_dict[ens_name] = {}

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    ens_dict[ens_name][key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle ensemble data from node:"
                    stash.debug_print_node(node, node_key, "get_stash_ens")
                    raise

    return ens_dict

def get_output_streams(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a xios output stream namelist"""

    output_streams_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored streams
        if node.state is not "":
            continue

        try:
            file_id = get_item_value(node, "file_id")
        except:
            print "Error trying to handle output stream data from node:"
            stash.debug_print_node(node, node_key, "get_output_streams")
            raise

        output_streams_dict[file_id] = {}

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    output_streams_dict[file_id][key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle output stream data from node:"
                    stash.debug_print_node(node, node_key, "get_output_streams")
                    raise

    return output_streams_dict

def get_options(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a options namelist/section"""

    options_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored xios options
        if node.state is not "":
            continue

        for key,node1 in node.walk(no_ignore=False):
            options_dict[key[1]] = get_item_value(node1,None)

    return options_dict

def get_contexts(config):
    """Take a nested config node object and return a dictionary containing
       the elements of a options namelist/section"""

    contexts_dict = {}

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored xios options
        if node.state is not "":
            continue

        try:
            id = get_item_value(node, "id")
        except:
            print "Error trying to handle usage data from node:"
            stash.debug_print_node(node, node_key, "get_contexts")
            raise

        contexts_dict[id] = {}

        for key,node1 in node.walk(no_ignore=False):
            contexts_dict[id][key[1]] = get_item_value(node1,None)

    return contexts_dict

def get_stash_reqs(config, usage_dict):
    """Take a nested config node object and return a dictionary containing
       the elements of a STASH request namelist"""

    stash_reqs_dict = Vividict()

    for node_key, node in config.walk(no_ignore=False):
        # Skip top level info, looking only for config nodes (dictionaries)
        if not isinstance(node.value, dict):
            continue

        # Not interested in ignored STASH requests
        if node.state is not "":
            continue

        try:
            use_name = get_item_value(node, "use_name")
        except:
            print "Error trying to handle STASH Request data from node:"
            stash.debug_print_node(node, node_key, "get_stash_reqs")
            raise

        if node.state is "":
            included = "Yes"
        else:
            included = stash._INCLUDED_DICT[node.state]

        stash_entry_dict = {}
        stash_entry_dict["included"] = included

        for key,node1 in node.walk(no_ignore=False):
            if node1.state is "":
                try:
                    stash_entry_dict[key[1]] = get_item_value(node1,None)
                except:
                    print "Error trying to handle STASH Request data from node:"
                    stash.debug_print_node(node, node_key, "get_stash_reqs")
                    raise

        try:
            isec = get_item_value(node, "isec")
            item = get_item_value(node, "item")
        except:
            print "Error trying to handle STASH Request data from node:"
            stash.debug_print_node(node, node_key, "get_stash_reqs")
            raise

        if not isinstance(stash_reqs_dict[isec][item], list):
            stash_reqs_dict[isec][item] = []
        stash_reqs_dict[isec][item].append(stash_entry_dict)

    # Add extra entries to STASH requests dictionary
    update_stash_reqs(stash_reqs_dict)

    return stash_reqs_dict

def update_stash_reqs(stash_reqs_dict):
    """Add field ID to stash_reqs_dict.
       Check stash_reqs_dict for duplicate entries, time and usage profile 
       information isn't taken into account"""

    for isec in sorted(stash_reqs_dict,key=int):
        for item in sorted(stash_reqs_dict[isec],key=int):
            num_reqs = 0
            for stash_req in sorted(sorted(stash_reqs_dict[isec][item],
                    key=itemgetter('dom_name','tim_name','use_name')),
                    key=itemgetter('included'), reverse=True):

                num_reqs += 1
                id = 'm01s{0:02d}i{1:03d}'.format(int(isec),int(item))
                if (num_reqs > 1):
                    id += '_' + str(num_reqs)

                stash_req["id"] = id

    # Check for entries with the same STASH item/section numbers 
    # and the same domain profile
    for isec in stash_reqs_dict:
        for item in stash_reqs_dict[isec]:
            for stash_req in sorted(stash_reqs_dict[isec][item],
                    key=itemgetter('id'), reverse=True):
                stash_req["dup"] = None
                for stash_req2 in sorted(stash_reqs_dict[isec][item],
                        key=itemgetter('id')):
                    # Don't check entry against itself
                    if (stash_req["id"] == stash_req2["id"]):
                        continue
                    # Don't check entry against a duplicate
                    if ("dup" in stash_req2 and stash_req2["dup"] is not None):
                        continue

                    #print "-------",stash_req["id"],stash_req2["id"]
                    if (stash_req["dom_name"] == stash_req2["dom_name"]):
                        #print "------- duplicate found"
                        stash_req["dup"] = stash_req2["id"]
                        break


def get_stash_master_info(config):
    """Create nested dictionary of selected items from STASHmaster records"""
    # Find the STASHmaster and get the nested dictionary of
    # STASHmaster records.
    #print "\nSTASHMASTER_PATH =",widget.stash.STASHMASTER_PATH
    parser = widget.stash_parse.StashMasterParserv1(
                                             widget.stash.STASHMASTER_PATH)
    lookup_dict = parser.get_lookup_dict()

    stash_master_dict = Vividict()

    for node_key, node in config.walk(no_ignore=False):
        if not isinstance(node.value, dict):
            continue

        try:
            isec = get_item_value(node, "isec")
            item = get_item_value(node, "item")

            if item not in lookup_dict[isec]:
                if (verbosity > 0):
                    print 'Item',item,'not in section',isec
                continue

            stash_master_dict[isec][item]["name"] = lookup_dict[isec][item]["name"]

            grid = lookup_dict[isec][item]["grid"]
            # See UM documentation paper C04, section C2, Grid 
            # for the meaning of these numbers
            if (grid ==  '1' or grid ==  '2' or grid ==  '3' or grid == '4' or
                grid ==  '5' or grid == '17' or grid == '21' or
                grid == '22' or grid == '26' or grid == '29'):
                grid_type = 'grid_t'
            elif (grid == '18' or grid == '27'):
                grid_type = 'grid_cu'
            elif (grid == '19' or grid == '28'):
                grid_type = 'grid_cv'
            elif (grid == '11' or grid == '12'or grid == '13' or
                  grid == '14' or grid == '15'):
                grid_type = 'grid_uv'
            elif (grid == '23'):
                grid_type = 'grid_r'
            stash_master_dict[isec][item]["grid_type"] = grid_type

            halo = lookup_dict[isec][item]["halo"]
            # See UM documentation paper C04, section C3, Halo 
            # for the meaning of these numbers
            if (halo == '1'):
                halo_type = 'single'
            elif (halo == '2'):
                halo_type = 'extended'
            elif (halo == '3'):
                halo_type = 'none'
            stash_master_dict[isec][item]["halo_type"] = halo_type
        except:
            print "Error trying to handle STASHmaster data:"
            stash.debug_print_node(node, node_key, "get_stash_master_info")
            raise

    return stash_master_dict

def get_cf_info(rotated):
    """Read STASH_to_CF.txt to create nested dictionary with section,item 
       as the keys and standard_name,units as key,value pair"""

    stash_to_cf=os.path.join(META_DIR, 'etc', 'STASH2CF', 'STASH_to_CF.txt')

    cf_dict = Vividict()
    with open(stash_to_cf, 'r') as csvfile:

        reader = csv.reader(csvfile,delimiter='!',skipinitialspace=True)
        for line in reader:
            if line[0].startswith('#'):
                continue
            isec = line[0]
            item = line[1]
            pp_extra = line[5]
            if (len(pp_extra) == 0 or 
                (rotated and pp_extra == 'rotated_latitude_longitude') or
                (not rotated and pp_extra == 'true_latitude_longitude')):
                cf_dict[isec][item]["standard_name"] = line[2]
                cf_dict[isec][item]["units"] = line[3]

    return cf_dict

def expandvars (var):
    """expand all environment variables in var, recursively"""

    var1 = var
    index = 0
    maxindex = 100
    while True:
        var2 = os.path.expandvars(var1)
        if var1 == var2:
            break
        if index > maxindex:
            print 'WARNING possible infinite recursion expanding variable value',var2
            break
        var1 = var2
        index += 1

    return var1

def main():
    """Convert STASH configuration options into XIOS XML files"""

    rose.macro.add_meta_paths()
    opts, args = parse_args()
    print "opts =",opts
    print "args =",args

    global verbosity
    verbosity = opts.verbosity - opts.quietness

    # Get config data for xml app
    #opts.conf_dir = '/work/n02/n02/jwc/cylc-run/xmlapp/app/xml'
    opts.conf_dir = os.path.join(os.environ['ROSE_SUITE_DIR'],'app',os.environ['ROSE_TASK_NAME'])
    print 'opts.conf_dir =',opts.conf_dir
    return_objects = get_data_from_opts(opts)
    if return_objects is None:
        sys.exit(1)
    app_config, app_config_map, config_name, cur_conf_type = return_objects

    # Load needed macro and widget modules
    load_extra_modules(app_config, opts)

    # Set xml app environment varibles
    stuff_to_find = [(re.compile(r'env'), None, None)]
    conf_key = None
    config = app_config_map[conf_key]
    set_env(stuff_to_find, config)

    # Get output directory
    try:
        output_dir = expandvars(os.environ["XMLDIR"])
    except:
        output_dir = 'xmlfiles'
    if (verbosity > 1): print "Output directory =",output_dir

    # Get number of ensemble members if defined
    try:
        ens_size = int(expandvars(os.environ['NENS']))
    except:
        ens_size = 0
    if (verbosity > 1): print "Number of ensemble members =",ens_size

    stuff_to_find = [(IS_STASH, None, None)]
    messages, stash_config = stash.filter_on_match(stuff_to_find, config)

    stuff_to_find = [(IS_STASH_DOMAIN, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    domains_dict = get_stash_domains(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "Domain profiles:"
        for dom_name in domains_dict:
            print dom_name,domains_dict[dom_name]

    stuff_to_find = [(IS_STASH_TIME, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    times_dict = get_stash_times(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "Time profiles:"
        for tim_name in times_dict:
           print tim_name,times_dict[tim_name]

    stuff_to_find = [(IS_STASH_USAGE, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    usage_dict = get_stash_usage(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "Usage profiles:"
        for use_name in usage_dict:
            print use_name,usage_dict[use_name]

    stuff_to_find = [(IS_STASH_ENS, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    ens_dict = get_stash_ens(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "Ensemble profiles:"
        for ens_name in ens_dict:
           print ens_name,ens_dict[ens_name]

    stuff_to_find = [(IS_STASH_STREQ, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    stash_reqs_dict = get_stash_reqs(temp_config,usage_dict)

    if (verbosity > 2):
        print "\n\n\n"
        print "STASH requests:"
        for s in stash_reqs_dict:
            for i in stash_reqs_dict[s]:
                for stash_req in stash_reqs_dict[s][i]:
                    print s,i,stash_req

    # Get Selected information from STASHmaster file
    stash_master_dict = get_stash_master_info(temp_config)

    stuff_to_find = [(IS_UM_XIOS_STREAM, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,stash_config)
    output_streams_dict = get_output_streams(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "File streams:"
        for file_id in output_streams_dict:
            print file_id,output_streams_dict[file_id]

    stuff_to_find = [(IS_UM_XIOS_OPTIONS, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,config)
    um_xios_options_dict = get_options(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "UM XIOS Options:"
        print um_xios_options_dict

    rotated = 'is_rotated' in um_xios_options_dict and um_xios_options_dict['is_rotated'] == '.true.'
    cf_dict = get_cf_info(rotated)

    stuff_to_find = [(IS_XIOS_OPTIONS, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,config)
    xios_options_dict = get_options(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "XIOS Options:"
        print xios_options_dict

    stuff_to_find = [(IS_XIOS_CONTEXTS, None, None)]
    messages, temp_config = stash.filter_on_match(stuff_to_find,config)
    xios_contexts_dict = get_contexts(temp_config)

    if (verbosity > 2):
        print "\n\n\n"
        print "XIOS Contexts:"
        for id in xios_contexts_dict:
            print id,xios_contexts_dict[id]
        print "\n\n\n"

    # Create XIOS xml files directory
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)

    create_iodef_xml(ens_size,xios_contexts_dict,xios_options_dict,output_dir)
    grid_refs = create_streq_xml(stash_reqs_dict,stash_master_dict,cf_dict,
                                 um_xios_options_dict,output_dir,ens_size)
    create_domain_xml(domains_dict,um_xios_options_dict,
                      stash_reqs_dict,stash_master_dict,
                      grid_refs,output_dir,ens_size)
    create_file_xml(stash_reqs_dict,output_streams_dict,usage_dict,times_dict,
                    um_xios_options_dict,output_dir,ens_size)

    stuff_to_find = [(re.compile(r'env'), None, None)]
    for ens_mem in range(ens_size):
        conf_key = OPT_ENS_NAME + str(ens_mem)
        try:
            config = app_config_map[conf_key]
        except KeyError:
            config = None
            rose.reporter.Reporter()("Optional configuration file rose-app-{0}.conf doesn't exist".format(conf_key),
                                     kind=rose.reporter.Reporter.KIND_ERR,
                                     level=rose.reporter.Reporter.WARN)

        # Save current environment and restore for each ensemble
        _environ = dict(os.environ)
        try:
            if (config):
                set_env(stuff_to_find, config)
            create_file_xml(stash_reqs_dict,output_streams_dict,usage_dict,
                            times_dict,um_xios_options_dict,
                            output_dir,ens_size,ens_mem)
        finally:
            os.environ.clear()
            os.environ.update(_environ)

if __name__ == "__main__":
    main()
