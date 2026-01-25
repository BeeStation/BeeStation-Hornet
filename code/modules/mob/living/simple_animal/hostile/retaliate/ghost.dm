/mob/living/simple_animal/hostile/retaliate/ghost
	name = "ghost"
	desc = "A soul of the dead, spooky."
	icon = 'icons/mob/observer.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = MOB_SPIRIT
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "swings through"
	response_disarm_simple = "swing through"
	response_harm_continuous = "punches through"
	response_harm_simple = "punch through"
	combat_mode = TRUE
	healable = 0
	speed = 0
	maxHealth = 40
	health = 40
	melee_damage = 15
	del_on_death = TRUE
	emote_see = list("weeps silently", "groans", "mumbles")
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("weeps")
	deathmessage = "wails, disintegrating into a pile of ectoplasm!"
	loot = list(/obj/item/ectoplasm)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	is_flying_animal = TRUE
	pressure_resistance = 300
	gold_core_spawnable = NO_SPAWN //too spooky for science
	var/ghost_hair_style
	light_system = MOVABLE_LIGHT
	light_range = 1 // same glowing as visible player ghosts
	light_power = 2
	var/ghost_hair_color
	var/mutable_appearance/ghost_hair
	var/ghost_facial_hair_style
	var/ghost_facial_hair_color
	var/mutable_appearance/ghost_facial_hair
	var/random = TRUE //if you want random names for ghosts or not
	discovery_points = 1000

/mob/living/simple_animal/hostile/retaliate/ghost/Initialize(mapload)
	. = ..()
	give_hair()
	if(random)
		switch(rand(0,1))
			if(0)
				name = "ghost of [pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			if(1)
				name = "ghost of [pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE, "#490066")

/mob/living/simple_animal/hostile/retaliate/ghost/Destroy()
	. = ..()
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		qdel(beacon)

/mob/living/simple_animal/hostile/retaliate/ghost/proc/give_hair()
	if(ghost_hair_style != null)
		ghost_hair = mutable_appearance('icons/mob/human/human_face.dmi', "hair_[ghost_hair_style]", CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		add_overlay(ghost_hair)
	if(ghost_facial_hair_style != null)
		ghost_facial_hair = mutable_appearance('icons/mob/human/human_face.dmi', "facial_[ghost_facial_hair_style]", CALCULATE_MOB_OVERLAY_LAYER(HAIR_LAYER))
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)
