#!/bin/bash

# Download/Update CS2
steamcmd \
    +api_logging 1 1 \
    +@sSteamCmdForcePlatformType linux \
    +@sSteamCmdForcePlatformBitness $BITS \
    +force_install_dir /home/${USER}/cs2_server/ \
    +login anonymous \
    +app_update 730 \
    +quit

CS2_DIR="$HOME/cs2_server/game/csgo"
ADDONS_DIR="$CS2_DIR/addons"
METAMOD_DIR="$ADDONS_DIR/metamod"
MAPS_DIR="$CS2_DIR/maps"
CFG_DIR="$CS2_DIR/cfg"
CS_SHARP_DIR="$ADDONS_DIR/counterstrikesharp"
CS_SHARP_PLUGINS_DIR="$CS_SHARP_DIR/plugins"


# Create addons directory. Recreate if it already exists
if [[ -d "$ADDONS_DIR" ]] ; then
	echo "Addons directory already exists. Removing..."
	rm -rf $ADDONS_DIR
fi

echo "Creating addons directory"
mkdir -p $ADDONS_DIR

# Extract metamod if it doesn't exist
# https://docs.cssharp.dev/docs/guides/getting-started.html#installing-metamod
if [[ ! -d $METAMOD_DIR ]] ; then
	echo "Extracting metamod to $ADDONS_DIR"
	tar xfz /tmp/metamod.tar.gz -C $CS2_DIR
else
	echo "Metamod already installed"
fi


# Update gameinfo.gi to include Metamod
if [[ -f "$CS2_DIR/gameinfo.gi" ]] ; then
	echo "Found gameinfo.gi"

	if [[ -z $(grep "metamod" $CS2_DIR/gameinfo.gi) ]] ; then
		echo "Adding metamod to gameinfo.gi"
		sed -i -e "/Game_LowViolence/a\\
			Game	csgo\/addons\/metamod" $CS2_DIR/gameinfo.gi
	else
		echo "gameinfo.gi already updated"
	fi
else
	echo "WARNING: gameinfo.gi not found"
fi


# Download CounterStrikeSharp if it doesn't exist
# https://docs.cssharp.dev/docs/guides/getting-started.html#installing-counterstrikesharp
if [[ ! -d $CS_SHARP_DIR ]] ; then
	echo "Extracting CounterStrikeSharp to $ADDONS_DIR"

	# -q tells unzip to stfu
	# -o tells unzip to overwrite files without prompting
	unzip -qo /tmp/counterstrikesharp.zip -d $CS2_DIR
else
	echo "CounterStrikeSharp already installed"
fi

# Copy pre-baked CounterStrikeSharp plugins to plugins directory
# https://docs.cssharp.dev/docs/guides/hello-world-plugin.html#installing-your-plugin
for dir in /tmp/prebaked_plugins/*/; do
	plugin=$(basename $dir)
	
	if [[ ! -d "$CS_SHARP_PLUGINS_DIR/$plugin" ]] ; then
		echo "Copying plugin to server: $plugin"
		cp -r $dir $CS_SHARP_PLUGINS_DIR
	else
		echo "$plugin plugin already exists. Not copying."
	fi
done

# Copy prebaked configs to cfg directory
cp /tmp/prebaked_config/*.cfg $CFG_DIR


# Copy normalCounterStrikeSharp plugins to the server.
echo "Copying plugins to the server."
for zip in /tmp/plugins/*.zip; do
	unzip $zip -d $CS2_DIR
done

# Install plugins
cp ./gamemodes_server.txt $CS2_DIR

/home/steam/cs2_server/game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate 128 \
    +map de_dust2 \
    -maxplayers 24 \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \
    +sv_lan 0
