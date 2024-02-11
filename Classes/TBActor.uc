class TBActor extends Actor
    config(System);

// =============================================================================
// Variables
// =============================================================================
var int zzCurrentID;
var TBSettings zzSettings;
var string zzMyVer;

// =============================================================================
// Config Variables
// =============================================================================
var config float CheckInterval;     // Number of seconds between each check
var config float CheckTimeout;      // Time allowed to finish the check
var config bool bCheckRendering;    // General Rendering tweaks (Hidden/Transparent textures), wallhacks, lightradius
var config bool bCheckRMode;        // Classic RMODE hacks
var config bool bCheckPlayerSkins;  // Brightskins by replacing player textures
var config bool bCheckFlags;        // Flag tweaks
var config bool bExternalLogs;      // Create External logs when someone gets kicked?
var config string LogPath;          // Folder to log to
var config string LogPrefix;        // Tag
var config bool bCheckLODBias; // Check lodbias
var config float bMaxAllowedLODBias;   // Max allowed lodbias
var config bool bCheckWeaponModels; // Check all weapon models
var config bool bCheckBeltHacks; // Check UT_ShieldBeltEffect tweaks
var config bool bCheckPowerUps; // Check UDamage, UT_Invisibility and Shield Belt tweaks
var string lastLODBias;

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
        bCheckRendering, bCheckRMode, bCheckPlayerSkins, bCheckFlags, bCheckLODBias, bCheckBeltHacks, bMaxAllowedLODBias, bCheckPowerUps, bCheckWeaponModels;
}

// =============================================================================
// PostBeginPlay ~
// =============================================================================
function PostBeginPlay()
{
    local TBMutator zzMut;

    Log("### TweakBlocker v0.3 - (c) 2009 AnthraX, 2023 Banko, 2024 rX");

    zzMut = Level.Spawn(class'TBMutator');
    zzMut.zzActor = self;
    Level.Game.BaseMutator.AddMutator(zzMut);
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

    zzRI = Level.Spawn(class'TBReplicationInfo',zzPP);
    zzS = Level.Spawn(class'TBSettings',zzPP);
    zzPP.ClientMessage("This server is running TweakBlocker by AnthraX");
    zzRI.xxInitRI(self,zzS);
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
        // Update the last known LOD bias value
        lastLODBias = lodBias;
    }

    // Return the LODBias value
    return lodBias;
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    bHidden=true
    bAlwaysRelevant=true
    NetPriority=3.0
    zzMyVer="v0.3"
    CheckInterval=30.0
    CheckTimeOut=15.0
    bCheckRendering=true
    bCheckRMode=true
    bCheckPlayerSkins=true
    bCheckLODBias=true
    bCheckFlags=true
    bCheckWeaponModels=true
    bCheckPowerUps=true
    bCheckBeltHacks=true
    bExternalLogs=true
    bMaxAllowedLODBias=4.0000
    LogPath="../Logs/"
    LogPrefix="[TB]"
}