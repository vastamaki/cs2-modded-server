######## INSTALL ########

# Set the base image
FROM debian:12-slim

# Set environment variables
ENV USER steam
ENV HOME /home/${USER}

# Set working directory
RUN useradd -m "${USER}"
WORKDIR $HOME

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd wget unzip libicu-dev \
 && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
 && locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Update SteamCMD and verify latest version
RUN steamcmd +quit

# Fix missing directories and libraries
RUN mkdir -p $HOME/.steam \
 && mkdir -p $HOME/cs2_server \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux32 $HOME/.steam/sdk32 \
 && ln -s $HOME/.local/share/Steam/steamcmd/linux64 $HOME/.steam/sdk64 \
 && ln -s $HOME/.steam/sdk32/steamclient.so $HOME/.steam/sdk32/steamservice.so \
 && ln -s $HOME/.steam/sdk64/steamclient.so $HOME/.steam/sdk64/steamservice.so


# Download CSSharp and Metamod
RUN wget https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1315-linux.tar.gz -O /tmp/metamod.tar.gz
RUN wget https://github.com/roflmuffin/CounterStrikeSharp/releases/download/v291/counterstrikesharp-with-runtime-build-291-linux-6349c11.zip -O /tmp/counterstrikesharp.zip


# Download plugins
RUN wget https://github.com/nickj609/GameModeManager/releases/download/v1.0.50/GameModeManager_v1.0.50.zip -P /tmp/plugins/
RUN wget https://github.com/LordFetznschaedl/CS2Rcon/releases/download/1.2.0/CS2Rcon-1.2.0.zip -P /tmp/plugins/
RUN wget https://github.com/kus/CS2_ExecAfter/releases/download/v1.0.0/CS2_ExecAfter-1.0.0.zip -P /tmp/plugins/
RUN wget https://github.com/kus/CS2-Remove-Map-Weapons/releases/download/v1.0.1/CS2-Remove-Map-Weapons-1.0.1.zip -P /tmp/plugins/
RUN wget https://github.com/KitsuneLab-Development/CS2_DamageInfo/releases/download/v2.3.4/K4ryuuDamageInfo.zip -P /tmp/plugins/
RUN wget https://github.com/abnerfs/cs2-rockthevote/releases/download/v1.8.5/RockTheVote_v1.8.5.zip -P /tmp/plugins/
RUN wget https://github.com/shobhit-pathak/MatchZy/releases/download/0.8.7/MatchZy-0.8.7.zip -P /tmp/plugins/
RUN wget https://github.com/B3none/cs2-retakes/releases/download/20.0.16/cs2-retakes-20.0.16.zip -P /tmp/plugins/
RUN wget https://github.com/B3none/cs2-retakes/releases/download/20.0.16/cs2-retakes-shared-20.0.16.zip -P /tmp/plugins/
RUN wget https://github.com/B3none/cs2-instadefuse/releases/download/2.0.0/cs2-instadefuse-2.0.0.zip -P /tmp/plugins/
RUN wget https://github.com/yonilerner/cs2-retakes-allocator/releases/download/v2.3.17/cs2-retakes-allocator-v2.3.17.zip -P /tmp/plugins/
RUN wget https://github.com/zwolof/cs2-executes/releases/download/1.0.6/cs2-executes-1.0.6.zip -P /tmp/plugins/
RUN wget https://github.com/NockyCZ/CS2-Deathmatch/releases/download/v1.2.2/Deathmatch.zip -P /tmp/plugins/
RUN wget https://github.com/lengran/OpenPrefirePrac/releases/download/v0.1.41/OpenPrefirePrac-v0.1.41.zip -P /tmp/plugins/
RUN wget https://github.com/KitsuneLab-Development/K4-Arenas/releases/download/v1.5.3/K4-Arenas.zip -P /tmp/plugins/


# Download prebaked plugins
RUN mkdir /tmp/prebaked_plugins
RUN mkdir /tmp/prebaked_config

RUN chown -R ${USER}:${USER} $HOME
USER ${USER}
