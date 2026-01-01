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

	req_access = list(ACCESS_TOX)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	var/locked = FALSE
	var/id_cache = list()
	var/id_cache_seq = 1
	var/compact = TRUE

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name
	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/LateInitialize()
	. = ..()
	if(!stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		stored_research.consoles_accessing += src

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
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
				to_chat(user, span_danger("A technology disk is already loaded!"))
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, span_danger("[D] is stuck to your hand!"))
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, span_danger("A design disk is already loaded!"))
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, span_danger("[D] is stuck to your hand!"))
				return
			d_disk = D
		else
			to_chat(user, span_danger("Machine cannot accept disks in that format."))
			return
		to_chat(user, span_notice("You insert [D] into \the [src]!"))
		return
	return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/rdconsole)
DEFINE_BUFFER_HANDLER(/obj/machinery/computer/rdconsole)
	if(istype(buffer, /datum/techweb))
		balloon_alert(user, "techweb connected")
		stored_research = buffer
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research || !stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either no techweb is found, node is already researched or is not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		user.investigate_log("researched [id]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(istype(stored_research, /datum/techweb/science))
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id, research_source = src))
			say("Successfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI [user.name]"
			if(iscyborg(user))
				logname = "CYBORG [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "[idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "[ID.registered_name]"
			stored_research.research_logs += list(list(
				"node_name" = TN.display_name,
				"node_cost" = price[TECHWEB_POINT_TYPE_GENERIC],
				"node_researcher" = logname,
				"node_research_location" = "[get_area(src)]",
			))
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/on_emag(mob/user)
	..()
	balloon_alert(user, "security protocols disabled")
	playsound(src, "sparks", 75, TRUE)
	var/obj/item/circuitboard/computer/rdconsole/board = circuit
	if(!(board.obj_flags & EMAGGED))
		board.silence_announcements = TRUE
	locked = FALSE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Techweb", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/rdconsole/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs),
	)

// heavy data from this proc should be moved to static data when possible
/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	data["stored_research"] = !!stored_research
	data["locked"] = locked
	if(!stored_research) //lack of a research node is all we care about.
		return data
	data += list(
		"nodes" = list(),
		"experiments" = list(),
		"researched_designs" = stored_research.researched_designs,
		"points" = stored_research.research_points,
		"points_last_tick" = stored_research.last_bitcoins,
		"web_org" = stored_research.organization,
		"sec_protocols" = !(obj_flags & EMAGGED),
		"t_disk" = null,
		"d_disk" = null,
		"itemmats" = list(),
		"itempoints" = list(),
		"analyzeritem" = null,
		"compact" = compact,
		"tech_tier" = stored_research.current_tier,
	)

	if (t_disk)
		data["t_disk"] = list (
			"stored_research" = t_disk.stored_research.researched_nodes
		)
	if (d_disk)
		data["d_disk"] = list("blueprints" = list())
		for (var/datum/design/D in d_disk.blueprints)
			data["d_disk"]["blueprints"] += D.id

	// Serialize all nodes to display
	for(var/v in stored_research.tiers)
		var/datum/techweb_node/n = SSresearch.techweb_node_by_id(v)

		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[v])
			continue

		var/costs = n.get_price(stored_research)

		data["nodes"] += list(list(
			"id" = n.id,
			"can_unlock" = stored_research.can_afford(costs),
			"tier" = stored_research.tiers[n.id],
			"costs" = costs,
		))
	return data

/obj/machinery/computer/rdconsole/proc/compress_id(id)
	if (!id_cache[id])
		id_cache[id] = id_cache_seq
		id_cache_seq += 1
	return id_cache[id]

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	. = list(
		"static_data" = list(),
		"point_types_abbreviations" = SSresearch.point_types,
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
	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	for (var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_id] || SSresearch.error_design
		var/compressed_id = "[compress_id(design.id)]"
		var/size = spritesheet.icon_size_id(design.id)
		design_cache[compressed_id] = list(
			design.name,
			design.desc,
			"["[size] "][design.id]"
		)

	// Ensure id cache is included for decompression
	var/flat_id_cache = list()
	for (var/id in id_cache)
		flat_id_cache += id

	.["static_data"] = list(
		"node_cache" = node_cache,
		"design_cache" = design_cache,
		"id_cache" = flat_id_cache,
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
				to_chat(usr, span_boldwarning("Security protocol error: Unable to access locking protocols."))
				return TRUE
			if(allowed(usr))
				locked = !locked
			else
				to_chat(usr, span_boldwarning("Unauthorized Access."))
			return TRUE
		if ("compactify")
			compact = !compact
			return TRUE
		if ("researchNode")
			research_node(params["node_id"], usr)
			return TRUE
		if ("ejectDisk")
			eject_disk(params["type"])
			return TRUE
		if ("uploadDisk")
			if (params["type"] == RND_DESIGN_DISK)
				if(QDELETED(d_disk))
					say("No design disk inserted!")
					return TRUE
				for(var/D in d_disk.blueprints)
					if(D)
						stored_research.add_design(D, TRUE)
				say("Uploading blueprints from disk.")
				return TRUE
			if (params["type"] == RND_TECH_DISK)
				if (QDELETED(t_disk))
					say("No tech disk inserted!")
					return TRUE
				say("Uploading technology disk.")
				t_disk.stored_research.copy_research_to(stored_research)
			return TRUE
		// Tech disk-only action
		if ("loadTech")
			if(QDELETED(t_disk))
				say("No tech disk inserted!")
				return
			stored_research.copy_research_to(t_disk.stored_research)
			say("Downloading to technology disk.")
			return TRUE

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == RND_DESIGN_DISK && d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == RND_TECH_DISK && t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null

/obj/machinery/computer/rdconsole/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_ID_GIVE_GENERAL_POINT, "Give General Points")
	VV_DROPDOWN_OPTION(VV_ID_GIVE_DISCOVERY_POINT, "Give Discovery Points")
	VV_DROPDOWN_OPTION(VV_ID_GIVE_NANITE_POINT, "Give Nanite Points")

/obj/machinery/computer/rdconsole/vv_do_topic(list/href_list)
	. = ..()

	var/point_type
	if(href_list[VV_ID_GIVE_GENERAL_POINT])
		point_type = TECHWEB_POINT_TYPE_GENERIC
	else if(href_list[VV_ID_GIVE_DISCOVERY_POINT])
		point_type = TECHWEB_POINT_TYPE_DISCOVERY
	else if(href_list[VV_ID_GIVE_NANITE_POINT])
		point_type = TECHWEB_POINT_TYPE_NANITES

	if(!(point_type in TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES))
		return

	var/target_value = input(usr, "How many [point_type] points would you like to add? (use negative to take)", "Give [point_type] points") as num
	stored_research.add_point_type(point_type, target_value)
	to_chat(usr, "Success: [target_value] points have been added to [point_type]")


#undef RND_TECH_DISK
#undef RND_DESIGN_DISK
