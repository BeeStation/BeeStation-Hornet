
// --------------------------
//
//  Fugitive Capture Chamber
//
// --------------------------

/obj/machinery/fugitive_capture
	name = "fugitive capture device"
	desc = "A bluespace chamber used for holding prisoners for transport."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	state_open = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/locked = FALSE
	var/message_cooldown
	var/breakout_time = 600

/obj/machinery/fugitive_capture/power_change()
	..()
	update_icon()

/obj/machinery/fugitive_capture/interact(mob/user)
	. = ..()
	if(locked)
		to_chat(user, "<span class='warning'>[src] is locked!</span>")
		return
	toggle_open(user)

/obj/machinery/fugitive_capture/updateUsrDialog()
	return

/obj/machinery/fugitive_capture/attackby(obj/item/I, mob/user)
	if(!occupant && default_deconstruction_screwdriver(user, "[icon_state]", "[icon_state]",I))
		update_icon()
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_pry_open(I))
		return

	return ..()

/obj/machinery/fugitive_capture/update_icon()
	icon_state = initial(icon_state) + (state_open ? "_open" : "")
	//no power or maintenance
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state += "_unpowered"
		if((machine_stat & MAINT) || panel_open)
			icon_state += "_maintenance"
		return

	if((machine_stat & MAINT) || panel_open)
		icon_state += "_maintenance"
		return

	//running and someone in there
	if(occupant)
		icon_state += "_occupied"
		return


/obj/machinery/fugitive_capture/relaymove(mob/user)
	if(user.stat != CONSCIOUS)
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()

/obj/machinery/fugitive_capture/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the door of [src]!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a metallic creaking from [src].</span>")
	if(do_after(user, breakout_time, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return
		locked = FALSE
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/fugitive_capture/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	if(state_open)
		close_machine()
		return
	if(!locked)
		open_machine()

// ---------------------------
//
//  Fugitive Capture Computer
//
// ---------------------------

/obj/machinery/computer/fugitive_capture_computer
	name = "fugitive capture device console"
	desc = "A bluespace control device designed to hold prisoners for transport."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_HUNTERS)
	light_color = LIGHT_COLOR_RED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/machinery/fugitive_capture/chamber

/obj/machinery/computer/fugitive_capture_computer/Initialize(mapload)
	. = ..()
	scan_machinery()

/obj/machinery/computer/fugitive_capture_computer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/fugitive_capture_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FugitiveCaptureConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/fugitive_capture_computer/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = istype(chamber)
	data["locked"] = chamber?.locked
	data["open"] = chamber?.state_open
	if(chamber && (chamber.occupant && ishuman(chamber.occupant)))
		var/mob/living/carbon/human/prisoner = chamber.occupant
		data["prisoner_valid"] = !!prisoner.mind?.has_antag_datum(/datum/antagonist/fugitive)
		data["prisoner_ref"] = REF(prisoner.mind)
	var/fugitives = list()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			continue
		var/list/entry = list()
		entry["name"] = A.owner.name
		entry["ref"] = "[REF(A.owner)]" // used as a unique ID for the UI
		entry["captured"] = A.is_captured
		entry["captured_living"] = A.living_on_capture
		if(A.owner.current)
			var/datum/orbital_object/orbital_body = SSorbits.assoc_z_levels["[A.owner.current.get_virtual_z_level()]"]
			entry["location"] = orbital_body.name
			entry["living"] = A.owner.current.stat != DEAD
		fugitives += list(entry)
	data["targets"] = fugitives
	return data

/obj/machinery/computer/fugitive_capture_computer/ui_act(action, list/params)
	if(..())
		return
	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return
	switch(action)
		if("scan")
			scan_machinery()
			return TRUE
		if("toggle_open")
			if(chamber.locked)
				to_chat(usr, "<span class='alert'>The chamber must be unlocked first.</span>")
				return
			chamber.toggle_open()
			return TRUE
		if("toggle_lock")
			if(chamber.state_open)
				to_chat(usr, "<span class='alert'>The chamber must be closed first.</span>")
				return
			chamber.locked = !chamber.locked
			return TRUE
		if("capture")
			if(!chamber)
				return
			addtimer(CALLBACK(src, PROC_REF(capture), usr), 5)
			return TRUE

/obj/machinery/computer/fugitive_capture_computer/proc/scan_machinery()
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/fugitive_capture/chamberf = locate(/obj/machinery/fugitive_capture, get_step(src, direction))
		if(chamberf && chamberf.is_operational)
			chamber = chamberf
			return

/obj/machinery/computer/fugitive_capture_computer/proc/capture(mob/user)
	var/mob/living/carbon/human/prisoner = chamber.occupant
	if(!istype(prisoner))
		chamber.say("ERROR: Invalid prisoner identification. Data: Unknown occupant.")
		playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return
	var/datum/antagonist/fugitive/antag = prisoner.mind?.has_antag_datum(/datum/antagonist/fugitive)
	if(!antag)
		chamber.say("ERROR: Invalid prisoner identification. Data: Not currently a wanted fugitive.")
		playsound(src, 'sound/machines/terminal_error.ogg', 15, TRUE)
		return
	playsound(src, 'sound/weapons/emitter.ogg', 50, TRUE)
	log_game("[key_name(user)] permanently captured the fugitive [key_name(prisoner)].")
	chamber.occupant = null // remove the reference
	antag.is_captured = TRUE
	antag.living_on_capture = prisoner.stat != DEAD
	to_chat(prisoner, "<span class='big boldannounce'>You are thrown into a vast void of bluespace, and as you fall further into oblivion the comparatively small entrance to reality gets smaller and smaller until you cannot see it anymore. You have failed to avoid capture.</span>")
	prisoner.ghostize(FALSE)
	qdel(prisoner)
	chamber.locked = FALSE
	chamber.toggle_open()
	ui_update()

// ----------------
// Shuttle Computer
// ----------------

/obj/machinery/computer/shuttle_flight/hunter
	name = "shuttle console"
	shuttleId = "huntership"
	possible_destinations = "huntership_home;huntership_custom;whiteship_home;syndicate_nw"
	req_access = list(ACCESS_HUNTERS)
