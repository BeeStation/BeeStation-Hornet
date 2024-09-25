/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "17x15".
	Therefore, the top right corner (except during admin shenanigans) is at "17,15"
*/


#define ui_devilsouldisplay "WEST:6,CENTER-1:15"

	//borgs
#define ui_borg_crew_manifest "CENTER+5:21,SOUTH:5"	//borgs

#define ui_monkey_body "CENTER-6:12,SOUTH:5"	//monkey

//constructs
#define ui_construct_pull "EAST,CENTER-2:15"
#define ui_construct_health "EAST,CENTER:15"  //same as borgs and humans

//slimes
#define ui_slime_health "EAST,CENTER:15"  //same as borgs, constructs and humans

#define ui_ai_mod_int "SOUTH:6,WEST+10"
#define ui_ai_move_up "SOUTH:6,WEST+14"
#define ui_ai_move_down "SOUTH:6,WEST+15"

#define ui_pai_mod_int "SOUTH:6,WEST+12"


//Ghosts

#define ui_ghost_jumptomob "SOUTH:6,CENTER-3:24"

//Team finder

#define ui_team_finder "CENTER,CENTER"

// Holoparasites
#define ui_holopara_l_hand			"CENTER:8,SOUTH+1:4"
#define ui_holopara_r_hand			"CENTER+1:8,SOUTH+1:4"
#define ui_holopara_pull			"CENTER:24,SOUTH:20"
#define ui_holopara_pull_dex		"CENTER-1:9,SOUTH+1:2"
#define ui_holopara_swap_l			"CENTER:8,SOUTH+2:4"
#define ui_holopara_swap_r			"CENTER+1:8,SOUTH+2:4"
#define ui_holopara_button(pos)		"CENTER[pos >= 0 ? "+" : ""][pos]:8,SOUTH:5"
#define ui_holopara_hand(pos)		"CENTER[pos >= 0 ? "+" : ""][pos]:8,SOUTH+1:4"
