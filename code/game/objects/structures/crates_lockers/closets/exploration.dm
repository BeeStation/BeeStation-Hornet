/obj/structure/closet/crate/science/shuttle
	name = "\proper Shuttle Supplies crate"
	icon_state = "sci_crate"
	
/obj/structure/closet/crate/science/shuttle/populate_contents_immediate()
	..()
	new /obj/item/circuitboard/computer/shuttle/exploration_shuttle(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/multitool(src)
	new /obj/item/radio/headset/headset_exploration(src)
	new /obj/item/radio/headset/headset_exploration(src)
	new /obj/item/radio/headset/headset_exploration(src)

/obj/structure/closet/crate/science/mining
	name = "\proper Mining Supplies crate"
	icon_state = "crate"
	
/obj/structure/closet/crate/science/mining/populate_contents_immediate()
	..()
	new /obj/item/storage/bag/ore(src)
	new /obj/item/pickaxe(src)
	new /obj/item/mining_scanner(src)
	new /obj/item/gps/mining/exploration(src)

