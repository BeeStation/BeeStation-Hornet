/obj/puddle
	name = "Puddle"
	icon = 'icons/obj/puddle.dmi'
	icon_state = "puddle" // just use error state for now
	alpha = 0
	appearance_flags = RESET_ALPHA

/obj/puddle/Initialize()
	. = ..()
	SSpuddle.puddlelist += src
	reagents = new(1250)

/obj/puddle/proc/update()
	color = mix_color_from_reagents(reagents.reagent_list)
	var/one = reagents.total_volume / reagents.maximum_volume
	alpha = 45 + (one * 210)
	layer = one * 5
	if(reagents.total_volume == 0)
		qdel(src)

/obj/puddle/proc/spread()
	var/percent = (reagents.total_volume / reagents.maximum_volume) * 100
	if(percent < 4)
		return

	var/turf/t_loc = get_turf(src)
	for(var/obj/puddle/puddle in t_loc) // condense all puddles on the same tile into one puddle
		if(src == puddle)
			continue
		if(puddle.reagents.total_volume + reagents.total_volume <= puddle.reagents.maximum_volume)
			reagents.trans_to(puddle, reagents.total_volume)
			qdel(src)

	var/list/near = list()  // list of puddles within 1 tile

	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		var/obj/puddle/p = locate() in T
		if(p)
			near += p
			continue
		p  = new(T)
		near += p

	if(!length(near))
		return

	var/transfer_amt = (reagents.total_volume / 2) / length(near)

	for(var/obj/puddle/puddle in near)
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