
/// The number of influences spawned per heretic
#define NUM_INFLUENCES_PER_HERETIC 4

/**
 * #Reality smash tracker
 *
 * A global singleton data that tracks all the heretic
 * influences ("reality smashes") that we've created,
 * and all of the heretics (minds) that can see them.
 *
 * Handles ensuring all minds can see influences, generating
 * new influences for new heretic minds, and allowing heretics
 * to see new influences that are created.
 */
/datum/reality_smash_tracker
	/// The total number of influences that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/heretic_influence/smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/**
 * Automatically fixes the target and smash network
 *
 * Fixes any bugs that are caused by late Generate() or exchanging clients
 */
/datum/reality_smash_tracker/proc/rework_network()
	SIGNAL_HANDLER

	for(var/mind in tracked_heretics)
		if(isnull(mind))
			stack_trace("A null somehow landed in the [type] list of minds. How?")
			tracked_heretics -= mind
			continue

		add_to_smashes(mind)

/**
 * Allow [to_add] to see all tracked reality smashes.
 */
/datum/reality_smash_tracker/proc/add_to_smashes(datum/mind/to_add)
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		reality_smash.add_mind(to_add)

/**
 * Stop [to_remove] from seeing any tracked reality smashes.
 */
/datum/reality_smash_tracker/proc/remove_from_smashes(datum/mind/to_remove)
	for(var/obj/effect/heretic_influence/reality_smash as anything in smashes)
		reality_smash.remove_mind(to_remove)

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/reality_smash_tracker/proc/generate_new_influences()
	// 1 heretic = 4 influences
	// 2 heretics = 7 influences
	// 3 heretics = 9 influences
	// 4 heretics = 10 influences, +1 for each onwards.
	var/how_many_can_we_make = 0
	for(var/heretic_number in 1 to length(tracked_heretics))
		how_many_can_we_make += max(NUM_INFLUENCES_PER_HERETIC - heretic_number + 1, 1)

	var/location_sanity = 0
	while((length(smashes) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turfs()

		// We don't want them close to each other - at least 1 tile of seperation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/heretic_influence(chosen_location)

	rework_network()

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	tracked_heretics |= heretic

	// If our heretic's on station, generate some new influences
	if(ishuman(heretic.current) && !is_centcom_level(heretic.current.z))
		generate_new_influences()

	add_to_smashes(heretic)


/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	tracked_heretics -= heretic

	remove_from_smashes(heretic)

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/heretic.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)

	var/image/silicon_image = image('icons/effects/heretic.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)
	addtimer(CALLBACK(src,PROC_REF(dissipate)), 60 SECONDS)
/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	animate(src, alpha = 255, time = 15 SECONDS)

/obj/effect/visible_heretic_influence/proc/dissipate()
	animate(src,alpha = 0,time = 15 SECONDS)
	QDEL_IN(src, 15 SECONDS)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	if(IS_HERETIC(user))
		to_chat(user, "<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
		return TRUE

	var/mob/living/carbon/human/human_user = user
	var/obj/item/bodypart/their_poor_arm = human_user.get_active_hand()
	if(prob(25))
		to_chat(human_user, "<span class='userdanger'>An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!</span>")
		their_poor_arm.dismember()
		qdel(their_poor_arm)
	else
		to_chat(human_user,"<span class='danger'>You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existance itself!</span>")
	return TRUE

/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(IS_HERETIC(user))
		to_chat(user, "<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
		return

	var/mob/living/carbon/human/human_user = user

	// A very elaborate way to suicide
	to_chat(human_user, "<span class='userdanger'>Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!</span>")
	human_user.ghostize()
	var/obj/item/bodypart/head/head = locate() in human_user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
		qdel(head)
	else
		human_user.gib()

	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start(src)

/obj/effect/visible_heretic_influence/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user) || !ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, "<span class='userdanger'>Your mind burns as you stare at the tear!</span>")
	human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	SEND_SIGNAL(human_user, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/heretic_influence
	name = "reality smash"
	icon = 'icons/effects/heretic.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_SPIRIT
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE
	/// The icon state applied to the image created for this influence.
	var/real_icon_state = "reality_smash"
	/// A list of all minds that can see us.
	var/list/datum/mind/minds = list()
	/// The image shown to heretics
	var/image/heretic_image

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	heretic_image = image(icon, src, real_icon_state, OBJ_LAYER)
	generate_name()

/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	for(var/datum/mind/heretic in minds)
		remove_mind(heretic)

	heretic_image = null
	return ..()

/obj/effect/heretic_influence/attack_hand(mob/user, list/modifiers)
	if(!IS_HERETIC(user)) // Shouldn't be able to do this, but just in case
		return

	if(being_drained)
		balloon_alert(user, "Already being drained")
	else
		INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 1)

	return

/obj/effect/heretic_influence/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(.)
		return

	// Using a codex will give you two knowledge points for draining.
	if(!being_drained && istype(weapon, /obj/item/codex_cicatrix))
		var/obj/item/codex_cicatrix/codex = weapon
		codex.open_animation()
		INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 2)
		return TRUE


/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user, knowledge_to_gain)

	being_drained = TRUE
	balloon_alert(user, "You begin draining the influence")
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	if(!do_after(user, 10 SECONDS, target = src))
		being_drained = FALSE
		balloon_alert(user, "Interrupted")
		UnregisterSignal(user, COMSIG_PARENT_EXAMINE)
		return

	// We don't need to set being_drained back since we delete after anyways
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE)
	balloon_alert(user, "Influence drained")

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.knowledge_points += knowledge_to_gain

	// Aaand now we delete it
	after_drain(user)

/*
 * Handle the effects of the drain.
 */
/obj/effect/heretic_influence/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, "<span class='hypnophrase'>[pick(strings(HERETIC_INFLUENCE_FILE, "drain_message"))]</span>")
		to_chat(user, "<span class='warning'>[src] begins to fade into reality!</span>")

	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = "\improper" + pick(strings(HERETIC_INFLUENCE_FILE, "drained")) + " " + format_text(name)

	GLOB.reality_smash_track.num_drained++
	qdel(src)

/*
 * Signal proc for [COMSIG_PARENT_EXAMINE], registered on the user draining the influence.
 *
 * Gives a chance for examiners to see that the heretic is interacting with an infuence.
 */
/obj/effect/heretic_influence/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(prob(50))
		return

	examine_list += "<span class='warning'>[source]'s hand seems to be glowing a ["<span class='hypnophrase'>strange purple</span>"]...</span>"

/*
 * Add a mind to the list of tracked minds,
 * making another person able to see us.
 */
/obj/effect/heretic_influence/proc/add_mind(datum/mind/heretic)
	minds |= heretic
	heretic.current?.client?.images |= heretic_image

/*
 * Remove a mind present in our list
 * from being able to see us.
 */
/obj/effect/heretic_influence/proc/remove_mind(datum/mind/heretic)
	if(!(heretic in minds))
		CRASH("[type] - remove_mind called with a mind not present in the minds list!")

	minds -= heretic
	heretic.current?.client?.images -= heretic_image

/*
 * Generates a random name for the influence.
 */
/obj/effect/heretic_influence/proc/generate_name()
	name = "\improper" + pick(strings(HERETIC_INFLUENCE_FILE, "prefix")) + " " + pick(strings(HERETIC_INFLUENCE_FILE, "postfix"))

#undef NUM_INFLUENCES_PER_HERETIC
