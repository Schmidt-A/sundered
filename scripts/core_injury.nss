#include "nwnx_funcs"

#include "core_pc_token"


#include "core_pc_token"

// --------- Initialization -----------
void ApplyInjuryHP(object oPC);
int GetInjuryHPCap(object oPC);


// --------- Definitions ------------

/*
	This applies the reduction in HP to a full health character
*/
void ApplyInjuryHP(object oPC)
{
    int iInjuryHP = GetInjuryHPCap(oPC);
    
    if(GetCurrentHitPoints(oPC) > iInjuryHP)
    {
<<<<<<< HEAD
    	SetCurrentHitPoints(oPC, iInjuryHP);
=======
    	return;// TODO: SetHP Via NWNX
>>>>>>> Fixed some compiler errors
    }
}

/*
	This returns the maximum amount of HP a character can have based on 
	the injuries that they've accrued.

	Needs to be called by the EffectHeal in the nwscript.nss
*/
int GetInjuryHPCap(object oPC)
{
	int iInjuries = PCDGetInjuries(oPC);
	int iMaxHP = GetMaxHitPoints(oPC);
	int iInjuryHP = iMaxHP;

    if(iInjuries > 0)
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