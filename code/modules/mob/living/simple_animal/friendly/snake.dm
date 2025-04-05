/mob/living/simple_animal/hostile/retaliate/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	health = 20
	maxHealth = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage = 6
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "steps on"
	response_harm_simple = "step on"
	faction = list(FACTION_HOSTILE)
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	chat_color = "#26F55A"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	held_state = "snake"


/mob/living/simple_animal/hostile/retaliate/snake/Initialize(mapload, special_reagent)
	. = ..()
	if(!special_reagent)
		special_reagent = /datum/reagent/toxin/venom
	AddElement(/datum/element/venomous, special_reagent, 3)
	AddComponent(/datum/component/udder, /obj/item/udder/venom, reagent_produced_typepath = special_reagent)

/mob/living/simple_animal/hostile/retaliate/snake/ListTargets(atom/the_target)
	var/atom/target_from = GET_TARGETS_FROM(src)
	var/list/living_mobs = list()
	var/list/mice = list()
	for(var/mob/living/HM in oview(vision_range, target_from))
		//Yum a tasty mouse
		if(istype(HM, /mob/living/simple_animal/mouse))
			mice += HM
			continue
		living_mobs += HM

	// if no tasty mice to chase, lets chase any living mob enemies in our vision range
	if(!length(mice))
		//Filter living mobs (in range mobs) by those we consider enemies (retaliate behaviour)
		return living_mobs & enemies
	return mice

/mob/living/simple_animal/hostile/retaliate/snake/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse))
		visible_message(span_notice("[name] consumes [target] in a single gulp!"), span_notice("You consume [target] in a single gulp!"))
		QDEL_NULL(target)
		adjustBruteLoss(-2)
	else
		return ..()
