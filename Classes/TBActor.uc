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
var string zzClientGameVersion;        // Client's Game Version

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
var config bool bCheckCustomClasses;    // Check for IGPlus classes (If bDisableTweaks is enabled)
var config string ResetCustomClassNames[65];   // Names of the Custom Classes to reset

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
         bCheckRendering, bStealthMode, bDisableTweaks, bCheckRMode, bCheckPlayerSkins, bCheckFlags, bCheckLODBias, bCheckBeltHacks, bMaxAllowedLODBias, bCheckPowerUps, bCheckWeaponModels, bCheckCustomClasses, zzClientGameVersion,ResetCustomClassNames;
}

// =============================================================================
// PostBeginPlay ~
// =============================================================================
function PostBeginPlay()
{
    local TBMutator zzMut;

    Log("### TweakBlocker v0.7 - (c) 2009 AnthraX, 2024 rX");

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
    zzMyVer="v0.7"
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
    bCheckCustomClasses=true
    bExternalLogs=true
    bMaxAllowedLODBias=4.0000
    LogPath="../Logs/"
    LogPrefix="[TB]"
    ResetCustomClassNames(0)="ST_BioGlob"
    ResetCustomClassNames(1)="ST_BioSplash"
    ResetCustomClassNames(2)="ST_FlakSlug"
    ResetCustomClassNames(3)="ST_minigun2"
    ResetCustomClassNames(4)="ST_UT_Grenade"
    ResetCustomClassNames(5)="ST_GuidedWarshell"
    ResetCustomClassNames(6)="ST_ut_biorifle"
    ResetCustomClassNames(7)="ST_ImpactHammer"
    ResetCustomClassNames(8)="ST_PBolt"
    ResetCustomClassNames(9)="ST_PlasmaSphere"
    ResetCustomClassNames(10)="ST_PulseGun"
    ResetCustomClassNames(11)="ST_Razor2"
    ResetCustomClassNames(12)="ST_Razor2Alt"
    ResetCustomClassNames(13)="ST_enforcer"
    ResetCustomClassNames(14)="ST_RocketMk2"
    ResetCustomClassNames(15)="ST_ShockProj"
    ResetCustomClassNames(16)="ST_ShockRifle"
    ResetCustomClassNames(17)="ST_ShockWave"
    ResetCustomClassNames(18)="ST_SniperRifle"
    ResetCustomClassNames(19)="ST_StarterBolt"
    ResetCustomClassNames(20)="ST_UT_SeekingRocket"
    ResetCustomClassNames(21)="ST_WarheadLauncher"
    ResetCustomClassNames(22)="ST_UTChunk"
    ResetCustomClassNames(23)="ST_UTChunk1"
    ResetCustomClassNames(24)="ST_UTChunk2"
    ResetCustomClassNames(25)="ST_UTChunk3"
    ResetCustomClassNames(26)="ST_UTChunk4"
    ResetCustomClassNames(27)="ST_ripper"
    ResetCustomClassNames(28)="ST_UT_BioGel"
    ResetCustomClassNames(29)="ST_UT_Eightball"
    ResetCustomClassNames(30)="ST_UT_FlakCannon"
    ResetCustomClassNames(31)="ST_Translocator"
    ResetCustomClassNames(32)="ST_TranslocatorTarget"
    ResetCustomClassNames(33)=""
    ResetCustomClassNames(34)=""
    ResetCustomClassNames(35)=""
    ResetCustomClassNames(36)=""
    ResetCustomClassNames(37)=""
    ResetCustomClassNames(38)=""
    ResetCustomClassNames(39)=""
    ResetCustomClassNames(40)=""
    ResetCustomClassNames(41)=""
    ResetCustomClassNames(42)=""
    ResetCustomClassNames(43)=""
    ResetCustomClassNames(44)=""
    ResetCustomClassNames(45)=""
    ResetCustomClassNames(46)=""
    ResetCustomClassNames(47)=""
    ResetCustomClassNames(48)=""
    ResetCustomClassNames(49)=""
    ResetCustomClassNames(50)=""
    ResetCustomClassNames(51)=""
    ResetCustomClassNames(52)=""
    ResetCustomClassNames(53)=""
    ResetCustomClassNames(54)=""
    ResetCustomClassNames(55)=""
    ResetCustomClassNames(56)=""
    ResetCustomClassNames(57)=""
    ResetCustomClassNames(58)=""
    ResetCustomClassNames(59)=""
    ResetCustomClassNames(60)=""
    ResetCustomClassNames(61)=""
    ResetCustomClassNames(62)=""
    ResetCustomClassNames(63)=""
    ResetCustomClassNames(64)=""
}