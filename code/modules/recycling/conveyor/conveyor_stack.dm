/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'monkestation/icons/obj/machinery/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	merge_type = /obj/item/stack/conveyor
	/// ID for linking a belt to one or more switches, all conveyors with the same ID will be controlled the same switch(es).
	var/id = ""

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(target) || istype(target, /area/shuttle))
		return
	var/belt_dir = get_dir(target, user)
	if(target == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return
	var/obj/machinery/conveyor/belt = new/obj/machinery/conveyor(target, belt_dir, id)
	transfer_fingerprints_to(belt)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/item_used, mob/user, params)
	..()
	if(istype(item_used, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("You link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/switch_construct = item_used
		id = switch_construct.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30
