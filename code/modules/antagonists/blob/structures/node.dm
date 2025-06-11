/obj/structure/blob/special/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	max_integrity = BLOB_NODE_MAX_HP
	max_hit_damage = BLOB_NODE_MAX_HP / 10
	health_regen = BLOB_NODE_HP_REGEN
	armor_type = /datum/armor/blob_node
	point_return = BLOB_REFUND_NODE_COST
	claim_range	= BLOB_NODE_CLAIM_RANGE
	pulse_range = BLOB_NODE_PULSE_RANGE
	expand_range = BLOB_NODE_EXPAND_RANGE
	resistance_flags = LAVA_PROOF
	max_spores = BLOB_NODE_MAX_SPORES
	ignore_syncmesh_share = TRUE

/datum/armor/blob_node
	fire = 65
	acid = 90

/obj/structure/blob/special/node/Initialize(mapload)
	GLOB.blob_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/blob/special/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/special/node/update_icon()
	cut_overlays()
	color = null
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/blob.dmi', "blob")
	if(overmind)
		blob_overlay.color = overmind.blobstrain.color
	add_overlay(blob_overlay)
	add_overlay(mutable_appearance('icons/mob/blob.dmi', "blob_node_overlay"))

/obj/structure/blob/special/node/creation_action()
	if(overmind)
		overmind.node_blobs += src

/obj/structure/blob/special/node/Destroy()
	GLOB.blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	if(overmind)
		overmind.node_blobs -= src
	return ..()

/obj/structure/blob/special/node/process(delta_time)
	if(overmind)
		pulse_area(overmind, claim_range, pulse_range, expand_range)
		reinforce_area(delta_time)
		produce_spores()

/obj/structure/blob/special/node/lone/process(delta_time)
	pulse_area(overmind, claim_range, pulse_range, expand_range)
	reinforce_area(delta_time)
	produce_spores()


