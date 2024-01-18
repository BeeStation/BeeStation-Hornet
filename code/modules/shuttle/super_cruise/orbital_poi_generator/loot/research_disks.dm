/obj/item/disk/tech_disk/research
	desc = "A research disk that will unlock a research node when uploaded into a research console."
	var/node_id

/obj/item/disk/tech_disk/research/Initialize(mapload)
	. = ..()
	SSorbits.research_disks += src
	if(node_id)
		stored_research.hidden_nodes[node_id] = FALSE
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
		name = "research disk ([node.display_name])"

/obj/item/disk/tech_disk/research/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#e7a3e4", TRUE, TRUE)
	//After 15 minutes the tracking beacon turns off
	addtimer(CALLBACK(src, PROC_REF(signal_decay)), 15 MINUTES)

/obj/item/disk/tech_disk/research/proc/signal_decay()
	var/datum/component/tracking_beacon/component = GetComponent(/datum/component/tracking_beacon)
	if(component)
		qdel(component)

/obj/item/disk/tech_disk/research/pickup(mob/user)
	. = ..()
	var/datum/component/tracking_beacon/component = GetComponent(/datum/component/tracking_beacon)
	if(component)
		qdel(component)

/obj/item/disk/tech_disk/research/Destroy()
	SSorbits.research_disks -= src
	var/datum/component/tracking_beacon/component = GetComponent(/datum/component/tracking_beacon)
	if(component)
		qdel(component)
	. = ..()

/obj/item/disk/tech_disk/research/random/Initialize(mapload)
	var/list/valid_nodes = list()
	for(var/obj/item/disk/tech_disk/research/disk as() in subtypesof(/obj/item/disk/tech_disk/research))
		if(!initial(disk.node_id))
			continue
		if(!SSresearch.science_tech.isNodeResearchedID(initial(disk.node_id)))
			valid_nodes += initial(disk.node_id)
	if(!length(valid_nodes))
		new /obj/effect/spawner/lootdrop/ruinloot/basic(get_turf(src))
		return INITIALIZE_HINT_QDEL
	node_id = pick(valid_nodes)
	. = ..()

/obj/item/disk/tech_disk/research/boh
	node_id = "bagofholding"

/obj/item/disk/tech_disk/research/wormhole_gun
	node_id = "wormholegun"

/obj/item/disk/tech_disk/research/swapper
	node_id = "qswapper"

/obj/item/disk/tech_disk/research/plasma_refiner
	node_id = "plasmarefiner"

/obj/item/disk/tech_disk/research/adv_combat_implants
	node_id = "adv_combat_cyber_implants"

/obj/item/disk/tech_disk/research/combat_implants
	node_id = "combat_cyber_implants"

/obj/item/disk/tech_disk/research/radioactive_weapons
	node_id = "radioactive_weapons"

/obj/item/disk/tech_disk/research/beam_weapons
	node_id = "beam_weapons"

/obj/item/disk/tech_disk/research/adv_beam_weapons
	node_id = "adv_beam_weapons"

/obj/item/disk/tech_disk/research/exotic_ammo
	node_id = "exotic_ammo"

/obj/item/disk/tech_disk/research/phazon
	node_id = "mecha_phazon"

/obj/item/disk/tech_disk/research/linkedsurgery_implant
	node_id = "linkedsurgery_implant"

/obj/item/disk/tech_disk/research/bsanchor
	node_id = "bluespace_anchor"
