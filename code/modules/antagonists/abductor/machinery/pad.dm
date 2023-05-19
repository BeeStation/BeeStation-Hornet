/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from the humans' habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	var/turf/teleport_target

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	if(!target.buckled)
		do_teleport(target, get_turf(src), no_effects = TRUE, channel = TELEPORT_CHANNEL_BLINK, teleport_mode = TELEPORT_MODE_ABDUCTORS)

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = GLOB.teleportlocs[pick(GLOB.teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		do_teleport(target, teleport_target, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLINK, teleport_mode = TELEPORT_MODE_ABDUCTORS)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
		to_chat(target, "<span class='warning'>The instability of the warp leaves you disoriented!</span>")
		target.SetSleeping(60)
		//If the target is wearing an abductor vest, increase the stimulant cooldown
		if (ishuman(target))
			var/mob/living/carbon/human/abductor = target
			var/obj/item/clothing/suit/armor/abductor/vest/abductor_vest = abductor.wear_suit
			if (istype(abductor_vest))
				//Set a minimum 6 second cooldown
				abductor_vest.combat_cooldown = max(abductor_vest.combat_cooldown, 6)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/doMobToLoc(place, atom/movable/target)
	flick("alien-pad", src)
	do_teleport(target, place, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLINK, teleport_mode = TELEPORT_MODE_ABDUCTORS)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doMobToLoc), place, target), 80)

/obj/machinery/abductor/pad/proc/doPadToLoc(place)
	flick("alien-pad", src)
	for(var/mob/living/target in get_turf(src))
		do_teleport(target, place, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLINK, teleport_mode = TELEPORT_MODE_ABDUCTORS)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doPadToLoc), place), 80)

/obj/effect/temp_visual/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 80

/obj/effect/temp_visual/teleport_abductor/Initialize(mapload)
	. = ..()
	var/datum/effect_system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()
