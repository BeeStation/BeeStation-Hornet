/obj/effect/spawner/structure/ratvar_skewer_trap
	spawn_list = list(
		/obj/structure/destructible/clockwork/trap/pressure_sensor,
		/obj/structure/destructible/clockwork/trap/skewer
	)

/obj/effect/spawner/structure/ratvar_skewer_trap_kill
	spawn_list = list(
		/obj/structure/destructible/clockwork/trap/pressure_sensor,
		/obj/structure/destructible/clockwork/trap/skewer,
		/obj/structure/destructible/clockwork/sigil/vitality
	)

/obj/effect/spawner/structure/ratvar_flipper_trap
	spawn_list = list(
		/obj/structure/destructible/clockwork/trap/pressure_sensor,
		/obj/structure/destructible/clockwork/trap/flipper
	)

/obj/effect/spawner/ocular_warden_setup/Initialize(mapload)
	var/turf/T = get_turf(src)
	new /obj/structure/destructible/clockwork/ocular_warden(T)
	var/turf/open/power_turf = locate() in shuffle(view(3, src))
	new /obj/structure/destructible/clockwork/sigil/transmission(power_turf)
	return ..()

/obj/effect/spawner/interdiction_lens_setup/Initialize(mapload)
	var/turf/T = get_turf(src)
	new /obj/structure/destructible/clockwork/gear_base/interdiction_lens/free(T)
	var/turf/open/power_turf = locate() in shuffle(view(3, src))
	new /obj/structure/destructible/clockwork/sigil/transmission(power_turf)
	return ..()
