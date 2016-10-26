#include "core_pc_token"


object GetPCByName(string sPCName)
{
    object oTemp = GetFirstPC();
    object oPC = OBJECT_INVALID;

    while(GetIsObjectValid(oTemp))
    {
        if(GetName(oTemp) == sPCName || PCDGetFirstName(oTemp) == sPCName)
	{
	    oPC = oTemp;
	    break;
	}
	oTemp = GetNextPC();
    }

    if(oPC == OBJECT_INVALID)
    {
    	WriteTimestampedLogEntry("ERROR: Tried to find PC named " + sPCName +
		" but could not find one.");
    }

    return oPC;
}
