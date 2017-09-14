#! /bin/bash
# Copied from https://github.com/bhurlow/machine-share

TARGET=$1
filename=$(basename "$TARGET")
FILENAME="${filename%.*}"

if [ -d "$HOME/.docker/machine/machines/$FILENAME" ] ; then
  echo "A machine with that name already exists"
  exit 1
fi

# cleanup
rm -rf /tmp/$FILENAME

# extract
unzip $TARGET -d /tmp/$FILENAME

# add correct $HOME var
cat /tmp/$FILENAME/config.json | sed -e "s:{{HOME}}:$HOME:g" > /tmp/$FILENAME/config.json.fixed
mv /tmp/$FILENAME/config.json.fixed /tmp/$FILENAME/config.json

mkdir -p $HOME/.docker/machine/machines/$FILENAME

# move it into docker machines files
cp -r /tmp/$FILENAME $HOME/.docker/machine/machines/

# update the stupid raw driver
#machine-driverfix $FILENAME

echo "Import of docker-machine $FILENAME was succesfull."
