/datum/generator_settings/ratvar
	probability = 2
	floor_break_prob = 8
	structure_damage_prob = 6

/datum/generator_settings/ratvar/get_floortrash()
	. = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/blood/old = 3,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris/old = 1,
		/obj/effect/decal/cleanable/vomit/old = 4,
		/obj/effect/decal/cleanable/blood/gibs/old = 1,
		/obj/effect/decal/cleanable/greenglow/filled = 1,
		/obj/effect/spawner/random/decoration/glowstick/lit = 6,
		/obj/effect/spawner/random/maintenance = 3,
		/obj/item/ammo_box/c38/exploration = 1,
		null = 70,
		/obj/effect/spawner/structure/ratvar_skewer_trap = 4,
		/obj/effect/spawner/structure/ratvar_flipper_trap = 2,
		/obj/effect/spawner/structure/ratvar_skewer_trap_kill = 1,
		/mob/living/simple_animal/hostile/clockwork_marauder = 1,
		/obj/structure/destructible/clockwork/wall_gear/displaced = 10,
		/obj/effect/spawner/ocular_warden_setup = 1,
		/obj/effect/spawner/interdiction_lens_setup = 1,
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/ratvar/get_directional_walltrash()
	return list(
		/obj/machinery/light/broken = 4,
		/obj/machinery/light/small = 1,
		null = 75,
	)

/datum/generator_settings/ratvar/get_non_directional_walltrash()
	return list(
		/obj/item/radio/intercom = 2,
		/obj/structure/sign/poster/random = 1,
		/obj/machinery/newscaster = 2,
		/obj/structure/destructible/clockwork/trap/delay = 1,
		/obj/structure/destructible/clockwork/trap/lever = 1,
		/obj/structure/extinguisher_cabinet = 3,
		null = 30
	)
