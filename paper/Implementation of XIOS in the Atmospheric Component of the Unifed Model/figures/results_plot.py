import csv
from collections import OrderedDict
from matplotlib import pyplot as plt
import numpy as np

class Result(object):
    def __init__(self,name):
        """ Initialise with name, monkey patch the rest"""
        self.data = None
        self.single = None
        self.multi = None
        self.name = name
    def __str__(self):
        """ If we have a data attribute return it in string form"""
        if self.data:
            return str(self.data)

def load_csvdata(filename, name):
    """
    Reads data from results csv.
    Expect headers in row 1 then arbitrary number of rows
    """

    def myint(x):
        try:
            return int(x)
        except:
            if x == '':
                return 0
            elif x =='TRUE':
                return 1
            elif x == 'FALSE':
                return 0
            else:
                raise ValueError('Unexpected input [%s]' % x )

    o = Result(name)

    with open(filename) as csvfile:
        reader = csv.reader(csvfile)
        header = reader.next()
        header = [h.decode('utf-8-sig').encode('utf-8') for h in header]
        data = OrderedDict()
        for h in header:
            data[h] = []
        column_indices = range(len(data))
        for r in reader:
            for i in column_indices:
                data[data.keys()[i]].append(myint(r[i]))

    o.data = data
    keys = [k for k in data.keys()]
    keys.remove('MultiFile')
    o.single = OrderedDict([(k,[]) for k in keys])
    o.multi = OrderedDict([(k,[]) for k in keys])
    for k in keys:
        for i in range(len(data['Members'])):
            if data['MultiFile'][i]:
                o.multi[k].append(data[k][i])
            else:
                o.single[k].append(data[k][i])
    return o

def process():

    files = [('n96.csv', 'N96'), ('n512.csv', 'N512')]

    color_choices = {'single':'red', 'multi':'blue'}
    marker_choices = {'N96':'s','N512':'o',2:'<'}
    line_choices = {1:'-',2:':'}


    fig, ax = plt.subplots()

    first_plot = True

    for f,n in files:
        data = load_csvdata(f,n)

        for a in ['single','multi']:

            x = getattr(data, a)['Members']
            y = getattr(data, a)['Wall Clock']
            s = getattr(data, a)['Series']

            for ss in [1, 2]:
                xx, yy = [], []
                for i, j, k in zip(x, y, s):
                    if i != 0 and k == ss:
                        xx.append(i)
                        yy.append(j)
                if len(xx) > 0:
                    if ss == 1:
                        marker = marker_choices[data.name]
                    else:
                        marker = marker_choices[ss]
                    print ss, xx, yy, marker
                    ax.scatter(xx, yy, c=color_choices[a], marker=marker,
                               label='%s:%s(%s)' % (data.name, a, ss))

                    z = np.polyfit(xx, yy, 3)
                    f = np.poly1d(z)
                    xn = np.linspace(xx[0], xx[-1], 10)
                    yn = f(xn)
                    ax.plot(xn, yn, color=color_choices[a], linestyle=line_choices[ss])



    ax.legend()
    #ax.set_xscale('log')
    ax.set_ylabel('Wall Clock (s)')
    ax.set_xlabel('Ensemble Size')

    plt.savefig('results.pdf')

def scaling():
    f = 'n512.csv'
    data = load_csvdata(f, 'N512')
    fig, ax = plt.subplots()
    color_choices = {'single': 'red', 'multi': 'blue'}
    marker_choices = {1:'s',2:'o'}
    line_choices = {1: '-', 2: ':'}

    for a in ['single','multi']:
        x = np.array(getattr(data, a)['Processors'])
        y = np.array(getattr(data, a)['Wall Clock'])
        s = getattr(data, a)['Series']
        for ss in [1,2]:
            xx, yy = [],[]
            for i,j,k in zip(x,y,s):
                if k == ss:
                    xx.append(i)
                    yy.append(j)
            if len(xx) > 0:
                yy = yy - yy[0]
                ax.scatter(xx, yy, color=color_choices[a], marker=marker_choices[ss],
                           label='%s(%s)'%(a,ss))

                z = np.polyfit(xx, yy, 3)
                f = np.poly1d(z)
                xn = np.linspace(xx[0], xx[-1], 10)
                yn = f(xn)
                ax.plot(xn, yn, color=color_choices[a], linestyle=line_choices[ss])

    ax.legend()
    ax.set_xlabel('Processors')
    ax.set_ylabel('Wall Clock wrt 1 ensemble member')
    ax.set_title('N512 - Processor Counts')

    plt.savefig('results-pe.pdf')




if __name__=="__main__":
    process()
    scaling()


