#include "class_bard"
#include "core_pc_token"

void main()
{
    object oPC = GetPCLevellingUp();
    int iBardLevels = GetLevelByClass(CLASS_TYPE_BARD, oPC);

    if(PCDBardLevelChanged(oPC, iBardLevels))
        BardLevel(oPC, iBardLevels);
}
