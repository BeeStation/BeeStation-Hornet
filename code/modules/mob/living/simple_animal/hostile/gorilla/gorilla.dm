#define GORILLA_HANDS_LAYER 1
#define GORILLA_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/gorilla
	name = "Gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa."
	icon = 'icons/mob/gorilla.dmi'
	icon_state = "crawling"
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 80
	maxHealth = 220
	health = 220
	loot = list(/obj/effect/gibspawner/generic/animal)
	butcher_results = list(/obj/item/food/meat/slab/gorilla = 4)
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "challenges"
	response_disarm_simple = "challenge"
	response_harm_continuous = "thumps"
	response_harm_simple = "thump"
	speed = 1
	melee_damage = 16
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummel"
	attack_sound = 'sound/weapons/punch1.ogg'
	dextrous = TRUE
	held_items = list(null, null)
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	faction = list("jungle")
	robust_searching = TRUE
	stat_attack = HARD_CRIT
	minbodytemp = 270
	maxbodytemp = 350
	unique_name = TRUE
	hardattacks = TRUE
	var/list/gorilla_overlays[GORILLA_TOTAL_LAYERS]
	var/oogas = 0

	footstep_type = FOOTSTEP_MOB_BAREFOOT

// Gorillas like to dismember limbs from unconscious mobs.
// Returns null when the target is not an unconscious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/target_bodyparts(atom/the_target)
	var/list/parts = list()
	if(iscarbon(the_target))
		var/mob/living/carbon/C = the_target
		if(C.stat >= UNCONSCIOUS)
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						parts += BP
			return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget()
	if(client)
		oogaooga()
	var/list/parts = target_bodyparts(target)
	if(parts)
		if(!parts.len)
			return FALSE
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		return ..()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(prob(80))
			var/atom/throw_target = get_edge_target_turf(L, dir)
			L.throw_at(throw_target, rand(1,2), 7, src)
		else
			L.Unconscious(20)
			visible_message("<span class='danger'>[src] knocks [L] out!</span>")

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = target_bodyparts(target)
	return ..() && !istype(the_target, /mob/living/carbon/monkey) && (!parts  || parts.len > 3)


/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)


/mob/living/simple_animal/hostile/gorilla/gib(no_brain)
	if(!no_brain)
		var/mob/living/brain/B = new(drop_location())
		B.name = real_name
		B.real_name = real_name
		if(mind)
			mind.transfer_to(B)
	..()

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)
	..()

/mob/living/simple_animal/hostile/gorilla/can_use_guns(obj/item/G)
	to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
	return FALSE


/mob/living/simple_animal/hostile/gorilla/proc/oogaooga()
	oogas++
	if(oogas >= rand(2,6))
		playsound(src, 'sound/creatures/gorilla.ogg', 50)
		oogas = 0

/mob/living/simple_animal/hostile/gorilla/rabid
	name = "Rabid Gorilla"
	desc = "A mangy looking gorilla."
	icon_state = "crawling"
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 80
	maxHealth = 220
	health = 220
	loot = list(/obj/effect/gibspawner/generic/animal)
	butcher_results = list(/obj/item/food/meat/slab/gorilla = 4)
	melee_damage = 20
	damage_coeff = list(BRUTE = 0.8, BURN = 1, TOX = 1, CLONE = 0, STAMINA = 0, OXY = 1)
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_RWALLS

/mob/living/simple_animal/hostile/gorilla/proc/apply_overlay(cache_index)
	. = gorilla_overlays[cache_index]
	if(.)
		add_overlay(.)

/mob/living/simple_animal/hostile/gorilla/proc/remove_overlay(cache_index)
	var/I = gorilla_overlays[cache_index]
	if(I)
		cut_overlay(I)
		gorilla_overlays[cache_index] = null
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/gorilla/update_inv_hands()
	cut_overlays("standing_overlay")
	remove_overlay(GORILLA_HANDS_LAYER)

	var/standing = FALSE
	for(var/I in held_items)
		if(I)
			standing = TRUE
			break
	if(!standing)
		if(stat != DEAD)
			icon_state = "crawling"
			speed = 1
		return ..()
	if(stat != DEAD)
		icon_state = "standing"
		speed = 3 // Gorillas are slow when standing up.

	var/list/hands_overlays = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		var/mutable_appearance/r_hand_overlay = r_hand.build_worn_icon(src, default_layer = GORILLA_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)
		r_hand_overlay.pixel_y -= 1
		hands_overlays += r_hand_overlay

	if(l_hand)
		var/mutable_appearance/l_hand_overlay = l_hand.build_worn_icon(src, default_layer = GORILLA_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)
		l_hand_overlay.pixel_y -= 1
		hands_overlays += l_hand_overlay

	if(hands_overlays.len)
		gorilla_overlays[GORILLA_HANDS_LAYER] = hands_overlays
	apply_overlay(GORILLA_HANDS_LAYER)
	add_overlay("standing_overlay")
	return ..()

/mob/living/simple_animal/hostile/gorilla/regenerate_icons()
	update_inv_hands()



#undef GORILLA_HANDS_LAYER
#undef GORILLA_TOTAL_LAYERS
