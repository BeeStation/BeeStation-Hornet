/**
 * ### Blood Crawl
 *
 * Lets the caster enter and exit pools of blood.
 */
/datum/action/spell/jaunt/bloodcrawl
	name = "Blood Crawl"
	desc = "Allows you to phase in and out of existance via pools of blood."
	background_icon_state = "bg_demon"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "bloodcrawl"

	spell_requirements = NONE

	/// The time it takes to enter blood
	var/enter_blood_time = 0 SECONDS
	/// The time it takes to exit blood
	var/exit_blood_time = 2 SECONDS
	/// The radius around us that we look for blood in
	var/blood_radius = 1
	/// If TRUE, we equip "blood crawl" hands to the jaunter to prevent using items
	var/equip_blood_hands = TRUE

/datum/action/spell/jaunt/bloodcrawl/on_cast(mob/living/user, atom/target)
	. = ..()
	for(var/obj/effect/decal/cleanable/blood_nearby in range(blood_radius, get_turf(user)))
		if(blood_nearby.can_bloodcrawl_in())
			return do_bloodcrawl(blood_nearby, user)

	reset_spell_cooldown()
	to_chat(user, ("<span class='warning'>There must be a nearby source of blood!</span>"))

/**
 * Attempts to enter or exit the passed blood pool.
 * Returns TRUE if we successfully entered or exited said pool, FALSE otherwise
 */
/datum/action/spell/jaunt/bloodcrawl/proc/do_bloodcrawl(obj/effect/decal/cleanable/blood, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(blood, jaunter)
	else
		. = try_enter_jaunt(blood, jaunter)

	if(!.)
		reset_spell_cooldown()
		to_chat(jaunter, ("<span class='warning'>You are unable to blood crawl!</span>"))

/**
 * Attempts to enter the passed blood pool.
 * If forced is TRUE, it will override enter_blood_time.
 */
/datum/action/spell/jaunt/bloodcrawl/proc/try_enter_jaunt(obj/effect/decal/cleanable/blood, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(enter_blood_time > 0 SECONDS)
			blood.visible_message(("<span class='warning'>[jaunter] starts to sink into [blood]!</span>"))
			if(!do_after(jaunter, enter_blood_time, target = blood))
				return FALSE

	// The actual turf we enter
	var/turf/jaunt_turf = get_turf(blood)

	// Begin the jaunt
	jaunter.notransform = TRUE
	var/obj/effect/dummy/phased_mob/holder = enter_jaunt(jaunter, jaunt_turf)
	if(!holder)
		jaunter.notransform = FALSE
		return FALSE

	if(equip_blood_hands && iscarbon(jaunter))
		jaunter.drop_all_held_items()
		// Give them some bloody hands to prevent them from doing things
		var/obj/item/bloodcrawl/left_hand = new(jaunter)
		var/obj/item/bloodcrawl/right_hand = new(jaunter)
		left_hand.icon_state = "bloodhand_right" // Icons swapped intentionally..
		right_hand.icon_state = "bloodhand_left" // ..because perspective, or something
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	blood.visible_message(("<span class='warning'>[jaunter] sinks into [blood]!</span>"))
	playsound(jaunt_turf, 'sound/magic/enter_blood.ogg', 50, TRUE, -1)
	jaunter.extinguish_mob()

	jaunter.notransform = FALSE
	return TRUE

/**
 * Attempts to Exit the passed blood pool.
 * If forced is TRUE, it will override exit_blood_time, and if we're currently consuming someone.
 */
/datum/action/spell/jaunt/bloodcrawl/proc/try_exit_jaunt(obj/effect/decal/cleanable/blood, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(jaunter.notransform)
			to_chat(jaunter, ("<span class='warning'>You cannot exit yet!!</span>"))
			return FALSE

		if(exit_blood_time > 0 SECONDS)
			blood.visible_message(("<span class='warning'>[blood] starts to bubble...</span>"))
			if(!do_after(jaunter, exit_blood_time, target = blood))
				return FALSE

	if(!exit_jaunt(jaunter, get_turf(blood)))
		return FALSE

	if(equip_blood_hands && iscarbon(jaunter))
		for(var/obj/item/bloodcrawl/blood_hand in jaunter.held_items)
			jaunter.temporarilyRemoveItemFromInventory(blood_hand, force = TRUE)
			qdel(blood_hand)

	blood.visible_message(("<span class='boldwarning'>[jaunter] rises out of [blood]!</span>"))
	return TRUE

/datum/action/spell/jaunt/bloodcrawl/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	. = ..()
	if(!.)
		return

	exit_blood_effect(unjaunter)

/// Adds an coloring effect to mobs which exit blood crawl.
/datum/action/spell/jaunt/bloodcrawl/proc/exit_blood_effect(mob/living/exited)
	var/turf/landing_turf = get_turf(exited)
	playsound(landing_turf, 'sound/magic/exit_blood.ogg', 50, TRUE, -1)

	// Make the mob have the color of the blood pool it came out of
	var/obj/effect/decal/cleanable/came_from = locate() in landing_turf
	var/new_color = came_from?.get_blood_color()
	if(!new_color)
		return

	exited.add_atom_colour(new_color, TEMPORARY_COLOUR_PRIORITY)
	// ...but only for a few seconds
	addtimer(CALLBACK(exited, TYPE_PROC_REF(/atom, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, new_color), 6 SECONDS)

/**
 * Slaughter demon's blood crawl
 * Allows the blood crawler to consume people they are dragging.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon
	name = "Voracious Blood Crawl"
	desc = "Allows you to phase in and out of existance via pools of blood. If you are dragging someone in critical or dead, \
		they will be consumed by you, fully healing you."
	/// The sound played when someone's consumed.
	var/consume_sound = 'sound/magic/demon_consume.ogg'

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/try_enter_jaunt(obj/effect/decal/cleanable/blood, mob/living/jaunter)
	// Save this before the actual jaunt
	var/atom/coming_with = jaunter.pulling

	// Does the actual jaunt
	. = ..()
	if(!.)
		return

	var/turf/jaunt_turf = get_turf(jaunter)
	// if we're not pulling anyone, or we can't what we're pulling
	if(!isliving(coming_with))
		return

	var/mob/living/victim = coming_with

	if(victim.stat == CONSCIOUS)
		jaunt_turf.visible_message(
			("<span class='warning'>[victim] kicks free of [blood] just before entering it!</span>"),
			blind_message = ("<span class='notice'>You hear splashing and struggling.</span>"),
		)
		return FALSE

	if(SEND_SIGNAL(victim, COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED, src, jaunter, blood) & COMPONENT_STOP_CONSUMPTION)
		return FALSE

	victim.forceMove(jaunter)
	victim.emote("scream")
	jaunt_turf.visible_message(
		("<span class='boldwarning'>[jaunter] drags [victim] into [blood]!</span>"),
		blind_message = ("<span class='notice'>You hear a splash.</span>"),
	)

	jaunter.notransform = TRUE
	consume_victim(victim, jaunter)
	jaunter.notransform = FALSE

	return TRUE

/**
 * Consumes the [victim] from the [jaunter], fully healing them
 * and calling [proc/on_victim_consumed] if successful.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/proc/consume_victim(mob/living/victim, mob/living/jaunter)
	on_victim_start_consume(victim, jaunter)

	for(var/i in 1 to 3)
		playsound(get_turf(jaunter), consume_sound, 50, TRUE)
		if(!do_after(jaunter, 3 SECONDS, victim))
			to_chat(jaunter, ("<span class='danger'>You lose your victim!</span>"))
			return FALSE
		if(QDELETED(src))
			return FALSE

	if(SEND_SIGNAL(victim, COMSIG_LIVING_BLOOD_CRAWL_CONSUMED, src, jaunter) & COMPONENT_STOP_CONSUMPTION)
		return FALSE

	jaunter.revive(HEAL_ALL)

	// No defib possible after laughter
	victim.apply_damage(1000, BRUTE)
	victim.death()
	on_victim_consumed(victim, jaunter)

/**
 * Called when a victim starts to be consumed.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/proc/on_victim_start_consume(mob/living/victim, mob/living/jaunter)
	to_chat(jaunter, ("<span class='danger'>You begin to feast on [victim]... You can not move while you are doing this.</span>"))

/**
 * Called when a victim is successfully consumed.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/proc/on_victim_consumed(mob/living/victim, mob/living/jaunter)
	to_chat(jaunter, ("<span class='danger'>You devour [victim]. Your health is fully restored.</span>"))
	qdel(victim)

/**
 * Laughter demon's blood crawl
 * All mobs consumed are revived after the demon is killed.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny
	name = "Friendly Blood Crawl"
	desc = "Allows you to phase in and out of existance via pools of blood. If you are dragging someone in critical or dead - I mean, \
		sleeping, when entering a blood pool, they will be invited to a party and fully heal you!"
	consume_sound = 'sound/misc/scary_horn.ogg'

	// Keep the people we hug!
	var/list/mob/living/consumed_mobs = list()

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/Destroy()
	consumed_mobs.Cut()
	return ..()

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/Remove(mob/living/remove_from)
	UnregisterSignal(remove_from, COMSIG_LIVING_DEATH)
	return ..()

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/on_victim_start_consume(mob/living/victim, mob/living/jaunter)
	to_chat(jaunter, ("<span class='clown'>You invite [victim] to your party! You can not move while you are doing this.</span>"))

/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/on_victim_consumed(mob/living/victim, mob/living/jaunter)
	to_chat(jaunter, ("<span class='clown'>[victim] joins your party! Your health is fully restored.</span>"))
	consumed_mobs += victim
	RegisterSignal(victim, COMSIG_MOB_STATCHANGE, PROC_REF(on_victim_statchange))
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_victim_deleted))

/**
 * Signal proc for COMSIG_LIVING_DEATH and COMSIG_QDELETING
 *
 * If our demon is deleted or destroyed, expel all of our consumed mobs
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/proc/on_death(datum/source)
	SIGNAL_HANDLER

	var/turf/release_turf = get_turf(source)
	for(var/mob/living/friend as anything in consumed_mobs)

		// Unregister the signals first
		UnregisterSignal(friend, list(COMSIG_MOB_STATCHANGE, COMSIG_QDELETING))

		friend.forceMove(release_turf)
		// Heals them back to state one
		if(!friend.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE))
			continue
		playsound(release_turf, consumed_mobs, 50, TRUE, -1)
		to_chat(friend, ("<span class='clown'>You leave [source]'s warm embrace, and feel ready to take on the world.</span>"))


/**
 * Handle signal from a consumed mob changing stat.
 *
 * A signal handler for if one of the laughter demon's consumed mobs has
 * changed stat. If they're no longer dead (because they were dead when
 * swallowed), eject them so they can't rip their way out from the inside.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/proc/on_victim_statchange(mob/living/victim, new_stat)
	SIGNAL_HANDLER

	if(new_stat == DEAD)
		return
	// Someone we've eaten has spontaneously revived; maybe regen coma, maybe a changeling
	victim.forceMove(get_turf(victim))
	victim.visible_message(("<span class='warning'>[victim] falls out of the air, covered in blood, with a confused look on their face.</span>"))
	exit_blood_effect(victim)

	consumed_mobs -= victim
	UnregisterSignal(victim, COMSIG_MOB_STATCHANGE)

/**
 * Handle signal from a consumed mob being deleted. Clears any references.
 */
/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny/proc/on_victim_deleted(datum/source)
	SIGNAL_HANDLER

	consumed_mobs -= source

/// Bloodcrawl "hands", prevent the user from holding items in bloodcrawl
/obj/item/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	item_flags = ABSTRACT | DROPDEL

/obj/item/bloodcrawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
