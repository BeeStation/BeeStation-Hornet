/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	max_integrity = BLOB_NODE_MAX_HP
	max_hit_damage = 40
	armor_type = /datum/armor/blob_node
	health_regen = BLOB_NODE_HP_REGEN
	point_return = BLOB_REFUND_NODE_COST
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

/obj/structure/blob/node/process(delta_time)
	if(overmind)
		Pulse_Area(overmind, BLOB_NODE_CLAIM_RANGE, BLOB_NODE_PULSE_RANGE, BLOB_NODE_EXPAND_RANGE)

	for(var/obj/structure/blob/normal/B in range(BLOB_NODE_STRONG_REINFORCE_RANGE, src))
		if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
			B.change_to(/obj/structure/blob/shield/core, overmind)
	for(var/obj/structure/blob/normal/B in range(BLOB_NODE_REFLECTOR_REINFORCE_RANGE, src))
		if(DT_PROB(BLOB_REINFORCE_CHANCE, delta_time))
			B.change_to(/obj/structure/blob/shield/reflective, overmind)

/obj/structure/blob/node/lone/process()
	Pulse_Area(overmind, BLOB_NODE_CLAIM_RANGE, BLOB_NODE_PULSE_RANGE, BLOB_NODE_EXPAND_RANGE)


