
SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/processing/station,
	)

	/// Associative list of all techweb nodes
	/// node.id -> /datum/techweb_node
	var/list/techweb_nodes = list()
	/// Associative list of all designs
	/// design.id -> /datum/design
	var/list/techweb_designs = list()

	/// List of all techwebs, generating points or not.
	/// Autolathes, Mechfabs, and others all have shared techwebs, for example.
	var/list/datum/techweb/techwebs = list()

	/// These two are what you get if a node/design is deleted and somehow still stored in a console.
	var/datum/techweb_node/error_node/error_node
	var/datum/design/error_design/error_design

	/// Nodes that EVERY techweb starts with unlocked
	/// node.id -> TRUE
	var/list/techweb_nodes_starting = list()
	/// category name = list(node.id = TRUE)
	var/list/techweb_categories = list()
	/// Associative list of all items that can unlock a node
	/// node.id -> list(item typepaths)
	var/list/techweb_unlock_items = list()
	/// Nodes that should be hidden by default.
	/// node.id -> TRUE
	var/list/techweb_nodes_hidden = list()
	/// Associative list of all items that give research points when destroyed by the destructive analyzer
	/// item typepath = list(point type = value)
	var/list/techweb_point_items = list(
		/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = 10000, TECHWEB_POINT_TYPE_DISCOVERY = 5000)
	)
	/// Associative list of all point types that techwebs will have and their respective 'abbreviated' name.
	var/list/point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	autosort_categories()
	error_design = new()
	error_node = new()

	new /datum/techweb/science
	new /datum/techweb/admin
	new /datum/techweb/oldstation
	new /datum/techweb/golem

	return SS_INIT_SUCCESS

/datum/controller/subsystem/research/fire()
	for(var/datum/techweb/techweb_list as anything in techwebs)
		if(!techweb_list.should_generate_points)
			continue
		var/list/bitcoins = list()
		for(var/obj/machinery/rnd/server/miner as anything in techweb_list.techweb_servers)
			var/list/results = miner.mine()
			for(var/i in results)
				bitcoins[i] += results[i]

		if(!isnull(techweb_list.last_income))
			var/income_time_difference = world.time - techweb_list.last_income
			techweb_list.last_bitcoins = bitcoins // Doesn't take tick drift into account
			for(var/i in bitcoins)
				bitcoins[i] *= income_time_difference / 10
			techweb_list.add_point_list(bitcoins)

		techweb_list.last_income = world.time

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = TRUE
		else
			techweb_categories[I.category] = list(I.id = TRUE)

/datum/controller/subsystem/research/proc/techweb_node_by_id(id)
	return techweb_nodes[id] || error_node

/datum/controller/subsystem/research/proc/techweb_design_by_id(id)
	return techweb_designs[id] || error_design

/datum/controller/subsystem/research/proc/on_design_deletion(datum/design/D)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN = techwebs[i]
		TN.on_design_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/on_node_deletion(datum/techweb_node/TN)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN2 = techwebs[i]
		TN2.on_node_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(techweb_nodes) && clearall)
		QDEL_LIST(techweb_nodes)
	if(islist(techweb_nodes_starting && clearall))
		techweb_nodes_starting.Cut()
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		TN = new path
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_nodes_starting[TN.id] = TRUE
	for(var/id in techweb_nodes)
		var/datum/techweb_node/TN = techweb_nodes[id]
		TN.Initialize()
	techweb_nodes = returned
	calculate_techweb_nodes()
	calculate_techweb_item_unlocking_requirements()

/datum/controller/subsystem/research/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(techweb_designs) && clearall)
		QDEL_LIST(techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		DN.InitializeMaterials() //Initialize the materials in the design
		returned[initial(DN.id)] = DN
	techweb_designs = returned

/datum/controller/subsystem/research/proc/calculate_techweb_nodes()
	for(var/design_id in techweb_designs)
		var/datum/design/D = techweb_designs[design_id]
		D.unlocked_by.Cut()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
		for(var/i in node.design_ids)
			var/datum/design/D = techweb_designs[i]
			node.design_ids[i] = TRUE
			if(isnull(D))
				CRASH("[D] is null! You probably added to a design id list without associating the entry with a design.")
			D.unlocked_by += node.id
		if(node.hidden)
			techweb_nodes_hidden[node.id] = TRUE
		CHECK_TICK
	generate_techweb_unlock_linking()

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in techweb_nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq_node = techweb_node_by_id(prereq_id)
			prereq_node.unlock_ids[node.id] = node

/datum/controller/subsystem/research/proc/calculate_techweb_item_unlocking_requirements()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/path in node.required_items_to_unlock)
			if(!ispath(path))
				continue
			if(length(techweb_unlock_items[path]))
				techweb_unlock_items[path][node.id] = node.required_items_to_unlock[path]
			else
				techweb_unlock_items[path] = list(node.id = node.required_items_to_unlock[path])
		CHECK_TICK

/**
 * Goes through all techwebs and goes through their servers to find ones on a valid z-level
 * Returns the full list of all techweb servers.
 */
/datum/controller/subsystem/research/proc/get_available_servers(turf/location)
	var/list/local_servers = list()
	if(!location)
		return local_servers
	for (var/datum/techweb/individual_techweb as anything in techwebs)
		var/list/servers = find_valid_servers(location, individual_techweb)
		if(length(servers))
			local_servers += servers
	return local_servers

/**
 * Goes through an individual techweb's servers and finds one on a valid z-level
 * Returns a list of existing ones, or an empty list otherwise.
 * Args:
 * - checking_web - The techweb we're checking the servers of.
 */
/datum/controller/subsystem/research/proc/find_valid_servers(turf/location, datum/techweb/checking_web)
	var/list/valid_servers = list()
	for(var/obj/machinery/rnd/server/server as anything in checking_web.techweb_servers)
		if(!is_valid_z_level(get_turf(server), location))
			continue
		valid_servers += server
	return valid_servers
