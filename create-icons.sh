#!/bin/bash
# Creates an icns file from a source image

FILES="pngs/*.png"
for f in $FILES
do
    src_image="$f"

    basename="${src_image%%.*}"

    icns_name="$2"
    if [ -z "$2" ]; then
        icns_name="tmp"
    fi

    if [ "${src_image:(-3)}" != "png" ]; then
        echo "Source image is not a PNG, making a converted copy..."
        /usr/bin/sips -s format png "$src_image" --out "${src_image}.png"
        if [ $? -ne 0 ]; then
            echo "The source image could not be converted to PNG format."
            exit 1
        fi
        src_image="${src_image}.png"
    fi

    iconset_path="./${icns_name}.iconset"
    if [ -e "$iconset_path" ]; then
        /bin/rm -r "$iconset_path"
        if [ $? -ne 0 ]; then
            echo "There is a pre-existing file/dir $iconset_path the could not be deleted"
            exit 1
        fi
    fi

    /bin/mkdir "$iconset_path"

    icon_file_list=(
        "icon_16x16.png"
        "icon_16x16@2x.png"
        "icon_32x32.png"
        "icon_32x32@2x.png"
        "icon_128x128.png"
        "icon_128x128@2x.png"
        "icon_256x256.png"
        "icon_256x256@2x.png"
        "icon_512x512.png"
        "icon_512x512@2x.png"
        )

    icon_size=(
        '16'
        '32'
        '32'
        '64'
        '128'
        '256'
        '256'
        '512'
        '512'
        '1024'
        )

    counter=0

    for a in ${icon_file_list[@]}; do
        icon="${iconset_path}/${a}"
        /bin/cp "$src_image" "$icon"
        icon_size=${icon_size[$counter]}
        /usr/bin/sips -z $icon_size $icon_size "$icon"&>/dev/null
        counter=$(($counter + 1))
    done

    echo "Creating .icns file from $f"
    /usr/bin/iconutil -c icns "$iconset_path" &>/dev/null
    if [ $? -ne 0 ]; then
        echo "There was an error creating the .icns file"
        exit 1
    fi

    path=$src_image
    base=${path##*/}

    cp tmp.icns "icons/${base%.*}.icns"
done

echo "# macOS Application Icons" > readme.md
echo "| Icon  | _Get it_ |" >> readme.md
echo "| ------------- | ------------- |" >> readme.md

FILES="pngs/*.png"
for f in $FILES
do
    basename="${src_image%%.*}"
    path=$src_image
    base=${path##*/}
    echo "| <img src='${f}' width='370'>  | [.icns](icons/${base%.*}.icns) [.png](pngs/${base%.*}.png)  |" >> readme.md
done

exit 0