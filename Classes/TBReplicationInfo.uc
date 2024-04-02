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
var int        zzStealthTweaksLogged;   // Number of tweaks found during stealth mode
var class<Actor> zzDynClass;           // Dynamic class for iterating through custom classes
var class<Actor> zzDynItem;            // Dynamic class for iterating through custom classes for items
var bool bDisabledCustomClassTweaks;   // Have the Custom class tweaks been disabled
var bool bDisabledBaseClassTweaks;     // Have the Base Game class tweaks been disabled
var bool bStoppedLog;                  // Has the log been sent?

var string zzDetectedTweakClassNames[128];    // For collecting the class name detected tweaks during stealth mode
var string zzDetectedTweakPropery[128];       // For collecting all detected tweaks during stealth mode
var string zzTimeStamp;                         // Time Stamp string for the log
var string zzClientVersion;                   // Game Client Version from the player

// =============================================================================
// Replication
// =============================================================================
replication
{
    // Run on clients
    reliable if (ROLE == ROLE_AUTHORITY)
        xxDisableCustomClassTweaks, xxDisableBaseClassTweaks, xxSetClassDefaults, xxCheck, xxConsoleCommand, xxShowConsole, xxGetClientVersion, xxCheckClientPackages;

    reliable if (ROLE < ROLE_AUTHORITY)
        xxCheckReply, xxStealthAddTweak, xxSaveClientVersion, xxFindClientRoguePackages;
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

    if (zzActor.bDisableTweaks) //Replicate defaults only if they're needed
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
            if (!bDisabledbaseClassTweaks)
                {
                    xxDisableBaseClassTweaks(zzDefaults);
                    bDisabledBaseClassTweaks = true;
                    // xxClientMessage("Your tweaks have been disabled"); // Debug
                }

            if (zzActor.bDisableCustomClassTweaks && !bDisabledCustomClassTweaks) // Main Toggle for Checking IG+ Classes
            {
                for (i = 0; i < ArrayCount(zzActor.CustomClassNames); i++)
                {
                    if( zzActor.CustomClassNames[i]=="" ) continue;
                    zzDynClass = None;
                    SetPropertyText("zzDynClass", "Class'"$zzActor.CustomClassNames[i]$"'");
                    if( zzDynClass==None ) continue;
                    xxDisableCustomClassTweaks(zzDefaults, zzDynClass);
                }   

                bDisabledCustomClassTweaks = true;
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
                    if (zzActor.bCheckClientPackages) // Check if client packages are enabled
                    {
                        zzState = 4; // Go to Client Packages Check
                    }
                    else
                    {
                        zzState = 5; // Go to Stealth Mode Report
                    }
                    SetTimer(3,false);    
                }
            else  // Schedule next check
             {
                zzState = 0;

                // xxClientMessage("Restarting checks in state 2...");  // Debug

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
    else if (zzState == 4) // State Check Client Packages is true
    {
        xxCheckClientPackages();

        // xxClientMessage("Restarting checks in state 4...");  // Debug

        zzState = 5; // Go to Stealth Mode Report

        SetTimer(zzActor.CheckInterval-zzActor.CheckTimeOut+RandRange(1,10),false);
        return;
    }
    else if (zzState == 5) // Stealth mode state to keep logging reports
    {
        if (zzStealthTweaksFound > zzStealthTweaksLogged) // If new tweaks were found log reports
        {
            zzTimeStamp = Level.Day$"-"$Level.Month$"-"$Level.Year$" / "$Level.Hour$":"$Level.Minute$":"$Level.Second;

            if (bStoppedLog == true) zzLog.StartLog(); // Start the log if the old one is not running

            xxLog("+------------------------------------------------------------------------------+");
            xxLog("|                       TweakBlocker Stealth Mode Report                       |");
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("PlayerName.............: "$zzPRI.PlayerName$"");
            xxLog("PlayerIP...............: "$zzPlayerIP$"");
            xxLog("PlayerClient...........: "$zzClientVersion$"");
            xxLog("TimeStamp..............: "$zzTimeStamp$"");
            xxLog("TweaksFound............: "$zzStealthTweaksFound-zzStealthTweaksLogged$"");
            xxLog("+------------------------------------------------------------------------------+");
            xxLog("|                                Tweaks List                                   |");
            xxLog("+------------------------------------------------------------------------------+");
            
            for (i = zzStealthTweaksLogged; i < zzStealthTweaksFound; i++)
                {
                    // xxClientMessage(""$zzDetectedTweakClassNames[i]$" -> "$zzDetectedTweakPropery[i]$""); //Debug
                    xxLog(""$zzDetectedTweakClassNames[i]$" -> "$zzDetectedTweakPropery[i]$"");
                    zzStealthTweaksLogged++;
                }

            xxLog("+------------------------------------------------------------------------------+");
            
            zzState = 0; // Go back to Idle and restart checks
            
            zzLog.StopLog(); // Stop the log - convert .tmp to .log
            bStoppedLog = true; // Save log state
            SetTimer(zzActor.CheckInterval-zzActor.CheckTimeOut+RandRange(1,10),false);
            return;
        }
        else
        {
            // xxClientMessage("No new tweaks logged, restarting checks...");  // Debug
            zzState = 0; // Go back to Idle and restart checks
            SetTimer(zzActor.CheckInterval-zzActor.CheckTimeOut+RandRange(1,10),false);
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

// ============================================================================================
// xxCheckClientPackages ~ Retrieves non-default client-side packages
// ============================================================================================

simulated function xxCheckClientPackages()
{
    local Actor zzActor;
    local name ClientPackages[128];
    local int i, j;

    foreach AllActors(class'Actor', zzActor)
    {
        if (zzActor.Role == ROLE_Authority && !zzActor.bStatic && !zzActor.bNoDelete && zzActor.Class.Outer.Name != 'Botpack' && zzActor.Class.Outer.Name != 'UnrealShare' && zzActor.Class.Outer.Name != 'UnrealI' && zzActor.Class.Outer.Name != Level.Outer.Name)
        {
            for (j = 0; j < i; j++)
                if (ClientPackages[j] == zzActor.Class.Outer.Name)
                    break;
            if (j == i)
            {
                ClientPackages[i++] = zzActor.Class.Outer.Name;
                xxFindClientRoguePackages(zzActor.Class.Outer.Name);
            }
        }
    }
}

// ============================================================================================
// xxFindClientRoguePackages ~ Checks for rogue packages that the server doesn't have
// ============================================================================================

simulated function xxFindClientRoguePackages(coerce string ClientPackages)
{ 
    if (IsInPackageMap(ClientPackages, true) == false)
            {
                if (zzActor.bStealthMode)
                {
                    xxStealthAddTweak("Illegal Client Package Found",ClientPackages);
                }
                else
                {
                    xxKickPlayer("Illegal Package Found: "$ClientPackages$"");
                }
            }
}

// =============================================================================
// xxGetClientVersion ~ Retrieves the client version
// =============================================================================

simulated function xxGetClientVersion()
{
    local string zzClientVer;

    zzClientVer = Level.EngineVersion$xxGetVal(Level, "EngineRevision");

    xxSaveClientVersion(zzClientVer);
}

// =============================================================================
// xxGetClientVersion ~ Saves the client version to a server variable
// =============================================================================

simulated function xxSaveClientVersion(string zzClientVer)
{
    zzClientVersion = zzClientVer;
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

    // Check for rogue packages

    if (zzA.bCheckClientPackages)
    {
        xxCheckClientPackages();
    }

    // RMode checks
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
                zzLODBias = zzA.xxGetLODBias(zzPP);

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
    local int i;

    if (zzActor.bStealthMode) // Add tweak to DetectedTweaks array if stealth mode is enabled
        {
            for (i = 0; i < zzStealthTweaksFound; i++)
            {
                if (zzDetectedTweakClassNames[i] == zzClassName && zzDetectedTweakPropery[i] == zzTweakedProperty)
                {
                    return;
                }
            }
            zzDetectedTweakClassNames[zzStealthTweaksFound] = zzClassName;
            zzDetectedTweakPropery[zzStealthTweaksFound] = zzTweakedProperty;
            zzStealthTweaksFound++;
        }
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

simulated function string xxGetVal(Actor actor, string prop) {
    local string ret;
    local ENetRole OldRole;

    OldRole = actor.Role;
    actor.Role = ROLE_Authority;
    ret = actor.GetPropertyText(prop);
    actor.Role = OldRole;

    return ret;
}

// ===============================================================================
// xxDisableCustomClassTweaks ~ Reset tweaks made to custom classes
// ===============================================================================

simulated function xxDisableCustomClassTweaks(TBDefaults zzD, class<Actor> zzDynClass)
{
    
    if (ClassIsChildOf(zzDynClass, class'ShockProj'))
    {
        xxSetClassDefaults(zzD.zzShockProjDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked ShockProj");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'PBolt'))
    {
        xxSetClassDefaults(zzD.zzPBoltDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked PBolt");  //Debug
    }

    else if(ClassIsChildOf(zzDynClass, class'BioGlob'))
    {
        xxSetClassDefaults(zzD.zzBioGlobDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked BioGlob");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'BioSplash'))
    {
        xxSetClassDefaults(zzD.zzBioSplashDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked BioSplash");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'FlakSlug'))
    {
        xxSetClassDefaults(zzD.zzFlakSlugDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked FlakSlug");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Minigun2'))
    {
        xxSetClassDefaults(zzD.zzMinigun2Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Minigun2");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_BioRifle'))
    {
        xxSetClassDefaults(zzD.zzUT_BioRifleDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_BioRifle");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'ImpactHammer'))
    {
        xxSetClassDefaults(zzD.zzImpactHammerDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked ImpactHammer");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'PlasmaSphere'))
    {
        xxSetClassDefaults(zzD.zzPlasmaSphereDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked PlasmaSphere");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'PulseGun'))
    {
        xxSetClassDefaults(zzD.zzPulseGunDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked PulseGun");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Razor2'))
    {
        xxSetClassDefaults(zzD.zzRazor2Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Razor2");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Razor2Alt'))
    {
        xxSetClassDefaults(zzD.zzRazor2AltDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Razor2Alt");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Enforcer'))
    {
        xxSetClassDefaults(zzD.zzEnforcerDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Enforcer");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'RocketMk2'))
    {
        xxSetClassDefaults(zzD.zzRocketMk2Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked RocketMk2");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'ShockRifle'))
    {
        xxSetClassDefaults(zzD.zzShockRifleDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked ShockRifle");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'ShockWave'))
    {
        xxSetClassDefaults(zzD.zzShockWaveDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked ShockWave");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'SniperRifle'))
    {
        xxSetClassDefaults(zzD.zzSniperRifleDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked SniperRifle");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'StarterBolt'))
    {
        xxSetClassDefaults(zzD.zzStarterBoltDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked StarterBolt");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UTChunk'))
    {
        xxSetClassDefaults(zzD.zzUTChunkDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UTChunk");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UTChunk1'))
    {
        xxSetClassDefaults(zzD.zzUTChunk1Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UTChunk1");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UTChunk2'))
    {
        xxSetClassDefaults(zzD.zzUTChunk2Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UTChunk2");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UTChunk3'))
    {
        xxSetClassDefaults(zzD.zzUTChunk3Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UTChunk3");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UTChunk4'))
    {
        xxSetClassDefaults(zzD.zzUTChunk4Defaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UTChunk4");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Ripper'))
    {
        xxSetClassDefaults(zzD.zzRipperDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Ripper");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_BioGel'))
    {
        xxSetClassDefaults(zzD.zzUT_BioGelDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_BioGel");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_Eightball'))
    {
        xxSetClassDefaults(zzD.zzUT_EightballDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_Eightball");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_FlakCannon'))
    {
        xxSetClassDefaults(zzD.zzUT_FlakCannonDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_FlakCannon");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_Grenade'))
    {
        xxSetClassDefaults(zzD.zzUT_GrenadeDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_Grenade");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'UT_SeekingRocket'))
    {
        xxSetClassDefaults(zzD.zzUT_SeekingRocketDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked UT_SeekingRocket");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'WarheadLauncher'))
    {
        xxSetClassDefaults(zzD.zzWarheadLauncherDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked WarheadLauncher");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'Translocator'))
    {
        xxSetClassDefaults(zzD.zzTranslocatorTargetDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked Translocator");  //Debug
    }
    else if(ClassIsChildOf(zzDynClass, class'TranslocatorTarget'))
    {
        xxSetClassDefaults(zzD.zzTranslocatorTargetDefaults, zzDynClass);
        // PlayerPawn(Owner).ClientMessage("Custom Class Checked TranslocatorTarget");  //Debug
    }
}

// =============================================================================
// xxSetClassDefaults ~ Reset sent classes back to defaults
// =============================================================================

simulated function xxSetClassDefaults(TBDefaults.Properties Str, class<Actor> Cls)
{
    local class<Weapon> WeaponClass;
    local class<AnimSpriteEffect> AnimSpriteEffectClass;
    local class<Projectile> ProjectileClass;

    WeaponClass = class<Weapon>(Cls);
    AnimSpriteEffectClass = class<AnimSpriteEffect>(Cls);
    
    Cls.default.Style = Str.Style;
    Cls.default.DrawScale = Str.DrawScale;
    Cls.default.DrawType = Str.DrawType;
    Cls.default.Texture = Str.Texture;
    Cls.default.Skin = Str.Skin;
    Cls.default.bUnlit = Str.bUnlit;
    Cls.default.bHidden = Str.bHidden;
    Cls.default.bMeshEnviroMap = Str.bMeshEnviroMap;
    Cls.default.LightHue = Str.LightHue;
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

    if (ProjectileClass != None)
    {
        ProjectileClass.default.bHidden = Str.bHidden;
    }

    if (WeaponClass != None)
    {
        WeaponClass.default.ShakeMag = Str.ShakeMag;
        WeaponClass.default.ShakeTime = Str.ShakeTime;
        WeaponClass.default.ShakeVert = Str.ShakeVert;
        WeaponClass.default.bDrawMuzzleFlash = Str.bDrawMuzzleFlash;
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
        AnimSpriteEffectClass.default.NumFrames = Str.NumFrames;
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
    local WaterRing zzWaterRing;
    
    // Reset Weapon Defaults
    xxSetClassDefaults(zzD.zzUT_EightballDefaults, class'UT_Eightball');
    xxSetClassDefaults(zzD.zzUT_FlakCannonDefaults, class'UT_FlakCannon');
    xxSetClassDefaults(zzD.zzUT_BioRifleDefaults, class'UT_BioRifle');
    xxSetClassDefaults(zzD.zzMinigun2Defaults, class'Minigun2');
    xxSetClassDefaults(zzD.zzPulseGunDefaults, class'PulseGun');
    xxSetClassDefaults(zzD.zzRipperDefaults, class'Ripper');
    xxSetClassDefaults(zzD.zzEnforcerDefaults, class'Enforcer');
    xxSetClassDefaults(zzD.zzImpactHammerDefaults, class'ImpactHammer');
    xxSetClassDefaults(zzD.zzShockRifleDefaults, class'ShockRifle');
    xxSetClassDefaults(zzD.zzSniperRifleDefaults, class'SniperRifle');
    xxSetClassDefaults(zzD.zzWarheadLauncherDefaults, class'WarheadLauncher');

    // Reset Rocket projectile defaults
    xxSetClassDefaults(zzD.zzRocketMk2Defaults, class'RocketMk2');
    xxSetClassDefaults(zzD.zzRocketTrailDefaults, class'RocketTrail');
    xxSetClassDefaults(zzD.zzUT_GrenadeDefaults, class'UT_Grenade');
    xxSetClassDefaults(zzD.zzUT_SeekingRocketDefaults, class'UT_SeekingRocket');

    // Reset Rocket smoke effect defaults
    xxSetClassDefaults(zzD.zzLightSmokeTrailDefaults, class'LightSmokeTrail');
    xxSetClassDefaults(zzD.zzUT_SpriteSmokePuffDefaults, class'UT_SpriteSmokePuff');
    xxSetClassDefaults(zzD.zzUTSmokeTrailDefaults, class'UTSmokeTrail');

    // Reset Rocket explosion defaults
    xxSetClassDefaults(zzD.zzUT_SpriteBallChildDefaults, class'UT_SpriteBallChild');
    xxSetClassDefaults(zzD.zzUT_SpriteBallExplosionDefaults, class'UT_SpriteBallExplosion');

    // Reset Flak projectile defaults
    xxSetClassDefaults(zzD.zzChunkTrailDefaults, class'ChunkTrail');
    xxSetClassDefaults(zzD.zzUTChunkDefaults, class'UTChunk');
    xxSetClassDefaults(zzD.zzUTChunk1Defaults, class'UTChunk1');
    xxSetClassDefaults(zzD.zzUTChunk2Defaults, class'UTChunk2');
    xxSetClassDefaults(zzD.zzUTChunk3Defaults, class'UTChunk3');
    xxSetClassDefaults(zzD.zzUTChunk4Defaults, class'UTChunk4');
    xxSetClassDefaults(zzD.zzUT_FlameExplosionDefaults, class'UT_FlameExplosion');
    xxSetClassDefaults(zzD.zzFlakSlugDefaults, class'FlakSlug');

    // Reset Bio Rifle projectile defaults
    xxSetClassDefaults(zzD.zzBioGlobDefaults, class'BioGlob');
    xxSetClassDefaults(zzD.zzBioSplashDefaults, class'BioSplash');
    xxSetClassDefaults(zzD.zzUT_BioGelDefaults, class'UT_BioGel');

    // Reset Ripper projectile defaults
    xxSetClassDefaults(zzD.zzRazor2Defaults, class'Razor2');
    xxSetClassDefaults(zzD.zzRazor2AltDefaults, class'Razor2Alt');

    // Reset Impact Hammer defaults
    xxSetClassDefaults(zzD.zzImpactMarkDefaults, class'ImpactMark');

    // Reset Shock Rifle defaults
    xxSetClassDefaults(zzD.zzShockExploDefaults, class'ShockExplo');
    xxSetClassDefaults(zzD.zzUT_RingExplosion5Defaults, class'UT_RingExplosion5');
    xxSetClassDefaults(zzD.zzUT_RingExplosionDefaults, class'UT_RingExplosion');
    xxSetClassDefaults(zzD.zzUT_RingExplosion4Defaults, class'UT_RingExplosion4');
    xxSetClassDefaults(zzD.zzUT_RingExplosion3Defaults, class'UT_RingExplosion3');
    xxSetClassDefaults(zzD.zzUT_ComboRingDefaults, class'UT_ComboRing');
    xxSetClassDefaults(zzD.zzShockBeamDefaults, class'ShockBeam');
    xxSetClassDefaults(zzD.zzShockRifleWaveDefaults, class'ShockRifleWave');
    xxSetClassDefaults(zzD.zzShockProjDefaults, class'ShockProj');
    xxSetClassDefaults(zzD.zzShockWaveDefaults, class'ShockWave');

    // Reset pulse gun defaults
    xxSetClassDefaults(zzD.zzPlasmaCapDefaults, class'PlasmaCap');
    xxSetClassDefaults(zzD.zzPlasmaHitDefaults, class'PlasmaHit');
    xxSetClassDefaults(zzD.zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxSetClassDefaults(zzD.zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxSetClassDefaults(zzD.zzStarterBoltDefaults, class'StarterBolt');
    xxSetClassDefaults(zzD.zzStarterBoltDefaults, class'StarterBolt');
    xxSetClassDefaults(zzD.zzpBoltDefaults, class'PBolt');

     // Reset translocator projectile defaults
    xxSetClassDefaults(zzD.zzTranslocatorDefaults, class'Translocator');
    xxSetClassDefaults(zzD.zzTranslocatorTargetDefaults, class'TranslocatorTarget');
    xxSetClassDefaults(zzD.zzTranslocOutEffectDefaults, class'TranslocOutEffect');

    // Reset Power-Up Item defaults
    xxSetClassDefaults(zzD.zzShieldBeltEffectDefaults, class'UT_ShieldBeltEffect');
    xxSetClassDefaults(zzD.zzShieldBeltDefaults, class'UT_ShieldBelt');
    xxSetClassDefaults(zzD.zzUDamageDefaults, class'UDamage');
    xxSetClassDefaults(zzD.zzInvisibilityDefaults, class'UT_Invisibility');
    xxSetClassDefaults(zzD.zzArmor2Defaults, class'Armor2');
    xxSetClassDefaults(zzD.zzThighPadsDefaults, class'ThighPads');
    xxSetClassDefaults(zzD.zzUT_JumpBootsDefaults, class'UT_JumpBoots');

     // Reset health pickup defaults
    xxSetClassDefaults(zzD.zzMedboxDefaults, class'MedBox');
    xxSetClassDefaults(zzD.zzHealthPackDefaults, class'HealthPack');
    xxSetClassDefaults(zzD.zzHealthVialDefaults, class'HealthVial');

    // Reset ammo pickup defaults
    xxSetClassDefaults(zzD.zzEclipDefaults, class'EClip');
    xxSetClassDefaults(zzD.zzMiniAmmoDefaults, class'MiniAmmo');
    xxSetClassDefaults(zzD.zzBioAmmoDefaults, class'BioAmmo');
    xxSetClassDefaults(zzD.zzShockCoreDefaults, class'ShockCore');
    xxSetClassDefaults(zzD.zzPAmmoDefaults, class'PAmmo');
    xxSetClassDefaults(zzD.zzBladeHopperDefaults, class'BladeHopper');
    xxSetClassDefaults(zzD.zzFlakAmmoDefaults, class'FlakAmmo');
    xxSetClassDefaults(zzD.zzRocketPackDefaults, class'RocketPack');
    xxSetClassDefaults(zzD.zzBulletBoxDefaults, class'BulletBox');

    // Reset random player model defaults
    xxSetClassDefaults(zzD.zzTMale1Defaults, class'TMale1');
    xxSetClassDefaults(zzD.zzTmale2Defaults, class'Tmale2');
    xxSetClassDefaults(zzD.zzTFemale1Defaults, class'TFemale1');
    xxSetClassDefaults(zzD.zzTFemale2Defaults, class'TFemale2');
    xxSetClassDefaults(zzD.zzTBossDefaults, class'TBoss');

    // Reset dead body defaults
    xxSetClassDefaults(zzD.zzTmale1CarcassDefault, class'Tmale1Carcass');
    xxSetClassDefaults(zzD.zzTmale2CarcassDefault, class'Tmale2Carcass');
    xxSetClassDefaults(zzD.zzTFemale1CarcassDefault, class'TFemale1Carcass');
    xxSetClassDefaults(zzD.zzTFemale2CarcassDefault, class'TFemale2Carcass');
    xxSetClassDefaults(zzD.zzTmalebodyDefault, class'Tmalebody');

    // Reset shellcase defaults
    xxSetClassDefaults(zzD.zzMiniShellCaseDefaults, class'MiniShellCase');
    xxSetClassDefaults(zzD.zzUT_ShellCaseDefaults, class'UT_ShellCase');
    
    // Reset wall hit defaults
    xxSetClassDefaults(zzD.zzUT_SparkDefaults, class'UT_Spark');
    xxSetClassDefaults(zzD.zzUT_SparksDefaults, class'UT_Sparks');
    xxSetClassDefaults(zzD.zzmTracerDefaults, class'mTracer');
    xxSetClassDefaults(zzD.zzUT_HeavyWallHitEffectDefaults, class'UT_HeavyWallHitEffect');
    xxSetClassDefaults(zzD.zzUT_LightWallHitEffectDefaults, class'UT_LightWallHitEffect');
    xxSetClassDefaults(zzD.zzUT_WallHitDefaults, class'UT_WallHit');
    
     // Reset misc classes defaults
    xxSetClassDefaults(zzD.zzWaterZoneDefaults, class'WaterZone');
    xxSetClassDefaults(zzD.zzWaterRingDefaults, class'WaterRing');
    xxSetClassDefaults(zzD.zzUTTeleportEffectDefaults, class'UTTeleportEffect');
    xxSetClassDefaults(zzD.zzUT_GreenBloodPuffDefaults, class'UT_GreenBloodPuff');
    xxSetClassDefaults(zzD.zzUTTeleEffectDefaults, class'UTTeleEffect');
    xxSetClassDefaults(zzD.zzEnhancedRespawnDefaults, class'EnhancedRespawn');

    // Reset item classes which have been spawned

    // Reset spawned weapon item to defaults
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

    foreach Level.AllActors(class'WaterRing', zzWaterRing)
        {
            if (zzWaterRing != none)
            {
                zzWaterRing.bHidden = zzD.zzWaterRingDefaults.bHidden;
            }
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
    zzMyVer="v08"
    NetPriority=10.0
}