class TBMutator extends Mutator;

// =============================================================================
// Variables
// =============================================================================
var TBActor zzActor;

// =============================================================================
// Mutate ~
// =============================================================================
simulated function Mutate(string zzMessage, PlayerPawn zzPP)
{
    super.Mutate(zzMessage,zzPP);

    if (zzMessage ~= "tb info")
    {
        zzPP.ClientMessage("TweakBlocker Info:");
        zzPP.ClientMessage("=============");
        zzPP.ClientMessage("* Version:"@zzActor.zzMyVer);
        zzPP.ClientMessage("* Checking Rendering:"@zzActor.bCheckRendering);
        zzPP.ClientMessage("* Checking RMode:"@zzActor.bCheckRMode);
        zzPP.ClientMessage("* Checking Skins:"@zzActor.bCheckPlayerSkins);
        zzPP.ClientMessage("* Checking LODBias:"@zzActor.bCheckLODBias);
        zzPP.ClientMessage("* Checking Weapons:"@zzActor.bCheckWeaponModels);
        zzPP.ClientMessage("* Checking Powerups:"@zzActor.bCheckPowerUps);
        zzPP.ClientMessage("* Checking Flags:"@zzActor.bCheckFlags);
    }
}
