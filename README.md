<p align="center">
  
# Minecraft Development for Zed

[![Zed](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/zed-industries/zed/main/assets/badge/v0.json)](https://zed.dev)

## Info and Documentation

**THIS IS BASED ON THE INTELLIJ PLUGIN OF A SIMILAR NAME ([MinecraftDev](https://github.com/minecraft-dev/MinecraftDev))**

This repo is where I will host scripts for Zed that will create the necessary folders for developing Minecraft Mods and Plugins!
Feel free to contribute and hopefully we can make Zed a first party Minecraft Development IDE!

## Initial Setup for UNIX Platforms (Linux / Mac / FreeBSD)

Please copy and paste this command to clone these scripts on UNIX Platforms:

`git clone --recurse-submodules https://github.com/msork/MinecraftDevForZed && cd MinecraftDevForZed`

Next, make all relevant scripts executable and initialize the script by running these commands:

`chmod +x ./mcinit.sh && chmod +x ./unix-scripts/*.sh`

`./mcinit.sh` 

Now you will be able to run `mcgen <DIRECTORY> --<PLATFORM>` from anywhere. 

## [IN PROGRESS] - Creating folders for Plugins

Depending on the plugin platform you'd like to use, add it as an argument to the mcgen.sh script.
For example this is how you generate the necessary folders for SpongeAPI in the ./spongeTest directory.:

`mcgen ./spongeTest --sponge`

Finally, you will get asked questions for initial setup, answer them and you will have the necessary folders for the plugin!

## [NOT STARTED] - Creating folders for Mods

Depending on the mod platform you'd like to use, add it as an argument to the mcgen.sh script.
For example this is how you generate the necessary folders for FabricAPI in the ./fabricTest directory.:

`mcgen ./fabricTest --fabric`

Finally, you will get asked questions for initial setup, answer them and you will have the necessary folders for the mod!

## [NOT STARTED] - Using JSON Files for Advanced Setup

When using any `mcgen` command, mcgen will generate json files for each project at $HOME/.mcgen/<PROJECT_NAME>.json.

You are able to use these json files to create your own json template that mcgen can use. This is for quicker setup.

Simply run the following command to use mcgen in json mode (for example with Spigot in the ./spigotTest folder with the json file in the user's Downloads folder):

`mcgen ./spigotTest --spigot --json ~/Downloads/spigotTest.json`

It will generate everything and if there are any empty or invalid values, it will ask you to clarify. Then it will generate the folders.

## Currently Supported Platforms

- [![Sponge Icon](assets/platform-icons/Sponge_dark.png?raw=true) **Sponge**](https://www.spongepowered.org/)

## Planned to be Supported Platforms

- [![Spigot Icon](assets/platform-icons/Spigot.png?raw=true) **Spigot**](https://spigotmc.org/) ([![Paper Icon](assets/platform-icons/Paper.png?raw=true) Paper](https://papermc.io/))
- [![Architectury Icon](assets/platform-icons/Architectury.png?raw=true) **Architectury**](https://github.com/architectury/architectury-api)
- [![Forge Icon](assets/platform-icons/Forge.png?raw=true) **Minecraft Forge**](https://forums.minecraftforge.net/)
- [![Neoforge Icon](assets/platform-icons/Neoforge.png?raw=true) **Neoforge**](https://neoforged.net)
- [![Fabric Icon](assets/platform-icons/Fabric.png?raw=true) **Fabric**](https://fabricmc.net)
- [![Mixins Icon](assets/platform-icons/Mixins.png?raw=true) **Mixins**](https://github.com/SpongePowered/Mixin)
- [![BungeeCord Icon](assets/platform-icons/BungeeCord.png?raw=true) **BungeeCord**](https://www.spigotmc.org/wiki/bungeecord/) ([![Waterfall Icon](assets/platform-icons/Waterfall.png?raw=true) Waterfall](https://github.com/PaperMC/Waterfall))
- [![Velocity Icon](assets/platform-icons/Velocity.png?raw=true) **Velocity**](https://velocitypowered.com/)
- [![Adventure Icon](assets/platform-icons/Adventure.png?raw=true) **Adventure**](https://kyori.net/)
- [![Quilt Icon](assets/platform-icons/Quilt.png?raw=true) **Quilt**](https://quiltmc.org/)
