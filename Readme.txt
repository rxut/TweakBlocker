TweakBlocker for Unreal Tournament 1999

1) What is it?
--------------

TweakBlocker is an unreal script based tool that blocks a series of tweaks/cheats
undetected by ACE Anti-Cheat. Most of these tweaks are rendering-related
and will have a severe impact on the player's view of the level/other players.

Examples of tweaks/cheats being detected:
- Illegal packages and actors spawned while connected to the server
- Bright Skins
- DrawScale, Fatness, and Lighting hacks on Player Models, Powerups, and Weapons
- LODBias
- Shield Belt Effect Hacks, which work similarly to Bright Skins
- Flag hacks
- Weapon Model Texture replacements
- Visible Spawn Point Hack

TweakBlocker can turn off all tweaks and reset class properties back to defaults. It includes support for custom weapon and projectile classes, which can be customized inside the config section.

TweakBlocker can work in Stealth Mode. When this mode is enabled, no messages are sent to players, and players will not be kicked if tweaks are found. Tweak Blocker will collect all detected tweaks and log a report file for each player.

2) How to install it?
-----------------------

* Unzip the contents of this zip archive to the system folder of your server

* Open the UnrealTournament.ini file of your server. Then browse to the 
  [Engine.GameEngine] section and add the following lines:

  ServerActors=TweakBlocker_v08.TBActor
  ServerPackages=TweakBlocker_v08

* TweakBlocker configuration section is inside the main UnrealTournament.ini server file.

  The default configuration includes IG+ custom classes and looks like this:

  [TweakBlocker_v08.TBActor]
  CheckInterval=30.000000
  CheckTimeout=15.000000
  bStealthMode=False
  bDisableTweaks=True
  bDisableCustomClassTweaks=True
  bCheckClientPackages=True
  bCheckRendering=True
  bCheckLODBias=True
  bMaxAllowedLODBias=4.000000
  bCheckRMode=True
  bCheckPlayerSkins=True
  bCheckWeaponModels=True
  bCheckBeltHacks=True
  bCheckPowerUps=True
  bCheckFlags=True
  bExternalLogs=True
  LogPath=../Logs/
  LogPrefix=[TB]
  CustomClassNames[0]=ST_BioGlob
  CustomClassNames[1]=ST_BioSplash
  CustomClassNames[2]=ST_FlakSlug
  CustomClassNames[3]=ST_minigun2
  CustomClassNames[4]=ST_UT_Grenade
  CustomClassNames[5]=ST_GuidedWarshell
  CustomClassNames[6]=ST_ut_biorifle
  CustomClassNames[7]=ST_ImpactHammer
  CustomClassNames[8]=ST_PBolt
  CustomClassNames[9]=ST_PlasmaSphere
  CustomClassNames[10]=ST_PulseGun
  CustomClassNames[11]=ST_Razor2
  CustomClassNames[12]=ST_Razor2Alt
  CustomClassNames[13]=ST_enforcer
  CustomClassNames[14]=ST_RocketMk2
  CustomClassNames[15]=ST_ShockProj
  CustomClassNames[16]=ST_ShockRifle
  CustomClassNames[17]=ST_ShockWave
  CustomClassNames[18]=ST_SniperRifle
  CustomClassNames[19]=ST_StarterBolt
  CustomClassNames[20]=ST_UT_SeekingRocket
  CustomClassNames[21]=ST_WarheadLauncher
  CustomClassNames[22]=ST_UTChunk
  CustomClassNames[23]=ST_UTChunk1
  CustomClassNames[24]=ST_UTChunk2
  CustomClassNames[25]=ST_UTChunk3
  CustomClassNames[26]=ST_UTChunk4
  CustomClassNames[27]=ST_ripper
  CustomClassNames[28]=ST_UT_BioGel
  CustomClassNames[29]=ST_UT_Eightball
  CustomClassNames[30]=ST_UT_FlakCannon
  CustomClassNames[31]=ST_Translocator
  CustomClassNames[32]=ST_TranslocatorTarget
  CustomClassNames[33]=
  CustomClassNames[34]=
  CustomClassNames[35]=
  CustomClassNames[36]=
  CustomClassNames[37]=
  CustomClassNames[38]=
  CustomClassNames[39]=
  CustomClassNames[40]=
  CustomClassNames[41]=
  CustomClassNames[42]=
  CustomClassNames[43]=
  CustomClassNames[44]=
  CustomClassNames[45]=
  CustomClassNames[46]=
  CustomClassNames[47]=
  CustomClassNames[48]=
  CustomClassNames[49]=
  CustomClassNames[50]=
  CustomClassNames[51]=
  CustomClassNames[52]=
  CustomClassNames[53]=
  CustomClassNames[54]=
  CustomClassNames[55]=
  CustomClassNames[56]=
  CustomClassNames[57]=
  CustomClassNames[58]=
  CustomClassNames[59]=
  CustomClassNames[60]=
  CustomClassNames[61]=
  CustomClassNames[62]=
  CustomClassNames[63]=
  CustomClassNames[64]=

* Save the UnrealTournament.ini file and reboot your server

3) History
----------
v0.8:
  Major update with a new check to detect illegal client-side packages. This feature detects tweaks spawned on the fly after the client has already joined to server.
  This version also brings improved logging in Stealth Mode, cleaner code, and multiple bug fixes.
v0.7:
  Added the configurable Custom Class Names list to reset those classes back to default values. This improves support for mods like InstaGibPlus and UTPure.
  Improved overall detection, fixed several bugs, and cleaned up the code.
v0.6:
  Major update with a variety of bug fixes, code optimizations, and new features:
    bStealthMode: When enabled, no messages are sent to players, and players will not be kicked. Tweak Blocker will add detected tweaks into a report and create a log file for each player.
    bDisableTweaks: Enabling this will restore default properties for all classes and effectively turn off tweaks.
    bCheckIGPlusClasses: This specific toggle will allow IG+ classes to be reset to disable tweaks.
v0.5
  First working implementation for disabling tweaks instead of kicking players.
v0.4
  Minor improvements to the code and testing new features
v0.3:
  Third version by rX adds a few notable features, such as LODbias detection
v0.2:
  Second version by banko
v0.1:
  First beta release

4) Authors
----------
Original Author: AnthraX

Modified and actively developed by rX

Contributions by Buggie, Deoad, Marco, and banko
