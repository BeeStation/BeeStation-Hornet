///Called when a Bloodsucker buys a power: (power)
/datum/antagonist/bloodsucker/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	for(var/datum/action/cooldown/bloodsucker/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] purchased [power].")
	return TRUE

///Called when a Bloodsucker loses a power: (power)
/datum/antagonist/bloodsucker/proc/RemovePower(datum/action/cooldown/bloodsucker/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

///When a Bloodsucker breaks the Masquerade, they get their HUD icon changed, and Malkavian Bloodsuckers get alerted.
/datum/antagonist/bloodsucker/proc/break_masquerade(mob/admin)
	if(broke_masquerade)
		return

	owner.current.playsound_local(null, 'sound/bloodsuckers/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, "<span class='cultboldtalic'>You have broken the Masquerade!</span>")
	to_chat(owner.current, "<span class='warning'>Bloodsucker Tip: When you break the Masquerade, you become open for termination by fellow Bloodsuckers, and your Vassals are no longer completely loyal to you, as other Bloodsuckers can steal them for themselves!</span>")
	broke_masquerade = TRUE
	antag_hud_name = "masquerade_broken"
	set_antag_hud(owner.current, antag_hud_name)
	SEND_GLOBAL_SIGNAL(COMSIG_BLOODSUCKER_BROKE_MASQUERADE, src)

///This is admin-only of reverting a broken masquerade, sadly it doesn't remove the Malkavian objectives yet.
/datum/antagonist/bloodsucker/proc/fix_masquerade(mob/admin)
	if(!broke_masquerade)
		return
	antag_hud_name = "bloodsucker"
	set_antag_hud(owner.current, antag_hud_name)
	to_chat(owner.current, "<span class='cultboldtalic'>You have re-entered the Masquerade.</span>")
	broke_masquerade = FALSE

/datum/antagonist/bloodsucker/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++
	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, "<span class='cultbold'>You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become a criminal to the Bloodsucker's Cause!</span>")

/datum/antagonist/bloodsucker/proc/RankUp()
	if(!owner || !owner.current || IS_FAVORITE_VASSAL(owner.current))
		return
	bloodsucker_level_unspent++
	if(!my_clan)
		to_chat(owner.current, "<span class='notice'>You have gained a rank. Join a Clan to spend it.</span>")
		return
	// Spend Rank Immediately?
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		to_chat(owner, "<span class='notice'><EM>You have grown more ancient! Sleep in a coffin that you have claimed to thicken your blood and become more powerful[istype(my_clan, /datum/bloodsucker_clan/ventrue) ? ", or put your Favorite Vassal on a persuasion rack to level them up" : ""]</EM></span>")
		return
	SpendRank()

/datum/antagonist/bloodsucker/proc/RankDown()
	bloodsucker_level_unspent--

/datum/antagonist/bloodsucker/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(power.purchase_flags & BLOODSUCKER_DEFAULT_POWER)
			continue
		RemovePower(power)
		if(return_levels)
			bloodsucker_level_unspent++

/datum/antagonist/bloodsucker/proc/LevelUpPowers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			continue
		power.upgrade_power()

///Disables all powers, accounting for torpor
/datum/antagonist/bloodsucker/proc/DisableAllPowers(forced = FALSE)
	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && HAS_TRAIT(owner.current, TRAIT_NODEATH)))
			if(power.active)
				power.DeactivatePower()

/datum/antagonist/bloodsucker/proc/SpendRank(mob/living/carbon/human/target, cost_rank = TRUE, blood_cost)
	if(!owner || !owner.current || !owner.current.client || (cost_rank && bloodsucker_level_unspent <= 0))
		return
	SEND_SIGNAL(src, BLOODSUCKER_RANK_UP, target, cost_rank, blood_cost)

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
