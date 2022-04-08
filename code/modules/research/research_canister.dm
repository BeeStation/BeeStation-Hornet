/obj/item/disk/research
	name = "research disk (empty)"
	desc = "A technology disk containing compressed data related to a specific field of study."
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

/obj/item/artifact_fragment
	name = "artifact fragment"
	desc = "The fragment of an unknown artifact. These are incredibly rare and expensive as damaging artifacts is currently impossible."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "artifact_fragment_1"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | RESIST_DESTRUCTION

/obj/item/artifact_fragment/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	if(prob(50))
		icon_state = "artifact_fragment_2"
