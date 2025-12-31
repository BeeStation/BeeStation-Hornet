/**
 * # Techweb Node
 *
 * A datum representing a researchable node in the techweb.
 *
 * Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant
 * changes should never be made to them in-game. USE SSRESEARCH PROCS TO OBTAIN REFERENCES.
 * DO NOT REFERENCE OUTSIDE OF SSRESEARCH OR YOU WILL FUCK UP GC.
 */
/datum/techweb_node
	/// Internal ID of the node
	var/id
	/// The tech tier of the node.
	/// If a node with a higher tier than the linked techweb is researched discovery points are subtracted based off of the difference in tier. See calculate_discovery_cost()
	var/tech_tier = 0
	/// The name of the node as it is shown on UIs
	var/display_name = "Errored Node"
	/// A description of the node to show on UIs
	var/description = "Why are you seeing this?"
	/// The category of the node
	var/category = "Misc"
	/// Whether it starts off hidden
	var/hidden = FALSE
	/// Whether it's available without any research
	var/starting_node = FALSE
	/// A list of prerequisite node ids that must be researched before we are available
	var/list/prereq_ids = list()
	/// A list of design ids unlocked when this node is researched
	var/list/design_ids = list()
	/// CALCULATED FROM OTHER NODE'S PREREQUISITIES. Associated list id = TRUE
	var/list/unlock_ids = list()
	/// List of items you need to deconstruct to unlock this node.
	var/list/required_items_to_unlock = list()
	/// An associative list of how much this node costs to research in various point types
	/// point type -> point amount
	var/list/research_costs = list()
	/// Whether or not this node should show on the wiki
	var/show_on_wiki = TRUE

/datum/techweb_node/error_node
	id = "ERROR"
	display_name = "ERROR"
	description = "This usually means something in the database has corrupted. If it doesn't go away automatically, inform Central Command for their techs to fix it ASAP(tm)"
	show_on_wiki = FALSE

/datum/techweb_node/proc/Initialize()
	//Make lists associative for lookup
	for(var/id in prereq_ids)
		prereq_ids[id] = TRUE
	for(var/id in design_ids)
		design_ids[id] = TRUE
	for(var/id in unlock_ids)
		unlock_ids[id] = TRUE

/datum/techweb_node/Destroy()
	SSresearch.techweb_nodes -= id
	return ..()

/datum/techweb_node/proc/on_design_deletion(datum/design/D)
	prune_design_id(D.id)

/datum/techweb_node/proc/on_node_deletion(datum/techweb_node/TN)
	prune_node_id(TN.id)

/datum/techweb_node/proc/prune_design_id(design_id)
	design_ids -= design_id

/datum/techweb_node/proc/prune_node_id(node_id)
	prereq_ids -= node_id
	unlock_ids -= node_id

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(host)
		var/list/actual_costs = research_costs
		if(host.boosted_nodes[id])
			var/list/L = host.boosted_nodes[id]
			for(var/i in L)
				if(actual_costs[i])
					actual_costs[i] -= L[i]
		actual_costs[TECHWEB_POINT_TYPE_DISCOVERY] = calculate_discovery_cost(host.current_tier)
		return actual_costs
	else
		return research_costs

/datum/techweb_node/proc/calculate_discovery_cost(their_tier)
	var/delta = tech_tier - their_tier
	switch(delta)
		if(-INFINITY to 0)
			return 0
		if(1)
			return TECHWEB_TIER_1_POINTS
		if(2)
			return TECHWEB_TIER_2_POINTS
		if(3)
			return TECHWEB_TIER_3_POINTS
		if(4 to INFINITY)
			return TECHWEB_TIER_4_POINTS

/datum/techweb_node/proc/price_display(datum/techweb/TN)
	return techweb_point_display_generic(get_price(TN))

/// Proc called when the Station (Science techweb specific) researches a node.
/datum/techweb_node/proc/on_station_research()
	SHOULD_CALL_PARENT(FALSE)
