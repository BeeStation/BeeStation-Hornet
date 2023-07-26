/obj/item/device_linker
	name = "device linker"
	desc = "A device which can be used to link devices together."
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_range = 7
	throw_speed = 3
	materials = list(/datum/material/iron=50, /datum/material/glass=20)
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound =  'sound/items/handling/multitool_pickup.ogg'

/obj/item/device_linker/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/buffer)
