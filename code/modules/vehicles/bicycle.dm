/obj/vehicle/ridden/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon_state = "bicycle"
	fall_off_if_missing_arms = TRUE
	max_integrity = 150
	integrity_failure = 0.5
	var/fried = FALSE

/obj/vehicle/ridden/bicycle/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.vehicle_move_delay = 0


/obj/vehicle/ridden/bicycle/zap_act(power, zap_flags) // :::^^^)))
	//This didn't work for 3 years because none ever tested it I hate life
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	can_buckle = FALSE
	fried = TRUE
	. = ..()
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)

/obj/vehicle/ridden/bicycle/welder_act(mob/living/user, obj/item/I)
	if(fried)
		balloon_alert(user, "it's fried!")
		return TRUE
	if(obj_integrity >= max_integrity)
		return TRUE
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	obj_integrity += min(10, max_integrity-obj_integrity)
	if(obj_integrity == max_integrity)
		balloon_alert(user, "fully repaired")
	else
		balloon_alert(user, "repaired some damages")
	return TRUE
