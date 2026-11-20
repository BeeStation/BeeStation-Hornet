//Unlock 20% of a tier and the tier will progress to that one.
#define TIER_PROPORTATION_TO_UNLOCK 0.2
#define MAX_TIER 5

/**
 * # Techweb
 *
 * A datum representing a research techweb
 *
 * Techweb datums are meant to store unlocked research, being able to be stored
 * on research consoles, servers, and disks. They are NOT global.
 */
/datum/techweb
	/// The id/name of the whole Techweb viewable to players.
	var/id = "Generic"
	/// Organization name, used for display
	var/organization = "Third-Party"
	/// Already unlocked and all designs are now available. Assoc list, id = TRUE
	var/list/researched_nodes = list()
	/// Visible nodes, doesn't mean it can be researched. Assoc list, id = TRUE
	var/list/visible_nodes = list()
	/// Nodes that can immediately be researched, all reqs met. assoc list, id = TRUE
	var/list/available_nodes = list()
	/// Designs that are available for use. Assoc list, id = TRUE
	var/list/researched_designs = list()
	/// Custom inserted designs like from disks that should survive recalculation.
	var/list/custom_designs = list()
	/// Hidden nodes. id = TRUE. Used for hiding nodes until an item unhides it, such as illegal technology
	var/list/hidden_nodes = list()
	/// List of items already deconstructed for research points, preventing infinite research point generation.
	var/list/deconstructed_items = list()
	/// Available research points, type = number
	var/list/research_points = list()
	/// Game logs of research nodes, "node_name" "node_cost" "node_researcher" "node_research_location"
	var/list/research_logs = list()
	/// The radius of the biggest bomb detected by a tachyon doppler array connected to this techweb
	var/largest_bomb_value = 0
	/// Current per-second production, used for display only.
	var/list/last_bitcoins = list()
	/// Mutations discovered by genetics, this way they are shared and cant be destroyed by destroying a single console
	var/list/discovered_mutations = list()
	/// Assoc list, id = number, 1 is available, 2 is all reqs are 1, so on
	/// Tiers used for the RD console, not actual tier
	var/list/tiers = list()

	/// The tier of our techweb
	var/current_tier = 1
	/// Assoc list, Key = "[tier level]", Value = Amount of nodes in tier
	var/list/items_per_tier = list()
	/// Assoc list, Key = "[tier level]", Value = Amount of nodes unlocked in tier
	var/list/unlocked_in_tier = list()
	/// A list of atoms scanned by a discovery scanner
	var/list/scanned_atoms = list()

	/// All RD consoles connected to this individual techweb.
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	/// All research servers connected to this individual techweb.
	var/list/obj/machinery/rnd/server/techweb_servers = list()

	/// Boolean on whether the techweb should generate research points overtime.
	var/should_generate_points = FALSE
	/// The last world.time this techweb attempted to have points generated
	var/last_income

/datum/techweb/New()
	SSresearch.techwebs += src
	for(var/node_path in SSresearch.techweb_nodes_starting)
		research_node(SSresearch.techweb_nodes[node_path], TRUE, FALSE)
	hidden_nodes = SSresearch.techweb_nodes_hidden.Copy()

	for(var/node_path, _node in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = _node
		items_per_tier["[node.tech_tier]"] += 1

/datum/techweb/Destroy()
	researched_nodes = null
	researched_designs = null
	available_nodes = null
	visible_nodes = null
	custom_designs = null
	items_per_tier = null
	unlocked_in_tier = null
	SSresearch.techwebs -= src
	return ..()

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE, wipe_custom_designs = FALSE)
	var/list/datum/techweb_node/processing = list()
	for(var/id in researched_nodes)
		processing[id] = TRUE
	for(var/id in visible_nodes)
		processing[id] = TRUE
	for(var/id in available_nodes)
		processing[id] = TRUE
	if(recalculate_designs)
		researched_designs = custom_designs.Copy()
		if(wipe_custom_designs)
			custom_designs = list()
	items_per_tier = list()
	for(var/node_path in processing)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		update_node_status(node)
		items_per_tier["[node.tech_tier]"] += 1
		CHECK_TICK
	recalculate_tiers()

	// Update all console UIs
	for(var/obj/machinery/computer/rdconsole/console as anything in consoles_accessing)
		console.ui_update()

/datum/techweb/proc/recalculate_tiers()
	unlocked_in_tier = list()
	for(var/node_path in researched_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		unlocked_in_tier["[node.tech_tier]"] += 1
	calculate_current_tier()

/datum/techweb/proc/calculate_current_tier()
	current_tier = 1
	for(var/tier in 1 to MAX_TIER)
		var/researched_amount = unlocked_in_tier["[tier]"]
		var/total_amount = items_per_tier["[tier]"]
		if(!researched_amount)
			continue
		if(researched_amount >= total_amount * TIER_PROPORTATION_TO_UNLOCK)
			current_tier = tier

/// Adjusts the amount of a certain point type
/datum/techweb/proc/adjust_points(point_type, point_amount)
	if(!SSresearch.point_types[point_type] || !point_amount)
		return
	research_points[point_type] = max(FLOOR(research_points[point_type] + point_amount, 0.1), 0)

/// Adjusts the amount of multiple point types
/datum/techweb/proc/adjust_multiple_points(list/point_list)
	for(var/point_type, point_amount in point_list)
		adjust_points(point_type, point_amount)

/// Adjust all point types by this amount
/datum/techweb/proc/adjust_all_points(point_amount)
	var/list/new_points = SSresearch.point_types.Copy()
	for(var/point_type in new_points)
		new_points[point_type] = point_amount
	adjust_multiple_points(new_points)

/// Takes all of the research from a tech disk
/datum/techweb/proc/absorb_techdisk(obj/item/disk/tech_disk/disk)
	for(var/node_path in disk.stored_nodes - researched_nodes)
		CHECK_TICK
		research_node(node_path, TRUE, FALSE, FALSE)
	recalculate_nodes()

/datum/techweb/proc/get_visible_nodes()	//The way this is set up is shit but whatever.
	return visible_nodes - hidden_nodes

/datum/techweb/proc/get_available_nodes()
	return available_nodes - hidden_nodes

/datum/techweb/proc/get_researched_nodes()
	return researched_nodes - hidden_nodes

/// Check if we can add a design to this techweb
/datum/techweb/proc/is_valid_design(datum/design/design)
	return TRUE

/**
 * Adds a design to this techweb
 *
 * Arguments:
 * * design - The instance or typepath of the design to add
 * * custom - Boolean on whether the node should also be added to custom_designs
 * * add_to - A custom list to add the node to, overwriting research_designs.
 */
/datum/techweb/proc/add_design(datum/design/design, custom = FALSE, list/add_to)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(design, /datum/design))
		design = SSresearch.techweb_designs[design]

	if(!istype(design) || !is_valid_design(design))
		return FALSE

	if(custom)
		custom_designs[design.type] = TRUE

	if(add_to)
		add_to[design.type] = TRUE
	else
		researched_designs[design.type] = TRUE

	for(var/unlocked_by in design.unlocked_by)
		hidden_nodes -= unlocked_by

	design_added(design)
	SEND_SIGNAL(src, COMSIG_TECHWEB_ADD_DESIGN, design, custom)
	return TRUE

/// A design was added to this techweb
/datum/techweb/proc/design_added(datum/design/design)
	return

/**
 * Removes a design from this techweb
 *
 * Arguments:
 * * design - The instance or typepath of the design to remove
 * * custom - Boolean on whether the node should also be removed from custom_designs
 */
/datum/techweb/proc/remove_design(datum/design/design, custom = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(design, /datum/design))
		design = SSresearch.techweb_designs[design]

	if(!istype(design))
		return FALSE

	if(custom)
		custom_designs -= design.type

	researched_designs -= design.type

	SEND_SIGNAL(src, COMSIG_TECHWEB_REMOVE_DESIGN, design, custom)
	return TRUE

/datum/techweb/proc/can_afford(list/point_list)
	for(var/point_type, point_amount in point_list)
		if(research_points[point_type] < point_amount)
			return FALSE
	return TRUE

/**
 * Adds a node to this techweb
 *
 * Arguments:
 * * node - The typepath or instance of the node to research
 * * force - If TRUE, availability checks are ignored
 * * auto_adjust_cost - If TRUE, the node's point cost(s) are deducted from this techweb
 * * research_source - The thing responsible for researching this node. Used in overrides.
 */
/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, atom/research_source)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(node))
		node = SSresearch.techweb_nodes[node]
	if(!istype(node))
		return FALSE

	update_node_status(node)
	if(!force && (!available_nodes[node.type] || (auto_adjust_cost && !can_afford(node.get_price(src)))))
		return FALSE

	var/log_message = "[id]/[organization] researched node [node.type]"
	if(auto_adjust_cost)
		var/list/node_cost = node.get_price(src)
		for(var/point_type in node_cost)
			node_cost[point_type] *= -1
		adjust_multiple_points(node_cost)
		log_message += " at the cost of [json_encode(node_cost)]"

	node_added(node, research_source)
	//Add to our researched list
	researched_nodes[node.type] = TRUE

	// Gain the experiments from the new node
	for(var/unlocked_path in node.unlocked_nodes)
		visible_nodes[unlocked_path] = TRUE
		var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[unlocked_path]
		update_node_status(unlocked_node)

	// Unlock what the research actually unlocks
	for(var/design_path in node.unlocked_designs)
		add_design(design_path)
	update_node_status(node)

	return TRUE

/// A node was added to this techweb
/datum/techweb/proc/node_added(datum/techweb_node/node, atom/research_source)
	return

/**
 * Removes a node from this techweb
 *
 * Arguments:
 * * node_path - The instance or typepath of the node to remove
 */
/datum/techweb/proc/unresearch_node(datum/techweb_node/node_path)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/datum/techweb_node/node_instance
	if(istype(node_path, /datum/techweb_node))
		node_instance = node_path
		node_path = node_instance.type
	else
		node_instance = SSresearch.techweb_nodes[node_path]
	if(!istype(node_instance))
		return

	node_removed(node_instance)
	researched_nodes -= node_path
	recalculate_nodes(recalculate_designs = TRUE) //Fully rebuild the tree.

///Removes a node from the hidden_nodes list, making it viewable and researchable (if no experiments are required).
/datum/techweb/proc/unhide_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	hidden_nodes -= node.type
	///Make it available if the prereq ids are already researched
	update_node_status(node)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	while (length(current))
		var/list/next = list()
		for (var/datum/techweb_node/node as anything in current)
			var/tier = 0
			if (!researched_nodes[node.type])  // researched is tier 0
				for (var/prerequisite_path in node.prerequisite_nodes)
					var/prereq_tier = tiers[prerequisite_path]
					tier = max(tier, prereq_tier + 1)

			if (tier != tiers[node.type])
				tiers[node.type] = tier
				for (var/unlocked_path in node.unlocked_nodes)
					next += SSresearch.techweb_nodes[unlocked_path]
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_nodes[node.type])
		researched = TRUE
	var/needed = LAZYLEN(node.prerequisite_nodes)
	for(var/prerequisite_path in node.prerequisite_nodes)
		if(researched_nodes[prerequisite_path])
			visible = TRUE
			needed--
	if(!needed)
		available = TRUE
	researched_nodes -= node.type
	available_nodes -= node.type
	visible_nodes -= node.type
	if(hidden_nodes[node.type]) //Hidden.
		return

	if(researched)
		researched_nodes[node.type] = TRUE
		for(var/design_path in SANITIZE_LIST(node.unlocked_designs) - researched_designs)
			add_design(design_path)
	else if(available)
		available_nodes[node.type] = TRUE
	else if(visible)
		visible_nodes[node.type] = TRUE

	update_tiers(node)
