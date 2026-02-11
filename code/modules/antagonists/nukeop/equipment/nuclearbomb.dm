GLOBAL_VAR_INIT(station_was_nuked, FALSE)
GLOBAL_VAR_INIT(nuke_off_station, 0)

#define ARM_ACTION_COOLDOWN (5 SECONDS)

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/timer_set = 90
	var/minimum_timer_set = 90
	var/maximum_timer_set = 3600

	var/numeric_input = ""
	var/ui_mode = NUKEUI_AWAIT_DISK

	var/timing = FALSE
	var/exploding = FALSE
	var/exploded = FALSE
	var/detonation_timer = null
	var/r_code = "ADMIN"
	var/yes_code = FALSE
	var/safety = TRUE
	var/obj/item/disk/nuclear/auth = null
	use_power = NO_POWER_USE
	var/previous_level = ""
	var/obj/item/nuke_core/core = null
	var/deconstruction_state = NUKESTATE_INTACT
	var/lights = ""
	var/interior = ""
	var/proper_bomb = TRUE //Please
	var/bomb_z_level = null
	var/obj/effect/countdown/nuclearbomb/countdown
	var/sound/countdown_music = null
	COOLDOWN_DECLARE(arm_cooldown)

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	countdown = new(src)
	GLOB.nuke_list += src
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_icon()
	AddElement(/datum/element/point_of_interest)
	previous_level = SSsecurity_level.get_current_level_as_text()

/obj/machinery/nuclearbomb/Destroy()
	safety = FALSE
	if(!exploding)
		// If we're not exploding, set the alert level back to normal
		set_safety()
	GLOB.nuke_list -= src
	QDEL_NULL(countdown)
	QDEL_NULL(core)
	. = ..()

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(exploding)
		to_chat(user, "It is in the process of exploding. Perhaps reviewing your affairs is in order.")
	if(timing)
		to_chat(user, "There are [get_time_left()] seconds until detonation.")

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = TRUE //stops it being moved

/obj/machinery/nuclearbomb/syndicate
	// actually the nuke op bomb is a stole nt bomb

/obj/machinery/nuclearbomb/syndicate/get_cinematic_type(off_station)
	switch(off_station)
		if(0)
			return CINEMATIC_NUKE_WIN
		if(1)
			return CINEMATIC_NUKE_MISS
		if(2)
			return CINEMATIC_NUKE_FAR
	return CINEMATIC_NUKE_FAR

/obj/machinery/nuclearbomb/proc/disk_check(obj/item/disk/nuclear/D)
	if(D.fake)
		say("Authentication failure; disk not recognised.")
		return FALSE
	else
		return TRUE

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/disk/nuclear))
		if(!disk_check(I))
			return
		if(!user.transferItemToLoc(I, src))
			return
		auth = I
		update_ui_mode()
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		add_fingerprint(user)
		ui_update()
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/screwdriver/nuke))
				to_chat(user, span_notice("You start removing [src]'s front panel's screws..."))
				if(I.use_tool(src, user, 60, volume=100))
					deconstruction_state = NUKESTATE_UNSCREWED
					to_chat(user, span_notice("You remove the screws from [src]'s front panel."))
					update_icon()
				return

		if(NUKESTATE_PANEL_REMOVED)
			if(I.tool_behaviour == TOOL_WELDER)
				if(!I.tool_start_check(user, amount=1))
					return
				to_chat(user, span_notice("You start cutting [src]'s inner plate..."))
				if(I.use_tool(src, user, 80, volume=100, amount=1))
					to_chat(user, span_notice("You cut [src]'s inner plate."))
					deconstruction_state = NUKESTATE_WELDED
					update_icon()
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				to_chat(user, span_notice("You start loading the plutonium core into [core_box]..."))
				if(do_after(user, 5 SECONDS, target = src, hidden = TRUE))
					if(core_box.load(core, user))
						to_chat(user, span_notice("You load the plutonium core into [core_box]."))
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_icon()
						core = null
					else
						to_chat(user, span_warning("You fail to load the plutonium core into [core_box]. [core_box] has already been used!"))
				return
			if(istype(I, /obj/item/stack/sheet/iron))
				if(!I.tool_start_check(user, amount=20))
					return

				to_chat(user, span_notice("You begin repairing [src]'s inner metal plate..."))
				if(I.use_tool(src, user, 100, amount=20))
					to_chat(user, span_notice("You repair [src]'s inner metal plate. The radiation is contained."))
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					STOP_PROCESSING(SSobj, core)
					update_icon()
				return
	. = ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			to_chat(user, span_notice("You start removing [src]'s front panel..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You remove [src]'s front panel."))
				deconstruction_state = NUKESTATE_PANEL_REMOVED
				update_icon()
			return TRUE
		if(NUKESTATE_WELDED)
			to_chat(user, span_notice("You start prying off [src]'s inner plate..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You pry off [src]'s inner plate. You can see the core's green glow!"))
				deconstruction_state = NUKESTATE_CORE_EXPOSED
				update_icon()
				START_PROCESSING(SSobj, core)
			return TRUE

/obj/machinery/nuclearbomb/can_interact(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/ui_state(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return GLOB.conscious_state
	return ..()

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(exploding)
		return NUKE_ON_EXPLODING
	if(timing)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "nuclearbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "nuclearbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "nuclearbomb_exploding"
	else
		icon_state = "nuclearbomb_base"
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/proc/update_icon_interior()
	cut_overlay(interior)
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			interior = "panel-unscrewed"
		if(NUKESTATE_PANEL_REMOVED)
			interior = "panel-removed"
		if(NUKESTATE_WELDED)
			interior = "plate-welded"
		if(NUKESTATE_CORE_EXPOSED)
			interior = "plate-removed"
		if(NUKESTATE_CORE_REMOVED)
			interior = "core-removed"
		if(NUKESTATE_INTACT)
			return
	add_overlay(interior)

/obj/machinery/nuclearbomb/proc/update_icon_lights()
	if(lights)
		cut_overlay(lights)
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = ""
			return
		if(NUKE_OFF_UNLOCKED)
			lights = "lights-safety"
		if(NUKE_ON_TIMING)
			lights = "lights-timing"
		if(NUKE_ON_EXPLODING)
			lights = "lights-exploding"
	add_overlay(lights)

/obj/machinery/nuclearbomb/process()
	if(timing && !exploding)
		if(detonation_timer < world.time)
			explode()
		else
			var/volume = (get_time_left() <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, FALSE)

/obj/machinery/nuclearbomb/proc/update_ui_mode()
	if(exploded)
		ui_mode = NUKEUI_EXPLODED
		return

	if(!auth)
		ui_mode = NUKEUI_AWAIT_DISK
		return

	if(timing)
		ui_mode = NUKEUI_TIMING
		return

	if(!safety)
		ui_mode = NUKEUI_AWAIT_ARM
		return

	if(!yes_code)
		ui_mode = NUKEUI_AWAIT_CODE
		return

	ui_mode = NUKEUI_AWAIT_TIMER

/obj/machinery/nuclearbomb/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(timing)
		. = TRUE // Autoupdate while counting down

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui=null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb")
		ui.open()

/obj/machinery/nuclearbomb/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth

	var/hidden_code = (ui_mode == NUKEUI_AWAIT_CODE && numeric_input != "ERROR")

	var/current_code = ""
	if(hidden_code)
		while(length(current_code) < length(numeric_input))
			current_code = "[current_code]*"
	else
		current_code = numeric_input
	while(length(current_code) < 5)
		current_code = "[current_code]-"

	var/first_status
	var/second_status
	switch(ui_mode)
		if(NUKEUI_AWAIT_DISK)
			first_status = "DEVICE LOCKED"
			if(timing)
				second_status = "TIME: [get_time_left()]"
			else
				second_status = "AWAIT DISK"
		if(NUKEUI_AWAIT_CODE)
			first_status = "INPUT CODE"
			second_status = "CODE: [current_code]"
		if(NUKEUI_AWAIT_TIMER)
			first_status = "INPUT TIME"
			second_status = "TIME: [current_code]"
		if(NUKEUI_AWAIT_ARM)
			first_status = "DEVICE READY"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_TIMING)
			first_status = "DEVICE ARMED"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_EXPLODED)
			first_status = "DEVICE DEPLOYED"
			second_status = "THANK YOU"

	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	if(..())
		return
	playsound(src, "terminal_type", 20, FALSE)
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
					playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					auth = I
					. = TRUE
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("C")
						if(auth && ui_mode == NUKEUI_AWAIT_ARM)
							set_safety()
							yes_code = FALSE
							playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
						else
							playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
						numeric_input = ""
						. = TRUE
					if("E")
						switch(ui_mode)
							if(NUKEUI_AWAIT_CODE)
								if(numeric_input == r_code)
									numeric_input = ""
									yes_code = TRUE
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									. = TRUE
								else
									playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
									numeric_input = "ERROR"
							if(NUKEUI_AWAIT_TIMER)
								var/number_value = text2num(numeric_input)
								if(number_value)
									timer_set = clamp(number_value, minimum_timer_set, maximum_timer_set)
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									set_safety()
									. = TRUE
							else
								playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
					if("0","1","2","3","4","5","6","7","8","9")
						if(numeric_input != "ERROR")
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							else
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
							. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("arm")
			if(auth && yes_code && !safety && !exploded)
				if(!COOLDOWN_FINISHED(src, arm_cooldown))
					return
				playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
				set_active()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("anchor")
			if(auth && yes_code)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				set_anchor()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)

	if(.)
		update_ui_mode()

/obj/machinery/nuclearbomb/proc/set_anchor()
	if(isinspace() && !anchored)
		to_chat(usr, span_warning("There is nothing to anchor to!"))
	else
		set_anchored(!anchored)

/obj/machinery/nuclearbomb/proc/set_safety()
	safety = !safety
	if(safety)
		if(timing)
			SSsecurity_level.set_level(previous_level)
			stop_soundtrack_music(stop_playing = TRUE)
			for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
				S.switch_mode_to(initial(S.mode))
				S.alert = FALSE
		timing = FALSE
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/proc/set_active()
	if(safety)
		to_chat(usr, span_danger("The safety is still on."))
		return
	timing = !timing
	if(timing)
		previous_level = SSsecurity_level.get_current_level_as_number()
		detonation_timer = world.time + (timer_set * 10)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(TRACK_INFILTRATOR)
		countdown.start()
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)

		if(proper_bomb) // Why does this exist
			countdown_music = play_soundtrack_music(/datum/soundtrack_song/bee/countdown)
	else
		detonation_timer = null
		SSsecurity_level.set_level(previous_level)
		stop_soundtrack_music(stop_playing = TRUE)

		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(initial(S.mode))
			S.alert = FALSE
		countdown.stop()
	COOLDOWN_START(src, arm_cooldown, ARM_ACTION_COOLDOWN)
	update_icon()

/obj/machinery/nuclearbomb/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(exploding)
		return
	qdel(src)

/obj/machinery/nuclearbomb/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 127
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_icon()
	if(proper_bomb)
		sound_to_playing_players('sound/machines/alarm.ogg')
	if(SSticker.HasRoundStarted())
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, PROC_REF(actually_explode)), 100)

/obj/machinery/nuclearbomb/proc/actually_explode()
	if(!core)
		Cinematic(CINEMATIC_NUKE_NO_CORE,world)
		SSticker.roundend_check_paused = FALSE
		return

	GLOB.enter_allowed = FALSE

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	var/area/A = get_area(bomb_location)

	if(bomb_location && is_station_level(bomb_location.z))
		if(istype(A, /area/space))
			off_station = NUKE_NEAR_MISS
		if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = NUKE_NEAR_MISS
	else if(bomb_location.onSyndieBase())
		off_station = NUKE_SYNDICATE_BASE
	else
		off_station = NUKE_MISS_STATION

	bomb_z_level = get_virtual_z_level() // store for really_actually_explode (src loc gets lost in callback) and hope this is not null

	if(off_station < 2)
		SSshuttle.registerHostileEnvironment(src)
		SSshuttle.lockdown = TRUE

	//Cinematic
	GLOB.nuke_off_station = off_station
	if(off_station < NUKE_MISS_STATION)
		GLOB.station_was_nuked = TRUE
	really_actually_explode(off_station)
	SSticker.roundend_check_paused = FALSE

/obj/machinery/nuclearbomb/proc/really_actually_explode(off_station)
	Cinematic(get_cinematic_type(off_station),world)
	ASSERT(!isnull(bomb_z_level), "/obj/machinery/nuclearbomb/really_actually_explode() was called without a z level!")
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(kill_everyone_on_z_group), bomb_z_level)
	qdel(src)

/obj/machinery/nuclearbomb/proc/get_cinematic_type(off_station)
	if(off_station < 2)
		return CINEMATIC_SELFDESTRUCT
	else
		return CINEMATIC_SELFDESTRUCT_MISS

/obj/machinery/nuclearbomb/beer
	name = "\improper Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	var/obj/structure/reagent_dispensers/beerkeg/keg

/obj/machinery/nuclearbomb/beer/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)

/obj/machinery/nuclearbomb/beer/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		to_chat(user, span_notice("It has [keg.reagents.total_volume] unit\s left."))
	else
		to_chat(user, span_danger("It's empty."))

/obj/machinery/nuclearbomb/beer/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		W.afterattack(keg, user, TRUE) 	// redirect refillable containers to the keg, allowing them to be filled
		return TRUE 										// pretend we handled the attack, too.
	if(istype(W, /obj/item/nuke_core_container))
		to_chat(user, span_notice("[src] has had its plutonium core removed as a part of being decommissioned."))
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm()
		return
	if(is_station_level(bomb_location.z))
		var/datum/round_event_control/beer_clog/beer_event = new()
		beer_event.runEvent()
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 110)
	else
		visible_message(span_notice("[src] fizzes ominously."))
		addtimer(CALLBACK(src, PROC_REF(fizzbuzz)), 110)

/obj/machinery/nuclearbomb/beer/proc/disarm()
	detonation_timer = null
	exploding = FALSE
	exploded = TRUE
	SSsecurity_level.set_level(previous_level)
	for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
		S.switch_mode_to(initial(S.mode))
		S.alert = FALSE
	countdown.stop()
	update_icon()
	update_ui_mode()
	ui_update()

/obj/machinery/nuclearbomb/beer/proc/fizzbuzz()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(200, get_turf(src), R)
	foam.start()
	disarm()

/obj/machinery/nuclearbomb/beer/really_actually_explode()
	disarm()

/proc/kill_everyone_on_z_group(zGroup)
	// take in a z level as a number, and kill everyone on the same 'z orbital map' or z group
	if(!zGroup)
		return
	for(var/mob/living/M in GLOB.alive_mob_list)
		if (compare_z(M.get_virtual_z_level(), zGroup)) // check whether the mob is on the same z orbital map as the input level (as in multi-z stations etc)
			if(M.stat != DEAD && !istype(M.loc, /obj/structure/closet/secure_closet/freezer))
				to_chat(M, span_userdanger("You are shredded to atoms!"))
				M.investigate_log("has been gibbed by a nuclear blast.", INVESTIGATE_DEATHS)
				M.gib()

/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/set_anchor()
	return

/obj/machinery/nuclearbomb/selfdestruct/set_active()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

/obj/machinery/nuclearbomb/selfdestruct/set_safety()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

/obj/machinery/nuclearbomb/syndicate/bananium
	name = "bananium fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "bananiumbomb_base"

/obj/machinery/nuclearbomb/syndicate/bananium/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "bananiumbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "bananiumbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "bananiumbomb_exploding"
	else
		icon_state = "bananiumbomb_base"
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/syndicate/bananium/get_cinematic_type(off_station)
	switch(off_station)
		if(0)
			return CINEMATIC_NUKE_CLOWNOP
		if(1)
			return CINEMATIC_NUKE_MISS
		if(2)
			return CINEMATIC_NUKE_FAKE //it is farther away, so just a bikehorn instead of an airhorn
	return CINEMATIC_NUKE_FAKE

/obj/machinery/nuclearbomb/syndicate/bananium/really_actually_explode(off_station)
	Cinematic(get_cinematic_type(off_station), world)
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		var/turf/T = get_turf(H)
		if(!T || T.get_virtual_z_level() != get_virtual_z_level())
			continue
		H.Stun(10)
		var/obj/item/clothing/C
		if(!H.w_uniform || H.dropItemToGround(H.w_uniform))
			C = new /obj/item/clothing/under/rank/civilian/clown(H)
			ADD_TRAIT(C, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_ICLOTHING)

		if(!H.shoes || H.dropItemToGround(H.shoes))
			C = new /obj/item/clothing/shoes/clown_shoes(H)
			ADD_TRAIT(C, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_FEET)

		if(!H.wear_mask || H.dropItemToGround(H.wear_mask))
			C = new /obj/item/clothing/mask/gas/clown_hat(H)
			ADD_TRAIT(C, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
			H.equip_to_slot_or_del(C, ITEM_SLOT_MASK)

		H.dna.add_mutation(/datum/mutation/clumsy)
		H.gain_trauma(/datum/brain_trauma/mild/phobia/clowns, TRAUMA_RESILIENCE_LOBOTOMY) //MWA HA HA

#undef ARM_ACTION_COOLDOWN
#undef NUKERANGE
