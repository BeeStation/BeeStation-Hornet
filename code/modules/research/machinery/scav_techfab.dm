var/datum/techweb/host_research
/obj/machinery/rnd/production/techfab/scav
	name = "Scavfab"
	desc = "Produces researched prototypes with raw materials and energy."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab/scav
	department_tag = "Scavenger"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCAV
/obj/machinery/rnd/production/techfab/scav/Initialize(mapload)
		. = ..()
		create_reagents(0, OPENCONTAINER)
		matching_designs = list()
		cached_designs = list()
		stored_research = new
		host_research = SSresearch.scavenger_tech
		update_research()
		materials = AddComponent(/datum/component/remote_materials, "lathe", mapload)
		RefreshParts()
