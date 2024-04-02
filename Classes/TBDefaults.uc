class TBDefaults extends Info;

// =============================================================================
// Variables
// =============================================================================

struct Properties
{
    var int	NumFrames;
    var texture	SpriteAnim[20];
    var ERenderStyle Style;
    var float DrawScale;
    var EDrawType DrawType;
    var texture Texture;
    var texture Skin;
    var bool bHidden;
    var bool bUnlit;
    var bool bMeshEnviroMap;
    var byte LightBrightness;
    var byte LightHue;
    var byte LightSaturation;
    var byte LightRadius;
    var bool bParticles;
    var bool bRandomFrame;
    var mesh Mesh;
    var byte Fatness;
    var float LifeSpan;
    var rotator RotationRate;
    var float ShakeMag;
    var float ShakeTime;
    var float ShakeVert;
    var bool bDrawMuzzleFlash;
    var texture	MFTexture;
    var texture	MuzzleFlare;
    var mesh MuzzleFlashMesh;
    var float MuzzleScale;
    var ERenderStyle MuzzleFlashStyle;
    var texture	MuzzleFlashTexture;
    var float ScaleGlow;
    var bool bHighDetail;
    var texture ExpType;
    var float Muzzleflashscale;
    var vector PrePivot;
};

// Power-up defaults
var Properties zzShieldBeltEffectDefaults, zzShieldBeltDefaults, zzUDamageDefaults, zzInvisibilityDefaults, zzArmor2Defaults, zzThighPadsDefaults, zzUT_JumpBootsDefaults;

// Health Pickup defaults
var Properties zzMedboxDefaults,zzHealthPackDefaults,zzHealthVialDefaults;

// Ammo Pickup defaults
var Properties zzEclipDefaults, zzMiniAmmoDefaults, zzBioAmmoDefaults, zzShockCoreDefaults, zzPAmmoDefaults, zzBladeHopperDefaults, zzFlakAmmoDefaults, zzRocketPackDefaults, zzBulletBoxDefaults;

// Weapon defaults
var Properties zzUT_EightballDefaults, zzUT_FlakCannonDefaults, zzShockRifleDefaults, zzSniperRifleDefaults, zzMinigun2Defaults, zzPulseGunDefaults, zzEnforcerDefaults, zzRipperDefaults, zzUT_BiorifleDefaults, zzImpactHammerDefaults, zzWarheadLauncherDefaults;

// Translocator Projectiles
var Properties zzTranslocatorDefaults, zzTranslocatorTargetDefaults, zzTranslocOutEffectDefaults;

// Bio Projectiles
var Properties zzBioGlobDefaults, zzBioSplashDefaults, zzUT_BioGelDefaults;

// Rocket projectiles
var Properties zzRocketMk2Defaults, zzRocketTrailDefaults, zzUT_GrenadeDefaults, zzUT_SeekingRocketDefaults;

// Rocket smoke
var Properties zzLightSmokeTrailDefaults, zzUT_SpriteSmokePuffDefaults, zzUTSmokeTrailDefaults;

// Rocket explosion
var Properties zzUT_SpriteBallChildDefaults, zzUT_SpriteBallExplosionDefaults;

// Flak projectiles
var Properties zzChunkTrailDefaults, zzUTChunkDefaults, zzUTChunk1Defaults, zzUTChunk2Defaults, zzUTChunk3Defaults, zzUTChunk4Defaults, zzUT_FlameExplosionDefaults, zzFlakSlugDefaults;

// Ripper projectiles
var Properties zzRazor2Defaults, zzRazor2AltDefaults;

// Impact Hammer effects

var Properties zzImpactMarkDefaults;

// Shock Rifle effects
var Properties zzShockExploDefaults, zzUT_RingExplosion5Defaults, zzUT_RingExplosionDefaults, zzUT_RingExplosion4Defaults,zzUT_RingExplosion3Defaults, zzUT_ComboRingDefaults, zzShockBeamDefaults, zzShockRifleWaveDefaults, zzShockProjDefaults, zzShockWaveDefaults;

// Pulse Gun effects
var Properties zzPlasmaCapDefaults, zzPlasmaHitDefaults, zzPlasmaSphereDefaults, zzStarterBoltDefaults, zzpBoltDefaults;

// Random tweaks

// Hidden dead bodies
var Properties zzTMale1Defaults, zzTmale2Defaults, zzTFemale1Defaults, zzTFemale2Defaults, zzTBossDefaults, zzTmale1CarcassDefault, zzTmale2CarcassDefault, zzTFemale1CarcassDefault, zzTFemale2CarcassDefault, zzTmalebodyDefault;

// Portal
var Properties zzBarrelDefaults;

// Shellcases
var Properties zzMiniShellCaseDefaults, zzUT_ShellCaseDefaults;

// Wall Hits
var Properties zzUT_SparkDefaults, zzUT_SparksDefaults;

var Properties zzWaterZoneDefaults, zzWaterRingDefaults;

var Properties zzmTracerDefaults, zzUT_HeavyWallHitEffectDefaults, zzUT_LightWallHitEffectDefaults, zzUT_WallHitDefaults,  zzUTTeleportEffectDefaults, zzUT_GreenBloodPuffDefaults, zzUTTeleEffectDefaults, zzEnhancedRespawnDefaults;


// =============================================================================
// Replication
// =============================================================================

replication
{
    
    // Power-up defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzShieldBeltEffectDefaults, zzShieldBeltDefaults, zzUDamageDefaults, zzInvisibilityDefaults, zzArmor2Defaults, zzThighPadsDefaults, zzUT_JumpBootsDefaults;

    // Health Pickup defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzMedboxDefaults,zzHealthPackDefaults,zzHealthVialDefaults;

    // Ammo Pickup defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzEclipDefaults, zzMiniAmmoDefaults, zzBioAmmoDefaults, zzShockCoreDefaults, zzPAmmoDefaults, zzBladeHopperDefaults, zzFlakAmmoDefaults, zzRocketPackDefaults, zzBulletBoxDefaults;

    // Weapon defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzUT_EightballDefaults, zzUT_FlakCannonDefaults, zzShockRifleDefaults, zzSniperRifleDefaults, zzMinigun2Defaults, zzPulseGunDefaults, zzEnforcerDefaults, zzRipperDefaults, zzUT_BiorifleDefaults, zzImpactHammerDefaults, zzWarheadLauncherDefaults,zzTranslocOutEffectDefaults, zzTranslocatorTargetDefaults;

    // Bio and flak projectiles
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzBioGlobDefaults, zzBioSplashDefaults, zzUT_BioGelDefaults, zzFlakSlugDefaults;

    // Rocket projectiles
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzRocketMk2Defaults, zzRocketTrailDefaults, zzUT_GrenadeDefaults, zzUT_SeekingRocketDefaults;

    // Rocket smoke
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzLightSmokeTrailDefaults, zzUT_SpriteSmokePuffDefaults, zzUTSmokeTrailDefaults;

    // Rocket explosion
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzUT_SpriteBallChildDefaults, zzUT_SpriteBallExplosionDefaults;

    // Flak projectiles
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzChunkTrailDefaults, zzUTChunkDefaults, zzUTChunk1Defaults, zzUTChunk2Defaults, zzUTChunk3Defaults, zzUTChunk4Defaults, zzUT_FlameExplosionDefaults;

    // Ripper projectiles
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzRazor2Defaults, zzRazor2AltDefaults;

    // Impact Hammer effects
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzImpactMarkDefaults;

    // Shock Rifle effects
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzShockExploDefaults, zzUT_RingExplosion5Defaults, zzUT_RingExplosionDefaults, zzUT_RingExplosion4Defaults, zzUT_RingExplosion3Defaults, zzUT_ComboRingDefaults, zzShockBeamDefaults, zzShockRifleWaveDefaults, zzShockProjDefaults, zzShockWaveDefaults;

    // Pulse Gun effects
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzPlasmaCapDefaults, zzPlasmaHitDefaults, zzPlasmaSphereDefaults, zzStarterBoltDefaults, zzpBoltDefaults;

    // Random tweaks

    // Hidden dead bodies
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzTMale1Defaults, zzTmale2Defaults, zzTFemale1Defaults, zzTFemale2Defaults, zzTBossDefaults, zzTmale1CarcassDefault, zzTmale2CarcassDefault, zzTFemale1CarcassDefault, zzTFemale2CarcassDefault, zzTmalebodyDefault;

    // Portal
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzBarrelDefaults;

    // Shellcases
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzUT_ShellCaseDefaults, zzMiniShellCaseDefaults;

    // Wall Hits
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzUT_SparkDefaults, zzUT_SparksDefaults, zzWaterZoneDefaults, zzWaterRingDefaults, zzmTracerDefaults, zzUT_HeavyWallHitEffectDefaults, zzUT_LightWallHitEffectDefaults, zzUT_WallHitDefaults, zzUTTeleportEffectDefaults, zzUT_GreenBloodPuffDefaults, zzUTTeleEffectDefaults, zzEnhancedRespawnDefaults;

}

function xxSaveClassDefaults(out Properties Str, class<Actor> Cls)
{
    local class<Weapon> WeaponClass;
    local class<AnimSpriteEffect> AnimSpriteEffectClass;

    // Common properties for all actors
    Str.Style = Cls.default.Style;
    Str.DrawScale = Cls.default.DrawScale;
    Str.DrawType = Cls.default.DrawType;
    Str.Texture = Cls.default.Texture;
    Str.Skin = Cls.default.Skin;
    Str.bHidden = Cls.default.bHidden;
    Str.bUnlit = Cls.default.bUnlit;
    Str.bMeshEnviroMap = Cls.default.bMeshEnviroMap;
    Str.LightHue = Cls.default.LightHue;
    Str.LightBrightness = Cls.default.LightBrightness;
    Str.LightSaturation = Cls.default.LightSaturation;
    Str.LightRadius = Cls.default.LightRadius;
    Str.Mesh = Cls.default.Mesh;
    Str.Fatness = Cls.default.Fatness;
    Str.LifeSpan = Cls.default.LifeSpan;
    Str.RotationRate = Cls.default.RotationRate;
    Str.bParticles = Cls.default.bParticles;
    Str.bRandomFrame = Cls.default.bRandomFrame;
    Str.ScaleGlow = Cls.default.ScaleGlow;
    Str.bHighDetail = Cls.default.bHighDetail;
    Str.PrePivot = Cls.default.PrePivot;

    // Check if the class is a subclass of Weapon
    if (ClassIsChildOf(Cls, class'Weapon'))
    {
        WeaponClass = class<Weapon>(Cls);
        if (WeaponClass != None)
        {
            // Save weapon-specific properties
            Str.ShakeMag = WeaponClass.default.ShakeMag;
            Str.ShakeTime = WeaponClass.default.ShakeTime;
            Str.ShakeVert = WeaponClass.default.ShakeVert;
            Str.bDrawMuzzleFlash = WeaponClass.default.bDrawMuzzleFlash;
            Str.MFTexture = WeaponClass.default.MFTexture;
            Str.MuzzleFlare = WeaponClass.default.MuzzleFlare;
            Str.MuzzleFlashMesh = WeaponClass.default.MuzzleFlashMesh;
            Str.MuzzleScale = WeaponClass.default.MuzzleScale;
            Str.MuzzleFlashStyle = WeaponClass.default.MuzzleFlashStyle;
            Str.MuzzleFlashTexture = WeaponClass.default.MuzzleFlashTexture;
            Str.Muzzleflashscale = WeaponClass.default.Muzzleflashscale;
        }
    }

    // Check if the class is a subclass of AnimSpriteEffect
    if (ClassIsChildOf(Cls, class'AnimSpriteEffect'))
    {
        AnimSpriteEffectClass = class<AnimSpriteEffect>(Cls);
        if (AnimSpriteEffectClass != None)
        {
            // Save projectile-specific properties
            Str.NumFrames = AnimSpriteEffectClass.default.Numframes;
            Str.SpriteAnim[0] = AnimSpriteEffectClass.default.SpriteAnim[0];
            Str.SpriteAnim[1] = AnimSpriteEffectClass.default.SpriteAnim[1];
            Str.SpriteAnim[2] = AnimSpriteEffectClass.default.SpriteAnim[2];
            Str.SpriteAnim[3] = AnimSpriteEffectClass.default.SpriteAnim[3];
            Str.SpriteAnim[4] = AnimSpriteEffectClass.default.SpriteAnim[4];
            Str.SpriteAnim[5] = AnimSpriteEffectClass.default.SpriteAnim[5];
            Str.SpriteAnim[6] = AnimSpriteEffectClass.default.SpriteAnim[6];
        }
    }
}

// =============================================================================
// xxSetDefaultVars ~ Replicate all default variables to the client
// =============================================================================
function xxSetDefaultVars()
{
    // Save weapon defaults   
    xxSaveClassDefaults(zzUT_EightballDefaults, class'UT_Eightball');
    xxSaveClassDefaults(zzUT_FlakCannonDefaults, class'UT_FlakCannon');
    xxSaveClassDefaults(zzUT_BioRifleDefaults, class'UT_BioRifle');
    xxSaveClassDefaults(zzMinigun2Defaults, class'Minigun2');
    xxSaveClassDefaults(zzPulseGunDefaults, class'PulseGun');
    xxSaveClassDefaults(zzRipperDefaults, class'Ripper');
    xxSaveClassDefaults(zzEnforcerDefaults, class'Enforcer');
    xxSaveClassDefaults(zzImpactHammerDefaults, class'ImpactHammer');
    xxSaveClassDefaults(zzShockRifleDefaults, class'ShockRifle');
    xxSaveClassDefaults(zzSniperRifleDefaults, class'SniperRifle');
    xxSaveClassDefaults(zzWarheadLauncherDefaults, class'WarheadLauncher');

    // Save pickup defaults   
    xxSaveClassDefaults(zzShieldBeltEffectDefaults, class'UT_ShieldBeltEffect');
    xxSaveClassDefaults(zzShieldBeltDefaults, class'UT_ShieldBelt');
    xxSaveClassDefaults(zzUDamageDefaults, class'UDamage');
    xxSaveClassDefaults(zzInvisibilityDefaults, class'UT_Invisibility');
    xxSaveClassDefaults(zzArmor2Defaults, class'Armor2');
    xxSaveClassDefaults(zzThighPadsDefaults, class'ThighPads');
    xxSaveClassDefaults(zzUT_JumpBootsDefaults, class'UT_JumpBoots');

    // Save health pickup defaults
    xxSaveClassDefaults(zzMedboxDefaults, class'MedBox');
    xxSaveClassDefaults(zzHealthPackDefaults, class'HealthPack');
    xxSaveClassDefaults(zzHealthVialDefaults, class'HealthVial');

    // Save ammo pickup defaults
    xxSaveClassDefaults(zzEclipDefaults, class'EClip');
    xxSaveClassDefaults(zzMiniAmmoDefaults, class'MiniAmmo');
    xxSaveClassDefaults(zzBioAmmoDefaults, class'BioAmmo');
    xxSaveClassDefaults(zzShockCoreDefaults, class'ShockCore');
    xxSaveClassDefaults(zzPAmmoDefaults, class'PAmmo');
    xxSaveClassDefaults(zzBladeHopperDefaults, class'BladeHopper');
    xxSaveClassDefaults(zzFlakAmmoDefaults, class'FlakAmmo');
    xxSaveClassDefaults(zzRocketPackDefaults, class'RocketPack');
    xxSaveClassDefaults(zzBulletBoxDefaults, class'BulletBox');

    // Save translocator projectile defaults
    xxSaveClassDefaults(zzTranslocatorDefaults, class'Translocator');
    xxSaveClassDefaults(zzTranslocatorTargetDefaults, class'TranslocatorTarget');
    xxSaveClassDefaults(zzTranslocOutEffectDefaults, class'TranslocOutEffect');

    // Save bio projectile defaults
    xxSaveClassDefaults(zzBioGlobDefaults, class'BioGlob');
    xxSaveClassDefaults(zzBioSplashDefaults, class'BioSplash');
    xxSaveClassDefaults(zzUT_BioGelDefaults, class'UT_BioGel');

    // Save rocket projectile defaults
    xxSaveClassDefaults(zzRocketMk2Defaults, class'RocketMk2');
    xxSaveClassDefaults(zzRocketTrailDefaults, class'RocketTrail');
    xxSaveClassDefaults(zzUT_GrenadeDefaults, class'UT_Grenade');
    xxSaveClassDefaults(zzUT_SeekingRocketDefaults, class'UT_SeekingRocket');

    // Save rocket smoke defaults
    xxSaveClassDefaults(zzLightSmokeTrailDefaults, class'LightSmokeTrail');
    xxSaveClassDefaults(zzUT_SpriteSmokePuffDefaults, class'UT_SpriteSmokePuff');
    xxSaveClassDefaults(zzUTSmokeTrailDefaults, class'UTSmokeTrail');

    // Save rocket explosion defaults
    xxSaveClassDefaults(zzUT_SpriteBallChildDefaults, class'UT_SpriteBallChild');
    xxSaveClassDefaults(zzUT_SpriteBallExplosionDefaults, class'UT_SpriteBallExplosion');

    // Save flak projectile defaults
    xxSaveClassDefaults(zzChunkTrailDefaults, class'ChunkTrail');
    xxSaveClassDefaults(zzUTChunkDefaults, class'UTChunk');
    xxSaveClassDefaults(zzUTChunk1Defaults, class'UTChunk1');
    xxSaveClassDefaults(zzUTChunk2Defaults, class'UTChunk2');
    xxSaveClassDefaults(zzUTChunk3Defaults, class'UTChunk3');
    xxSaveClassDefaults(zzUTChunk4Defaults, class'UTChunk4');
    xxSaveClassDefaults(zzUT_FlameExplosionDefaults, class'UT_FlameExplosion');
    xxSaveClassDefaults(zzFlakSlugDefaults, class'FlakSlug');

    // Save ripper projectile defaults
    xxSaveClassDefaults(zzRazor2Defaults, class'Razor2');
    xxSaveClassDefaults(zzRazor2AltDefaults, class'Razor2Alt');

    // Save impact hammer effects
    xxSaveClassDefaults(zzImpactMarkDefaults, class'ImpactMark');

    // Save shock rifle effects
    xxSaveClassDefaults(zzShockExploDefaults, class'ShockExplo');
    xxSaveClassDefaults(zzUT_RingExplosion5Defaults, class'UT_RingExplosion5');
    xxSaveClassDefaults(zzUT_RingExplosionDefaults, class'UT_RingExplosion');
    xxSaveClassDefaults(zzUT_RingExplosion4Defaults, class'UT_RingExplosion4');
    xxSaveClassDefaults(zzUT_RingExplosion3Defaults, class'UT_RingExplosion3');
    xxSaveClassDefaults(zzUT_ComboRingDefaults, class'UT_ComboRing');
    xxSaveClassDefaults(zzShockBeamDefaults, class'ShockBeam');
    xxSaveClassDefaults(zzShockRifleWaveDefaults, class'ShockRifleWave');
    xxSaveClassDefaults(zzShockProjDefaults, class'ShockProj');
    xxSaveClassDefaults(zzShockWaveDefaults, class'ShockWave');

    // Save pulse gun effects
    xxSaveClassDefaults(zzPlasmaCapDefaults, class'PlasmaCap');
    xxSaveClassDefaults(zzPlasmaHitDefaults, class'PlasmaHit');
    xxSaveClassDefaults(zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxSaveClassDefaults(zzPlasmaSphereDefaults, class'PlasmaSphere');
    xxSaveClassDefaults(zzStarterBoltDefaults, class'StarterBolt');
    xxSaveClassDefaults(zzStarterBoltDefaults, class'StarterBolt');
    xxSaveClassDefaults(zzpBoltDefaults, class'PBolt');

    // Save random tweaks
    xxSaveClassDefaults(zzTMale1Defaults, class'TMale1');
    xxSaveClassDefaults(zzTmale2Defaults, class'Tmale2');
    xxSaveClassDefaults(zzTFemale1Defaults, class'TFemale1');
    xxSaveClassDefaults(zzTFemale2Defaults, class'TFemale2');
    xxSaveClassDefaults(zzTBossDefaults, class'TBoss');
    xxSaveClassDefaults(zzTmale1CarcassDefault, class'Tmale1Carcass');
    xxSaveClassDefaults(zzTmale2CarcassDefault, class'Tmale2Carcass');
    xxSaveClassDefaults(zzTFemale1CarcassDefault, class'TFemale1Carcass');
    xxSaveClassDefaults(zzTFemale2CarcassDefault, class'TFemale2Carcass');
    xxSaveClassDefaults(zzTmalebodyDefault, class'Tmalebody');

    // Save shellcase defaults
    xxSaveClassDefaults(zzMiniShellCaseDefaults, class'MiniShellCase');
    xxSaveClassDefaults(zzUT_ShellCaseDefaults, class'UT_ShellCase');

    // Save misc class defaults
    xxSaveClassDefaults(zzUT_SparkDefaults, class'UT_Spark');
    xxSaveClassDefaults(zzUT_SparksDefaults, class'UT_Sparks');
    xxSaveClassDefaults(zzWaterZoneDefaults, class'WaterZone');
    xxSaveClassDefaults(zzWaterRingDefaults, class'WaterRing');
    xxSaveClassDefaults(zzmTracerDefaults, class'mTracer');
    xxSaveClassDefaults(zzUT_HeavyWallHitEffectDefaults, class'UT_HeavyWallHitEffect');
    xxSaveClassDefaults(zzUT_LightWallHitEffectDefaults, class'UT_LightWallHitEffect');
    xxSaveClassDefaults(zzUT_WallHitDefaults, class'UT_WallHit');
    xxSaveClassDefaults(zzUTTeleportEffectDefaults, class'UTTeleportEffect');
    xxSaveClassDefaults(zzUT_GreenBloodPuffDefaults, class'UT_GreenBloodPuff');
    xxSaveClassDefaults(zzUTTeleEffectDefaults, class'UTTeleEffect');
    xxSaveClassDefaults(zzEnhancedRespawnDefaults, class'EnhancedRespawn');

}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    NetPriority=11.0
}
