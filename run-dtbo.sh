#!/bin/bash

# dtb recompiler
# TG: @mochi_wwww / GIT: Jebaitedneko

[[ ! -f dtbo-stock.img ]] && echo -e "Run\n\n\nsu\n\nsh img.sh\n\nexit\n\n\nand then re-run run-dtbo.sh" && exit
chmod +x dtb.py && python dtb.py dtbo-stock.img &> /dev/null && mv dtb dtbs
grep "VAYU" dtbs/*.dtb &> match
mv "$(cut -f2 -d: < match | column -t)" "./dtb" && rm match && rm -rf dtbs
dtc -I dtb -O dts -o dts dtb &> /dev/null && rm dtb
cp dts dts.old
function label() {
	sed -i "s/$1 {/$2: $1 {/g" "dts"
}
echo -e "\n" >> dts
function get_frag_num() {
	FRAG_NUM=$(grep -B4 $1 dts | tail -n5 | head -n1 | grep -oE '[0-9]+')
}
function push_node() {
	get_frag_num $1
	FIXUP=$(cat mod-dtbo.dtsi | sed "s/FRAG_NUM/$FRAG_NUM/g;s/NODE_NAME/$1/g;s/PROP/$(echo -e $2)/g")
	echo -e "/ { $FIXUP };" >> dts
}
sed -i "s/;;/;/g" "dts"
dtc -I dts -O dtb -o "dtb" "dts" &> /dev/null
dtc -I dtb -O dts -o "dts.new" "dtb" &> /dev/null
echo "Done."
echo -e "\nAutogenerated from dtbo-recompiler\nby MOCHI [TG: @mochi_wwww | GIT: @Jebaitedneko]\n" > ak3/banner
echo -e "$(diff -ur dts.old dts.new)" >> ak3/banner && rm dts.old dts.new dts
python mkdtboimg.py create dtbo.img --page_size=4096 dtb && rm dtb
[[ -f dtbo-mod.zip ]] && rm dtbo-mod.zip
mv dtbo.img ak3 && ( cd ak3 && zip -r9 ../dtbo-mod.zip ./* &> /dev/null ) && rm ak3/dtbo.img ak3/banner
[[ -d /sdcard ]] && mv *.zip /sdcard
