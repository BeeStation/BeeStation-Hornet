/*
 * Don't use the apostrophe in name or desc. Causes script errors.//probably no longer true
 */

/datum/action/changeling
	name = "Prototype Sting - Debug button, ahelp this"
	background_icon_state = "bg_changeling"
	icon_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = null
	check_flags = AB_CHECK_CONSCIOUS
	var/needs_button = TRUE//for passive abilities like hivemind that dont need a button
	var/helptext = "" // Details
	var/chemical_cost = 0 // negative chemical cost is for passive abilities (chemical glands)
	var/dna_cost = -1 //cost of the sting in dna points. 0 = auto-purchase (see changeling.dm), -1 = cannot be purchased
	var/points_to_use = 0  //amount of genetic points needed to use this ability
	var/req_human = 0 //if you need to be human to use this ability
	var/recharge_slowdown = 0 // Chemical upkeep of ability in use
	var/limb_sacrifice = FALSE // Sacrifices a limb and turns it into something else, can only be cast if ling has a limb obviously
	var/ignores_fakedeath = FALSE // usable with the FAKEDEATH flag

/*
changeling code now relies on on_purchase to grant powers.
if you override it, MAKE SURE you call parent or it will not be usable
the same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec
*/

/datum/action/changeling/proc/on_purchase(mob/user, is_respec)
	if(!is_respec)
		SSblackbox.record_feedback("tally", "changeling_power_purchase", 1, name)
	if(needs_button)
		Grant(user)//how powers are added rather than the checks in mob.dm

/datum/action/changeling/is_available()
	return ..() && owner.mind && owner.mind.has_antag_datum(/datum/antagonist/changeling)

/datum/action/changeling/on_activate(mob/user, atom/target)
	try_to_sting(user)

/datum/action/changeling/proc/try_to_sting(mob/living/user, mob/living/target)
	if(!ling_can_cast(user, target))
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(sting_action(user, target))
		sting_feedback(user, target)
		changeling.adjust_chemicals(-chemical_cost)

/datum/action/changeling/proc/sting_action(mob/living/user, mob/living/target)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	if(limb_sacrifice) // For limb sacrifice abilities, check in ling_can_cast
		var/mob/living/carbon/C = user
		var/list/parts = list()
		for(var/limb in C.bodyparts)
			var/obj/item/bodypart/BP = limb
			if(BP.body_part != HEAD && BP.body_part != CHEST && IS_ORGANIC_LIMB(BP))
				if(BP.dismemberable)
					parts += BP
		//limb related actions
		var/obj/item/bodypart/BP = pick(parts)
		for(var/obj/item/bodypart/Gir in parts)
			if(Gir.body_part == ARM_RIGHT || Gir.body_part == ARM_LEFT)	//arms first so they don't become a stump too fast
				BP = Gir
		//text message
		C.visible_message(span_warning("[user]'s [BP] detaches itself and mutates!"),
				span_userdanger("Our [BP] reforms to our will!"))
		BP.dismember()
		BP.Destroy()
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	// If the spell requires genetic points, deducts them here, check itself is done in ling_can_cast
	if(points_to_use)
		changeling.genetic_points -= points_to_use
	if(recharge_slowdown)
		changeling.chem_recharge_slowdown += recharge_slowdown
	return FALSE

/datum/action/changeling/proc/subtract_slowdown(mob/living/user)
	if(recharge_slowdown)	// Just to be sure!
		var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
		changeling.chem_recharge_slowdown -= recharge_slowdown

/datum/action/changeling/proc/sting_feedback(mob/living/user, mob/living/target)
	return FALSE

//Fairly important to remember to return 1 on success >.<
/datum/action/changeling/proc/ling_can_cast(mob/living/user, mob/living/target)
	if (!is_available(user))
		return FALSE
	if(!ishuman(user) && !ismonkey(user)) //typecast everything from mob to carbon from this point onwards
		return FALSE
	if(req_human && !ishuman(user))
		to_chat(user, span_warning("We cannot do that in this form!"))
		return FALSE
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(c.chem_charges < chemical_cost)
		to_chat(user, span_warning("We require at least [chemical_cost] unit\s of chemicals to do that!"))
		return FALSE
	if(c.genetic_points < points_to_use)
		user.balloon_alert(user, "Insuficient Genetic Points!")
		to_chat(user, span_warning("We require at least [points_to_use] genetic point\s."))
		return FALSE
	if(limb_sacrifice)	//Checking here too just in case
		var/mob/living/carbon/C = user
		var/list/parts = list()
		for(var/limb in C.bodyparts)
			var/obj/item/bodypart/BP = limb
			if(BP.body_part != HEAD && BP.body_part != CHEST && IS_ORGANIC_LIMB(BP))
				if(BP.dismemberable)
					parts += BP
		if(!LAZYLEN(parts))
			to_chat(user, span_notice("We don't have any limbs to detach."))
			return FALSE
	if((HAS_TRAIT(user, TRAIT_DEATHCOMA)) && (!ignores_fakedeath))
		to_chat(user, span_warning("We are incapacitated."))
		return FALSE
	return TRUE

/datum/action/changeling/proc/can_be_used_by(mob/living/user)
	if(!user || QDELETED(user))
		return 0
	if(!ishuman(user) && !ismonkey(user))
		return FALSE
	if(req_human && !ishuman(user))
		return FALSE
	return TRUE
