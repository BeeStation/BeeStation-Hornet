/datum/action/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed. Costs 5 chemicals."
	button_icon_state = "transform"
	chemical_cost = 5
	dna_cost = 0
	req_dna = 1
	req_human = TRUE

/obj/item/clothing/glasses/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/glasses/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/under/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/under/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/suit/changeling
	name = "flesh"
	item_flags = DROPDEL
	allowed = list(/obj/item/changeling)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/suit/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/head/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/head/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/shoes/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/shoes/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/gloves/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/gloves/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/clothing/mask/changeling
	name = "flesh"
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clothing/mask/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_notice("You reabsorb [src] into your body."))
		qdel(src)
		return
	. = ..()

/obj/item/changeling
	name = "flesh"
	slot_flags = ALL
	allowed = list(/obj/item/changeling)
	item_flags = DROPDEL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(user, span_notice("You reabsorb [src] into your body."))
		else
			to_chat(user, span_notice("[src] vanishes, it was just an illusion!"))
		qdel(src)
		return
	. = ..()

//=============
// ID CARD
// Copy pasted due to requiring inherited behaviour
//=============

/obj/item/card/id/changeling
	name = "flesh"
	item_flags = DROPDEL

/obj/item/card/id/changeling/attack_hand(mob/user, list/modifiers)
	if(loc == user)
		if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(user, span_notice("You reabsorb [src] into your body."))
		else
			to_chat(user, span_notice("[src] vanishes, it was just an illusion!"))
		qdel(src)
		return
	. = ..()

//Change our DNA to that of somebody we've absorbed.
/datum/action/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/chosen_prof = changeling.select_dna()

	if(!chosen_prof)
		return
	..()
	changeling.transform(user, chosen_prof)
	return TRUE

/**
 * Gives a changeling a list of all possible dnas in their profiles to choose from and returns profile containing their chosen dna
 */
/datum/antagonist/changeling/proc/select_dna()
	var/mob/living/carbon/user = owner.current
	if(!istype(user))
		return

	var/list/disguises = list("Drop Flesh Disguise" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_drop"))
	for(var/datum/changeling_profile/current_profile in stored_profiles)
		var/datum/icon_snapshot/snap = current_profile.profile_snapshot
		var/image/disguise_image = image(icon = snap.icon, icon_state = snap.icon_state)
		disguise_image.overlays = snap.overlays
		disguises[current_profile.name] = disguise_image

	var/chosen_name = show_radial_menu(user, user, disguises, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 40, require_near = TRUE, tooltips = TRUE)
	if(!chosen_name)
		return

	if(chosen_name == "Drop Flesh Disguise")
		for(var/slot in slot2type)
			if(istype(user.vars[slot], slot2type[slot]))
				qdel(user.vars[slot])
		return

	var/datum/changeling_profile/prof = get_dna(chosen_name)
	return prof

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The carbon mob interacting with the menu
 */
/datum/antagonist/changeling/proc/check_menu(mob/living/carbon/user)
	if(!istype(user))
		return FALSE
	var/datum/antagonist/changeling/changeling_datum = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling_datum)
		return FALSE
	return TRUE
