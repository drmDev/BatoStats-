BatoStats++ v1.006 - Post-battle combat statistics for Batomon Showdown
=====================================================================

BatoStats++ adds a collapsible panel after each battle that compares your
team's combat statistics with the opponent's.


FEATURES
--------
- Team totals for damage, status damage, healing, shield, and casts.
- A comparison operator (>, <, or =) between your total and the opponent's.
- A compact one-row-per-unit table for each team.
- The top value for each metric on each team is highlighted in green.
- Zero and missing values are shown in a muted color.
- The panel can be collapsed and dragged.

The panel appears when a battle finishes and hides when you leave the battle.
It is also hidden while a replay is running.


SETTINGS
--------
Settings > Mods > BatoStats++

- Team Comparison Totals: show the summed team comparison at the top of the
  panel (on by default). Turn it off to show only the per-unit tables.
- Auto-update: download and install new versions from GitHub (on by default).


AUTO-UPDATE
-----------
BatoStats++ keeps itself current. On game start it checks for a newer version.
When a new version is out, Auto-update (Settings > Mods > BatoStats++, on by
default) downloads it and checks it before anything is replaced: the download
must match the release's checksum, contain only BatoStats++ files, and every
script must load on your game build. If a check fails or the download fails,
nothing on disk changes.

After a successful update a small notice says to restart. The new version takes
effect the next time Batomon Showdown starts.

Turn Auto-update off to get a notice only and install new versions yourself
(e.g. from Nexus Mods or GitHub) by replacing the Mods\BatoStats++ folder.


REQUIREMENTS
------------
- Batomon Showdown (Steam, PC)
- Community Batomon Showdown Mod Loader

IMPORTANT: The community Mod Loader is REQUIRED and must be installed before
BatoStats++.

Mod Loader by EmoUsedHM01 and madibye (separate download).


INSTALLATION
------------
1. Install the community Batomon Showdown Mod Loader first.
   Follow the installation instructions on its Nexus Mods page.

2. Close Batomon Showdown.

3. Locate your game installation folder:
   Steam > Right-click Batomon Showdown > Manage > Browse local files

4. Extract the BatoStats++ ZIP into the game folder, preserving the folder
   structure.

   The resulting structure should look like:

   Batomon Showdown\Mods\BatoStats++\
      mod_main.gd
      mod.json
      ...additional mod files...

   IMPORTANT:
   - Do not create an extra nested BatoStats++ folder.
   - mod_main.gd and mod.json must be directly inside Mods\BatoStats++\.

5. Launch Batomon Showdown.

The Mod Loader should automatically detect BatoStats++. No settings are
required; installing the mod enables it.


UNINSTALLATION
--------------
1. Close Batomon Showdown.
2. Delete the folder:

   Batomon Showdown\Mods\BatoStats++

3. Launch the game normally.

BatoStats++ does not modify game saves or permanent gameplay data. Uninstalling
does not require starting a new run.


COMPATIBILITY & TROUBLESHOOTING
-------------------------------
BatoStats++ is designed to work alongside other mods using the community Mod
Loader, but compatibility with every mod is not guaranteed.

If the mod does not appear:
- Confirm the Mod Loader is installed and working.
- Verify the folder structure shown above.
- Restart the game.

If you encounter a bug, please include a description, reproduction steps, and
screenshots if possible.


FEEDBACK
--------
Suggestions, bug reports, and feature requests are welcome!

Leave feedback on Nexus Mods or submit an issue on GitHub.


CREDITS
-------
BatoStats++ is an unofficial fan-made mod.

Not affiliated with or endorsed by the developers of Batomon Showdown.

Community Mod Loader by EmoUsedHM01 and madibye.

Batomon Showdown and its assets belong to their respective owners.
