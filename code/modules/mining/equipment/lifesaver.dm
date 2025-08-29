/obj/item/clothing/neck/necklace/lifesaver
	name = "Acrux-brand life-saving necklace"
	desc = "You won't be getting any style points with this boring plastitanium box around your neck, but at least you will get rescued in time after it detects your untimely demise and begins causing a massive ruckus over it. Since it uses the satellite array over lavaland to locate, It won't function in space."
	icon_state = "lifesaver"
	worn_icon_state = "lifesaver"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // We want this thing to SURVIVE

	var/obj/item/radio/radio
	var/mob/living/carbon/human/active_owner
	var/active = FALSE

	var/radio_counter

/obj/item/clothing/neck/necklace/lifesaver/Initialize(mapload)
	. = ..()

	radio = new /obj/item/radio(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_COMMON)
	radio.canhear_range = 0

/obj/item/clothing/neck/necklace/lifesaver/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/clothing/neck/necklace/lifesaver/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_NECK)
		active_owner = user
		say("User detected. Monitor process started.")
		RegisterSignal(active_owner, COMSIG_MOB_DEATH, PROC_REF(pre_enable_alert), override = TRUE)
		return

	if(active_owner)
		UnregisterSignal(active_owner, COMSIG_MOB_DEATH)
	active_owner = null

/obj/item/clothing/neck/necklace/lifesaver/attack_self(mob/user)
	if(!active)
		return
	to_chat(user, span_notice("You press your finger on the touch-button, disarming the necklace's alert state."))
	disable_alert()

//Just to give a fella some time to rip it off and disable it.
/obj/item/clothing/neck/necklace/lifesaver/proc/pre_enable_alert()
	if(is_mining_level(active_owner.z))
		icon_state = "lifesaver_active"
		worn_icon_state = "lifesaver_active"
		active_owner.regenerate_icons()

		say("ALERT - LIFESIGNS CRITICAL - DEPLOYING IN: 15 SECONDS.")
		playsound(src, 'sound/machines/triple_beep.ogg', 80, FALSE)
		active = TRUE

		addtimer(CALLBACK(src, PROC_REF(enable_alert)), 15 SECONDS)

/obj/item/clothing/neck/necklace/lifesaver/proc/enable_alert()
	if(active)
		radio.talk_into(src, "Alert - Rescue required! GPS beacon active!")
		say("ALERT - LIFESIGNS CRITICAL - DEPLOYING")

		playsound(src, 'sound/effects/lifesaver.ogg', 150, FALSE, 10)

		AddComponent(/datum/component/gps, "#ACTIVE LIFESAVER - RESCUE REQUIRED#")
		addtimer(CALLBACK(src, PROC_REF(alertRoutine)), 5 SECONDS)

/obj/item/clothing/neck/necklace/lifesaver/proc/disable_alert()
	icon_state = "lifesaver"
	worn_icon_state = "lifesaver"

	qdel(GetComponent(/datum/component/gps))
	active = FALSE

//Loops every few seconds
/obj/item/clothing/neck/necklace/lifesaver/proc/alertRoutine()
	if(active)
		// Periodic unhelpful radio announcements
		if(radio_counter >= 100)
			radio.talk_into(src, "Alert - Rescue required! GPS beacon active!")
			say("ALERT - RESCUE REQUIRED")
			radio_counter = 0
		else
			radio_counter++

		playsound(src, 'sound/effects/ping_hit.ogg', 100, FALSE, 5)
		addtimer(CALLBACK(src, PROC_REF(alertRoutine)), 3 SECONDS)
