class TBSettings extends Info;

// =============================================================================
// Variables
// =============================================================================
// Rendering tweaks
var bool zzRenderingWaterHidden, zzRenderingWetHidden, zzRenderingLightboxHidden;

// Flag defaults
var float zzFlagDrawScale;
var float zzFlagLightRadius;
var mesh zzFlagMesh;

// Belt defaults
var int zzShieldBeltEffectStyle;
var float zzShieldBeltEffectDrawScale;
var int zzShieldBeltEffectDrawType;
var texture zzShieldBeltEffectTexture;

var int zzShieldBeltDrawType;
var float zzShieldBeltDrawScale;
var texture zzShieldBeltTexture;

// UDamage defaults
var int zzUDamageDrawType;
var float zzUDamageDrawScale;
var texture zzUDamageTexture;

// Invisibility defaults
var int zzInvisibilityDrawType;
var float zzInvisibilityDrawScale;
var texture zzInvisibilityTexture;

// Player defaults
var float zzPPDefaultDrawScale;
var float zzPPDefaultFatness;

// =============================================================================
// Replication
// =============================================================================
replication
{
    // Rendering defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzRenderingWaterHidden, zzRenderingWetHidden, zzRenderingLightboxHidden;

    // Flag defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzFlagDrawScale, zzFlagLightRadius, zzFlagMesh;

    // Belt Effect defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzShieldBeltEffectStyle, zzShieldBeltEffectDrawScale, zzShieldBeltEffectDrawType, zzShieldBeltEffectTexture;

    // Belt defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzShieldBeltDrawType, zzShieldBeltDrawScale, zzShieldBeltTexture;

    // UDamage defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzUDamageDrawType, zzUDamageDrawScale, zzUDamageTexture;

    // Invisibility defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzInvisibilityDrawType, zzInvisibilityDrawScale, zzInvisibilityTexture;

    // Player defaults
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzPPDefaultDrawScale, zzPPDefaultFatness;
}

// =============================================================================
// xxSetDefaultVars ~ Replicate all default variables to the client
// =============================================================================
function xxSetDefaultVars()
{
    local CTFFlag zzFlag;

    // Rendering tweaks
    zzRenderingWaterHidden = class'fire.watertexture'.default.bInvisible;
    zzRenderingWetHidden = class'fire.wetTexture'.default.bInvisible;
    zzRenderingLightboxHidden = class'Lightbox'.default.bHidden;

    // Flag defaults
    foreach Level.AllActors(class'CTFFlag',zzFlag)
    {
        zzFlagDrawScale = zzFlag.DrawScale;
        zzFlagLightRadius = zzFlag.LightRadius;
        zzFlagMesh = zzFlag.Mesh;
        break;
    }

    // Belt defaults
    zzShieldBeltEffectStyle = class'UT_ShieldBeltEffect'.default.Style;
    zzShieldBeltEffectDrawScale= class'UT_ShieldBeltEffect'.default.DrawScale;
    zzShieldBeltEffectDrawType = class'UT_ShieldBeltEffect'.default.DrawType;
    zzShieldBeltEffectTexture = class'UT_ShieldBeltEffect'.default.Texture;
    
    zzShieldBeltDrawType = class'UT_ShieldBelt'.default.DrawType;
    zzShieldBeltDrawScale = class'UT_ShieldBelt'.default.DrawScale;
    zzShieldBeltTexture = class'UT_ShieldBelt'.default.Texture;

    // UDamage defaults
    zzUDamageDrawType = class'UDamage'.default.DrawType;
    zzUDamageDrawScale = class'UDamage'.default.DrawScale;
    zzUDamageTexture = class'UDamage'.default.Texture;

    // Invisibility defaults
    zzInvisibilityDrawType = class'UT_Invisibility'.default.DrawType;
    zzInvisibilityDrawScale = class'UT_Invisibility'.default.DrawScale;
    zzInvisibilityTexture = class'UT_Invisibility'.default.Texture;

    // Player defaults
    zzPPDefaultDrawScale = class'PlayerPawn'.default.DrawScale;
    zzPPDefaultFatness = class'PlayerPawn'.default.Fatness;
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    NetPriority=11.0
}