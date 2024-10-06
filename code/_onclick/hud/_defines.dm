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
#define ui_monkey_head "CENTER-5:14,SOUTH:5"	//monkey
#define ui_monkey_mask "CENTER-4:15,SOUTH:5"	//monkey
#define ui_monkey_neck "CENTER-3:16,SOUTH:5"	//monkey
#define ui_monkey_back "CENTER-2:17,SOUTH:5"	//monkey

//#define ui_alien_storage_l "CENTER-2:14,SOUTH:5"//alien
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"//alien
#define ui_alien_language_menu "EAST-3:26,SOUTH:5" //alien

#define ui_drone_drop "CENTER+1:18,SOUTH:5"     //maintenance drones
#define ui_drone_pull "CENTER+2:2,SOUTH:5"      //maintenance drones
#define ui_drone_storage "CENTER-2:14,SOUTH:5"  //maintenance drones
#define ui_drone_head "CENTER-3:14,SOUTH:5"     //maintenance drones

//Lower right, persistent menu
#define ui_drop_throw "EAST-1:28,SOUTH+1:7"
#define ui_above_movement "EAST-2:26,SOUTH+1:7"
#define ui_above_intent "EAST-3:24, SOUTH+1:7"
#define ui_movi "EAST-2:26,SOUTH:5"
#define ui_acti "EAST-3:24,SOUTH:5"
#define ui_zonesel "EAST-1:28,SOUTH:5"
#define ui_acti_alt "EAST-1:28,SOUTH:5"	//alternative intent switcher for when the interface is hidden (F12)
#define ui_crafting	"EAST-4:22,SOUTH:5"
#define ui_building "EAST-4:22,SOUTH:21"
#define ui_language_menu "EAST-4:6,SOUTH:21"

#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"


//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:28,CENTER+5:27"
#define ui_alert2 "EAST-1:28,CENTER+4:25"
#define ui_alert3 "EAST-1:28,CENTER+3:23"
#define ui_alert4 "EAST-1:28,CENTER+2:21"
#define ui_alert5 "EAST-1:28,CENTER+1:19"


//Middle right (status indicators)
#define ui_healthdoll "EAST-1:28,CENTER-2:13"
#define ui_health "EAST-1:28,CENTER-1:15"
#define ui_internal "EAST-1:28,CENTER+1:17"
#define ui_mood "EAST-1:28,CENTER:17"
#define ui_spacesuit "EAST-1:28,CENTER-4:10"
#define ui_stamina "EAST-1:28,CENTER-3:10"

//borgs
#define ui_borg_health "EAST-1:28,CENTER-1:15"		//borgs have the health display where humans have the pressure damage indicator.

//aliens
#define ui_alien_health "EAST,CENTER-1:15"	//aliens have the health display where humans have the pressure damage indicator.
#define ui_alienplasmadisplay "EAST,CENTER-2:15"
#define ui_alien_queen_finder "EAST,CENTER-3:15"

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
