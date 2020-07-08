/obj/puddle
	name = "Puddle"
	icon = 'icons/puddle.dmi'
	icon_state = "puddle" // just use error state for now
	alpha = 0

/obj/puddle/New()
	reagents = new(3000)

/obj/puddle/proc/update()
	color = mix_color_from_reagents(reagents.reagent_list)
	var/one = reagents.total_volume / reagents.maximum_volume
	alpha = 75 + (one * 180)
	layer = one * 4
	if(reagents.total_volume == 0)
		qdel(src)
		// update layer here

/obj/puddle/proc/spread()
	var/percent = (reagents.total_volume / reagents.maximum_volume) * 100
	if(percent < 10)
		return
	for(var/obj/puddle/p in loc)
		if(p == src)
			continue
		if(p.reagents.total_volume > reagents.total_volume)
			var/list/nearby = list()
			for(var/obj/puddle/near in range(1, src))
				if(src == near)
					continue
				nearby |= nearby
			var/trans_amt = reagents.total_volume / length(nearby)
			for(var/obj/puddle/near in nearby)
				reagents.trans_to(near, trans_amt)
				near.update()
	// get list of turfs with and without nearby puddles
	var/list/nearby_puddles = list()
	var/list/nearby_empty_turfs = list()
	for(var/turf/open/O in range(1, src))
		if(loc == O)  // my home
			continue
		var/obj/puddle/P = locate() in O
		if(P)
			nearby_puddles |= P
		else
			if(isspaceturf(O))
				continue
			var/obj/machinery/door/airlock/A = locate() in O
			if(A && A.density)
				continue
			nearby_empty_turfs |= O

	for(var/turf/open/O in nearby_empty_turfs) // create new puddles
		var/obj/puddle/new_puddle = new(O)
		nearby_puddles |= new_puddle
	
	var/transfer_amt = (reagents.total_volume / 2) / length(nearby_puddles)

	for(var/obj/puddle/puddle in nearby_puddles)
		if(puddle.reagents.total_volume > src.reagents.total_volume)
			continue // cant transfer up
		else
			reagents.trans_to(puddle, transfer_amt)
			puddle.update()

/obj/puddle/process()
	spread()
	update()

/mob/verb/test_spacedrugs()
	var/obj/puddle/puddle = new(loc)
	puddle.reagents.add_reagent(/datum/reagent/drug/space_drugs, puddle.reagents.maximum_volume)
	puddle.update()

/mob/verb/test_crank()
	var/obj/puddle/puddle = new(loc)
	puddle.reagents.add_reagent(/datum/reagent/drug/crank, puddle.reagents.maximum_volume)
	puddle.update()

