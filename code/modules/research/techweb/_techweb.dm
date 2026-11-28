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

	/// A list of researched nodes. Associative for faster lookup.
	var/list/researched_nodes = list()
	/// A list of visible nodes, i.e: nodes which have at least one pre-requisite researched. Associative for faster lookup.
	var/list/visible_nodes = list()
	/// A list of nodes with all of their pre-requisites met. Associative for faster lookup.
	var/list/available_nodes = list()
	/// Hidden nodes. Used for unhiding nodes when requirements are met by removing the entry of the node. Associative for faster lookup.
	var/list/hidden_nodes = list()

	/// A list of unlocked designs. Associative for faster lookup.
	var/list/researched_designs = list()
	/// Custom inserted designs like from disks that should survive recalculation.
	var/list/custom_designs = list()

	/// List of items already deconstructed for research points, preventing infinite research point generation.
	var/list/deconstructed_items = list()
	/// Available research points
	/// e.g: [TECHWEB_POINT_TYPE_GENERIC --> 100, TECHWEB_POINT_TYPE_DISCOVERY --> 40]
	var/list/research_points = list()
	/// Game logs of research nodes, "node_name" "node_cost" "node_researcher" "node_research_location"
	var/list/research_logs = list()
	/// The radius of the biggest bomb detected by a tachyon doppler array connected to this techweb
	var/largest_bomb_value = 0
	/// Current per-second production, used for display only.
	var/list/last_bitcoins = list()
	/// Mutations discovered by genetics, this way they are shared and cant be destroyed by destroying a single console
	var/list/discovered_mutations = list()
	/// An associative list of techweb typepaths to their respective tier.
	/// 1 means that the node is available. 2 means that all of the reqs are 1 away, and so on.
	/// Tiers used for the RD console, not related to current_tier
	var/list/tiers = list()

	/// The tier of our techweb
	var/current_tier = 1
	/// An alist of techweb tiers to the amount of researched techweb nodes in that tier.
	/// e.g: [1 --> 10, 2 --> 0, etc.]
	var/alist/researched_nodes_per_tier = alist()
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
	hidden_nodes = SSresearch.techweb_nodes_hidden.Copy()
	for(var/node_path in SSresearch.techweb_nodes_starting)
		research_node(node_path, force = TRUE, apply_cost = FALSE)

/datum/techweb/Destroy()
	SSresearch.techwebs -= src
	return ..()

/datum/techweb/proc/calculate_current_tier()
	current_tier = 1
	for(var/tier = 1 to MAX_TIER)
		var/researched_amount = researched_nodes_per_tier[tier]
		if(!researched_amount)
			continue
		var/total_amount = SSresearch.nodes_per_techweb_tier[tier]
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
	for(var/node_path in SANITIZE_LIST(disk.stored_nodes) - researched_nodes)
		research_node(node_path, force = TRUE, apply_cost = FALSE)
		CHECK_TICK

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
 * * add_to - The list to add the node to. research_designs by default
 */
/datum/techweb/proc/add_design(datum/design/design, custom = FALSE, list/add_to = researched_designs)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(design, /datum/design))
		design = SSresearch.techweb_designs[design]
	if(!istype(design) || !is_valid_design(design))
		return

	if(custom)
		custom_designs[design.type] = TRUE

	// Already researched
	if(add_to[design.type])
		return

	add_to[design.type] = TRUE

	// If we came from a hidden node, unhide that node.
	for(var/unlocked_by in design.unlocked_by)
		if(!hidden_nodes[unlocked_by])
			continue
		hidden_nodes -= unlocked_by
		update_node_status(SSresearch.techweb_nodes[unlocked_by])

	SEND_SIGNAL(src, COMSIG_TECHWEB_ADD_DESIGN, design, custom)

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
		return

	if(custom)
		custom_designs -= design.type

	// Not researched
	if(!researched_designs[design.type])
		return

	researched_designs -= design.type

	SEND_SIGNAL(src, COMSIG_TECHWEB_REMOVE_DESIGN, design, custom)

/datum/techweb/proc/can_afford(list/point_list)
	for(var/point_type, point_amount in point_list)
		if(research_points[point_type] < point_amount)
			return FALSE
	return TRUE

/**
 * Adds a node to this techweb
 * Returns TRUE if successful
 *
 * Arguments:
 * * node - The typepath or instance of the node to research
 * * force - If TRUE, availability checks are ignored
 * * apply_cost - If TRUE, the node's point cost is deducted from this techweb
 * * research_source - The thing responsible for researching this node. Used in overrides.
 */
/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, apply_cost = TRUE, atom/research_source)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(node, /datum/techweb_node))
		node = SSresearch.techweb_nodes[node]
	if(!istype(node))
		return FALSE

	// Already researched
	if(researched_nodes[node.type])
		return FALSE

	if(!force && (!available_nodes[node.type] || (apply_cost && !can_afford(node.get_price(src)))))
		return FALSE

	if(apply_cost)
		var/list/node_cost = node.get_price(src)
		for(var/point_type in node_cost)
			node_cost[point_type] *= -1
		adjust_multiple_points(node_cost)

	// Actually research the node
	researched_nodes[node.type] = TRUE

	// Update our techweb tier
	researched_nodes_per_tier[node.tech_tier]++
	calculate_current_tier()

	// Update the status of the nodes which we unlock
	// They will become either available or visible
	for(var/unlocked_path in node.unlocked_nodes)
		update_node_status(SSresearch.techweb_nodes[unlocked_path])

	// Unlock what the research actually unlocks
	for(var/design_path in node.unlocked_designs)
		add_design(design_path)

	update_node_status(node)
	node_added(node, research_source)

	return TRUE

/// A node was added to this techweb
/datum/techweb/proc/node_added(datum/techweb_node/node, atom/research_source)
	return

/**
 * Removes a node from this techweb
 *
 * Arguments:
 * * node - The instance or typepath of the node to remove
 */
/datum/techweb/proc/unresearch_node(datum/techweb_node/node)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(ispath(node, /datum/techweb_node))
		node = SSresearch.techweb_nodes[node]
	if(!istype(node))
		return

	// Not researched
	if(!researched_nodes[node.type])
		return

	// Get rid of the node
	researched_nodes -= node.type

	// Update our techweb tier
	researched_nodes_per_tier[node.tech_tier]--
	calculate_current_tier()

	// Update the status of the nodes which we unlock
	// If they aren't already researched, they will become unavailable
	for(var/unlocked_path in node.unlocked_nodes)
		update_node_status(SSresearch.techweb_nodes[unlocked_path])

	// Purge designs
	for(var/design_path in node.unlocked_designs - custom_designs)
		var/do_we_come_from_another_node = FALSE

		var/datum/design/design = SSresearch.techweb_designs[design_path]
		for(var/unlocking_node in design.unlocked_by)
			if(researched_nodes[unlocking_node])
				do_we_come_from_another_node = TRUE
				break

		if(!do_we_come_from_another_node)
			remove_design(design)

	update_node_status(node)

/// Removes a node from the hidden_nodes list, making it viewable and researchable.
/datum/techweb/proc/unhide_node(datum/techweb_node/node)
	if(!istype(node))
		return
	hidden_nodes -= node.type
	// Update availability
	update_node_status(node)

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

/// Determines the availability of a node based off of its researched pre-requisites
/datum/techweb/proc/update_node_status(datum/techweb_node/node)
	available_nodes -= node.type
	visible_nodes -= node.type
	if(researched_nodes[node.type])
		update_tiers(node)
		return

	var/has_all_prerequisites = TRUE
	var/has_any_prerequsite = FALSE
	for(var/prerequisite_path in node.prerequisite_nodes)
		if(researched_nodes[prerequisite_path])
			has_any_prerequsite = TRUE
		else
			has_all_prerequisites = FALSE

	if(hidden_nodes[node.type])
		// Pre-requisites are met, we can go ahead and unhide this node
		if((node.node_flags & TECHWEB_NODE_WAIT_FOR_PREREQS) && has_all_prerequisites)
			hidden_nodes -= node.type
		else
			return

	if(has_all_prerequisites)
		available_nodes[node.type] = TRUE
	else if(has_any_prerequsite)
		visible_nodes[node.type] = TRUE

	update_tiers(node)
