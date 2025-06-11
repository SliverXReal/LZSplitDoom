LZSplitDoom v1.68
=================
2024 Sliver X 
(sliverxreal@proton.me)

![Image Screenshot](https://github.com/SliverXReal/LZSplitDoom/blob/1cd556ba3c5db0ca44b0cc0190c06323a721b541/screenshot.png)

What It Is
----------
A Doom launcher for LZDoom that allows 2, 3 or 4 player "splitscreen" COOP/Deathmatch
on a single display using gamepads, simulating a console multiplayer experience. 


Requirements
------------
Windows Vista (x86 or x64) through Windows 11 or i686/AMD64 Linux using Wine.

2 to 4 XInput compatible gamepads.

GPU with OpenGL v3.3 support.


How To Use
----------


1) GUI Mode
-----

Invoke LZSplitDoom32.exe or LZSplitDoom64.exe with no command line options to load
the GUI: Select your options, then click the Launch button.

To get all the preconfigured games working, the following files are needed in the
DATA subdirectory (Default location: Set WADFOLDER= in LZSplitDoom.ini to change).

Ultimate Doom: doom.wad (Additionally, sigil.wad and sigil2.wad will be detected in DATA if present)

Doom 2: doom2.wad (Additionally, nerve.wad will be detected in DATA if present)

Final Doom - Evilution: tnt.wad

Final Doom - The Plutonia Experiment: plutonia.wad

Heretic: heretic.wad

Hexen: hexen.wad

Hexen - Death Kings of The Dark Citadel: hexdd.wad + hexen.wad

Strife: strife1.wad (and optionally voices.wad)

Each game has a specific subfolder under DATA that acts as an autoload directory: Anything
dropped into them will be loaded for their respective game.


2) CUSTOM GAMES
-----

The launcher supports custom game definitions that are defined in small INI files,
located by default under CUSTOM_GAMES (Default location: Set CUSTOMGAMEFOLDER= in 
LZSplitDoom.ini to change).

An example for Harmony.ini is shown here:

~~~~~~~~~~~~~~
[LZSplitDoomCustomGame]

Used for Save & Autoload Directory names.
GAMENAME=harmony

IWAD file.
IWAD=harm1.wad

Map List to populate "Level" control in GUI.
MAPLIST=map01|map02|map03|map04|map05|map06|map07|map08|map09|map10|map11|map12|map13

Custom Command Line: Overrides manual entries set in GUI if present.
CUSTOMCL=
~~~~~~~~~~~~~~

Note that if "Custom Game Template" is set to "none" in the interface all parameters
except for what makes the split screen functions work are supplied in the Command
Line edit box, such as:

-iwad doom2.wad -file smoothdoom.pk3 -file morelights2.pk3



3) SAVE GAMES
-----

Save game selection/loading is supported. Each game has an individual subfolder for saves
under CFG (Default location: Set CFGFOLDER= in LZSplitDoom.ini to change).

The launcher will prevent loading of a save made with a different number of players than
currently configured. If you want to delete a save, a Delete button has now been added
to the main interface.



4) CLI Mode
-----

Eight LZSplitDoom specific flags are defined. These should go before the standard command line
string you would typically define to run a game, though it doesn't particulary matter as of v1.52 or above.


Split Screen Type (Required)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-split=[FLAG]

[FLAG] values: vertical | horizontal | trih | triv | quad

Split the screen in two (vertically or horizontally), into thirds (Horizontal split with P1 on top and P2/P3 on the bottom or Vertical split with P1 on left and P2/P3 on right)
or into fourths.

-mirror=[BOOL]

[Bool] values: 0 | 1
~~~~~~~~~~~~~~~~
Invert splitscreen layout.


Hexen Class Type
~~~~~~~~~~~~~~~~

-p1class=[FLAG]
-p2class=[FLAG]
-p3class=[FLAG]
-p4class=[FLAG]
~~~~~~~~~~~~~~~~
[FLAG] values: fighter | cleric | mage


Set Player Classes. Values are ignored by LZDoom if not a Hexen based game.
These are simply the values for vanilla Hexen: If running a mod that adds
new classes whatever values the mod uses can be substituted here.

5) Reset Config
~~~~~~~~~~~~~~~~
-resetconfig
~~~~~~~~~~~~~~~~
Wipe Player/Launcher configs to be rebuilt at next run.



6) Help Menu
~~~~~~~~~~~~~~~~
-help
~~~~~~~~~~~~~~~~
Shows LZSplitDoom command line switches.

Example Usage:

[2 Player Hexen Deathmatch: 64 Bit: Mirrored Layout]
lzsplitdoom64.exe -split=vertical -mirror=1 -p1class=mage -p2class=cleric -iwad hexen.wad -deathmatch -nomonsters

[4 Player Doom 2 + Brutal Doom Coop: 32 Bit: No Mirroring]
lzsplitdoom32.exe -split=quad -mirror=0 -iwad doom2.wad -file brutaldoom.pk3


Default Controls
----------------
Up to 4 XInput compatible gamepads may be used. The program ships with
default control bindings and gameplay rules (Mostly following how the original games played), 
but any settings can be changed in Player 1's running instance and these will be propagated
to P2-P4 on next launch.

Common
~~~~~~
Dpad: Forward/Back/Strafe Left/Strafe Right
Left Stick: Forward/Back | Strafe Left/Strafe Right
Right Stick: Turn Left/Right | Look Up/LookDown (35 degree limit)
Right Trigger: Fire
Left Shoulder: Switch Weapon Left
Right Shoulder: Switch Weapon Right
B: Use
Y: Automap
Left Thumb: Toggle Always Run
Right Thumb: Center View
Back: Menu (Player 1 only!)

{Automap}
Left Stick: Pan (Follow Mode Off)
Right Stick Up/Down: Zoom In/Out
Left Thumb: Follow Mode On/Off
Right Thumb: Reset Zoom
~~~~~~

Hexen/Heretic
~~~~~~~~~~~~~
X: Inventory Left
A: Inventory Right
Start: Use Item
~~~~~~~~~~~~~

Hexen/Strife/Square's Adventure
~~~~~~~~~~~~~
Left Trigger: Jump
~~~~~~~~~~~~~

Strife Only
~~~~~~~~~~~~~
X: Objectives
A: Inventory Right
~~~~~~~~~~~~~

Square's Adventure Only
~~~~~~~~~~~~~
A: Goonades
X: Crouch
~~~~~~~~~~~~~

Other
-----
Included are Freedoom 1 and 2, Chex Quest 3, Hacx v1.2 Improved Version, Square's Adventure and Harmony.

John Romero's Sigil & Sigil II are also bundled and require doom.wad in the DATA folder to run.

No Rest For The Living: The 3.6MB nerve.wad from the PC version of Doom 3 BFG Edition was verified as working.

Also included is a mod I made called "Discount Doom 3D" that has Freedoom: Phase 1's maps with Doom's assets
using Cheelo's Voxel Doom mod with pkweapports and better dynamic lights. Requires doom.wad as well.

How It Works
------------
Player 1's INI is copied to P2-4 at every load to avoid conflicting settings, then
P2-4's INIs are edited in place before executing LZDoom to assign a different color
to them and a name of Player_2, Player_3 or Player_4, swapping Gamepad IDs so any
connected controllers don't interfere with each other, muting music on all clients
except Player 1 and setting save directory paths.

This program then strips the window borders off the instances, calculates the dimensions
of the primary display and resizes/moves them based on this information.

The menu button (By default, Back on Gamepad 1) is only bound to Player 1, and if
P1 quits, all other instances are terminated.

If Player 1's INI has been deleted it is recreated from a default template with
the settings needed to make all this work.

System settings, etc are always the same as Player 1 for all other players.
You can edit Player 1's config (Either .\CFG\player1\player1.ini manually or from P1's 
in-game menu) and the changes will be pushed to the other three players on next load.

Simultaneous keyboard controls fundamentally can't work because there's no way to run
them in the background on each client in LZDoom: Only gamepads.


Thanks
------

drfrag for LZDoom:
https://github.com/drfrag666/gzdoom/releases/tag/3.88b

Nir Sofer for nircmd.exe:
https://www.nirsoft.net

AutoIT:
https://www.autoitscript.com/site/

Gokuma from the Doomworld forums for their post that gave me a starting point:
https://www.doomworld.com/forum/topic/112080-local-four-player-splitscreen-lzdoom


Changelog
---------

v1.68
~~~~~
Fixed fairly serious bug regarding paths containing spaces. Now supports IWADs with spaces in name too.
Massive overhaul to default control schemas for all games. Viable for either dpad or left stick movement!
Replaced Hacx 2.0 with Hacx 1.2 Improved Edition.
Added Strife Co-Op v1.0 mod. Note that only P1 can control other player's dialog menus, but otherwise it works well.
Updated Cheelo's voxel models for Discount Doom to official GZDoom variant.
Fixed case of -MIRROR flag to be -mirror as intended for CLI use.
Informational text more suited for command line mode writes to console now, like the CLI -help flag.
Added command line flag ("-resetconfig") to reset configuration data in case of corruption/etc.
Minor code optimizations and several bug fixes in command line mode functions.


v1.666d
~~~~~~~
1) Updated LZDoom from v3.88b to vl4.8pre-619.
2) Mirror mode for split layout schemas.
3) Universal 35 degree look defined for all games. Must bind look up/down to inputs to enable.
4) Fixed Custom Command Line data not updating immediately when edited.
5) Minor code optimizations.


v1.52
~~~~~
1)  Removed Tri-Split mode, replaced with TriH and TriV modes (TriHorizontal/TriVertical).
2)  Removed Doom 64 Retribution and Wolf3D TC due to severe technical issues with multiplayer in both.
3)  -split parameter can be put anywhere in a command line string now instead of needing to be the first defined: This should allow 100% compatability with being launched from another Doom launcher.
4)  Added "Discount Doom 3D" Custom Game: Freedoom 1 maps using maximal Doom assets along with Voxel Doom and more. Requires doom.wad to function.

v1.5
~~~~
1)  Tri-Split mode added.
2)  Added Doom 64 Retribution data files and special handling for its soundfont.
3)  Implemented mechanism to prevent loading of save games made with different number of currently selected players.
4)  Added Delete button for saves.
5)  Improved documentation.

v1.4
~~~~
1)  Custom Game Template support: Add any game/mod via simple to make INI files.
2)  Added Strife Coop support.
3)  Added Square's Adventure and Harmony.
4)  Greatly expanded Readme.
5)  Code cleanups/optimizations.
6)  Restructured config/save logic.
7)  Fixed typos.

v1.32
~~~~~
1)  Save file management.
2)  Strife support (Deathmatch only).
3)  Refactored approximately 60% of the launcher code: Interface is much more intelligent now.
    Code is also a thousand times better so should be much easier to read for, say, creating a
    Linux equivalent to this program.
4)  Ability to edit %APPDATA%\LZSplitDoom\LZSplitDoom.ini to define custom WAD path for GUI.
5)  New GUI design.

v1.2
~~~~
1)  Skill level GUI control bug fixed.
2)  Fixed HighDPI detection bug for Windows 10 versions pre-1709.
3)  Map list corrections for Hexen - Deathkings of The Dark Citadel.
4)  Minor fixes to NERVE.WAD detection and added proper SIGIL.WAD detection.
5)  Launcher and player INI files now stored under %APPDATA%\LZSplitDoom instead of BIN
6)  P1 name "Player" changed to "Player_1" to better match P2-P3.
7)  Massive launcher code refactoring: Should be slightly faster now, and less buggy.
8)  Recreation of default LZSplitDoom.ini and player1.ini if missing.
9)  Merged X64 and X86 LZDoom install folders: Reduces size by 11MB.
10) AutoIT 3 source code now included under BIN\SRC

v1.1
~~~~
1)  HighDPI fixes: Should work properly on all versions of Windows from XP to 11 now.
2)  Added NERVE.WAD from Doom 3 BFG Edition detection/support for Doom 2 - No Rest For The Living
3)  Improved Readme.txt

v1.0
~~~~
1)  Command line support.
2)  Better HighDPI Support.
3)  32 bit and 64 bit with separate launchers. Configuration data is shared between them and the two LZDoom builds.
4)  Screens are now displayed on Primary Monitor only instead of spanning all displays in multi-monitor setups.
5)  Fixed several errors in map select lists for some games.
6)  Player 1 window always set to focused on launch.
7)  Single lzdoom.exe for all players instead of 4 separate copies.

Beta 4
~~~~~~
Initial release.
