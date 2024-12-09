#!/bin/bash

# Download/Update CS2
/home/${USER}/steamcmd/steamcmd.sh \
    +api_logging 1 1 \
    +@sSteamCmdForcePlatformType linux \
    +@sSteamCmdForcePlatformBitness $BITS \
    +force_install_dir /home/${USER}/cs2_server/ \
    +login anonymous \
    +app_update 730 \
    +quit

# Download/Update Metamod
cd /home/steam/cs2_server/
wget https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1315-linux.tar.gz -O mmsource.tar.gz
tar -xzf mmsource.tar.gz -C /home/steam/cs2_server/steamapps/common/Counter-Strike\ Global\ Offensive/game/csgo/ && rm mmsource.tar.gz
PATTERN="Game_LowViolence[[:space:]]*csgo_lv // Perfect World content override"
LINE_TO_ADD="\t\t\tGame\tcsgo/addons/metamod"
REGEX_TO_CHECK="^[[:space:]]*Game[[:space:]]*csgo/addons/metamod"

if grep -qE "$REGEX_TO_CHECK" "$FILE"; then
    echo "$FILE already patched for Metamod."
else
    awk -v pattern="$PATTERN" -v lineToAdd="$LINE_TO_ADD" '{
        print $0;
        if ($0 ~ pattern) {
            print lineToAdd;
        }
    }' "$FILE" > tmp_file && mv tmp_file "$FILE"
    echo "$FILE successfully patched for Metamod."
fi

# Download/Update Sourcemod
wget https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v291/counterstrikesharp-build-291-linux-6349c11.zip -O counterstrikesharp.zip
unzip counterstrikesharp.zip -d /home/steam/cs2_server/steamapps/common/Counter-Strike\ Global\ Offensive/game/csgo/ && rm counterstrikesharp.zip

/home/steam/cs2_server/steamapps/common/Counter-Strike\ Global\ Offensive/game/bin/linuxsteamrt64/cs2 \
    -dedicated \
    -console \
    -usercon \
    -autoupdate \
    -tickrate 128 \
    +map de_dust2 \
    +game_type 0 \
    +game_mode 0 \
    +mapgroup mg_active \