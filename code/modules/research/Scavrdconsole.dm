/obj/machinery/computer/rdconsole/production/scav
	name = "Design Upload Computer"
	desc = "A Console made to facilitate uploading new designs to the ship board fabricator"
	circuit = /obj/item/circuitboard/computer/rdconsole/production/scav

/obj/machinery/computer/rdconsole/production/scav/Initialize()
	. = ..()
	stored_research = SSresearch.scavenger_tech
	stored_research.consoles_accessing[src] = TRUE
	matching_design_ids = list()
	SyncRDevices()
obj/machinery/computer/rdconsole/production/scav/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["research_node"])
		if(!research_control)
			return				//honestly should call them out for href exploiting :^)
		if(!SSresearch.scavenger_tech.available_nodes[ls["research_node"]])
			return			//Nope!
		research_node(ls["research_node"], usr)
