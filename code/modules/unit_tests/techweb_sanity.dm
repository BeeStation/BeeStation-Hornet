/// Test to ensure that every techweb is properly defined
/datum/unit_test/techweb_sanity
	var/list/designs = list()
	var/list/nodes = list()
	var/static/list/allowed_empty = list(
		/datum/techweb_node/datatheory,
		/datum/techweb_node/neural_programming,
	)

/datum/unit_test/techweb_sanity/Run()
	build_designs()
	build_techwebs()
	verify_design_ownership()

/datum/unit_test/techweb_sanity/proc/build_designs()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			Fail("[path] is invalid!")
			continue
		if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(designs[initial(DN.id)])
			Fail("[DN] has a duplicate design id!")
			continue
		DN.InitializeMaterials()
		designs[initial(DN.id)] = DN
	verify_designs()

/datum/unit_test/techweb_sanity/proc/verify_designs()
	for(var/id in designs)
		var/datum/design/DN = designs[id]
		if(!istype(DN))
			Fail("Invalid design ID [id] on the designs list.")
			continue

/datum/unit_test/techweb_sanity/proc/build_techwebs()
	for(var/path in subtypesof(/datum/techweb_node) - /datum/techweb_node/error_node)
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			Fail("[path] is invalid!")
			continue
		TN = new path
		if(nodes[initial(TN.id)])
			Fail("[TN] has a duplicate techweb id!")
			continue
		nodes[initial(TN.id)] = TN
	for(var/id in nodes)
		var/datum/techweb_node/TN = nodes[id]
		TN.Initialize()
	verify_techwebs()

/datum/unit_test/techweb_sanity/proc/verify_techwebs()
	var/list/points_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES
	for(var/id in nodes)
		var/datum/techweb_node/TN = nodes[id]
		if(!istype(TN))
			Fail("Invalid techweb ID [id] on the techwebs list.")
			continue
		for(var/p in TN.prereq_ids)
			var/datum/techweb_node/P = nodes[p]
			if(!istype(P))
				Fail("[TN] has an invalid/missing pre-requisite node [p]!")
				continue
		if(is_type_in_list(TN, allowed_empty) && length(TN.design_ids))
			Fail("[TN] is not allowed to have any design IDs!")
			continue
		for(var/d in TN.design_ids)
			var/datum/design/D = designs[d]
			if(!istype(D))
				Fail("[TN] has an invalid/missing design node [d]!")
				continue
		for(var/u in TN.unlock_ids)
			var/datum/techweb_node/U = nodes[u]
			if(!istype(U))
				Fail("[TN] has an invalid [u]!")
				continue
		for(var/p in TN.boost_item_paths)
			if(!ispath(p))
				Fail("[TN] has invalid boost information: [p] is not a valid path.")
				continue
			var/list/points = TN.boost_item_paths[p]
			if(islist(points))
				for(var/i in points)
					if(!isnum_safe(points[i]))
						Fail("[TN] has invalid boost information: [points[i]] is not a valid number.")
						continue
					if(!points_types[i])
						Fail("[TN] has invalid boost information: [i] is not a valid point type.")
						continue
			else if(!isnull(points))
				Fail("[TN] has invalid boost information: No valid list.")
				continue

/datum/unit_test/techweb_sanity/proc/verify_design_ownership()
	var/list/all_nodes = list()
	for(var/n_id in nodes)
		all_nodes += n_id
	for(var/d_id in designs)
		for(var/n_id in nodes)
			var/datum/techweb_node/TN = nodes[n_id]
			if(d_id in TN.design_ids)
				all_nodes -= n_id
				continue
	for(var/n_id in all_nodes)
		var/datum/techweb_node/TN = nodes[n_id]
		if(is_type_in_list(TN, allowed_empty))
			continue
		Fail("Node ID [n_id] has no designs attached!")
