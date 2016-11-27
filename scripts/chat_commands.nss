#include "x0_i0_stringlib"
#include "nw_i0_plot"

#include "nwnx_chat"

#include "core_utilities"
#include "core_pc_token"
#include "incl_colors"
#include "incl_dicebag"

// --------------- Helper Methods ----------------

/* Handles the message displayed to the user based on the dice roll difference

*/
string SendSocialMessage(object oUser, object oTarget, int iDifference string sSkill)
{

    //  TODO: Messages to the user??
    string sUserMessage = "";
    string sTargetMessage = "";

    //  TODO: DB-Driven Messages?
    //  TODO: different messages for different skills

    //  Numbers should be 10, 4, -4, -10 as it's more statistically even
    
    //Intimidate has a separate set of messages
    if(sSkill == "itimidate")
    {
        if(iDifference <= -10) 
        {
            // Huge failure
            sTargetMessage = GetName(oTarget) + " is all bark, no bite.";
        }
        else if(iDifference >= -9 && iDifference <= -5)
        {
            // failure
            sTargetMessage = GetName(oTarget) + " seems like they might not be able to back up that claim.";
        }
        else if(iDifference >= -4 && iDifference <= 4)
        {
            // No effect
            sTargetMessage = GetName(oTarget) + " has gotten your attention. But you're not convinced yet.";
        }
        else if(iDifference >= 5 && iDifference <= 9)
        {
            // success
            sTargetMessage = GetName(oTarget) + "'s point is very pointly made. Pointily.";
        }
        else
        {
            // Great success
            sTargetMessage = "Agreeing with " + GetName(oTarget) + " seems like a great way to continue your time on Faerun.";
        }
    }
    // Persuade and Bluff have the same messages except for failures
    // A good lie doesn't even sound like one
    else
    {
        if(iDifference <= -10) 
        {
            // Huge failure
            if (sSkill == "bluff")
            {
                sTargetMessage = GetName(oTarget) + " is lying. You're sure of it.";
            }
            else
            {
                sTargetMessage = GetName(oTarget) + " can't expect that you'll agree to that.";
            }
        }
        else if(iDifference >= -9 && iDifference <= -5)
        {
            // failure
            if (sSkill == "bluff")
            {
                sTargetMessage = GetName(oTarget) + " is acting rather suspiciously.";
            }
            else
            {
                sTargetMessage = GetName(oTarget) + " isn't doing much to convince you.";
            }
        }
        else if(iDifference >= -4 && iDifference <= 4)
        {
            // No effect
            sTargetMessage = GetName(oTarget) + " makes some sense. But you're not quite sure.";
        }
        else if(iDifference >= 5 && iDifference <= 9)
        {
            // success
            sTargetMessage = GetName(oTarget) + " has quite a compelling point.";
        }
        else
        {
            // Great success
            sTargetMessage = GetName(oTarget) + " has you convinced. You're sold.";
        }
    }

    // Actually send the message
    SendMessageToPC(oTarget, sTargetMessage);
    
    // Log to DMs. Actually sent after the returned function since this just compiles the target list
    string sResult = (iDifference >= 0) ? "succeeded" : "failed";
    string sLog = " | " + sResult + " against " + + GetName(oTarget) + " by " + IntToString(abs(iDifference));
    
    return sLog;
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

    int iIdx = FindSubString("bluff persuade intimidate", sSkill);

    if(iIdx < 0)
    {
        SendMessageToPC(oUser, "Social command failed - skill must be bluff, persuade, or intimidate");
        return;
    }

    //Form the DM logging base message
    string sMessageForDM = GetName(oUser) + "attempted a " + sSkill + " check";

    // Why are we relying on a DB value for this rather than  property file? 
    // I don't think we'll ever change this without recompiling the code :PP -Aez
    int iSkillConst = DBGetSkillConst(sSkill);
    int iCheck = d10() + GetSkillRank(iSkillConst, oUser);

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

            int iOpposed = GetOpposedSocialSkillCheck(oTarget);
            int iDifference = iCheck - iOpposed; // positive = user won
            sMessageForDM += SendSocialMessage(oUser, oTarget, sSkill);
        
            AssignCommand(oUser, SpeakString(sMessageForDM, TALKVOLUME_SILENT_SHOUT));
            
    	    oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, lUserLoc);
    	}
    }
    else if(sTarget != "")
    {
    	oTarget = GetPCByName(sTarget);

    	if(!GetObjectSeen(oUser, oTarget) ||
    		GetDistanceBetween(oUser, oTarget) > fRange)
    	{
    	    SendMessageToPC(oUser, "Social command failed - " + sTarget + " is not nearby.");
    	    return;
    	}
        if(oTarget == OBJECT_INVALID)
        {
            // TODO: Better string system?
            SendMessageToPC(oUser, "Social command failed - could not find a PC " +
                    "named " + sTarget + ".");
            return;
        }

        int iOpposed = GetOpposedSocialSkillCheck(oTarget);
        int iDifference = iCheck - iOpposed; // positive = user won

        //Returns the message that should be logged to the DM
    	sMessageForDM += SendSocialMessage(oUser, oTarget, sSkill);
        AssignCommand(oUser, SpeakString(sMessageForDM, TALKVOLUME_SILENT_SHOUT));
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
        //Maybe Death level should be reverted to 0 if no DM is online at the time? in onEnter or something?
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
