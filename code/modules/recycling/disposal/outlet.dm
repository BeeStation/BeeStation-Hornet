// the disposal outlet machine
/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	var/active = FALSE
	var/turf/target	// this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/trunk // the attached pipe trunk
	var/start_eject = 0
	var/eject_range = 2

/obj/structure/disposaloutlet/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()

	if(make_from)
		setDir(make_from.dir)

	target = get_ranged_target_turf(src, dir, 10)

	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		trunk.linked = null
		trunk = null
	return ..()

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)
	H.active = FALSE
	flick("outlet-open", src)
	if((start_eject + 30) < world.time)
		start_eject = world.time
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 0, 0)
		addtimer(CALLBACK(src, .proc/expel_holder, H, TRUE), 20)
	else
		addtimer(CALLBACK(src, .proc/expel_holder, H), 20)

/obj/structure/disposaloutlet/proc/expel_holder(obj/structure/disposalholder/H, playsound=FALSE)
	if(playsound)
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)

	if(!H)
		return

	var/turf/T = get_turf(src)

	for(var/A in H)
		var/atom/movable/AM = A
		AM.forceMove(T)
		AM.pipe_eject(dir)
		AM.throw_at(target, eject_range, 1)

	H.vent_gas(T)
	qdel(H)

/obj/structure/disposaloutlet/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	add_fingerprint(user)
	playsound(src, 'sound/items/welder2.ogg', 100, 1)
	to_chat(user, "<span class='notice'>You start slicing the floorweld off [src]...</span>")
	if(I.use_tool(src, user, 20))
		to_chat(user, "<span class='notice'>You slice the floorweld off [src].</span>")
		deconstruct()
	return TRUE

/obj/structure/disposaloutlet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/structure/disposalconstruct(loc, null, SOUTH, FALSE, src)
	..()
