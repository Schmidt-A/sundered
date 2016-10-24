#include "x0_i0_stringlib"
#include "core_utilities"


// ------------------ Helper Functions ---------------------

/* Returns an opposed social skill check. This will be whichever is highest:
  - The PC's Bluff check;
  - The PC's Intimidate check;
  - The PC's Persuade check; OR
  - The PC's Will Save + their Wisdom modifier
  Plus their d20 roll.
*/
int GetOpposedSocialSkillCheck(object oPC)
{
    int iRoll  = Random(20) + 1;
    // TODO: Scaling cap on this sense motive modifier
    int iMod   = GetWillSavingThrow(oPC) + GetAbilityModifier(ABILITY_WISDOM, oPC);
    int iSkill = GetSkillRank(SKILL_BLUFF, oPC);                                

    if(iSkill > iMod)                                                           
        iMod = iSkill;        
                                                  
    iSkill = GetSkillRank(SKILL_INTIMIDATE, oPC);                               
    if(iSkill > iMod)                                                           
        iMod = iSkill;                                                          

    iSkill = GetSkillRank(SKILL_PERSUADE, oPC);                                 
    if(iSkill > iMod)                                                           
        iMod = iSkill;                                                          
                                                                                
    return iRoll + iMod;  
}

// TODO: DB this up
int SkillRankFromString(string sSkillName)
{
    if(sSkillName == "bluff")
	return SKILL_BLUFF;
    if(sSkillName == "intimidate")
        return SKILL_INTIMIDATE;
    if(sSkillName == "persuade")
	return SKILL_PERSUADE;
}

void DoSocialCheck(object oUser, object oTarget, string sSkill)
{
    if(oTarget == OBJECT_INVALID)
    {
	// TODO: Better string system?
	SendMessageToPC(oUser, "Social command failed - could not find a PC " +
		"named " + sTarget + ".");
	return;
    }

    int iCheck = (Random(20) + 1) + GetSkillRank(SkillRankFromString(sSkill), oUser);
    int iOpposed = GetOpposedSocialSkillCheck(oTarget, sSkill);
    int iDifference = iCheck - iOpposed; // positive = user won

    if(iDifference <= -10) // dramatic failure
    {
	// TODO: (probably DB-driven) messages
	// TODO: different messages for different skills
	// Notify both parties about success/failure
	// Huge failure
    }
    else if(iDifference >= -9 && iDifference <= -5)
    {
        // Partial failure
    }
    else if(iDifference >= -4 && iDifference =< 4)
    {
    	// No effect
    }
    else if(iDifference >= 5 && iDifference <= 9)
    {
	// Slight success
    }
    else
    {
	// Great success
    }

    // Log to DMs
    string sResult = (iDifference >= 0) ? "succeeded" : "failed";
    string sLog = GetName(oUser) + " " + sResult + " in a " + sSkill + " check " +
    	"against " + GetName(oTarget) + " by " + IntToString(abs(iDifference)) + ".";
    AssignCommand(oUser, SpeakString(sLog, TALKVOLUME_SILENT_SHOUT));
}


// ---------------- Chat Command Handlers ------------------

void RollCommand(object oUser, string sText)
{

}

/* Expects a string of the format
   [social roll] [target]
   
   Where [social skill] can be: bluff, intimidate, or persuade
   and [target] can be either a PC name or all 

   Examples: bluff Miriam, intimidate all
*/
void SocialCommand(object oUser, string sText)
{
    string sSkill  = GetStringLowerCase(GetTokenByPosition(sText, " ", 0));
    string sTarget = GetStringLowerCase(GetTokenByPosition(sText, " ", 1));
    object oTarget;

    if(sTarget == "all")
    {
    	location lUserLoc = GetLocation(oUser);
	oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 50.0, lUserLoc);

	while(GetIsObjectValid(oTarget))
	{
	    if(!GetIsPC(oTarget))
	        continue;
	    
	    DoSocialCheck(oUser, oTarget, sSkill);
	    oTarget = GetNextObjectInShape(SHAPE_SPHERE, 50.0, lUserLoc);
	}
    }
    else
    {
    	// TODO: handle first name
	oTarget = GetPCByName(sTarget);
	DoSocialCheck(oUser, oTarget, sSkill);
    }
}

void HelpCommand(object oUser, string sText)
{

}

void EmoteCommand(object oUser, string sText)
{

}
