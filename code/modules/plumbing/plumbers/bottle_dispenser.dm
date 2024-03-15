///We take a constant input of reagents, and produce a bottle once a set volume is reached
/obj/machinery/plumbing/bottle_dispenser
	name = "bottle filler"
	desc = "A dispenser that fills bottles from a tap."
	icon_state = "pill_press" //TODO SPRITE IT !!!!!!

/obj/machinery/plumbing/bottle_dispenser/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The [name] currently has [stored_bottles.len] stored. There needs to be less than [max_floor_bottles] on the floor to continue dispensing.</span>"

/obj/machinery/plumbing/bottle_dispenser/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/bottle_dispenser/attackby(obj/item/C, mob/user)
	var/datum/reagents/container = C.reagents
	if (!container)
		return ..()
	if (!(container.flags & OPENCONTAINER))
		user.balloon_alert("[C] is not fillable!")
		return FALSE
	reagents.trans_to(container, min(reagents.total_volume, container.maximum_volume - container.total_volume), transfered_by = user)
	return FALSE

/obj/machinery/plumbing/bottle_dispenser/process()
	if(machine_stat & NOPOWER)
		return
	if((reagents.total_volume >= bottle_size) && (stored_bottles.len < max_stored_bottles))
		var/obj/item/reagent_containers/glass/bottle/P = new(src)
		reagents.trans_to(P, bottle_size)
		P.name = bottle_name
		stored_bottles += P
	if(stored_bottles.len)
		var/bottle_amount = 0
		for(var/obj/item/reagent_containers/glass/bottle/P in loc)
			bottle_amount++
			if(bottle_amount >= max_floor_bottles) //too much so just stop
				break
		if(bottle_amount < max_floor_bottles)
			var/atom/movable/AM = stored_bottles[1] //AM because forceMove is all we need
			stored_bottles -= AM
			AM.forceMove(drop_location())
