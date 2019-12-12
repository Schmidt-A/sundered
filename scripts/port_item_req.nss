/*******************************************************
 port_item_req

 This should be put on a placeable's OnUse event.

 Jump a PC from one placeable to another. This script expects four variables
 to be set on the object the player is using:

 string sTargetTag       - Tag of whatever placeable we are jumping to.
 string sRequiredItemTag - (Optional) PC must possess an item with this tag
                           in order to make the jump.
 string sSuccessMessage  - Message to send the PC if the jump is successful.
 string sFailureMessage  - Message to send the PC if they are lacking the item
                           necessary for the jump.

 *******************************************************/

void main()
{
    object oPC = GetLastUsedBy();
    string sTargetTag       = GetLocalString(OBJECT_SELF, "sDestinationObjectTag");
    string sRequiredItemTag = GetLocalString(OBJECT_SELF, "sRequiredItemTag");
    string sSuccessMessage  = GetLocalString(OBJECT_SELF, "sSuccessMessage");
    string sFailureMessage  = GetLocalString(OBJECT_SELF, "sFailureMessage");

    location lTarget = GetLocation(GetObjectByTag(sTargetTag));

    // Make sure we've got a valid port target.
    if(GetAreaFromLocation(lTarget) == OBJECT_INVALID)
    {
        WriteTimestampedLogEntry("ERROR: Jump to object " + sTargetTag + " failed.");
	    return;
    }

    // If a required item tag was supplied, make sure the PC has it.
    if(
        GetStringLength(sRequiredItemTag) > 0 &&
        GetItemPossessedBy(oPC, sRequiredItemTag) == OBJECT_INVALID)
    {
        SendMessageToPC(oPC, sFailureMessage);
        return;
    }

    // Do the jump.
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionJumpToLocation(lTarget));
    SendMessageToPC(oPC, sSuccessMessage);
}
