/*
 * Don't use the apostrophe in name or desc. Causes script errors.//probably no longer true
 */

/datum/action/changeling
	name = "Prototype Sting - Debug button, ahelp this"
	background_icon_state = "bg_changeling"
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = null
	check_flags = AB_CHECK_CONSCIOUS
	var/needs_button = TRUE//for passive abilities like hivemind that dont need a button
	var/helptext = "" // Details
	var/chemical_cost = 0 // negative chemical cost is for passive abilities (chemical glands)
	var/dna_cost = -1 //cost of the sting in dna points. 0 = auto-purchase (see changeling.dm), -1 = cannot be purchased
	var/req_dna = 0  //amount of dna needed to use this ability. Changelings always have atleast 1
	var/req_human = 0 //if you need to be human to use this ability
	var/req_absorbs = 0 //similar to req_dna, but only gained from absorbing, not DNA sting
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
	if(!can_sting(user, target))
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(sting_action(user, target))
		sting_feedback(user, target)
		changeling.adjust_chemicals(-chemical_cost)

/datum/action/changeling/proc/sting_action(mob/living/user, mob/living/target)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return FALSE

/datum/action/changeling/proc/sting_feedback(mob/living/user, mob/living/target)
	return FALSE

//Fairly important to remember to return 1 on success >.<
/datum/action/changeling/proc/can_sting(mob/living/user, mob/living/target)
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
	if(c.absorbed_count < req_dna)
		to_chat(user, span_warning("We require at least [req_dna] sample\s of compatible DNA."))
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
