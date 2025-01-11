///Called when a Vampire buys a power: (power)
/datum/antagonist/vampire/proc/BuyPower(datum/action/cooldown/vampire/power)
	for(var/datum/action/cooldown/vampire/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] purchased [power].")
	return TRUE

///Called when a Vampire loses a power: (power)
/datum/antagonist/vampire/proc/RemovePower(datum/action/cooldown/vampire/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

///When a Vampire breaks the Masquerade, they get their HUD icon changed, and Malkavian Vampires get alerted.
/datum/antagonist/vampire/proc/break_masquerade(mob/admin)
	if(broke_masquerade)
		return

	owner.current.playsound_local(null, 'sound/vampires/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, "<span class='cultboldtalic'>You have broken the Masquerade!</span>")
	to_chat(owner.current, "<span class='warning'>Vampire Tip: When you break the Masquerade, you become open for termination by fellow Vampires, and your Vassals are no longer completely loyal to you, as other Vampires can steal them for themselves!</span>")
	broke_masquerade = TRUE
	set_antag_hud(owner.current, "masquerade_broken")
	SEND_GLOBAL_SIGNAL(COMSIG_VAMPIRE_BROKE_MASQUERADE, src)

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/vampire/proc/fix_masquerade(mob/admin)
	if(!broke_masquerade)
		return
	set_antag_hud(owner.current, "vampire")
	to_chat(owner.current, "<span class='cultboldtalic'>You have re-entered the Masquerade.</span>")
	broke_masquerade = FALSE

/datum/antagonist/vampire/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, "<span class='cultbold'>You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the Vampire's Cause!</span>")

/datum/antagonist/vampire/proc/RankUp()
	if(!owner || !owner.current || IS_FAVORITE_VASSAL(owner.current))
		return
	vampire_level_unspent++
	if(!my_clan)
		to_chat(owner.current, "<span class='notice'>You have gained a rank. Join a Clan to spend it.</span>")
		return
	// Spend Rank Immediately?
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		to_chat(owner, "<span class='notice'><EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful[istype(my_clan, /datum/vampire_clan/ventrue) ? ", or put your Favorite Vassal on a persuasion rack to level them up" : ""]</EM></span>")
		return
	SpendRank()

/datum/antagonist/vampire/proc/RankDown()
	vampire_level_unspent--

/datum/antagonist/vampire/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/cooldown/vampire/power as anything in powers)
		if(power.purchase_flags & VAMPIRE_DEFAULT_POWER)
			continue
		RemovePower(power)
		if(return_levels)
			vampire_level_unspent++

/datum/antagonist/vampire/proc/LevelUpPowers()
	for(var/datum/action/cooldown/vampire/power as anything in powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			continue
		power.upgrade_power()

///Disables all powers, accounting for torpor
/datum/antagonist/vampire/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/cooldown/vampire/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH)))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/vampire/proc/SpendRank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && vampire_level_unspent <= 0))
		return
	SEND_SIGNAL(src, VAMPIRE_RANK_UP, target, cost_rank, blood_cost)

/// Do I have a stake in my heart?
/datum/antagonist/vampire/proc/check_staked()
	var/obj/item/bodypart/chosen_bodypart = owner.current.get_bodypart(BODY_ZONE_CHEST)
	if(!chosen_bodypart)
		return FALSE
	for(var/obj/item/embedded_stake in chosen_bodypart.embedded_objects)
		if(istype(embedded_stake, /obj/item/stake))
			return TRUE
	return FALSE

/// You can't go to sleep in a coffin with a stake in you.
/datum/antagonist/vampire/proc/can_stake_kill()
	if(owner.current.IsSleeping())
		return TRUE
	if(owner.current.stat >= UNCONSCIOUS)
		return TRUE
	if(HAS_TRAIT(owner.current, TRAIT_TORPOR))
		return TRUE
	return FALSE

/**
 * CARBON INTEGRATION
 *
 * All overrides of mob/living and mob/living/carbon
 */
/// Brute
/mob/living/proc/getBruteLoss_nonProsthetic()
	return getBruteLoss()

/mob/living/carbon/getBruteLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		amount += chosen_bodypart.brute_dam
	return amount

/// Burn
/mob/living/proc/getFireLoss_nonProsthetic()
	return getFireLoss()

/mob/living/carbon/getFireLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		amount += chosen_bodypart.burn_dam
	return amount
