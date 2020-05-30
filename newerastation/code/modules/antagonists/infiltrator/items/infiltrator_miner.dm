//NOT yoinked from hippie. aw yeah.
GLOBAL_VAR_INIT(infil_miner_transmitted, 0)

/obj/item/infiltrator_miner
	name = "strange wireless device"
	desc = "A small circuit board attached to an antenna, branded with a large red S." //bad writing reeee
	icon = 'newerastation/icons/obj/module.dmi'
	icon_state = "bitcoin_minerp"
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/paper
	var/target
	var/target_reached = FALSE
	var/obj/item/radio/alert_radio

/obj/item/infiltrator_miner/Initialize()
	. = ..()
	paper = new /obj/item/paper/guides/antag/infil_miner_guide(src)
	alert_radio = new(src)
	alert_radio.make_syndie()
	alert_radio.listening = FALSE
	alert_radio.canhear_range = 0

/obj/item/infiltrator_miner/examine(mob/user)
	. = ..()
	if(paper)
		. += ("<span class='notice'>It has a written note on it. Alt click to remove it.</span>")


/obj/item/infiltrator_miner/AltClick(mob/user)
	if(issilicon(usr) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	if(paper)
		user.put_in_hands(paper)
		to_chat(user, "<span class='notice'>You remove the note from the [src].</span>")
		playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)
		icon_state = "bitcoin_miner"
		paper = null

/obj/machinery/rnd/server/attackby(obj/item/infiltrator_miner/I, mob/user, params)
	if(istype(I) && src.panel_open)
		if(!locate(/obj/item/infiltrator_miner) in src.contents)
			user.visible_message("<span class='warning'>[user] begins attaching something to [src]...</span>")
			if(do_after(user,55,target = src))
				user.dropItemToGround(I)
				I.forceMove(src)
				message_admins("[ADMIN_LOOKUPFLW(user)] has attached a syndicate miner device to [ADMIN_LOOKUPFLW(src)]!")
		else
			to_chat(user, "<span class='warning'>This server already has a miner in it!</span>")
		return
	return ..()

/obj/item/infiltrator_miner/proc/on_mine(stolen)
	GLOB.infil_miner_transmitted += stolen
	if(GLOB.infil_miner_transmitted >= target && !target_reached)
		alert_radio.talk_into(src.loc, "Research point objective reached. Disabling hooks to avoid further suspicion...", "Syndicate")
		visible_message("<span class='notice'>[src] beeps.</span>")
		playsound(src, 'sound/machines/ping.ogg', 100, 1)
		target_reached = TRUE

/obj/machinery/rnd/server/attack_hand(mob/user)
	if(src.panel_open)
		var/obj/item/infiltrator_miner/M = locate(/obj/item/infiltrator_miner) in src.contents
		if(M)
			to_chat(user, "<span class='warning'>Huh? What's this? This device wasn't supposed to be here! You attempt to remove it...</span>")
			if(do_after(user,100,target = src))
				M.forceMove(loc)
				M.alert_radio.talk_into(src, "Alert: Connection to bluespace data recombobulation pipeline has been lost.", "Syndicate") //Yes, the server says it. This is intentional.
			else
				to_chat(user, "<span class='notice'>You fail to remove the device.</span>")
		return
	return ..()
