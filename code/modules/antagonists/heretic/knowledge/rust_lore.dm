/**
 * # The path of Rust.
 *
 * Goes as follows:
 *
 * Blacksmith's Tale
 * Grasp of Rust
 * Leeching Walk
 * > Sidepaths:
 *   Priest's Ritual
 *   Armorer's Ritual
 *
 * Mark of Rust
 * Aggressive Spread
 * > Sidepaths:
 *   Curse of Corrosion
 *   Mawed Crucible
 *
 * Toxic Blade
 * Entropic Plume
 * > Sidepaths:
 *   Rusted Ritual
 *   Blood Cleave
 *
 * Rustbringer's Oath
 */
/datum/heretic_knowledge/limited_amount/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. \
		Allows you to transmute a knife with any trash item into a Rusty Blade. \
		You can only create two at a time."
	gain_text = "\"Let me tell you a story\", said the Blacksmith, as he gazed deep into his rusty blade."
	next_knowledge = list(/datum/heretic_knowledge/rust_fist)
	banned_knowledge = list(
		/datum/heretic_knowledge/limited_amount/base_ash,
		/datum/heretic_knowledge/limited_amount/base_flesh,
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/limited_amount/base_void,
		)
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/trash = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	limit = 2
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 5
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/limited_amount/base_rust/on_research(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.heretic_path = route

/datum/heretic_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Your Mansus Grasp will deal 500 damage to non-living matter and rust any surface it touches. \
		Already rusted surfaces are destroyed. Surfaces and structures can only be rusted by using Disarm intent."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	next_knowledge = list(/datum/heretic_knowledge/rust_regen)
	cost = 1
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/rust_fist/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/rust_fist/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	return target.rust_heretic_act()


/datum/heretic_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Grants you passive healing and stun resistance while standing over rust."
	gain_text = "The speed was unparalleled, the strength unnatural. The Blacksmith was smiling."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/armor,
		/datum/heretic_knowledge/essence,
	)
	cost = 1
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/rust_regen/on_gain(mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/heretic_knowledge/rust_regen/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have stun resistance on the new turf.
 */
/datum/heretic_knowledge/rust_regen/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_STUNRESISTANCE, type)
		return

	REMOVE_TRAIT(source, TRAIT_STUNRESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including stuns and stamina damage.
 */
/datum/heretic_knowledge/rust_regen/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	source.adjustBruteLoss(-2, FALSE)
	source.adjustFireLoss(-2, FALSE)
	source.adjustToxLoss(-2, FALSE, forced = TRUE)
	source.adjustOxyLoss(-0.5, FALSE)
	source.adjustStaminaLoss(-2)
	source.AdjustAllImmobility(-5)

/datum/heretic_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust. The mark is triggered from an attack with your Rusty Blade. \
		When triggered, the victim's organs and equipment will have a 75% chance to sustain damage and may be destroyed."
	gain_text = "The Blacksmith looks away. To a place lost long ago. \"The Rusted Hills help those in dire need... at a cost.\""
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/rust)
	banned_knowledge = list(
		/datum/heretic_knowledge/ash_mark,
		/datum/heretic_knowledge/flesh_mark,
		/datum/heretic_knowledge/void_mark,
	)
	cost = 2
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/rust_mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))

/datum/heretic_knowledge/rust_mark/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/rust_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/heretic_mark/rust)

/datum/heretic_knowledge/rust_mark/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/heretic_mark/mark = target.has_status_effect(/datum/status_effect/heretic_mark)
	if(!istype(mark))
		return

	mark.on_effect()

/datum/heretic_knowledge/knowledge_ritual/rust
	next_knowledge = list(/datum/heretic_knowledge/spell/area_conversion)
	banned_knowledge = list(
		/datum/heretic_knowledge/knowledge_ritual/ash,
		/datum/heretic_knowledge/knowledge_ritual/void,
		/datum/heretic_knowledge/knowledge_ritual/flesh,
	)
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Grants you Aggressive Spread, a spell that spreads rust to nearby surfaces. \
		Already rusted surfaces are destroyed."
	gain_text = "All wise men know not to visit the Rusted Hills... Yet the Blacksmith's tale was inspiring."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_blade_upgrade,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/curse/corrosion,
		/datum/heretic_knowledge/crucible,
	)
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	cost = 1
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/rust_blade_upgrade
	name = "Toxic Blade"
	desc = "Your Rusty Blade now poisons enemies on attack."
	gain_text = "The Blacksmith hands you their blade. \"The Blade will guide you through the flesh, should you let it.\" \
		The heavy rust weighs it down. You stare deeply into it. The Rusted Hills call for you, now."
	next_knowledge = list(/datum/heretic_knowledge/spell/entropic_plume)
	banned_knowledge = list(
		/datum/heretic_knowledge/ash_blade_upgrade,
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/void_blade_upgrade,
	)
	cost = 2
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/rust_blade_upgrade/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))

/datum/heretic_knowledge/rust_blade_upgrade/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK)

/datum/heretic_knowledge/rust_blade_upgrade/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	// No user == target check here, cause it's technically good for the heretic?
	target.reagents?.add_reagent(/datum/reagent/eldritch, 5)

/datum/heretic_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "Grants you Entropic Plume, a spell that releases a vexing wave of Rust. \
		Blinds, poisons, and inflicts Amok on any heathen it hits, causing them to strike \
		at friend or foe wildly. Also rusts and destroys and surfaces it hits."
	gain_text = "The corrosion was unstoppable. The rust was unpleasable. \
		The Blacksmith was gone, and you hold their blade. Champions of hope, the Rustbringer is nigh!"
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cleave,
		/datum/heretic_knowledge/final/rust_final,
		/datum/heretic_knowledge/summon/rusty,
	)
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	cost = 1
	route = HERETIC_PATH_RUST

/datum/heretic_knowledge/final/rust_final
	name = "Rustbringer's Oath"
	desc = "The ascension ritual of the Path of Rust. \
		Bring three corpses to a transumation rune on the bridge of the station to complete the ritual. \
		When completed, the ritual site will endlessly spread rust onto any surface, stopping for nothing. \
		Additionally, you will become extremely resilient on rust, healing at triple the rate \
		and becoming immune to many effects and dangers."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark, for the RUSTBRINGER has come! \
		The Blacksmith forges ahead! Rusted Hills, CALL MY NAME! WITNESS MY ASCENSION!"
	route = HERETIC_PATH_RUST
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A typepath to an area that we must finish the ritual in.
	var/area/ritual_location = /area/bridge
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_NOSLIPALL,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NOBREATH
		)

/datum/heretic_knowledge/final/rust_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(ritual_location)
		var/area/our_area = get_area(loc)
		if(!istype(our_area, ritual_location))
			loc.balloon_alert(user, "ritual failed, must be in [initial(ritual_location.name)]!") // "must be in bridge"
			return FALSE
	return ..()

/datum/heretic_knowledge/final/rust_final/on_research(mob/user)
	. = ..()
	// This map doesn't have a Bridge, for some reason??
	// Let them complete the ritual anywhere
	if(!GLOB.areas_by_type[ritual_location])
		ritual_location = null

/datum/heretic_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/heretic_knowledge/final/rust_final/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			for(var/trait in conditional_immunities)
				ADD_TRAIT(source, trait, type)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			for(var/trait in conditional_immunities)
				REMOVE_TRAIT(source, trait, type)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/heretic_knowledge/final/rust_final/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	source.adjustBruteLoss(-4, FALSE)
	source.adjustFireLoss(-4, FALSE)
	source.adjustToxLoss(-4, FALSE, forced = TRUE)
	source.adjustOxyLoss(-4, FALSE)
	source.adjustStaminaLoss(-20)

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it.
 *
 * Simple implementation of automatically growing entity.
 */
/datum/rust_spread
	/// The rate of spread every tick.
	var/spread_per_sec = 6
	/// The very center of the spread.
	var/turf/centre
	/// List of turfs at the edge of our rust (but not yet rusted).
	var/list/edge_turfs = list()
	/// List of all turfs we've afflicted.
	var/list/rusted_turfs = list()
	/// Static blacklist of turfs we can't spread to.
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/open/indestructible,
		/turf/closed/indestructible,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm
	))

/datum/rust_spread/New(loc)
	centre = get_turf(loc)
	centre.rust_heretic_act()
	rusted_turfs += centre
	START_PROCESSING(SSprocessing, src)

/datum/rust_spread/Destroy(force, ...)
	centre = null
	edge_turfs.Cut()
	rusted_turfs.Cut()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/rust_spread/process(delta_time)
	var/spread_amount = round(spread_per_sec * delta_time)

	if(length(edge_turfs) < spread_amount)
		compile_turfs()

	for(var/i in 0 to spread_amount)
		if(!length(edge_turfs))
			break
		var/turf/afflicted_turf = pick_n_take(edge_turfs)
		afflicted_turf.rust_heretic_act()
		rusted_turfs |= afflicted_turf

/**
 * Compile turfs
 *
 * Recreates the edge_turfs list.
 * Updates the rusted_turfs list, in case any turfs within were un-rusted.
 */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs.Cut()

	var/max_dist = 1
	for(var/turf/found_turf as anything in rusted_turfs)
		if(!HAS_TRAIT(found_turf, TRAIT_RUSTY))
			rusted_turfs -= found_turf
		max_dist = max(max_dist, get_dist(found_turf, centre) + 1)

	for(var/turf/nearby_turf as anything in spiral_range_turfs(max_dist, centre, FALSE))
		if(nearby_turf in rusted_turfs || is_type_in_typecache(nearby_turf, blacklisted_turfs))
			continue

		for(var/turf/line_turf as anything in getline(nearby_turf, centre))
			if(get_dist(nearby_turf, line_turf) <= 1)
				edge_turfs |= nearby_turf
		CHECK_TICK
