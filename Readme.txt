TweakBlocker v0.6 by AnthraX (Modified by rX)

1) What is it?
--------------

TweakBlocker is an unreal script based tool that blocks a series of tweaks/cheats
that were previously undetected by ACE Anti-Cheat. Most of these tweaks are rendering-related
and will have a severe impact on the player's view of the level/other players.

Examples of tweaks/cheats being detected:
- Bright Skins
- DrawScale, Fatness, and Lighting hacks on Player Models, Powerups, and Weapons
- LODBias
- Shield Belt Effect Hacks which work similarly to Bright Skins
- Flag hacks
- Weapon Model Texture replacements
- Visible Spawn Point Hack

TweakBlocker can also disable all tweaks and reset class properties back to defaults.

If you prefer to not kick players, when TweakBlocker Stealth Mode is enabled, no messages are sent to players, and players will not be kicked. Tweak Blocker will simply collect all detected tweaks into a report and create a log file for each player.

2) How to install it?
-----------------------

* Unzip the contents of this zip archive to the system folder of your server

* Open the UnrealTournament.ini file of your server. Then browse to the 
  [Engine.GameEngine] section and add the following lines:

  ServerActors=TweakBlocker_v06.TBActor
  ServerPackages=TweakBlocker_v06

* Browse to the end of the UnrealTournament.ini file and add the following lines:

  [TweakBlocker_v06.TBActor]
  CheckInterval=30.0
  CheckTimeout=15.0
  bStealthMode=false
  bDisableTweaks=true
  bCheckIGPlusClasses=true
  bCheckRendering=true
  bCheckRMode=true
  bCheckPlayerSkins=true
  bCheckLODBias=true
  bCheckFlags=true
  bCheckBeltHacks=true
  bCheckPowerUps=true
  bCheckWeaponModels=true
  bMaxLODBias=4.0000
  bExternalLogs=true

* Save the UnrealTournament.ini file and reboot your server

3) History
----------
v0.6:
  Major update with a variety of bug fixes, code optimizations and new features:
    bStealthMode: When enabled, no messages are sent to players, and players will not be kicked. Tweak Blocker will add detected tweaks into a report and create a log file for each player.
    bDisableTweaks: Enabling this will restore default properties for all classes and effectively disable tweaks.
    bCheckIGPlusClasses: This is a specific toggle for IG+ and will allow IG+ classes to be reset to disable tweaks.
v0.3:
  Third version by rX adding new features
v0.2:
  Second version by banko
v0.1:
  First beta release
