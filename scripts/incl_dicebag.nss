#include "nwnx_odbc"

/* Returns an opposed social skill check. This will be whichever is highest:
  - The PC's Bluff check;
  - The PC's Intimidate check;
  - The PC's Persuade check; OR
  - The PC's Will Save + their Wisdom modifier
  Plus their d10 roll.
*/
int GetOpposedSocialSkillCheck(object oPC)
{
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

    return d10() + iMod;
}

int DBGetSkillConst(string sSkillName)
{
    SQLExecDirect("SELECT engine_value FROM lookup_skills " +
    	"WHERE string_ref = " + sSkillName + ";");

    if(SQLFetch() == SQL_SUCCESS)
	return SQLGetData(1);

    return -1;
}

int DBGetAbilityConst(string sAbilityName)
{
    SQLExecDirect("SELECT engine_value FROM lookup_abilities " +
    	"WHERE string_ref = " + sAbilityName + ";");

    if(SQLFetch() == SQL_SUCCESS)
	return SQLGetData(1);

    return -1;
}
