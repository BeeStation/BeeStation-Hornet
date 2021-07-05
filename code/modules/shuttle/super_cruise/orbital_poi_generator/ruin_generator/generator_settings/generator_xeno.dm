/datum/generator_settings/xeno
	probability = 2
	floor_break_prob = 4
	structure_damage_prob = 20

/datum/generator_settings/xeno/get_floortrash()
	. = list(
		/obj/effect/decal/cleanable/dirt = 3,
		/obj/effect/decal/cleanable/blood/old = 6,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris/old = 1,
		/obj/effect/decal/cleanable/vomit/old = 4,
		/obj/effect/decal/cleanable/blood/gibs/old = 6,
		/obj/effect/decal/cleanable/greenglow/filled = 3,
		/obj/effect/spawner/lootdrop/glowstick/lit = 5,
		/obj/effect/spawner/lootdrop/glowstick = 1,
		/obj/effect/spawner/lootdrop/maintenance = 3,
		/obj/item/ammo_casing/c9mm = 4,
		/obj/item/gun/ballistic/automatic/pistol/no_mag = 1,
		/mob/living/simple_animal/hostile/alien/drone = 1,
		/mob/living/simple_animal/hostile/alien/sentinel = 1,
		/mob/living/simple_animal/hostile/alien = 1,
		/obj/structure/alien/egg = 1,
		/obj/structure/alien/weeds/node = 8,
		/obj/structure/alien/gelpod = 4,
		/obj/effect/mob_spawn/human/corpse/nanotrasensoldier = 1,
		/obj/effect/mob_spawn/human/corpse/assistant = 1,
		/obj/effect/mob_spawn/human/corpse/cargo_tech = 1,
		/obj/effect/mob_spawn/human/corpse/damaged = 1,
		null = 90
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/xeno/get_directional_walltrash()
	return list(
		/obj/machinery/light/built = 1,
		/obj/machinery/light/broken = 8,
		/obj/machinery/light/small = 1,
		/obj/machinery/light/small/broken = 6,
		null = 75,
	)

/datum/generator_settings/xeno/get_non_directional_walltrash()
	return list(
		/obj/item/radio/intercom = 1,
		/obj/structure/sign/poster/ripped = 2,
		/obj/machinery/newscaster = 1,
		/obj/structure/extinguisher_cabinet = 3,
		null = 30
	)
