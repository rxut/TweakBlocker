class TBReplicationInfo extends ReplicationInfo DependsOn(TBDefaults);

// =============================================================================
// Variables
// =============================================================================
var TBActor    zzActor;                // Reference to the main actor
var TBLog      zzLog;                  // Reference to the logging object
var TBSettings zzSettings;             // Settings
var TBDefaults zzDefaults;             // Default classes
var TBPlayerDisplayProperties zzProps; // Displayproperties
var int        zzState;                // 0 = Idle, 1 = Replicating pre-check variables, 2 = Check called - waiting for response, 3 = Player being kicked, 4 = No more checks
var int        zzCheckKey;             // Encryption key used during last check
var bool       zzCheckValid;           // Was the latest check return valid?
var string     zzPlayerIP;             // IP of the player
var PlayerReplicationInfo zzPRI;       // PRI of the player
var string     zzMyVer;                // Version
var int        zzTweaksFound;          // Number of tweaks found during normal mode
var int        zzStealthTweaksFound;   // Number of tweaks found during stealth mode
var class<Actor> zzDynClass;           // Dynamic class for iterating through IG+ classes
var bool bDisabledIGPlusClassTweaks;   // Have the IG+ class tweaks been disabled
var bool bDisabledBaseClassTweaks;            // Have the base class tweaks been disabled
var string zzIGPlusClassNames[32];            // Names of the IG+ classes
var string zzDetectedTweakClassNames[128];    // For collecting the class name detected tweaks during stealth mode
var string zzDetectedTweakPropery[128];       // For collecting all detected tweaks during stealth mode
var string VersionStr;                        // Game Version string
var string TimeStamp;                         // Time Stamp string

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
        xxDisableIGPlusClassTweaks, xxDisableBaseClassTweaks, xxResetDefaultClass, xxCheck, xxConsoleCommand, xxShowConsole;

    reliable if (ROLE < ROLE_AUTHORITY)
        xxCheckReply, xxStealthAddTweak;
}

// =============================================================================
// xxInitRI ~
// =============================================================================

function xxInitRI(TBActor zzA, TBSettings zzS, TBDefaults zzD)
{
    zzActor = zzA;
    zzSettings = zzS;
    zzDefaults = zzD;

    // Start replicating
    zzS.xxSetDefaultVars();

    if (zzActor.bDisableTweaks) // Replicate defaults only if they're needed
    {
        zzD.xxSetDefaultVars();
    }

    // Get ip and pri
    if (PlayerPawn(Owner) != none)
    {
        zzPRI = PlayerPawn(Owner).PlayerReplicationInfo;
        zzPlayerIP = PlayerPawn(Owner).GetPlayerNetworkAddress();
        if (InStr(zzPlayerIP,":") != -1)
            zzPlayerIP = Left(zzPlayerIP,InStr(zzPlayerIP,":"));
    }
   
    // Determine check start time
    SetTimer(RandRange(5,10),false);
}

// =============================================================================
// Timer ~
// =============================================================================
function Timer()
{
    local int i;
    
    if (PlayerPawn(Owner) == none) // Cleanup
    {
        Destroy();
        return;
    }
    
    if (zzState == 0) // Idle => replicate pre-check vars
    {
        zzState = 1;

        //xxClientMessage("zzState 0 set to: "@zzState); // Debug

        xxGetProperties();

        if (zzActor.bDisableTweaks) // Main Toggle for Disabling Tweaks
        {
            if (zzActor.bCheckIGPlusClasses && !bDisabledIGPlusClassTweaks) // Main Toggle for Checking IG+ Classes
            {
                zzIGPlusClassNames[0] = "Class'ST_BioGlob'";
                zzIGPlusClassNames[1] = "Class'ST_BioSplash'";
                zzIGPlusClassNames[2] = "Class'ST_FlakSlug'";
                zzIGPlusClassNames[3] = "Class'ST_minigun2'";
                zzIGPlusClassNames[4] = "Class'ST_UT_Grenade'";
                zzIGPlusClassNames[5] = "Class'ST_GuidedWarshell'";
                zzIGPlusClassNames[6] = "Class'ST_UT_BioRifle'";
                zzIGPlusClassNames[7] = "Class'ST_ImpactHammer'";
                zzIGPlusClassNames[8] = "Class'ST_PBolt'";
                zzIGPlusClassNames[9] = "Class'ST_PlasmaSphere'";
                zzIGPlusClassNames[10] = "Class'ST_PulseGun'";
                zzIGPlusClassNames[11] = "Class'ST_Razor2'";
                zzIGPlusClassNames[12] = "Class'ST_Razor2Alt'";
                zzIGPlusClassNames[13] = "Class'ST_enforcer'";
                zzIGPlusClassNames[14] = "Class'ST_RocketMk2'";
                zzIGPlusClassNames[15] = "Class'ST_ShockProj'";
                zzIGPlusClassNames[16] = "Class'ST_ShockRifle'";
                zzIGPlusClassNames[17] = "Class'ST_ShockWave'";
                zzIGPlusClassNames[18] = "Class'ST_SniperRifle'";
                zzIGPlusClassNames[19] = "Class'ST_StarterBolt'";
                zzIGPlusClassNames[20] = "Class'ST_UT_SeekingRocket'";
                zzIGPlusClassNames[21] = "Class'ST_WarheadLauncher'";
                zzIGPlusClassNames[22] = "Class'ST_UTChunk'";
                zzIGPlusClassNames[23] = "Class'ST_UTChunk1'";
                zzIGPlusClassNames[24] = "Class'ST_UTChunk2'";
                zzIGPlusClassNames[25] = "Class'ST_UTChunk3'";
                zzIGPlusClassNames[26] = "Class'ST_UTChunk4'";
                zzIGPlusClassNames[27] = "Class'ST_ripper'";
                zzIGPlusClassNames[28] = "Class'ST_UT_BioGel'";
                zzIGPlusClassNames[29] = "Class'ST_UT_Eightball'";
                zzIGPlusClassNames[30] = "Class'ST_UT_FlakCannon'";
                zzIGPlusClassNames[31] = "Class'TranslocatorTarget'";

                for (i = 0; i < 32; i++)
                {
                    SetPropertyText("zzDynClass", zzIGPlusClassNames[i]);
                    xxDisableIGPlusClassTweaks(zzDefaults, zzDynClass);
                }   
                
                bDisabledIGPlusClassTweaks = true;
            }

            if (!bDisabledbaseClassTweaks)
                {
                    xxDisableBaseClassTweaks(zzDefaults);
                    bDisabledBaseClassTweaks = true;
                    if (zztweaksFound > 0)
                    {
                        xxClientMessage("Your tweaks have been disabled");
                    }
                }
        }

        SetTimer(2.0,false);
        return;
    }
    else if (zzState == 1) // Replicating pre-check vars => start a check, set the timer to check for timeouts
    {
        zzState = 2;

        // xxClientMessage("zzState 1 set to: "@zzState);  // Debug
        // xxClientMessage("First check starting...");   // Debug

        zzCheckKey = int(RandRange(1,2004318072));
        xxCheck(zzCheckKey,zzActor,zzSettings,zzProps);
        SetTimer(zzActor.CheckTimeOut,false);
        return;
    }
    else if (zzState == 2) // Waiting for reply => Check for timeout => Reset timer if valid check
    {
        if (!zzCheckValid)
        {
            xxKickPlayer("Check Timeout");
            return;
        }
        else
        {
            if (zzActor.bStealthMode) // Check if stealth mode is enabled
                {
                    zzState = 4; // No more checks needed

                    // xxClientMessage("zzState 2 set to: "@zzState);  // Debug

                    SetTimer(3,false);    
                }
            else  // Schedule next check
             {
                zzState = 0;

                // xxClientMessage("zzState 2 set to: "@zzState);  // Debug
                // xxClientMessage("Restarting checks...");  // Debug

                SetTimer(zzActor.CheckInterval-zzActor.CheckTimeOut+RandRange(1,10),false);
                return;
            }
        }
    }
    else if (zzState == 3) // Player being kicked => he's still here! force destroy
    {
        //xxClientMessage("zzState is: "@zzState);
        if (PlayerPawn(Owner) != none)
        {
            PlayerPawn(Owner).Destroy();
            Destroy();
            return;
        }
    }
    else if (zzState == 4) // Only entering this state when stealth mode is enabled
    {
        if (zzStealthTweaksFound > 0) // If tweaks were found, create a report
        {
            VersionStr = PlayerPawn(Owner).Level.EngineVersion$Level.GetPropertyText("EngineRevision");
            TimeStamp = Level.Day$"-"$Level.Month$"-"$Level.Year$" / "$Level.Hour$":"$Level.Minute$":"$Level.Second;
            
            /*   // Debug report using ClientMessage
            xxClientMessage("+------------------------------------------------------------------------------+");
            xxClientMessage("|                           TweakBlocker Report                                    |");
            xxClientMessage("+------------------------------------------------------------------------------+");
            xxClientMessage("Player Name: "$zzPRI.PlayerName$"");
            xxClientMessage("Player IP: "$zzPlayerIP$"");
            xxClientMessage("TimeStamp: "$TimeStamp$"");
            xxClientMessage("Tweaks Found: "$zzStealthTweaksFound$"");
            xxClientMessage("+------------------------------------------------------------------------------+");
            xxClientMessage("|                            Tweaks List                                            |");
            xxClientMessage("+------------------------------------------------------------------------------+");
             */
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("|                           TweakBlocker Report                                |");
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("PlayerName.............: "$zzPRI.PlayerName$"");
            xxLog("PlayerIP...............: "$zzPlayerIP$"");
            xxLog("TimeStamp..............: "$TimeStamp$"");
            xxLog("TweaksFound............: "$zzStealthTweaksFound$"");
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("|                                Tweaks List                                   |");
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("+------------------------------------------------------------------------------+");
            
            for (i = 0; i < zzStealthTweaksFound; i++)
                {
                    // xxClientMessage(""$zzDetectedTweakClassNames[i]$" -> "$zzDetectedTweakPropery[i]$""); //Debug
                    xxLog(""$zzDetectedTweakClassNames[i]$" -> "$zzDetectedTweakPropery[i]$"");
                }

            // xxClientMessage("+------------------------------------------------------------------------------+");  //Debug
            xxLog("+------------------------------------------------------------------------------+");

            zzLog.StopLog();

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
    zzStealthTweaksFound = 0;

    // RMode checks (hi royal)
    if (zzA.bCheckRMode)
    {
        zzReply = xxGetRenderProperties(none);
        if (xxGetToken(zzReply, 0) != "5")
        {
            xxAddTweak(zzTweaksReply,"Illegal RMode:"@xxGetToken(zzReply,0));
            xxStealthAddTweak("Illegal RMode",""$xxGetToken(zzReply,0)$"");
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
            xxStealthAddTweak("Renderer Tweak","Illegal MacroTexture="$xxGetToken(zzReply,1)$"");
        }
        if (xxGetToken(zzReply, 2) == "1")
        {
            xxAddTweak(zzTweaksReply,"Illegal Setting:"@"Texture bInvisible"@xxGetToken(zzReply,2));
            xxStealthAddTweak("Renderer Tweak","Texture bInvisible="$xxGetToken(zzReply,2)$"");
        }
        if (xxGetToken(zzReply, 3) == "1")
        {
            xxAddTweak(zzTweaksReply,"Illegal Setting:"@"Texture bTransparent="@xxGetToken(zzReply,3));
            xxStealthAddTweak("Renderer Tweak","Texture bTransparent="$xxGetToken(zzReply,3)$"");
        }

        // Invisible water etc
        if ((xxGetToken(xxGetTextureProperties(class'fire.watertexture'), 3) == "1" && !zzS.zzRenderingWaterHidden)
            || (xxGetToken(xxGetTextureProperties(class'fire.wetTexture'), 3) == "1" && !zzS.zzRenderingWetHidden))
        {
            xxAddTweak(zzTweaksReply,"No Water Tweak");
            xxStealthAddTweak("Renderer Tweak","No Water");
        }

        // Invisible Lightboxes
        if (xxGetToken(xxGetRenderProperties(class'LightBox'), 1) == "1" && !zzS.zzRenderingLightboxHidden)
        {
            xxAddTweak(zzTweaksReply,"Hidden Lightbox Tweak");
            xxStealthAddTweak("Renderer Tweak","Lightbox Hidden");
        }

        // Visible Spawn Point Hack

        if (xxGetToken(xxGetRenderProperties(class'PlayerStart'), 1) == "0")
        {
            xxAddTweak(zzTweaksReply,"Player Spawn Point Hack");
            xxStealthAddTweak("Reveal Player Spawn Points Hack","bHidden=True");
        }

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
                            xxAddTweak(zzTweaksReply,""$zzWeapon.Name$" Texture: "$zzWeapon.Texture$"");
                            xxStealthAddTweak(string(zzWeapon.Name), "Texture="$zzWeapon.Texture$"");
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
                xxAddTweak(zzTweaksReply,"Shield Belt DrawScale: "$zzShieldBelt.DrawScale$"");
                xxStealthAddTweak(string(zzShieldBelt.Name), "DrawScale="$zzShieldBelt.DrawScale$"");
            }
                
            if (zzShieldBelt != none && zzShieldBelt.DrawType != zzS.zzShieldBeltDrawType)
            {
                xxAddTweak(zzTweaksReply,"Shield Belt DrawType: "$zzShieldBelt.DrawType$"");
                xxStealthAddTweak(string(zzShieldBelt.Name), "DrawType="$zzShieldBelt.DrawType$"");

            }

            if (zzShieldBelt != none && zzShieldBelt.Texture != zzS.zzShieldBeltTexture)
            {
                xxAddTweak(zzTweaksReply,"Shield Belt Texture: "$zzShieldBelt.Texture$"");
                xxStealthAddTweak(string(zzShieldBelt.Name), "Texture="$zzShieldBelt.Texture$"");
            }
        }

        foreach Level.AllActors(class'UDamage', zzUDamage)
        {
            if (zzUDamage != none && zzUDamage.DrawScale != zzS.zzUDamageDrawScale)
            {
                xxAddTweak(zzTweaksReply,"UDamage DrawScale: "$zzUDamage.DrawScale$"");
                xxStealthAddTweak(string(zzUDamage.Name), "DrawScale="$zzUDamage.DrawScale$"");
            }

            if (zzUDamage != none && zzUDamage.DrawType != zzS.zzUDamageDrawType)
            {
                xxAddTweak(zzTweaksReply,"UDamage DrawType: "$zzUDamage.DrawType$"");
                xxStealthAddTweak(string(zzUDamage.Name), "DrawType="$zzUDamage.DrawType$"");
            }

            if (zzUDamage != none && zzUDamage.Texture != zzS.zzUDamageTexture)
            {
                xxAddTweak(zzTweaksReply,"UDamage Texture: "$zzUDamage.Texture$"");
                xxStealthAddTweak(string(zzUDamage.Name), "Texture="$zzUDamage.Texture$"");
            }
        }

        foreach Level.AllActors(class'UT_Invisibility', zzInvisibility)
        {
            if (zzInvisibility != none && zzInvisibility.DrawScale != zzS.zzInvisibilityDrawScale)
            {
                xxAddTweak(zzTweaksReply,"Invisibility DrawScale: "$zzInvisibility.DrawScale$"");
                xxStealthAddTweak(string(zzInvisibility.Name), "DrawScale="$zzInvisibility.DrawScale$"");  
            }
      
            if (zzInvisibility != none && zzInvisibility.DrawType != zzS.zzInvisibilityDrawType)
            {
                xxAddTweak(zzTweaksReply,"Invisibility DrawType: "$zzInvisibility.DrawType$"");
                xxStealthAddTweak(string(zzInvisibility.Name), "DrawType="$zzInvisibility.DrawType$"");
            }

            if (zzInvisibility != none && zzInvisibility.Texture != zzS.zzInvisibilityTexture)
            {
                xxAddTweak(zzTweaksReply,"Invisibility Texture: "$zzInvisibility.Texture$"");
                xxStealthAddTweak(string(zzInvisibility.Name), "Texture="$zzInvisibility.Texture$"");
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
                    xxStealthAddTweak(zzTweaksReply,"LODBias Too High. Max Allowed LODBias = "$zzA.bMaxAllowedLODBias);
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
                        xxAddTweak(zzTweaksReply,"Player Brightskins: "@xxGetToken(zzReply,0));
                        xxStealthAddTweak("Player Model Brightskins","Skin="$xxGetToken(zzReply,0)$"");
                }
            }
            if (xxGetToken(zzReply, 5) == "1")
            {   
                // If the player is not invisible, perform the MeshEnviroMapped check
                if (xxGetToken(zzReply, 0) != "UnrealShare.Belt_fx.Invis.Invis")
                {
                    if (zzPlayerProps == none || (zzPlayerProps != none && !zzPlayerProps.zzOwnerEnviroMap && !zzPlayerProps.zzOwnerHasBelt && !zzPlayerProps.zzOwnerHasInvi))
                        xxAddTweak(zzTweaksReply,"Modified Player Skin: "@xxGetToken(zzReply,0));
                        xxStealthAddTweak("Player Model Tweak","Skin="$xxGetToken(zzReply,0)$"");
                }
            }
            // Check Glow
            if (zzPP.LightRadius > 10)
            {
                if (zzPlayerProps == none || (zzPlayerProps != none && zzPlayerProps.zzOwnerLightRadius != zzPP.LightRadius))
                    xxAddTweak(zzTweaksReply,"Player Glow: "$zzPP.LightRadius$"");
                    xxStealthAddTweak("Player Model","LightRadius="$zzPP.LightRadius$"");
            }
            
            // Check Player Model DrawScale
            if (zzPP.DrawScale != zzS.zzPPDefaultDrawScale)
            {
                xxAddTweak(zzTweaksReply,"Player DrawScale: "$zzPP.DrawScale$"");
                xxStealthAddTweak("Player Model","DrawScale="$zzPP.DrawScale$"");
            }

            // Check Player Model Fatness

            if (zzPP.Fatness != zzS.zzPPDefaultFatness)
            {
                xxAddTweak(zzTweaksReply,"Player Size: "$zzPP.Fatness$"");
                xxStealthAddTweak("Player Model","Fatness="$zzPP.Fatness$"");
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
                xxAddTweak(zzTweaksReply,"Flag Size: "$zzFlag.DrawScale$")");
                xxStealthAddTweak(string(zzFlag.Name), "Style="$zzFlag.DrawScale$"");
            }
            if (zzFlag.Mesh != none && zzFlag.Mesh != zzS.zzFlagMesh)
            {
                xxAddTweak(zzTweaksReply,"Flag Mesh: "$zzFlag.Mesh$")");
                xxStealthAddTweak(string(zzFlag.Name), "Mesh="$zzFlag.Mesh$"");
            }
            if (zzFlag.LightRadius != zzS.zzFlagLightRadius && !zzFlag.bHeld)
            {
                xxAddTweak(zzTweaksReply,"Flag Glow: "$zzFlag.LightRadius$")");
                xxStealthAddTweak(string(zzFlag.Name), "LightRadius="$zzFlag.LightRadius$"");
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
                    xxStealthAddTweak(string(zzSBE.Name), "Style="$zzSBE.Style$"");
                }

                if (zzSBE != none && zzSBE.DrawScale != zzS.zzShieldBeltDrawScale)
                {
                    xxAddTweak(zzTweaksReply, "Shield Belt Effect DrawScale Tweak");
                    xxStealthAddTweak(string(zzSBE.Name), "DrawScale="$zzSBE.DrawScale$"");
                }

                if (zzSBE != none && zzSBE.DrawType != zzS.zzShieldBeltEffectDrawType)
                {
                    xxAddTweak(zzTweaksReply, "Shield Belt Effect DrawType Tweak");
                    xxStealthAddTweak(string(zzSBE.Name), "DrawType="$zzSBE.DrawType$"");

                }
            }

         zzTestsExecuted++;
    }

    zzTweaksReply = zzTweaksFound$chr(9)$zzTweaksReply$chr(9)$zzTestsExecuted$chr(9);

    while (Len(zzTweaksReply)%33 != zzKey%33)
        zzTweaksReply = zzTweaksReply$".";
    xxCheckReply(zzTweaksReply);
    
}

// ========================================================================================
// xxStealthAddTweak ~ Add a tweak to the list of found tweaks (but don't make the string too long)
// ========================================================================================
simulated function xxStealthAddTweak(string zzClassName, string zzTweakedProperty)
{
    if (zzActor.bStealthMode) // Add tweak to DetectedTweaks array if stealth mode is enabled
        {
            zzDetectedTweakClassNames[zzStealthTweaksFound] = zzClassName;
            zzDetectedTweakPropery[zzStealthTweaksFound] = zzTweakedProperty;
        }

    //PlayerPawn(Owner).ClientMessage(""$zzDetectedTweakClassNames[zzStealthTweaksFound]$" -> "$zzDetectedTweakPropery[zzStealthTweaksFound]$"");  //Debug

    zzStealthTweaksFound++;
    //PlayerPawn(Owner).ClientMessage("zzStealthTweaksFound: "@zzStealthTweaksFound);  //Debug
}


// ========================================================================================
// xxAddTweak ~ Add a tweak to the list of found tweaks (but don't make the string too long)
// ========================================================================================
simulated function xxAddTweak(out string zzTweaksReply, string zzTweak)
{
    // PlayerPawn(Owner).ClientMessage("xxAddTweak zzTweak: "@zzTweak);  //Debug

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
    // PlayerPawn(Owner).ClientMessage("xxAddTweak zzTweaksFound: "@zzTweaksFound);  //Debug
}

// =============================================================================
// xxCheckReply ~ Process the reply of the latest check - kick player if needed
// =============================================================================
simulated function xxCheckReply (string zzReply)
{
    // Verify result
    local int zzTweaksFound;
    local int zzTestsExecuted;
    local int zzTestsExpected;
    local string zzTweaksReply;
    
    zzTestsExpected = (int(zzActor.bCheckRMode) + int(zzActor.bCheckRendering) + int(zzActor.bCheckPlayerSkins) + int (zzActor.bCheckFlags) + int(zzActor.bCheckPowerUps) + int (zzActor.bCheckBeltHacks) + int(zzActor.bCheckWeaponModels));

    // Check Length
    if (Len(zzReply)%33 != zzCheckKey%33)
    {
        PlayerPawn(Owner).ClientMessage("if (Len(zzReply)%33 != zzCheckKey%33)");
        xxKickPlayer("Check Failed - Code 1");
        return;
    }

    zzTweaksFound = int(xxGetToken(zzReply,0));
    zzTweaksReply = xxGetToken(zzReply,1);
    zzTestsExecuted = int(xxGetToken(zzReply,2));

    // PlayerPawn(Owner).ClientMessage("xxCheckReply zzTweaksFound: "@zzTweaksFound); //Debug

    if (zzTweaksFound != 0)
    {
        if (zzActor.bStealthMode)
        {
            // xxClientMessage("zzCheckValid True via bStealthMode");  //Debug
            zzCheckValid = true;
            return;
        }
        else
        {
            xxKickPlayer(zzTweaksReply,zzTweaksFound);
            return;
        }
    }
    else if (zzTestsExecuted != zzTestsExpected)
    {
        xxKickPlayer("Check Failed - Code 2 -"@zzTestsExecuted@zzTestsExpected);
    }
    else
    {
        // xxClientMessage("zzCheckValid True");  //Debug
        zzCheckValid = true;
        return;
    }
}

// ===============================================================================
// xxDisableIGPlusClassTweaks ~ Reset tweaks made to IG+ weapon classes
// ===============================================================================

simulated function xxDisableIGPlusClassTweaks(TBDefaults zzD, class<Actor> zzDynClass)
{
    //PlayerPawn(Owner).ClientMessage("IG+ Tweaks Disabled for: "@zzDynClass.Name);  //Debug

    if(InStr(zzDynClass.Name, "ShockProj") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked ShockProj");  //Debug
        zzDynClass.default.Style = zzD.zzShockProjDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzShockProjDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzShockProjDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzShockProjDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzShockProjDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzShockProjDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzShockProjDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzShockProjDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzShockProjDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzShockProjDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzShockProjDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "BioGlob") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked BioGlob");  //Debug
        zzDynClass.default.Style = zzD.zzBioGlobDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzBioGlobDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzBioGlobDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzBioGlobDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzBioGlobDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzBioGlobDefaults.bUnlit;
        zzDynClass.default.LightHue = zzD.zzBioGlobDefaults.LightHue;
        zzDynClass.default.LightSaturation = zzD.zzBioGlobDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzBioGlobDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzBioGlobDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzBioGlobDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzBioGlobDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "BioSplash") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked BioSplash");  //Debug
        zzDynClass.default.Style = zzD.zzBioSplashDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzBioSplashDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzBioSplashDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzBioSplashDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzBioSplashDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzBioSplashDefaults.bUnlit;
        zzDynClass.default.LightHue = zzD.zzBioSplashDefaults.LightHue;
        zzDynClass.default.LightSaturation = zzD.zzBioSplashDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzBioSplashDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzBioSplashDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzBioSplashDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzBioSplashDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "FlakSlug") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked FlakSlug");  //Debug
        zzDynClass.default.Style = zzD.zzFlakSlugDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzFlakSlugDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzFlakSlugDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzFlakSlugDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzFlakSlugDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzFlakSlugDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzFlakSlugDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzFlakSlugDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzFlakSlugDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzFlakSlugDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzFlakSlugDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "minigun2") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked minigun2");  //Debug
        zzDynClass.default.Style = zzD.zzMinigun2Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzMinigun2Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzMinigun2Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzMinigun2Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzMinigun2Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzMinigun2Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzMinigun2Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzMinigun2Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzMinigun2Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzMinigun2Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzMinigun2Defaults.Fatness;

        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzMinigun2Defaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzMinigun2Defaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzMinigun2Defaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "UT_BioRifle") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_BioRifle");  //Debug
        zzDynClass.default.Style = zzD.zzUT_BioRifleDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_BioRifleDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_BioRifleDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_BioRifleDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_BioRifleDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_BioRifleDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUT_BioRifleDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_BioRifleDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_BioRifleDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_BioRifleDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_BioRifleDefaults.Fatness;

        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzUT_BioRifleDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzUT_BioRifleDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzUT_BioRifleDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "ImpactHammer") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked ImpactHammer");  //Debug
        zzDynClass.default.Style = zzD.zzImpactHammerDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzImpactHammerDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzImpactHammerDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzImpactHammerDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzImpactHammerDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzImpactHammerDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzImpactHammerDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzImpactHammerDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzImpactHammerDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzImpactHammerDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzImpactHammerDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzImpactHammerDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzImpactHammerDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzImpactHammerDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "PBolt") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked PBolt");  //Debug
        zzDynClass.default.Style = zzD.zzPBoltDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzPBoltDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzPBoltDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzPBoltDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzPBoltDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzPBoltDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzPBoltDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzPBoltDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzPBoltDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzPBoltDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzPBoltDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "PlasmaSphere") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked PlasmaSphere");  //Debug
        zzDynClass.default.Style = zzD.zzPlasmaSphereDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzPlasmaSphereDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzPlasmaSphereDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzPlasmaSphereDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzPlasmaSphereDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzPlasmaSphereDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzPlasmaSphereDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzPlasmaSphereDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzPlasmaSphereDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzPlasmaSphereDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzPlasmaSphereDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "PulseGun") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked PulseGun");  //Debug
        zzDynClass.default.Style = zzD.zzPulseGunDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzPulseGunDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzPulseGunDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzPulseGunDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzPulseGunDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzPulseGunDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzPulseGunDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzPulseGunDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzPulseGunDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzPulseGunDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzPulseGunDefaults.Fatness;
        class<Weapon>(zzDynClass).default.MuzzleFlashMesh = zzD.zzPulseGunDefaults.MuzzleFlashMesh;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzPulseGunDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzPulseGunDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzPulseGunDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "Razor2") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked Razor2");  //Debug
        zzDynClass.default.Style = zzD.zzRazor2Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzRazor2Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzRazor2Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzRazor2Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzRazor2Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzRazor2Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzRazor2Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzRazor2Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzRazor2Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzRazor2Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzRazor2Defaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "Razor2Alt") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked Razor2Alt");  //Debug
        zzDynClass.default.Style = zzD.zzRazor2AltDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzRazor2AltDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzRazor2AltDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzRazor2AltDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzRazor2AltDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzRazor2AltDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzRazor2AltDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzRazor2AltDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzRazor2AltDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzRazor2AltDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzRazor2AltDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "enforcer") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked enforcer");  //Debug
        zzDynClass.default.Style = zzD.zzEnforcerDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzEnforcerDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzEnforcerDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzEnforcerDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzEnforcerDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzEnforcerDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzEnforcerDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzEnforcerDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzEnforcerDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzEnforcerDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzEnforcerDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzEnforcerDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzEnforcerDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzEnforcerDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "RocketMk2") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked RocketMk2");  //Debug
        zzDynClass.default.Style = zzD.zzRocketMk2Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzRocketMk2Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzRocketMk2Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzRocketMk2Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzRocketMk2Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzRocketMk2Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzRocketMk2Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzRocketMk2Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzRocketMk2Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzRocketMk2Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzRocketMk2Defaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "ShockRifle") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked ShockRifle");  //Debug
        zzDynClass.default.Style = zzD.zzShockRifleDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzShockRifleDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzShockRifleDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzShockRifleDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzShockRifleDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzShockRifleDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzShockRifleDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzShockRifleDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzShockRifleDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzShockRifleDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzShockRifleDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzShockRifleDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzShockRifleDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzShockRifleDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "ShockWave") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked ShockWave");  //Debug
        zzDynClass.default.Style = zzD.zzShockWaveDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzShockWaveDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzShockWaveDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzShockWaveDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzShockWaveDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzShockWaveDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzShockWaveDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzShockWaveDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzShockWaveDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzShockWaveDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzShockWaveDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "SniperRifle") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked SniperRifle");  //Debug
        zzDynClass.default.Style = zzD.zzSniperRifleDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzSniperRifleDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzSniperRifleDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzSniperRifleDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzSniperRifleDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzSniperRifleDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzSniperRifleDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzSniperRifleDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzSniperRifleDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzSniperRifleDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzSniperRifleDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzSniperRifleDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzSniperRifleDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzSniperRifleDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "StarterBolt") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked StarterBolt");  //Debug
        zzDynClass.default.Style = zzD.zzStarterBoltDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzStarterBoltDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzStarterBoltDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzStarterBoltDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzStarterBoltDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzStarterBoltDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzStarterBoltDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzStarterBoltDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzStarterBoltDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzStarterBoltDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzStarterBoltDefaults.Fatness;
    }
    else if(string(zzDynClass.Name) == "ST_UTChunk")
    {
        // // PlayerPawn(Owner).ClientMessage("IG+ Checked UTChunk");  //Debug
        zzDynClass.default.Style = zzD.zzUTChunkDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUTChunkDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUTChunkDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUTChunkDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUTChunkDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUTChunkDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUTChunkDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUTChunkDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUTChunkDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUTChunkDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUTChunkDefaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUTChunkDefaults.bHidden;
    }
    else if(InStr(zzDynClass.Name, "UTChunk1") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UTChunk1");  //Debug
        zzDynClass.default.Style = zzD.zzUTChunk1Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUTChunk1Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUTChunk1Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUTChunk1Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUTChunk1Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUTChunk1Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUTChunk1Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUTChunk1Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUTChunk1Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUTChunk1Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUTChunk1Defaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUTChunk1Defaults.bHidden;

    }
    else if(InStr(zzDynClass.Name, "UTChunk2") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UTChunk2");  //Debug
        zzDynClass.default.Style = zzD.zzUTChunk2Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUTChunk2Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUTChunk2Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUTChunk2Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUTChunk2Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUTChunk2Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUTChunk2Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUTChunk2Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUTChunk2Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUTChunk2Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUTChunk2Defaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUTChunk2Defaults.bHidden;
    }
    else if(InStr(zzDynClass.Name, "UTChunk3") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UTChunk3"); //Debug
        zzDynClass.default.Style = zzD.zzUTChunk3Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUTChunk3Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUTChunk3Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUTChunk3Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUTChunk3Defaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUTChunk3Defaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUTChunk3Defaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUTChunk3Defaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUTChunk3Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUTChunk3Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUTChunk3Defaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUTChunk3Defaults.bHidden;
    }
    else if(InStr(zzDynClass.Name, "UTChunk4") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UTChunk4"); //Debug
        zzDynClass.default.Style = zzD.zzUTChunk4Defaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUTChunk4Defaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUTChunk4Defaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUTChunk4Defaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUTChunk4Defaults.bMeshEnviroMap;
        zzDynClass.default.Mesh = zzD.zzUTChunk4Defaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUTChunk4Defaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUTChunk4Defaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUTChunk4Defaults.bHidden;
    }
    else if(InStr(zzDynClass.Name, "ripper") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked ripper"); //Debug
        zzDynClass.default.Style = zzD.zzRipperDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzRipperDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzRipperDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzRipperDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzRipperDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzRipperDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzRipperDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzRipperDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzRipperDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzRipperDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzRipperDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzRipperDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzRipperDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzRipperDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "UT_BioGel") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_BioGel"); //Debug
        zzDynClass.default.Style = zzD.zzUT_BioGelDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_BioGelDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_BioGelDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_BioGelDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_BioGelDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_BioGelDefaults.bUnlit;
        zzDynClass.default.LightHue = zzD.zzUT_BioGelDefaults.LightHue;
        zzDynClass.default.LightSaturation = zzD.zzUT_BioGelDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_BioGelDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_BioGelDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_BioGelDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_BioGelDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "UT_Eightball") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_Eightball"); //Debug
        zzDynClass.default.Style = zzD.zzUT_EightballDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_EightballDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_EightballDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_EightballDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_EightballDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_EightballDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUT_EightballDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_EightballDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_EightballDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_EightballDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_EightballDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzUT_EightballDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzUT_EightballDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzUT_EightballDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "UT_FlakCannon") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_FlakCannon"); //Debug
        zzDynClass.default.Style = zzD.zzUT_FlakCannonDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_FlakCannonDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_FlakCannonDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_FlakCannonDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_FlakCannonDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_FlakCannonDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUT_FlakCannonDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_FlakCannonDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_FlakCannonDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_FlakCannonDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_FlakCannonDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzUT_FlakCannonDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzUT_FlakCannonDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzUT_FlakCannonDefaults.ShakeVert;
    }
        else if(InStr(zzDynClass.Name, "UT_Grenade") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_Grenade"); //Debug
        zzDynClass.default.Style = zzD.zzUT_GrenadeDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_GrenadeDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_GrenadeDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_GrenadeDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_GrenadeDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_GrenadeDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUT_GrenadeDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_GrenadeDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_GrenadeDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_GrenadeDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_GrenadeDefaults.Fatness;
    }
    else if(InStr(zzDynClass.Name, "UT_SeekingRocket") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked UT_SeekingRocket"); //Debug
        zzDynClass.default.Style = zzD.zzUT_SeekingRocketDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzUT_SeekingRocketDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzUT_SeekingRocketDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzUT_SeekingRocketDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzUT_SeekingRocketDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzUT_SeekingRocketDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzUT_SeekingRocketDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzUT_SeekingRocketDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzUT_SeekingRocketDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzUT_SeekingRocketDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzUT_SeekingRocketDefaults.Fatness;
        zzDynClass.default.bHidden = zzD.zzUT_SeekingRocketDefaults.bHidden;
        zzDynClass.default.PrePivot = zzD.zzUT_SeekingRocketDefaults.PrePivot;
    }
    else if(InStr(zzDynClass.Name, "WarheadLauncher") != -1)
    {
        // PlayerPawn(Owner).ClientMessage("IG+ Checked WarheadLauncher"); //Debug
        zzDynClass.default.Style = zzD.zzWarheadLauncherDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzWarheadLauncherDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzWarheadLauncherDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzWarheadLauncherDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzWarheadLauncherDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzWarheadLauncherDefaults.bUnlit;
        zzDynClass.default.LightSaturation = zzD.zzWarheadLauncherDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzWarheadLauncherDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzWarheadLauncherDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzWarheadLauncherDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzWarheadLauncherDefaults.Fatness;
        class<Weapon>(zzDynClass).default.ShakeMag = zzD.zzWarheadLauncherDefaults.ShakeMag;
        class<Weapon>(zzDynClass).default.ShakeTime = zzD.zzWarheadLauncherDefaults.ShakeTime;
        class<Weapon>(zzDynClass).default.ShakeVert = zzD.zzWarheadLauncherDefaults.ShakeVert;
    }
    else if(InStr(zzDynClass.Name, "TranslocatorTarget") != -1)
    {
        zzDynClass.default.Style = zzD.zzTranslocatorTargetDefaults.Style;
        zzDynClass.default.DrawScale = zzD.zzTranslocatorTargetDefaults.DrawScale;
        zzDynClass.default.DrawType = zzD.zzTranslocatorTargetDefaults.DrawType;
        zzDynClass.default.Texture = zzD.zzTranslocatorTargetDefaults.Texture;
        zzDynClass.default.bMeshEnviroMap = zzD.zzTranslocatorTargetDefaults.bMeshEnviroMap;
        zzDynClass.default.bUnlit = zzD.zzTranslocatorTargetDefaults.bUnlit;
        zzDynClass.default.LightBrightness = zzD.zzTranslocatorTargetDefaults.LightBrightness;
        zzDynClass.default.LightSaturation = zzD.zzTranslocatorTargetDefaults.LightSaturation;
        zzDynClass.default.LightRadius = zzD.zzTranslocatorTargetDefaults.LightRadius;
        zzDynClass.default.Mesh = zzD.zzTranslocatorTargetDefaults.Mesh;
        zzDynClass.default.LifeSpan = zzD.zzTranslocatorTargetDefaults.LifeSpan;
        zzDynClass.default.Fatness = zzD.zzTranslocatorTargetDefaults.Fatness;
    }
}


// =============================================================================
// xxResetDefaultClass ~ Reset sent classes back to defaults
// =============================================================================

simulated function xxResetDefaultClass(TBDefaults.Properties Str, class<Actor> Cls)
{
    local class<Weapon> WeaponClass;
    local class<AnimSpriteEffect> AnimSpriteEffectClass;

    WeaponClass = class<Weapon>(Cls);
    AnimSpriteEffectClass = class<AnimSpriteEffect>(Cls);
    
    Cls.default.DrawScale = Str.DrawScale;
    Cls.default.DrawType = Str.DrawType;
    Cls.default.Texture = Str.Texture;
    Cls.default.Skin = Str.Skin;
    Cls.default.bHidden = Str.bHidden;
    Cls.default.bUnlit = Str.bUnlit;
    Cls.default.bMeshEnviroMap = Str.bMeshEnviroMap;
    Cls.default.LightBrightness = Str.LightBrightness;
    Cls.default.LightSaturation = Str.LightSaturation;
    Cls.default.LightRadius = Str.LightRadius;
    Cls.default.Mesh = Str.Mesh;
    Cls.default.Fatness = Str.Fatness;
    Cls.default.LifeSpan = Str.LifeSpan;
    Cls.default.RotationRate = Str.RotationRate;
    Cls.default.bParticles = Str.bParticles;
    Cls.default.bRandomFrame = Str.bRandomFrame;
    Cls.default.ScaleGlow = Str.ScaleGlow;
    Cls.default.bHighDetail = Str.bHighDetail;
    Cls.default.PrePivot = Str.PrePivot;

    if (WeaponClass != None)
    {
        // Store weapon-specific properties
        WeaponClass.default.ShakeMag = Str.ShakeMag;
        WeaponClass.default.ShakeTime = Str.ShakeTime;
        WeaponClass.default.ShakeVert = Str.ShakeVert;
        WeaponClass.default.bDrawMuzzleFlash = Str.bDrawMuzzleFlash;
        WeaponClass.default.FlareOffset = Str.FlareOffset;
        WeaponClass.default.FlashC = Str.FlashC;
        WeaponClass.default.FlashLength = Str.FlashLength;
        WeaponClass.default.FlashO = Str.FlashO;
        WeaponClass.default.FlashS = Str.FlashS;
        WeaponClass.default.FlashY = Str.FlashY;
        WeaponClass.default.MFTexture = Str.MFTexture;
        WeaponClass.default.MuzzleFlare = Str.MuzzleFlare;
        WeaponClass.default.MuzzleFlashMesh = Str.MuzzleFlashMesh;
        WeaponClass.default.MuzzleScale = Str.MuzzleScale;
        WeaponClass.default.MuzzleFlashStyle = Str.MuzzleFlashStyle;
        WeaponClass.default.MuzzleFlashTexture = Str.MuzzleFlashTexture;
        WeaponClass.default.Muzzleflashscale = Str.Muzzleflashscale;
    }
    // Check if the class is a subclass of AnimSpriteEffect
    if (AnimSpriteEffectClass != None)
    {
        // Store projectile-specific properties
        AnimSpriteEffectClass.default.SpriteAnim[0] = Str.SpriteAnim[0];
        AnimSpriteEffectClass.default.SpriteAnim[1] = Str.SpriteAnim[1];
        AnimSpriteEffectClass.default.SpriteAnim[2] = Str.SpriteAnim[2];
        AnimSpriteEffectClass.default.SpriteAnim[3] = Str.SpriteAnim[3];
        AnimSpriteEffectClass.default.SpriteAnim[4] = Str.SpriteAnim[4];
        AnimSpriteEffectClass.default.SpriteAnim[5] = Str.SpriteAnim[5];
        AnimSpriteEffectClass.default.SpriteAnim[6] = Str.SpriteAnim[6];
    }
}

// ===================================================================================
// xxDisableBaseClassTweaks ~ Disable tweaks for base class defaults and spawned items
// ===================================================================================

simulated function xxDisableBaseClassTweaks(TBDefaults zzD)
{
    // Declare local variables to search for existing actors

    // Power-ups
    local UT_ShieldBelt zzshieldBelt;
    local UDamage zzUDamage;
    local UT_Invisibility zzInvisibility;
    local Armor2 zzArmor2;
    local ThighPads zzThighPads;
    local UT_JumpBoots zzJumpBoots;

    // Health Pickup defaults
    local Medbox zzMedbox;
    local HealthPack zzHealthPack;
    local HealthVial zzHealthVial;

    // Ammo Pickup defaults
    local Eclip zzEclip;
    local MiniAmmo zzMiniAmmo;
    local BioAmmo zzBioAmmo;
    local ShockCore zzShockCore;
    local PAmmo zzPAmmo;
    local BladeHopper zzBladeHopper;
    local FlakAmmo zzFlakAmmo;
    local RocketPack zzRocketPack;
    local BulletBox zzBulletBox;

    // Weapon defaults
    local UT_Eightball zzUT_Eightball;
    local UT_FlakCannon zzUT_FlakCannon;
    local ShockRifle zzShockRifle;
    local SniperRifle zzSniperRifle;
    local Minigun2 zzMinigun2;
    local PulseGun zzPulseGun;
    local Enforcer zzEnforcer;
    local Ripper zzRipper;
    local UT_Biorifle zzUT_Biorifle;
    local ImpactHammer zzImpactHammer;
    local WarheadLauncher zzWarheadLauncher;

    // Hidden dead bodies
    local TMale1 zzTMale1;
    local Tmale2 zzTmale2;
    local TFemale1 zzTFemale1;
    local TFemale2 zzTFemale2;
    local TBoss zzTBoss;

    // Misc
    local WaterZone zzWaterZone;
    local WaterRing zzWaterRing;
    
    // Reset weapon defaults
    xxResetDefaultClass(zzD.zzUT_EightballDefaults, class'UT_Eightball');
    xxResetDefaultClass(zzD.zzUT_FlakCannonDefaults, class'UT_FlakCannon');
    xxResetDefaultClass(zzD.zzUT_BioRifleDefaults, class'UT_BioRifle');
    xxResetDefaultClass(zzD.zzMinigun2Defaults, class'Minigun2');
    xxResetDefaultClass(zzD.zzPulseGunDefaults, class'PulseGun');
    xxResetDefaultClass(zzD.zzRipperDefaults, class'Ripper');
    xxResetDefaultClass(zzD.zzEnforcerDefaults, class'Enforcer');
    xxResetDefaultClass(zzD.zzImpactHammerDefaults, class'ImpactHammer');
    xxResetDefaultClass(zzD.zzShockRifleDefaults, class'ShockRifle');
    xxResetDefaultClass(zzD.zzSniperRifleDefaults, class'SniperRifle');
    xxResetDefaultClass(zzD.zzWarheadLauncherDefaults, class'WarheadLauncher');

    // Reset spawned weapon item to default

    foreach Level.AllActors(class'UT_Eightball', zzUT_Eightball)
        {
            if (zzUT_Eightball != none)
            {
                zzUT_Eightball.Style = zzD.zzUT_EightballDefaults.Style;
                zzUT_Eightball.DrawScale = zzD.zzUT_EightballDefaults.DrawScale;
                zzUT_Eightball.DrawType = zzD.zzUT_EightballDefaults.DrawType;
                zzUT_Eightball.Texture = zzD.zzUT_EightballDefaults.Texture;
                zzUT_Eightball.bMeshEnviroMap = zzD.zzUT_EightballDefaults.bMeshEnviroMap;
                zzUT_Eightball.bUnlit = zzD.zzUT_EightballDefaults.bUnlit;
                zzUT_Eightball.ShakeMag = zzD.zzUT_EightballDefaults.ShakeMag;
                zzUT_Eightball.ShakeTime = zzD.zzUT_EightballDefaults.ShakeTime;
                zzUT_Eightball.ShakeVert = zzD.zzUT_EightballDefaults.ShakeVert;
                zzUT_Eightball.RotationRate = zzD.zzUT_EightballDefaults.RotationRate;
            }
        }
    
    foreach Level.AllActors(class'UT_FlakCannon', zzUT_FlakCannon)
        {
            if (zzUT_FlakCannon != none)
            {
                zzUT_FlakCannon.Style = zzD.zzUT_FlakCannonDefaults.Style;
                zzUT_FlakCannon.DrawScale = zzD.zzUT_FlakCannonDefaults.DrawScale;
                zzUT_FlakCannon.DrawType = zzD.zzUT_FlakCannonDefaults.DrawType;
                zzUT_FlakCannon.Texture = zzD.zzUT_FlakCannonDefaults.Texture;
                zzUT_FlakCannon.bMeshEnviroMap = zzD.zzUT_FlakCannonDefaults.bMeshEnviroMap;
                zzUT_FlakCannon.bUnlit = zzD.zzUT_FlakCannonDefaults.bUnlit;
                zzUT_FlakCannon.ShakeMag = zzD.zzUT_FlakCannonDefaults.ShakeMag;
                zzUT_FlakCannon.ShakeTime = zzD.zzUT_FlakCannonDefaults.ShakeTime;
                zzUT_FlakCannon.ShakeVert = zzD.zzUT_FlakCannonDefaults.ShakeVert;
                zzUT_FlakCannon.RotationRate = zzD.zzUT_FlakCannonDefaults.RotationRate;
            }
        }

    foreach Level.AllActors(class'UT_BioRifle', zzUT_BioRifle)
        {
            if (zzUT_BioRifle != none)
            {
                zzUT_BioRifle.Style = zzD.zzUT_BioRifleDefaults.Style;
                zzUT_BioRifle.DrawScale = zzD.zzUT_BioRifleDefaults.DrawScale;
                zzUT_BioRifle.DrawType = zzD.zzUT_BioRifleDefaults.DrawType;
                zzUT_BioRifle.Texture = zzD.zzUT_BioRifleDefaults.Texture;
                zzUT_BioRifle.bMeshEnviroMap = zzD.zzUT_BioRifleDefaults.bMeshEnviroMap;
                zzUT_BioRifle.bUnlit = zzD.zzUT_BioRifleDefaults.bUnlit;
                zzUT_BioRifle.ShakeMag = zzD.zzUT_BioRifleDefaults.ShakeMag;
                zzUT_BioRifle.ShakeTime = zzD.zzUT_BioRifleDefaults.ShakeTime;
                zzUT_BioRifle.ShakeVert = zzD.zzUT_BioRifleDefaults.ShakeVert;
                zzUT_BioRifle.RotationRate = zzD.zzUT_BioRifleDefaults.RotationRate;
            }
        }

    foreach Level.AllActors(class'Minigun2', zzMinigun2)
        {
            if (zzMinigun2 != none)
            {
                zzMinigun2.Style = zzD.zzMinigun2Defaults.Style;
                zzMinigun2.DrawScale = zzD.zzMinigun2Defaults.DrawScale;
                zzMinigun2.DrawType = zzD.zzMinigun2Defaults.DrawType;
                zzMinigun2.Texture = zzD.zzMinigun2Defaults.Texture;
                zzMinigun2.bMeshEnviroMap = zzD.zzMinigun2Defaults.bMeshEnviroMap;
                zzMinigun2.bUnlit = zzD.zzMinigun2Defaults.bUnlit;
                zzMinigun2.ShakeMag = zzD.zzMinigun2Defaults.ShakeMag;
                zzMinigun2.ShakeTime = zzD.zzMinigun2Defaults.ShakeTime;
                zzMinigun2.ShakeVert = zzD.zzMinigun2Defaults.ShakeVert;
                zzMinigun2.RotationRate = zzD.zzMinigun2Defaults.RotationRate;
            }
        }

    foreach Level.AllActors(class'PulseGun', zzPulseGun)
        {
            if (zzPulseGun != none)
            {
                zzPulseGun.Style = zzD.zzPulseGunDefaults.Style;
                zzPulseGun.DrawScale = zzD.zzPulseGunDefaults.DrawScale;
                zzPulseGun.DrawType = zzD.zzPulseGunDefaults.DrawType;
                zzPulseGun.Texture = zzD.zzPulseGunDefaults.Texture;
                zzPulseGun.bMeshEnviroMap = zzD.zzPulseGunDefaults.bMeshEnviroMap;
                zzPulseGun.bUnlit = zzD.zzPulseGunDefaults.bUnlit;
                zzPulseGun.ShakeMag = zzD.zzPulseGunDefaults.ShakeMag;
                zzPulseGun.ShakeTime = zzD.zzPulseGunDefaults.ShakeTime;
                zzPulseGun.ShakeVert = zzD.zzPulseGunDefaults.ShakeVert;
                zzPulseGun.RotationRate = zzD.zzPulseGunDefaults.RotationRate;
            }
        }

    foreach Level.AllActors(class'Ripper', zzRipper)
        {
            if (zzRipper != none)
            {
                zzRipper.Style = zzD.zzRipperDefaults.Style;
                zzRipper.DrawScale = zzD.zzRipperDefaults.DrawScale;
                zzRipper.DrawType = zzD.zzRipperDefaults.DrawType;
                zzRipper.Texture = zzD.zzRipperDefaults.Texture;
                zzRipper.bMeshEnviroMap = zzD.zzRipperDefaults.bMeshEnviroMap;
                zzRipper.bUnlit = zzD.zzRipperDefaults.bUnlit;
                zzRipper.ShakeMag = zzD.zzRipperDefaults.ShakeMag;
                zzRipper.ShakeTime = zzD.zzRipperDefaults.ShakeTime;
                zzRipper.ShakeVert = zzD.zzRipperDefaults.ShakeVert;
                zzRipper.RotationRate = zzD.zzRipperDefaults.RotationRate;
            }
        }
    
    foreach Level.AllActors(class'Enforcer', zzEnforcer)
        {
            if (zzEnforcer != none)
            {
                zzEnforcer.Style = zzD.zzEnforcerDefaults.Style;
                zzEnforcer.DrawScale = zzD.zzEnforcerDefaults.DrawScale;
                zzEnforcer.DrawType = zzD.zzEnforcerDefaults.DrawType;
                zzEnforcer.Texture = zzD.zzEnforcerDefaults.Texture;
                zzEnforcer.bMeshEnviroMap = zzD.zzEnforcerDefaults.bMeshEnviroMap;
                zzEnforcer.bUnlit = zzD.zzEnforcerDefaults.bUnlit;
                zzEnforcer.ShakeMag = zzD.zzEnforcerDefaults.ShakeMag;
                zzEnforcer.ShakeTime = zzD.zzEnforcerDefaults.ShakeTime;
                zzEnforcer.ShakeVert = zzD.zzEnforcerDefaults.ShakeVert;
                zzEnforcer.RotationRate = zzD.zzEnforcerDefaults.RotationRate;
            }
        }

    foreach Level.AllActors(class'ImpactHammer', zzImpactHammer)
        {
            if (zzImpactHammer != none)
            {
                zzImpactHammer.Style = zzD.zzImpactHammerDefaults.Style;
                zzImpactHammer.DrawScale = zzD.zzImpactHammerDefaults.DrawScale;
                zzImpactHammer.DrawType = zzD.zzImpactHammerDefaults.DrawType;
                zzImpactHammer.Texture = zzD.zzImpactHammerDefaults.Texture;
                zzImpactHammer.bMeshEnviroMap = zzD.zzImpactHammerDefaults.bMeshEnviroMap;
                zzImpactHammer.bUnlit = zzD.zzImpactHammerDefaults.bUnlit;
                zzImpactHammer.ShakeMag = zzD.zzImpactHammerDefaults.ShakeMag;
                zzImpactHammer.ShakeTime = zzD.zzImpactHammerDefaults.ShakeTime;
                zzImpactHammer.ShakeVert = zzD.zzImpactHammerDefaults.ShakeVert;
                zzImpactHammer.RotationRate = zzD.zzImpactHammerDefaults.RotationRate;
            }
        }
    
    foreach Level.AllActors(class'ShockRifle', zzShockRifle)
        {
            if (zzShockRifle != none)
            {
                zzShockRifle.Style = zzD.zzShockRifleDefaults.Style;
                zzShockRifle.DrawScale = zzD.zzShockRifleDefaults.DrawScale;
                zzShockRifle.DrawType = zzD.zzShockRifleDefaults.DrawType;
                zzShockRifle.Texture = zzD.zzShockRifleDefaults.Texture;
                zzShockRifle.bMeshEnviroMap = zzD.zzShockRifleDefaults.bMeshEnviroMap;
                zzShockRifle.bUnlit = zzD.zzShockRifleDefaults.bUnlit;
                zzShockRifle.ShakeMag = zzD.zzShockRifleDefaults.ShakeMag;
                zzShockRifle.ShakeTime = zzD.zzShockRifleDefaults.ShakeTime;
                zzShockRifle.ShakeVert = zzD.zzShockRifleDefaults.ShakeVert;
                zzShockRifle.RotationRate = zzD.zzShockRifleDefaults.RotationRate;
            }
        }
    
    foreach Level.AllActors(class'SniperRifle', zzSniperRifle)
        {
            if (zzSniperRifle != none)
            {
                zzSniperRifle.Style = zzD.zzSniperRifleDefaults.Style;
                zzSniperRifle.DrawScale = zzD.zzSniperRifleDefaults.DrawScale;
                zzSniperRifle.DrawType = zzD.zzSniperRifleDefaults.DrawType;
                zzSniperRifle.Texture = zzD.zzSniperRifleDefaults.Texture;
                zzSniperRifle.bMeshEnviroMap = zzD.zzSniperRifleDefaults.bMeshEnviroMap;
                zzSniperRifle.bUnlit = zzD.zzSniperRifleDefaults.bUnlit;
                zzSniperRifle.ShakeMag = zzD.zzSniperRifleDefaults.ShakeMag;
                zzSniperRifle.ShakeTime = zzD.zzSniperRifleDefaults.ShakeTime;
                zzSniperRifle.ShakeVert = zzD.zzSniperRifleDefaults.ShakeVert;
                zzSniperRifle.RotationRate = zzD.zzSniperRifleDefaults.RotationRate;
            }
        }
    
    foreach Level.AllActors(class'WarheadLauncher', zzWarheadLauncher)
        {
            if (zzWarheadLauncher != none)
            {
                zzWarheadLauncher.Style = zzD.zzWarheadLauncherDefaults.Style;
                zzWarheadLauncher.DrawScale = zzD.zzWarheadLauncherDefaults.DrawScale;
                zzWarheadLauncher.DrawType = zzD.zzWarheadLauncherDefaults.DrawType;
                zzWarheadLauncher.Texture = zzD.zzWarheadLauncherDefaults.Texture;
                zzWarheadLauncher.bMeshEnviroMap = zzD.zzWarheadLauncherDefaults.bMeshEnviroMap;
                zzWarheadLauncher.bUnlit = zzD.zzWarheadLauncherDefaults.bUnlit;
                zzWarheadLauncher.ShakeMag = zzD.zzWarheadLauncherDefaults.ShakeMag;
                zzWarheadLauncher.ShakeTime = zzD.zzWarheadLauncherDefaults.ShakeTime;
                zzWarheadLauncher.ShakeVert = zzD.zzWarheadLauncherDefaults.ShakeVert;
                zzWarheadLauncher.RotationRate = zzD.zzWarheadLauncherDefaults.RotationRate;
            }
        }

    // Reset Power-Up Item Defaults
    xxResetDefaultClass(zzD.zzShieldBeltEffectDefaults, class'UT_ShieldBeltEffect');
    xxResetDefaultClass(zzD.zzShieldBeltDefaults, class'UT_ShieldBelt');
    xxResetDefaultClass(zzD.zzUDamageDefaults, class'UDamage');
    xxResetDefaultClass(zzD.zzInvisibilityDefaults, class'UT_Invisibility');
    xxResetDefaultClass(zzD.zzArmor2Defaults, class'Armor2');
    xxResetDefaultClass(zzD.zzThighPadsDefaults, class'ThighPads');
    xxResetDefaultClass(zzD.zzUT_JumpBootsDefaults, class'UT_JumpBoots');

    foreach Level.AllActors(class'UT_ShieldBelt', zzShieldBelt)
        {
            if (zzShieldBelt != none)
            {
                zzShieldBelt.Style = zzD.zzShieldBeltDefaults.Style;
                zzShieldBelt.DrawScale = zzD.zzShieldBeltDefaults.DrawScale;
                zzShieldBelt.DrawType = zzD.zzShieldBeltDefaults.DrawType;
                zzShieldBelt.Texture = zzD.zzShieldBeltDefaults.Texture;
                zzShieldBelt.bMeshEnviroMap = zzD.zzShieldBeltDefaults.bMeshEnviroMap;
                zzShieldBelt.bUnlit = zzD.zzShieldBeltDefaults.bUnlit;
                zzShieldBelt.LightSaturation = zzD.zzShieldBeltDefaults.LightSaturation;
                zzShieldBelt.LightRadius = zzD.zzShieldBeltDefaults.LightRadius;
                zzShieldBelt.Mesh = zzD.zzShieldBeltDefaults.Mesh;
                zzShieldBelt.Fatness = zzD.zzShieldBeltDefaults.Fatness;
            }
        }

    foreach Level.AllActors(class'UDamage', zzUDamage)
        {
            if (zzUDamage != none)
            {
                zzUDamage.Style = zzD.zzUDamageDefaults.Style;
                zzUDamage.DrawScale = zzD.zzUDamageDefaults.DrawScale;
                zzUDamage.DrawType = zzD.zzUDamageDefaults.DrawType;
                zzUDamage.Texture = zzD.zzUDamageDefaults.Texture;
                zzUDamage.bMeshEnviroMap = zzD.zzUDamageDefaults.bMeshEnviroMap;
                zzUDamage.bUnlit = zzD.zzUDamageDefaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'UT_Invisibility', zzInvisibility)
        {
            if (zzInvisibility != none)
            {
                
                zzInvisibility.Style = zzD.zzInvisibilityDefaults.Style;
                zzInvisibility.DrawScale = zzD.zzInvisibilityDefaults.DrawScale;
                zzInvisibility.DrawType = zzD.zzInvisibilityDefaults.DrawType;
                zzInvisibility.Texture = zzD.zzInvisibilityDefaults.Texture;
                zzInvisibility.bMeshEnviroMap = zzD.zzInvisibilityDefaults.bMeshEnviroMap;
                zzInvisibility.bUnlit = zzD.zzInvisibilityDefaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'Armor2', zzArmor2)
        {
            if (zzArmor2 != none)
            {
                zzArmor2.Style = zzD.zzArmor2Defaults.Style;
                zzArmor2.DrawScale = zzD.zzArmor2Defaults.DrawScale;
                zzArmor2.DrawType = zzD.zzArmor2Defaults.DrawType;
                zzArmor2.Texture = zzD.zzArmor2Defaults.Texture;
                zzArmor2.bMeshEnviroMap = zzD.zzArmor2Defaults.bMeshEnviroMap;
                zzArmor2.bUnlit = zzD.zzArmor2Defaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'ThighPads', zzThighPads)
        {
            if (zzThighPads != none)
            {
                zzThighPads.Style = zzD.zzThighPadsDefaults.Style;
                zzThighPads.DrawScale = zzD.zzThighPadsDefaults.DrawScale;
                zzThighPads.DrawType = zzD.zzThighPadsDefaults.DrawType;
                zzThighPads.Texture = zzD.zzThighPadsDefaults.Texture;
                zzThighPads.bMeshEnviroMap = zzD.zzThighPadsDefaults.bMeshEnviroMap;
                zzThighPads.bUnlit = zzD.zzThighPadsDefaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'UT_JumpBoots', zzJumpBoots)
        {
            if (zzJumpBoots != none)
            {
                zzJumpBoots.Style = zzD.zzUT_JumpBootsDefaults.Style;
                zzJumpBoots.DrawScale = zzD.zzUT_JumpBootsDefaults.DrawScale;
                zzJumpBoots.DrawType = zzD.zzUT_JumpBootsDefaults.DrawType;
                zzJumpBoots.Texture = zzD.zzUT_JumpBootsDefaults.Texture;
                zzJumpBoots.bMeshEnviroMap = zzD.zzUT_JumpBootsDefaults.bMeshEnviroMap;
                zzJumpBoots.bUnlit = zzD.zzUT_JumpBootsDefaults.bUnlit;
            }
        }

    // Reset health pickup defaults
    xxResetDefaultClass(zzD.zzMedboxDefaults, class'MedBox');
    xxResetDefaultClass(zzD.zzHealthPackDefaults, class'HealthPack');
    xxResetDefaultClass(zzD.zzHealthVialDefaults, class'HealthVial');

    // Reset health pickup spawned items

    foreach Level.AllActors(class'Medbox', zzMedbox)
        {
            if (zzMedbox != none)
            {
                zzMedbox.Style = zzD.zzMedboxDefaults.Style;
                zzMedbox.DrawScale = zzD.zzMedboxDefaults.DrawScale;
                zzMedbox.DrawType = zzD.zzMedboxDefaults.DrawType;
                zzMedbox.Texture = zzD.zzMedboxDefaults.Texture;
                zzMedbox.bMeshEnviroMap = zzD.zzMedboxDefaults.bMeshEnviroMap;
                zzMedbox.bUnlit = zzD.zzMedboxDefaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'HealthPack', zzHealthPack)
        {
            if (zzHealthPack != none)
            {
                zzHealthPack.Style = zzD.zzHealthPackDefaults.Style;
                zzHealthPack.DrawScale = zzD.zzHealthPackDefaults.DrawScale;
                zzHealthPack.DrawType = zzD.zzHealthPackDefaults.DrawType;
                zzHealthPack.Texture = zzD.zzHealthPackDefaults.Texture;
                zzHealthPack.bMeshEnviroMap = zzD.zzHealthPackDefaults.bMeshEnviroMap;
                zzHealthPack.bUnlit = zzD.zzHealthPackDefaults.bUnlit;
                
            }
        }
    
    foreach Level.AllActors(class'HealthVial', zzHealthVial)
        {
            if (zzHealthVial != none)
            {
                zzHealthVial.Style = zzD.zzHealthVialDefaults.Style;
                zzHealthVial.DrawScale = zzD.zzHealthVialDefaults.DrawScale;
                zzHealthVial.DrawType = zzD.zzHealthVialDefaults.DrawType;
                zzHealthVial.Texture = zzD.zzHealthVialDefaults.Texture;
                zzHealthVial.bMeshEnviroMap = zzD.zzHealthVialDefaults.bMeshEnviroMap;
                zzHealthVial.bUnlit = zzD.zzHealthVialDefaults.bUnlit;
            }
        }

    // Reset ammo pickup defaults
    xxResetDefaultClass(zzD.zzEclipDefaults, class'EClip');
    xxResetDefaultClass(zzD.zzMiniAmmoDefaults, class'MiniAmmo');
    xxResetDefaultClass(zzD.zzBioAmmoDefaults, class'BioAmmo');
    xxResetDefaultClass(zzD.zzShockCoreDefaults, class'ShockCore');
    xxResetDefaultClass(zzD.zzPAmmoDefaults, class'PAmmo');
    xxResetDefaultClass(zzD.zzBladeHopperDefaults, class'BladeHopper');
    xxResetDefaultClass(zzD.zzFlakAmmoDefaults, class'FlakAmmo');
    xxResetDefaultClass(zzD.zzRocketPackDefaults, class'RocketPack');
    xxResetDefaultClass(zzD.zzBulletBoxDefaults, class'BulletBox');

    // Reset ammo pickup spawned items
    foreach Level.AllActors(class'Eclip', zzEclip)
        {
            if (zzEclip != none)
            {
                zzEclip.Style = zzD.zzEclipDefaults.Style;
                zzEclip.DrawScale = zzD.zzEclipDefaults.DrawScale;
                zzEclip.DrawType = zzD.zzEclipDefaults.DrawType;
                zzEclip.Texture = zzD.zzEclipDefaults.Texture;
                zzEclip.bMeshEnviroMap = zzD.zzEclipDefaults.bMeshEnviroMap;
                zzEclip.bUnlit = zzD.zzEclipDefaults.bUnlit;
                
            }
        }

    foreach Level.AllActors(class'MiniAmmo', zzMiniAmmo)
        {
            if (zzMiniAmmo != none)
            {
                zzMiniAmmo.Style = zzD.zzMiniAmmoDefaults.Style;
                zzMiniAmmo.DrawScale = zzD.zzMiniAmmoDefaults.DrawScale;
                zzMiniAmmo.DrawType = zzD.zzMiniAmmoDefaults.DrawType;
                zzMiniAmmo.Texture = zzD.zzMiniAmmoDefaults.Texture;
                zzMiniAmmo.bMeshEnviroMap = zzD.zzMiniAmmoDefaults.bMeshEnviroMap;
                zzMiniAmmo.bUnlit = zzD.zzMiniAmmoDefaults.bUnlit;
                
            }
        }
    
    foreach Level.AllActors(class'BioAmmo', zzBioAmmo)
        {
            if (zzBioAmmo != none)
            {
                zzBioAmmo.Style = zzD.zzBioAmmoDefaults.Style;
                zzBioAmmo.DrawScale = zzD.zzBioAmmoDefaults.DrawScale;
                zzBioAmmo.DrawType = zzD.zzBioAmmoDefaults.DrawType;
                zzBioAmmo.Texture = zzD.zzBioAmmoDefaults.Texture;
                zzBioAmmo.bMeshEnviroMap = zzD.zzBioAmmoDefaults.bMeshEnviroMap;
                zzBioAmmo.bUnlit = zzD.zzBioAmmoDefaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'ShockCore', zzShockCore)
        {
            if (zzShockCore != none)
            {
                zzShockCore.Style = zzD.zzShockCoreDefaults.Style;
                zzShockCore.DrawScale = zzD.zzShockCoreDefaults.DrawScale;
                zzShockCore.DrawType = zzD.zzShockCoreDefaults.DrawType;
                zzShockCore.Texture = zzD.zzShockCoreDefaults.Texture;
                zzShockCore.bMeshEnviroMap = zzD.zzShockCoreDefaults.bMeshEnviroMap;
                zzShockCore.bUnlit = zzD.zzShockCoreDefaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'PAmmo', zzPAmmo)
        {
            if (zzPAmmo != none)
            {
                zzPAmmo.Style = zzD.zzPAmmoDefaults.Style;
                zzPAmmo.DrawScale = zzD.zzPAmmoDefaults.DrawScale;
                zzPAmmo.DrawType = zzD.zzPAmmoDefaults.DrawType;
                zzPAmmo.Texture = zzD.zzPAmmoDefaults.Texture;
                zzPAmmo.bMeshEnviroMap = zzD.zzPAmmoDefaults.bMeshEnviroMap;
                zzPAmmo.bUnlit = zzD.zzPAmmoDefaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'BladeHopper', zzBladeHopper)
        {
            if (zzBladeHopper != none)
            {
                zzBladeHopper.Style = zzD.zzBladeHopperDefaults.Style;
                zzBladeHopper.DrawScale = zzD.zzBladeHopperDefaults.DrawScale;
                zzBladeHopper.DrawType = zzD.zzBladeHopperDefaults.DrawType;
                zzBladeHopper.Texture = zzD.zzBladeHopperDefaults.Texture;
                zzBladeHopper.bMeshEnviroMap = zzD.zzBladeHopperDefaults.bMeshEnviroMap;
                zzBladeHopper.bUnlit = zzD.zzBladeHopperDefaults.bUnlit;

            }
        }
    
    foreach Level.AllActors(class'FlakAmmo', zzFlakAmmo)
        {
            if (zzFlakAmmo != none)
            {
                zzFlakAmmo.Style = zzD.zzFlakAmmoDefaults.Style;
                zzFlakAmmo.DrawScale = zzD.zzFlakAmmoDefaults.DrawScale;
                zzFlakAmmo.DrawType = zzD.zzFlakAmmoDefaults.DrawType;
                zzFlakAmmo.Texture = zzD.zzFlakAmmoDefaults.Texture;
                zzFlakAmmo.bMeshEnviroMap = zzD.zzFlakAmmoDefaults.bMeshEnviroMap;
                zzFlakAmmo.bUnlit = zzD.zzFlakAmmoDefaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'RocketPack', zzRocketPack)
        {
            if (zzRocketPack != none)
            {
                zzRocketPack.Style = zzD.zzRocketPackDefaults.Style;
                zzRocketPack.DrawScale = zzD.zzRocketPackDefaults.DrawScale;
                zzRocketPack.DrawType = zzD.zzRocketPackDefaults.DrawType;
                zzRocketPack.Texture = zzD.zzRocketPackDefaults.Texture;
                zzRocketPack.bMeshEnviroMap = zzD.zzRocketPackDefaults.bMeshEnviroMap;
                zzRocketPack.bUnlit = zzD.zzRocketPackDefaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'BulletBox', zzBulletBox)
        {
            if (zzBulletBox != none)
            {
                zzBulletBox.Style = zzD.zzBulletBoxDefaults.Style;
                zzBulletBox.DrawScale = zzD.zzBulletBoxDefaults.DrawScale;
                zzBulletBox.DrawType = zzD.zzBulletBoxDefaults.DrawType;
                zzBulletBox.Texture = zzD.zzBulletBoxDefaults.Texture;
                zzBulletBox.bMeshEnviroMap = zzD.zzBulletBoxDefaults.bMeshEnviroMap;
                zzBulletBox.bUnlit = zzD.zzBulletBoxDefaults.bUnlit;
            }
        }


    // Reset translocator projectile defaults
    xxResetDefaultClass(zzD.zzTranslocatorTargetDefaults, class'TranslocatorTarget');
    xxResetDefaultClass(zzD.zzTranslocOutEffectDefaults, class'TranslocOutEffect');

    // Reset bio projectile defaults
    xxResetDefaultClass(zzD.zzBioGlobDefaults, class'BioGlob');
    xxResetDefaultClass(zzD.zzBioSplashDefaults, class'BioSplash');
    xxResetDefaultClass(zzD.zzUT_BioGelDefaults, class'UT_BioGel');

    // Reset rocket projectile defaults
    xxResetDefaultClass(zzD.zzRocketMk2Defaults, class'RocketMk2');
    xxResetDefaultClass(zzD.zzRocketTrailDefaults, class'RocketTrail');
    xxResetDefaultClass(zzD.zzUT_GrenadeDefaults, class'UT_Grenade');
    xxResetDefaultClass(zzD.zzUT_SeekingRocketDefaults, class'UT_SeekingRocket');

    // Reset rocket smoke defaults
    xxResetDefaultClass(zzD.zzLightSmokeTrailDefaults, class'LightSmokeTrail');
    xxResetDefaultClass(zzD.zzUT_SpriteSmokePuffDefaults, class'UT_SpriteSmokePuff');
    xxResetDefaultClass(zzD.zzUTSmokeTrailDefaults, class'UTSmokeTrail');

    // Reset rocket explosion defaults
    xxResetDefaultClass(zzD.zzUT_SpriteBallChildDefaults, class'UT_SpriteBallChild');
    xxResetDefaultClass(zzD.zzUT_SpriteBallExplosionDefaults, class'UT_SpriteBallExplosion');

    // Reset flak projectile defaults
    xxResetDefaultClass(zzD.zzChunkTrailDefaults, class'ChunkTrail');
    xxResetDefaultClass(zzD.zzUTChunkDefaults, class'UTChunk');
    xxResetDefaultClass(zzD.zzUTChunk1Defaults, class'UTChunk1');
    xxResetDefaultClass(zzD.zzUTChunk2Defaults, class'UTChunk2');
    xxResetDefaultClass(zzD.zzUTChunk3Defaults, class'UTChunk3');
    xxResetDefaultClass(zzD.zzUTChunk4Defaults, class'UTChunk4');
    xxResetDefaultClass(zzD.zzUT_FlameExplosionDefaults, class'UT_FlameExplosion');
    xxResetDefaultClass(zzD.zzFlakSlugDefaults, class'FlakSlug');

    // Reset ripper projectile defaults
    xxResetDefaultClass(zzD.zzRazor2Defaults, class'Razor2');
    xxResetDefaultClass(zzD.zzRazor2AltDefaults, class'Razor2Alt');

    // Reset impact hammer effects
    xxResetDefaultClass(zzD.zzImpactMarkDefaults, class'ImpactMark');

    // Reset shock rifle effects
    xxResetDefaultClass(zzD.zzShockExploDefaults, class'ShockExplo');
    xxResetDefaultClass(zzD.zzUT_RingExplosion5Defaults, class'UT_RingExplosion5');
    xxResetDefaultClass(zzD.zzUT_RingExplosionDefaults, class'UT_RingExplosion');
    xxResetDefaultClass(zzD.zzUT_RingExplosion4Defaults, class'UT_RingExplosion4');
    xxResetDefaultClass(zzD.zzUT_RingExplosion3Defaults, class'UT_RingExplosion3');
    xxResetDefaultClass(zzD.zzUT_ComboRingDefaults, class'UT_ComboRing');
    xxResetDefaultClass(zzD.zzShockBeamDefaults, class'ShockBeam');
    xxResetDefaultClass(zzD.zzShockRifleWaveDefaults, class'ShockRifleWave');
    xxResetDefaultClass(zzD.zzShockProjDefaults, class'ShockProj');
    xxResetDefaultClass(zzD.zzShockWaveDefaults, class'ShockWave');

    // Reset pulse gun effects
    xxResetDefaultClass(zzD.zzPlasmaCapDefaults, class'PlasmaCap');
    xxResetDefaultClass(zzD.zzPlasmaHitDefaults, class'PlasmaHit');
    xxResetDefaultClass(zzD.zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxResetDefaultClass(zzD.zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxResetDefaultClass(zzD.zzStarterBoltDefaults, class'StarterBolt');
    xxResetDefaultClass(zzD.zzStarterBoltDefaults, class'StarterBolt');
    xxResetDefaultClass(zzD.zzpBoltDefaults, class'PBolt');

    // Reset random tweaks
    xxResetDefaultClass(zzD.zzTMale1Defaults, class'TMale1');
    xxResetDefaultClass(zzD.zzTmale2Defaults, class'Tmale2');
    xxResetDefaultClass(zzD.zzTFemale1Defaults, class'TFemale1');
    xxResetDefaultClass(zzD.zzTFemale2Defaults, class'TFemale2');
    xxResetDefaultClass(zzD.zzTBossDefaults, class'TBoss');
    xxResetDefaultClass(zzD.zzTmale1CarcassDefault, class'Tmale1Carcass');
    xxResetDefaultClass(zzD.zzTmale2CarcassDefault, class'Tmale2Carcass');
    xxResetDefaultClass(zzD.zzTFemale1CarcassDefault, class'TFemale1Carcass');
    xxResetDefaultClass(zzD.zzTFemale2CarcassDefault, class'TFemale2Carcass');
    xxResetDefaultClass(zzD.zzTmalebodyDefault, class'Tmalebody');

    foreach Level.AllActors(class'TMale1', zzTMale1)
        {
            if (zzTMale1 != none)
            {
                zzTMale1.bMeshEnviroMap = zzD.zzTMale1Defaults.bMeshEnviroMap;
                zzTMale1.bUnlit = zzD.zzTMale1Defaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'Tmale2', zzTmale2)
        {
            if (zzTmale2 != none)
            {
                zzTmale2.bMeshEnviroMap = zzD.zzTmale2Defaults.bMeshEnviroMap;
                zzTmale2.bUnlit = zzD.zzTmale2Defaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'TFemale1', zzTFemale1)
        {
            if (zzTFemale1 != none)
            {
                zzTFemale1.bMeshEnviroMap = zzD.zzTFemale1Defaults.bMeshEnviroMap;
                zzTFemale1.bUnlit = zzD.zzTFemale1Defaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'TFemale2', zzTFemale2)
        {
            if (zzTFemale2 != none)
            {
                zzTFemale2.bMeshEnviroMap = zzD.zzTFemale2Defaults.bMeshEnviroMap;
                zzTFemale2.bUnlit = zzD.zzTFemale2Defaults.bUnlit;
            }
        }
    
    foreach Level.AllActors(class'TBoss', zzTBoss)
        {
            if (zzTBoss != none)
            {
                zzTBoss.bMeshEnviroMap = zzD.zzTBossDefaults.bMeshEnviroMap;
                zzTBoss.bUnlit = zzD.zzTBossDefaults.bUnlit;
            }
        }

    foreach Level.AllActors(class'WaterZone', zzWaterZone)
        {
            if (zzWaterZone != none)
            {
                zzWaterZone.viewfog = zzD.zzWaterZoneDefaults.viewfog;
            }
        }
    
    foreach Level.AllActors(class'WaterRing', zzWaterRing)
        {
            if (zzWaterRing != none)
            {
                zzWaterRing.bHidden = zzD.zzWaterRingDefaults.bHidden;
            }
        }

    // Reset wall hit defaults
    xxResetDefaultClass(zzD.zzUT_SparkDefaults, class'UT_Spark');
    xxResetDefaultClass(zzD.zzUT_SparksDefaults, class'UT_Sparks');
    xxResetDefaultClass(zzD.zzWaterZoneDefaults, class'WaterZone');
    xxResetDefaultClass(zzD.zzWaterRingDefaults, class'WaterRing');
    xxResetDefaultClass(zzD.zzmTracerDefaults, class'mTracer');
    xxResetDefaultClass(zzD.zzUT_HeavyWallHitEffectDefaults, class'UT_HeavyWallHitEffect');
    xxResetDefaultClass(zzD.zzUT_LightWallHitEffectDefaults, class'UT_LightWallHitEffect');
    xxResetDefaultClass(zzD.zzUT_WallHitDefaults, class'UT_WallHit');
    xxResetDefaultClass(zzD.zzMiniShellCaseDefaults, class'MiniShellCase');
    xxResetDefaultClass(zzD.zzUTTeleportEffectDefaults, class'UTTeleportEffect');
    xxResetDefaultClass(zzD.zzUT_GreenBloodPuffDefaults, class'UT_GreenBloodPuff');
    xxResetDefaultClass(zzD.zzUTTeleEffectDefaults, class'UTTeleEffect');
    xxResetDefaultClass(zzD.zzEnhancedRespawnDefaults, class'EnhancedRespawn');

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

    VersionStr = Level.EngineVersion$Level.GetPropertyText("EngineRevision");

    xxLog("=== Player Kick ===");
    xxLog("Player Name  :"@zzPlayerName);
    xxLog("Player IP    :"@zzPlayerIP);
    if (zzTweaksFound > 0)
    xxLog("Tweaks found :"@zzTweaksFound);
    xxLog("Tweaks       :"@zzReason);
    xxLog("=== Player Kick ===");

    zzLog.StopLog();

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
    xxConsoleCommand("disconnect");
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
        PlayerPawn(Owner).ConsoleCommand(zzCommand);
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

            zzLog.PlayerName = SafeFileName(zzPRI.PlayerName);

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

final static function string SafeFileName(string FileName) {
    FileName = Replace(FileName, ":", "_");
    FileName = Replace(FileName, ";", "_");
    FileName = Replace(FileName, "?", "");
    FileName = Replace(FileName, "/", "");
    FileName = Replace(FileName, "\\", "");
    FileName = Replace(FileName, "|", "");
    FileName = Replace(FileName, "*", "");
    FileName = Replace(FileName, "\"", "");
    FileName = Replace(FileName, "<", "");
    FileName = Replace(FileName, ">", "");
    FileName = Replace(FileName, " ", "_");

    return FileName;
}

final static function string Replace(string Haystack, string Needle, string Substitute) {
    local int Pos, NeedleLen;
    local string Result;

    NeedleLen = Len(Needle);
    Pos = InStr(Haystack, Needle);
    while(Pos >= 0) {
        Result = Result $ Left(Haystack, Pos) $ Substitute;

        Haystack = Mid(HayStack, Pos + NeedleLen);
        Pos = InStr(Haystack, Needle);
    }

    return Result $ Haystack;
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    zzMyVer="v06"
    NetPriority=10.0
}