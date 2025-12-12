/obj/item/clothing/shoes/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either." //Thanks Fel
	icon_state = "sneakers"
	worn_icon_state = "wheelys"
	inhand_icon_state = "wheelys"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_wheelys
	actions_types = list(/datum/action/item_action/wheelys)
	custom_price = 100
	///False means wheels are not popped out
	var/wheelToggle = FALSE
	///The vehicle associated with the shoes
	var/obj/vehicle/ridden/scooter/skateboard/wheelys/W

/obj/item/clothing/shoes/wheelys/Initialize(mapload)
	. = ..()
	W = new /obj/vehicle/ridden/scooter/skateboard/wheelys(null)

/obj/item/clothing/shoes/wheelys/ui_action_click(mob/user, action)
	if(!isliving(user))
		return
	if(!istype(user.get_item_by_slot(ITEM_SLOT_FEET), /obj/item/clothing/shoes/wheelys))
		balloon_alert(user, "must be worn!")
		return
	if(!(W.is_occupant(user)))
		wheelToggle = FALSE
	if(wheelToggle)
		W.unbuckle_mob(user)
		wheelToggle = FALSE
		return
	W.forceMove(get_turf(user))
	W.buckle_mob(user)
	wheelToggle = TRUE

/obj/item/clothing/shoes/wheelys/dropped(mob/user)
	..()
	if(wheelToggle)
		W.unbuckle_mob(user)
		wheelToggle = FALSE

/obj/item/clothing/shoes/wheelys/Destroy()
	QDEL_NULL(W)
	. = ..()
