/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	max_integrity = 200
	max_hit_damage = 40
	armor_type = /datum/armor/blob_node
	health_regen = 3
	point_return = 25
	resistance_flags = LAVA_PROOF


/datum/armor/blob_node
	fire = 65
	acid = 90

/obj/structure/blob/node/Initialize(mapload)
	GLOB.blob_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/blob/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/node/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	add_overlay(blob_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_node_overlay"))

/obj/structure/blob/node/Destroy()
	GLOB.blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/process()
	if(overmind)
		Pulse_Area(overmind, 10, 3, 2)

/obj/structure/blob/node/lone/process()
	Pulse_Area(overmind, 10, 3, 2)


