/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron = 300, /datum/material/glass = 100)

	/// A List of all design typepaths that are stored on this disk
	var/list/blueprints

/obj/item/disk/design_disk/Initialize(mapload)
	. = ..()
	if(!mapload)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/disk/design_disk/Destroy()
	blueprints = null
	return ..()
