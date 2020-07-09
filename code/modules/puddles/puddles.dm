/obj/puddle
	name = "Puddle"
	icon = 'icons/obj/puddle.dmi'
	icon_state = "puddle" // just use error state for now
	alpha = 0

/obj/puddle/Initialize()
	. = ..()
	SSpuddle.puddlelist += src
	reagents = new(1500)

/obj/puddle/proc/update()
	color = mix_color_from_reagents(reagents.reagent_list)
	var/one = reagents.total_volume / reagents.maximum_volume
	alpha = 75 + (one * 180)
	layer = one * 5
	if(reagents.total_volume == 0)
		qdel(src)
		// update layer here

/obj/puddle/proc/spread()
	var/percent = (reagents.total_volume / reagents.maximum_volume) * 100
	if(percent < 1)
		return

	var/turf/t_loc = get_turf(src)
	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		if(locate(/obj/puddle) in T)
			continue
		new /obj/puddle(T)
	
	var/list/nearby_puddles = list()

	for(var/obj/puddle/p in range(1, src))
		nearby_puddles += p

	var/transfer_amt = (reagents.total_volume / 2) / length(nearby_puddles)

	for(var/obj/puddle/puddle in nearby_puddles)
		if(puddle.reagents.total_volume > src.reagents.total_volume)
			continue // cant transfer up
		else
			reagents.trans_to(puddle, transfer_amt)
			puddle.update()

/obj/puddle/Destroy()
	. = ..()
	SSpuddle.puddlelist -= src

/obj/puddle/proc/called()
	set waitfor = FALSE
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