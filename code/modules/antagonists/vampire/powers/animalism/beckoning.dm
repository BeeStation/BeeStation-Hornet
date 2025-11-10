/datum/action/vampire/beckoning
	name = "Beckoning"
	desc = "Summon a pack of wild dogs, loyal to your command, to aid you in battle."
	button_icon_state = "power_beckon"
	power_explanation = "Activate to select your unique vampire clan."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 400
	cooldown_time = 1200 SECONDS
	background_icon_state = "tremere_power_gold_off"
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"

/datum/action/vampire/beckoning/activate_power()
	. = ..()

	playsound(get_turf(owner), 'sound/vampires/awo1.ogg', 80, extrarange = 10)

	check_witnesses()
	var/mob/living/basic/pet/dog/beast/doggo
	for(var/dogcount = 0; dogcount < 3; dogcount++)
		doggo = new /mob/living/basic/pet/dog/beast(owner.loc)
		if (doggo.befriend(owner))
			doggo.tamed(owner)

	deactivate_power()

/mob/living/basic/pet/dog/beast
	name = "\improper wild dog"
	real_name = "wild dog"
	desc = "A fearsome looking dog of undefinable breed."
	icon = 'icons/vampires/dogsummon.dmi'
	icon_state = "gray"
	icon_living = "gray"
	icon_dead = "gray_dead"
	butcher_results = list(/obj/item/food/meat/slab = 3)
	gold_core_spawnable = HOSTILE_SPAWN
	speak_emote = list("growls")
	faction = list(FACTION_HOSTILE)
	can_be_held = FALSE
	health = 20
	maxHealth = 20
	speed = 10
	obj_damage = 20
	melee_damage = 10
	armour_penetration = 30
	sharpness = NONE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	ai_controller = /datum/ai_controller/basic_controller/beast

/datum/ai_controller/basic_controller/beast
	blackboard = list(
		BB_DOG_HARASS_HARM = FALSE,
		BB_VISION_RANGE = BB_HOSTILE_VISION_RANGE,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
	)

// We are free thinkers
/mob/living/basic/pet/dog/beast/add_collar()
	return FALSE
