#define RND_TECH_DISK "tech"
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
	circuit = /obj/item/circuitboard/computer/rdconsole
	req_access = list(ACCESS_TOX) // Locking and unlocking the console requires research access
	/// Reference to global science techweb
	var/datum/techweb/stored_research
	/// The stored technology disk, if present
	var/obj/item/disk/tech_disk/t_disk
	/// The stored design disk, if present
	var/obj/item/disk/design_disk/d_disk
	/// Used for compressing data sent to the UI via static_data as payload size is of concern
	var/id_cache = list()
	/// Sequence var for the id cache
	var/id_cache_seq = 1
	/// If the UI is in "compact" mode
	var/compact = TRUE
	/// Cooldown that prevents hanging the MC when tech disks are copied
	STATIC_COOLDOWN_DECLARE(copy_cooldown)

/obj/machinery/computer/rdconsole/unlocked
	circuit = /obj/item/circuitboard/computer/rdconsole/unlocked

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

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, list/modifiers)
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

/obj/machinery/computer/rdconsole/proc/research_node(node_path, mob/user)
	if(!stored_research)
		say("Node unlock failed: No techweb found!")
		return FALSE
	if(!stored_research.available_nodes[node_path])
		say("Node unlock failed: Node is not available!")
		return FALSE
	if(stored_research.researched_nodes[node_path])
		say("Node unlock failed: Node is already researched!")
		return FALSE

	var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[node_path]
	if(!istype(unlocked_node))
		say("Node unlock failed: Unknown error.")
		return FALSE

	var/list/price = unlocked_node.get_price(stored_research)
	if(!stored_research.can_afford(price))
		say("Not enough research points...")
		return FALSE

	if(!stored_research.research_node(unlocked_node, research_source = src))
		say("Failed to research node: Internal database error!")
		return FALSE

	user.investigate_log("researched [unlocked_node.display_name]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
	if(istype(stored_research, /datum/techweb/science))
		SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("path" = "[node_path]", "name" = unlocked_node.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))

	say("Successfully researched [unlocked_node.display_name].")

	var/logname
	if(isAI(user))
		logname = "AI [user.name]"
	else if(iscyborg(user))
		logname = "CYBORG [user.name]"
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/obj/item/card/id/id = human_user.wear_id?.GetID()
		if(istype(id))
			logname = "[id.registered_name]"
	else if(iscarbon(user))
		var/obj/item/card/id/idcard = user.get_active_held_item()
		if(istype(idcard))
			logname = "[idcard.registered_name]"
	else
		logname = "Unknown"

	stored_research.research_logs += list(list(
		"node_name" = unlocked_node.display_name,
		"node_cost" = price[TECHWEB_POINT_TYPE_GENERIC],
		"node_researcher" = logname,
		"node_research_location" = "[get_area(src)]",
	))
	return TRUE

/obj/machinery/computer/rdconsole/on_emag(mob/user)
	..()
	balloon_alert(user, "security protocols disabled")
	playsound(src, "sparks", 75, TRUE)
	var/obj/item/circuitboard/computer/rdconsole/board = circuit
	if(!(board.obj_flags & EMAGGED))
		board.silence_announcements = TRUE
	board.locked = FALSE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
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

	var/obj/item/circuitboard/computer/rdconsole/board = circuit

	data["stored_research"] = !!stored_research
	data["locked"] = board.locked
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
		data["t_disk"] = list(
			"stored_research" = t_disk.stored_nodes
		)
	if (d_disk)
		data["d_disk"] = list(
			"blueprints" = d_disk.blueprints
		)

	// Serialize all nodes to display
	for(var/node_path, node_tier in stored_research.tiers)
		// Ensure node is supposed to be visible
		if (stored_research.hidden_nodes[node_path])
			continue

		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		var/list/costs = node.get_price(stored_research)
		data["nodes"] += list(list(
			"path" = node_path,
			"can_unlock" = stored_research.can_afford(costs),
			"tier" = node_tier,
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
	var/list/node_cache = list()
	for (var/node_path, _node in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = _node
		var/compressed_id = "[compress_id(node.type)]"
		node_cache[compressed_id] = list(
			"name" = node.display_name,
			"description" = node.description,
			"node_tier" = node.tech_tier,
		)
		if (LAZYLEN(node.prerequisite_nodes))
			node_cache[compressed_id]["prerequisite_nodes"] = list()
			for (var/prerequisite_node in node.prerequisite_nodes)
				node_cache[compressed_id]["prerequisite_nodes"] += compress_id(prerequisite_node)
		if (LAZYLEN(node.unlocked_designs))
			node_cache[compressed_id]["unlocked_designs"] = list()
			for (var/unlocked_design in node.unlocked_designs)
				node_cache[compressed_id]["unlocked_designs"] += compress_id(unlocked_design)
		if (LAZYLEN(node.unlocked_nodes))
			node_cache[compressed_id]["unlocked_nodes"] = list()
			for (var/unlocked_node in node.unlocked_designs)
				node_cache[compressed_id]["unlocked_nodes"] += compress_id(unlocked_node)

	// Build design cache
	var/list/design_cache = list()
	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	for (var/design_path, _design in SSresearch.techweb_designs)
		var/datum/design/design = _design
		var/size = spritesheet.icon_size_id(design.asset_id)
		design_cache["[compress_id(design.type)]"] = list(
			design.name,
			design.desc,
			"[size] [design.asset_id]",
		)

	// Ensure id cache is included for decompression
	var/flat_id_cache = assoc_to_keys(id_cache)

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

	var/obj/item/circuitboard/computer/rdconsole/board = circuit

	// Check if the console is locked to block any actions occuring
	if (board.locked && action != "toggleLock")
		say("Console is locked, cannot perform further actions.")
		return TRUE

	switch (action)
		if ("toggleLock")
			if(obj_flags & EMAGGED)
				to_chat(usr, span_boldwarning("Security protocol error: Unable to access locking protocols."))
				return TRUE
			if(allowed(usr))
				board.locked = !board.locked
			else
				to_chat(usr, span_boldwarning("Unauthorized Access."))
			return TRUE
		if ("compactify")
			compact = !compact
			return TRUE
		if ("researchNode")
			research_node(text2path(params["node_path"]), usr)
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
				if (!COOLDOWN_FINISHED(src, copy_cooldown)) // prevents MC hang
					say("Servers busy!")
					return
				if (QDELETED(t_disk))
					say("No tech disk inserted!")
					return TRUE
				COOLDOWN_START(src, copy_cooldown, 5 SECONDS)
				say("Uploading technology disk.")
				stored_research.absorb_techdisk(t_disk)
			return TRUE
		// Tech disk-only action
		if ("loadTech")
			if(!COOLDOWN_FINISHED(src, copy_cooldown)) // prevents MC hang
				say("Servers busy!")
				return
			if(QDELETED(t_disk))
				say("No tech disk inserted!")
				return
			COOLDOWN_START(src, copy_cooldown, 5 SECONDS)
			say("Downloading to technology disk.")
			LAZYOR(t_disk.stored_nodes, stored_research.researched_nodes)
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
	stored_research.adjust_points(point_type, target_value)
	to_chat(usr, "Success: [target_value] points have been added to [point_type]")

#undef RND_TECH_DISK
#undef RND_DESIGN_DISK
