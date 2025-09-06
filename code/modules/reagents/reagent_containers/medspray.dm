/obj/item/reagent_containers/medspray
	name = "medical spray"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "medspray"
	inhand_icon_state = "spraycan"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	item_flags = NOBLUDGEON
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10)
	volume = 60
	var/can_fill_from_container = TRUE
	var/apply_type = PATCH
	var/apply_method = "spray"
	var/self_delay = 30
	var/squirt_mode = 0
	custom_price = 40

/obj/item/reagent_containers/medspray/attack_self(mob/user)
	squirt_mode = !squirt_mode
	return ..()

/obj/item/reagent_containers/medspray/attack_self_secondary(mob/user)
	squirt_mode = !squirt_mode
	return ..()

/obj/item/reagent_containers/medspray/mode_change_message(mob/user)
	to_chat(user, span_notice("You will now apply the medspray's contents in [squirt_mode ? "short bursts":"extended sprays"]. You'll now use [amount_per_transfer_from_this] units per use."))

/obj/item/reagent_containers/medspray/attack(mob/living/carbon/M, mob/user)
	if(!iscarbon(M))
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	var/datum/task/target_zone_task = user.select_bodyzone(M, FALSE, BODYZONE_STYLE_MEDICAL)
	target_zone_task.continue_with(CALLBACK(src, PROC_REF(do_spray), M, user))

/obj/item/reagent_containers/medspray/proc/do_spray(mob/living/carbon/M, mob/user, def_zone)
	if (!def_zone)
		return
	if (!user.can_interact_with(M, TRUE))
		balloon_alert(user, "[M] is too far away!")
		return
	if (!user.can_interact_with(src, TRUE))
		balloon_alert(user, "[src] is too far away!")
		return
	var/obj/item/bodypart/affecting = M.get_bodypart(check_zone(def_zone))
	if(!affecting)
		balloon_alert(user, "The limb is missing.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] doesn't work on robotic limbs.")
		return

	if(M == user)
		M.visible_message(span_notice("[user] attempts to [apply_method] [src] on [user.p_them()]self."))
		if(self_delay)
			if(!do_after(user, self_delay, M))
				return
			if(!reagents || !reagents.total_volume)
				return
		to_chat(M, span_notice("You [apply_method] yourself with [src]."))

	else
		log_combat(user, M, "attempted to apply", src, reagents.log_list())
		M.visible_message(span_danger("[user] attempts to [apply_method] [src] on [M]."), \
							span_userdanger("[user] attempts to [apply_method] [src] on [M]."))
		if(!do_after(user, 3 SECONDS, target = M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message(span_danger("[user] [apply_method]s [M] down with [src]."), \
							span_userdanger("[user] [apply_method]s [M] down with [src]."))

	if(!reagents || !reagents.total_volume)
		return

	else
		log_combat(user, M, "applied", src, reagents.log_list())
		playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.expose(M, apply_type, fraction, affecting = affecting)
		reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
	return

/obj/item/reagent_containers/medspray/styptic
	name = "medical spray (styptic powder)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains styptic powder, for treating cuts and bruises."
	icon_state = "brutespray"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 60)

/obj/item/reagent_containers/medspray/silver_sulf
	name = "medical spray (silver sulfadiazine)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains silver sulfadiazine, useful for treating burns."
	icon_state = "burnspray"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 60)

/obj/item/reagent_containers/medspray/synthflesh
	name = "medical spray (synthflesh)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains synthflesh, an apex brute and burn healing agent."
	icon_state = "synthspray"
	list_reagents = list(/datum/reagent/medicine/synthflesh = 60)
	custom_price = 80

/obj/item/reagent_containers/medspray/sterilizine
	name = "sterilizer spray"
	desc = "Spray bottle loaded with non-toxic sterilizer. Useful in preparation for surgery."
	list_reagents = list(/datum/reagent/space_cleaner/sterilizine = 60)

/obj/item/reagent_containers/medspray/barber
	name = "hair spray"
	desc = "Spray bottle loaded with an unknown hair growth agent."
	icon_state = "hairgrowth"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/barbers_aid = 60)
	squirt_mode = 1

/obj/item/reagent_containers/medspray/dye
	name = "hair dye"
	desc = "Spray bottle loaded with an all-purpose hair dye."
	icon_state = "hairdye"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/hair_dye = 60)
	squirt_mode = 1

/obj/item/reagent_containers/medspray/spraytan
	name = "spray tan"
	desc = "A spray tan bottle, jury rigged to deliver just too much spray tan per spray."
	icon_state = "spraytan"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/spraytan = 55)
	amount_per_transfer_from_this = 10
