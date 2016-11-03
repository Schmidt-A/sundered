#include "nw_i0_plot"

#include "core_pc_token"
#include "nwnx_chat"

void main()
{
    object oPC = GetEnteringObject();
    dmb_PCin(oPC); // initialize nwnx chat

    if(GetIsPlayerCharacter(oPC))
    {
        int iDMDeathLevel = PCDGetDeathLevelDM(oPC);
        if(iDMDeathLevel > 0)
        {
            string sWarning = "PLAYER " + GetPCPlayerName(oPC) + "'S CHARACTER " +
                GetName(oPC) + "LOGGED IN WITH CUSTOM DEATH LEVEL " +
                IntToString(iDMDeathLevel) + ". THIS MUST BE CLEARED.";
            SendMessageToAllDMs(sWarning);
            WriteTimestampedLogEntry(sWarning);
        }
    }
}
