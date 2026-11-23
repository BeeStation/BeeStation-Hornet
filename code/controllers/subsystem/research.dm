SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/processing/station,
	)

	/// An associative list of techweb node typepaths to instances.
	var/list/techweb_nodes = list()
	/// An associative list of design typepaths to instances.
	var/list/techweb_designs = list()

	/// A list of all techwebs, generating points or not.
	/// Autolathes, Mechfabs, and others all have shared techwebs.
	var/list/datum/techweb/techwebs = list()

	/// A list of techweb node paths that all techwebs start with.
	var/list/techweb_nodes_starting = list()
	/// A list of techweb node paths that are hidden by default. Associative for faster lookups.
	var/list/techweb_nodes_hidden = list()
	/// An associative list of item paths to a list of techweb nodes that depend on that item.
	/// e.g: [/obj/item/scalpel/alien --> [/datum/techweb_node/alien/base, /datum/techweb_node/alien/engi...]]
	var/list/techweb_unlock_items = list()

	/// An associative list of item paths to a list of points granted. Used in the destructive analyzer only.
	var/list/techweb_point_items = list(
		/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS, TECHWEB_POINT_TYPE_DISCOVERY = TECHWEB_TIER_4_POINTS)
	)
	/// An associative list of all point types that techwebs will have and their respective 'abbreviated' name.
	var/list/point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES

	/// An associative lazy list of queued techweb nodes to create an announcement for
	/// e.g: [RADIO_CHANNEL_SCIENCE --> [/datum/techweb_node/engineering, /datum/techweb_node/adv_engi]]
	var/list/researched_node_announcement_queue
	/// Whether or not we're queued to announce our researched nodes in the next ~10 seconds
	var/node_announcement_queued = FALSE

/datum/controller/subsystem/research/Initialize()
	initialize_designs()
	initialize_nodes()
	new /datum/techweb/science()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/research/fire()
	for(var/datum/techweb/techweb as anything in techwebs)
		if(!techweb.should_generate_points)
			continue

		// Point generation
		var/list/bitcoins = list()
		for(var/obj/machinery/rnd/server/miner as anything in techweb.techweb_servers)
			for(var/generated_point_type, point_amount in miner.mine())
				bitcoins[generated_point_type] += point_amount

		if(!isnull(techweb.last_income))
			var/income_time_difference = world.time - techweb.last_income
			techweb.last_bitcoins = bitcoins // Doesn't take tick drift into account
			for(var/point_type in bitcoins)
				bitcoins[point_type] *= income_time_difference / 10
			techweb.adjust_multiple_points(bitcoins)

		techweb.last_income = world.time

/datum/controller/subsystem/research/proc/initialize_designs()
	for(var/datum/design/design_path as anything in valid_subtypesof(/datum/design))
		var/datum/design/new_design = new design_path()
		// This design doesn't want to exist. OK THEN!
		if(QDELING(new_design))
			continue

		techweb_designs[design_path] = new_design

/datum/controller/subsystem/research/proc/initialize_nodes()
	for(var/datum/techweb_node/node_path as anything in valid_subtypesof(/datum/techweb_node))
		var/datum/techweb_node/new_node = new node_path()
		// This node doesn't want to exist. OK THEN!
		if(QDELING(new_node))
			continue

		if(new_node.node_flags & TECHWEB_NODE_STARTER)
			techweb_nodes_starting += node_path
		if(new_node.node_flags & TECHWEB_NODE_HIDDEN)
			techweb_nodes_hidden[node_path] = TRUE // assoc for speed

		// Tell our unlocked designs that we unlock them
		for(var/design_path in new_node.unlocked_designs)
			var/datum/design/unlocked_design = techweb_designs[design_path]
			LAZYADD(unlocked_design.unlocked_by, node_path)

		// Register that our required items unlock us
		for(var/required_item_path in new_node.required_items_to_unlock)
			LAZYADD(techweb_unlock_items[required_item_path], node_path)

		techweb_nodes[node_path] = new_node

	// We have to do this after the above loop to ensure everything has been initialized
	for(var/node_path, _node in techweb_nodes)
		var/datum/techweb_node/node = _node
		// Tell our prerequisite nodes that we are unlocked by them
		for(var/prerequisite_path in node.prerequisite_nodes)
			var/datum/techweb_node/prerequisite_node = techweb_nodes[prerequisite_path]
			LAZYADD(prerequisite_node.unlocked_nodes, node_path)

/**
 * Goes through all techwebs and goes through their servers to find ones on a valid z-level
 * Returns the full list of all techweb servers.
 */
/datum/controller/subsystem/research/proc/get_available_servers(turf/location) as /list
	var/list/local_servers = list()
	if(location)
		for (var/datum/techweb/individual_techweb as anything in techwebs)
			local_servers += find_valid_servers(location, individual_techweb)
	return local_servers

/**
 * Goes through an individual techweb's servers and finds one on a valid z-level
 * Returns a list of existing ones, or an empty list otherwise.
 * Args:
 * - checking_web - The techweb we're checking the servers of.
 */
/datum/controller/subsystem/research/proc/find_valid_servers(turf/location, datum/techweb/checking_web) as /list
	var/list/valid_servers = list()
	for(var/obj/machinery/rnd/server/server as anything in checking_web.techweb_servers)
		if(!is_valid_z_level(get_turf(server), location))
			continue
		valid_servers += server
	return valid_servers

/**
 * Handles a techweb node's announce_channels var
 *
 * Instead of sending an automated announcement every time a node is researched,
 * we batch all nodes researched in a 10 second time-frame
 */
/datum/controller/subsystem/research/proc/update_announcement_queue(list/channels_to_use, node)
	for(var/radio_channel in channels_to_use)
		LAZYORASSOCLIST(researched_node_announcement_queue, radio_channel, node)
	if(!node_announcement_queued)
		node_announcement_queued = TRUE
		addtimer(CALLBACK(src, PROC_REF(announce_research_queue)), 10 SECONDS)

/datum/controller/subsystem/research/proc/announce_research_queue()
	node_announcement_queued = FALSE
	for(var/radio_channel, list_of_nodes in researched_node_announcement_queue)
		if(length(list_of_nodes) > 1)
			aas_config_announce(/datum/aas_config_entry/researched_multiple_nodes, list("NODE_AMOUNT" = length(list_of_nodes), "NODE_TYPE" = radio_channel), null, list(radio_channel))
		else
			var/datum/techweb_node/node = list_of_nodes[1]
			aas_config_announce(/datum/aas_config_entry/researched_single_node, list("NODE" = node.display_name), null, list(radio_channel))

	LAZYNULL(researched_node_announcement_queue)

/// Helper proc to turn an associative list of points into a more human readable format.
/proc/techweb_point_display_generic(list/point_list)
	var/list/ret = list()
	for(var/point_type, point_amount in point_list)
		ret += "[SSresearch.point_types[point_type] || "ERRORED POINT TYPE"]: [point_amount]"
	return jointext(ret, "<br>")
