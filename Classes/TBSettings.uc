class TBSettings extends Info;

// =============================================================================
// Variables
// =============================================================================
// Rendering tweaks
var bool zzRenderingWaterHidden, zzRenderingWetHidden, zzRenderingLightboxHidden;

// Flag tweaks
var float zzFlagDrawScale;
var float zzFlagLightRadius;
var mesh zzFlagMesh;
var int zzShieldBeltEffectStyle;

// =============================================================================
// Replication
// =============================================================================
replication
{
    // Rendering tweaks
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzRenderingWaterHidden, zzRenderingWetHidden, zzRenderingLightboxHidden;

    // Flag tweaks
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzFlagDrawScale, zzFlagLightRadius, zzFlagMesh;

    // Belt tweaks
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzShieldBeltEffectStyle;
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

    // Flag tweaks
    foreach Level.AllActors(class'CTFFlag',zzFlag)
    {
        zzFlagDrawScale = zzFlag.DrawScale;
        zzFlagLightRadius = zzFlag.LightRadius;
        zzFlagMesh = zzFlag.Mesh;
        break;
    }

    // Belt tweaks
    zzShieldBeltEffectStyle = class'UT_ShieldBeltEffect'.default.Style;
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    NetPriority=11.0
}
