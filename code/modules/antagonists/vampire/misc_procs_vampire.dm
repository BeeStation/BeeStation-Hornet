/**
 * Helper proc for adding a power
**/
/datum/antagonist/vampire/proc/grant_power(datum/action/vampire/power)
	for(var/datum/action/vampire/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] has purchased: [power].")
	return TRUE

/**
 * Helper proc for removing a power
**/
/datum/antagonist/vampire/proc/remove_power(datum/action/vampire/power)
	if(power.currently_active)
		power.deactivate_power()
	powers -= power
	power.Remove(owner.current)

/**
 * This is admin-only way of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
**/
/datum/antagonist/vampire/proc/fix_masquerade(mob/admin)
	if(!broke_masquerade)
		return
	broke_masquerade = FALSE

	owner.current.playsound_local(null, 'sound/vampires/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_userdanger("You have re-entered the Masquerade."))

	set_antag_hud(owner.current, "vampire")

	GLOB.masquerade_breakers.Remove(src)

/**
 * When a Vampire breaks the Masquerade, they get their HUD icon changed, and Malkavian Vampires get alerted.
**/
/datum/antagonist/vampire/proc/break_masquerade(mob/admin)
	if(broke_masquerade)
		return
	broke_masquerade = TRUE

	owner.current.playsound_local(null, 'sound/vampires/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, span_userdanger("You have broken the Masquerade!"))
	to_chat(owner.current, span_warning("Vampire Tip: When you break the Masquerade, you become open for termination by fellow Vampires, and your Vassals are no longer completely loyal to you, as other Vampires can steal them for themselves!"))

	set_antag_hud(owner.current, "masquerade_broken")

	SEND_GLOBAL_SIGNAL(COMSIG_VAMPIRE_BROKE_MASQUERADE, src)
	GLOB.masquerade_breakers.Add(src)

/**
 * Increment the masquerade infraction counter and warn the vampire accordingly
**/
/datum/antagonist/vampire/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++

	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the all other Vampires!"))

/**
 * Increase our unspent vampire levels by one and try to rank up if inside a coffin
 * Called near the end of Sol and admin abuse
**/
/datum/antagonist/vampire/proc/rank_up()
	if(QDELETED(owner) || QDELETED(owner.current))
		return

	vampire_level_unspent++
	if(!my_clan)
		to_chat(owner.current, span_notice("You have gained a rank. Join a clan to spend it."))
		return

	// If we're in a coffin go ahead and try to spend the rank
	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		my_clan.spend_rank()
	else
		to_chat(owner, span_notice("<EM>You have grown more ancient! \
			Sleep in a coffin that you have claimed to thicken your blood and become more powerful\
			[istype(my_clan, /datum/vampire_clan/ventrue) ? ", or put your Favorite Vassal on a persuasion rack to level them up." : "!"]</EM>"))

/**
 * Decrease the unspent vampire levels by one. Only for admins
**/
/datum/antagonist/vampire/proc/rank_down()
	vampire_level_unspent--

/datum/antagonist/vampire/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(power.purchase_flags & VAMPIRE_DEFAULT_POWER)
			continue
		remove_power(power)
		if(return_levels)
			vampire_level_unspent++

/**
 * Helper proc to upgrade all powers and their cooldown time when ranking up
**/
/datum/antagonist/vampire/proc/level_up_powers()
	for(var/datum/action/vampire/power as anything in powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			continue
		power.upgrade_power()

/**
 * Disables all Torpor exclusive powers, if forced is TRUE, disable all powers
**/
/datum/antagonist/vampire/proc/disable_all_powers(forced = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && is_in_torpor()))
			if(power.currently_active)
				power.deactivate_power()

/**
 * Check if we have a stake in our heart
**/
/datum/antagonist/vampire/proc/check_if_staked()
	var/obj/item/bodypart/chosen_bodypart = owner.current.get_bodypart(BODY_ZONE_CHEST)
	for(var/obj/item/stake/embedded_stake in chosen_bodypart?.embedded_objects)
		return TRUE

	return FALSE
