///Called when a Vampire buys a power: (power)
/datum/antagonist/vampire/proc/BuyPower(datum/action/vampire/power)
	for(var/datum/action/vampire/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] purchased [power].")
	return TRUE

///Called when a Vampire loses a power: (power)
/datum/antagonist/vampire/proc/RemovePower(datum/action/vampire/power)
	if(power.currently_active)
		power.deactivate_power()
	powers -= power
	power.Remove(owner.current)

///When a Vampire breaks the Masquerade, they get their HUD icon changed, and Malkavian Vampires get alerted.
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

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/vampire/proc/fix_masquerade(mob/admin)
	if(!broke_masquerade)
		return
	broke_masquerade = FALSE

	GLOB.masquerade_breakers.Remove(src)

	owner.current.playsound_local(null, 'sound/vampires/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	set_antag_hud(owner.current, "vampire")
	to_chat(owner.current, span_userdanger("You have re-entered the Masquerade."))

/datum/antagonist/vampire/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the all other Vampires!"))

/datum/antagonist/vampire/proc/RankUp()
	if(!owner?.current)
		return
	vampire_level_unspent++
	if(!my_clan)
		to_chat(owner.current, span_notice("You have gained a rank. Join a Clan to spend it."))
		return
	// Spend Rank Immediately?
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		to_chat(owner, span_notice("<EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful[istype(my_clan, /datum/vampire_clan/ventrue) ? ", or put your Favorite Vassal on a persuasion rack to level them up" : ""]</EM>"))
		return
	spend_rank()

/datum/antagonist/vampire/proc/RankDown()
	vampire_level_unspent--

/datum/antagonist/vampire/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(power.purchase_flags & VAMPIRE_DEFAULT_POWER)
			continue
		RemovePower(power)
		if(return_levels)
			vampire_level_unspent++

/datum/antagonist/vampire/proc/LevelUpPowers()
	for(var/datum/action/vampire/power as anything in powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			continue
		power.upgrade_power()

///Disables all powers, accounting for torpor
/datum/antagonist/vampire/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH)))
			if(power.currently_active)
				power.deactivate_power()

/datum/antagonist/vampire/proc/spend_rank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && vampire_level_unspent <= 0))
		return
	SEND_SIGNAL(src, VAMPIRE_RANK_UP, target, cost_rank, blood_cost)

/// Do I have a stake in my heart?
/datum/antagonist/vampire/proc/check_if_staked()
	var/obj/item/bodypart/chosen_bodypart = owner.current.get_bodypart(BODY_ZONE_CHEST)
	if(!chosen_bodypart)
		return FALSE
	for(var/obj/item/embedded_stake in chosen_bodypart.embedded_objects)
		if(istype(embedded_stake, /obj/item/stake))
			return TRUE
	return FALSE
