/mob/living/carbon/human/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job", hand_first = TRUE)
	var/obj/item/card/id/id = get_idcard(hand_first)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_id
	if(id)
		. = id.get_assignment()
	else
		var/obj/item/modular_computer/pda = wear_id
		if(istype(pda))
			. = pda.saved_job
		else
			return if_no_id
	if(!.)
		return if_no_job

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_idcard(FALSE)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_id
	if(id)
		return id.registered_name
	var/obj/item/modular_computer/pda = wear_id
	if(istype(pda))
		return pda.saved_identification
	return if_no_id

/// Used to update our name based on whether our face is obscured/disfigured
/mob/living/carbon/human/proc/update_visible_name()
	SIGNAL_HANDLER
	name = get_visible_name()

/// Combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a separate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
	var/list/identity = list(null, null, null)
	SEND_SIGNAL(src, COMSIG_HUMAN_GET_VISIBLE_NAME, identity)
	var/signal_face = LAZYACCESS(identity, VISIBLE_NAME_FACE)
	var/signal_id = LAZYACCESS(identity, VISIBLE_NAME_ID)
	var/force_set = LAZYACCESS(identity, VISIBLE_NAME_FORCED)
	if(force_set) // our name is overriden by something
		return signal_face // no need to null-check, because force_set will always set a signal_face

	var/face_name = isnull(signal_face) ? get_face_name("") : signal_face
	var/id_name = isnull(signal_id) ? get_id_name("") : signal_id

	// We need to account for real name
	if(force_real_name)
		var/disguse_name = get_visible_name(add_id_name = TRUE, force_real_name = FALSE)
		return "[real_name][disguse_name == real_name ? "" : " (as [disguse_name])"]"

	// We're just some unknown guy
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return "Unknown"

	// We have a face and an ID
	if(face_name && id_name)
		var/normal_id_name = get_id_name("") // need to check base ID name to avoid "John (as Captain John)"
		if(normal_id_name == face_name)
			return id_name // (this turns "John" into "Captain John")
		if(add_id_name)
			return "[face_name] (as [id_name])"

	// Just go down the list of stuff we recorded
	return face_name || id_name || "Unknown"

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when Fluacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name(if_no_face="Unknown")
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		return if_no_face //We're Unknown, no face information for you
	if(obscured_slots & HIDEFACE)
		return if_no_face
	var/obj/item/bodypart/O = get_bodypart(BODY_ZONE_HEAD)
	if( !O || (HAS_TRAIT(src, TRAIT_DISFIGURED)) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )	//disfigured. use id-name if possible
		return if_no_face
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/storage/wallet/wallet = wear_id
	var/obj/item/modular_computer/tablet/tablet = wear_id
	var/obj/item/card/id/id = wear_id
	var/list/identity = list(null, null, null)
	SEND_SIGNAL(src, COMSIG_HUMAN_GET_FORCED_NAME, identity)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_APPEARANCE))
		. = if_no_id //You get NOTHING, no id name, good day sir
		if(identity[VISIBLE_NAME_FORCED])
			. = identity[VISIBLE_NAME_FACE] // to return forced names when unknown, instead of ID
			return
	if(istype(wallet))
		id = wallet.front_id
	if(istype(id))
		. = id.registered_name
	else if(istype(tablet))
		var/obj/item/computer_hardware/card_slot/card_slot = tablet.all_components[MC_CARD]
		if(card_slot?.stored_card)
			. = card_slot.stored_card.registered_name
	if(!.)
		. = if_no_id	//to prevent null-names making the mob unclickable
	return

/mob/living/carbon/human/get_idcard(hand_first = TRUE)
	. = ..()
	if(. && hand_first)
		return
	//Check inventory slots
	return wear_id?.GetID() || belt?.GetID() || .

/mob/living/carbon/human/get_cash_list(list/search_through = null)
	return ..(search_through || list(get_active_held_item(), get_inactive_held_item(), wear_id, belt))

/mob/living/carbon/human/can_use_guns(obj/item/G)
	. = ..()
	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(check_chunky_fingers())
			balloon_alert(src, "fingers are too big!")
			return FALSE
	if(HAS_TRAIT(src, TRAIT_NOGUNS))
		to_chat(src, span_warning("You can't bring yourself to use a ranged weapon!"))
		return FALSE

/mob/living/carbon/human/proc/check_chunky_fingers()
	if(HAS_TRAIT_NOT_FROM(src, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT) && HAS_TRAIT_NOT_FROM(src, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT))
		return TRUE
	return IS_LEFT_INDEX(active_hand_index) ? HAS_TRAIT_FROM(src, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT) : HAS_TRAIT_FROM(src, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT)

/mob/living/carbon/human/proc/get_job_id() //Used in secHUD icon generation (the new one)
	var/obj/item/card/id/I = wear_id.GetID()
	if(!I)
		return
	var/I_hud = I.get_hud_state()
	if(I_hud)
		return I_hud
	return "unknown"

///copies over clothing preferences like underwear to another human
/mob/living/carbon/human/proc/copy_clothing_prefs(mob/living/carbon/human/destination)
	destination.underwear = underwear
	destination.underwear_color = underwear_color
	destination.undershirt = undershirt
	destination.socks = socks
	destination.jumpsuit_style = jumpsuit_style


/// Fully randomizes everything according to the given flags.
/mob/living/carbon/human/proc/randomize_human_appearance(randomize_flags = ALL)
	var/datum/preferences/preferences = new

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			preferences.write_preference(preference, preference.create_random_value(preferences))
