void PortToWaypoint(object oPC, string sWPTag)
{
    location lTarget = GetLocation(GetWaypointByTag(sWPTag));

    // Make sure we've got a valid port target.
    if(GetAreaFromLocation(lTarget) == OBJECT_INVALID)
    {
        WriteTimestampedLogEntry("ERROR: Jump to " + sWPTag + " failed.");
	    return;
    }

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionJumpToLocation(lTarget));
}

void PortToObject(object oPC, string sObjectTag)
{
    location lTarget = GetLocation(GetObjectByTag(sObjectTag));

    // Make sure we've got a valid port target.
    if(GetAreaFromLocation(lTarget) == OBJECT_INVALID)
    {
        WriteTimestampedLogEntry("ERROR: Jump to object " + sWPTag + " failed.");
	    return;
    }

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionJumpToLocation(lTarget));
}
