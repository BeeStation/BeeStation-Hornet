/obj/item/weldingtool/makeshift
	name = "Makeshift Welding Tool"
	desc = "Wow, using your emergency airtank for this, what a nice idea."
	icon = 'modular_nostra/icons/obj/tools.dmi'
	icon_state = "makeshift_welder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	change_icons = 0
	toolspeed = 2.5


/obj/item/weldingtool/makeshift/Initialize()
	. = ..()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, 0)
	update_icon()
