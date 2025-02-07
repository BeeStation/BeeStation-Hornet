/mob/living/simple_animal/hostile/tree
	name = "pine tree"
	desc = "A pissed off tree-like alien. It seems annoyed with the festivities..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	icon_living = "pine_1"
	icon_dead = "pine_1"
	icon_gib = "pine_1"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "brushes"
	response_help_simple = "brush"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"
	faction = list(FACTION_PLANTS)
	speed = 1
	maxHealth = 250
	health = 250
	mob_size = MOB_SIZE_LARGE

	pixel_x = -16
	base_pixel_x = -16

	melee_damage = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("pines")
	emote_taunt = list("growls")
	taunt_chance = 20

	atmos_requirements = list("min_oxy" = 2, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	minbodytemp = 0
	maxbodytemp = 1200

	faction = list(FACTION_PLANTS)
	deathmessage = "is hacked into pieces!"
	loot = list(/obj/item/stack/sheet/wood)
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = TRUE
	hardattacks = TRUE

	discovery_points = 1000

/mob/living/simple_animal/hostile/tree/Life()
	..()
	if(isopenturf(loc))
		var/turf/open/T = src.loc
		if(T.air)
			var/co2 = GET_MOLES(/datum/gas/carbon_dioxide, T.air)
			if(co2 > 0)
				if(prob(25))
					var/amt = min(co2, 9)
					T.air.gases[/datum/gas/carbon_dioxide][MOLES] += -amt
					T.atmos_spawn_air("[GAS_O2]=[amt];[TURF_TEMPERATURE(T20C)]")

/mob/living/simple_animal/hostile/tree/festivus
	name = "festivus pole"
	desc = "Serenity now... SERENITY NOW!"
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	loot = list(/obj/item/stack/rods)
	speak_emote = list("polls")
	faction = list()
