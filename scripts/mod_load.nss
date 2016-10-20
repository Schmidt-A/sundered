#include "core_hunger"
#include "nwnx_odbc"

void main()
{
    SetLocalString(GetModule(),"NWNX!INIT","1");
    GetLocalObject(GetModule(), "NWNX!INIT");
    // Init placeholders for ODBC gateway
    SQLInit();

    DBInitFood();
}

