#include "x0_i0_stringlib"
#include "nw_i0_plot"

#include "nwnx_chat"

#include "core_utilities"
#include "core_pc_token"
#include "incl_colors"
#include "incl_dicebag"


void DoSocialCheck(object oUser, object oTarget, string sSkill)
{

    int iSkillConst = DBGetSkillConst(sSkill);
    if(iSkillConst < 0)
    {
    	SendMessageToPC(oUser, "Social command failed - did not understand " +
		"skill " + sSkill);
	return;
    }

    int iCheck = d10() + GetSkillRank(iSkillConst, oUser);
    int iOpposed = GetOpposedSocialSkillCheck(oTarget);
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
    else if(iDifference >= -4 && iDifference <= 4)
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
    int iConst, iMod;
    string sNormalized = GetStringLowerCase(sText);
    int iIdx = -1;

    // Ability score roll
    iIdx = FindSubString("strength dexterity constitution intelligence wisdom charisma", sNormalized);
    if(iIdx >= -1)
    {
        iConst = DBGetAbilityConst(sNormalized);
        if(iConst < 0)
        {
            SendMessageToPC(oUser, "Roll command failed - could not find roll " +
                    "option " + sText);
            return;
        }
        iMod = GetAbilityModifier(iConst, oUser);
    }

    // Save roll          0         10     17
    iIdx = FindSubString("fortitude reflex will", sNormalized);
    switch(iIdx)
    {
        case 0:  iMod = GetFortitudeSavingThrow(oUser); break;
        case 10: iMod = GetReflexSavingThrow(oUser)   ; break;
        case 17: iMod = GetWillSavingThrow(oUser)     ; break;
    }

    // Must be a skill roll. TODO: Probably a cleaner way of doing this
    if(iIdx < 0)
    {
        iConst = DBGetSkillConst(sNormalized);
        if(iConst < 0)
        {
            SendMessageToPC(oUser, "Roll command failed - could not find roll " +
                    "option " + sText);
            return;
        }
        iMod = GetSkillRank(iConst, oUser);
    }

    int iRoll = d20();
    string sResult = "[" + sText + " check: 1d20(" + IntToString(iRoll) +
        ") + modifier(" + IntToString(iMod) + ") = " +
        IntToString(iRoll+iMod) + "]";

    // TODO: allow private/public?
    AssignCommand(oUser, SpeakString(ColorTokenBlue() + sResult, TALKVOLUME_TALK));
    AssignCommand(oUser, SpeakString(sResult, TALKVOLUME_SILENT_SHOUT));
}

/* Expects sText to be of the format
   [social roll] (target)

   Where [social skill] must be: bluff, intimidate, or persuade
   and (target) can be either a PC name or all

   intimidate and persuade can be used selectively on targets, but bluff
   must be used on all who can hear.

   Examples: bluff, intimidate Miriam
*/
void SocialCommand(object oUser, string sText, int iChannel)
{
    string sSkill  = "";
    string sTarget = "";
    object oTarget;

    // TODO: see how this range looks in-game
    float fRange = 50.0;
    if(iChannel == CHAT_CHANNEL_WHISPER)
        fRange = 10.0;

    struct sStringTokenizer sParams = GetStringTokenizer(sText, " ");

    while(HasMoreTokens(sParams))
    {
	if(sSkill == "")
	    sSkill = GetStringLowerCase(GetNextToken(sParams));
	else
	{
	    sTarget = GetStringLowerCase(GetNextToken(sParams));
	    break;
	}
	sParams = AdvanceToNextToken(sParams);
    }

    if(sSkill == "bluff" || sTarget == "")
    {

    	location lUserLoc = GetLocation(oUser);
	oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, lUserLoc);

	while(GetIsObjectValid(oTarget))
	{
	    if(!GetIsPlayerCharacter(oTarget))
	        continue;

	    if(!GetObjectSeen(oUser, oTarget))
	        continue;

	    DoSocialCheck(oUser, oTarget, sSkill);
	    oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, lUserLoc);
	}
    }
    else if(sSkill != "bluff" && sTarget != "")
    {
	oTarget = GetPCByName(sTarget);

	if(!GetObjectSeen(oUser, oTarget) ||
		GetDistanceBetween(oUser, oTarget) > fRange)
	{
	    SendMessageToPC(oUser, "Social command failed - not close enough " +
	    	"to " + sTarget + ".");
	    return;
	}
        if(oTarget == OBJECT_INVALID)
        {
            // TODO: Better string system?
            SendMessageToPC(oUser, "Social command failed - could not find a PC " +
                    "named " + sTarget + ".");
            return;
        }

	DoSocialCheck(oUser, oTarget, sSkill);
    }
    else
    {
	SendMessageToPC(oUser, "Social command failed - failed to understand " +
		"command '" +sText + "'.");
	return;
    }
}

void DeathLevelCommand(object oUser, string sText)
{
    int iIdx = FindSubString("0 1 2 3", sText);

    if(iIdx < 0)
    {
        SendMessageToPC(oUser, "Death Level command failed - level must be 0, 1, 2 or 3");
        return;
    }

    int iLevel   = StringToInt(sText);
    object oArea = GetArea(oUser);
    object oObj  = GetFirstObjectInArea(oArea);

    string sPCList;
    string sLevel;
    switch(iLevel)
    {
        case 0: sLevel = "Cleared";                  break;
        case 1: sLevel = "Standard Unconsciousness"; break;
        case 2: sLevel = "Permanent Injury";         break;
        case 3: sLevel = "Permanent Death";          break;
    }

    while(oObj != OBJECT_INVALID)
    {
        if(!GetIsPlayerCharacter(oObj))
            continue;

        // Set Death level on player appropriately - overrides area settings
        PCDSetDeathLevelDM(oObj, iLevel);
        sPCList = sPCList + GetName(oObj) + ", ";

        oObj = GetNextObjectInArea(oArea);
    }

    sPCList = GetStringLeft(sPCList, GetStringLength(sPCList)-2);

    SendMessageToPC(oUser, "DM Death level for PCs in area set to " + sText + ": " +
        sLevel);
    if(iLevel > 0)
    {
        SendMessageToPC(oUser, "WARNING: You MUST set the death level to 0 " +
            "for all affected PCs once your event is complete. Affected PCs: " +
            sPCList);
    }
    else
        SendMessageToPC(oUser, "DM Death level cleared.");
}

void HelpCommand(object oUser, string sText)
{

}

void InvalidCommand(object oUser, string sText)
{

}

void EmoteCommand(object oUser, string sText)
{

}
