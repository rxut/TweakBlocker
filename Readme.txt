#############################################################################
#                            TweakBlocker v0.3                              #
#                               by AnthraX                                  # 
#                              Modified by rX                               # 
#############################################################################

1) What is it?
--------------

TweakBlocker is an unrealscript based tool that blocks a series of tweaks/cheats
that were previously undetected. Most of these tweaks are rendering related
and will have a severe impact on the player's view of the level/other players.

2) How do I install it?
-----------------------

* Unzip the contents of this zip archive to the system folder of your server

* Open the UnrealTournament.ini file of your server. Then browse to the 
  [Engine.GameEngine] section and add the following lines:

  ServerActors=TBv03.TBActor
  ServerPackages=TBv03

* Browse to the end of the UnrealTournament.ini file and add the following lines:

[TBv03.TBActor]
CheckInterval=30.0
CheckTimeout=15.0
bCheckRendering=true
bCheckRMode=true
bCheckPlayerSkins=true
bCheckLODBias=true
bCheckFlags=true
bCheckBeltHacks=true
bCheckWeaponModels=true
bMaxLODBias=4.0000
bExternalLogs=true

* Save the UnrealTournament.ini file and reboot your server

3) History
----------
v0.3:
  Third version by rX adding new features
v0.2:
  Second version by banko
v0.1:
  First beta release
