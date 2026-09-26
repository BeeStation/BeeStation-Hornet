/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "flux"
	density = TRUE
	anomaly_core = /obj/item/assembly/signaler/anomaly/flux
	var/can_shock = FALSE
	var/shock_damage = 20
	var/explosive = ANOMALY_FLUX_EXPLOSIVE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/anomaly/flux)

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, explosive = ANOMALY_FLUX_EXPLOSIVE)
	. = ..()
	src.explosive = explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/flux/Bump(atom/bumped_atom)
	shock_mob(bumped_atom)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	shock_mob(AM)

/obj/effect/anomaly/flux/anomaly_process()
	. = ..()
	can_shock = TRUE
	for(var/mob/living/poor_soul in get_turf(src))
		shock_mob(poor_soul)

/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	shock_mob(arrived)

/obj/effect/anomaly/flux/proc/shock_mob(mob/living/mob_to_shock)
	if(!can_shock || !istype(mob_to_shock))
		return
	can_shock = FALSE
	mob_to_shock.electrocute_act(shock_damage, name, flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/flux/detonate()
	switch(explosive)
		if(ANOMALY_FLUX_EXPLOSIVE)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(ANOMALY_FLUX_LOW_EXPLOSIVE)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6)
		if(ANOMALY_FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)
	generate_fake_pierced_realities(center_turf = get_turf(src), max_amount = max_spawned_faked)
