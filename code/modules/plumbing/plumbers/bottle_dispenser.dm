///We take a constant input of reagents, and produce a bottle once a set volume is reached
/obj/machinery/plumbing/bottle_dispenser
	name = "bottle filler"
	desc = "A dispenser that fills bottles from a tap."
	icon_state = "pill_press" //TODO SPRITE IT !!!!!!

/obj/machinery/plumbing/bottle_dispenser/examine(mob/user)
	. = ..()
	. += span_notice("Use an open container on it to fill it up!")

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/plumbing/bottle_dispenser)

/obj/machinery/plumbing/bottle_dispenser/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/bottle_dispenser/attackby(obj/item/C, mob/user)
	var/datum/reagents/container = C.reagents
	if (!container)
		return ..()
	if (!(container.flags & OPENCONTAINER))
		user.balloon_alert(user, "[C] is not fillable!")
		return FALSE
	reagents.trans_to(container, min(reagents.total_volume, container.maximum_volume - container.total_volume), transfered_by = user)
	return FALSE
