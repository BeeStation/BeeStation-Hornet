<h1 align="center">CarpStation 13 a CodeBase for Space Station 13 (CarpCode)</h1>  
  
**Website:** N/a  
**Code:** https://github.com/CarpStation/CarpStation  
**Wiki:** https://wiki.beestation13.com/view/Main_Page - Needs own wiki.  
  
## ABOUT  
This is a code base using Bee as a foundation.  
Current features:  
-HippieChem: Reagents can become solids, liquids, and vapors.  
-Sticky Tape: Cover items in tape and throw them at people! Or apply directly using grab intent (even yourself)  
-Dual Wield melee: Attacking in harm mode will now swing both of your current weapons!  
-Atmos Chems: Currently not connected. Infrustructure for creating gasses for all chemicals and handling their reactions.  
  
  
  
### Python Tools:  
Disclaimer these are probably written horribly and barely work :)  
  
## CreateChemGas.py
This will go through all files in \reagents\chemistry\reagents, and \reagents\chemistry\recipes then automatically build gasses, gas containers, and ui element for said gasses in gas_types.dm, canister.dm and constants.js  
  
It will place the generated info between '// BEGIN' and '// END' (or // LIST BEGIN) to indicate where it should be writing to.  
Note that changes shouldn't be made to the gasses themselves or their mixtures as it rewrites the data in between these.  
  
At the end of running it will tell you the total number of gasses, use this number and recompile byond-extools setting TOTAL_NUM_GASES.  
Once done replace byond-extools.dll and byond-extools.pdb  
  
  
## Update DME.py  
A script I made to simplify porting things. Run it to automatically add all files to carpstation.dme.  
  
You can also put any of the following in Config.txt to have this ignore files that match  
Exclude: /folder/  
Exclude: /folder  
Exclude: folder  
Exclude: achievements.dm  
  
  
## Update DME.py  
A script to simplify porting from other servers. Can run regex replacements against entire codebases.  
Update Config.txt then point it toward the folder you want it to work on.  
Examples:  
Replace: "hairstyle" "hair-styles"  
  
To ude regex follow the following format:  
Replace: "regex//.+" ""  
  
  
## LICENSE

All code after [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST](https://github.com/tgstation/tgstation/commit/333c566b88108de218d882840e61928a9b759d8f) is licensed under [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Including tools unless their readme specifies otherwise.)

See LICENSE and GPLv3.txt for more details.

tgui clientside is licensed as a subproject under the MIT license.
Font Awesome font files, used by tgui, are licensed under the SIL Open Font License v1.1
tgui assets are licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
The TGS3 API is licensed as a subproject under the MIT license.

See tgui/LICENSE.md for the MIT license.
See tgui/assets/fonts/SIL-OFL-1.1-LICENSE.md for the SIL Open Font License.
See the footers of code/\_\_DEFINES/server\_tools.dm, code/modules/server\_tools/st\_commands.dm, and code/modules/server\_tools/st\_inteface.dm for the MIT license.

All assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.

byond-extools.dll is licensed under MIT. See MIT.txt for more details.

# Other Codebase Credits
- HippieStation, for their Reagent Systems
- beestation, for the codebase
- /tg/, for the codebase.
- CEV Eris, for the PDA sprites
- TGMC, for the custom keybinds base
- Citadel, for their beautiful lighting
