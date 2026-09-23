/// Checks add_access()/remove_access() handle lists, single values, and no-ops like the raw list ops did.
/datum/unit_test/id_card_access

/datum/unit_test/id_card_access/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list()

	// Add a list.
	card.add_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT(ACCESS_MEDICAL in card.access, "add_access(list) did not grant ACCESS_MEDICAL")
	TEST_ASSERT(ACCESS_ENGINE in card.access, "add_access(list) did not grant ACCESS_ENGINE")
	TEST_ASSERT_EQUAL(length(card.access), 2, "add_access(list) changed the access count unexpectedly")

	// Add a single value.
	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(ACCESS_BRIG in card.access, "add_access(single) did not grant ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access(single) changed the access count unexpectedly")

	// Re-adding held access does nothing.
	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access() duplicated an access the card already held")

	// Remove a single value.
	card.remove_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(!(ACCESS_BRIG in card.access), "remove_access(single) did not revoke ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 2, "remove_access(single) changed the access count unexpectedly")

	// Remove a list.
	card.remove_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access(list) did not revoke all listed access")

	// Removing absent access does nothing.
	card.remove_access(ACCESS_MEDICAL, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access() of an absent access altered the access list")

/// Checks temporary access grants surface through GetAccess(), stay out of the permanent list, and revoke cleanly.
/datum/unit_test/id_card_temporary_access

/datum/unit_test/id_card_temporary_access/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MEDICAL)

	// An open-ended grant surfaces through GetAccess() but not the permanent list.
	var/datum/access_grant/grant = card.grant_temporary_access(ACCESS_ENGINE, "unit test")
	TEST_ASSERT_NOTNULL(grant, "grant_temporary_access did not return a grant")
	TEST_ASSERT(ACCESS_ENGINE in card.GetAccess(), "temporary access did not surface through GetAccess()")
	TEST_ASSERT(!(ACCESS_ENGINE in card.access), "temporary access leaked into the permanent access list")

	// Revoking removes the access and clears the grant.
	grant.revoke()
	TEST_ASSERT(!(ACCESS_ENGINE in card.GetAccess()), "revoked temporary access still surfaced through GetAccess()")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "revoked grant was not cleared from the card")

	// A grant overlapping a permanent access must not strip it on revoke.
	var/datum/access_grant/overlap = card.grant_temporary_access(ACCESS_MEDICAL, "unit test")
	overlap.revoke()
	TEST_ASSERT(ACCESS_MEDICAL in card.GetAccess(), "revoking an overlapping temporary grant stripped permanent access")

	// Expiry follows the same path and clears the grant.
	var/datum/access_grant/timed = card.grant_temporary_access(ACCESS_BRIG, "unit test")
	timed.expire()
	TEST_ASSERT(!(ACCESS_BRIG in card.GetAccess()), "expired temporary access still surfaced through GetAccess()")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "expired grant was not cleared from the card")

	// A grace period keeps access live past revocation until it elapses.
	var/datum/access_grant/graced = card.grant_temporary_access(ACCESS_BRIG, "unit test")
	graced.revoke("revoked", 30 SECONDS)
	TEST_ASSERT(ACCESS_BRIG in card.GetAccess(), "grace-period revocation cut access immediately")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 1, "grace-period grant was dropped before its grace elapsed")

	// Revoking again during grace finalizes immediately.
	graced.revoke()
	TEST_ASSERT(!(ACCESS_BRIG in card.GetAccess()), "revoking during grace did not cut access")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "grant was not cleared after finalizing during grace")

/// Checks the department aggregates cover what they claim to
/datum/unit_test/department_access

/datum/unit_test/department_access/Run()
	var/list/station_access = SSdepartment.get_department_access(DEPARTMENT_ID_STATION_ALL)
	var/list/all_access = SSdepartment.get_department_access(DEPARTMENT_ID_ALL_ACCESS)

	for(var/datum/department_group/dept as anything in SSdepartment.department_datums)
		if(!dept.is_station)
			continue
		for(var/access in dept.get_access_list())
			TEST_ASSERT(access in station_access, "station aggregate is missing [access] from [dept.dept_id]")

	TEST_ASSERT(!(ACCESS_CENT_GENERAL in station_access), "station aggregate leaked CentCom access")
	TEST_ASSERT(!(ACCESS_SYNDICATE in station_access), "station aggregate leaked syndicate access")
	TEST_ASSERT_EQUAL(length(all_access | station_access), length(all_access), "global aggregate does not contain the station aggregate")
	TEST_ASSERT(ACCESS_CENT_GENERAL in all_access, "global aggregate is missing CentCom access")
	TEST_ASSERT(ACCESS_SYNDICATE in all_access, "global aggregate is missing syndicate access")

	// An aggregate that is also a station department would try to combine with itself forever.
	for(var/datum/department_group/aggregate/dept in SSdepartment.department_datums)
		TEST_ASSERT(!dept.is_station, "aggregate [dept.dept_id] is a station department and will recurse")
		TEST_ASSERT(!(dept.dept_id in dept.member_dept_ids), "aggregate [dept.dept_id] lists itself as a member")

	var/list/restricted = SSdepartment.restricted_access
	TEST_ASSERT(ACCESS_CENT_GENERAL in restricted, "CentCom access is not restricted to the CentCom console")
	TEST_ASSERT(ACCESS_SYNDICATE in restricted, "syndicate access is not restricted to the CentCom console")
	TEST_ASSERT(ACCESS_BLOODCULT in restricted, "special access is not restricted to the CentCom console")
	TEST_ASSERT(!(ACCESS_MEDICAL in restricted), "ordinary station access was restricted to the CentCom console")

	// Every access the ID consoles render needs a description.
	for(var/dept_id in SSdepartment.station_access_dept_ids)
		for(var/access in SSdepartment.get_department_access(dept_id))
			TEST_ASSERT(!findtext(get_access_desc(access), "Unknown "), "[dept_id] grants [access], which has no description")
