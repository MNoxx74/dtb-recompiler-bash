#!/bin/bash

# dtb recompiler
# TG: @mochi_wwww / GIT: Jebaitedneko

[[ ! -f boot.img ]] && echo -e "Run\n\n\nsu\n\nsh img.sh\n\nexit\n\n\nand then re-run run-dtb.sh"  && exit
chmod +x dtb.py && python dtb.py boot.img &> /dev/null && mv dtb dtbs
grep "Qualcomm Technologies, Inc. SM8150 v2 SoC" dtbs/*.dtb &> match
mv "$(cut -f2 -d: < match | column -t)" "./dtb" && rm match && rm -rf dtbs
dtc -I dtb -O dts -o dts dtb &> /dev/null && rm dtb
cp dts dts.old
function label() {
	sed -i "s/$1 {/$2: $1 {/g" "dts"
}
label "soc" "soc"
label "gpu_opp_table_v2" "gpu_opp"
label "qcom,gpu-pwrlevels-1" "gpu_pwrlvl"
label "lmh-dcvs-00" "lmh_0"
label "lmh-dcvs-01" "lmh_1"
cat "mod-dtb.dtsi" >> "dts"
sed -i "s/==> dts <==//g" "dts"
dtc -I dts -O dtb "dts" -o "dtb" &> /dev/null && rm "dts"
dtc -I dtb -O dts -o dts.new "dtb" &> /dev/null
echo "Done."
echo -e "\nAutogenerated from dtb-recompiler\nby MOCHI [TG: @mochi_wwww | GIT: @Jebaitedneko]\n" > ak3/banner
echo -e "$(diff -ur dts.old dts.new)" >> ak3/banner && rm dts.old dts.new
cat mod-dtb.dtsi >> ak3/banner
[[ -f dtb-mod.zip ]] && rm dtb-mod.zip
mv dtb ak3 && ( cd ak3 && zip -r9 ../dtb-mod.zip ./* &> /dev/null ) && rm ak3/dtb ak3/banner
[[ -d /sdcard ]] && mv *.zip /sdcard
