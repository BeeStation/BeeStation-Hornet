/// Test to ensure that every design has a connected techweb node and vice-versa
/datum/unit_test/orphaned_designs

/datum/unit_test/orphaned_designs/Run()
	var/list/all_designs = subtypesof(/datum/design)
	// error case
	all_designs -= /datum/design/error_design

	var/list/all_design_ids = list()
	var/list/passed_design_ids = list()
	for(var/datum/design/check as() in all_designs)
		if(check.id in all_design_ids)
			Fail("Duplicate design_id [check.id] present in multiple /datum/design!")
			continue
		all_design_ids += check.id
		passed_design_ids += check.id

	for(var/datum/techweb_node/node as() in subtypesof(/datum/techweb_node))
		for(var/id in node.design_ids)
			if(id in passed_design_ids)
				passed_design_ids -= id
				continue

			// This detects if there is a duplicate, as we have already passed it above
			if(id in all_design_ids)
				Fail("Duplicate design_id [id] present in multiple techweb nodes!")
			else
				Fail("Techweb node [node] has a design_id [id] which does not have a corresponding /datum/design id!")

	for(var/id in passed_design_ids)
		Fail("Orphaned /datum/design id [id] does not have a techweb node containing it!")
