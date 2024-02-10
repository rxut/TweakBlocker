class TBPlayerDisplayProperties extends Info;

// =============================================================================
// Variables
// =============================================================================
var TBPlayerDisplayProperties zzNextProperties; // Next Properties
var PlayerPawn zzPropertiesOwner;               // Whose displayproperties are these?
var texture zzOwnerTexture;                     // Owner's texture
var mesh zzOwnerMesh;                           // Owner's mesh
var bool zzOwnerEnviroMap;                      // Owner's EnviroMap
var bool zzOwnerUnlit;                          // Owner's Unlit
var bool zzOwnerHasBelt;                        // Owner has a shieldbelt?
var bool zzOwnerHasInvi;                        // Owner has a shieldbelt?
var float zzOwnerLightRadius;                   //
var float zzOwnerDrawScale;                     // Owner's DrawScale

// =============================================================================
// replication
// =============================================================================
replication
{
    reliable if (ROLE == ROLE_AUTHORITY && bNetOwner)
        zzPropertiesOwner, zzOwnerTexture, zzOwnerMesh, zzOwnerEnviroMap, zzOwnerUnlit, zzOwnerHasBelt, zzOwnerHasInvi, zzOwnerLightRadius, zzNextProperties, zzOwnerDrawScale;
}

// =============================================================================
// Destroy ~ Linked list destroy
// =============================================================================
event Destroyed()
{
    if (zzNextProperties != none)
        zzNextProperties.Destroy();
}

// =============================================================================
// xxAddProperties ~ Add a new object at the end of the list and set properties
// =============================================================================
function xxAddProperties(PlayerPawn zzPP, texture zzTex, mesh zzMesh, bool zzEnviroMap, bool zzUnlit, bool zzHasBelt, bool zzHasInvi, float zzLightRadius, float zzDrawScale)
{
    if (zzNextProperties != none)
    {
        zzNextProperties.xxAddProperties(zzPP,zzTex,zzMesh,zzEnviroMap,zzUnlit,zzHasBelt,zzHasInvi,zzLightRadius, zzDrawScale);
    }
    else
    {
        zzNextProperties = Level.Spawn(class'TBPlayerDisplayProperties', Owner);
        zzNextProperties.zzPropertiesOwner = zzPP;
        zzNextProperties.zzOwnerTexture = zzTex;
        zzNextProperties.zzOwnerMesh = zzMesh;
        zzNextProperties.zzOwnerEnviroMap = zzEnviroMap;
        zzNextProperties.zzOwnerUnlit = zzUnlit;
        zzNextProperties.zzOwnerHasBelt = zzHasBelt;
        zzNextProperties.zzOwnerHasInvi = zzOwnerHasInvi;
        zzNextProperties.zzOwnerLightRadius = zzLightRadius;
        zzNextProperties.zzOwnerDrawScale = zzDrawScale;
    }
}

// =============================================================================
// xxGetPlayerProperties ~ Get the properties for this player
// =============================================================================
simulated function TBPlayerDisplayProperties xxGetPlayerProperties(PlayerPawn zzPP)
{
    if (zzPP == zzPropertiesOwner)
        return self;
    else if (zzNextProperties != none)
        return zzNextProperties.xxGetPlayerProperties(zzPP);
    else
        return none;
}

// =============================================================================
// defaultproperties
// =============================================================================
defaultproperties
{
    NetPriority=12.0
}
