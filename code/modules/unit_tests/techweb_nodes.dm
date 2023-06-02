/// Test to ensure that every design has a connected techweb node and vice-versa
/datum/unit_test/orphaned_designs

/datum/unit_test/orphaned_designs/Run()
	var/list/all_designs = subtypesof(/datum/design)
	// error case
	all_designs -= /datum/design/error_design
	// subtypes
	all_designs -= list(
		/datum/design/battery,
		/datum/design/board,
		/datum/design/breaching_slug,
		/datum/design/component,
		/datum/design/component/arbitrary_input_amount,
		/datum/design/disk,
		/datum/design/nanites,
		/datum/design/netcard,
		/datum/design/portabledrive,
		/datum/design/rcd_upgrade,
		/datum/design/rpd_upgrade,
		/datum/design/surgery,
		/datum/design/surgery/healing,
	)

	var/list/all_technodes = subtypesof(/datum/techweb_node)
	// error case
	all_technodes -= /datum/techweb_node/error_node

	var/list/all_design_ids = list()
	var/list/passed_design_ids = list()
	for(var/datum/design/DN as() in all_designs)
		if(isnull(initial(DN.id)))
			Fail("[DN] is missing an id!")
			continue
		if(initial(DN.id) == DESIGN_ID_IGNORE)
			Fail("[DN] is set to the ignored id!")
			continue
		if(initial(DN.id) in all_design_ids)
			Fail("Duplicate design_id [initial(DN.id)] present in multiple /datum/design!")
			continue
		all_design_ids += initial(DN.id)
		passed_design_ids += initial(DN.id)

	for(var/datum/techweb_node/TN as() in all_technodes)
		for(var/id in initial(TN.design_ids))
			if(id in passed_design_ids)
				passed_design_ids -= id
				continue

			// This detects if there is a duplicate, as we have already passed it above
			if(id in all_design_ids)
				Fail("Duplicate design_id [id] present in multiple techweb nodes!")
			else
				Fail("Techweb node [TN] has a design_id [id] which does not have a corresponding /datum/design id!")

	for(var/id in passed_design_ids)
		Fail("Orphaned /datum/design id [id] does not have a techweb node containing it!")
