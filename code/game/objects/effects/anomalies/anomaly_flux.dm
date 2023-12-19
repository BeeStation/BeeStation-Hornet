/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "electricity2"
	density = TRUE
	var/canshock = 0
	var/shockdamage = 20
	var/explosive = ANOMALY_FLUX_EXPLOSIVE

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, explosive = ANOMALY_FLUX_EXPLOSIVE)
	. = ..()
	src.explosive = explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = 1
	for(var/mob/living/M in get_turf(src))
		mobShock(M)

/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	mobShock(AM)

/obj/effect/anomaly/flux/Bump(mob/living/M)
	mobShock(M)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	mobShock(AM)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = 0 //Just so you don't instakill yourself if you slam into the anomaly five times in a second.
		if(iscarbon(M))
			if(ishuman(M))
				M.electrocute_act(shockdamage, "[name]", safety=1)
				return
			M.electrocute_act(shockdamage, "[name]")
			return
		else
			M.adjustFireLoss(shockdamage)
			M.visible_message("<span class='danger'>[M] was shocked by \the [name]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>")

/obj/effect/anomaly/flux/detonate()
	switch(explosive)
		if(ANOMALY_FLUX_EXPLOSIVE)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(ANOMALY_FLUX_LOW_EXPLOSIVE)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6)
		if(ANOMALY_FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)
	var/turf/T = get_turf(src)
	T.generate_fake_pierced_realities(max_spawned_faked)
