class TBActor extends Actor
    config(System);

// =============================================================================
// Variables
// =============================================================================
var int zzCurrentID;
var TBSettings zzSettings;
var TBDefaults zzDefaults;
var string zzMyVer;
var string lastLODBias;                 // Last known LODBias value
// =============================================================================
// Config Variables
// =============================================================================
var config float CheckInterval;         // Number of seconds between each check
var config float CheckTimeout;          // Time allowed to finish the check
var config bool bStealthMode;           // Stealth mode, no messages to players or kicks. Just log each tweak
var config bool bDisableTweaks;         // Disable tweaks and restore default properties for actors
var config bool bCheckRendering;        // General Rendering tweaks (Hidden/Transparent textures), wallhacks, lightradius
var config bool bCheckRMode;            // Classic RMODE hacks
var config bool bCheckPlayerSkins;      // Brightskins by replacing player textures
var config bool bCheckFlags;            // Flag tweaks
var config bool bExternalLogs;          // Create External logs when someone gets kicked?
var config string LogPath;              // Folder to log to
var config string LogPrefix;            // Tag
var config bool bCheckLODBias;          // Check lodbias
var config float bMaxAllowedLODBias;    // Max allowed lodbias
var config bool bCheckWeaponModels;     // Check all weapon models
var config bool bCheckBeltHacks;        // Check UT_ShieldBeltEffect tweaks
var config bool bCheckPowerUps;         // Check UDamage, UT_Invisibility and Shield Belt tweaks
var config bool bCheckIGPlusClasses;    // Check for IGPlus classes (If bDisableTweaks is enabled)

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
         bCheckRendering, bStealthMode, bDisableTweaks, bCheckRMode, bCheckPlayerSkins, bCheckFlags, bCheckLODBias, bCheckBeltHacks, bMaxAllowedLODBias, bCheckPowerUps, bCheckWeaponModels, bCheckIGPlusClasses;
}

// =============================================================================
// PostBeginPlay ~
// =============================================================================
function PostBeginPlay()
{
    local TBMutator zzMut;

    Log("### TweakBlocker v0.6 - (c) 2009 AnthraX, 2024 rX");

    zzMut = Level.Spawn(class'TBMutator');
    zzMut.zzActor = self;
    Level.Game.BaseMutator.AddMutator(zzMut);
    SaveConfig();
}

// =============================================================================
// Tick ~ Track playerjoins
// =============================================================================
function Tick(float DeltaTime)
{
    local Pawn zzP;

    if (Level.Game.CurrentID > zzCurrentID)
    {
        for (zzP = Level.PawnList; zzP != none; zzP = zzP.NextPawn)
        {
            if (zzP.PlayerReplicationInfo == None)
              continue;

            if ((zzP.PlayerReplicationInfo.PlayerID == zzCurrentID) && zzP.IsA('PlayerPawn') && !zzP.IsA('MessagingSpectator') && !zzP.IsA('Spectator'))
            {
                xxInitNewPlayer(PlayerPawn(zzP));
            }
        }
        ++zzCurrentID;
    }
}

// =============================================================================
// xxInitNewPlayer ~ Set up TB for the new player
// =============================================================================
function xxInitNewPlayer(PlayerPawn zzPP)
{
    local TBReplicationInfo zzRI;
    local TBSettings zzS;
    local TBDefaults zzD;

    zzRI = Level.Spawn(class'TBReplicationInfo',zzPP);
    zzS = Level.Spawn(class'TBSettings',zzPP);
    zzD = Level.Spawn(class'TBDefaults',zzPP);
    //zzPP.ClientMessage("This server is running TweakBlocker");
    zzRI.xxInitRI(self,zzS,zzD);
}

// =============================================================================
// GetLODBias ~ Retrieve the current LODBias value for a player
// =============================================================================

simulated function string GetLODBias(PlayerPawn zzPP)
{
    local string lodBias;

    lodBias = zzPP.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice lodbias");

    if (lodBias == "")
    {
        lodBias = lastLODBias;
    }
    else
    {
        lastLODBias = lodBias;          // Update the last known LOD bias value
    }
    
    return lodBias;                     // Return the LODBias value
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    bHidden=true
    bAlwaysRelevant=true
    NetPriority=3.0
    zzMyVer="v0.6"
    CheckInterval=30.0
    CheckTimeOut=15.0
    bStealthMode=false
    bDisableTweaks=true
    bCheckRendering=true
    bCheckRMode=true
    bCheckPlayerSkins=true
    bCheckLODBias=true
    bCheckFlags=true
    bCheckWeaponModels=true
    bCheckPowerUps=true
    bCheckBeltHacks=true
    bCheckIGPlusClasses=true
    bExternalLogs=true
    bMaxAllowedLODBias=4.0000
    LogPath="../Logs/"
    LogPrefix="[TB]"
}