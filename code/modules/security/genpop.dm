//From NSV13
//Credit to oraclestation for the idea! This just a recode...
// Recode CanAllowThrough() and machine_stat

/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to the brig."
	icon = 'icons/obj/machines/turnstile.dmi' //ADD ICON
	icon_state = "turnstile_map" //ADD ICON
	power_channel = AREA_USAGE_ENVIRON
	density = TRUE
	pass_flags_self = PASSTRANSPARENT | PASSGRILLE | PASSSTRUCTURE
	obj_integrity = 250
	max_integrity = 250
	integrity_failure = 74
	//Robust! It'll be tough to break...
	armor = list("melee" = 50, "bullet" = 20, "laser" = 0, "energy" = 80, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50, "stamina" = 0)
	anchored = TRUE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_PRISONER)
	//Cooldown so we don't shock a million times a second
	COOLDOWN_DECLARE(shock_cooldown)
	circuit = /obj/item/circuitboard/machine/turnstile
	var/state = TURNSTILE_SECURED

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
		. += "<span class='notice'>The turnstile panel is tightly <b>screwed</b> to the frame.</span>"
	if(state == TURNSTILE_CIRCUIT_EXPOSED)
		. += "<span class='notice'>The turnstile circuitboard is exposed, you could <b>pry it</b> from the frame.</span>"
	if(state == TURNSTILE_SHELL)
		. += "<span class='notice'>The turnstile frame is empty, ready to be sliced apart through <b>welding</b>.</span>"

//Executive officer's line variant. For rule of cool.
/*/obj/machinery/turnstile/xo
	name = "\improper XO line turnstile"
	req_one_access = list(ACCESS_BRIG, ACCESS_HEADS)
*/

/obj/structure/closet/secure_closet/genpop
	name = "Prisoner locker"
	desc = "A locker to store a prisoner's valuables, that they can collect at a later date."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	locked = FALSE
	var/registered_name = null

/obj/structure/closet/secure_closet/genpop/Initialize(mapload)
	. = ..()

/obj/structure/closet/secure_closet/genpop/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = null
	if(istype(W, /obj/item/card/id))
		I = W
	else
		I = W.GetID()
	if(istype(I))
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(!I || !I.registered_name)
			return
		//Sec officers can always open the lockers. Bypass the ID setting behaviour.
		//Buuut, if they're holding a prisoner ID, that takes priority.
		if(allowed(user) && !istype(I, /obj/item/card/id/prisoner))
			locked = !locked
			update_icon()
			return TRUE
		//Handle setting a new ID.
		if(!registered_name)
			if(istype(I, /obj/item/card/id/prisoner)) //Don't claim the locker for a sec officer mind you...
				var/obj/item/card/id/prisoner/P = I
				if(P.assigned_locker)
					to_chat(user, "<span class='notice'>This ID card is already registered to a locker.</span>")
					return FALSE
				P.assigned_locker = src
				registered_name = I.registered_name
				desc = "Assigned to: [I.registered_name]."
				say("Locker sealed. Assignee: [I.registered_name]")

				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				locked = TRUE
				update_icon()
			else
				to_chat(user, "<span class='danger'>Invalid ID. Only prisoners / officers may use these lockers.</span>")
			return FALSE
		//It's an ID, and is the correct registered name.
		if(istype(I) && (registered_name == I.registered_name))
			var/obj/item/card/id/prisoner/ID = I
			//Not a prisoner ID.
			if(!istype(ID))
				return FALSE
			if(ID.served_time < ID.sentence)
				playsound(loc, 'sound/machines/buzz-sigh.ogg', 80) //find another sound
				say("DANGER: PRISONER HAS NOT COMPLETED SENTENCE. AWAIT SENTENCE COMPLETION. COMPLIANCE IS IN YOUR BEST INTEREST.")
				return FALSE
			visible_message("<span class='warning'>[user] slots [I] into [src]'s ID slot, freeing its contents!</span>")
			registered_name = null
			desc = initial(desc)
			locked = FALSE
			update_icon()
			qdel(I)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()


/obj/machinery/turnstile/Initialize(mapload)
	. = ..()
	icon_state = "turnstile"
	//Attach a signal handler to the turf below for when someone passes through.
	//Signal automatically gets unattached and reattached when we're moved.
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/turnstile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(arrived, /mob))
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)

///Handle movables (especially mobs) bumping into us.
/obj/machinery/turnstile/Bumped(atom/movable/movable)
	. = ..()
	if(!istype(movable, /mob)) //just let non-mobs bump
		return
	if(machine_stat & BROKEN) //try to shock mobs if we're broken
		try_shock(movable)
		return
	//pretend to be an airlock if a mob bumps us
	//(which means they tried to move through but didn't have access)
	flick("deny", src)
	playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)

///Shock attacker if we're broken
/obj/machinery/turnstile/attackby(obj/item/item, mob/user, params)
	if(default_deconstruction_screwdriver(user, "turnstile", "turnstile", item))
		update_appearance()//add proper panel icons
		state = TURNSTILE_CIRCUIT_EXPOSED
		return
	if(item.tool_behaviour == TOOL_CROWBAR && panel_open && circuit != null)
		to_chat(user, "<span class='notice'>You start tearing out the circuitry...")
		if(do_after(user, 3 SECONDS))
			circuit.forceMove(loc)
			circuit = null
			state = TURNSTILE_SHELL
		return
	. = ..()
	if(machine_stat & BROKEN)
		try_shock(user)

//Shock attack if something is thrown at it if we're broken
/obj/machinery/turnstile/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && BROKEN)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				playsound(src, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, 8000, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN | TESLA_ALLOW_DUPLICATES) // Around 20 damage for humans
	return ..()

/obj/machinery/turnstile/welder_act(mob/living/user, obj/item/I)
	//Shamelessly copied airlock code
	. = TRUE
	if(circuit == null && user.a_intent == INTENT_HARM)
		var/obj/item/weldingtool/W = I
		if(W.welding)
			if(W.use_tool(src, user, 40, volume=50))
				to_chat(user, "<span class='notice'>You start slicing off the bars of the [src]")
				new /obj/item/stack/rods/ten(get_turf(src))
				qdel(src)
	if(!I.tool_start_check(user, amount=0))
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>The turnstile doesn't need repairing.</span>")
		return
	user.visible_message("[user] is welding the turnstile.", \
				"<span class='notice'>You begin repairing the turnstile...</span>", \
				"<span class='italics'>You hear welding.</span>")
	if(I.use_tool(src, user, 40, volume=50))
		obj_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		user.visible_message("[user.name] has repaired [src].", \
							"<span class='notice'>You finish repairing the turnstile.</span>")
		update_icon()
		return

/obj/machinery/turnstile/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(. == TRUE)
		return TRUE //Allow certain things declared with pass_flags_self through wihout side effects
	if(machine_stat & BROKEN)
		return FALSE
	if(get_dir(loc, target) == dir) //Always let people through in one direction. Not used at the moment.
		return TRUE
	var/allowed = allowed(mover)
	//Everyone with access can drag you out. Prisoners can't drag each other out.
	if(istype(mover, /obj/vehicle/ridden) && mover.buckled_mobs)
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50)
		say("ERROR. For security reasons, wheelchairs and other ridden devices are not allowed through the turnstile.")
		return FALSE
	if(!allowed && mover.pulledby && ishuman(mover.pulledby))
		var/mob/living/carbon/human/H = mover.pulledby
		if(istype(H.wear_id, /obj/item/card/id/prisoner) || istype(H.get_active_held_item(), /obj/item/card/id/prisoner))
			return FALSE
		else
			allowed = allowed(mover.pulledby)
	//Can't get piggyback rides out of jail (anticipated for gh#10205)
	if(!allowed && mover.buckled_mobs)
		var/mob/living/carbon/human/H = mover.buckled_mobs
		if(istype(H.wear_id, /obj/item/card/id/prisoner) || istype(H.get_active_held_item(), /obj/item/card/id/prisoner))
			return FALSE
		else
			allowed = allowed(mover.buckled_mobs)
	if(allowed)
		return TRUE
	return FALSE

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
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	circuit = /obj/item/circuitboard/machine/genpop_interface
	var/time_to_screwdrive = 20
	var/next_print = 0
	var/desired_name //What is their name?
	var/desired_details //Details of the crime
	var/obj/item/radio/Radio //needed to send messages to sec radio
	/// A list of all of the available crimes in a formated served to the user interface.
	var/static/list/crime_list
	var/static/regex/valid_crime_name_regex = null

/obj/item/circuitboard/machine/genpop_interface
	name = "Prisoner Management Interface (circuit)"
	build_path = /obj/machinery/genpop_interface

/obj/machinery/genpop_interface/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start to disconnect the monitor...</span>")
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user) //drops one station bounced radio out of thin air, not ideal but no easily implemented solution thus far.
	return TRUE

/obj/machinery/genpop_interface/Initialize(mapload)
	. = ..()
	update_icon()

	if (!crime_list || !valid_crime_name_regex)
		build_static_information()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0
	Radio.set_frequency(FREQ_SECURITY)

/obj/machinery/genpop_interface/proc/build_static_information()
	var/crime_names = list()

	// Generate the crime list
	if (!crime_list)
		crime_list = list()
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
				"tooltip" = initial(crime_path.tooltip),
				"colour" = initial(crime_path.colour),
				"icon" = initial(crime_path.icon),
				"sentence" = initial(crime_path.sentence),
			))

	if (valid_crime_name_regex)
		return

	// Form the valid crime regex
	var/regex_string = "^(Attempted )?([jointext(crime_names, "|")])( \\(Repeat offender\\))?$"
	valid_crime_name_regex = regex(regex_string, "gm")

/obj/machinery/genpop_interface/update_icon()
	if(machine_stat & (NOPOWER))
		icon_state = "frame"
		return

	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return
	set_picture("genpop")

/obj/machinery/genpop_interface/attackby(obj/item/C, mob/user)
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
		id_info["id"] = "\ref[ID]"
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
		to_chat(user, "<span class='warning'>[src]'s ID printer is on cooldown.</span>")
		return FALSE
	investigate_log("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 600] for [desired_sentence / 600] min", INVESTIGATE_RECORDS)
	user.log_message("[key_name(user)] created a prisoner ID with sentence: [desired_sentence / 600] for [desired_sentence / 600] min", LOG_ATTACK)

	if(desired_crime)
		var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.general)
		if(R)
			R.fields["criminal"] = "Incarcerated"
			var/crime = GLOB.data_core.createCrimeEntry(desired_crime, null, user.real_name, station_time_timestamp())
			GLOB.data_core.addCrime(R.fields["id"], crime)
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [R.fields["name"]] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [R.fields["name"]] successfully updated.")
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)

	var/obj/item/card/id/id = new /obj/item/card/id/prisoner(get_turf(src), desired_sentence * 0.1, desired_crime, desired_name)
	Radio.talk_into(src, "Prisoner [id.registered_name] has been incarcerated for [desired_sentence / 600 ] minutes.")
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.add_raw_text("<h1 id='record-of-incarceration'>Record Of Incarceration:</h1> <hr> <h2 id='name'>Name: </h2> <p>[desired_name]</p> <h2 id='crime'>Crime: </h2> <p>[desired_crime]</p> <h2 id='sentence-min'>Sentence (Min)</h2> <p>[desired_sentence/60]</p> <h2 id='description'>Description </h2> <p>[desired_details]</p> <p>WhiteRapids Military Council, disciplinary authority</p>")
	paperwork.update_appearance()
	desired_name = null
	desired_details = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	next_print = world.time + 5 SECONDS




/obj/machinery/genpop_interface/ui_act(action, params)
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("prisoner_name")
			// Encode the name and ensure it is saniticed for IC input
			var/prisoner_name = stripped_input(usr, "Input prisoner's name...", "Crimes", desired_name)
			prisoner_name = sanitize_name(prisoner_name)
			if(!prisoner_name || (!Adjacent(usr) && !IsAdminGhost(usr)))
				return FALSE
			var/prisoner_details = stripped_input(usr, "Input details of the offense...", "Crimes", desired_details)
			if (!prisoner_details || CHAT_FILTER_CHECK(prisoner_details) || (!Adjacent(usr) && !IsAdminGhost(usr)))
				return FALSE
			desired_details = prisoner_details
			desired_name = prisoner_name
			// Ask them for the details of the crime
		if("edit_details")
			var/prisoner_details = stripped_input(usr, "Input details of the offense...", "Crimes", desired_details)
			if (!prisoner_details || CHAT_FILTER_CHECK(prisoner_details) || (!Adjacent(usr) && !IsAdminGhost(usr)))
				return FALSE
			desired_details = prisoner_details
			// Ask them for the details of the crime
		if("print")
			if (!desired_name)
				return
			if (!desired_details)
				return
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
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			var/value = text2num(params["adjust"])
			if(!istype(id) || id.access == ACCESS_PRISONER) //check for prisonner access too
				return
			if(id.served_time >= id.sentence)
				say("Prisoner has already served their time! Please apply another charge to sentence them with!")
				return
			if(value && isnum(value))
				id.sentence += value
				id.sentence = clamp(id.sentence,0,MAX_TIMER)

		if("release")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			if(!istype(id))
				return
			if(alert("Are you sure you want to release [id.registered_name]", "Prisoner Release", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has been discharged.")
			investigate_log("[key_name(usr)] has early-released [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has early-released [id] ([id.loc])", LOG_ATTACK)
			id.served_time = id.sentence
		if("escaped")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
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
	item_state = "orange-id"
	assignment = "convict"
	hud_state = JOB_HUD_PRISONER
	var/served_time = 0 //Seconds.
	var/sentence = 0 //'ard time innit.
	var/crime = null //What you in for mate?
	var/atom/assigned_locker = null //Where's our stuff then guv?

/obj/item/card/id/prisoner/Initialize(mapload, _sentence, _crime, _name)
	. = ..()
	LAZYADD(GLOB.prisoner_ids, src)
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
	var/floortime = FLOOR(served_time / 60, 1)
	if(sentence)
		. += "<span class='notice'>You have served [floortime] / [sentence  / 60] minutes.</span>"
	if(crime)
		. += "<span class='warning'>It appears its holder was convicted of: <b>[crime]</b></span>"

/obj/item/card/id/prisoner/process()
	served_time ++ //Maybe 2?
	if(served_time >= sentence) //FREEDOM!
		assignment = "Ex-Convict"
		access = list(ACCESS_PRISONER)
		update_label(registered_name, assignment)
		playsound(loc, 'sound/machines/ping.ogg', 50, 1)

		var/datum/data/record/R = find_record("name", registered_name, GLOB.data_core.general)
		if(R)
			R.fields["criminal"] = "Discharged"

		if(isliving(loc))
			to_chat(loc, "<span class='boldnotice'>You have served your sentence! You may now exit prison through the turnstiles and collect your belongings.</span>")
		return PROCESS_KILL

#undef MAX_TIMER
