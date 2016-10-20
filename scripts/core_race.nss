void RaceLoginCheck(object oPC);
void SetupNextECLLevel(object oPC);

int     GetLA(string sRace);
string  GetDBVarName(object oPC);
int     GetECLXP(int iLA);

string GetDBVarName(object oPC)
{
    return GetSubString(GetPCPlayerName(oPC), 0, 8) + GetSubString(GetName(oPC), 0, 8);
}

void RaceLoginCheck(object oPC)
{
    string sPre = GetDBVarName(oPC);
    // Don't do anything unless this is the first time logging in.
    if(GetCampaignInt("RACE", sPre+"enabled") == TRUE)
        return;

    string sRace = GetStringLowerCase(GetSubRace(oPC));
    int iLA = GetLA(sRace);

    object oSkin = CreateItemOnObject(sRace, oPC);
    AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));

    SetCampaignInt("RACE", sPre+"enabled", TRUE);
    // Don't need any more setup for a no-ECL subrace
    if(iLA < 1)
        return;

    // Give them a subrace token
    object oItem = GetItemPossessedBy(oPC, "ecl_token");
    if(oItem == OBJECT_INVALID)
        oItem = CreateItemOnObject("ecl_token", oPC);
}

void SetupNextECLLevel(object oPC)
{
    int iBaseLevel = GetHitDice(oPC)+1;
    string sPre = GetDBVarName(oPC);
    int iECL = iBaseLevel + GetCampaignInt("RACE", sPre+"iLA");

    SetCampaignInt("RACE", sPre+"iECL", iECL);
    SetCampaignInt("RACE", sPre+"iRealXP", GetSubraceXP(iBaseLevel));
    SetCampaignInt("RACE", sPre+"iXPNeeded", GetSubraceXP(iECL));
}

int GetLA(string sRace)
{
    // TODO: replace these subraces with whatever races we are allowing
    if(sRace == "lizardfolk")
        return 1;
    if(sRace == "drow" || sRace == "fey'ri")
        return 2;
    if(sRace == "svirfneblin")
        return 3;
    return 0;
}

int GetECLXP(int iEffectiveLevel)
{
    int iXPNeeded = 0;
    switch(iEffectiveLevel)
    {
        case 2:
            iXPNeeded = 3000;
            break;
        case 3:
            iXPNeeded = 6000;
            break;
        case 4:
            iXPNeeded = 10000;
            break;
        case 5:
            iXPNeeded = 15000;
            break;
        case 6:
            iXPNeeded = 21000;
            break;
        case 7:
            iXPNeeded = 28000;
            break;
        case 8:
            iXPNeeded = 36000;
            break;
        case 9:
            iXPNeeded = 45000;
            break;
        case 10:
            iXPNeeded = 55000;
            break;
        default:
            break;
    }
    return iXPNeeded;
}
