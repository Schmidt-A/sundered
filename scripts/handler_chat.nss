//::///////////////////////////////////////////////
//:: _handler_chat
//:: Created by: rmilne
//:: Adapted from chat_script.nss.sample by Dumbo
//:: https://github.com/NWNX/nwnx2-linux/blob/master/plugins/chat/nwn/chat_script.nss.sample
//:://////////////////////////////////////////////

#include "chat_commands"
#include "nwnx_chat"

// Format : CHAT_[LEVL]:[SOURCE] | [DESTINATION] | [MESSAGE]

void LogChat(string sText, int iMode, int iTo)
{
    object oPCn;
    // Portion of format : CHAT_[LEVL]:[SOURCE] |
    string sMsg = "CHAT_" + dmb_getChannelText(iMode) + ": (";
    sMsg += GetPCPlayerName(OBJECT_SELF) + ") " + GetName(OBJECT_SELF) + " | ";

    // Portion of format : [DESTINATION]
    if (iMode == CHAT_CHANNEL_TALK || iMode == CHAT_CHANNEL_WHISPER)
    {
        int iIdx = 1;
        float fDst = 3.0;
        if (iMode == CHAT_CHANNEL_TALK)
            fDst = 10.0;

        // consider all players within fDst to be [DESTINATION]
        while (GetIsObjectValid(oPCn=GetNearestCreature(
                                                    CREATURE_TYPE_PLAYER_CHAR,
                                                    PLAYER_CHAR_IS_PC,
                                                    OBJECT_SELF,
                                                    iIdx++)))
        {
            if (GetDistanceToObject(oPCn) < fDst && oPCn != OBJECT_SELF)
                sMsg += GetName(oPCn)+":";
            else
                break;
        }
    }
    else if (iMode == CHAT_CHANNEL_SHOUT)
        sMsg += "(ALL)";
    else if (iMode == CHAT_CHANNEL_PARTY)
    {
        oPCn = GetFirstFactionMember(OBJECT_SELF, TRUE);
        while (GetIsObjectValid(oPCn))
        {
            sMsg += GetName(oPCn)+":";
            oPCn = GetNextFactionMember(OBJECT_SELF, TRUE);
        }
    }
    else if (iMode == CHAT_CHANNEL_PRIVATE)
    {
        oPCn = dmb_getPC(iTo);
        sMsg += "(" + GetPCPlayerName(oPCn) + ") " + GetName(oPCn);
    }
    else
    {
        oPCn = GetFirstPC();
        while (GetIsObjectValid(oPCn))
        {
            if (GetIsDM(oPCn))
                sMsg += " (" + GetPCPlayerName(oPCn)+") " + GetName(oPCn) + ":";
            oPCn = GetNextPC();
        }
    }
    // Portion of format : | [MESSAGE]
    sMsg += " | ";
    SetLocalString(OBJECT_SELF, "NWNX!CHAT!LOG", sMsg+"\n");
    SetLocalString(OBJECT_SELF, "NWNX!CHAT!LOG", " *** "+sText+"\n");

    // The internet never forgets
    WriteTimestampedLogEntry(sMsg + sText);
}

void main()
{
    // speaking object
    object oPC = OBJECT_SELF;
    object oPCn;

    // get text
    SetLocalString(oPC, "NWNX!CHAT!TEXT", dmb_GetSpacer());
    string sText = GetLocalString(oPC, "NWNX!CHAT!TEXT");
    int iMode	 = StringToInt(GetStringLeft(sText,2));
    int iTo 	 = StringToInt(GetSubString(sText,2,10));

    // trim 12 off the front to get rid of the mode data
    sText = dmb_GetStringFrom(sText, 12);

    // Chat command
    if(GetSubString(sText, 0, 1) == "/")
    {
    	if(GetSubString(sText, 1, 4) == "roll")
	{
	    RollCommand(oPC, GetStringRight(sText, 6));
	}
	else if(GetSubString(sText, 1, 6)== "social")
	{
	    SocialCommand(oPC, GetStringRight(sText, 8), iMode);
	}
	else if(GetSubString(sText, 1, 4) == "help")
	{
	    HelpCommand(oPC, GetStringRight(sText, 6));
	}
	else if(GetSubString(sText, 1, 5) == "emote")
	{
	    EmoteCommand(oPC, GetStringRight(sText, 7));
	}
        else if(GetSubString(sText, 1, 10) == "deathlevel")
        {
            if(GetIsPlayerCharacter(oPC))
                InvalidCommand(oPC, sText);
            else
                DeathLevelCommand(oPC, GetStringRight(sText, 12));
        }
	else
	{
	    InvalidCommand(oPC, sText);
	}

	SetLocalString(oPC, "NWNX!CHAT!SUPRESS", "1");
    }

    // Log this message
    LogChat(sText, iMode, iTo);

    // remove garbage
    DeleteLocalString(oPC, "NWNX!CHAT!TEXT");
    DeleteLocalString(oPC, "NWNX!CHAT!SUPRESS");
}


