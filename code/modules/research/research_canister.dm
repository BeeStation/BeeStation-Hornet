/obj/item/disk/research
	name = "research disk (empty)"
	desc = "A technology disk containing compressed data related to a specific field of study."
	materials = list(/datum/material/iron=50)
	var/overlay_type = ""

/obj/item/disk/research/Initialize(mapload)
	. = ..()
	if(overlay_type)
		add_overlay(overlay_type)

/obj/item/disk/research/physics
	name = "research disk (physics)"
	desc = "A technology disk packed with compressed data related to the nature of physics and the universe."
	icon_state = "research_physics"

/obj/item/disk/research/physics/gold
	name = "high capacity research disk (physics)"
	overlay_type = "research_gold"

/obj/item/disk/research/physics/diamond
	name = "super high capacity research disk (physics)"
	overlay_type = "research_diamond"

/obj/item/disk/research/military
	name = "research disk (military)"
	desc = "A technology disk packed with compressed military weapon testing data."
	icon_state = "research_military"

/obj/item/disk/research/military/gold
	name = "high capacity research disk (military)"
	overlay_type = "research_gold"

/obj/item/disk/research/military/diamond
	name = "super high capacity research disk (military)"
	overlay_type = "research_diamond"

/obj/item/disk/research/biomed
	name = "research disk (biomedical)"
	desc = "A technology disk packed with compressed genetic and biological data."
	icon_state = "research_biomed"

/obj/item/disk/research/biomed/gold
	name = "high capacity research disk (biomedical)"
	overlay_type = "research_gold"

/obj/item/disk/research/biomed/diamond
	name = "super high capacity research disk (biomedical)"
	overlay_type = "research_diamond"
