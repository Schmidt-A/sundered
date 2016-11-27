
// --------- Initialization -----------
void ApplyInjuryHP(object oPC);
int GetInjuryHPCap(object oPC);


// --------- Definitions ------------

/*
	This applies the reduction in HP to a full health character
*/
void ApplyInjuryHP(oPC)
{
    int iInjuryHP = GetInjuryHPCap(oPC);
    
    if(GetCurrentHitPoints(oPC) > iMaxHP)
    {
    	// TODO: SetHP Via NWNX
    }
}

/*
	This returns the maximum amount of HP a character can have based on 
	the injuries that they've accrued.
*/
int GetInjuryHPCap(oPC)
{
	int iInjuries = PCDGetInjuries(oPC);
	int iMaxHP = GetMaxHitPoints(oPC);
	int iInjuryHP = iMaxHP;

    if(PCDGetInjuries > 0)
    {
    	// TODO: Handle rounding
    	// Each injury lowers the max hp by 5%
   		iInjuryHP = iMaxHP - FloatToInt(
   					IntToFloat(iMaxHP) - (0.05 * IntToFloat(iInjuries))
   				);

   		//lower bound of 1 HP - you can't perm die by injuries
   		if(iInjuryHP <= 0)
   			iInjuryHP = 1;
    }

    return iInjuryHP;
}