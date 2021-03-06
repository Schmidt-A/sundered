#include "nwnx_odbc"

/* Returns an opposed social skill check. This will be whichever is highest:
  - The PC's Bluff check;
  - The PC's Intimidate check;
  - The PC's Persuade check; OR
  - The PC's Will Save + their Wisdom modifier (with a level cap)
  Plus their d10 roll.
*/
int GetOpposedSocialSkillCheck(object oPC)
{
    int iMod = GetWillSavingThrow(oPC) + GetAbilityModifier(ABILITY_WISDOM, oPC);

    // Scaling cap applied to the will + wisdom because we want people to have to sacrifice to be able to defend against these well
    // 12 - PC level right now
    int iCap = 12 - GetHitDice(oPC);
    if(iMod > iCap)
    {
        iMod = iCap;
    }
    
    int iSkill = GetSkillRank(SKILL_BLUFF, oPC);
    if(iSkill > iMod)
        iMod = iSkill;

    iSkill = GetSkillRank(SKILL_INTIMIDATE, oPC);
    if(iSkill > iMod)
        iMod = iSkill;

    iSkill = GetSkillRank(SKILL_PERSUADE, oPC);
    if(iSkill > iMod)
        iMod = iSkill;

    return d10() + iMod;
}

int DBGetSkillConst(string sSkillName)
{
    SQLExecDirect("SELECT engine_value FROM lookup_skills " +
    	"WHERE string_ref = " + sSkillName + ";");

    if(SQLFetch() == SQL_SUCCESS)
	return StringToInt(SQLGetData(1));

    return -1;
}

int DBGetAbilityConst(string sAbilityName)
{
    SQLExecDirect("SELECT engine_value FROM lookup_abilities " +
    	"WHERE string_ref = " + sAbilityName + ";");

    if(SQLFetch() == SQL_SUCCESS)
	return StringToInt(SQLGetData(1));

    return -1;
}
