/obj/machinery/door/airlock/personal
	name = "personal airlock"
	desc = "A personal airlock, swipe an ID to register as owner!"
	icon = 'icons/obj/doors/airlocks/station/private.dmi'
	assemblytype = /obj/structure/door_assembly/personal
	var/registered_name = null        // owner's name once claimed

/* -------------------------------------------------------------------------- */
/* 1.  CLAIMING THE DOOR                                                      */
/* -------------------------------------------------------------------------- */

/obj/machinery/door/airlock/personal/attackby(obj/item/W, mob/user, params)
	// Only ID cards interest us; let the parent handle the rest.
	var/obj/item/card/id/I = W.GetID()
	if(!istype(I) || !I.electric) // We're ignoring paper slips for obvious reasons
		return ..()
	if((ACCESS_CAPTAIN in I.access) && registered_name)
		registered_name = null
		balloon_alert_to_viewers("<font color='#ec8907'>Warning!</font> ID registry <font color='#ad3098'>purged!</font>")
		to_chat(user, "The airlock beeps confusingly as it forgets its owner.")
		playsound(src, 'sound/machines/uplinkerror.ogg', 50, FALSE)
		return

		// Subsequent swipes
	if(registered_name == I.registered_name)
		// Owner toggles bolts by swiping again
		if(locked)
			unbolt()
			balloon_alert_to_viewers("Bolts: <font color='#70eb0c'>Unlocked!</font>")
		else
			bolt()
			balloon_alert_to_viewers("Bolts: <font color='#ec0707'>Locked!</font>")
		return

	if(!I.registered_name)
		playsound(src, 'sound/machines/uplinkerror.ogg', 50, FALSE)
		balloon_alert_to_viewers("<font color='#ec0707'>Error!</font> ID lacks name to register!")
		to_chat(user, ("The airlock fails to register a new owner."))
		return

	// First claim
	if(!registered_name)
		registered_name = I.registered_name
		desc = "Owned by [registered_name]."
		playsound(src, 'sound/machines/terminal_success.ogg', 50)
		balloon_alert_to_viewers("ID registered! Welcome <font color='#ffea2d'>[registered_name]</font>!")
		to_chat(user, "The airlock beeps happily and recognizes <b>[registered_name]</b> as its owner.")
		return
	playsound(src, 'sound/machines/uplinkerror.ogg', 50, FALSE)
	balloon_alert_to_viewers("<font color='#ec0707'>Access denied!</font>")
	to_chat(user, span_warning("Access denied!"))

/* -------------------------------------------------------------------------- */
/* 2.  CUSTOM ACCESS CHECK                                                    */
/* -------------------------------------------------------------------------- */

/obj/machinery/door/airlock/personal/proc/_card_matches(mob/living/user)
	var/obj/item/card/id/I = user.get_idcard()
	return I && I.registered_name == registered_name

/obj/machinery/door/airlock/personal/allowed(mob/user)
	if(issilicon(user) || IsAdminGhost(user))
		return TRUE
	if(!registered_name)
		return ..()
	return _card_matches(user)

/obj/structure/door_assembly/personal
	name = "personal airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/private.dmi'
	base_name = "personal airlock"
	glass_type = /obj/machinery/door/airlock/personal/glass
	airlock_type = /obj/machinery/door/airlock/personal

/obj/machinery/door/airlock/personal/glass
	opacity = FALSE
	glass = TRUE
