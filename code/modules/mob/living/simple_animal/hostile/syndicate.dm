/*
	CONTENTS
	LINE 10  - BASE MOB
	LINE 52  - SWORD AND SHIELD
	LINE 164 - GUNS
	LINE 267 - MISC
*/


///////////////Base mob////////////
/obj/effect/light_emitter/red_energy_sword //used so there's a combination of both their head light and light coming off the energy sword
	set_luminosity = 2
	set_cap = 2.5
	light_color = LIGHT_COLOR_RED


/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	maxHealth = 100
	health = 100
	melee_damage = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list(ROLE_SYNDICATE)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1
	dodging = TRUE
	rapid_melee = 2

	do_footstep = TRUE

///////////////Melee////////////

/mob/living/simple_animal/hostile/syndicate/space
	icon_state = "syndicate_space"
	icon_living = "syndicate_space"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/syndicate/space/Initialize()
	. = ..()
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/space/stormtrooper
	icon_state = "syndicate_stormtrooper"
	icon_living = "syndicate_stormtrooper"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/simple_animal/hostile/syndicate/melee //dude with a knife and no shields
	melee_damage = 15
	icon_state = "syndicate_knife"
	icon_living = "syndicate_knife"
	loot = list(/obj/effect/gibspawner/human)
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	status_flags = 0
	var/projectile_deflect_chance = 0
	hardattacks = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/space
	icon_state = "syndicate_space_knife"
	icon_living = "syndicate_space_knife"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE
	projectile_deflect_chance = 50
	hardattacks = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/space/Initialize()
	. = ..()
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/melee/space/stormtrooper
	icon_state = "syndicate_stormtrooper_knife"
	icon_living = "syndicate_stormtrooper_knife"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50

/mob/living/simple_animal/hostile/syndicate/melee/sword
	melee_damage = 30
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	attacktext = "slashes"
	attack_sound = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	light_color = LIGHT_COLOR_RED
	status_flags = 0
	var/obj/effect/light_emitter/red_energy_sword/sord

/mob/living/simple_animal/hostile/syndicate/melee/sword/Initialize()
	. = ..()
	set_light(2)

/mob/living/simple_animal/hostile/syndicate/melee/sword/Destroy()
	QDEL_NULL(sord)
	return ..()

/mob/living/simple_animal/hostile/syndicate/melee/sword/space
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/sword/space/Initialize()
	. = ..()
	sord = new(src)
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/melee/sword/space/Destroy()
	QDEL_NULL(sord)
	return ..()

/mob/living/simple_animal/hostile/syndicate/melee/sword/space/stormtrooper
	icon_state = "syndicate_stormtrooper_sword"
	icon_living = "syndicate_stormtrooper_sword"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

///////////////Guns////////////

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicate_pistol"
	icon_living = "syndicate_pistol"
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gunshot.ogg'
	loot = list(/obj/effect/gibspawner/human)
	dodging = FALSE
	rapid_melee = 1

/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator //shuttle loan event
	projectilesound = 'sound/weapons/gunshot_silenced.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicate_space_pistol"
	icon_living = "syndicate_space_pistol"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/space/Initialize()
	. = ..()
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/ranged/space/stormtrooper
	icon_state = "syndicate_stormtrooper_pistol"
	icon_living = "syndicate_stormtrooper_pistol"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/simple_animal/hostile/syndicate/ranged/smg
	rapid = 2
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot_smg.ogg'

/mob/living/simple_animal/hostile/syndicate/ranged/smg/pilot //caravan ambush ruin
	name = "Syndicate Salvage Pilot"
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)

/mob/living/simple_animal/hostile/syndicate/ranged/smg/space
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/Initialize()
	. = ..()
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/stormtrooper
	icon_state = "syndicate_stormtrooper_smg"
	icon_living = "syndicate_stormtrooper_smg"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/simple_animal/hostile/syndicate/ranged/shotgun
	rapid = 2
	rapid_fire_delay = 6
	minimum_distance = 3
	icon_state = "syndicate_shotgun"
	icon_living = "syndicate_shotgun"
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst

/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space
	icon_state = "syndicate_space_shotgun"
	icon_living = "syndicate_space_shotgun"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	spacewalk = TRUE

/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/Initialize()
	. = ..()
	set_light(4)

/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/stormtrooper
	icon_state = "syndicate_stormtrooper_shotgun"
	icon_living = "syndicate_stormtrooper_shotgun"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

///////////////Misc////////////

/mob/living/simple_animal/hostile/syndicate/civilian
	minimum_distance = 10
	retreat_distance = 10
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/syndicate/civilian/Aggro()
	..()
	summon_backup(15)
	say("GUARDS!!")


/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE | PASSMOB
	a_intent = INTENT_HARM
	mob_biotypes = list(MOB_ROBOTIC)
	health = 25
	maxHealth = 25
	melee_damage = 15
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list(ROLE_SYNDICATE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	mob_size = MOB_SIZE_TINY
	movement_type = FLYING
	limb_destroyer = 1
	speak_emote = list("states")
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = 1
	deathmessage = "is smashed into pieces!"

/mob/living/simple_animal/hostile/viscerator/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)
