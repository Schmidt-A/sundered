#include "core_pc_token"
#include "nwnx_chat"

void main()
{
    object oPC = GetExitingObject();
    dmb_PCout(oPC); // clear nwnx chat

    if(GetIsPlayerCharacter(oPC))
    {
        int iDMDeathLevel = PCDGetDeathLevelDM(oPC);
        if(iDMDeathLevel > 0)
        {
            string sWarning = "PLAYER " GetPCPlayerName(oPC) + "'S CHARACTER " +
                GetName(oPC) + "LOGGED OFF WITH CUSTOM DEATH LEVEL " +
                iDMDeathLevel + ". THIS MUST BE CLEARED.";
            SendMessageToAllDMs(sWarning);
            WriteTimestampedLogEntry(sWarning);
        }
    }
}