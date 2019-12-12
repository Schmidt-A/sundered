# sundered

A collection of Neverwinter Nights script utilities using the pynwn Python module, an nsscript compiler wrapper to facilitate custom compilation, a custom NWN log parser, and some preliminary server scripts/database concepts.

## Dependencies

Python:
 * pynwn
 * pygtail

Script Compilation:
 * Bioware base game scripts must be included in `scripts/` under `bioware/scripts` (we can't redistribute this).

Compiled nwnnsscomp binary is included in `tools/`. See `tools/license.txt` for more info.

## Project Tidbits

### The compiler wrapper

We found there was a lot of repetition of passing command line args for similar tasks (always having to specify the base Bioware scripts directory, etc) and it was tedious to compile a large number of scripts. compiler.py handles a lot of this.

### Script/Waypoint finders

In the interest of culling unused/bloaty scripts and dead waypoints, we wanted to know what scripts were actually being used in areas. There's no native way to check this in the toolset, so the script and waypoint finders list all area objects and their corresponding waypoints/scripts.

### Lumberjack

Once we started to expand our DM/PC event logging, we realized there was no real way to group and manage server logs - it all just winds up in one file. Lumberjack splits the single server log into configured separate files based on log type. The `dm_xp_parser` was written to ensure that players were being fairly awarded XP by the DM team.

### Game Scripts

Some prelimnary game server scripts including:
* Detailed PC hunger system;
* Custom injury-based death rules;
* Racial ECL level modifiers;
* Buffs for underpowered classes (bard currently, others to come);
* Chat command framework.

## Contributors

 * Tweek/Allisa - Compiler wrapper, script finder, XP checker, server scripts;
 * Aez/Alex - Database schemas and test data, server scripts;
 * Crust/Russ - Lumberjack.