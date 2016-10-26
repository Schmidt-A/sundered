#include "core_pc_token"


void Unconsciousness(object oPC)
{
    int iGainedXP = GetXP(oPC) - PCDGetAreaEnterXP(oPC);

    // Take away whatever XP the player had gained in the given area
    SetXP(oPC, GetXP(oPC) - iGainedXP);

    // TODO: Clear spawns unless the area has conscious PCs in it
    // TODO: Drop some (?) of wealth
    // TODO: Cutscene darkness for X minutes
    // TODO: Some sort of message
}

void Injury(object oPC)
{
    PCDAddInjury(oPC);
    // TODO: Message
}

void Bleed(int iBleedAmt)
{
    effect eBleedEffect = EffectDamage(iBleedAmt);

    if(GetCurrentHitPoints <= 0)
    {
        if(iBleedAmt < 0) // Negative bleeding = healing
            eBleedEffect = EffectHeal(-iBleedAmt);

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eBleedEffect, OBJECT_SELF);

        // "Dead" - need to figure out what happens given active death level
        if(GetCurrentHitPoints() <= -10)
        {
            // DM-set death levels override area ones.
            int iDeathLevel = PCDGetDeathLevelDM(OBJECT_SELF);
            if(iDeathLevel < 1)
                iDeathLevel = PCDGetDeathLevel(OBJECT_SELF);

            switch(iDeathLevel)
            {
                case DEATH_LEVEL_UNCONSCIOUSNESS:
                    Unconsciousness(OBJECT_SELF);
                    break;
                case DEATH_LEVEL_INJURY:
                    Injury(OBJECT_SELF);
                    break;
                case DEATH_LEVEL_PERMA:
                    PlayVoiceChat(VOICE_CHAT_DEATH, OBJECT_SELF);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), OBJECT_SELF);
                    break;
            }
        }

        // If we haven't stablized, see if we keep bleeding
        if(iBleedAmt > 0)
        {
            // 10% chance of stablizing, as per 3.5 rules
            if(d10() == 10)
            {
                iBleedAmt = -iBleedAmt;
                SendMessageToPC(OBJECT_SELF, "You have stabilized and begun to heal");
            }
            else
            {
                SendMessageToPC(OBJECT_SELF, "You've failed to stabilize and continue bleeding");
                switch(d3())
                {
                    case 1: PlayVoiceChat(VOICE_CHAT_PAIN1); break;
                    case 2: PlayVoiceChat(VOICE_CHAT_PAIN2); break;
                    case 3: PlayVoiceChat(VOICE_CHAT_PAIN3); break;
                }
            }
        }

        // Keep bleeding out if we need to
        if(GetCurrentHitPoints() <= 0)
            DelayCommand(6.0 Bleed(iBleedAmt));
    }
}

void main()
{
    object oPC = GetLastPlayerDying();

    if(!GetIsPlayerCharacter(oPC))
        return;

    // TODO: Rules for PvP death
    AssignCommand(oDying, Bleed(1))
}
