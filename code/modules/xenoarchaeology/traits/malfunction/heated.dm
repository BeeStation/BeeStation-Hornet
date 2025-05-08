/*
	Mass Area Combustion
	Makes a bunch of hotspots near the artifact
*/
/datum/xenoartifact_trait/malfunction/heated
	label_name = "M.A.C."
	alt_label_name = "Mass Area Combustion"
	label_desc = "Mass Area Combustion: A strange malfunction that causes the Artifact to violently combust."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT

/datum/xenoartifact_trait/malfunction/heated/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(component_parent.parent)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)
	for(var/turf/open/turf in RANGE_TURFS(max(1, 4*(component_parent.trait_strength/100)), T))
		if(!locate(/obj/effect/safe_fire) in turf)
			new /obj/effect/safe_fire(turf)

//Lights on fire, does nothing else damage / atmos wise
/obj/effect/safe_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

/obj/effect/safe_fire/Initialize(mapload)
	. = ..()
	for(var/atom/AT in loc)
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(400, 50) //should be average enough to not do too much damage
	addtimer(CALLBACK(src, PROC_REF(after_burn)), 0.3 SECONDS)

/obj/effect/safe_fire/proc/after_burn()
	qdel(src)
