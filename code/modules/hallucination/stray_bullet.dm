//hallucination projectile code in code/modules/projectiles/projectile/special.dm
/datum/hallucination/stray_bullet

/datum/hallucination/stray_bullet/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(getexpandedview(world.view, 1, 1),target))
		startlocs += T
	for(var/turf/open/T in view(world.view,target)) // God this is bad
		startlocs -= T
	if(!startlocs.len)
		qdel(src)
		return
	var/turf/start = pick(startlocs)
	var/proj_type = pick(subtypesof(/obj/item/projectile/hallucination))
	feedback_details += "Type: [proj_type]"
	var/obj/item/projectile/hallucination/H = new proj_type(start)
	target.playsound_local(start, H.hal_fire_sound, 60, 1)
	H.hal_target = target
	H.preparePixelProjectile(target, start)
	H.fire()
	qdel(src)
