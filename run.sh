#!/bin/bash

# dtb recompiler
# TG: @mochi_wwww / GIT: Jebaitedneko

[[ ! -f boot.img ]] && echo -e "Run\n\n\nsu\n\nsh img.sh\n\nexit\n\n\nand then re-run run.sh"  && exit
chmod +x dtb.py && python dtb.py boot.img &> /dev/null
mv dtb/*.dtb . && rm -rf dtb
grep "Qualcomm Technologies, Inc. SM8150 v2 SoC" *.dtb &> match
mv "$(cat match | cut -f2 -d: | column -t)" dtb && rm match && rm *.dtb
dtc -I dtb -O dts -o dts dtb &> /dev/null && rm dtb
function label() {
	sed -i "s/$1 {/$2: $1 {/g" "dts"
}
label "soc" "soc"
label "gpu_opp_table_v2" "gpu_opp"
label "qcom,gpu-pwrlevels-1" "gpu_pwrlvl"
label "lmh-dcvs-00" "lmh_0"
label "lmh-dcvs-01" "lmh_1"
cat "mod.dtsi" >> "dts"
sed -i "s/==> dts <==//g" "dts"
dtc -I dts -O dtb "dts" -o "dtb" &> /dev/null && rm "dts"
echo "Done."
[[ -f dtb-mod.zip ]] && rm dtb-mod.zip
mv dtb ak3 && ( cd ak3 && zip -r9 ../dtb-mod.zip * &> /dev/null ) && rm ak3/dtb
