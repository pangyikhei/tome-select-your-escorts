-- Pick your Escort Addon
-- tome-select-your-escorts/init.lua

long_name = "Select your Escorts"
short_name = "select-your-escorts" -- Determines the name of your addon's file.
for_module = "tome"
version = {1,6,0}
addon_version = {2,2,0}
weight = 512 -- The lower this value, the sooner your addon will load compared to other addons.
author = {'Pseudoku'}
homepage = 'https://steamcommunity.com/id/Pseudoku/home'
description = [[Allows you to choose which escorts you will encounter at the start of the game.
You may change the future encounters in the game menu (Esc).

There is an option to choose a random escort in case you just wanted to guarantee some unlocks before continuing with the base game's behavior.

Note: You're only supposed to be able to choose the lost tinker once. (Must have the Embers of Rage DLC and unlocked by playing in the Orcs campaign)
Note: Unfortunately the only time that addons can get the possible escort types is after the random escort quest is assigned.
This means escorts added by other addons will not be available for selection, but will still be possible to find using the random selection.
]] -- the [[ ]] things are like quote marks that can span multiple lines
tags = {'escort', 'escort quest', 'escorts'}

overload = true
superload = false
data = false
hooks = true