#include "core_race"

// Custom XP-granting function to account for ECLs.
void GiveXPToPC(object oPC, int iAmount, string sSource="");

void GiveXPToPC(object oPC, int iAmount, string sSource="")
{
    // Normal case - not an ECL character.
    if(GetItemPossessedBy(oPC, "ecl_token") == OBJECT_INVALID)
    {
        SetXP(oPC, GetXP(oPC) + iAmount);
        return;
    }
    string sPre = GetDBVarName(oPC);

    int iXPNeeded = GetCampaignInt("RACE", sPre+"iXPNeeded");
    int iCumulativeXP = GetCampaignInt("RACE", sPre+"iCumulativeXP");

    iCumulativeXP += iAmount;
    SetCampaignInt("RACE", sPre+"iCumulativeXP", iCumulativeXP);
    SendMessageToPC(oPC, "You gained " + IntToString(iAmount) + " XP.");

    // Woo they have enough to level
    if(iCumulativeXP >= iXPNeeded)
    {
        SendMessageToPC(oPC, "Congratulations! You have earned the ECL XP necessary to level up!");
        int iRealXP = GetCampaignInt("RACE", sPre+"iRealXP");
        iRealXP += (iCumulativeXP - iXPNeeded);
        SetXP(oPC, iRealXP);
        SetupNextECLLevel(oPC);
    }
}
