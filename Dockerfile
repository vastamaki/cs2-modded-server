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
RUN wget https://github.com/nickj609/GameModeManager/releases/download/v1.0.50/GameModeManager_v1.0.50.zip -O /tmp/plugins/


RUN chown -R ${USER}:${USER} $HOME
USER ${USER}
