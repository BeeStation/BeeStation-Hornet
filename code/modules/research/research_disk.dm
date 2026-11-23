
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/list/stored_nodes

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	if(!islist(stored_nodes))
		// gotta make it assoc or else it breaks
		stored_nodes = make_associative(SSresearch.techweb_nodes_starting)
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	custom_materials = null

/obj/item/disk/tech_disk/debug/Initialize(mapload)
	stored_nodes = make_associative(SSresearch.techweb_nodes) // contains every node
	return ..()
