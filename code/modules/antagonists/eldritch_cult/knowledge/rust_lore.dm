/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. Allows you to transmute a kitchen knife, or its derivatives, with any trash item into a Rusty Blade."
	gain_text = "'Let me tell you a story', said the Blacksmith, as he gazed deep into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/last/ash_final,/datum/eldritch_knowledge/last/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Empowers your Mansus Grasp to deal 500 damage to non-living matter and rust any surface it touches. Already rusted surfaces are destroyed."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	target.rust_heretic_act()
	return TRUE

/datum/eldritch_knowledge/rust_fist/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)

/datum/eldritch_knowledge/spell/area_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust to nearby surfaces. Already rusted surfaces are destroyed."
	gain_text = "All wise men know well not to touch the Bound King."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/guise,/datum/eldritch_knowledge/spell/blood_siphon)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you when you are on rusted tiles."
	gain_text = "The strength was unparalleled, unnatural. The Blacksmith was smiling."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/essence)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	..()
	var/turf/user_loc_turf = get_turf(user)
	if(!istype(user_loc_turf, /turf/open/floor/plating/rust) || !isliving(user))
		return
	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE, TRUE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)
	living_user.AdjustAllImmobility(-5)

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Rust has a chance to deal between 0 to 200 damage to 75% of your enemy's held items."
	gain_text = "Rusted Hills help those in dire need at a cost."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_mark/on_mansus_grasp(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic blade"
	desc = "Your blade of choice will now poison your enemies on hit."
	gain_text = "The Blade will guide you through the flesh, should you let it."
	desc = "Your blade of choice will now transfer your pain as toxic damage."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	var/mob/living/carbon/carbon_user = user
	var/mob/living/carbon/carbon_target = target
	if(istype(carbon_user) && istype(carbon_target))
		carbon_target.adjustToxLoss((carbon_user.maxHealth - carbon_user.health)/10)

/datum/eldritch_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a befuddling plume that blinds, poisons and makes enemies strike each other. Also converts the area into rust."
	gain_text = "Messenger's of hope fear the rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(/datum/eldritch_knowledge/last/rust_final,/datum/eldritch_knowledge/spell/cleave,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_RUST

/datum/eldritch_knowledge/last/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become more resillient overall and space proof."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for Rustbringer has come!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_RUST
	var/list/trait_list = list(TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTLOWPRESSURE,TRAIT_NODISMEMBER)

/datum/eldritch_knowledge/last/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	return ..()


/datum/eldritch_knowledge/last/rust_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-4, FALSE)
	human_user.adjustFireLoss(-4, FALSE)
	human_user.adjustToxLoss(-4, FALSE, TRUE)
	human_user.adjustOxyLoss(-2, FALSE)
	human_user.adjustStaminaLoss(-20)
	human_user.AdjustAllImmobility(-10)

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it
 *
 * Simple implementation of automatically growing entity
 */
/datum/rust_spread
	var/list/edge_turfs = list()
	var/turf/centre
	var/list/turfs = list()
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/indestructible,/turf/closed/indestructible,/turf/open/space,/turf/open/lava,/turf/open/chasm))
	var/spread_per_sec = 6


/datum/rust_spread/New(loc)
	. = ..()
	centre = get_turf(loc)
	centre.rust_heretic_act()
	turfs += centre
	START_PROCESSING(SSprocessing,src)


/datum/rust_spread/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/rust_spread/process(delta_time)
	var/spread_am = round(spread_per_sec * delta_time)

	if(edge_turfs.len < spread_am)
		compile_turfs()

	var/turf/T
	for(var/i in 0 to spread_am)
		if(!edge_turfs.len)
			continue
		T = pick(edge_turfs)
		edge_turfs -= T
		T.rust_heretic_act()
		turfs += T

/**
 * Compile turfs
 *
 * Recreates all edge_turfs as well as normal turfs.
 */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs = list()
	var/list/removal_list = list()
	var/max_dist = 1
	for(var/turfie in turfs)
		if(!istype(turfie,/turf/closed/wall/rust) && !istype(turfie,/turf/closed/wall/r_wall/rust) && !istype(turfie,/turf/open/floor/plating/rust))
			removal_list += turfie
		max_dist = max(max_dist,get_dist(turfie,centre)+1)
	turfs -= removal_list
	for(var/turfie in spiral_range_turfs(max_dist,centre,FALSE))
		if(turfie in turfs || is_type_in_typecache(turfie,blacklisted_turfs))
			continue
		for(var/line_turfie_owo in getline(turfie,centre))
			if(get_dist(turfie,line_turfie_owo) <= 1)
				edge_turfs += turfie
		CHECK_TICK
