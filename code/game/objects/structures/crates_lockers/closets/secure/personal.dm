/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/empty
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"

/obj/structure/closet/secure_closet/personal/empty/PopulateContents()
	return

/obj/structure/closet/secure_closet/personal/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/duffelbag(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/PopulateContents()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/sneakers/white( src )

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/personal/cabinet/PopulateContents()
	new /obj/item/storage/backpack/satchel/leather/withwallet( src )
	new /obj/item/instrument/piano_synth(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = W.GetID()
	if(!istype(I) || !I.electric)
		return ..()
	if(broken)
		broken_effect(user)
		return
	if(I.registered_name == registered_name)
		togglelock(user, FALSE)
		return
	if(((ACCESS_CAPTAIN in I.access) || (ACCESS_ALL_PERSONAL_LOCKERS in I.access)) && registered_name)
		registered_name = null
		balloon_alert_to_viewers("<font color='#ec8907'>Warning!</font> ID registry <font color='#ad3098'>purged!</font>")
		to_chat(user, "Locker ID registry purged.")
		playsound(src, 'sound/machines/uplinkerror.ogg', 50, FALSE)
		return
	if(!I.registered_name)
		balloon_alert_to_viewers("<font color='#ec0707'>Error!</font> ID lacks name to register!")
		to_chat(user, "The ID lacks a name to register.")
		playsound(src, 'sound/machines/uplinkerror.ogg', 50, FALSE)
		return

	if(!registered_name)
		registered_name = I.registered_name
		desc = "Owned by [registered_name]."
		playsound(src, 'sound/machines/terminal_success.ogg', 50)
		balloon_alert_to_viewers("ID registered! Welcome <font color='#ffea2d'>[registered_name]</font>!")
		to_chat(user, "Locker registered under the name of <b>[registered_name]</b>.")
		return

	playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
	balloon_alert_to_viewers("<font color='#ec0707'>Access denied!</font>")
	to_chat(user, span_warning("Access denied!"))

/obj/structure/closet/secure_closet/personal/allowed(mob/user)
	if(issilicon(user) || IsAdminGhost(user))
		return TRUE
	if(!registered_name)
		return ..()
	var/obj/item/card/id/I = user.get_idcard()
	if(!I)
		return FALSE
	if(I.registered_name == registered_name)
		return TRUE
	return FALSE

/obj/structure/closet/secure_closet/personal/togglelock(mob/living/user, finger)
	if(broken)
		broken_effect(user)
		return
	if(!allowed(user))
		playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
		balloon_alert_to_viewers("<font color='#ec0707'>Access denied!</font>")
		to_chat(user, span_warning("Access denied!"))
		return
	if(iscarbon(user) && finger)
		add_fingerprint(user)
	if(locked)
		balloon_alert_to_viewers("Storage <font color='#70eb0c'>Unlocked!</font>")
		playsound(src, 'sound/machines/terminal_select.ogg', 25, FALSE)
		locked = FALSE
	else
		balloon_alert_to_viewers("Storage <font color='#eb0c0c'>Locked!</font>")
		playsound(src, 'sound/machines/terminal_select.ogg', 25, FALSE)
		locked = TRUE
	to_chat(user, "You [locked ? null : "un"]lock [src].")
	update_appearance()

/obj/structure/closet/secure_closet/personal/proc/broken_effect(mob/living/user)
	balloon_alert_to_viewers("<font color='#ec0707'>ERROR</font> LO/K MAL<font color='#22973c'>%$TI0</font>N!")
	to_chat(user, span_danger("It appears to be broken."))
	playsound(src, "sparks", 50, 1)
	new /obj/effect/particle_effect/sparks(src)
