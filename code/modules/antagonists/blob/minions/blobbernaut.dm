/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage = BLOBMOB_BLOBBERNAUT_DMG_SOLO
	obj_damage = BLOBMOB_BLOBBERNAUT_OBJ_DMG
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blobattack.ogg'
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	force_threshold = 10
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	hud_type = /datum/hud/living/blobbernaut
	flavor_text = FLAVOR_TEXT_GOAL_ANTAG
	move_resist = MOVE_FORCE_STRONG

/mob/living/simple_animal/hostile/blob/blobbernaut/mind_initialize()
	. = ..()
	if(independent | !overmind)
		return
	var/datum/antagonist/blob_minion/blobbernaut/naut = new(overmind)
	mind.add_antag_datum(naut)

/mob/living/simple_animal/hostile/blob/blobbernaut/Life(delta_time = SSMOBS_DT, times_fired)
	if(!..())
		return
	var/list/blobs_in_area = range(2, src)

	if(independent)
		return FALSE // strong independent blobbernaut that don't need no blob

	var/damagesources = 0

	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damagesources++

	if(!factory)
		damagesources++
	else
		if(locate(/obj/structure/blob/special/core) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_CORE * delta_time)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = COLOR_BLACK
		if(locate(/obj/structure/blob/special/node) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_NODE * delta_time)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src))
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = COLOR_BLACK

	if(!damagesources)
		return FALSE

	adjustHealth(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damagesources * delta_time) //take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
	var/mutable_appearance/healing = mutable_appearance('icons/mob/blob.dmi', "nautdamage", MOB_LAYER+0.01)
	healing.appearance_flags = RESET_COLOR

	if(overmind)
		healing.color = overmind.blobstrain.complementary_color

	flick_overlay_view(healing, 0.8 SECONDS)

/// Called by the blob creation power to give us a mind and a basic task orientation
/mob/living/simple_animal/hostile/blob/blobbernaut/proc/assign_key(ckey, datum/blobstrain/blobstrain)
	key = ckey
	flick("blobbernaut_produce", src)
	health = maxHealth / 2 // Start out injured to encourage not beelining away from the blob
	SEND_SOUND(src, sound('sound/effects/blobattack.ogg'))
	SEND_SOUND(src, sound('sound/effects/attackblob.ogg'))
	to_chat(src, span_infoplain("You are powerful, hard to kill, and slowly regenerate near nodes and cores, [span_cultlarge("but will slowly die if not near the blob")] or if the factory that made you is killed."))
	to_chat(src, span_infoplain("You can communicate with other blobbernauts and overminds <b>telepathically</b> by attempting to speak normally"))
	to_chat(src, span_infoplain("Your overmind's blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!"))
	to_chat(src, span_infoplain("The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]"))

/mob/living/simple_animal/hostile/blob/blobbernaut/AttackingTarget()
	. = ..()
	if(. && isliving(target) && overmind)
		overmind.blobstrain.blobbernaut_attack(target, src)

/mob/living/simple_animal/hostile/blob/blobbernaut/update_icons()
	..()
	if(overmind) //if we have an overmind, we're doing chemical reactions instead of pure damage
		melee_damage = BLOBMOB_BLOBBERNAUT_DMG
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message
	else
		melee_damage = BLOBMOB_BLOBBERNAUT_DMG_SOLO
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	if(factory)
		factory.blobbernaut = null //remove this blobbernaut from its factory
		factory.max_integrity = initial(factory.max_integrity)
	flick("blobbernaut_death", src)
	return ..()

/mob/living/simple_animal/hostile/blob/blobbernaut/independent
	independent = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
