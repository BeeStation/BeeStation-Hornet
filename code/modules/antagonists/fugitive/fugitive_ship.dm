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

/obj/machinery/fugitive_capture/proc/add_prisoner(mob/living/carbon/human/fugitive)
	var/datum/antagonist/fugitive/antag = fugitive.mind.has_antag_datum(/datum/antagonist/fugitive)
	if(!antag)
		return
	fugitive.forceMove(src)
	antag.is_captured = TRUE
	to_chat(fugitive, "<span class='userdanger'>You are thrown into a vast void of bluespace, and as you fall further into oblivion the comparatively small entrance to reality gets smaller and smaller until you cannot see it anymore. You have failed to avoid capture.</span>")
	fugitive.ghostize(TRUE) //so they cannot suicide, round end stuff.

/obj/machinery/computer/shuttle_flight/hunter
	name = "shuttle console"
	shuttleId = "huntership"
	possible_destinations = "huntership_home;huntership_custom;whiteship_home;syndicate_nw"
	req_access = list(ACCESS_HUNTERS)
