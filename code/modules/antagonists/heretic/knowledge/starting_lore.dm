// Heretic starting knowledge.

/// Global list of all heretic knowledge that have route = HERETIC_PATH_START. List of PATHS.
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to HERETIC_PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(initial(knowledge.route) == HERETIC_PATH_START)
			. += knowledge

/*
 * The base heretic knowledge. Grants the Mansus Grasp spell.
 */
/datum/heretic_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey into the Mansus. \
		Grants you the Mansus Grasp, a powerful and upgradable \
		disabling spell that can be cast regardless of having a focus."
	next_knowledge = list(
		/datum/heretic_knowledge/limited_amount/base_rust,
		/datum/heretic_knowledge/limited_amount/base_ash,
		/datum/heretic_knowledge/limited_amount/base_flesh,
		/datum/heretic_knowledge/limited_amount/base_void,
		)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	cost = 0
	route = HERETIC_PATH_START

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets. \
		Should you lose your heart, you can transmute a flower and a pool of blood \
		to awaken your heart into a Living Heart. If your heart is cybernetic, \
		you will additionally require a usable organic heart in the transmutation."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/reagent_containers/food/snacks/grown/flower = 1,
	)
	var/required_organ_type = /obj/item/organ/heart
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Knowing how to remake your heart is important
	route = HERETIC_PATH_START

/datum/heretic_knowledge/living_heart/on_research(mob/user)
	. = ..()

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		our_heart.AddComponent(/datum/component/living_heart)

/datum/heretic_knowledge/living_heart/on_lose(mob/user)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		qdel(our_heart.GetComponent(/datum/component/living_heart))

// Don't bother letting them invoke this ritual if they have a Living Heart already in their chest
/datum/heretic_knowledge/living_heart/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.has_living_heart() == HERETIC_HAS_LIVING_HEART)
		return FALSE
	return TRUE

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/our_living_heart = user.getorganslot(ORGAN_SLOT_HEART)
	// Obviously you need a heart in your chest to do a ritual on your... heart
	if(!our_living_heart)
		loc.balloon_alert(user, "ritual failed, you have no [ORGAN_SLOT_HEART]!") // "you have no heart!"
		return FALSE
	// For sanity's sake, check if they've got a heart -
	// even though it's not invokable if you already have one,
	// they may have gained one unexpectantly in between now and then
	if(HAS_TRAIT(our_living_heart, TRAIT_LIVING_HEART))
		loc.balloon_alert(user, "ritual failed, already have a living heart!")
		return FALSE

	// By this point they are making a new heart
	// If their current heart is organic / not synthetic, we can continue the ritual as normal
	if(our_living_heart.status == ORGAN_ORGANIC && !(our_living_heart.organ_flags & ORGAN_SYNTHETIC))
		return TRUE

	// If their current heart is not organic / is synthetic, they need an organic replacement
	// ...But if our organ-to-be-replaced is unremovable, we're screwed
	if(our_living_heart.organ_flags & ORGAN_UNREMOVABLE)
		loc.balloon_alert(user, "ritual failed, [ORGAN_SLOT_HEART] unremovable!") // "heart unremovable!"
		return FALSE

	// Otherwise, seek out a replacement in our atoms
	for(var/obj/item/organ/nearby_organ in atoms)
		if(!istype(nearby_organ, required_organ_type))
			continue
		if(!nearby_organ.useable)
			continue
		if(nearby_organ.status != ORGAN_ORGANIC || (nearby_organ.organ_flags & (ORGAN_SYNTHETIC|ORGAN_FAILING)))
			continue

		selected_atoms += nearby_organ
		return TRUE

	loc.balloon_alert(user, "ritual failed, need a replacement [ORGAN_SLOT_HEART]!") // "need a replacement heart!"
	return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)

	// Our heart is robotic or synthetic - we need to replace it, and we fortunately should have one by here
	if(our_heart.status != ORGAN_ORGANIC || (our_heart.organ_flags & ORGAN_SYNTHETIC))
		var/obj/item/organ/heart/our_replacement_heart = locate() in selected_atoms
		if(our_replacement_heart)
			// Throw our current heart out of our chest, violently
			user.visible_message("<span class='boldwarning'>[user]'s [our_heart.name] bursts suddenly out of [user.p_their()] chest!</span>")
			INVOKE_ASYNC(user, /mob/proc/emote, "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			// And put our organic heart in its place
			our_replacement_heart.Insert(user, special = TRUE, drop_if_replaced = TRUE)
			our_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
			our_heart = our_replacement_heart
		else
			CRASH("[type] required a replacement organic heart in on_finished_recipe, but did not find one.")

	if(!our_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	// Don't delete our shiny new heart
	if(our_heart in selected_atoms)
		selected_atoms -= our_heart
	our_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, "<span class='warning'>You feel your [our_heart.name] begin to pulse faster and faster as it awakens!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE

/**
 * Allows the heretic to craft a spell focus.
 * They require a focus to cast advanced spells.
 */
/datum/heretic_knowledge/amber_focus
	name = "Amber Focus"
	desc = "Allows you to transmute a sheet of glass and a pair of eyes to create an Amber Focus. \
		A focus must be worn in order to cast more advanced spells."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Not as important as making a heart or sacrificing, but important enough.
	route = HERETIC_PATH_START
