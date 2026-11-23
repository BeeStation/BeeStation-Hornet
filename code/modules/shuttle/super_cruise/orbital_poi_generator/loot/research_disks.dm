/obj/item/disk/tech_disk/research
	name = "research disk"
	desc = "A research disk that will unlock a research node when uploaded into a research console."

/obj/item/disk/tech_disk/research/Initialize(mapload)
	. = ..()
	SSorbits.research_disks += src
	update_appearance(UPDATE_NAME)
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#e7a3e4", TRUE, TRUE)
	// After 15 minutes the tracking beacon turns off
	addtimer(CALLBACK(src, PROC_REF(signal_decay)), 15 MINUTES, TIMER_DELETE_ME)

/obj/item/disk/tech_disk/research/Destroy()
	SSorbits.research_disks -= src
	return ..()

/obj/item/disk/tech_disk/research/update_name()
	. = ..()
	if(!LAZYLEN(stored_nodes))
		name = initial(name)
		return
	var/list/node_names = list()
	for(var/node_path in stored_nodes)
		var/datum/techweb_node/node_instance = SSresearch.techweb_nodes[node_path]
		node_names += node_instance.display_name
	name = "[initial(name)] ([jointext(node_names, ", ")])"

/obj/item/disk/tech_disk/research/pickup(mob/user)
	. = ..()
	qdel(GetComponent(/datum/component/tracking_beacon))

/obj/item/disk/tech_disk/research/proc/signal_decay()
	qdel(GetComponent(/datum/component/tracking_beacon))

/obj/item/disk/tech_disk/research/random

/obj/item/disk/tech_disk/research/random/Initialize(mapload)
	var/list/possible_nodes = list(
		/datum/techweb_node/bag_of_holding,
		/datum/techweb_node/wormhole_gun,
		/datum/techweb_node/quantum_spin,
		/datum/techweb_node/plasma_refiner,
		/datum/techweb_node/adv_combat_cyber_implants,
		/datum/techweb_node/combat_cyber_implants,
		/datum/techweb_node/radioactive_weapons,
		/datum/techweb_node/beam_weapons,
		/datum/techweb_node/adv_beam_weapons,
		/datum/techweb_node/phazon,
		/datum/techweb_node/linkedsurgery_implant,
		/datum/techweb_node/bluespace_stabilization,
	)

	var/datum/techweb/science_web = locate(/datum/techweb/science) in SSresearch.techwebs
	possible_nodes -= science_web.researched_nodes

	if(!length(possible_nodes))
		new /obj/effect/spawner/random/ruinloot/basic(loc)
		return INITIALIZE_HINT_QDEL

	stored_nodes = list(pick(possible_nodes))
	return ..()
