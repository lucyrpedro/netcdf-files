mkdir -p attached_mode
mkdir -p servered_mode
mkdir -p TL_servered_mode

cp TP_src/* ./attached_mode
cp TP_src/* ./servered_mode
cp TP_src/* ./TL_servered_mode

rm -f attached_mode/TL_iodef.xml
rm -f attached_mode/run_servered
rm -f attached_mode/servered_param.def

rm -f servered_mode/TL_iodef.xml
rm -f servered_mode/run_attached
rm -f servered_mode/param.def
mv servered_mode/servered_param.def servered_mode/param.def

rm -f TL_servered_mode/iodef.xml
mv TL_servered_mode/TL_iodef.xml TL_servered_mode/iodef.xml
rm -f TL_servered_mode/run_attached
rm -f TL_servered_mode/param.def
mv TL_servered_mode/servered_param.def TL_servered_mode/param.def
