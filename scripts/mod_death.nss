#include "core_pc_token"

// TODO: Functions for setting/clearing death levels on a given area

void Unconsciousness(object oPC)
{

}

void Injury(object oPC)
{

}

void Death(object oPC)
{

}

void main()
{
    object oPC = GetLastPlayerDied();

    // DM-set death levels override area ones.
    int iDeathLevel = PCDGetDeathLevelDM(oPC);
    if(iDeathLevel < 1)
        iDeathLevel = PCDGetDeathLevel(oPC);

    switch(iDeathLevel)
    {
        case DEATH_LEVEL_UNCONSCIOUSNESS:
            Unconsciousness(oPC);
            break;
        case DEATH_LEVEL_INJURY:
            Injury(oPC);
            break;
        case DEATH_LEVEL_PERMA:
            Death(oPC);
            break;
    }
}
