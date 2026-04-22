/datum/generator_settings/netherworld
	probability = 1
	floor_break_prob = 30
	structure_damage_prob = 40

/datum/generator_settings/netherworld/get_floortrash()
	. = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/blood/old = 3,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris/old = 1,
		/obj/effect/decal/cleanable/vomit/old = 4,
		/obj/effect/decal/cleanable/blood/gibs/old = 1,
		/obj/effect/decal/cleanable/greenglow/filled = 1,
		/obj/effect/spawner/random/decoration/glowstick/lit = 2,
		/obj/effect/spawner/random/decoration/glowstick = 4,
		/obj/effect/spawner/random/maintenance = 3,
		/obj/item/ammo_box/c38/exploration = 1,
		/mob/living/simple_animal/hostile/netherworld/blankbody = 2,
		/mob/living/simple_animal/hostile/netherworld/migo = 2,
		/obj/structure/spawner/nether = 0.3,
		/obj/structure/destructible/cult/pylon = 2,
		/obj/structure/destructible/cult/forge = 1,
		/obj/effect/rune/blood_boil = 1,
		/obj/effect/rune/empower = 1,
		null = 140,
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/netherworld/get_directional_walltrash()
	return list(
		/obj/machinery/light/built = 5,
		/obj/machinery/light = 1,
		/obj/machinery/light/broken = 4,
		/obj/machinery/light/small = 2,
		/obj/machinery/light/small/broken = 5,
		null = 75,
	)

/datum/generator_settings/netherworld/get_non_directional_walltrash()
	return list(
		/obj/item/radio/intercom = 1,
		/obj/structure/sign/poster/random = 1,
		/obj/structure/sign/poster/ripped = 2,
		/obj/machinery/newscaster = 1,
		/obj/structure/extinguisher_cabinet = 3,
		null = 30
	)
