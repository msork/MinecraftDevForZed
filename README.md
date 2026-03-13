<p align="center">
  
# Minecraft Development for Zed

[![Zed](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/zed-industries/zed/main/assets/badge/v0.json)](https://zed.dev)

## Info and Documentation

**THIS IS BASED ON THE INTELLIJ PLUGIN OF A SIMILAR NAME ([MinecraftDev](https://github.com/minecraft-dev/MinecraftDev))**

This repo is where I will host scripts for Zed that will create the necessary folders for developing Minecraft Mods and Plugins!
Feel free to contribute and hopefully we can make Zed a first party Minecraft Development IDE!

## [IN PROGRESS] - Initial Setup for UNIX Platforms (Linux / Mac / FreeBSD)

Please copy and paste this command to clone these scripts on UNIX Platforms:

`git clone --recurse-submodules https://github.com/msork/MinecraftDevForZed && cd MinecraftDevForZed`

Next, make the mcinit script executable and run it by following these commands:

`chmod +x ./mcinit.sh`

`./mcinit.sh` 

Now you will be able to run `mcgen <DIRECTORY> --<PLATFORM>` from anywhere. 

## [NOT STARTED] - Initial Setup for Windows Platforms (Windows 10/11)

TODO

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

- <a href="https://www.spongepowered.org/"><img src="assets/platform-icons/Sponge.png?raw=true" width="16" height="16"/> <b>Sponge</b><a/>

## Planned to be Supported Platforms

- <a href="https://spigotmc.org/"><img src="assets/platform-icons/Spigot.png?raw=true" width="16" height="16"/> <b>Spigot</b><a/> (<a href="https://papermc.io/"><img src="assets/platform-icons/Paper.png?raw=true" width="16" height="16"/> Paper<a/>)
- <a href="https://github.com/architectury/architectury-api"><img src="assets/platform-icons/Architectury.png?raw=true" width="16" height="16"/> <b>Architectury</b><a/>
- <a href="https://forums.minecraftforge.net/"><img src="assets/platform-icons/Forge.png?raw=true" width="16" height="16"/> <b>Forge</b><a/>
- <a href="https://neoforged.net/"><img src="assets/platform-icons/Neoforge.png?raw=true" width="16" height="16"/> <b>Neoforge</b><a/>
- <a href="https://fabricmc.net"><img src="assets/platform-icons/Fabric.png?raw=true" width="16" height="16"/> <b>Fabric</b><a/>
- <a href="https://quiltmc.org/"><img src="assets/platform-icons/Quilt.png?raw=true" width="16" height="16"/> <b>Quilt</b><a/>
- <a href="https://github.com/SpongePowered/Mixin"><img src="assets/platform-icons/Mixins.png?raw=true" width="16" height="16"/> <b>Mixins</b><a/>
- <a href="https://www.spigotmc.org/wiki/bungeecord/"><img src="assets/platform-icons/BungeeCord.png?raw=true" width="16" height="16"/> <b>BungeeCord</b><a/> (<a href="https://github.com/PaperMC/Waterfall"><img src="assets/platform-icons/Waterfall.png?raw=true" width="16" height="16"/> Waterfall<a/>)
- <a href="https://velocitypowered.com/"><img src="assets/platform-icons/Velocity.png?raw=true" width="16" height="16"/> <b>Velocity</b><a/>
- <a href="https://kyori.net/"><img src="assets/platform-icons/Adventure.png?raw=true" width="16" height="16"/> <b>Adventure</b><a/>
