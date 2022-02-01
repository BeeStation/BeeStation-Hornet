var/global/rust_g = null
var/global/list/available_ui_styles = list(
	"Midnight",
	"Retro",
	"Plasmafire",
	"Slimecore",
	"Operative",
	"Clockwork"
)
var/global/list/ghost_forms = list("ghost","ghostking","ghostian2","skeleghost","ghost_red","ghost_black", \
							"ghost_blue","ghost_yellow","ghost_green","ghost_pink", \
							"ghost_cyan","ghost_dblue","ghost_dred","ghost_dgreen", \
							"ghost_dcyan","ghost_grey","ghost_dyellow","ghost_dpink", "ghost_purpleswirl","ghost_funkypurp","ghost_pinksherbert","ghost_blazeit",\
							"ghost_mellow","ghost_rainbow","ghost_camo","ghost_fire", "catghost")
var/global/list/ghost_orbits = list(GHOST_ORBIT_CIRCLE,GHOST_ORBIT_TRIANGLE,GHOST_ORBIT_SQUARE,GHOST_ORBIT_HEXAGON,GHOST_ORBIT_PENTAGON)
var/global/list/ghost_accs_options = list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL)
var/global/list/ghost_others_options = list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING)
var/global/list/pda_styles = list(MONO, VT, ORBITRON, SHARE)
var/global/list/balloon_alerts = list(BALLOON_ALERT_ALWAYS, BALLOON_ALERT_NEVER, BALLOON_ALERT_WITH_CHAT)
var/global/list/scaling_methods = list(SCALING_METHOD_NORMAL, SCALING_METHOD_BLUR, SCALING_METHOD_DISTORT)
// Defaults dumped from a savefile
var/global/list/keybinding_list_by_key = list(
		"F3" = list("admin_say"),
		"F4" = list("mentor_say"),
		"F5" = list("admin_ghost"),
		"F6" = list("player_panel"),
		"F7" = list("toggle_build_mode"),
		"F8" = list("invismin"),
		"F10" = list("dead_say"),
		"R" = list("toggle_throw_mode"),
		"1" = list("select_help_intent","toggle_module_1"),
		"2" = list("select_disarm_intent","toggle_module_2"),
		"3" = list("select_grab_intent","toggle_module_3"),
		"4" = list("change_intent_robot","select_harm_intent"),
		"G" = list("Give_Item"),
		"F1" = list("get_help"),
		"F2" = list("screenshot"),
		"F12" = list("toggleminimalhud"),
		"\]" = list("zoomin"),
		"E" = list("quick_equip"),
		"Shift-E" = list("quick_equip_belt"),
		"Shift-B" = list("quick_equip_backpack"),
		"Shift-Q" = list("quick_equip_suit_storage"),
		"B" = list("resist"),
		"V" = list("rest"),
		"W" = list("move_north"),
		"D" = list("move_east"),
		"S" = list("move_south"),
		"A" = list("move_west"),
		"Ctrl-W" = list("face_north"),
		"Ctrl-D" = list("face_east"),
		"Ctrl-S" = list("face_south"),
		"Ctrl-A" = list("face_west"),
		"H" = list("stop_pulling"),
		"Home" = list("cycle_intent_right"),
		"Insert" = list("cycle_intent_left"),
		"X" = list("swap_hands"),
		"Z" = list("activate_inhand"),
		"Q" = list("drop_item","unequip_module"),
		"Alt" = list("toggle_move_intent"),
		"Unbound" = list("toggle_move_intent_alt"),
		"Numpad8" = list("target_head_cycle"),
		"Numpad4" = list("target_r_arm"),
		"Numpad5" = list("target_body_chest"),
		"Numpad6" = list("target_left_arm"),
		"Numpad1" = list("target_right_leg"),
		"Numpad2" = list("target_body_groin"),
		"Numpad3" = list("target_left_leg"),
		"Ctrl" = list("block_movement"))

/world/New()
	if(world.system_type == MS_WINDOWS)
		rust_g = "rust_g"
	else
		rust_g = "librust_g.so"

	log = file("log.txt")

	run_migration()

/world/proc/ImmediateInvokeAsync(thingtocall, proctocall, ...)
	set waitfor = FALSE

	if (!thingtocall)
		return

	var/list/calling_arguments = length(args) > 2 ? args.Copy(3) : null

	if (thingtocall == GLOBAL_PROC)
		call(proctocall)(arglist(calling_arguments))
	else
		call(thingtocall, proctocall)(arglist(calling_arguments))

/proc/run_migration()
	var/datum/dbcore/db = new
	if(!db.IsConnected())
		world.log << "Failed to connect to DB, check creds"
		return

	world.log << "Starting savefile conversion"
	var/list/first_letters = flist(SAVEFILE_DIRECTORY)
	for(var/letter in first_letters)
		if(copytext(letter, -1) != "/")
			continue // skip files
		var/letter_path = SAVEFILE_DIRECTORY + letter
		var/list/keys = flist(letter_path)
		for(var/key in keys)
			if(copytext(key, -1) != "/")
				continue // skip files
			var/savefile_path = letter_path + key + "preferences.sav"
			var/datum/preferences/prefs = new
			var/ckey = copytext(key, 1, -1) // remove trailing /
			world.log << "Processing [ckey]"
			prefs.path = savefile_path
			prefs.ckey = ckey
			prefs.load_preferences()
			var/datum/DBQuery/query = db.NewQuery({"
				REPLACE INTO [DB_PREFS_TABLE] (ckey, asay_color, ooc_color, last_changelog, ui_style, outline_color, see_balloon_alerts, be_special, default_slot, chat_toggles, toggles, toggles_2, sound_toggles, ghost_form, ghost_orbit, ghost_accs, ghost_others, preferred_map, ignoring, client_fps, parallax, pixel_size, scaling_method, tip_delay, pda_style, pda_color, purchased_gear, equipped_gear, pai_name, pai_description, pai_role, pai_comments)
				VALUES(:ckey, :asay_color, :ooc_color, :last_changelog, :ui_style, :outline_color, :see_balloon_alerts, :be_special, :default_slot, :chat_toggles, :toggles, :toggles_2, :sound_toggles, :ghost_form, :ghost_orbit, :ghost_accs, :ghost_others, :preferred_map, :ignoring, :client_fps, :parallax, :pixel_size, :scaling_method, :tip_delay, :pda_style, :pda_color, :purchased_gear, :equipped_gear, :pai_name, :pai_description, :pai_role, :pai_comments)
			"}, list(
				"ckey" = ckey,
				"asay_color" = prefs.asaycolor,
				"ooc_color" = prefs.ooccolor,
				"last_changelog" = prefs.lastchangelog,
				"ui_style" = prefs.UI_style,
				"outline_color" = prefs.outline_color,
				"see_balloon_alerts" = prefs.see_balloon_alerts,
				"be_special" = json_encode(prefs.be_special),
				"default_slot" = prefs.default_slot,
				"chat_toggles" = prefs.chat_toggles,
				"toggles" = prefs.toggles,
				"toggles_2" = prefs.toggles_2,
				"sound_toggles" = prefs.sound_toggles,
				"ghost_form" = prefs.ghost_form,
				"ghost_orbit" = prefs.ghost_orbit,
				"ghost_accs" = prefs.ghost_accs,
				"ghost_others" = prefs.ghost_others,
				"preferred_map" = prefs.preferred_map,
				"ignoring" = json_encode(prefs.ignoring),
				"client_fps" = prefs.clientfps,
				"parallax" = prefs.parallax,
				"pixel_size" = prefs.pixel_size,
				"scaling_method" = prefs.scaling_method,
				"tip_delay" = prefs.tip_delay,
				"pda_style" = prefs.pda_style,
				"pda_color" = prefs.pda_color,
				"purchased_gear" = json_encode(prefs.purchased_gear),
				"equipped_gear" = json_encode(prefs.equipped_gear),
				"pai_name" = prefs.pai_name,
				"pai_description" = prefs.pai_description,
				"pai_role" = prefs.pai_role,
				"pai_comments" = prefs.pai_comments
			))
			if(query)
				query.Execute(async = FALSE, log_error = TRUE)
				query.Destroy()
				del(query)
			else
				world.log << "Couldn't create a query"
				return
