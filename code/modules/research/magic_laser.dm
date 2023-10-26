/obj/item/magic_laser
	name = "laser tuner"
	desc = "A laser modified to convert impossible frequencies into electronic signals."
	icon_state = "magic_laser"
	icon = 'icons/obj/stock_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/magic_laser/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)
