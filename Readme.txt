##############################################################################
#                            TweakBlocker v0.1                               #
#                               by AnthraX                                   #
##############################################################################

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
bCheckPlayerUnlitSkins=true
bCheckPickupUnlit=true
bCheckLODBias=true
bCheckFlags=true
bCheckWeaponModels=true
bMaxLODBias=4.0000
bExternalLogs=true


* Save the UnrealTournament.ini file and reboot your server

3) History
----------

v0.1:
  First beta release


4) Feedback & support
---------------------

http://www.unrealadmin.org/forums/forumdisplay.php?f=177

Or talk to me on IRC:

Nick: ]DoE[AnthraX or [anth]
Server: Quakenet
Channels: #unrealadmin or #doe