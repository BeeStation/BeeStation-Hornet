#define RND_TECH_DISK	"tech"
#define RND_DESIGN_DISK	"design"


/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The only thing that requires toxins access is locking and unlocking the console on the settings menu.
Nothing else in the console has ID requirements.

*/
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	desc = "A console used to interface with R&D tools."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/disk/tech_disk/t_disk	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy	//Linked Destructive Analyzer
	var/obj/machinery/rnd/production/protolathe/linked_lathe				//Linked Protolathe
	var/obj/machinery/rnd/production/circuit_imprinter/linked_imprinter	//Linked Circuit Imprinter

	req_access = list(ACCESS_TOX)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	var/locked = FALSE
	var/id_cache = list()
	var/id_cache_seq = 1
	var/compact = TRUE

	var/research_control = TRUE

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name
	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/production
	circuit = /obj/item/circuitboard/computer/rdconsole/production
	research_control = FALSE

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/protolathe))
			if(linked_lathe == null)
				var/obj/machinery/rnd/production/protolathe/P = D
				if(!P.console_link)
					continue
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/production/circuit_imprinter))
			if(linked_imprinter == null)
				var/obj/machinery/rnd/production/circuit_imprinter/C = D
				if(!C.console_link)
					continue
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize(mapload)
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(istype(D, /obj/item/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='danger'>A technology disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='danger'>A design disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		investigate_log("[key_name(user)] researched [id]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id))
			say("Successfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			var/i = stored_research.research_logs.len
			stored_research.research_logs += null
			stored_research.research_logs[++i] = list(TN.display_name, price["General Research"], logname, "[get_area(src)] ([src.x],[src.y],[src.z])")
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NEW_RESEARCH, id)
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()

/obj/machinery/computer/rdconsole/on_emag(mob/user)
	..()
	to_chat(user, "<span class='notice'>You disable the security protocols[locked? " and unlock the console":""].</span>")
	playsound(src, "sparks", 75, 1)
	locked = FALSE

/obj/machinery/computer/rdconsole/multitool_act(mob/user, obj/item/multitool/I)
	var/lathe = linked_lathe && linked_lathe.multitool_act(user, I)
	var/print = linked_imprinter && linked_imprinter.multitool_act(user, I)
	return lathe || print

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Techweb", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/rdconsole/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	)

// heavy data from this proc should be moved to static data when possible
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	. = list(
		"nodes" = list(),
		"experiments" = list(),
		"researched_designs" = stored_research.researched_designs,
		"points" = stored_research.research_points,
		"points_last_tick" = stored_research.last_bitcoins,
		"web_org" = stored_research.organization,
		"sec_protocols" = !(obj_flags & EMAGGED),
		"t_disk" = null,
		"d_disk" = null,
		"locked" = locked,
		"linkedanalyzer" = FALSE,
		"analyzertechs" = list(),
		"itemmats" = list(),
		"itempoints" = list(),
		"analyzeritem" = null,
		"compact" = compact,
		"tech_tier" = stored_research.current_tier,
	)

	if (t_disk)
		.["t_disk"] = list (
			"stored_research" = t_disk.stored_research.researched_nodes
		)
	if (d_disk)
		.["d_disk"] = list (
			"max_blueprints" = d_disk.max_blueprints,
			"blueprints" = list()
		)
		for (var/i in 1 to d_disk.max_blueprints)
			if (d_disk.blueprints[i])
				var/datum/design/D = d_disk.blueprints[i]
				.["d_disk"]["blueprints"] += D.id
			else
				.["d_disk"]["blueprints"] += null

	if(linked_destroy && (!QDELETED(linked_destroy)))
		.["linkedanalyzer"] = TRUE

		if(linked_destroy.loaded_item && (!QDELETED(linked_destroy.loaded_item)))
			var/list/techyitems = techweb_item_boost_check(linked_destroy.loaded_item)
			var/list/pointss = techweb_item_point_check(linked_destroy.loaded_item)
			var/list/materials = linked_destroy.loaded_item.materials
			var/list/matstuff = list()

			if(length(techyitems))
				for(var/v in techyitems)
					.["analyzertechs"][v] = 1
			else
				.["analyzertechs"] = null
			for(var/M in materials)
				matstuff += "[CallMaterialName(M)] x [materials[M]]"
			if(length(matstuff))
				.["itemmats"] = matstuff
			else
				.["itemmats"] = null
			if(length(pointss))
				.["itempoints"] = techweb_point_display_generic(pointss, FALSE)
			else
				.["itempoints"] = null
			.["analyzeritem"] = linked_destroy.loaded_item.name
		else
			.["analyzeritem"] = null
	else
		.["linkedanalyzer"] = FALSE



	// Serialize all nodes to display
	for(var/v in stored_research.tiers)
		var/datum/techweb_node/n = SSresearch.techweb_node_by_id(v)

		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[v])
			continue

		var/costs = n.get_price(stored_research)

		.["nodes"] += list(list(
			"id" = n.id,
			"can_unlock" = stored_research.can_afford(costs),
			"costs" = costs,
			"tier" = stored_research.tiers[n.id]
		))

/obj/machinery/computer/rdconsole/proc/compress_id(id)
	if (!id_cache[id])
		id_cache[id] = id_cache_seq
		id_cache_seq += 1
	return id_cache[id]

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	. = list(
		"static_data" = list(),
		"researchable" = research_control
	)
	// Build node cache...
	// Note this looks a bit ugly but its to reduce the size of the JSON payload
	// by the greatest amount that we can, as larger JSON payloads result in
	// hanging when the user opens the UI
	var/node_cache = list()
	for (var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id] || SSresearch.error_node
		var/compressed_id = "[compress_id(node.id)]"
		node_cache[compressed_id] = list(
			"name" = node.display_name,
			"description" = node.description,
			"node_tier" = node.tech_tier,
		)
		if (LAZYLEN(node.prereq_ids))
			node_cache[compressed_id]["prereq_ids"] = list()
			for (var/prerequisite_node in node.prereq_ids)
				node_cache[compressed_id]["prereq_ids"] += compress_id(prerequisite_node)
		if (LAZYLEN(node.design_ids))
			node_cache[compressed_id]["design_ids"] = list()
			for (var/unlocked_design in node.design_ids)
				node_cache[compressed_id]["design_ids"] += compress_id(unlocked_design)
		if (LAZYLEN(node.unlock_ids))
			node_cache[compressed_id]["unlock_ids"] = list()
			for (var/unlocked_node in node.unlock_ids)
				node_cache[compressed_id]["unlock_ids"] += compress_id(unlocked_node)

	// Build design cache
	var/design_cache = list()
	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"
	for (var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_id] || SSresearch.error_design
		var/compressed_id = "[compress_id(design.id)]"
		var/size = spritesheet.icon_size_id(design.id)
		design_cache[compressed_id] = list(
			design.name,
			design.desc,
			"[size == size32x32 ? "" : "[size] "][design.id]"
		)

	// Ensure id cache is included for decompression
	var/flat_id_cache = list()
	for (var/id in id_cache)
		flat_id_cache += id

	.["static_data"] = list(
		"node_cache" = node_cache,
		"design_cache" = design_cache,
		"id_cache" = flat_id_cache
	)

/obj/machinery/computer/rdconsole/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	add_fingerprint(usr)

	// Check if the console is locked to block any actions occuring
	if (locked && action != "toggleLock")
		say("Console is locked, cannot perform further actions.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(obj_flags & EMAGGED)
				to_chat(usr, "<span class='boldwarning'>Security protocol error: Unable to access locking protocols.</span>")
				return TRUE
			if(allowed(usr))
				locked = !locked
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
			return TRUE
		if ("compactify")
			compact = !compact
			return TRUE
		if ("linkmachines")
			say("Linked nearby machines!")
			SyncRDevices()
			return TRUE
		if ("researchNode")
			if(!research_control)
				return TRUE
			if(!SSresearch.science_tech.available_nodes[params["node_id"]])
				return TRUE
			research_node(params["node_id"], usr)
			return TRUE
		if ("ejectDisk")
			eject_disk(params["type"])
			return TRUE
		if ("writeDesign")
			if(QDELETED(d_disk))
				say("No Design Disk Inserted!")
				return TRUE
			var/slot = text2num(params["slot"])
			var/datum/design/design = SSresearch.techweb_design_by_id(params["selectedDesign"])
			if(design)
				var/autolathe_friendly = TRUE
				if(design.reagents_list.len)
					autolathe_friendly = FALSE
					design.category -= "Imported"
				else
					for(var/material in design.materials)
						if( !(material in list(/datum/material/iron, /datum/material/glass)))
							autolathe_friendly = FALSE
							design.category -= "Imported"

				if(design.build_type & (AUTOLATHE|PROTOLATHE)) // Specifically excludes circuit imprinter and mechfab
					design.build_type = autolathe_friendly ? (design.build_type | AUTOLATHE) : design.build_type
					design.category |= "Imported"
				d_disk.blueprints[slot] = design
			return TRUE
		if ("uploadDesignSlot")
			if(QDELETED(d_disk))
				say("No design disk found.")
				return TRUE
			var/n = text2num(params["slot"])
			stored_research.add_design(d_disk.blueprints[n], TRUE)
			return TRUE
		if ("clearDesignSlot")
			if(QDELETED(d_disk))
				say("No design disk inserted!")
				return TRUE
			var/n = text2num(params["slot"])
			var/datum/design/D = d_disk.blueprints[n]
			say("Wiping design [D.name] from design disk.")
			d_disk.blueprints[n] = null
			return TRUE
		if ("eraseDisk")
			if (params["type"] == RND_DESIGN_DISK)
				if(QDELETED(d_disk))
					say("No design disk inserted!")
					return TRUE
				say("Wiping design disk.")
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			if (params["type"] == RND_TECH_DISK)
				if(QDELETED(t_disk))
					say("No tech disk inserted!")
					return TRUE
				qdel(t_disk.stored_research)
				t_disk.stored_research = new
				say("Wiping technology disk.")
			return TRUE
		if ("uploadDisk")
			if (params["type"] == RND_DESIGN_DISK)
				if(QDELETED(d_disk))
					say("No design disk inserted!")
					return TRUE
				for(var/D in d_disk.blueprints)
					if(D)
						stored_research.add_design(D, TRUE)
			if (params["type"] == RND_TECH_DISK)
				if (QDELETED(t_disk))
					say("No tech disk inserted!")
					return TRUE
				say("Uploading technology disk.")
				t_disk.stored_research.copy_research_to(stored_research)
			return TRUE
		if ("loadTech")
			if(QDELETED(t_disk))
				say("No tech disk inserted!")
				return
			stored_research.copy_research_to(t_disk.stored_research)
			say("Downloading to technology disk.")
			return TRUE

		if ("destroyfortech")
			if(!linked_destroy || QDELETED(linked_destroy))
				say("No linked destructive analyzer!")
				return
			if(params["node_id"])
				linked_destroy.user_try_decon_id(params["node_id"], usr)
			return TRUE
		if ("destroyitem")
			if(!linked_destroy || QDELETED(linked_destroy))
				say("No linked destructive analyzer!")
				return
			linked_destroy.user_try_decon_id(null, usr)
			return TRUE
		if ("ejectitem")
			if(!linked_destroy || QDELETED(linked_destroy))
				say("No linked destructive analyzer!")
				return
			linked_destroy.unload_item()
			return TRUE

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design")
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech")
		t_disk.forceMove(get_turf(src))
		t_disk = null

/obj/machinery/computer/rdconsole/proc/check_canprint(datum/design/D, buildtype)
	var/amount = 50
	if(buildtype == IMPRINTER)
		if(QDELETED(linked_imprinter))
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_imprinter.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else if(buildtype == PROTOLATHE)
		if(QDELETED(linked_lathe))
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_lathe.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else
		return FALSE
	return amount

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize(mapload)
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"

#undef RND_TECH_DISK
#undef RND_DESIGN_DISK
