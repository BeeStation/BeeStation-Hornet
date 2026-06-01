//From NSV13
//Credit to oraclestation for the idea! This just a recode...
// Recode CanAllowThrough() at some point, it won't allow ridden vehicles //no

/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to the brig."
	icon = 'icons/obj/machines/turnstile.dmi' //ADD ICON
	icon_state = "turnstile_map" //ADD ICON
	power_channel = AREA_USAGE_ENVIRON
	density = TRUE
	pass_flags_self = PASSTRANSPARENT | PASSGRILLE | PASSSTRUCTURE
	max_integrity = 600
	integrity_failure = 0.35
	//Robust! It'll be tough to break...
	armor_type = /datum/armor/machinery_turnstile
	anchored = TRUE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_BRIG, ACCESS_BRIGPHYS)
	//Cooldown so we don't shock a million times a second
	COOLDOWN_DECLARE(shock_cooldown)
	circuit = /obj/item/circuitboard/machine/turnstile
	var/state = TURNSTILE_SECURED


/datum/armor/machinery_turnstile
	melee = 50
	bullet = 20
	energy = 80
	bomb = 10
	bio = 100
	fire = 90
	acid = 50

/obj/item/circuitboard/machine/turnstile
	name = "Turnstile circuitboard"
	desc = "The circuit board for a turnstile machine."
	build_path = /obj/machinery/turnstile
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/rods = 12
	)

/obj/machinery/turnstile/examine(mob/user)
	. = ..()
	if(state == TURNSTILE_SECURED)
		. += span_notice("The turnstile panel is tightly <b>screwed</b> to the frame.")
	if(state == TURNSTILE_CIRCUIT_EXPOSED)
		. += span_notice("The turnstile circuitboard is exposed, you could <b>pry it</b> from the frame.")
	if(state == TURNSTILE_SHELL && anchored)
		. += span_notice("The turnstile frame is empty but firmly <b>wrenched</b> to the floor.")
	if(state == TURNSTILE_SHELL && !anchored)
		. += span_notice("The turnstile frame is empty and unsecured, ready to be sliced through <b>welding</b>.")

//Executive officer's line variant. For rule of cool.
/*/obj/machinery/turnstile/xo
	name = "\improper XO line turnstile"
	req_one_access = list(ACCESS_BRIG, ACCESS_HEADS)
*/

/obj/structure/closet/secure_closet/genpop
	name = "Prisoner locker"
	desc = "A locker used to store a prisoner's valuables, that they can collect at a later date."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	locked = FALSE
	var/registered_name = null
	var/assigned_id = null

/obj/structure/closet/secure_closet/genpop/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/I = W
		if(broken)
			to_chat(user, span_danger("It appears to be broken."))
			return
		if(!I || !I.registered_name)
			return
		//Sec officers can always open the lockers. Bypass the ID setting behaviour.
		//Buuut, if they're holding a prisoner ID, that takes priority.
		if(allowed(user) && !istype(I, /obj/item/card/id/prisoner))
			if(!registered_name)
				say("Invalid, please assign this locker to prisoners first before handling it!") // Prevents officers from "forgetting" to assign lockers to the prisoners they are handling.
				return
			else
				var/unassign = alert(user, "Do you want to unassign this locker?", "Prisoner locker", "Yes", "No")
				switch(unassign)
					if("Yes")
						var/obj/item/card/id/prisoner/P = assigned_id
						P.assigned_locker = null
						registered_name = null
						desc = initial(desc)
						locked = FALSE
						update_icon()
						playsound(src, 'sound/machines/ping.ogg', 50, 0)
					if("No")
						locked = FALSE
						update_icon()
				return
		//Handle setting a new ID.
		if(!registered_name)
			if(istype(I, /obj/item/card/id/prisoner)) //Don't claim the locker for a sec officer mind you...
				var/obj/item/card/id/prisoner/P = I
				if(P.assigned_locker)
					to_chat(user, span_notice("This ID card is already registered to a locker."))
					return
				P.assigned_locker = src
				assigned_id = I
				registered_name = I.registered_name
				desc = "A locker used to store a prisoner's valuables, that they can collect at a later date.\nCurrently assigned to: [I.registered_name]. Swipe a security officer ID to unassign it."
				say("Locker sealed. Assignee: [I.registered_name]")
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				locked = TRUE
				update_icon()
			else
				to_chat(user, span_danger("Invalid ID. Only prisoners and officers may use these lockers."))
			return
		//It's an ID, and is the correct registered name.
		if(istype(I) && (registered_name == I.registered_name))
			var/obj/item/card/id/prisoner/ID = I
			//Not a prisoner ID.
			if(!istype(ID))
				return
			if(ID.served_time < ID.sentence)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 80) //find another sound
				say("DANGER: PRISONER HAS NOT COMPLETED SENTENCE. AWAIT SENTENCE COMPLETION. COMPLIANCE IS IN YOUR BEST INTEREST.")
				return
			visible_message(span_warning("[user] slots [I] into [src]'s ID slot, freeing its contents!"))
			registered_name = null
			desc = initial(desc)
			locked = FALSE
			update_icon()
			qdel(I)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		else
			say("Access Denied. If you are a released prisoner, please insert your prisoner ID.")
			return
	else
		return ..()

/obj/structure/closet/secure_closet/genpop/AltClick(user)
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.get_idcard()
	if(!registered_name)
		if(allowed(user) && !istype(I, /obj/item/card/id/prisoner))
			say("Invalid, please assign this locker to prisoners first before handling it!") // Prevents officers from "forgetting" to assign lockers to the prisoners they are handling.
			return
	..()


/obj/machinery/turnstile/Initialize(mapload)
	. = ..()
	icon_state = "turnstile"
	//Attach a signal handler to the turf below for when someone passes through.
	//Signal automatically gets unattached and reattached when we're moved.
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/turnstile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!istype(arrived, /mob))
		return
	flick("operate", src)
	playsound(src,'sound/items/ratchet.ogg',50,0,3)
	if(arrived.pulledby) // don't do anything else for prisoners that are being escorted.
		return
	if(!istype(arrived, /mob/living/carbon/human)) //we only want to prevent prisoners from being able to reuse their ID card.
		return
	var/mob/living/carbon/human/H = arrived
	var/obj/item/card/id/id_card = H.get_idcard(hand_first = TRUE)
	if(ACCESS_PRISONER in id_card?.GetAccess())
		id_card.access -= list(ACCESS_PRISONER) //Prisoner IDs can only be used once to exit the turnstile
		to_chat(H, span_warning("Your prisoner ID access has been purged, you won't be able to exit the prison through the turnstile again!"))
		addtimer(CALLBACK(src, PROC_REF(exit_push), H), 2)

/obj/machinery/turnstile/proc/exit_push(atom/movable/pushed) //Just "pushes" prisoners that are being released out of the turnstile so that they don't trap themselves.
	var/our_turf = get_turf(src)
	var/pushed_turf = get_turf(pushed)
	if(our_turf == pushed_turf)
		var/movedir = turn(dir, 180) //Set to be the opposite of the turnstile dir, as that would always be the exit, unless the turnstile has been built incorrectly.
		pushed.Move(get_step(pushed, movedir), movedir)

///Handle movables (especially mobs) bumping into us.
/obj/machinery/turnstile/Bumped(atom/movable/movable)
	. = ..()
	if(!ismob(movable)) //Try to mimmick how airlocks act when bumped by items and the likes. Except when pulled (for crates and beds etc.)
		if(movable.pulledby)
			return
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return
	if(machine_stat & BROKEN) //try to shock mobs if we're broken
		try_shock(movable)
		return
	//pretend to be an airlock if a mob bumps us
	//(which means they tried to move through but didn't have access)
	flick("deny", src)
	playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)

///Shock attacker if we're broken
/obj/machinery/turnstile/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "turnstile", "turnstile", I))
		update_appearance()//add proper panel icons
		state = TURNSTILE_CIRCUIT_EXPOSED
		return
	if(I.tool_behaviour == TOOL_CROWBAR && panel_open && circuit != null)
		to_chat(user, span_notice("You start tearing out the circuitry..."))
		if(do_after(user, 3 SECONDS))
			I.play_tool_sound(src, 50)
			circuit.forceMove(loc)
			circuit = null
			state = TURNSTILE_SHELL
		return
	if(istype(I, /obj/item/circuitboard/machine/turnstile) && state == TURNSTILE_SHELL && anchored)
		to_chat(user, span_notice("You add the circuitboard to the frame."))
		circuit = new/obj/item/circuitboard/machine/turnstile(src)
		qdel(I)
		state = TURNSTILE_CIRCUIT_EXPOSED
		return
	if(I.tool_behaviour == TOOL_WRENCH && state == TURNSTILE_SHELL)
		if(anchored)
			to_chat(user, span_notice("You unanchor the turnstile frame..."))
			if(do_after(user, 3 SECONDS))
				I.play_tool_sound(src, 50)
				anchored = FALSE
			return
		if(!anchored)
			to_chat(user, span_notice("You start anchoring the turnstile frame..."))
			if(do_after(user, 3 SECONDS))
				I.play_tool_sound(src, 50)
				anchored = TRUE
			return
	. = ..()
	if(machine_stat & BROKEN)
		try_shock(user)

//Shock attack if something is thrown at it if we're broken
/obj/machinery/turnstile/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && (machine_stat & BROKEN))
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				playsound(src, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, 8000, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) // Around 20 damage for humans
	return ..()

/obj/machinery/turnstile/welder_act(mob/living/user, obj/item/I)
	//Shamelessly copied airlock code
	. = TRUE
	if(!I.tool_start_check(user, amount=0))
		return
	if(circuit == null && user.combat_mode)
		var/obj/item/weldingtool/W = I
		if(W.use_tool(src, user, 40, volume=50))
			to_chat(user, span_notice("You start slicing off the bars of the [src]"))
			new /obj/item/stack/rods/ten(get_turf(src))
			qdel(src)
			return

	if(atom_integrity >= max_integrity)
		to_chat(user, span_notice("The turnstile doesn't need repairing."))
		return
	user.visible_message("[user] is welding the turnstile.", \
				span_notice("You begin repairing the turnstile..."), \
				span_italics("You hear welding."))
	if(I.use_tool(src, user, 40, volume=50))
		atom_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		user.visible_message("[user.name] has repaired [src].", \
							span_notice("You finish repairing the turnstile."))
		update_icon()
		return

/obj/machinery/turnstile/CanAllowThrough(atom/movable/mover, turf/target)
	var/obj/item/card/id/id_card // used to check for prisoners trying to drag or piggyback others through the turnstile
	. = ..()
	if(. == TRUE)
		return TRUE //Allow certain things declared with pass_flags_self through wihout side effects
	if(machine_stat & BROKEN)
		return FALSE

	// Nerds get to go one way
	if(mover.dir == dir)
		// But only if they're actually facing the turnstile
		if(is_source_facing_target(mover, src))
			return TRUE

	// Call the default allowed functionality, handles:
	// - Mobs with security access
	// - Mobs with security access that are buckled to a vehicle
	// - Monkeys carrying ID cards
	// - Objects trying to pass through that have security access
	// This doesn't handle prisoner access
	if (ismob(mover) && allowed(mover))
		return TRUE
	// Allow us through if the thing pulling us is allowed through
	if(ismob(mover.pulledby) && allowed(mover.pulledby))
		return TRUE
	// From this point on, we are assuming that the mover is a living entity
	if (isliving(mover))
		// Block anyone if they are carrying someone
		if (length(mover.buckled_mobs))
			return FALSE
		// At this point, allow anyone with prisoner access on their direct ID card through
		// although reject anyone attempting to pass without prisoner access
		var/mob/living/living_prisoner = mover
		id_card = living_prisoner.get_idcard(hand_first = TRUE)
		if(ACCESS_PRISONER in id_card?.GetAccess())
			return TRUE
	// Handle the prisoner being in a wheelchair
	// check if someone riding on / buckled to them has access
	if (!length(mover.buckled_mobs))
		return FALSE
	// Reject the moving thing if anyone inside of the moving thing doesn't have access
	for(var/mob/living/buckled in mover.buckled_mobs)
		if(mover == buckled || buckled == mover) // just in case to prevent a possible infinite loop scenario (but it won't happen)
			continue
		id_card = buckled.get_idcard(hand_first = TRUE)
		// If we aren't allowed through normally and we don't have prisoner access, reject
		if (!allowed(buckled) && !(ACCESS_PRISONER in id_card?.GetAccess()))
			return FALSE
	return TRUE

///Shock user if we can
/obj/machinery/turnstile/proc/try_shock(mob/user)
	if(machine_stat & NOPOWER)		// unpowered, no shock
		return FALSE
	if(!COOLDOWN_FINISHED(src, shock_cooldown)) //Don't shock in very short succession to avoid stuff getting out of hand.
		return FALSE
	COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)
	do_sparks(5, TRUE, src)
	if(electrocute_mob(user, power_source = get_area(src), source = src, dist_check = TRUE))
		return TRUE
	else
		return FALSE

//Officer interface.
/obj/machinery/genpop_interface
	name = "Prisoner Management Interface"
	icon = 'icons/obj/machines/genpop_display.dmi'
	icon_state = "frame"
	desc = "An all-in-one interface for officers to manage prisoners!"
	req_access = list(ACCESS_BRIG)
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	var/time_to_screwdrive = 20
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone
	var/next_print = 0
	var/desired_name //What is their name?
	var/desired_details //Details of the crime
	var/obj/item/radio/Radio //needed to send messages to sec radio
	var/config_file = file("config/space_law.json")
	/// A list of all of the available crimes in a formated served to the user interface.
	var/static/list/crime_list
	var/crime_names = list()
	var/static/regex/valid_crime_name_regex = null

//Prisoner interface wallframe
/obj/item/wallframe/genpop_interface
	name = "\improper prisoner interface frame"
	desc = "Frame used to build the prisoner interface."
	icon = 'icons/obj/machines/genpop_display.dmi'
	icon_state = "frame"
	pixel_shift = 32
	result_path = /obj/machinery/genpop_interface

/obj/item/electronics/genpop_interface
	name = "prisoner interface circuitboard"
	icon_state = "power_mod"
	desc = "Central processing unit for the prisoner interface."

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/genpop_interface)

/obj/machinery/genpop_interface/Initialize(mapload, nbuild)
	. = ..()
	update_icon()

	if(nbuild)
		buildstage = 0
		panel_open = TRUE

	if (!crime_list || !valid_crime_name_regex)
		build_static_information()

	Radio = new/obj/item/radio(src)
	Radio.set_listening(FALSE)
	Radio.set_frequency(FREQ_SECURITY)

/obj/machinery/genpop_interface/proc/build_static_information()
	// Generate the crime list
	try crime_list = json_decode(file2text(config_file))
	catch(var/exception/e)
		message_admins(span_boldannounce("[e] caught on [e.file]:[e.line]."))
		load_default_crimelist()
		return
	//we need to get the names of each crime for the regex
	for(var/key in crime_list)
		var/value = crime_list[key]
		for(var/second_key in value)
			var/second_value = second_key["name"]
			LAZYADD(crime_names, second_value)

	if (valid_crime_name_regex)
		return

	// Form the valid crime regex
	var/regex_string = "^(Attempted )?([jointext(crime_names, "|")])( \\(Repeat offender\\))?$"
	valid_crime_name_regex = regex(regex_string, "gm")

/obj/machinery/genpop_interface/proc/load_default_crimelist()
	crime_list = list()
	//Hardcoded crimes list from crimes.dm, not used unless the config file is missing somehow.
	message_admins(span_boldannounce("Failed to read the space_law config file! Defaulting to hardcoded datums.")) //Hardcoded crimes list from crimes.dm, not used unless the config file is missing somehow.
	for (var/datum/crime/crime_path as() in subtypesof(/datum/crime))
		// Ignore this crime, it is abstract
		if (isnull(initial(crime_path.name)))
			continue
		// We need to know about this crime for the regex
		crime_names += initial(crime_path.name)
		// Create the category if it is needed
		if (!islist(crime_list[initial(crime_path.category)]))
			crime_list[initial(crime_path.category)] = list()
		// Add crimes to that category
		crime_list[initial(crime_path.category)] += list(list(
			"name" = initial(crime_path.name),
			"tooltip" = initial(crime_path.tooltip),
			"colour" = initial(crime_path.colour),
			"icon" = initial(crime_path.icon),
			"sentence" = initial(crime_path.sentence),
			))
	var/regex_string = "^(Attempted )?([jointext(crime_names, "|")])( \\(Repeat offender\\))?$"
	valid_crime_name_regex = regex(regex_string, "gm")

/obj/machinery/genpop_interface/update_icon()
	if(buildstage< 2)
		icon_state = "frame"
		set_picture("ai_off")
		return

	if(panel_open)
		set_picture("ai_off")
		return

	if(machine_stat & (NOPOWER))
		icon_state = "frame"
		set_picture("ai_off")
		return

	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return
	set_picture("genpop")

/obj/machinery/genpop_interface/examine()
	. = ..()
	if(!panel_open)
		. += span_notice("The prisoner interface panel is <b>screwed</b> in safely.")
	if(panel_open && buildstage == 2)
		. += span_notice("The prisoner interface panel is open, the <b>wires</b> are exposed.\nThe interface cannot function with its panel <b>screwed open</b>.")
	if(buildstage == 1)
		. += span_notice("The circuits are visible and ready to be <b>pried</b> off.\nIt is lacking proper <b>wiring</b>")
	if(buildstage == 0)
		.+= span_notice("The empty frame is ready to be <b>wrenched</b> off the wall.\nIt is lacking a <b>circuitboard</b>.")

/obj/machinery/genpop_interface/attackby(obj/item/C, mob/user)
	switch(buildstage)
		if(0)
			if(istype(C, /obj/item/electronics/genpop_interface))
				if(user.temporarilyRemoveItemFromInventory(C))
					to_chat(user, span_notice("You insert the processing unit in the frame."))
					qdel(C)
					buildstage = 1
					return

			if(C.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You wrench the frame off the wall."))
				C.play_tool_sound(src)
				new /obj/item/wallframe/genpop_interface( user.loc )
				qdel(src)
				return
		if(1)
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = C
				if(cable.get_amount() < 5)
					to_chat(user, span_warning("You need five lengths of cable to wire the prisoner interface!"))
					return
				user.visible_message(span_notice("[user.name] wires the prisoner interface."), span_notice("You start wiring the prisoner interface."))
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						to_chat(user, span_notice("You wire the prisoner interface."))
						buildstage = 2
						update_icon()
				return

			if(C.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("You start prying out the electronics off the frame."))
				if (C.use_tool(src, user, 20))
					if (buildstage == 1)
						to_chat(user, span_notice("You remove the prisoner interface electronics."))
						new /obj/item/electronics/genpop_interface( src.loc )
						playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
						buildstage = 0
						update_icon()
				return
		if(2)
			if(C.tool_behaviour == TOOL_SCREWDRIVER)
				if(panel_open)
					to_chat(user, span_notice("You close the panel of the [src]."))
					C.play_tool_sound(src)
					panel_open = FALSE
					update_icon()
					return
				else
					to_chat(user, span_notice("You open the panel of the [src]."))
					C.play_tool_sound(src)
					panel_open = TRUE
					update_icon()
					return

			if(C.tool_behaviour == TOOL_WIRECUTTER && panel_open)
				C.play_tool_sound(src)
				to_chat(user, span_notice("You cut the wires."))
				new /obj/item/stack/cable_coil(loc, 5)
				buildstage = 1
				update_icon()
				return

	if(!istype(C, /obj/item/card/id))
		. = ..()
	else
		var/obj/item/card/id/I = C
		playsound(src, 'sound/machines/ping.ogg', 20)
		desired_name = I.registered_name

/obj/machinery/genpop_interface/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(mutable_appearance(icon, state))

/obj/machinery/genpop_interface/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/genpop_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GenPop")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/genpop_interface/ui_data(mob/user)
	var/list/data = list()
	data["allPrisoners"] = list()
	data["desired_name"] = desired_name
	data["desired_details"] = desired_details
	data["canPrint"] = world.time >= next_print
	var/list/L = data["allPrisoners"]
	for(var/obj/item/card/id/prisoner/ID in GLOB.prisoner_ids)
		var/list/id_info = list()
		id_info["name"] = ID.registered_name
		id_info["id"] = REF(ID)
		id_info["served_time"] = ID.served_time
		id_info["sentence"] = ID.sentence
		id_info["crime"] = ID.crime
		data["allPrisoners"][++L.len] = id_info
	return data

/// Send these in static data because  they will never change.
/obj/machinery/genpop_interface/ui_static_data(mob/user)
	var/list/data = list()
	// The global crime list
	data["crime_list"] = crime_list
	return data

/obj/machinery/genpop_interface/proc/print_id(mob/user, desired_crime, desired_sentence)

	if(world.time < next_print)
		to_chat(user, span_warning("[src]'s ID printer is on cooldown."))
		return FALSE
	investigate_log("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 600] for [desired_sentence / 600] min", INVESTIGATE_RECORDS)
	user.log_message("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 600] for [desired_sentence / 600] min", LOG_ATTACK)

	if(desired_crime)
		var/datum/record/crew/target_record = find_record(desired_name, GLOB.manifest.general)
		if(target_record)
			target_record.set_wanted_status(user, WANTED_PRISONER)
			var/datum/crime_record/new_crime = new(desired_crime, null, "General Populace")
			target_record.crimes += new_crime
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [target_record.name] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [target_record.name] successfully updated.")
			update_matching_security_huds(target_record.name)
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WANTED_STATUS_CHANGED, target_record, user, target_record.wanted_status)

	var/obj/item/card/id/id = new /obj/item/card/id/prisoner(get_turf(src), desired_sentence * 0.1, desired_crime, desired_name)
	Radio.talk_into(src, "Prisoner [id.registered_name] has been incarcerated for [desired_sentence / 600 ] minutes.")
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.add_raw_text("<h1 id='record-of-incarceration'>Record Of Incarceration:</h1> <hr> <h2 id='name'>Name: </h2> <p>[desired_name]</p> <h2 id='crime'>Crime: </h2> <p>[desired_crime]</p> <h2 id='sentence-min'>Sentence (Min)</h2> <p>[desired_sentence/600]</p> <h2 id='description'>Description </h2> <p>[desired_details]</p> <p>Nanotrasen Disciplinary council.</p>")
	paperwork.update_appearance()
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	next_print = world.time + 5 SECONDS
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PRISONER_REGISTERED, user, desired_name, desired_crime, desired_sentence)
	desired_name = null
	desired_details = null

/obj/machinery/genpop_interface/ui_act(action, params)
	if(buildstage != 2 & panel_open)
		return
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return
	switch(action)
		if("prisoner_name")
			// Encode the name and ensure it is saniticed for IC input
			var/prisoner_name = tgui_input_text(usr, "Input prisoner's name...", "Prisoner Name", desired_name, MAX_NAME_LEN)
			if(CHAT_FILTER_CHECK(prisoner_name)) // check for forbidden words
				to_chat(usr, span_warning("Your message contains forbidden words."))
				return FALSE
			if(!prisoner_name || (!Adjacent(usr) && !IsAdminGhost(usr)))
				return FALSE
			desired_name = prisoner_name
		if("edit_details")
			var/prisoner_details = tgui_input_text(usr, "Input details of the offense...", "Crime Details", desired_details)
			if (CHAT_FILTER_CHECK(prisoner_details)) // check for forbidden words
				to_chat(usr, span_warning("Your message contains forbidden words."))
				return FALSE
			if (!prisoner_details || (!Adjacent(usr) && !IsAdminGhost(usr)))
				return FALSE
			desired_details = prisoner_details
		if("print")
			if (!desired_name)
				return
			if (!desired_details)
				var/prisoner_details = tgui_input_text(usr, "Input details of the offense...", "Crime Details", desired_details)
				if (CHAT_FILTER_CHECK(prisoner_details)) // check for forbidden words
					to_chat(usr, span_warning("Your message contains forbidden words."))
					return FALSE
				if (!prisoner_details || (!Adjacent(usr) && !IsAdminGhost(usr)))
					say("Please provide a correct description of the incident that led to their charge.")
					return FALSE
				desired_details = prisoner_details
			var/desired_sentence = text2num(params["desired_sentence"])
			if (!desired_sentence)
				return
			var/desired_crime = params["desired_crime"]
			if (!valid_crime_name_regex.Find(desired_crime))
				log_href_exploit(usr, "Entered a desired crime which was not permitted by the desired crime regex.")
				return
			print_id(usr, desired_crime, desired_sentence)

		// For adjusting the time of pre-existing prisoners
		if("adjust_time")
			var/obj/item/card/id/prisoner/id = locate(params["id"]) in GLOB.prisoner_ids
			var/value = text2num(params["adjust"])
			if(!istype(id))
				return
			if(id.served_time >= id.sentence)
				say("Prisoner has already served their time! Please apply another charge to sentence them with!")
				return
			if(value && isnum(value))
				id.sentence = clamp(id.sentence + value , 0 , SENTENCE_MAX_TIMER)

		if("release")
			var/obj/item/card/id/prisoner/id = locate(params["id"]) in GLOB.prisoner_ids
			if(!istype(id))
				return
			if(alert("Are you sure you want to release [id.registered_name]", "Prisoner Release", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has been discharged.")
			investigate_log("[key_name(usr)] has early-released [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has early-released [id] ([id.loc])", LOG_ATTACK)
			id.served_time = id.sentence
		if("escaped")
			var/obj/item/card/id/prisoner/id = locate(params["id"]) in GLOB.prisoner_ids
			if(!istype(id))
				return
			if(alert("Do you want to reset the sentence of [id.registered_name]?", "Confirmation", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has had their serving time reset.")
			investigate_log("[key_name(usr)] has reset the timer of [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has reset the timer of [id] ([id.loc])", LOG_ATTACK)
			id.served_time = 0

GLOBAL_LIST_EMPTY(prisoner_ids)

/obj/item/card/id/prisoner //renamed existing prisonner id to id/gulag
	icon_state = "orange"
	inhand_icon_state = "orange-id"
	assignment = "convict"
	hud_state = JOB_HUD_PRISONER
	var/served_time = 0 //Seconds.
	var/sentence = 0 //'ard time innit.
	var/crime = null //What you in for mate?
	var/atom/assigned_locker = null //Where's our stuff then guv?

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/card/id/prisoner)

/obj/item/card/id/prisoner/Initialize(mapload, _sentence, _crime, _name)
	. = ..()
	GLOB.prisoner_ids += src
	if(_crime)
		crime = _crime
	if(_sentence)
		sentence = _sentence
		if(!_name)
			registered_name = "Prisoner WR-ROSETTA#[rand(0, 10000)]"
		else
			registered_name = _name
		update_label(registered_name, "Convict")
		START_PROCESSING(SSobj, src)

/obj/item/card/id/prisoner/Destroy()
	GLOB.prisoner_ids -= src
	. = ..()

/obj/item/card/id/prisoner/examine(mob/user)
	. = ..()
	if(sentence)
		. += span_notice("You have served [DisplayTimeText(served_time*10, 1)] out of [DisplayTimeText(sentence*10, 1)].")
	if(crime)
		. += span_warning("It appears its holder was convicted of: <b>[crime]</b>")

/obj/item/card/id/prisoner/process(delta_time)
	served_time += delta_time
	if(served_time >= sentence) //FREEDOM!
		assignment = "Ex-Convict"
		access = list(ACCESS_PRISONER)
		update_label(registered_name, assignment)
		playsound(loc, 'sound/machines/ping.ogg', 50, 1)

		var/datum/record/crew/R = find_record(registered_name, GLOB.manifest.general)
		if(R)
			R.set_wanted_status(src, WANTED_DISCHARGED)

		if(isliving(loc))
			to_chat(loc, span_boldnotice("You have served your sentence! You may now exit prison through the turnstiles and collect your belongings."))
		return PROCESS_KILL
