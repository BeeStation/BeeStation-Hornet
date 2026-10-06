/// Checks add_access()/remove_access()
/datum/unit_test/id_card_access

/datum/unit_test/id_card_access/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list()

	card.add_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT(ACCESS_MEDICAL in card.access, "add_access(list) did not grant ACCESS_MEDICAL")
	TEST_ASSERT(ACCESS_ENGINE in card.access, "add_access(list) did not grant ACCESS_ENGINE")
	TEST_ASSERT_EQUAL(length(card.access), 2, "add_access(list) changed the access count unexpectedly")

	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(ACCESS_BRIG in card.access, "add_access(single) did not grant ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access(single) changed the access count unexpectedly")

	card.add_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 3, "add_access() duplicated an access the card already held")

	card.remove_access(ACCESS_BRIG, "unit test")
	TEST_ASSERT(!(ACCESS_BRIG in card.access), "remove_access(single) did not revoke ACCESS_BRIG")
	TEST_ASSERT_EQUAL(length(card.access), 2, "remove_access(single) changed the access count unexpectedly")

	card.remove_access(list(ACCESS_MEDICAL, ACCESS_ENGINE), "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access(list) did not revoke all listed access")

	card.remove_access(ACCESS_MEDICAL, "unit test")
	TEST_ASSERT_EQUAL(length(card.access), 0, "remove_access() of an absent access altered the access list")

/// Checks temporary access grants through GetAccess()
/datum/unit_test/id_card_temporary_access

/datum/unit_test/id_card_temporary_access/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MEDICAL)

	var/datum/access_grant/grant = card.grant_temporary_access(ACCESS_ENGINE, "unit test")
	TEST_ASSERT_NOTNULL(grant, "grant_temporary_access did not return a grant")
	TEST_ASSERT(ACCESS_ENGINE in card.GetAccess(), "temporary access did not surface through GetAccess()")
	TEST_ASSERT(!(ACCESS_ENGINE in card.access), "temporary access leaked into the permanent access list")

	grant.revoke()
	TEST_ASSERT(!(ACCESS_ENGINE in card.GetAccess()), "revoked temporary access still surfaced through GetAccess()")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "revoked grant was not cleared from the card")

	var/datum/access_grant/overlap = card.grant_temporary_access(ACCESS_MEDICAL, "unit test")
	overlap.revoke()
	TEST_ASSERT(ACCESS_MEDICAL in card.GetAccess(), "revoking an overlapping temporary grant stripped permanent access")

	var/datum/access_grant/timed = card.grant_temporary_access(ACCESS_BRIG, "unit test")
	timed.expire()
	TEST_ASSERT(!(ACCESS_BRIG in card.GetAccess()), "expired temporary access still surfaced through GetAccess()")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "expired grant was not cleared from the card")

	var/datum/access_grant/graced = card.grant_temporary_access(ACCESS_BRIG, "unit test")
	graced.revoke("revoked", 30 SECONDS)
	TEST_ASSERT(ACCESS_BRIG in card.GetAccess(), "grace-period revocation cut access immediately")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 1, "grace-period grant was dropped before its grace elapsed")

	graced.revoke()
	TEST_ASSERT(!(ACCESS_BRIG in card.GetAccess()), "revoking during grace did not cut access")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), 0, "grant was not cleared after finalizing during grace")

/// Checks acting head promotion
/datum/unit_test/id_card_acting_head

/datum/unit_test/id_card_acting_head/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	SSjob.refresh_skeleton_access()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	var/list/engineer_access = card.GetAccess().Copy()
	var/engineer_hud = card.hud_state
	var/list/head_extra = chief.get_access() - engineer_access
	TEST_ASSERT(length(head_extra), "CE has no access beyond an engineer's")

	TEST_ASSERT(card.needs_acting_head_for(chief), "Engineer card didn't need acting CE")
	card.grant_acting_head(chief, "unit test")
	TEST_ASSERT_EQUAL(card.assignment, "Acting [JOB_NAME_CHIEFENGINEER]", "Acting CE has the wrong title")
	TEST_ASSERT_EQUAL(card.job_title, JOB_NAME_STATIONENGINEER, "Acting CE changed the card's job")
	TEST_ASSERT_EQUAL(card.hud_state, JOB_HUD_CHIEFENGINEER, "Acting CE has the wrong HUD")
	TEST_ASSERT_EQUAL(length(card.GetAccess() & head_extra), length(head_extra), "Acting CE is missing CE access")
	TEST_ASSERT(!length(card.access & head_extra), "Acting CE access is permanent")

	card.acting_head.revoke("revoked", 0)
	TEST_ASSERT_NULL(card.acting_head, "Acting role not cleared")
	TEST_ASSERT_EQUAL(card.assignment, JOB_NAME_STATIONENGINEER, "Title not restored")
	TEST_ASSERT_EQUAL(card.hud_state, engineer_hud, "HUD not restored")
	TEST_ASSERT(!length(card.GetAccess() & head_extra), "CE access kept after revoke")
	TEST_ASSERT_EQUAL(length(card.GetAccess() & engineer_access), length(engineer_access), "Engineer access lost after revoke")

	var/obj/item/card/id/chief_card = allocate(/obj/item/card/id)
	chief_card.job_title = JOB_NAME_CHIEFENGINEER
	TEST_ASSERT(!chief_card.needs_acting_head_for(chief), "CE card needed acting CE")
	chief_card.assign_job(chief)
	TEST_ASSERT_EQUAL(chief_card.assignment, JOB_NAME_CHIEFENGINEER, "CE card got an acting title")

	var/obj/item/card/id/replacement_card = allocate(/obj/item/card/id)
	replacement_card.registered_account = allocate(/datum/bank_account, "Replacement Card Test", chief)
	TEST_ASSERT(!replacement_card.needs_acting_head_for(chief), "Replacement CE card needed acting CE")

	card.grant_acting_head(chief, "unit test")
	var/datum/access_grant/acting_head/acting_head = card.acting_head
	var/mob/living/carbon/human/arrival = allocate(/mob/living/carbon/human/consistent)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, engineer, arrival)
	TEST_ASSERT(!acting_head.revoking, "Unrelated latejoin ended acting CE")
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, chief, arrival)
	TEST_ASSERT(acting_head.revoking, "CE latejoin didn't end acting CE")
	TEST_ASSERT(length(card.GetAccess() & head_extra), "Acting CE access ended before grace")
	acting_head.finish_revoke()
	TEST_ASSERT(!length(card.GetAccess() & head_extra), "Acting CE access kept after grace")

/// Checks head-only console access is temporary
/datum/unit_test/id_card_console_head_access

/datum/unit_test/id_card_console_head_access/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	var/grants_before = LAZYLEN(card.access_grants)

	card.add_console_access(list(ACCESS_CAPTAIN, ACCESS_MEDICAL), "unit test")
	TEST_ASSERT(ACCESS_MEDICAL in card.access, "Medical access not permanent")
	TEST_ASSERT(ACCESS_CAPTAIN in card.GetAccess(), "Captain access not granted")
	TEST_ASSERT(!(ACCESS_CAPTAIN in card.access), "Captain access granted permanently")

	card.remove_access(ACCESS_CAPTAIN, "unit test")
	TEST_ASSERT(!(ACCESS_CAPTAIN in card.GetAccess()), "Captain access not removed")
	TEST_ASSERT_EQUAL(LAZYLEN(card.access_grants), grants_before, "Emptied grant not deleted")

	var/list/head_only = (chief.get_access() & SSjob.head_only_access) - engineer.get_access()
	TEST_ASSERT(length(head_only), "CE has no head-only access beyond an engineer's")
	card.grant_acting_head(chief, "unit test")
	card.add_console_access(get_all_accesses(), "unit test")
	TEST_ASSERT(!length(card.access & head_only), "Grant all made acting CE access permanent")

	var/obj/item/card/id/chief_card = allocate(/obj/item/card/id)
	chief_card.job_title = JOB_NAME_CHIEFENGINEER
	chief_card.add_console_access(ACCESS_CE, "unit test")
	TEST_ASSERT(ACCESS_CE in chief_card.access, "CE access not permanent on CE card")

/// Checks acting heads on the manifest
/datum/unit_test/id_card_acting_head_manifest

/datum/unit_test/id_card_acting_head_manifest/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Acting Head Manifest Test"
	card.job_title = JOB_NAME_CHIEFENGINEER
	card.assignment = JOB_NAME_CHIEFENGINEER
	var/datum/record/crew/record = new(name = card.registered_name, rank = JOB_NAME_CHIEFENGINEER)
	LAZYADD(allocated, record)

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CAPTAIN), "unit test")
	TEST_ASSERT(ACCESS_CHANGE_IDS in card.get_authority_access(), "Acting captain can't edit IDs")
	TEST_ASSERT_EQUAL(record.rank, "Acting [JOB_NAME_CAPTAIN]", "Record rank not synced")
	TEST_ASSERT_EQUAL(record.acting_job_title, JOB_NAME_CAPTAIN, "Record acting job not synced")
	TEST_ASSERT(SSjob.has_minimum_jobs(99, head_jobs = list(JOB_NAME_CHIEFENGINEER)), "Acting captain no longer counts as CE")
	TEST_ASSERT(SSjob.has_minimum_jobs(99, head_jobs = list(JOB_NAME_CAPTAIN)), "Acting captain doesn't count as captain")

	var/list/manifest = GLOB.manifest.get_manifest()
	var/datum/department_group/engineering = SSdepartment.department_datums_by_type[/datum/department_group/engineering]
	var/datum/department_group/command = SSdepartment.department_datums_by_type[/datum/department_group/command]
	TEST_ASSERT(manifest_lists(manifest[engineering.manifest_category_name], card.registered_name), "Acting captain missing from engineering")
	TEST_ASSERT(manifest_lists(manifest[command.manifest_category_name], card.registered_name), "Acting captain missing from command")

	card.acting_head.revoke("revoked", 0)
	TEST_ASSERT_EQUAL(record.rank, JOB_NAME_CHIEFENGINEER, "Record rank not restored")
	TEST_ASSERT_NULL(record.acting_job_title, "Record acting job not cleared")

/datum/unit_test/id_card_acting_head_manifest/proc/manifest_lists(list/category, name)
	for(var/list/entry as anything in category)
		if(entry["name"] == name)
			return TRUE
	return FALSE

/// Checks skeleton crew access
/datum/unit_test/skeleton_crew_access
	var/old_chiefs
	var/old_assistants

/datum/unit_test/skeleton_crew_access/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/job/assistant = SSjob.get_job(JOB_NAME_ASSISTANT)
	var/datum/skeleton_access/rule = locate(/datum/skeleton_access/chief_engineer) in SSjob.skeleton_rules
	TEST_ASSERT_NOTNULL(rule, "CE skeleton rule missing")
	TEST_ASSERT(SSjob.get_crew_count() < COMMAND_POPULATION_MINIMUM, "Too much crew for skeleton access")
	old_chiefs = chief.current_positions
	old_assistants = assistant.current_positions
	chief.current_positions = 0
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.enabled, "CE rule off with no CE")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Engineer missing CE access with no CE")
	TEST_ASSERT(!(ACCESS_CE in card.access), "Skeleton access is permanent")
	var/datum/skeleton_access/cook_rule = locate(/datum/skeleton_access/cook) in SSjob.skeleton_rules
	TEST_ASSERT(rule.notifies(JOB_NAME_STATIONENGINEER) && !cook_rule.notifies(JOB_NAME_STATIONENGINEER), "Skeleton access announced outside its department")

	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human/consistent)
	corpse.equipOutfit(/datum/outfit/job/engineer)
	var/obj/item/card/id/corpse_card = corpse.wear_id
	TEST_ASSERT_NOTNULL(corpse_card, "Engineer outfit has no ID")
	TEST_ASSERT(!(ACCESS_CE in corpse_card.GetAccess()), "Corpse got skeleton access")

	var/obj/item/card/id/doctor_card = allocate(/obj/item/card/id)
	doctor_card.assign_job(SSjob.get_job(JOB_NAME_MEDICALDOCTOR))
	TEST_ASSERT(!(ACCESS_CE in doctor_card.GetAccess()), "Doctor got CE skeleton access")

	var/obj/item/card/id/withheld_card = allocate(/obj/item/card/id)
	withheld_card.assign_job(engineer)
	withheld_card.remove_access(ACCESS_CE, "unit test")
	TEST_ASSERT(!(ACCESS_CE in withheld_card.GetAccess()), "Withheld skeleton access still on")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Withholding affected another card")

	chief.current_positions = 1
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, chief, allocate(/mob/living/carbon/human/consistent))
	TEST_ASSERT(rule.revoke_timer, "CE latejoin didn't start grace")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Skeleton access ended before grace")
	rule.finish_revoke()
	TEST_ASSERT(!(ACCESS_CE in card.GetAccess()), "Skeleton access kept after grace")

	SSjob.FreeRole(chief)
	TEST_ASSERT_EQUAL(chief.current_positions, 0, "FreeRole didn't free the job")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Skeleton access didn't return after cryo")

	var/obj/item/card/id/acting_card = allocate(/obj/item/card/id)
	acting_card.assign_job(engineer)
	acting_card.grant_acting_head(chief, "unit test")
	TEST_ASSERT(rule.revoke_timer, "Acting CE didn't start grace")
	acting_card.acting_head.revoke("revoked", 0)
	TEST_ASSERT(!rule.revoke_timer, "Acting CE ending didn't cancel grace")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Skeleton access ended after acting CE")

	assistant.current_positions += COMMAND_POPULATION_MINIMUM
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.revoke_timer, "Crew limit didn't start grace")

	assistant.current_positions = old_assistants
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.enabled && !rule.revoke_timer, "Dropping under the limit didn't cancel grace")

/datum/unit_test/skeleton_crew_access/Destroy()
	if(!isnull(old_chiefs))
		var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
		chief.current_positions = old_chiefs
	if(!isnull(old_assistants))
		var/datum/job/assistant = SSjob.get_job(JOB_NAME_ASSISTANT)
		assistant.current_positions = old_assistants
	for(var/datum/skeleton_access/rule as anything in SSjob.skeleton_rules)
		deltimer(rule.revoke_timer)
		rule.revoke_timer = null
		rule.enabled = FALSE
	SSjob.update_skeleton_access()
	return ..()

/// Checks only head and acting head access can edit IDs
/datum/unit_test/id_card_authority
	var/old_chiefs

/datum/unit_test/id_card_authority/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/skeleton_access/rule = locate(/datum/skeleton_access/chief_engineer) in SSjob.skeleton_rules
	old_chiefs = chief.current_positions
	chief.current_positions = 0
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.enabled, "CE rule off with no CE")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	var/datum/computer_file/program/card_mod/program = allocate(/datum/computer_file/program/card_mod)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Engineer missing CE access with no CE")
	TEST_ASSERT(!program.authenticate(null, card), "Skeleton access can edit IDs")

	card.grant_temporary_access(ACCESS_CE, "unit test")
	TEST_ASSERT(!program.authenticate(null, card), "Console grant can edit IDs")

	card.grant_acting_head(chief, "unit test")
	TEST_ASSERT(program.authenticate(null, card), "Acting CE can't edit IDs")
	card.acting_head.revoke("revoked", 0)

/datum/unit_test/id_card_authority/Destroy()
	if(!isnull(old_chiefs))
		var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
		chief.current_positions = old_chiefs
	for(var/datum/skeleton_access/rule as anything in SSjob.skeleton_rules)
		deltimer(rule.revoke_timer)
		rule.revoke_timer = null
		rule.enabled = FALSE
	SSjob.update_skeleton_access()
	return ..()

/// Checks ID console pay changes need head authority over the department
/datum/unit_test/id_console_pay_authority

/datum/unit_test/id_console_pay_authority/Run()
	var/obj/machinery/computer/card/console = allocate(/obj/machinery/computer/card)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_HEADS)
	console.inserted_scan_id = card
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Bridge access can change pay")

	card.grant_temporary_access(ACCESS_HOP, "unit test")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Console grant can change pay")

	card.access |= ACCESS_HOP
	TEST_ASSERT(console.can_manage_pay(ACCOUNT_SRV_ID), "HoP can't change service pay")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SEC_ID), "HoP can change security pay")

	console.inserted_scan_id = null
	console.authenticated = 1
	console.accessible_dept_payment_bitflag = ACCOUNT_SEC_BITFLAG
	TEST_ASSERT(console.can_manage_pay(ACCOUNT_SEC_ID), "Logged in HoS can't change security pay")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Logged in HoS can change service pay")
