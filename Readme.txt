TweakBlocker for Unreal Tournament 1999

1) What is it?
--------------

TweakBlocker is an unreal script based tool that blocks a series of tweaks/cheats
undetected by ACE Anti-Cheat. Most of these tweaks are rendering-related
and will have a severe impact on the player's view of the level/other players.

Examples of tweaks/cheats being detected:
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

  ServerActors=TweakBlocker_v06.TBActor
  ServerPackages=TweakBlocker_v06

* TweakBlocker configuration section is inside the main UnrealTournament.ini server file.

  The default configuration includes IG+ custom classes and looks like this:

  [TweakBlocker_v07.TBActor]
  CheckInterval=30.000000
  CheckTimeout=15.000000
  bStealthMode=False
  bDisableTweaks=True
  bCheckRendering=True
  bCheckRMode=True
  bCheckPlayerSkins=True
  bCheckFlags=True
  bExternalLogs=True
  LogPath=../Logs/
  LogPrefix=[TB]
  bCheckLODBias=True
  bMaxAllowedLODBias=4.000000
  bCheckWeaponModels=True
  bCheckBeltHacks=True
  bCheckPowerUps=True
  bCheckCustomClasses=True
  ResetCustomClassNames[0]=ST_BioGlob
  ResetCustomClassNames[1]=ST_BioSplash
  ResetCustomClassNames[2]=ST_FlakSlug
  ResetCustomClassNames[3]=ST_minigun2
  ResetCustomClassNames[4]=ST_UT_Grenade
  ResetCustomClassNames[5]=ST_GuidedWarshell
  ResetCustomClassNames[6]=ST_ut_biorifle
  ResetCustomClassNames[7]=ST_ImpactHammer
  ResetCustomClassNames[8]=ST_PBolt
  ResetCustomClassNames[9]=ST_PlasmaSphere
  ResetCustomClassNames[10]=ST_PulseGun
  ResetCustomClassNames[11]=ST_Razor2
  ResetCustomClassNames[12]=ST_Razor2Alt
  ResetCustomClassNames[13]=ST_enforcer
  ResetCustomClassNames[14]=ST_RocketMk2
  ResetCustomClassNames[15]=ST_ShockProj
  ResetCustomClassNames[16]=ST_ShockRifle
  ResetCustomClassNames[17]=ST_ShockWave
  ResetCustomClassNames[18]=ST_SniperRifle
  ResetCustomClassNames[19]=ST_StarterBolt
  ResetCustomClassNames[20]=ST_UT_SeekingRocket
  ResetCustomClassNames[21]=ST_WarheadLauncher
  ResetCustomClassNames[22]=ST_UTChunk
  ResetCustomClassNames[23]=ST_UTChunk1
  ResetCustomClassNames[24]=ST_UTChunk2
  ResetCustomClassNames[25]=ST_UTChunk3
  ResetCustomClassNames[26]=ST_UTChunk4
  ResetCustomClassNames[27]=ST_ripper
  ResetCustomClassNames[28]=ST_UT_BioGel
  ResetCustomClassNames[29]=ST_UT_Eightball
  ResetCustomClassNames[30]=ST_UT_FlakCannon
  ResetCustomClassNames[31]=ST_Translocator
  ResetCustomClassNames[32]=ST_TranslocatorTarget

* Save the UnrealTournament.ini file and reboot your server

3) History
----------
v0.7:
  Added support for resetting Custom Weapon and Projectile classes to default values. Improved overall detection, fixed several bugs, and cleaned up the code.
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
