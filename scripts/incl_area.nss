#include "core_pc_token"

/* THESE TWO FUNCTIONS MUST BE CALLED FOR ANY PVE AREA ENTER/EXIT SCRIPTS. */

void PvEAreaEnter(object oPC, object oArea)
{
    PCDSetAreaEnterXP(oPC, GetXP(oPC));
    PCDSetDeathLevel(oPC, GetLocalInt(oArea, "iDeathLevel"));
}

void PvEAreaExit(object oPC)
{
    PCDSetAreaEnterXP(oPC, 0);
    PCDSetDeathLevel(oPC, DEATH_LEVEL_UNCONSCIOUSNESS);
}
