object GetPCByName(string sPCName)
{
    object oTemp = GetFirstPC();
    object oPC = OBJECT_INVALID;

    while(GetIsObjectValid(oTemp))
    {
    	// TODO: Allow to search by first name as well using PC Token
        if(GetName(oTemp) == sPCName)
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
