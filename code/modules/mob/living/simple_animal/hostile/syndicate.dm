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
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 100
	health = 100
	melee_damage = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_SYNDICATE)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2
	footstep_type = FOOTSTEP_MOB_SHOE
	mobchatspan = "syndmob"

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

/mob/living/simple_animal/hostile/syndicate/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
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
	projectile_deflect_chance = 50
	hardattacks = TRUE

/mob/living/simple_animal/hostile/syndicate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	light_color = LIGHT_COLOR_RED
	status_flags = 0
	var/obj/effect/light_emitter/red_energy_sword/sord

/mob/living/simple_animal/hostile/syndicate/melee/sword/Initialize(mapload)
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

/mob/living/simple_animal/hostile/syndicate/melee/sword/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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

/mob/living/simple_animal/hostile/syndicate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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

/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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

/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
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
	combat_mode = TRUE
	mob_biotypes = MOB_ROBOTIC
	health = 25
	maxHealth = 25
	melee_damage = 15
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	attack_verb_continuous = "cuts"
	attack_verb_simple = "cut"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list(FACTION_SYNDICATE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	mob_size = MOB_SIZE_TINY
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	limb_destroyer = TRUE
	speak_emote = list("states")
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = TRUE
	death_message = "is smashed into pieces!"

/mob/living/simple_animal/hostile/viscerator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)


/mob/living/simple_animal/hostile/syndicate/sniper
	name = "Syndicate Sniper"
	desc = "One of the best snipers the syndicate has to offer. Take cover or get shot!"
	icon_state = "fsniper"
	icon_living = "fsniper"
	ranged = TRUE
	speed = 1
	dodge_prob = 40
	ranged_cooldown_time = 40
	check_friendly_fire = 1
	sidestep_per_cycle = 3
	minimum_distance = 4
	turns_per_move = 6
	melee_queue_distance = 2
	health = 250
	maxHealth = 250
	melee_damage = 20
	rapid_melee = 3
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit3.ogg'
	projectilesound = 'sound/weapons/sniper_shot.ogg'
	speak_chance = 2
	var/cooldown = 0
	speak = list("You're pretty good.","You can't dodge everything!","Fall down already!")
	loot = list(/obj/item/gun/ballistic/sniper_rifle,
					/obj/effect/mob_spawn/human/corpse/sniper,
					/obj/item/ammo_box/magazine/sniper_rounds,
					/obj/item/ammo_box/magazine/sniper_rounds/penetrator,
					/obj/item/ammo_box/magazine/sniper_rounds/soporific)
	backup_nosound = TRUE

/mob/living/simple_animal/hostile/syndicate/sniper/Aggro()
	..()
	ranged_cooldown = 30
	if (cooldown < world.time)
		cooldown = world.time + 150
		summon_backup(10)
		playsound(get_turf(src), 'sound/weapons/sniper_rack.ogg', 80, TRUE)
		say("I've got you in my scope.")

/mob/living/simple_animal/hostile/syndicate/sniper/Shoot()
	var/allowed_projectile_types = list(/obj/item/ammo_casing/p50, /obj/item/ammo_casing/p50/penetrator)
	casingtype = pick(allowed_projectile_types)
	..()

/mob/living/simple_animal/hostile/syndicate/sniper/death(gibbed)
	playsound(get_turf(src), 'sound/creatures/wardendeath.ogg', 100, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/syndicate/heavy
	name = "Heavy gunner"
	desc = "They didn't get that backpack for nothing."
	icon_state = "Heavy"
	icon_living = "Heavy"
	sidestep_per_cycle = 0
	minimum_distance = 5
	approaching_target = TRUE
	ranged = TRUE
	rapid = 65
	rapid_fire_delay = 0.5
	projectiletype = /obj/projectile/beam
	ranged_cooldown_time = 110
	vision_range = 9
	speak_chance = 0
	speak = null
	aggro_vision_range = 9
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit3.ogg'
	retreat_distance = 2
	melee_queue_distance = 1
	melee_damage = 25
	move_to_delay = 4
	projectilesound = null
	speed = 15
	health = 300
	maxHealth = 300
	loot = list(/obj/effect/mob_spawn/human/corpse/heavy)
	var/cooldown = 0

/mob/living/simple_animal/hostile/syndicate/heavy/Initialize(mapload)
	..()

/mob/living/simple_animal/hostile/syndicate/heavy/Aggro()
	..()
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), 'sound/creatures/heavysight1.ogg', 30, 0, 0)

/mob/living/simple_animal/hostile/syndicate/heavy/OpenFire(atom/A)
	playsound(get_turf(src), 'sound/weapons/heavyminigunstart.ogg', 30, 0, 0)
	move_to_delay = 6//slowdown when shoot
	speed = 30
	sleep(15)
	playsound(get_turf(src), 'sound/weapons/heavyminigunshoot.ogg', 30, 0, 0)
	if(CheckFriendlyFire(A))
		return
	if(!(simple_mob_flags & SILENCE_RANGED_MESSAGE))
		visible_message(span_danger("<b>[src]</b> [ranged_message] at [A]!"))
	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, PROC_REF(Shoot), A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time
	playsound(get_turf(src), 'sound/weapons/heavyminigunstop.ogg', 30, 0, 0)
	move_to_delay = initial(move_to_delay)//restore speed
	speed = initial(speed)

/mob/living/simple_animal/hostile/syndicate/heavy/death(gibbed)
	playsound(get_turf(src), 'sound/creatures/heavydeath1.ogg', 30, TRUE, 0)
	..()
