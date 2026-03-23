// Some general sidepath options.

/// Shield integrity for the Mansus Barrier
#define MANSUS_BARRIER_MAX_INTEGRITY 80
/// Charge recovery per tick for the Mansus Barrier
#define MANSUS_BARRIER_CHARGE_RECOVERY 10
/// How long before the Mansus Barrier starts recharging after being hit
#define MANSUS_BARRIER_RECHARGE_DELAY (10 SECONDS)


// I dunno, this seems like a wacky way to do it. But it works, so eh.
/datum/heretic_knowledge/mansus_barrier
	name = "Mansus Barrier"
	desc = "The Mansus shields those who walk its path. \
		While wearing a focus, you are protected by an energy shield that absorbs incoming attacks. \
		The shield recharges over time when not taking damage."
	gain_text = "I stepped between the worlds and felt it - an invisible aegis, \
		woven from the fabric of the Mansus itself. The heathens' weapons faltered against it."
	cost = 1
	route = HERETIC_PATH_SIDE
	/// Weakref to the focus item currently carrying our shielded component.
	var/datum/weakref/shielded_focus_ref

/datum/heretic_knowledge/mansus_barrier/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_equipped))
	RegisterSignal(user, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_unequipped))
	// Check if the heretic already has a focus equipped
	if(HAS_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING))
		apply_shield(user)

/datum/heretic_knowledge/mansus_barrier/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, list(SIGNAL_ADDTRAIT(TRAIT_ALLOW_HERETIC_CASTING), SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING)))
	remove_shield()

/datum/heretic_knowledge/mansus_barrier/proc/on_focus_equipped(mob/user)
	SIGNAL_HANDLER
	apply_shield(user)
	to_chat(user, span_cultlarge("You feel an invisible protective barrier envelop you. Their guns will do them no good, now."))

/datum/heretic_knowledge/mansus_barrier/proc/on_focus_unequipped(mob/user)
	SIGNAL_HANDLER
	remove_shield()
	to_chat(user, span_cultlarge("You feel the protection of the Mansus leave you. You are vulnerable once more."))

/// Finds a worn focus item on the user and adds the shielded component to it.
/datum/heretic_knowledge/mansus_barrier/proc/apply_shield(mob/user)
	if(shielded_focus_ref?.resolve())
		return // Already have a shield active
	var/obj/item/focus_item = find_focus_item(user)
	if(!focus_item)
		return
	focus_item.AddComponent(/datum/component/shielded, \
		max_integrity = MANSUS_BARRIER_MAX_INTEGRITY, \
		charge_recovery = MANSUS_BARRIER_CHARGE_RECOVERY, \
		recharge_start_delay = MANSUS_BARRIER_RECHARGE_DELAY, \
		charge_increment_delay = 1 SECONDS, \
		shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_INVISIBLE, \
	)
	shielded_focus_ref = WEAKREF(focus_item)
	RegisterSignal(focus_item, COMSIG_ITEM_DROPPED, PROC_REF(on_focus_dropped))

/// Removes the shielded component from the current focus item.
/datum/heretic_knowledge/mansus_barrier/proc/remove_shield()
	var/obj/item/old_focus = shielded_focus_ref?.resolve()
	if(old_focus)
		UnregisterSignal(old_focus, COMSIG_ITEM_DROPPED)
		var/datum/component/shielded/shield = old_focus.GetComponent(/datum/component/shielded)
		if(shield)
			qdel(shield)
	shielded_focus_ref = null

/// Called when the focus item carrying our shield is dropped.
/datum/heretic_knowledge/mansus_barrier/proc/on_focus_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	remove_shield()
	// If we still have the casting trait (another focus is equipped), try to move the shield
	if(HAS_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING))
		apply_shield(user)

/// Searches the user's worn items for a heretic focus.
/datum/heretic_knowledge/mansus_barrier/proc/find_focus_item(mob/user)
	if(!ishuman(user))
		return null
	var/mob/living/carbon/human/human_user = user
	// Check all worn slots that could contain a focus
	var/list/check_items = list(human_user.wear_neck, human_user.head, human_user.wear_suit, human_user.w_uniform, human_user.belt)
	for(var/obj/item/candidate as anything in check_items)
		if(!candidate)
			continue
		// Check if this item is providing the heretic casting trait via the heretic_focus element
		if(HAS_TRAIT_FROM(user, TRAIT_ALLOW_HERETIC_CASTING, ELEMENT_TRAIT(candidate)))
			return candidate
	return null

#undef MANSUS_BARRIER_MAX_INTEGRITY
#undef MANSUS_BARRIER_CHARGE_RECOVERY
#undef MANSUS_BARRIER_RECHARGE_DELAY

/datum/heretic_knowledge/reroll_targets
	name = "The Relentless Heartbeat"
	desc = "Allows you transmute a flower, a book, and a jumpsuit while standing over a rune \
		to reroll your sacrifice targets."
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list(
		/obj/item/food/grown/flower = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
	)
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// Check first if they have a Living Heart. If it's missing, we should
	// throw a fail to show the heretic that there's no point in rerolling
	// if you don't have a heart to track the targets in the first place.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "ritual failed, no living heart!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	LAZYCLEARLIST(heretic_datum.sac_targets)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		loc.balloon_alert(user, "Ritual failed, no targets found!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to transmute a bible, a fountain pen, and hide from an animal (or human) to create a Codex Cicatrix. \
		The Codex Cicatrix can be used when draining influences to gain additional knowledge, but comes at greater risk of being noticed. \
		It can also be used to draw and remove transmutation runes easier."
	gain_text = "The occult leaves fragments of knowledge and power anywhere and everywhere. The Codex Cicatrix is one such example. \
		Within the leather-bound faces and age old pages, a path into the Mansus is revealed."
	required_atoms = list(
		/obj/item/storage/book/bible = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/stack/sheet/animalhide = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	route = HERETIC_PATH_SIDE
