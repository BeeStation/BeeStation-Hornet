/// The base distance a wizard rod will go without upgrades.
#define BASE_WIZ_ROD_RANGE 13

/datum/action/spell/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. \
		Purchasing this spell multiple times will also increase the rod's damage and travel range."
	button_icon_state = "immrod"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 25 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS

	invocation = "CLANG!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_OFF_CENTCOM

	/// The extra distance we travel per additional spell level.
	var/distance_per_spell_rank = 3
	/// The extra damage we deal per additional spell level.
	var/damage_per_spell_rank = 20
	/// The max distance the rod goes on cast
	var/rod_max_distance = BASE_WIZ_ROD_RANGE
	/// The damage bonus applied to the rod on cast
	var/rod_damage_bonus = 0

/datum/action/spell/rod_form/on_cast(mob/user, atom/target)
	. = ..()
	// The destination turf of the rod - just a bit over the max range we calculated, for safety
	var/turf/distant_turf = get_ranged_target_turf(get_turf(user), user.dir, (rod_max_distance + 2))

	new /obj/effect/immovablerod/wizard(
		get_turf(user),
		distant_turf,
		null,
		FALSE,
		user,
		rod_max_distance,
		rod_damage_bonus,
	)

/datum/action/spell/rod_form/level_spell(bypass_cap = FALSE)
	. = ..()
	if(!.)
		return FALSE

	rod_max_distance += distance_per_spell_rank
	rod_damage_bonus += damage_per_spell_rank
	return TRUE

/datum/action/spell/rod_form/delevel_spell()
	. = ..()
	if(!.)
		return FALSE

	rod_max_distance -= distance_per_spell_rank
	rod_damage_bonus -= damage_per_spell_rank
	return TRUE

/// Wizard Version of the Immovable Rod.
/obj/effect/immovablerod/wizard
	notify = FALSE
	/// The wizard who's piloting our rod.
	var/datum/weakref/our_wizard
	/// The distance the rod will go.
	var/max_distance = BASE_WIZ_ROD_RANGE
	/// The damage bonus of the rod when it smacks people.
	var/damage_bonus = 0
	/// The turf the rod started from, to calcuate distance.
	var/turf/start_turf
/obj/effect/immovablerod/wizard/Initialize(mapload, atom/target_atom, atom/specific_target, force_looping = FALSE, mob/living/wizard, max_distance = BASE_WIZ_ROD_RANGE, damage_bonus = 0)
	. = ..()
	if(wizard)
		set_wizard(wizard)
	start_turf = get_turf(src)
	src.max_distance = max_distance
	src.damage_bonus = damage_bonus
/obj/effect/immovablerod/wizard/Destroy(force)
	start_turf = null
	return ..()
/obj/effect/immovablerod/wizard/Move()
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		stop_travel()
		return
	return ..()
/obj/effect/immovablerod/wizard/penetrate(mob/living/penetrated)
	if(penetrated.can_block_magic())
		penetrated.visible_message(
			("<span class='danger'>[src] hits [penetrated], but it bounces back, then vanishes!</span>"),
			("<span class='userdanger'>[src] hits you... but it bounces back, then vanishes!</span>"),
			("<span class='danger'>You hear a weak, sad, CLANG.</span>")
			)
		stop_travel()
		return
	penetrated.visible_message(
		("<span class='danger'>[penetrated] is penetrated by an immovable rod!</span>"),
		("<span class='userdanger'>The [src] penetrates you!</span>"),
		("<span class='danger'>You hear a CLANG!</span>"),
		)
	penetrated.adjustBruteLoss(70 + damage_bonus)

/**
 * Called when the wizard rod reaches it's maximum distance
 * or is otherwise stopped by something.
 * Dumps out the wizard, and deletes.
 */
/obj/effect/immovablerod/wizard/proc/stop_travel()
	eject_wizard()
	qdel(src)
/**
 * Set wizard as our_wizard, placing them in the rod
 * and preparing them for travel.
 */
/obj/effect/immovablerod/wizard/proc/set_wizard(mob/living/wizard)
	our_wizard = WEAKREF(wizard)
	wizard.forceMove(src)
	wizard.notransform = TRUE
	wizard.add_traits(list(TRAIT_GODMODE, TRAIT_MAGICALLY_PHASED), "[type]")

/**
 * Eject our current wizard, removing them from the rod
 * and fixing all of the variables we changed.
 */
/obj/effect/immovablerod/wizard/proc/eject_wizard()
	var/mob/living/wizard = our_wizard?.resolve()
	if(QDELETED(wizard))
		return
	wizard.notransform = FALSE
	wizard.forceMove(get_turf(src))
	our_wizard = null
	wizard.remove_traits(list(TRAIT_GODMODE, TRAIT_MAGICALLY_PHASED), "[type]")

#undef BASE_WIZ_ROD_RANGE
