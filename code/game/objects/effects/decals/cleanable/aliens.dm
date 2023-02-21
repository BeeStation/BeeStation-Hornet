// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/xenoblood
	name = "xeno blood"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	blood_state = BLOOD_STATE_XENO

/obj/effect/decal/cleanable/xenoblood/Initialize(mapload)
	. = ..()
	add_blood_DNA(list("UNKNOWN DNA" = "X*"))

/obj/effect/decal/cleanable/xenoblood/xsplatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/xenoblood/xgibs
	name = "xeno gibs"
	desc = "Gnarly..."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xgib1"
	layer = LOW_OBJ_LAYER
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/xenoblood/xgibs/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, .proc/on_pipe_eject)

/obj/effect/decal/cleanable/xenoblood/xgibs/proc/streak(list/directions, mapload = FALSE)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions)
	var/direction = pick(directions)
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i in 1 to range)
			new /obj/effect/decal/cleanable/xenoblood/xsplatter(loc)
			if(!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = SSmove_manager.move_to_dir(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/spread_movement_effects)

/obj/effect/decal/cleanable/xenoblood/xgibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/xenoblood/xsplatter(loc)

/obj/effect/decal/cleanable/xenoblood/xgibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/xenoblood/xgibs/ex_act()
	return

/obj/effect/decal/cleanable/xenoblood/xgibs/up
	icon_state = "xgibup1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/xenoblood/xgibs/down
	icon_state = "xgibdown1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/xenoblood/xgibs/body
	icon_state = "xgibtorso"
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/xenoblood/xgibs/torso
	icon_state = "xgibtorso"
	random_icon_states = list("xgibtorso")

/obj/effect/decal/cleanable/xenoblood/xgibs/limb
	icon_state = "xgibleg"
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/xenoblood/xgibs/core
	icon_state = "xgibmid1"
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/xenoblood/xgibs/larva
	icon_state = "xgiblarva1"
	random_icon_states = list("xgiblarva1", "xgiblarva2")

/obj/effect/decal/cleanable/xenoblood/xgibs/larva/body
	icon_state = "xgiblarvatorso"
	random_icon_states = list("xgiblarvahead", "xgiblarvatorso")

/obj/effect/decal/cleanable/blood/xtracks
	icon_state = "xtracks"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/xtracks/Initialize(mapload)
	. = ..()
	add_blood_DNA(list("Unknown DNA" = "X*"))
