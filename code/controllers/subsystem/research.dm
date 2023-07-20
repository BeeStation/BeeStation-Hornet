
SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 10
	init_order = INIT_ORDER_RESEARCH
	//TECHWEB STATIC
	var/list/techweb_nodes = list()				//associative id = node datum
	var/list/techweb_designs = list()			//associative id = node datum
	var/list/datum/techweb/techwebs = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/datum/techweb_node/error_node/error_node	//These two are what you get if a node/design is deleted and somehow still stored in a console.
	var/datum/design/error_design/error_design

	var/list/obj/machinery/rnd/server/servers = list()

	var/list/techweb_nodes_starting = list()	//associative id = TRUE
	var/list/techweb_categories = list()		//category name = list(node.id = TRUE)
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = list(point_type = point_discount))
	var/list/techweb_nodes_hidden = list()		//Node ids that should be hidden by default.
	var/list/techweb_point_items = list(		//path = list(point type = value)
		/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	)
	var/list/point_types = list()				//typecache style type = TRUE list
	//----------------------------------------------
	var/list/single_server_income = list(TECHWEB_POINT_TYPE_GENERIC = 54.3)
	var/multiserver_calculation = TRUE			// Enable this to switch between using servers or the constant
	var/last_income
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

/datum/controller/subsystem/research/Initialize()
	point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	//Some points to get you started.
	//Points can be gained by
	// 1) Exploration team going to ruins
	// 2) Scientists using their shuttle to go to ruins
	// 3) Giving miners a scanner
	// 4) Scanning station pets
	// 5) Using the experimentor on maint devices
	// (probably more added since this comment was written.)
	science_tech.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, 2500)
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	error_design = new
	error_node = new
	return ..()

/datum/controller/subsystem/research/fire()
	var/list/bitcoins = list()
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			var/list/result = (miner.mine())	//SLAVE AWAY, SLAVE.
			for(var/i in result)
				result[i] *= eff
				bitcoins[i] = bitcoins[i]? bitcoins[i] + result[i] : result[i]
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break			//Just need one to work.
	if (!isnull(last_income))
		var/income_time_difference = world.time - last_income
		science_tech.last_bitcoins = bitcoins  // Doesn't take tick drift into account
		for(var/i in bitcoins)
			bitcoins[i] *= income_time_difference / 10
		science_tech.add_point_list(bitcoins)
	last_income = world.time

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/list/obj/machinery/rnd/server/active = new()
	for(var/obj/machinery/rnd/server/miner in servers)
		if(miner.working)
			active.Add(miner)
	var/amt = active.len
	if(!amt)
		return 0
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

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
	calculate_techweb_boost_list()

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

/datum/controller/subsystem/research/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		techweb_boost_items = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(techweb_boost_items[path]))
				techweb_boost_items[path][node.id] = node.boost_item_paths[path]
			else
				techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK
