
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/list/stored_nodes

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/// Helper proc to get all of the designs which the nodes stored on this disk contain
/obj/item/disk/tech_disk/proc/get_researched_designs() as /list
	var/list/researched_designs = list()
	for(var/node_path in stored_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		if(!istype(node))
			continue
		researched_designs |= node.unlocked_designs
	return researched_designs

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	custom_materials = null

/obj/item/disk/tech_disk/debug/Initialize(mapload)
	stored_nodes = make_associative(SSresearch.techweb_nodes) // contains every node
	return ..()
