class TBReplicationInfo extends ReplicationInfo;

// =============================================================================
// Variables
// =============================================================================
var TBActor    zzActor;                // Reference to the main actor
var TBLog      zzLog;                  // Reference to the logging object
var TBSettings zzSettings;             // Settings
var TBPlayerDisplayProperties zzProps; // Displayproperties
var int        zzState;                // 0 = Idle, 1 = Replicating pre-check variables, 2 = Check called - waiting for response, 3 = Player being kicked
var int        zzCheckKey;             // Encryption key used during last check
var bool       zzCheckValid;           // Was the latest check return valid?
var string     zzPlayerIP;             // IP of the player
var PlayerReplicationInfo zzPRI;       // PRI of the player
var string     zzMyVer;                // Version
var int        zzTweaksFound;

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
        xxCheck, xxConsoleCommand, xxShowConsole;

    reliable if (ROLE < ROLE_AUTHORITY)
        xxCheckReply;
}

// =============================================================================
// xxInitRI ~
// =============================================================================
function xxInitRI(TBActor zzA, TBSettings zzS)
{
    zzActor = zzA;
    zzSettings = zzS;

    // Start replicating
    zzS.xxSetDefaultVars();

    // Get ip and pri
    if (PlayerPawn(Owner) != none)
    {
        zzPRI = PlayerPawn(Owner).PlayerReplicationInfo;
        zzPlayerIP = PlayerPawn(Owner).GetPlayerNetworkAddress();
        if (InStr(zzPlayerIP,":") != -1)
            zzPlayerIP = Left(zzPlayerIP,InStr(zzPlayerIP,":"));
    }

    // Determine check start time
    SetTimer(RandRange(10,15),false);
    //SetTimer(5.0,false);
}

// =============================================================================
// Timer ~
// =============================================================================
function Timer()
{
    // Cleanup
    if (PlayerPawn(Owner) == none)
    {
        Destroy();
        return;
    }

    // Idle => replicate pre-check vars
    if (zzState == 0)
    {
        zzState = 1;
        xxGetProperties();
        SetTimer(2.0,false);
        return;
    }
    // Replicating pre-check vars => start a check, set the timer to check for timeouts
    else if (zzState == 1)
    {
        zzState = 2;
        SetTimer(zzActor.CheckTimeOut,false);
        zzCheckKey = int(RandRange(1,2004318072));
        xxCheck(zzCheckKey,zzActor,zzSettings,zzProps);
        return;
    }
    // Waiting for reply => Check for timeout
    else if (zzState == 2)
    {
        if (!zzCheckValid)
        {
            xxKickPlayer("Check Timeout");
            return;
        }
        // Schedule next check
        else
        {
            zzState = 0;
            SetTimer(zzActor.CheckInterval-zzActor.CheckTimeOut+RandRange(1,10),false);
            return;
        }
    }
    // Player being kicked => he's still here! force destroy
    else if (zzState == 3)
    {
        if (PlayerPawn(Owner) != none)
        {
            PlayerPawn(Owner).Destroy();
            Destroy();
            return;
        }
    }
}

// =============================================================================
// xxGetProperties ~ Rebuild properties list
// =============================================================================
function xxGetProperties()
{
    local Pawn zzP;
    local bool zzHasBelt;
    local bool zzHasInvi;
    local bool zzHasAmp;
    local Inventory zzInv;

    if (zzProps != none)
        zzProps.Destroy();

    zzProps = Level.Spawn(class'TBPlayerDisplayProperties',Owner);

    for (zzP = Level.PawnList; zzP != none; zzP = zzP.nextPawn)
    {
        for (zzInv = zzP.Inventory; zzInv != none; zzInv = zzInv.Inventory)
        {
            if (zzInv.IsA('UT_ShieldBelt'))
            {
                zzHasBelt = true;
                break;
            }
            if (zzInv.IsA('UT_Invisibility'))
            {
                zzHasInvi = true;
                break;
            }
            if (zzInv.IsA('UDamage'))
            {
                zzHasAmp = true;
                break;
            }
          }
        if (zzP.IsA('PlayerPawn') && !zzP.IsA('Spectator'))
            zzProps.xxAddProperties(PlayerPawn(zzP),zzP.texture,zzP.Mesh,zzP.bMeshEnviroMap,zzP.bUnlit,zzHasBelt,zzHasInvi,zzHasAmp,zzP.LightRadius,zzP.DrawScale);
    }
}


// =============================================================================
// xxCheck ~ Run clientside checks
// =============================================================================
simulated function xxCheck(int zzKey, TBActor zzA, TBSettings zzS, TBPlayerDisplayProperties zzProps)
{
    local string zzReply, zzTweaksReply;
    local int zzTestsExecuted;
    local PlayerPawn zzPP;
    local string zzLODBias;
    local CTFFlag zzFlag;
    local UT_ShieldBeltEffect zzSBE;
    local TBPlayerDisplayProperties zzPlayerProps;
    local Weapon zzWeapon;
    local UT_ShieldBelt zzshieldBelt;
    local UDamage zzUDamage;
    local UT_Invisibility zzInvisibility;

    zzTweaksFound = 0;

    // RMode checks (hi royal)
    if (zzA.bCheckRMode)
    {
        zzReply = xxGetRenderProperties(none);
        if (xxGetToken(zzReply, 0) != "5")
        {
            xxAddTweak(zzTweaksReply,"Illegal RMode:"@xxGetToken(zzReply,0));
        }
        zzTestsExecuted++;
    }

    // Renderer checks (macrotexture, wallhacks and such)
    if (zzA.bCheckRendering)
    {
        zzReply = xxGetRenderProperties(none);
        if (!(xxGetToken(zzReply, 1) ~= "None"))
        {
            xxAddTweak(zzTweaksReply,"Illegal MacroTexture:"@xxGetToken(zzReply,1));
        }
        if (xxGetToken(zzReply, 2) == "1")
        {
            xxAddTweak(zzTweaksReply,"Illegal Setting:"@"Texture bInvisible"@xxGetToken(zzReply,2));
        }
        if (xxGetToken(zzReply, 3) == "1")
        {
            xxAddTweak(zzTweaksReply,"Illegal Setting:"@"Texture bTransparent"@xxGetToken(zzReply,3));
        }

        // Invisible water etc
        if ((xxGetToken(xxGetTextureProperties(class'fire.watertexture'), 3) == "1" && !zzS.zzRenderingWaterHidden)
            || (xxGetToken(xxGetTextureProperties(class'fire.wetTexture'), 3) == "1" && !zzS.zzRenderingWetHidden))
        {
            xxAddTweak(zzTweaksReply,"No Water Tweak");
        }

        // Invisible Lightboxes
        if (xxGetToken(xxGetRenderProperties(class'LightBox'), 1) == "1" && !zzS.zzRenderingLightboxHidden)
        {
            xxAddTweak(zzTweaksReply,"Hidden Lightbox Tweak");
        }

        // Visible Spawn Point Hack

        if (xxGetToken(xxGetRenderProperties(class'PlayerStart'), 1) == "0")
        {
            xxAddTweak(zzTweaksReply,"Player Spawn Point Hack");
        }

        // Shield Belt Render Tweak Alternative Check
     // if (int(xxGetToken(xxGetRenderProperties(class'UT_ShieldBeltEffect'), 7)) == zzS.zzShieldBeltEffectStyle)
     // {
     //     xxAddTweak(zzTweaksReply,"Shield Belt Effect Tweak");
     // }

        zzTestsExecuted++;
    }

    // Check Weapons for bMeshEnviroMap, DrawScale and Texture hacks
    if (zzA.bCheckWeaponModels)
    { 
        foreach Level.AllActors(class'Weapon', zzWeapon)
        { 
            // Skip the checks if the weapon is modified by UT_Invisibility or UDamage
            if (!(zzWeapon.Style == ERenderStyle.STY_Translucent && (zzWeapon.Texture == FireTexture'Unrealshare.Belt_fx.Invis' || zzWeapon.Texture == FireTexture'UnrealShare.Belt_fx.UDamageFX')))
            {
                zzReply = xxGetTextureProperties(zzWeapon);

                if (xxGetToken(zzReply, 5) == "1")
                    {
                        if (zzWeapon.bMeshEnviroMap == True)
                        {
                            xxAddTweak(zzTweaksReply,"Weapon Texture Tweak");
                        }
                    }
            }
        }
        zzTestsExecuted++;
    }

    if (zzA.bCheckPowerUps)
    {

        foreach Level.AllActors(class'UT_ShieldBelt', zzShieldBelt)
        {
            if (zzShieldBelt != none && zzShieldBelt.DrawScale != zzS.zzShieldBeltDrawScale)
            {
                    xxAddTweak(zzTweaksReply,"Belt DrawScale Tweak");
            }
                
            if (zzShieldBelt != none && zzShieldBelt.DrawType != zzS.zzShieldBeltDrawType)
            {
                    xxAddTweak(zzTweaksReply,"Belt DrawType Tweak");
            }
        }

        foreach Level.AllActors(class'UDamage', zzUDamage)
        {
            if (zzUDamage != none && zzUDamage.DrawScale != zzS.zzUDamageDrawScale)
            {
                xxAddTweak(zzTweaksReply,"UDamage DrawScale Tweak");
            }

            if (zzUDamage != none && zzUDamage.DrawType != zzS.zzUDamageDrawType)
            {
                xxAddTweak(zzTweaksReply,"UDamage DrawType Tweak");
            }
        }

        foreach Level.AllActors(class'UT_Invisibility', zzInvisibility)
        {
            if (zzInvisibility != none && zzInvisibility.DrawScale != zzS.zzInvisibilityDrawScale)
            {
                xxAddTweak(zzTweaksReply,"Invisibility DrawScale Tweak");
            }
      
            if (zzInvisibility != none && zzInvisibility.DrawType != zzS.zzInvisibilityDrawType)
            {
                xxAddTweak(zzTweaksReply,"Invisibility DrawType Tweak");
            }
        }

        zzTestsExecuted++;
    }

    // Check for skin tweaks (skinhacks/brightskins)
    if (zzA.bCheckPlayerSkins)
    {
        // Check for brightskins (major tweak)
        foreach Level.AllActors(class'PlayerPawn',zzPP)
        {
            if (zzPP.IsA('Spectator'))
                continue;

            if (zzProps != none)
                zzPlayerProps = zzProps.xxGetPlayerProperties(zzPP);
        
             // Player LODBias Check
            if (zzA.bCheckLODBias)
            {  
                zzLODBias = zzA.GetLODBias(zzPP);

                if (float(zzLODBias) > zzA.bMaxAllowedLODBias) // Convert lodBias to float before comparing
                {
                    xxAddTweak(zzTweaksReply,"LODBias Too High. Max Allowed LODBias = "$zzA.bMaxAllowedLODBias);
                }
            }
            zzReply = xxGetTextureProperties(zzPP);

            // Check the XMenu skinhack
            if (xxGetToken(zzReply, 0) != string(zzPP.default.Texture))
            {
                // If the player is not invisible, perform the brightskins check
                if (xxGetToken(zzReply, 0) != "UnrealShare.Belt_fx.Invis.Invis")
                {
                    if (zzPlayerProps == none
                        || (zzPlayerProps != none && zzPlayerProps.zzOwnerTexture != none && string(zzPlayerProps.zzOwnerTexture.class) != xxGetToken(zzReply, 0) && !zzPlayerProps.zzOwnerHasBelt))
                        xxAddTweak(zzTweaksReply,"Brightskins -> "@xxGetToken(zzReply,0));
                }
            }
            if (xxGetToken(zzReply, 5) == "1")
            {   
                // If the player is not invisible, perform the MeshEnviroMapped check
                if (xxGetToken(zzReply, 0) != "UnrealShare.Belt_fx.Invis.Invis")
                {
                    if (zzPlayerProps == none || (zzPlayerProps != none && !zzPlayerProps.zzOwnerEnviroMap && !zzPlayerProps.zzOwnerHasBelt && !zzPlayerProps.zzOwnerHasInvi))
                        xxAddTweak(zzTweaksReply,"MeshEnviroMapped skins -> "@xxGetToken(zzReply,0));
                }
            }
            // Check Glow
            if (zzPP.LightRadius > 10)
            {
                if (zzPlayerProps == none || (zzPlayerProps != none && zzPlayerProps.zzOwnerLightRadius != zzPP.LightRadius))
                    xxAddTweak(zzTweaksReply,"Player Glow Tweak ("$zzPP.LightRadius$")");
            }
            
            // Check Player Model DrawScale
            if (zzPP.DrawScale != zzS.zzPPDefaultDrawScale)
            {
                xxAddTweak(zzTweaksReply,"Player DrawScale Tweak");
            }

            // Check Player Model Fatness

            if (zzPP.Fatness != zzS.zzPPDefaultFatness)
            {
                xxAddTweak(zzTweaksReply,"Player Size Tweak");
            }
        }

        zzTestsExecuted++;
    }

    // Flag glow tweaks
    if (zzA.bCheckFlags)
    {
        foreach Level.AllActors(class'CTFFlag',zzFlag)
        {
            if (zzFlag.DrawScale > zzS.zzFlagDrawScale)
            {
                xxAddTweak(zzTweaksReply,"Flag Size Tweak ("$zzFlag.DrawScale$")");
            }
            if (zzFlag.Mesh != none && zzFlag.Mesh != zzS.zzFlagMesh)
            {
                xxAddTweak(zzTweaksReply,"Flag mesh Tweak ("$zzFlag.Mesh$")");
            }
            if (zzFlag.LightRadius != zzS.zzFlagLightRadius && !zzFlag.bHeld)
            {
                xxAddTweak(zzTweaksReply,"Flag Glow Tweak ("$zzFlag.LightRadius$")");
            }
        }

        zzTestsExecuted++;
    }

    // Shield Belt Effect Hacks
    if (zzA.bCheckBeltHacks)
    {
        foreach Level.AllActors(class'UT_ShieldBeltEffect', zzSBE)
            {
                if (zzSBE != none && zzSBE.Style != zzS.zzShieldBeltEffectStyle)
                {
                    xxAddTweak(zzTweaksReply, "Shield Belt Effect Tweak");
                }

                if (zzSBE != none && zzSBE.DrawScale != zzS.zzShieldBeltDrawScale)
                {
                    xxAddTweak(zzTweaksReply, "Shield Belt Effect DrawScale Tweak");
                }

                if (zzSBE != none && zzSBE.DrawType != zzS.zzShieldBeltEffectDrawType)
                {
                    xxAddTweak(zzTweaksReply, "Shield Belt Effect DrawType Tweak");
                }
            }

         zzTestsExecuted++;
    }

    zzTweaksReply = zzTweaksFound$chr(9)$zzTweaksReply$chr(9)$zzTestsExecuted$chr(9);
    while (Len(zzTweaksReply)%33 != zzKey%33)
        zzTweaksReply = zzTweaksReply$".";
    zzTweaksReply = xxRC4Encrypt(zzKey, zzTweaksReply);
    xxCheckReply(zzTweaksReply);
}

// =============================================================================
// xxAddTweak ~ Add a tweak to the list of found tweaks (but don't make the string too long)
// =============================================================================
simulated function xxAddTweak(out string zzTweaksReply, string zzTweak)
{
    if (InStr(zzTweaksReply,zzTweak) == -1)
    {
        if (zzTweaksReply == "")
        {
            zzTweaksReply = zzTweak;
        }
        else if (Len(zzTweaksReply) + Len(zzTweak) < 200)
        {
            zzTweaksReply = zzTweaksReply$", "$zzTweak;
        }
        else if (Right(zzTweaksReply,4) != ",...")
        {
            zzTweaksReply = zzTweaksReply$",...";
        }
    }
    zzTweaksFound++;
}

// =============================================================================
// xxRC4Encrypt ~
// =============================================================================
simulated function string xxRC4Encrypt(int zzKey, string zzString)
{
    local int zzRc4Key[256];
    local int zzI,zzJ,zzK,zzTmp;
    local string zzResult;

    // Key init
    for (zzI = 0; zzI < 256; ++zzI)
        zzRc4Key[zzI] = zzI;

    // Key swap
    zzJ = 0;

    for (zzI = 0; zzI < 256; ++zzI)
    {
        zzJ = (zzJ + zzRc4Key[zzI] + asc(Left(Mid(string(zzKey),zzI % Len(string(zzKey))),1))) % 256;
        zzTmp = zzRc4Key[zzI];
        zzRc4Key[zzI] = zzRc4Key[zzJ];
        zzRc4Key[zzJ] = zzTmp;
    }

    // Encrypt
    zzI = 0;
    zzJ = 0;
    zzResult = "";
    for (zzK = 0; zzK < Len(zzString); ++zzK)
    {
        zzI = (zzI + 1) % 256;
        zzJ = (zzJ + zzRc4Key[zzI]) % 256;

        // Key swap
        zzTmp = zzRc4Key[zzI];
        zzRc4Key[zzI] = zzRc4Key[zzJ];
        zzRc4Key[zzJ] = zzTmp;

        // Calculate new char
        zzTmp = asc(Left(Mid(zzString,zzK),1)) ^ zzRc4Key[(zzRc4Key[zzI] + zzRc4Key[zzJ]) % 256];

        // Append
        zzResult = zzResult$xxPad(zzTmp);
    }

    return zzResult;
}

// =============================================================================
// xxRC4Decrypt ~
// =============================================================================
simulated function string xxRC4Decrypt(int zzKey, string zzString)
{
    local int zzRc4Key[256];
    local int zzI,zzJ,zzK,zzTmp;
    local string zzResult;

    // Key init
    for (zzI = 0; zzI < 256; ++zzI)
        zzRc4Key[zzI] = zzI;

    // Key swap
    zzJ = 0;

    for (zzI = 0; zzI < 256; ++zzI)
    {
        zzJ = (zzJ + zzRc4Key[zzI] + asc(Left(Mid(string(zzKey),zzI % Len(string(zzKey))),1))) % 256;
        zzTmp = zzRc4Key[zzI];
        zzRc4Key[zzI] = zzRc4Key[zzJ];
        zzRc4Key[zzJ] = zzTmp;
    }

    // Encrypt
    zzI = 0;
    zzJ = 0;
    zzResult = "";
    for (zzK = 0; zzK < Len(zzString)/3; ++zzK)
    {
        zzI = (zzI + 1) % 256;
        zzJ = (zzJ + zzRc4Key[zzI]) % 256;

        // Key swap
        zzTmp = zzRc4Key[zzI];
        zzRc4Key[zzI] = zzRc4Key[zzJ];
        zzRc4Key[zzJ] = zzTmp;

        // Calculate new char
        zzTmp = int(Left(Mid(zzString,zzK*3),3)) ^ zzRc4Key[(zzRc4Key[zzI] + zzRc4Key[zzJ]) % 256];

        // Append
        zzResult = zzResult$chr(zzTmp);
    }

    return zzResult;
}

// =============================================================================
// xxCheckReply ~ Process the reply of the latest check - kick player if needed
// =============================================================================
simulated function xxCheckReply (string zzString)
{
    // Verify result
    local string zzReply;
    local int zzTweaksFound;
    local int zzTestsExecuted;
    local int zzTestsExpected;
    local string zzTweaksReply;

    zzReply = xxRC4Decrypt(zzCheckKey,zzString);
    zzTestsExpected = (int(zzActor.bCheckRMode) + int(zzActor.bCheckRendering) + int(zzActor.bCheckPlayerSkins) + int (zzActor.bCheckFlags) + int(zzActor.bCheckPowerUps) + int (zzActor.bCheckBeltHacks) + int(zzActor.bCheckWeaponModels));

    // Check Length
    if (Len(zzReply)%33 != zzCheckKey%33)
    {
        xxKickPlayer("Check Failed - Code 1");
        return;
    }

    zzTweaksFound = int(xxGetToken(zzReply,0));
    zzTweaksReply = xxGetToken(zzReply,1);
    zzTestsExecuted = int(xxGetToken(zzReply,2));

    if (zzTweaksFound != 0)
    {
        xxKickPlayer(zzTweaksReply,zzTweaksFound);
        return;
    }
    else if (zzTestsExecuted != zzTestsExpected)
    {
        xxKickPlayer("Check Failed - Code 2 -"@zzTestsExecuted@zzTestsExpected);
    }
    else
    {
        zzCheckValid = true;
        return;
    }
}

// =============================================================================
// xxKickPlayer ~ Kick Player!
// =============================================================================
function xxKickPlayer(string zzReason, optional int zzTweaksFound)
{
    local string zzPlayerName;

    // Secondary kick timer
    zzState = 3;
    SetTimer(10.0,false);

    if (zzPRI != none)
        zzPlayerName = zzPRI.PlayerName;

    xxLog("=== Player Kick ===");
    xxLog("Player Name  :"@zzPlayerName);
    xxLog("Player IP    :"@zzPlayerIP);
    if (zzTweaksFound > 0)
    xxLog("Tweaks found :"@zzTweaksFound);
    xxLog("Tweaks       :"@zzReason);
    xxLog("=== Player Kick ===");

    // TODO: EXTERNAL LOGGING

    // Let the player know
    xxClientMessage("TB has removed you from the server for the following reason(s):");
    xxClientMessage(zzReason);

    // It's a tweak!
    if (!(zzReason ~= "Check Timeout" || Left(zzReason,Len("Check Failed")) ~= "Check Failed"))
    {
        xxClientMessage("Reboot your UT and come back without tweaks");
    }

    xxShowConsole();

    // I lol'ed when i wrote this line
    xxConsoleCommand(xxRC4Encrypt(0xDEADBEEF,"disconnect"));
}

// =============================================================================
// xxGetTextureProperties ~ Get the texture info for this actor/class
// =============================================================================
simulated function string xxGetTextureProperties(Object zzO)
{
    local Actor zzA;
    local class<Actor> zzC;
    local class<Texture> zzT;
    local string zzTexUnlit, zzTexTrans, zzTexInvis;

    if (zzO == none)
        return "";

    if (zzO.IsA('Actor'))
    {
        zzA = Actor(zzO);
        if (zzA.Texture != none)
        {
            zzTexUnlit = string(int(zzA.Texture.bUnlit));
            zzTexTrans = string(int(zzA.Texture.bTransparent));
            zzTexInvis = string(int(zzA.Texture.bInvisible));
        }
        return string(zzA.Texture)$chr(9)$int(zzA.default.bUnlit)$chr(9)$zzTexUnlit$chr(9)$zzTexTrans$chr(9)$zzTexInvis$chr(9)$int(zzA.bMeshEnviroMap);
    }
    else if (class<Actor>(zzO) != none)
    {
        zzC = class<Actor>(zzO);
        if (zzC.default.Texture != none)
        {
            zzTexUnlit = string(int(zzC.default.Texture.bUnlit));
            zzTexTrans = string(int(zzC.default.Texture.bTransparent));
            zzTexInvis = string(int(zzC.default.Texture.bInvisible));
        }
        return string(zzC.default.Texture)$chr(9)$int(zzC.default.bUnlit)$chr(9)$zzTexUnlit$chr(9)$zzTexTrans$chr(9)$zzTexInvis$chr(9)$int(zzC.default.bMeshEnviroMap);
    }
    else
    {
        zzT = class<Texture>(zzO);
        return string(zzT)$chr(9)$int(zzT.default.bUnlit)$chr(9)$int(zzT.default.bTransparent)$chr(9)$int(zzT.default.bInvisible);
    }
}


// =============================================================================
// xxGetLightProperties ~ Get the light info for this actor/class
// =============================================================================
simulated function string xxGetLightProperties(Object zzO)
{
    local Actor zzA;
    local class<Actor> zzC;

    if (zzO == none)
        return "";

    if (zzO.IsA('Actor'))
    {
        zzA = Actor(zzO);
        return zzA.LightRadius$chr(9)$zzA.LightEffect$chr(9)$zzA.LightType$chr(9)$zzA.LightBrightness$chr(9)$zzA.LightHue$chr(9)$zzA.LightSaturation;
    }
    else
    {
        zzC = class<Actor>(zzO);
        return zzC.default.LightRadius$chr(9)$zzC.default.LightEffect$chr(9)$zzC.default.LightType$chr(9)$zzC.default.LightBrightness$chr(9)$zzC.default.LightHue$chr(9)$zzC.default.LightSaturation;
    }
}

// =============================================================================
// xxGetRenderProperties ~ Get the render info for this actor/class
// =============================================================================
simulated function string xxGetRenderProperties(Object zzO)
{
    local Actor zzA;
    local class<Actor> zzC;

    if (zzO == none)
    {
        return PlayerPawn(Owner).GetPropertyText("RendMap")$chr(9)$class'Texture'.default.MacroTexture$chr(9)$int(class'Texture'.default.bInvisible)$chr(9)$int(class'Texture'.default.bTransparent)$chr(9);
    }
    else if (zzO.IsA('Actor'))
    {
        zzA = Actor(zzO);
        return string(zzA.Mesh)$chr(9)$int(zzA.bHidden)$chr(9)$zzA.DrawScale$chr(9)$zzA.DrawType$chr(9)$zzA.ScaleGlow$chr(9)$zzA.VisibilityRadius$chr(9)$zzA.VisibilityHeight$chr(9)$zzA.Style; // Added Style
    }
    else if (zzO.IsA('Class'))
    {
        zzC = class<Actor>(zzO);
        return string(zzC.default.Mesh)$chr(9)$int(zzC.default.bHidden)$chr(9)$zzC.default.DrawScale$chr(9)$zzC.default.DrawType$chr(9)$zzC.default.ScaleGlow$chr(9)$zzC.default.VisibilityRadius$chr(9)$zzC.default.VisibilityHeight$chr(9)$zzC.default.Style; // Added Style
    }
}

// =============================================================================
// xxClientMessage ~ Safe clientmessage
// =============================================================================
function xxClientMessage(string zzString)
{
    if (PlayerPawn(Owner) != none)
    {
        PlayerPawn(Owner).ClientMessage("[TB"$zzMyVer$"]"@zzString);
    }
}

// =============================================================================
// xxShowConsole ~ Make console visible
// =============================================================================
simulated function xxShowConsole()
{
    local WindowConsole zzConsole;

	if ((PlayerPawn(Owner) == none) || (PlayerPawn(Owner).Player == none) || (PlayerPawn(Owner).Player.Console == None))
        return;

    zzConsole = WindowConsole(PlayerPawn(Owner).player.Console);
	if (zzConsole==None) return;
	zzConsole.bQuickKeyenable = True;
	zzConsole.LaunchUWindow();
	zzConsole.ShowConsole();
}

// =============================================================================
// xxConsoleCommand ~ Encrypted consolecommand!
// =============================================================================
simulated function xxConsoleCommand(string zzCommand)
{
    if (PlayerPawn(Owner) != none)
    {
        PlayerPawn(Owner).ConsoleCommand(xxRC4Decrypt(0xDEADBEEF,zzCommand));
    }
}

// =============================================================================
// xxGetToken ~ Retrieve a token from a tokenstring
// =============================================================================
simulated function string xxGetToken(string zzString, int zzToken)
{
    local int zzI;

    zzString = zzString$chr(9);

    for (zzI = 0; zzI < zzToken; ++zzI)
    {
        if (InStr(zzString,chr(9)) != -1)
            zzString = Mid(zzString,InStr(zzString,chr(9))+1);
    }

    if (InStr(zzString,chr(9)) != -1)
        return Left(zzString,InStr(zzString,chr(9)));
    else
        return zzString;
}

// =============================================================================
// xxPad ~ printf("%03d",zzI) ;)
// =============================================================================
simulated function string xxPad(int zzI)
{
    local string zzResult;
    zzResult = string(zzI);
    while (Len(zzResult) < 3)
        zzResult = "0"$zzResult;
    return zzResult;
}

// =============================================================================
// xxLog ~ Log with version tag
// =============================================================================
simulated function xxLog(string zzString)
{
    Log("[TB"$zzMyVer$"]"@zzString);

    if (zzActor.bExternalLogs)
    {
        if (zzLog == none)
        {
            zzLog = Spawn(class'TBLog');

            if (zzActor.LogPath != "")
                zzLog.LogPath = zzActor.LogPath;
            else
                zzLog.LogPath = "../Logs/";

            if (zzActor.LogPrefix != "")
                zzLog.LogPrefix = zzActor.LogPrefix;
            else
                zzLog.LogPrefix = "[TB]";

            zzLog.StartLog();
        }

        zzLog.LogEventString("[TB"$zzMyVer$"]"@zzString);
        zzLog.FileFlush();
    }
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    zzMyVer="v03"
    NetPriority=10.0
}
