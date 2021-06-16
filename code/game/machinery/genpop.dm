//Credit to oraclestation for the idea! This just a recode...

/**

Genpop!
Idea by oraclestation, re-coded by Kmc2000 with sprites by Cdey.


*/

#define MAX_TIMER 10 HOURS //Permabrig.
#define PRESET_SHORT 2 MINUTES
#define PRESET_MEDIUM 3 MINUTES
#define PRESET_LONG 5 MINUTES

/**
A turnstile that allows one-way travel for people without ACCESS_PRISONER
*/

/obj/machinery/turnstile
	name = "turnstile"
	desc = "A mechanical door that permits one-way access to the brig."
	icon = 'icons/obj/objects.dmi'
	icon_state = "turnstile_map"
	power_channel = AREA_USAGE_ENVIRON
	density = TRUE
	obj_integrity = 250
	max_integrity = 250
	//Robust! It'll be tough to break...
	armor = list("melee" = 50, "bullet" = 20, "laser" = 0, "energy" = 80, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50, "stamina" = 0)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	//Seccies and brig phys may always pass, either way.
	req_one_access = list(ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_PRISONER)

//Executive officer's line variant. For rule of cool.
/obj/machinery/turnstile/hop
	name = "HOP line turnstile"
	req_one_access = list(ACCESS_BRIG, ACCESS_HEADS)

/obj/structure/closet/secure_closet/genpop
	name = "genpop locker"
	desc = "A locker to store a prisoner's valuables, that they can collect at a later date."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/registered_name = null

/obj/structure/closet/secure_closet/genpop/Initialize(mapload)
	. = ..()
	//Show that it's available.
	set_light(1,1,COLOR_GREEN)

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
				set_light(1,1,COLOR_RED)
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
				playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
				say("DANGER: PRISONER HAS NOT COMPLETED SENTENCE. AWAIT SENTENCE COMPLETION. COMPLIANCE IS IN YOUR BEST INTEREST.")
				return FALSE
			visible_message("<span class='warning'>[user] slots [I] into [src]'s ID slot, freeing its contents!</span>")
			registered_name = null
			desc = initial(desc)
			locked = FALSE
			update_icon()
			set_light(1,1,COLOR_GREEN)
			qdel(I)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()

/obj/machinery/turnstile/Initialize()
	. = ..()
	icon_state = "turnstile"

/obj/machinery/turnstile/CanAtmosPass(turf/T)
	return TRUE

/obj/machinery/turnstile/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(!isliving(mover))
		return TRUE
	var/allowed = allowed(mover)
	//Sec can drag you out unceremoniously.
	if(!allowed && mover.pulledby)
		allowed = allowed(mover.pulledby)
	if(get_dir(loc, target) == dir || allowed) //Make sure looking at appropriate border
		flick("operate", src)
		playsound(src,'sound/items/ratchet.ogg',50,0,3)
		return TRUE
	else
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		return FALSE

//Officer interface.
/obj/machinery/genpop_interface
	name = "Prisoner Management Interface"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "An all-in-one interface for officers to manage prisoners!"
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	circuit = /obj/item/circuitboard/machine/genpop_interface
	var/next_print = 0
	var/desired_sentence = 60 //What sentence do you want to give them?
	var/desired_crime = null //What is their crime?
	var/desired_name = null
	var/obj/item/radio/Radio //needed to send messages to sec radio
	//Preset crimes that you can set, without having to remember times
	var/static/list/crimes = list(
		list(name="Resisting Arrest", tooltip="Resisting Arrest.", colour="good",icon="car-crash",sentence="2"),
		list(name="Assault", tooltip="Grievous Bodily Harm.", colour="average",icon="first-aid",sentence="3"),
		list(name="Sabotage", tooltip="Sabotage (minor)",colour="average",icon="bomb",sentence="5"),
		list(name="Sedition", tooltip="Sedition (rebellion).", colour="average",icon="fist-raised",sentence="5"),
		list(name="EOC", tooltip="Enemy Of The Corp.", colour="bad",icon="gavel",sentence="[MAX_TIMER / 600]"),
		list(name="Murder", tooltip="Murder.", colour="bad",icon="hammer",sentence="[MAX_TIMER / 600]"),
		list(name="Grand Sabotage", tooltip="Grand Sabotage.", colour="bad",icon="bomb",sentence="[MAX_TIMER / 600]"),
		list(name="Mutiny", tooltip="Mutiny.", colour="bad",icon="skull-crossbones",sentence="[MAX_TIMER / 600]")
	)

/obj/item/circuitboard/machine/genpop_interface
	name = "Prisoner Management Interface (circuit)"
	build_path = /obj/machinery/genpop_interface

/obj/machinery/genpop_interface/Initialize()
	. = ..()
	update_icon()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0
	Radio.set_frequency(FREQ_SECURITY)

/obj/machinery/genpop_interface/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return

	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	set_picture("genpop")


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

/obj/machinery/genpop_interface/ui_data(mob/user)
	var/list/data = list()
	data["allPrisoners"] = list()
	data["desired_name"] = desired_name
	data["desired_crime"] = desired_crime
	data["sentence"] = desired_sentence
	data["canPrint"] = world.time >= next_print
	data["allCrimes"] = crimes
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

/obj/machinery/genpop_interface/proc/print_id(mob/user)

	if(world.time < next_print)
		to_chat(user, "<span class='warning'>[src]'s ID printer is on cooldown.</span>")
		return FALSE
	investigate_log("[key_name(user)] created a prisoner ID with sentence: [desired_sentence] for [desired_sentence] min", INVESTIGATE_RECORDS)
	user.log_message("[key_name(user)] created a prisoner ID with sentence: [desired_sentence] for [desired_sentence] min", LOG_ATTACK)

	if(desired_crime)
		var/datum/data/record/R = find_record("name", desired_name, GLOB.data_core.general)
		if(R)
			R.fields["criminal"] = "Incarcerated"
			var/crime = GLOB.data_core.createCrimeEntry(desired_crime, null, user.real_name, station_time_timestamp())
			GLOB.data_core.addCrime(R.fields["id"], crime)
			investigate_log("New Crime: <strong>[desired_crime]</strong> | Added to [R.fields["name"]] by [key_name(user)]", INVESTIGATE_RECORDS)
			say("Criminal record for [R.fields["name"]] successfully updated with inputted crime.")
			playsound(loc, 'sound/machines/ping.ogg', 50, 1)

	var/obj/item/card/id/id = new /obj/item/card/id/prisoner(get_turf(src), desired_sentence, desired_crime, desired_name)
	Radio.talk_into(src, "Prisoner [id.registered_name] has been incarcerated for [desired_sentence] minutes.", FREQ_SECURITY)
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.info = "<h1 id='record-of-incarceration'>Record Of Incarceration:</h1> <hr> <h2 id='name'>Name: </h2> <p>[desired_name]</p> <h2 id='crime'>Crime: </h2> <p>[desired_crime]</p> <h2 id='sentence-min'>Sentence (Min)</h2> <p>[desired_sentence/60]</p> <p>WhiteRapids Military Council, disciplinary authority</p>"
	desired_sentence = 60
	desired_crime = null
	desired_name = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	next_print = world.time + 20 SECONDS

/obj/machinery/genpop_interface/ui_act(action, params)
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value && isnum(value))
				desired_sentence += value
				desired_sentence = clamp(desired_sentence,0,MAX_TIMER)
		if("crime")
			var/crimes = stripped_input(usr, "Input prisoner's crimes...", "Crimes", desired_crime)
			if(crimes == null | !Adjacent(usr))
				return FALSE
			desired_crime = crimes
		if("prisoner_name")
			var/prisoner_name = stripped_input(usr, "Input prisoner's name...", "Crimes", desired_name)
			if(prisoner_name == null | !Adjacent(usr))
				return FALSE
			desired_name = prisoner_name
		if("print")
			print_id(usr)

		if("preset")
			var/preset = params["preset"]
			var/preset_time = 0
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
				if("medium")
					preset_time = PRESET_MEDIUM
				if("long")
					preset_time = PRESET_LONG
				if("perma")
					preset_time = MAX_TIMER

			desired_sentence = preset_time
			desired_sentence /= 10
		if("presetCrime")
			var/preset_time = text2num(params["preset"])
			var/preset_crime = params["crime"]
			desired_sentence = preset_time MINUTES
			desired_sentence /= 10
			desired_crime = preset_crime

		if("release")
			var/obj/item/card/id/prisoner/id = locate(params["id"])
			if(!istype(id))
				return
			if(alert("Are you sure you want to release [id.registered_name]", "Prisoner Release", "Yes", "No") != "Yes")
				return
			Radio.talk_into(src, "Prisoner [id.registered_name] has been discharged.", FREQ_SECURITY)
			investigate_log("[key_name(usr)] has early-released [id] ([id.loc])", INVESTIGATE_RECORDS)
			usr.log_message("[key_name(usr)] has early-released [id] ([id.loc])", LOG_ATTACK)
			id.served_time = id.sentence

GLOBAL_LIST_EMPTY(prisoner_ids)

/obj/item/card/id/prisoner
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
			registered_name = "Prisoner WR-DELPHIC#[rand(0, 10000)]"
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
		. += "<span class='notice'>You have served [served_time / 60] / [sentence  / 60] minutes.</span>"
	if(crime)
		. += "<span class='warning'>It appears its holder was convicted of: <b>[crime]</b></span>"

/obj/item/card/id/prisoner/process()
	served_time ++ //Maybe 2?

	if (served_time >= sentence) //FREEDOM!
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



#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
