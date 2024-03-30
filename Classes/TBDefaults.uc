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
    var int Curr;
    var mesh Mesh;
    var byte Fatness;
    var float LifeSpan;
    var rotator RotationRate;
    var bool bRandomize;
    var float ShakeMag;
    var float ShakeTime;
    var float ShakeVert;
    var bool bDrawMuzzleFlash;
    var float FlareOffset;
    var float FlashC;
    var float FlashLength;
    var float FlashO;
    var int	FlashS;
    var float FlashY;
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
    var vector ViewFog;
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
var Properties zzTranslocatorTargetDefaults, zzTranslocOutEffectDefaults;

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

// Wall Hits
var Properties zzUT_SparkDefaults, zzUT_SparksDefaults;

var Properties zzWaterZoneDefaults, zzWaterRingDefaults;

var Properties zzmTracerDefaults, zzUT_HeavyWallHitEffectDefaults, zzUT_LightWallHitEffectDefaults, zzUT_WallHitDefaults, zzMiniShellCaseDefaults, zzUTTeleportEffectDefaults, zzUT_GreenBloodPuffDefaults, zzUTTeleEffectDefaults, zzEnhancedRespawnDefaults;


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

    // Wall Hits
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
    zzUT_SparkDefaults, zzUT_SparksDefaults, zzWaterZoneDefaults, zzWaterRingDefaults, zzmTracerDefaults, zzUT_HeavyWallHitEffectDefaults, zzUT_LightWallHitEffectDefaults, zzUT_WallHitDefaults, zzMiniShellCaseDefaults, zzUTTeleportEffectDefaults, zzUT_GreenBloodPuffDefaults, zzUTTeleEffectDefaults, zzEnhancedRespawnDefaults;

}

function StoreClass(out Properties Str, class<Actor> Cls)
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
            // Store weapon-specific properties
            Str.ShakeMag = WeaponClass.default.ShakeMag;
            Str.ShakeTime = WeaponClass.default.ShakeTime;
            Str.ShakeVert = WeaponClass.default.ShakeVert;
            Str.bDrawMuzzleFlash = WeaponClass.default.bDrawMuzzleFlash;
            Str.FlareOffset = WeaponClass.default.FlareOffset;
            Str.FlashC = WeaponClass.default.FlashC;
            Str.FlashLength = WeaponClass.default.FlashLength;
            Str.FlashO = WeaponClass.default.FlashO;
            Str.FlashS = WeaponClass.default.FlashS;
            Str.FlashY = WeaponClass.default.FlashY;
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
            // Store projectile-specific properties
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
    // Store weapon defaults   
    StoreClass(zzUT_EightballDefaults, class'UT_Eightball');
    StoreClass(zzUT_FlakCannonDefaults, class'UT_FlakCannon');
    StoreClass(zzUT_BioRifleDefaults, class'UT_BioRifle');
    StoreClass(zzMinigun2Defaults, class'Minigun2');
    StoreClass(zzPulseGunDefaults, class'PulseGun');
    StoreClass(zzRipperDefaults, class'Ripper');
    StoreClass(zzEnforcerDefaults, class'Enforcer');
    StoreClass(zzImpactHammerDefaults, class'ImpactHammer');
    StoreClass(zzShockRifleDefaults, class'ShockRifle');
    StoreClass(zzSniperRifleDefaults, class'SniperRifle');
    StoreClass(zzWarheadLauncherDefaults, class'WarheadLauncher');

    // Store pickup defaults   
    StoreClass(zzShieldBeltEffectDefaults, class'UT_ShieldBeltEffect');
    StoreClass(zzShieldBeltDefaults, class'UT_ShieldBelt');
    StoreClass(zzUDamageDefaults, class'UDamage');
    StoreClass(zzInvisibilityDefaults, class'UT_Invisibility');
    StoreClass(zzArmor2Defaults, class'Armor2');
    StoreClass(zzThighPadsDefaults, class'ThighPads');
    StoreClass(zzUT_JumpBootsDefaults, class'UT_JumpBoots');

    // Store health pickup defaults
    StoreClass(zzMedboxDefaults, class'MedBox');
    StoreClass(zzHealthPackDefaults, class'HealthPack');
    StoreClass(zzHealthVialDefaults, class'HealthVial');

    // Store ammo pickup defaults
    StoreClass(zzEclipDefaults, class'EClip');
    StoreClass(zzMiniAmmoDefaults, class'MiniAmmo');
    StoreClass(zzBioAmmoDefaults, class'BioAmmo');
    StoreClass(zzShockCoreDefaults, class'ShockCore');
    StoreClass(zzPAmmoDefaults, class'PAmmo');
    StoreClass(zzBladeHopperDefaults, class'BladeHopper');
    StoreClass(zzFlakAmmoDefaults, class'FlakAmmo');
    StoreClass(zzRocketPackDefaults, class'RocketPack');
    StoreClass(zzBulletBoxDefaults, class'BulletBox');

    // Store translocator projectile defaults
    StoreClass(zzTranslocatorTargetDefaults, class'TranslocatorTarget');
    StoreClass(zzTranslocOutEffectDefaults, class'TranslocOutEffect');

    // Store bio projectile defaults
    StoreClass(zzBioGlobDefaults, class'BioGlob');
    StoreClass(zzBioSplashDefaults, class'BioSplash');
    StoreClass(zzUT_BioGelDefaults, class'UT_BioGel');

    // Store rocket projectile defaults
    StoreClass(zzRocketMk2Defaults, class'RocketMk2');
    StoreClass(zzRocketTrailDefaults, class'RocketTrail');
    StoreClass(zzUT_GrenadeDefaults, class'UT_Grenade');
    StoreClass(zzUT_SeekingRocketDefaults, class'UT_SeekingRocket');

    // Store rocket smoke defaults
    StoreClass(zzLightSmokeTrailDefaults, class'LightSmokeTrail');
    StoreClass(zzUT_SpriteSmokePuffDefaults, class'UT_SpriteSmokePuff');
    StoreClass(zzUTSmokeTrailDefaults, class'UTSmokeTrail');

    // Store rocket explosion defaults
    StoreClass(zzUT_SpriteBallChildDefaults, class'UT_SpriteBallChild');

    StoreClass(zzUT_SpriteBallExplosionDefaults, class'UT_SpriteBallExplosion');

    // Store flak projectile defaults
    StoreClass(zzChunkTrailDefaults, class'ChunkTrail');
    StoreClass(zzUTChunkDefaults, class'UTChunk');
    StoreClass(zzUTChunk1Defaults, class'UTChunk1');
    StoreClass(zzUTChunk2Defaults, class'UTChunk2');
    StoreClass(zzUTChunk3Defaults, class'UTChunk3');
    StoreClass(zzUTChunk4Defaults, class'UTChunk4');
    StoreClass(zzUT_FlameExplosionDefaults, class'UT_FlameExplosion');
    StoreClass(zzFlakSlugDefaults, class'FlakSlug');

    // Store ripper projectile defaults
    StoreClass(zzRazor2Defaults, class'Razor2');
    StoreClass(zzRazor2AltDefaults, class'Razor2Alt');

    // Store impact hammer effects
    StoreClass(zzImpactMarkDefaults, class'ImpactMark');

    // Store shock rifle effects
    StoreClass(zzShockExploDefaults, class'ShockExplo');
    StoreClass(zzUT_RingExplosion5Defaults, class'UT_RingExplosion5');
    StoreClass(zzUT_RingExplosionDefaults, class'UT_RingExplosion');
    StoreClass(zzUT_RingExplosion4Defaults, class'UT_RingExplosion4');
    StoreClass(zzUT_RingExplosion3Defaults, class'UT_RingExplosion3');
    StoreClass(zzUT_ComboRingDefaults, class'UT_ComboRing');
    StoreClass(zzShockBeamDefaults, class'ShockBeam');
    StoreClass(zzShockRifleWaveDefaults, class'ShockRifleWave');
    StoreClass(zzShockProjDefaults, class'ShockProj');
    StoreClass(zzShockWaveDefaults, class'ShockWave');

    // Store pulse gun effects
    StoreClass(zzPlasmaCapDefaults, class'PlasmaCap');
    StoreClass(zzPlasmaHitDefaults, class'PlasmaHit');
    StoreClass(zzPlasmaSphereDefaults, class'PlasmaSphere');
    StoreClass(zzPlasmaSphereDefaults, class'PlasmaSphere');
    StoreClass(zzStarterBoltDefaults, class'StarterBolt');
    StoreClass(zzStarterBoltDefaults, class'StarterBolt');
    StoreClass(zzpBoltDefaults, class'PBolt');


    // Store random tweaks
    StoreClass(zzTMale1Defaults, class'TMale1');
    StoreClass(zzTmale2Defaults, class'Tmale2');
    StoreClass(zzTFemale1Defaults, class'TFemale1');
    StoreClass(zzTFemale2Defaults, class'TFemale2');
    StoreClass(zzTBossDefaults, class'TBoss');
    StoreClass(zzTmale1CarcassDefault, class'Tmale1Carcass');
    StoreClass(zzTmale2CarcassDefault, class'Tmale2Carcass');
    StoreClass(zzTFemale1CarcassDefault, class'TFemale1Carcass');
    StoreClass(zzTFemale2CarcassDefault, class'TFemale2Carcass');
    StoreClass(zzTmalebodyDefault, class'Tmalebody');

    // Store wall hit defaults
    StoreClass(zzUT_SparkDefaults, class'UT_Spark');
    StoreClass(zzUT_SparksDefaults, class'UT_Sparks');
    StoreClass(zzWaterZoneDefaults, class'WaterZone');
    StoreClass(zzWaterRingDefaults, class'WaterRing');
    StoreClass(zzmTracerDefaults, class'mTracer');
    StoreClass(zzUT_HeavyWallHitEffectDefaults, class'UT_HeavyWallHitEffect');
    StoreClass(zzUT_LightWallHitEffectDefaults, class'UT_LightWallHitEffect');
    StoreClass(zzUT_WallHitDefaults, class'UT_WallHit');
    StoreClass(zzMiniShellCaseDefaults, class'MiniShellCase');
    StoreClass(zzUTTeleportEffectDefaults, class'UTTeleportEffect');
    StoreClass(zzUT_GreenBloodPuffDefaults, class'UT_GreenBloodPuff');
    StoreClass(zzUTTeleEffectDefaults, class'UTTeleEffect');
    StoreClass(zzEnhancedRespawnDefaults, class'EnhancedRespawn');

}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    NetPriority=11.0
}
