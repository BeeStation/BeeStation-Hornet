#define CAN_HEAR_MASTERS (1<<0)
#define CAN_HEAR_ACTIVE_HOLOCALLS (1<<1)
#define CAN_HEAR_RECORD_MODE (1<<2)
#define CAN_HEAR_HOLOCALL_USER (1<<3)
#define CAN_HEAR_ALL_FLAGS (CAN_HEAR_MASTERS|CAN_HEAR_ACTIVE_HOLOCALLS|CAN_HEAR_RECORD_MODE|CAN_HEAR_HOLOCALL_USER)

/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Any number of AIs can use a holopad. /Lo6
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2

/obj/machinery/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	base_icon_state = "holopad"
	layer = MAP_SWITCH(ABOVE_OPEN_TURF_LAYER, LOW_OBJ_LAYER)
	plane = MAP_SWITCH(FLOOR_PLANE, GAME_PLANE)
	req_access = list(ACCESS_KEYCARD_AUTH) //Used to allow for forced connecting to other (not secure) holopads. Anyone can make a call, though.
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	max_integrity = 300
	armor_type = /datum/armor/machinery_holopad
	circuit = /obj/item/circuitboard/machine/holopad
	/// associative lazylist of the form: list(owner of a hologram = hologram representing that owner).
	var/list/masters
	/// Holoray-owner link
	var/list/holorays
	/// To prevent request spam. ~Carn
	COOLDOWN_DECLARE(ai_spam_cooldown)
	/// Change to change how far the AI can move away from the holopad before deactivating
	var/holo_range = 5
	/// Array of /datum/holocalls that are calling US. this is only filled for holopads answering calls from another holopad
	var/list/holo_calls
	/// Currently outgoing holocall, cannot call any other holopads unless this is null.
	/// creating a new holocall from us to another holopad sets this var to that holocall datum
	var/datum/holocall/outgoing_call
	/// Record disk
	var/obj/item/disk/holodisk/disk
	/// Currently replaying a recording
	var/replay_mode = FALSE
	/// Currently looping a recording
	var/loop_mode = FALSE
	/// Currently recording
	var/record_mode = FALSE
	/// Recording start time
	var/record_start = 0
	/// User that inititiated the recording
	var/record_user
	/// Replay hologram
	var/obj/effect/overlay/holo_pad_hologram/replay_holo
	/// Calls will be automatically answered after a couple rings, here for debugging
	var/static/force_answer_call = FALSE
	/// If we're currently ringing another holopad or not. Used to prevent unnecessary update_appearance() calls.
	var/ringing = FALSE
	/// The offset of our current holodisk's recording. If 0, there is no offset and it's positioned on our turf.
	var/offset = 0
	/// If we're on the main holopad network or not. In other words, can we connect to other holopads?
	var/on_network = TRUE
	/// The main holopad network. Directly related to the above variable
	var/static/list/holopads = list()
	/// For pads in secure areas; do not allow forced connecting
	var/secure = FALSE
	/// If we are currently calling another holopad
	var/calling = FALSE
	/// Bitfield. used to turn on and off hearing sensitivity depending on if we can act on Hear() at all - meant for lowering the number of unessesary hearable atoms
	var/can_hear_flags = NONE

	emag_toggleable = TRUE

/datum/armor/machinery_holopad
	melee = 50
	bullet = 20
	laser = 20
	energy = 20
	fire = 50

/obj/machinery/holopad/Initialize(mapload)
	. = ..()
	if(on_network)
		holopads += src

/obj/machinery/holopad/secure
	name = "secure holopad"
	desc = "It's a floor-mounted device for projecting holographic images. This one will refuse to auto-connect incoming calls."
	secure = TRUE

/obj/machinery/holopad/secure/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/machine/holopad/board = circuit
	board.build_path = /obj/machinery/holopad/secure

/obj/machinery/holopad/tutorial
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1
	on_network = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor
	var/proximity_range = 1

/obj/machinery/holopad/tutorial/Initialize(mapload)
	. = ..()
	if(proximity_range)
		proximity_monitor = new(src, proximity_range)
	if(mapload)
		var/obj/item/disk/holodisk/new_disk = locate(/obj/item/disk/holodisk) in src.loc
		if(new_disk && !disk)
			new_disk.forceMove(src)
			disk = new_disk

/obj/machinery/holopad/tutorial/attack_hand(mob/user, list/modifiers)
	if(!istype(user))
		return
	if(user.incapacitated || !is_operational)
		return
	if(replay_mode)
		replay_stop()
	else if(disk?.record)
		replay_start()

/obj/machinery/holopad/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!loc)
		return
	// move any relevant holograms, basically non-AI, and rays with the pad
	for(var/mob/living/user as anything in holorays)
		var/obj/effect/overlay/holoray/ray = holorays[user]
		ray.abstract_move(loc)
	var/list/non_call_masters = masters?.Copy()
	for(var/datum/holocall/holocall as anything in holo_calls)
		if(!holocall.user || !LAZYACCESS(masters, holocall.user))
			continue
		non_call_masters -= holocall.user
		// moving the eye moves the holo which updates the ray too
		holocall.eye.setLoc(locate(clamp(x + (holocall.hologram.x - old_loc.x), 1, world.maxx), clamp(y + (holocall.hologram.y - old_loc.y), 1, world.maxy), z))
	for(var/datum/holo_master as anything in non_call_masters)
		var/obj/effect/holo = masters[holo_master]
		update_holoray(holo_master, holo.loc)

/obj/machinery/holopad/tutorial/HasProximity(atom/movable/AM)
	if (!isliving(AM))
		return
	if(!replay_mode && (disk && disk.record))
		replay_start()

/obj/machinery/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/datum/holocall/holocall_to_disconnect as anything in holo_calls)
		holocall_to_disconnect.ConnectionFailure(src)

	if(replay_mode)
		replay_stop()
	if(record_mode)
		record_stop()

	for (var/I in masters)
		clear_holo(I)

	QDEL_NULL(disk)

	holopads -= src
	return ..()

/obj/machinery/holopad/power_change()
	. = ..()
	if (!powered())
		if(replay_mode)
			replay_stop()
		if(record_mode)
			record_stop()
		outgoing_call?.ConnectionFailure(src)

/obj/machinery/holopad/atom_break()
	. = ..()
	outgoing_call?.ConnectionFailure(src)

/obj/machinery/holopad/on_deconstruction(dissassembled)
	disk?.forceMove(drop_location())
	return ..()

/obj/machinery/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/holopad/examine(mob/user)
	. = ..()
	if(isAI(user) || in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Current projection range: <b>[holo_range]</b> units.")

/obj/machinery/holopad/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.) || anchorvalue)
		return

	if(outgoing_call)
		outgoing_call.ConnectionFailure(src) //disconnect the call if we got unwrenched.

	for(var/datum/holocall/holocall_to_disconnect as anything in holo_calls)
		holocall_to_disconnect.ConnectionFailure(src)

	if(replay_mode)
		replay_stop()
	if(record_mode)
		record_stop()

/obj/machinery/holopad/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	return default_deconstruction_screwdriver(user, "holopad_open", "holopad0", tool)

/obj/machinery/holopad/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	return default_deconstruction_crowbar(tool)

/obj/machinery/holopad/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/disk/holodisk))
		return ..()

	if(disk)
		to_chat(user,span_notice("There's already a disk inside [src]"))
		return
	if (!user.transferItemToLoc(attacking_item, src))
		return
	to_chat(user, span_notice("You insert [attacking_item] into [src]"))
	disk = attacking_item
	ui_update()
	return TRUE

/obj/machinery/holopad/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == disk)
		disk = null

/obj/machinery/holopad/on_emag(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		to_chat(user, span_danger("You override the holopad's identity systems. It will now project false caller information."))
	else
		to_chat(user, span_notice("You reset the holopad's security override. The systems return to normal."))
		visible_message(span_notice("[src]'s indicator lights flicker and return to a steady blue."))
	return TRUE

/obj/machinery/holopad/ui_status(mob/user, datum/ui_state/state)
	if(!is_operational)
		return UI_CLOSE
	if(outgoing_call && !calling)
		return UI_CLOSE
	return ..()

/obj/machinery/holopad/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holopad", name)
		ui.open()

/obj/machinery/holopad/ui_data(mob/user)
	var/list/data = list()
	data["calling"] = calling
	data["on_network"] = on_network
	data["on_cooldown"] = !COOLDOWN_FINISHED(src, ai_spam_cooldown)
	data["allowed"] = allowed(user)
	data["disk"] = !!disk
	data["disk_record"] = !!disk?.record
	data["replay_mode"] = replay_mode
	data["loop_mode"] = loop_mode
	data["record_mode"] = record_mode
	data["holo_calls"] = list()
	for(var/datum/holocall/HC as anything in holo_calls)
		var/caller_name_display
		if(HC.spoofed)
			caller_name_display = "Unknown"
		else
			caller_name_display = HC.user?.name || "Unknown"
		var/list/call_data = list(
			"caller" = caller_name_display,
			"connected" = (HC.connected_holopad == src),
			"ref" = REF(HC)
		)
		data["holo_calls"] += list(call_data)
	return data

/obj/machinery/holopad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("AIrequest")
			if(isAI(usr))
				var/mob/living/silicon/ai/ai_user = usr
				ai_user.eyeobj.setLoc(get_turf(src))
				to_chat(usr, span_info("AIs can not request AI presence. Jumping instead."))
				return
			if(COOLDOWN_FINISHED(src, ai_spam_cooldown))
				COOLDOWN_START(src, ai_spam_cooldown, 20 SECONDS)
				to_chat(usr, span_info("You requested an AI's presence."))
				var/area/area = get_area(src)
				for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
					if(!ai.client)
						continue
					to_chat(ai, span_info("Your presence is requested at <a href='byond://?src=[REF(ai)];jump_to_holopad=[REF(src)]'>\the [area]</a>. <a href='byond://?src=[REF(ai)];project_to_holopad=[REF(src)]'>Project Hologram?</a>"))
				return TRUE
			else
				to_chat(usr, span_info("A request for AI presence was already sent recently."))
				return

		if("holocall")
			if(outgoing_call)
				return
			if(usr.loc == loc)
				var/list/callnames = list()
				for(var/I in holopads)
					var/area/A = get_area(I)
					if(A)
						LAZYADD(callnames[A], I)
				callnames -= get_area(src)
				var/result = tgui_input_list(usr, "Choose an area to call", "Holocall", sort_names(callnames))
				if(isnull(result))
					return
				if(QDELETED(usr) || outgoing_call)
					return
				if(usr.loc == loc)
					var/input = text2num(params["headcall"])
					var/headcall = input == 1 ? TRUE : FALSE
					var/datum/holocall/holo_call = new(usr, src, callnames[result], headcall)
					if(QDELETED(holo_call)) //can delete itself if the target pad was destroyed
						return FALSE
					calling = TRUE
					return TRUE
			else
				to_chat(usr, span_warning("You must stand on the holopad to make a call!"))

		if("connectcall")
			var/datum/holocall/call_to_connect = locate(params["holopad"]) in holo_calls
			if(!QDELETED(call_to_connect))
				call_to_connect.Answer(src)
				return TRUE

		if("disconnectcall")
			var/datum/holocall/call_to_disconnect = locate(params["holopad"]) in holo_calls
			if(!QDELETED(call_to_disconnect))
				call_to_disconnect.Disconnect(src)
				return TRUE

		if("rejectall")
			for(var/datum/holocall/call_to_reject as anything in holo_calls)
				if(call_to_reject.connected_holopad == src) // do not kill the current connection
					continue
				call_to_reject.Disconnect(src)
			return TRUE

		if("disk_eject")
			if(disk && !replay_mode)
				disk.forceMove(drop_location())
				return TRUE

		if("replay_mode")
			if(replay_mode)
				replay_stop()
				return TRUE
			else
				replay_start()
				return TRUE

		if("loop_mode")
			loop_mode = !loop_mode
			return TRUE

		if("record_mode")
			if(record_mode)
				record_stop()
				return TRUE
			else
				record_start(usr)
				return TRUE

		if("record_clear")
			record_clear()
			return TRUE

		if("offset")
			offset++
			if(offset > 4)
				offset = 0
			var/turf/new_turf
			if(!offset)
				new_turf = get_turf(src)
			else
				// GLOB.cardinals is ugly because it goes NSEW. NESW looks a lot prettier.
				var/static/list/direction_list = list(NORTH, EAST, SOUTH, WEST)
				new_turf = get_step(src, direction_list[offset])
			move_hologram(disk.record, new_turf)
			return TRUE

		if("hang_up")
			if(outgoing_call)
				outgoing_call.Disconnect(src)
				return TRUE

//setters
/**
 * setter for can_hear_flags. handles adding or removing the given flag on can_hear_flags and then adding hearing sensitivity or removing it depending on the final state
 * this is necessary because holopads are a significant fraction of the hearable atoms on station which increases the cost of procs that iterate through hearables
 * so we need holopads to not be hearable until it is needed
 *
 * * flag - one of the can_hear_flags flag defines
 * * set_flag - boolean, if TRUE sets can_hear_flags to that flag and might add hearing sensitivity if can_hear_flags was NONE before,
 * if FALSE unsets the flag and possibly removes hearing sensitivity
 */
/obj/machinery/holopad/proc/set_can_hear_flags(flag, set_flag = TRUE)
	if(!(flag & CAN_HEAR_ALL_FLAGS))
		return FALSE //the given flag doesnt exist

	if(set_flag)
		if(can_hear_flags == NONE)//we couldnt hear before, so become hearing sensitive
			become_hearing_sensitive()

		can_hear_flags |= flag
		return TRUE

	else
		can_hear_flags &= ~flag
		if(can_hear_flags == NONE)
			lose_hearing_sensitivity()

		return TRUE

///setter for adding/removing holocalls to this holopad. used to update the holo_calls list and can_hear_flags
///adds the given holocall if add_holocall is TRUE, removes if FALSE
/obj/machinery/holopad/proc/set_holocall(datum/holocall/holocall_to_update, add_holocall = TRUE)
	if(!istype(holocall_to_update))
		return FALSE

	if(add_holocall)
		set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS)
		LAZYADD(holo_calls, holocall_to_update)

	else
		LAZYREMOVE(holo_calls, holocall_to_update)
		if(!LAZYLEN(holo_calls))
			set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS, FALSE)

	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/**
 * hangup_all_calls: Disconnects all current holocalls from the holopad
 */
/obj/machinery/holopad/proc/hangup_all_calls()
	for(var/datum/holocall/holocall_to_disconnect as anything in holo_calls)
		holocall_to_disconnect.Disconnect(src)

//do not allow AIs to answer calls or people will use it to meta the AI sattelite
/obj/machinery/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!on_network)
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!LAZYLEN(masters) || !masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)

//this really should not be processing by default with how common holopads are
//everything in here can start processing if need be once first set and stop processing after being unset
/obj/machinery/holopad/process()
	if(LAZYLEN(masters)) //As someone in the original PR commented, the original code was indeed depressing
		if(replay_mode && !is_operational)
			replay_stop()
		for(var/datum/master as anything in masters)
			if(!is_operational || !validate_user(master))
				clear_holo(master)

	if(outgoing_call)
		outgoing_call.Check()

	var/are_ringing = FALSE

	for(var/datum/holocall/holocall as anything in holo_calls)
		if(holocall.connected_holopad == src)
			continue

		if(force_answer_call && world.time > (holocall.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2)))
			holocall.Answer(src)
			break
		if(holocall.head_call && !secure)
			holocall.Answer(src)
			break
		if(outgoing_call)
			holocall.Disconnect(src)//can't answer calls while calling
		else
			playsound(src, 'sound/machines/twobeep.ogg', 100) //bring, bring!
			are_ringing = TRUE

	if(ringing != are_ringing)
		ringing = are_ringing
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/holopad/proc/activate_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		AI = null

	if(is_operational && (!AI || AI.eyeobj.loc == loc))//If the projector has power and client eye is on it
		if(AI && istype(AI.current_holopad))
			to_chat(user, "[span_danger("ERROR:")] \black Image feed in progress.")
			return


		var/obj/effect/overlay/holo_pad_hologram/Hologram = new(loc)//Spawn a blank effect at the location.
		if(AI)
			Hologram.icon = AI.holo_icon
			Hologram.verb_say = AI.verb_say
			Hologram.verb_ask = AI.verb_ask
			Hologram.verb_exclaim = AI.verb_exclaim
			Hologram.verb_yell = AI.verb_yell
			Hologram.speech_span = AI.speech_span
		else //make it like real life
			Hologram.icon = user.icon
			Hologram.icon_state = user.icon_state
			Hologram.copy_overlays(user, TRUE)
			//codersprite some holo effects here
			Hologram.alpha = 100
			Hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
			Hologram.Impersonation = user

		Hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
		Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		Hologram.set_anchored(TRUE)//So space wind cannot drag it.
		Hologram.name = "[user.name] (Hologram)"//If someone decides to right click.
		Hologram.set_light(2)	//hologram lighting
		set_holo(user, Hologram)
		visible_message(span_notice("A holographic image of [user] flickers to life before your eyes!"))

		return Hologram
	else
		to_chat(user, "[span_danger("ERROR:")] Unable to project hologram.")

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/holopad/Hear(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	if(speaker && LAZYLEN(masters) && !radio_freq)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(masters[master] && speaker != master)
				master.relay_speech(speaker, message_language, raw_message, radio_freq, spans, message_mods)

	for(var/datum/holocall/holocall_to_update as anything in holo_calls)
		if(holocall_to_update.connected_holopad == src)//if we answered this call originating from another holopad
			if(speaker == holocall_to_update.hologram && holocall_to_update.user.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat))
				create_chat_message(speaker, message_language, list(holocall_to_update.user), raw_message, spans, message_mods)
			else
				var/mob/calling_mob = holocall_to_update.user
				if(calling_mob.client?.prefs?.read_preference(/datum/preference/toggle/enable_runechat))
					create_chat_message(speaker, message_language, list(calling_mob), raw_message, spans, message_mods)
				calling_mob.Hear(speaker, message_language, raw_message, radio_freq, spans, message_mods, message_range = INFINITY)

	if(outgoing_call && speaker == outgoing_call.user)
		var/list/extra_spans = spans?.Copy() || list()
		if(outgoing_call.spoofed)
			extra_spans |= "bold"
			extra_spans |= "danger"
		outgoing_call.hologram.say(raw_message, spans = extra_spans, sanitize = FALSE, language = message_language, message_mods = message_mods)

	if(record_mode && speaker == record_user)
		record_message(speaker, raw_message, message_language)

/obj/machinery/holopad/proc/SetLightsAndPower()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	update_use_power(total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE)
	update_mode_power_usage(ACTIVE_POWER_USE, initial(active_power_usage) + HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users))
	if(total_users || replay_mode)
		set_light(2)
	else
		set_light(0)
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/holopad/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
		return ..()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	var/has_spoofed_ringing = FALSE
	var/has_spoofed_active = FALSE
	for(var/datum/holocall/HC in holo_calls)
		if(!HC.spoofed)
			continue
		if(HC.connected_holopad == src)
			has_spoofed_active = TRUE
		else
			has_spoofed_ringing = TRUE
	if(ringing && has_spoofed_ringing)
		icon_state = "holopad_ringing2"
		return ..()
	if(has_spoofed_active)
		icon_state = "holopad2"
		return ..()
	if(ringing)
		icon_state = "[base_icon_state]_ringing"
		return ..()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
		return ..()
	icon_state = "[base_icon_state][(total_users || replay_mode) ? 1 : 0]"
	return ..()

/obj/machinery/holopad/proc/set_holo(datum/owner, obj/effect/overlay/holo_pad_hologram/h)
	LAZYSET(masters, owner, h)
	LAZYSET(holorays, owner, new /obj/effect/overlay/holoray(loc))
	set_can_hear_flags(CAN_HEAR_MASTERS)
	var/mob/living/silicon/ai/AI = owner
	if(istype(AI))
		AI.current_holopad = src
	SetLightsAndPower()
	update_holoray(owner, get_turf(loc))
	return TRUE

/obj/machinery/holopad/proc/clear_holo(datum/owner)
	qdel(masters[owner])
	unset_holo(owner)
	return TRUE

/**
 * Called by holocall to inform outgoing_call that the receiver picked up.
 */
/obj/machinery/holopad/proc/callee_picked_up()
	calling = FALSE
	set_can_hear_flags(CAN_HEAR_HOLOCALL_USER)

/**
 * Called by holocall to inform outgoing_call that the call is terminated.
 */
/obj/machinery/holopad/proc/callee_hung_up()
	set_can_hear_flags(CAN_HEAR_HOLOCALL_USER, set_flag = FALSE)
	calling = FALSE
	outgoing_call = null

/obj/machinery/holopad/proc/unset_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI) && AI.current_holopad == src)
		AI.current_holopad = null
	LAZYREMOVE(masters, user) // Discard AI from the list of those who use holopad
	if(!LAZYLEN(masters))
		set_can_hear_flags(CAN_HEAR_MASTERS, set_flag = FALSE)
	qdel(holorays[user])
	LAZYREMOVE(holorays, user)
	SetLightsAndPower()
	return TRUE

//Try to transfer hologram to another pad that can project on T
/obj/machinery/holopad/proc/transfer_to_nearby_pad(turf/T, datum/holo_owner)
	var/obj/effect/overlay/holo_pad_hologram/h = masters[holo_owner]
	if(!h || h.HC) //Holocalls can't change source.
		return FALSE
	for(var/obj/machinery/holopad/another as anything in holopads)
		if(another == src)
			continue
		if(another.validate_location(T))
			unset_holo(holo_owner)
			if(another.masters && another.masters[holo_owner])
				another.clear_holo(holo_owner)
			another.set_holo(holo_owner, h)
			return TRUE
	return FALSE

/obj/machinery/holopad/proc/validate_user(datum/owner)
	if(QDELETED(owner))
		return FALSE
	if(!isliving(owner))
		return TRUE
	var/mob/living/user = owner
	if(user.incapacitated || !user.client)
		return FALSE
	return TRUE

//Can we display holos there
//Area check instead of line of sight check because this is a called a lot if AI wants to move around.
/obj/machinery/holopad/proc/validate_location(turf/turf_to_check)
	return turf_to_check.get_virtual_z_level() == get_virtual_z_level() && get_dist(turf_to_check, src) <= holo_range && turf_to_check.loc == get_area(src)

/obj/machinery/holopad/proc/move_hologram(datum/owner, turf/new_turf)
	if(!LAZYLEN(masters) || !masters[owner])
		return TRUE
	var/obj/effect/overlay/holo_pad_hologram/holo = masters[owner]
	var/transfered = FALSE
	if(!validate_location(new_turf))
		if(!transfer_to_nearby_pad(new_turf, owner))
			clear_holo(owner)
			return FALSE
		else
			transfered = TRUE
	//All is good.
	holo.abstract_move(new_turf)
	if(!transfered)
		update_holoray(owner, new_turf)
	return TRUE

/obj/machinery/holopad/proc/update_holoray(datum/holo_owner, turf/new_turf)
	var/obj/effect/overlay/holo_pad_hologram/holo = masters[holo_owner]
	var/obj/effect/overlay/holoray/ray = holorays[holo_owner]
	var/disty = holo.y - ray.y
	var/distx = holo.x - ray.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M = matrix()
	if (get_dist(get_turf(holo),new_turf) <= 1)
		animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
	else
		ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)

	if(holo.HC?.spoofed)
		ray.add_atom_colour(COLOR_RED, FIXED_COLOUR_PRIORITY)
	else
		ray.remove_atom_colour(FIXED_COLOUR_PRIORITY)

// RECORDED MESSAGES

/obj/machinery/holopad/proc/setup_replay_holo(datum/holorecord/record)
	var/obj/effect/overlay/holo_pad_hologram/hologram = new(loc)//Spawn a blank effect at the location.
	hologram.add_overlay(record.caller_image)
	hologram.alpha = 170
	hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	hologram.dir = SOUTH //for now
	var/datum/language_holder/holder = hologram.get_language_holder()
	holder.selected_language = record.language
	hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	hologram.set_anchored(TRUE)//So space wind cannot drag it.
	hologram.name = "[record.caller_name] (Hologram)"//If someone decides to right click.
	hologram.set_light(2) //hologram lighting
	set_holo(record, hologram)
	visible_message(span_notice("A holographic image of [record.caller_name] flickers to life before your eyes!"))
	return hologram

/obj/machinery/holopad/proc/replay_start()
	if(!disk)
		say("Please insert the disc to play the recording.")
		return

	if(!disk.record)
		say("There is no record on the disc. Please check the disk.")
		return

	if(!replay_mode)
		replay_mode = TRUE
		replay_holo = setup_replay_holo(disk.record)
		SetLightsAndPower()
		replay_entry(1)

/obj/machinery/holopad/proc/replay_stop()
	if(!disk?.record || !replay_mode)
		return
	replay_mode = FALSE
	offset = 0
	clear_holo(disk.record)
	QDEL_NULL(replay_holo)
	SetLightsAndPower()
	ui_update()

/obj/machinery/holopad/proc/record_start(mob/living/user)
	if(!user || !disk || disk.record)
		return
	disk.record = new
	record_mode = TRUE
	set_can_hear_flags(CAN_HEAR_RECORD_MODE)
	record_start = world.time
	record_user = user
	disk.record.set_caller_image(user)

/obj/machinery/holopad/proc/record_message(mob/living/speaker,message,language)
	if(!record_mode)
		return
	//make this command so you can have multiple languages in single record
	if((!disk.record.caller_name || disk.record.caller_name == "Unknown") && istype(speaker))
		disk.record.caller_name = speaker.name
	if(!disk.record.language)
		disk.record.language = language
	else if(language != disk.record.language)
		disk.record.entries += list(list(HOLORECORD_LANGUAGE,language))

	var/current_delay = 0
	for(var/E in disk.record.entries)
		var/list/entry = E
		if(entry[1] != HOLORECORD_DELAY)
			continue
		current_delay += entry[2]

	var/time_delta = world.time - record_start - current_delay

	if(time_delta >= 1)
		disk.record.entries += list(list(HOLORECORD_DELAY,time_delta))
	disk.record.entries += list(list(HOLORECORD_SAY,message))
	if(disk.record.entries.len >= HOLORECORD_MAX_LENGTH)
		record_stop()

/obj/machinery/holopad/proc/replay_entry(entry_number)
	if(!replay_mode)
		return
	if(!anchored || !is_operational)
		record_stop()
		replay_stop()
		return
	if (!length(disk.record.entries)) // check for zero entries such as photographs and no text recordings
		return // and pretty much just display them statically untill manually stopped
	if(length(disk.record.entries) < entry_number)
		if(loop_mode)
			entry_number = 1
		else
			replay_stop()
			return
	var/list/entry = disk.record.entries[entry_number]
	var/command = entry[1]
	switch(command)
		if(HOLORECORD_SAY)
			var/message = entry[2]
			if(replay_holo)
				replay_holo.say(message)
		if(HOLORECORD_SOUND)
			playsound(src,entry[2],50,1)
		if(HOLORECORD_DELAY)
			addtimer(CALLBACK(src,PROC_REF(replay_entry),entry_number+1),entry[2])
			return
		if(HOLORECORD_LANGUAGE)
			var/datum/language_holder/holder = replay_holo.get_language_holder()
			holder.selected_language = entry[2]
		if(HOLORECORD_PRESET)
			var/preset_type = entry[2]
			var/datum/preset_holoimage/H = new preset_type
			replay_holo.cut_overlays()
			replay_holo.add_overlay(H.build_image())
		if(HOLORECORD_RENAME)
			replay_holo.name = entry[2] + " (Hologram)"
	.(entry_number+1)

/obj/machinery/holopad/proc/record_stop()
	if(record_mode)
		record_mode = FALSE
		record_user = null
		ui_update()
		set_can_hear_flags(CAN_HEAR_RECORD_MODE, FALSE)

/obj/machinery/holopad/proc/record_clear()
	if(disk?.record)
		QDEL_NULL(disk.record)
		ui_update()

/obj/effect/overlay/holo_pad_hologram
	initial_language_holder = /datum/language_holder/universal
	var/mob/living/Impersonation
	var/datum/holocall/HC

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(!QDELETED(HC))
		HC.Disconnect(HC.calling_holopad)
	HC = null
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
	return TRUE

/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()

/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32
	alpha = 100

#undef CAN_HEAR_MASTERS
#undef CAN_HEAR_ACTIVE_HOLOCALLS
#undef CAN_HEAR_RECORD_MODE
#undef CAN_HEAR_HOLOCALL_USER
#undef CAN_HEAR_ALL_FLAGS
#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
