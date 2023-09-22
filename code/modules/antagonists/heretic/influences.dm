/// The number of influences spawned per heretic
#define NUM_INFLUENCES_PER_HERETIC 4
/// The minimum amount of time until midround influences begin to spawn
#define MIDROUND_INFLUENCE_MIN_TIME	25 MINUTES
/// The maximum amount of time until midround influences begin to spawn
#define MIDROUND_INFLUENCE_MAX_TIME	40 MINUTES
/// How many tiles to "fuzz" the influence spawn location by.
#define HERETIC_INFLUENCE_SPAWN_FUZZ 5

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
	/// List of visible influences (harvested reality smashes)
	var/list/obj/effect/visible_heretic_influence/visible_smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()


/datum/reality_smash_tracker/Destroy()
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	QDEL_LIST(smashes)
	tracked_heretics.Cut()
	return ..()

/datum/reality_smash_tracker/proc/start_midround_influence_timer()
	var/time = FLOOR(rand(MIDROUND_INFLUENCE_MIN_TIME, MIDROUND_INFLUENCE_MAX_TIME), 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(spawn_midround_influences)), time, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

/**
 * Generates some random new influences in the middle of the round for each heretic,
 * regardless of pre-existing heretics.
 */
/datum/reality_smash_tracker/proc/spawn_midround_influences()
	start_midround_influence_timer()
	var/living_heretics = 0
	for(var/datum/mind/heretic_mind as anything in tracked_heretics)
		var/mob/living/carbon/heretic_body = heretic_mind.current
		var/datum/antagonist/heretic/heretic_datum = heretic_mind.has_antag_datum(/datum/antagonist/heretic)
		if(QDELETED(heretic_datum))
			continue
		if(heretic_datum.ascended)
			continue
		if(heretic_datum.can_ascend() && heretic_datum.get_knowledge(/datum/heretic_knowledge/final, subtypes = TRUE))
			continue
		if(QDELETED(heretic_body) || !istype(heretic_body))
			continue
		if(!heretic_body.ckey || heretic_body.stat == DEAD || heretic_body.InFullCritical())
			continue
		living_heretics++
	if(!living_heretics)
		return
	var/influences_to_spawn = rand(1, 3)
	for(var/heretic_number = 1 to living_heretics)
		influences_to_spawn += max(NUM_INFLUENCES_PER_HERETIC - heretic_number, 1)
	log_game("Spawning [influences_to_spawn] new midround influences for heretics")
	INVOKE_ASYNC(src, PROC_REF(generate_new_influences), influences_to_spawn)

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
/datum/reality_smash_tracker/proc/generate_new_influences(amount)
	/// Static list of station areas which would otherwise be valid, but we don't want to spawn influences in.
	var/static/list/station_area_blacklist = typecacheof(list(
		/area/chapel/office,
		/area/commons/dorms/barracks,
		/area/crew_quarters/theatre/abandoned,
		/area/crew_quarters/theatre/backstage,
		/area/hallway/secondary/asteroid,
		/area/hallway/secondary/command,
		/area/hallway/secondary/construction,
		/area/hallway/secondary/service,
		/area/hallway/upper/secondary/command,
		/area/hallway/upper/secondary/construction,
		/area/hallway/upper/secondary/service,
		/area/holodeck/rec_center/offstation_one,
		/area/hydroponics/garden/abandoned,
		/area/library/abandoned
	))
	/// Static list of station areas we will attempt to spawn influences in the general vicinity of.
	var/static/list/public_station_areas = typecacheof(list(
		/area/cargo/lobby,
		/area/chapel,
		/area/commons/dorms,
		/area/crew_quarters/cafeteria,
		/area/crew_quarters/fitness,
		/area/crew_quarters/locker,
		/area/crew_quarters/lounge,
		/area/crew_quarters/park,
		/area/crew_quarters/theatre,
		/area/crew_quarters/toilet,
		/area/hallway,
		/area/holodeck/rec_center,
		/area/hydroponics/garden,
		/area/library,
		/area/medical/medbay/central,
		/area/medical/medbay/lobby,
		/area/medical/sleeper,
		/area/science/lobby,
		/area/storage/art,
		/area/storage/primary,
		/area/storage/tools
	)) - station_area_blacklist
	/// Static typecache of 'secondary' areas that should be weighted less.
	var/static/list/low_weight_areas = typecacheof(/area/security/checkpoint)
	/// Static typecache of the areas we will NEVER spawn influences in.
	var/static/list/forbidden_influence_areas = (typecacheof(list(
		/area/ai_monitored,
		/area/asteroid,
		/area/bridge,
		/area/comms,
		/area/crew_quarters/heads,
		/area/docking,
		/area/drydock,
		/area/engine/atmospherics_engine,
		/area/engine/engine_room,
		/area/engine/gravity_generator,
		/area/engine/transit_tube,
		/area/gateway,
		/area/maintenance,
		/area/medical/abandoned,
		/area/quartermaster/qm,
		/area/quartermaster/qm_bedroom,
		/area/science/mixing/chamber,
		/area/security,
		/area/server,
		/area/shuttle,
		/area/solar,
		/area/space,
		/area/tcommsat,
		/area/teleporter
	)) + station_area_blacklist) - low_weight_areas

	if(!isnum_safe(amount) || amount <= 0)
		// 1 heretic = 4 influences
		// 2 heretics = 7 influences
		// 3 heretics = 9 influences
		// 4 heretics = 10 influences, +1 for each onwards.
		var/max_amount = 0
		for(var/heretic_number in 1 to length(tracked_heretics))
			max_amount += max(NUM_INFLUENCES_PER_HERETIC - heretic_number + 1, 1)
		amount = max_amount - (length(smashes) + num_drained)
		// Don't bother doing all this stuff if we've made enough influences already.
		if(amount <= 0)
			rework_network()
			return

	var/location_sanity = 0
	var/list/primary_turfs = list()
	var/list/banned_turfs = list()
	// Ensure at least 1 tile of seperation between other influences.
	for(var/obj/smash as anything in smashes + visible_smashes)
		var/turf/smash_loc = get_turf(smash)
		for(var/near_smash in RANGE_TURFS(1, smash_loc))
			banned_turfs[near_smash] = TRUE
	for(var/area/area_to_check as anything in GLOB.areas)
		if(!is_type_in_typecache(area_to_check, public_station_areas))
			continue
		for(var/turf/open/floor/floor in area_to_check.get_contained_turfs())
			if(banned_turfs[floor])
				continue
			primary_turfs |= floor
	if(!length(primary_turfs))
		CRASH("Could not find any valid turfs to spawn heretic influences on!")
	var/spawned = 0
	while(length(primary_turfs) && spawned < amount && location_sanity < 100)
		var/turf/chosen_location = pick_n_take(primary_turfs)
		var/list/eligible_locations = list()
		var/list/tested_turfs = list()
		view_loop:
			for(var/turf/open/floor/possibility in view(HERETIC_INFLUENCE_SPAWN_FUZZ, chosen_location))
				// Ensure we don't waste any time re-checking the same turf (or a banned turf)
				if(tested_turfs[possibility] || banned_turfs[possibility])
					continue
				tested_turfs[possibility] = TRUE
				var/area/area = get_area(possibility)
				// Ensure the turf isn't in an outright forbidden area
				if(is_type_in_typecache(area, forbidden_influence_areas))
					continue
				// Ensure all adjacent turfs are open (i.e no tiny rooms)
				for(var/turf/nearby_turf as anything in RANGE_TURFS(1, possibility))
					if(!isfloorturf(nearby_turf))
						continue view_loop
				// Ensure there's no dense objects on this turf
				for(var/obj/thingymajig as anything in possibility) // Minor optimization: don't filter the list for objs beforehand, as we're going to break on the first dense obj anyways.
					if(istype(thingymajig) && (thingymajig.density || initial(thingymajig.density)))
						continue view_loop
				// Ensure the turf is safe
				if(!is_turf_safe(possibility))
					continue
				// Lower weight for certain areas, and add it to our list of eligible locations
				eligible_locations[possibility] = is_type_in_typecache(area, low_weight_areas) ? 1 : 5
		if(!length(eligible_locations))
			location_sanity++
			continue
		var/turf/chosen_turf = pick_weight(eligible_locations)
		if(QDELETED(chosen_turf))
			location_sanity++
			continue
		for(var/near_chosen in RANGE_TURFS(1, chosen_turf))
			banned_turfs[near_chosen] = TRUE
			primary_turfs -= near_chosen
		new /obj/effect/heretic_influence(chosen_turf)
		spawned++

	rework_network()

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	// First heretic? Set up our midround timer!
	if(!length(tracked_heretics))
		start_midround_influence_timer()
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

/obj/effect/visible_heretic_influence/Initialize()
	. = ..()
	GLOB.reality_smash_track.visible_smashes += src
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)

	var/image/silicon_image = image('icons/effects/heretic.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", silicon_image)
	addtimer(CALLBACK(src, PROC_REF(dissipate)), 1 MINUTES)

/obj/effect/visible_heretic_influence/Destroy()
	GLOB.reality_smash_track.visible_smashes -= src
	return ..()

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	animate(src, alpha = 255, time = 15 SECONDS)

/obj/effect/visible_heretic_influence/proc/dissipate()
	animate(src,alpha = 0, time = 15 SECONDS)
	QDEL_IN(src, 15 SECONDS)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !ishuman(user))
		return
	if(IS_HERETIC_OR_MONSTER(user))
		to_chat(user, "<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
		return TRUE
	var/mob/living/carbon/human/human_user = user
	var/obj/item/bodypart/their_poor_arm = human_user.get_active_hand()
	// om nom nom
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
	if(IS_HERETIC_OR_MONSTER(user))
		to_chat(user, "<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
		return
	var/mob/living/carbon/human/human_user = user
	// A very elaborate way to suicide
	to_chat(human_user, "<span class='userdanger'>Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!</span>")
	human_user.ghostize()
	// Your head asplode!
	var/obj/item/bodypart/head/head = locate() in human_user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
		qdel(head)
	else
		human_user.gib()
	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start(src)

/obj/effect/visible_heretic_influence/examine(mob/living/carbon/human/user)
	. = ..()
	if(!istype(user) || IS_HERETIC_OR_MONSTER(user))
		return
	to_chat(user, "<span class='userdanger'>Your mind burns as you stare at the tear!</span>")
	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

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
	// Actually grant the heretic their well-earned knowledge
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.adjust_knowledge_points(knowledge_to_gain)
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
/obj/effect/heretic_influence/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!IS_HERETIC_OR_MONSTER(user) && prob(50))
		return
	examine_list += "<span class='warning'>[source.p_their(TRUE)] hand seems to be glowing a <span class='hypnophrase'>ominous, cosmic purple</span>...</span>"

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

#undef HERETIC_INFLUENCE_SPAWN_FUZZ
#undef MIDROUND_INFLUENCE_MAX_TIME
#undef MIDROUND_INFLUENCE_MIN_TIME
#undef NUM_INFLUENCES_PER_HERETIC
