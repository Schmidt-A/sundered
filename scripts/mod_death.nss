/*
  "When your time comes to die, be not like those whose hearts are filled with
  fear of death, so that when their time comes they weep and pray for a little 
  more time to live their lives over again in a different way.
  Sing your death song, and die like a hero going home."
*/

#include "core_pc_token"


void main()
{
    object oPC = GetLastPlayerDied();
    PCDSetDead(oPC);
}
