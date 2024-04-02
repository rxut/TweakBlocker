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
var config bool bDisableCustomClassTweaks;    // Check Custom Actor and Weapon classes to reset to default (Works only if bDisableTweaks is enabled)
var config bool bCheckClientPackages;   // Check for client packages that don't match the server and kick the player
var config bool bCheckRendering;        // General Rendering tweaks (Hidden/Transparent textures), wallhacks, lightradius
var config bool bCheckLODBias;          // Check lodbias
var config float bMaxAllowedLODBias;    // Max allowed lodbias
var config bool bCheckRMode;            // Classic RMODE hacks
var config bool bCheckPlayerSkins;      // Brightskins by replacing player textures
var config bool bCheckWeaponModels;     // Check all weapon models
var config bool bCheckBeltHacks;        // Check UT_ShieldBeltEffect tweaks
var config bool bCheckPowerUps;         // Check UDamage, UT_Invisibility and Shield Belt tweaks
var config bool bCheckFlags;            // Flag tweaks
var config bool bExternalLogs;          // Create External logs when someone gets kicked?
var config string LogPath;              // Folder to log to
var config string LogPrefix;            // Tag
var config string CustomClassNames[65];   // Names of the Custom Classes to reset to default

// =============================================================================
// Replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY)
         bCheckRendering, bStealthMode, bDisableTweaks, bCheckClientPackages, bCheckRMode, bCheckPlayerSkins, bCheckFlags, bCheckLODBias, bCheckBeltHacks, bMaxAllowedLODBias, bCheckPowerUps, bCheckWeaponModels, bDisableCustomClassTweaks, CustomClassNames;
}

// =============================================================================
// PostBeginPlay ~
// =============================================================================
function PostBeginPlay()
{
    local TBMutator zzMut;

    Log("### TweakBlocker v0.8 - (c) 2009 AnthraX, 2024 rX");

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
// xxGetLODBias ~ Retrieve the current LODBias value for a player
// =============================================================================

simulated function string xxGetLODBias(PlayerPawn zzPP)
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
    zzMyVer="v0.8"
    CheckInterval=30.0
    CheckTimeOut=15.0
    bStealthMode=false
    bDisableTweaks=true
    bCheckClientPackages=true
    bCheckRendering=true
    bCheckRMode=true
    bCheckPlayerSkins=true
    bCheckLODBias=true
    bCheckFlags=true
    bCheckWeaponModels=true
    bCheckPowerUps=true
    bCheckBeltHacks=true
    bDisableCustomClassTweaks=true
    bExternalLogs=true
    bMaxAllowedLODBias=4.0000
    LogPath="../Logs/"
    LogPrefix="[TB]"
    CustomClassNames(0)="ST_BioGlob"
    CustomClassNames(1)="ST_BioSplash"
    CustomClassNames(2)="ST_FlakSlug"
    CustomClassNames(3)="ST_minigun2"
    CustomClassNames(4)="ST_UT_Grenade"
    CustomClassNames(5)="ST_GuidedWarshell"
    CustomClassNames(6)="ST_ut_biorifle"
    CustomClassNames(7)="ST_ImpactHammer"
    CustomClassNames(8)="ST_PBolt"
    CustomClassNames(9)="ST_PlasmaSphere"
    CustomClassNames(10)="ST_PulseGun"
    CustomClassNames(11)="ST_Razor2"
    CustomClassNames(12)="ST_Razor2Alt"
    CustomClassNames(13)="ST_enforcer"
    CustomClassNames(14)="ST_RocketMk2"
    CustomClassNames(15)="ST_ShockProj"
    CustomClassNames(16)="ST_ShockRifle"
    CustomClassNames(17)="ST_ShockWave"
    CustomClassNames(18)="ST_SniperRifle"
    CustomClassNames(19)="ST_StarterBolt"
    CustomClassNames(20)="ST_UT_SeekingRocket"
    CustomClassNames(21)="ST_WarheadLauncher"
    CustomClassNames(22)="ST_UTChunk"
    CustomClassNames(23)="ST_UTChunk1"
    CustomClassNames(24)="ST_UTChunk2"
    CustomClassNames(25)="ST_UTChunk3"
    CustomClassNames(26)="ST_UTChunk4"
    CustomClassNames(27)="ST_ripper"
    CustomClassNames(28)="ST_UT_BioGel"
    CustomClassNames(29)="ST_UT_Eightball"
    CustomClassNames(30)="ST_UT_FlakCannon"
    CustomClassNames(31)="ST_Translocator"
    CustomClassNames(32)="ST_TranslocatorTarget"
    CustomClassNames(33)=""
    CustomClassNames(34)=""
    CustomClassNames(35)=""
    CustomClassNames(36)=""
    CustomClassNames(37)=""
    CustomClassNames(38)=""
    CustomClassNames(39)=""
    CustomClassNames(40)=""
    CustomClassNames(41)=""
    CustomClassNames(42)=""
    CustomClassNames(43)=""
    CustomClassNames(44)=""
    CustomClassNames(45)=""
    CustomClassNames(46)=""
    CustomClassNames(47)=""
    CustomClassNames(48)=""
    CustomClassNames(49)=""
    CustomClassNames(50)=""
    CustomClassNames(51)=""
    CustomClassNames(52)=""
    CustomClassNames(53)=""
    CustomClassNames(54)=""
    CustomClassNames(55)=""
    CustomClassNames(56)=""
    CustomClassNames(57)=""
    CustomClassNames(58)=""
    CustomClassNames(59)=""
    CustomClassNames(60)=""
    CustomClassNames(61)=""
    CustomClassNames(62)=""
    CustomClassNames(63)=""
    CustomClassNames(64)=""
}