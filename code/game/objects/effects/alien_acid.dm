/obj/effect/acid
	gender = PLURAL
	name = "acid"
	desc = "Burbling corrosive stuff."
	icon_state = "acid"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = ABOVE_NORMAL_TURF_LAYER
	var/turf/target


CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/acid)

/obj/effect/acid/Initialize(mapload, acid_pwr, acid_amt)
	. = ..()

	target = get_turf(src)

	if(acid_amt)
		acid_level = min(acid_amt*acid_pwr, 12000) //capped so the acid effect doesn't last a half hour on the floor.

	//handle APCs and newscasters and stuff nicely
	pixel_x = target.pixel_x + rand(-4,4)
	pixel_y = target.pixel_y + rand(-4,4)

	START_PROCESSING(SSobj, src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/acid/Destroy()
	STOP_PROCESSING(SSobj, src)
	target = null
	return ..()

/obj/effect/acid/process()
	. = 1
	if(!target)
		qdel(src)
		return 0

	if(prob(5))
		playsound(loc, 'sound/items/welder.ogg', 100, 1)

	for(var/obj/O in target)
		if(O.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE))
			continue
		if(prob(20))
			if(O.acid_level < acid_level*0.3)
				var/acid_used = min(acid_level*0.05, 20)
				O.acid_act(10, acid_used)
				acid_level = max(0, acid_level - acid_used*10)

	acid_level = max(acid_level - (5 + 2*round(sqrt(acid_level))), 0)
	if(acid_level <= 0)
		qdel(src)
		return 0

/obj/effect/acid/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	if(isliving(AM))
		var/mob/living/L = AM
		if(L.movement_type & (FLOATING|FLYING))
			return
		if(L.m_intent != MOVE_INTENT_WALK && prob(40))
			var/acid_used = min(acid_level*0.05, 20)
			if(L.acid_act(10, acid_used, "feet"))
				acid_level = max(0, acid_level - acid_used*10)
				playsound(L, 'sound/weapons/sear.ogg', 50, 1)
				to_chat(L, span_userdanger("[src] burns you!"))

//xenomorph corrosive acid
/obj/effect/acid/alien
	var/target_strength = 30


/obj/effect/acid/alien/process()
	. = ..()
	if(.)
		if(prob(45))
			playsound(loc, 'sound/items/welder.ogg', 100, 1)
		target_strength--
		if(target_strength <= 0)
			target.visible_message(span_warning("[target] collapses under its own weight into a puddle of goop and undigested debris!"))
			target.acid_melt()
			qdel(src)
		else

			switch(target_strength)
				if(24)
					visible_message(span_warning("[target] is holding up against the acid!"))
				if(16)
					visible_message(span_warning("[target] is being melted by the acid!"))
				if(8)
					visible_message(span_warning("[target] is struggling to withstand the acid!"))
				if(4)
					visible_message(span_warning("[target] begins to crumble under the acid!"))
