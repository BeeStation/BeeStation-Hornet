//entirely neutral or internal status effects go here

/datum/status_effect/sigil_mark //allows the affected target to always trigger sigils while mindless
	id = "sigil_mark"
	duration = -1
	alert_type = null
	var/stat_allowed = DEAD //if owner's stat is below this, will remove itself

/datum/status_effect/sigil_mark/tick()
	if(owner.stat < stat_allowed)
		qdel(src)

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/atom/movable/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/in_love
	var/mob/living/date

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/love_interest)
	. = ..()
	if(.)
		date = love_interest
	linked_alert.desc = "You're in love with [date.real_name]! How lovely."

/datum/status_effect/in_love/tick()
	if(date)
		new /obj/effect/temp_visual/love_heart/invisible(get_turf(date.loc), owner)
		if(get_dist(get_turf(owner), get_turf(date)) < 7)
			owner.heal_overall_damage(1, 1, BODYTYPE_ORGANIC)
			date.heal_overall_damage(1, 1, BODYTYPE_ORGANIC)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>You have been marked for death by [rewarded]. If you die, they will be rewarded.</span>")
	playsound(owner, 'sound/weapons/shotgunpump.ogg', 75, 0)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>Bounty claimed.</span>")
		playsound(owner, 'sound/weapons/shotgunshot.ogg', 75, 0)
		to_chat(rewarded, "<span class='greentext'>You feel a surge of mana flow into you!</span>")
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25, FALSE, TRUE)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

/datum/status_effect/bugged //Lets another mob hear everything you can
	id = "bugged"
	duration = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/mob/living/listening_in

/datum/status_effect/bugged/on_apply(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if (.)
		RegisterSignal(new_owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/datum/status_effect/bugged/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

/datum/status_effect/bugged/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	listening_in.show_message(hearing_args[HEARING_MESSAGE])


/datum/status_effect/bugged/on_creation(mob/living/new_owner, mob/living/tracker)
	. = ..()
	if(.)
		listening_in = tracker

/datum/status_effect/offering
	id = "offering"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// The people who were offered this item at the start
	var/list/possible_takers
	/// The actual item being offered
	var/obj/item/offered_item
	/// The type of alert given to people when offered, in case you need to override some behavior (like for high-fives)
	var/give_alert_type = /atom/movable/screen/alert/give

/datum/status_effect/offering/on_creation(mob/living/new_owner, obj/item/offer, give_alert_override)
	. = ..()
	if(!.)
		return
	offered_item = offer
	if(give_alert_override)
		give_alert_type = give_alert_override

	for(var/mob/living/carbon/possible_taker in orange(1, owner))
		if(!owner.CanReach(possible_taker) || IS_DEAD_OR_INCAP(possible_taker) || !possible_taker.can_hold_items())
			continue
		register_candidate(possible_taker)

	if(!possible_takers) // no one around
		qdel(src)
		return

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_owner_in_range))
	RegisterSignal(offered_item, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED), PROC_REF(dropped_item))

/datum/status_effect/offering/Destroy()
	for(var/i in possible_takers)
		var/mob/living/carbon/removed_taker = i
		remove_candidate(removed_taker)
	LAZYCLEARLIST(possible_takers)
	return ..()

/// Hook up the specified carbon mob to be offered the item in question, give them the alert and signals and all
/datum/status_effect/offering/proc/register_candidate(mob/living/carbon/possible_candidate)
	var/atom/movable/screen/alert/give/G = possible_candidate.throw_alert("[owner]", give_alert_type)
	if(!G)
		return
	LAZYADD(possible_takers, possible_candidate)
	RegisterSignal(possible_candidate, COMSIG_MOVABLE_MOVED, PROC_REF(check_taker_in_range))
	G.setup(possible_candidate, owner, offered_item)

/// Remove the alert and signals for the specified carbon mob. Automatically removes the status effect when we lost the last taker
/datum/status_effect/offering/proc/remove_candidate(mob/living/carbon/removed_candidate)
	removed_candidate.clear_alert("[owner]")
	LAZYREMOVE(possible_takers, removed_candidate)
	UnregisterSignal(removed_candidate, COMSIG_MOVABLE_MOVED)

	if(!possible_takers && !QDELING(src))
		qdel(src)

/// One of our possible takers moved, see if they left us hanging
/datum/status_effect/offering/proc/check_taker_in_range(mob/living/carbon/taker)
	SIGNAL_HANDLER
	if(owner.CanReach(taker) && !IS_DEAD_OR_INCAP(taker))
		return

/// The offerer moved, see if anyone is out of range now
/datum/status_effect/offering/proc/check_owner_in_range(mob/living/carbon/source)
	SIGNAL_HANDLER
	for(var/i in possible_takers)
		var/mob/living/carbon/checking_taker = i
		if(!istype(checking_taker) || !owner.CanReach(checking_taker) || IS_DEAD_OR_INCAP(checking_taker))
			remove_candidate(checking_taker)

/// We lost the item, give it up
/datum/status_effect/offering/proc/dropped_item(obj/item/source)
	SIGNAL_HANDLER
	qdel(src)
