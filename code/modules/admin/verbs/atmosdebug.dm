/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Plumbing") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for(var/obj/machinery/atmospherics/components/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]")

	//Manifolds
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]")

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]")

	//Erroneous Connections, e.g. duplicate pipes
	//This uses pipeline_expansion(), so you can detect some atmos machineries causing problems at pipenet code.
	for (var/obj/machinery/atmospherics/AM in GLOB.machines)
		for (var/obj/machinery/atmospherics/AMT in AM.pipeline_expansion())
			if (!(AM in AMT.pipeline_expansion()))
				to_chat(usr, "Errorneous connections around [AM.name]. Duplicate or rogue pipes suspected at or around [ADMIN_VERBOSEJMP(AM)]")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Power") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in GLOB.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")
