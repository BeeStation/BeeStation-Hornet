/// Base for these tests. Puts job counts back and turns skeleton rules off afterwards
/datum/unit_test/job_access
	abstract_type = /datum/unit_test/job_access
	/// Job title to its current_positions before the test changed it
	var/list/old_positions = list()

/datum/unit_test/job_access/Destroy()
	for(var/title in old_positions)
		var/datum/job/job = SSjob.get_job(title)
		job.current_positions = old_positions[title]
	. = ..()
	// After ..(), since deleting the cards refreshes skeleton rules
	reset_skeleton_access()

/// Changes a job's count. Destroy() puts back the count from before the first change
/datum/unit_test/job_access/proc/set_positions(title, count)
	var/datum/job/job = SSjob.get_job(title)
	if(!(title in old_positions))
		old_positions[title] = job.current_positions
	job.current_positions = count

/datum/unit_test/job_access/proc/reset_skeleton_access()
	for(var/datum/skeleton_access/rule as anything in SSjob.skeleton_rules)
		deltimer(rule.timer_id)
		rule.timer_id = null
		rule.revoking = FALSE
		rule.revoke_after_assignment = null
		rule.set_enabled(FALSE)

/datum/unit_test/job_access/temporary

/datum/unit_test/job_access/temporary/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MEDICAL)

	var/datum/access_grant/grant = card.grant_temporary_access(list(ACCESS_ENGINE), "unit test")
	TEST_ASSERT(ACCESS_ENGINE in card.GetAccess(), "Temporary access missing")
	TEST_ASSERT(!(ACCESS_ENGINE in card.access), "Temporary access is permanent")

	grant.revoke()
	TEST_ASSERT(!(ACCESS_ENGINE in card.GetAccess()), "Temporary access kept after revoke")

	var/datum/access_grant/overlap = card.grant_temporary_access(list(ACCESS_MEDICAL), "unit test")
	overlap.revoke()
	TEST_ASSERT(ACCESS_MEDICAL in card.GetAccess(), "Revoke removed permanent access")

	var/datum/access_grant/timed = card.grant_temporary_access(list(ACCESS_BRIG), "unit test")
	timed.expire()
	TEST_ASSERT(!(ACCESS_BRIG in card.GetAccess()), "Temporary access kept after expiring")

/datum/unit_test/job_access/grace_ends

/datum/unit_test/job_access/grace_ends/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CHIEFENGINEER), "unit test")
	card.acting_head.revoke_after(1)

	sleep(1 SECONDS)
	TEST_ASSERT_NULL(card.acting_head, "Acting CE outlived its grace")

/datum/unit_test/job_access/acting_head

/datum/unit_test/job_access/acting_head/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	SSjob.refresh_skeleton_access()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	var/list/head_extra = chief.get_access() - card.GetAccess()
	TEST_ASSERT(length(head_extra), "CE has no access beyond an engineer's")

	card.grant_acting_head(chief, "unit test")
	TEST_ASSERT_EQUAL(card.get_assignment(), "Acting [JOB_NAME_CHIEFENGINEER]", "Acting CE has the wrong title")
	TEST_ASSERT_EQUAL(card.get_hud_state(), JOB_HUD_CHIEFENGINEER, "Acting CE has the wrong HUD")
	TEST_ASSERT_EQUAL(length(card.GetAccess() & head_extra), length(head_extra), "Acting CE is missing CE access")

	card.acting_head.revoke()
	TEST_ASSERT_EQUAL(card.get_assignment(), JOB_NAME_STATIONENGINEER, "Title not restored")
	TEST_ASSERT(!length(card.GetAccess() & head_extra), "CE access kept after revoke")

	card.grant_acting_head(chief, "unit test")
	card.assignment = "Custom Title"
	card.acting_head.revoke()
	TEST_ASSERT_EQUAL(card.get_assignment(), "Custom Title", "Retitle during acting was lost")

	var/obj/item/card/id/chief_card = allocate(/obj/item/card/id)
	chief_card.job_title = JOB_NAME_CHIEFENGINEER
	TEST_ASSERT(!chief_card.needs_acting_head_for(chief), "CE card needed acting CE")

	var/obj/item/card/id/replacement_card = allocate(/obj/item/card/id)
	replacement_card.registered_account = allocate(/datum/bank_account, "Replacement Card Test", chief)
	TEST_ASSERT(!replacement_card.needs_acting_head_for(chief), "Replacement CE card needed acting CE")

	var/obj/item/card/id/unlinked_card = allocate(/obj/item/card/id)
	unlinked_card.registered_name = "Unlinked Card Test"
	TEST_ASSERT(unlinked_card.needs_acting_head_for(chief), "Unknown unlinked card didn't need acting CE")
	var/datum/record/crew/unlinked_record = new(name = unlinked_card.registered_name, initial_rank = JOB_NAME_CHIEFENGINEER)
	LAZYADD(allocated, unlinked_record)
	TEST_ASSERT(!unlinked_card.needs_acting_head_for(chief), "Unlinked CE card needed acting CE")

	card.grant_acting_head(chief, "unit test")
	var/datum/access_grant/acting_head/acting_head = card.acting_head
	var/mob/living/carbon/human/arrival = allocate(/mob/living/carbon/human/consistent)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, engineer, arrival)
	TEST_ASSERT(!acting_head.revoking, "Unrelated latejoin ended acting CE")
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, chief, arrival)
	TEST_ASSERT(acting_head.revoking, "CE latejoin didn't end acting CE")
	TEST_ASSERT(length(card.GetAccess() & head_extra), "Acting CE access ended before grace")
	acting_head.revoke()

	card.grant_acting_head(chief, "unit test")
	acting_head = card.acting_head
	set_positions(JOB_NAME_CHIEFENGINEER, 1)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, chief, arrival)
	SSjob.FreeRole(chief)
	TEST_ASSERT(!acting_head.revoking, "CE leaving during grace didn't keep acting CE")
	acting_head.revoke()

/// Checks head-only console access is temporary
/datum/unit_test/job_access/console_head_access

/datum/unit_test/job_access/console_head_access/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)

	card.add_console_access(list(ACCESS_CAPTAIN, ACCESS_MEDICAL), "unit test")
	TEST_ASSERT(ACCESS_MEDICAL in card.access, "Medical access not permanent")
	TEST_ASSERT(ACCESS_CAPTAIN in card.GetAccess(), "Captain access not granted")
	TEST_ASSERT(!(ACCESS_CAPTAIN in card.access), "Captain access granted permanently")

	card.remove_access(list(ACCESS_CAPTAIN))
	TEST_ASSERT(!(ACCESS_CAPTAIN in card.GetAccess()), "Captain access not removed")

	var/list/head_only = (chief.get_access() & SSdepartment.get_head_only_access()) - engineer.get_access()
	TEST_ASSERT(length(head_only), "CE has no head-only access beyond an engineer's")
	card.grant_acting_head(chief, "unit test")
	card.add_console_access(get_all_accesses(), "unit test")
	TEST_ASSERT(!length(card.access & head_only), "Grant all made acting CE access permanent")

	var/obj/item/card/id/chief_card = allocate(/obj/item/card/id)
	chief_card.job_title = JOB_NAME_CHIEFENGINEER
	chief_card.add_console_access(list(ACCESS_CE), "unit test")
	TEST_ASSERT(ACCESS_CE in chief_card.access, "CE access not permanent on CE card")

/// Checks a console can give an acting head back access it removed
/datum/unit_test/job_access/acting_head_restore

/datum/unit_test/job_access/acting_head_restore/Run()
	SSjob.refresh_skeleton_access()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(SSjob.get_job(JOB_NAME_STATIONENGINEER))
	card.grant_acting_head(SSjob.get_job(JOB_NAME_CHIEFENGINEER), "unit test")

	card.remove_console_access(list(ACCESS_CE), "unit test")
	TEST_ASSERT(!(ACCESS_CE in card.get_authority_access()), "Console didn't remove CE access from acting CE")

	card.add_console_access(list(ACCESS_CE), "unit test")
	TEST_ASSERT(ACCESS_CE in card.get_authority_access(), "Acting CE didn't get CE authority back")
	TEST_ASSERT(!(ACCESS_CE in card.access), "Giving CE access back made it permanent")

/datum/unit_test/job_access/acting_head_manifest

/datum/unit_test/job_access/acting_head_manifest/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Acting Head Manifest Test"
	card.job_title = JOB_NAME_CHIEFENGINEER
	card.assignment = JOB_NAME_CHIEFENGINEER
	var/datum/record/crew/record = new(name = card.registered_name, rank = JOB_NAME_CHIEFENGINEER)
	LAZYADD(allocated, record)

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CAPTAIN), "unit test")
	TEST_ASSERT_EQUAL(record.rank, "Acting [JOB_NAME_CAPTAIN]", "Record rank not synced")
	TEST_ASSERT(SSjob.has_minimum_jobs(99, head_jobs = list(JOB_NAME_CHIEFENGINEER)), "Acting captain no longer counts as CE")
	TEST_ASSERT(SSjob.has_minimum_jobs(99, head_jobs = list(JOB_NAME_CAPTAIN)), "Acting captain doesn't count as captain")

	var/list/manifest = GLOB.manifest.get_manifest()
	var/datum/department_group/engineering = SSdepartment.department_datums_by_type[/datum/department_group/engineering]
	var/datum/department_group/command = SSdepartment.department_datums_by_type[/datum/department_group/command]
	TEST_ASSERT(manifest_lists(manifest[engineering.manifest_category_name], card.registered_name), "Acting captain missing from engineering")
	TEST_ASSERT(manifest_lists(manifest[command.manifest_category_name], card.registered_name), "Acting captain missing from command")

	card.acting_head.revoke()
	TEST_ASSERT_EQUAL(record.rank, JOB_NAME_CHIEFENGINEER, "Record rank not restored")

/datum/unit_test/job_access/acting_head_manifest/proc/manifest_lists(list/category, name)
	for(var/list/entry as anything in category)
		if(entry["name"] == name)
			return TRUE
	return FALSE

/// Checks two acting cards sharing a bank account and a name
/datum/unit_test/job_access/acting_head_shared

/datum/unit_test/job_access/acting_head_shared/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/job/captain = SSjob.get_job(JOB_NAME_CAPTAIN)
	var/datum/bank_account/account = allocate(/datum/bank_account, "Shared Acting Test", engineer)
	var/base_pay = account.payment_per_department[ACCOUNT_COM_ID]
	var/chief_pay = chief.payment_per_department[ACCOUNT_COM_ID]
	TEST_ASSERT(chief_pay > base_pay, "Engineer already has command pay")
	var/datum/record/crew/record = new(name = "Shared Acting Test", rank = JOB_NAME_STATIONENGINEER)
	LAZYADD(allocated, record)

	var/obj/item/card/id/first = allocate(/obj/item/card/id)
	var/obj/item/card/id/second = allocate(/obj/item/card/id)
	for(var/obj/item/card/id/card as anything in list(first, second))
		card.registered_name = record.name
		card.registered_account = account
		card.assign_job(engineer)

	first.grant_acting_head(captain, "unit test")
	second.grant_acting_head(chief, "unit test")
	first.acting_head.revoke()
	TEST_ASSERT_EQUAL(account.payment_per_department[ACCOUNT_COM_ID], chief_pay, "Remaining acting head has the wrong command pay")
	TEST_ASSERT_EQUAL(record.get_acting_job()?.title, JOB_NAME_CHIEFENGINEER, "Remaining acting head left the manifest")
	var/obj/item/card/id/third = allocate(/obj/item/card/id)
	third.registered_name = record.name
	third.sync_manifest()
	TEST_ASSERT_EQUAL(record.get_acting_job()?.title, JOB_NAME_CHIEFENGINEER, "Syncing a card with the same name cleared the acting head")

	second.acting_head.revoke()
	TEST_ASSERT_EQUAL(account.payment_per_department[ACCOUNT_COM_ID], base_pay, "Command pay not restored")
	TEST_ASSERT_NULL(record.get_acting_job(), "Record acting job not cleared")

/datum/unit_test/job_access/acting_head_wallet

/datum/unit_test/job_access/acting_head_wallet/Run()
	var/obj/item/storage/wallet/wallet = allocate(/obj/item/storage/wallet)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(SSjob.get_job(JOB_NAME_STATIONENGINEER))
	card.forceMove(wallet)

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CAPTAIN), "unit test")
	TEST_ASSERT(findtext(wallet.name, "Acting [JOB_NAME_CAPTAIN]"), "Wallet name missing acting title")
	card.acting_head.revoke()
	TEST_ASSERT(!findtext(wallet.name, "Acting [JOB_NAME_CAPTAIN]"), "Wallet name kept acting title")

/datum/unit_test/job_access/acting_head_deleted

/datum/unit_test/job_access/acting_head_deleted/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/skeleton_access/rule = locate(/datum/skeleton_access/engineering/chief_engineer) in SSjob.skeleton_rules
	set_positions(JOB_NAME_CHIEFENGINEER, 0)
	SSjob.refresh_skeleton_access()

	var/obj/item/card/id/other_card = allocate(/obj/item/card/id)
	other_card.assign_job(engineer)
	var/obj/item/card/id/acting_card = allocate(/obj/item/card/id)
	acting_card.assign_job(engineer)
	acting_card.grant_acting_head(chief, "unit test")
	TEST_ASSERT(rule.revoking, "Acting CE didn't start grace")

	qdel(acting_card)
	TEST_ASSERT(rule.enabled && !rule.revoking, "Deleted acting CE didn't cancel grace")

/// Checks renaming an acting card ends the appointment and leaves both records right
/datum/unit_test/job_access/acting_head_renamed

/datum/unit_test/job_access/acting_head_renamed/Run()
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Renamed Acting Test"
	card.assign_job(SSjob.get_job(JOB_NAME_STATIONENGINEER))
	var/datum/record/crew/old_record = new(name = card.registered_name, rank = JOB_NAME_STATIONENGINEER)
	LAZYADD(allocated, old_record)
	var/datum/record/crew/new_record = new(name = "Renamed Acting Test Two", rank = JOB_NAME_MEDICALDOCTOR)
	LAZYADD(allocated, new_record)

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CAPTAIN), "unit test")
	card.set_registered_name(new_record.name)
	TEST_ASSERT_NULL(card.acting_head, "Rename kept the acting role")
	TEST_ASSERT_EQUAL(old_record.rank, JOB_NAME_STATIONENGINEER, "Old record kept the acting title")
	TEST_ASSERT_EQUAL(new_record.rank, JOB_NAME_MEDICALDOCTOR, "Rename overwrote the new name's record")

	var/obj/machinery/computer/card/console = allocate(/obj/machinery/computer/card)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	card.forceMove(console)
	console.inserted_modify_id = card
	console.id_eject(user, card)
	console.inserted_modify_id = null
	TEST_ASSERT_EQUAL(new_record.rank, JOB_NAME_MEDICALDOCTOR, "Ejecting the renamed card overwrote the new name's record")

	card.grant_acting_head(SSjob.get_job(JOB_NAME_CAPTAIN), "unit test")
	TEST_ASSERT_EQUAL(new_record.get_acting_job()?.title, JOB_NAME_CAPTAIN, "Second appointment not synced")
	SSjob.end_acting_heads_for(new_record.name, "unit test cryo")
	TEST_ASSERT_NULL(card.acting_head, "Cryo kept the acting role")

/// Checks command pay follows the card to a new account
/datum/unit_test/job_access/acting_head_account

/datum/unit_test/job_access/acting_head_account/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/captain = SSjob.get_job(JOB_NAME_CAPTAIN)
	var/datum/bank_account/first = allocate(/datum/bank_account, "Account Acting Test", engineer)
	var/datum/bank_account/second = allocate(/datum/bank_account, "Account Acting Test Two", engineer)
	var/base_pay = first.payment_per_department[ACCOUNT_COM_ID]
	var/command_pay = captain.payment_per_department[ACCOUNT_COM_ID]
	TEST_ASSERT(command_pay > base_pay, "Engineer already has command pay")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	card.grant_acting_head(captain, "unit test")
	card.set_registered_account(first)
	TEST_ASSERT_EQUAL(first.payment_per_department[ACCOUNT_COM_ID], command_pay, "Linking an account didn't add command pay")

	card.set_registered_account(second)
	TEST_ASSERT_EQUAL(first.payment_per_department[ACCOUNT_COM_ID], base_pay, "Old account kept command pay")
	TEST_ASSERT_EQUAL(second.payment_per_department[ACCOUNT_COM_ID], command_pay, "New account didn't get command pay")

/datum/unit_test/job_access/reassignment

/datum/unit_test/job_access/reassignment/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/job/captain = SSjob.get_job(JOB_NAME_CAPTAIN)
	set_positions(JOB_NAME_CHIEFENGINEER, 0)
	SSjob.refresh_skeleton_access()

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)

	card.grant_acting_head(captain, "unit test")
	card.grant_acting_head(chief, "unit test")
	TEST_ASSERT_EQUAL(card.get_assignment(), "Acting [JOB_NAME_CHIEFENGINEER]", "Replacing acting role has the wrong title")
	card.acting_head.revoke()
	TEST_ASSERT(!(ACCESS_CAPTAIN in card.GetAccess()), "Captain access kept after a replaced acting role")

	card.remove_console_access(list(ACCESS_CE), "unit test")
	card.grant_temporary_access(list(ACCESS_HOS), "unit test")
	card.grant_acting_head(captain, "unit test")
	card.assign_job(engineer)
	TEST_ASSERT_NULL(card.acting_head, "Reassigned card kept its acting role")
	TEST_ASSERT(!(ACCESS_HOS in card.GetAccess()), "Reassigned card kept console access")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Reassigned card kept withheld skeleton access")

	card.unassign_job("terminated")
	TEST_ASSERT(!length(card.GetAccess()), "Terminated card kept access")

/datum/unit_test/job_access/skeleton_crew

/datum/unit_test/job_access/skeleton_crew/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	var/datum/job/assistant = SSjob.get_job(JOB_NAME_ASSISTANT)
	var/datum/skeleton_access/rule = locate(/datum/skeleton_access/engineering/chief_engineer) in SSjob.skeleton_rules
	var/datum/job/atmos_tech = SSjob.get_job(JOB_NAME_ATMOSPHERICTECHNICIAN)
	set_positions(JOB_NAME_CHIEFENGINEER, 0)
	set_positions(JOB_NAME_ATMOSPHERICTECHNICIAN, 0)
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.enabled, "CE rule off with no CE")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Engineer missing CE access with no CE")
	var/datum/skeleton_access/cook_rule = locate(/datum/skeleton_access/service/cook) in SSjob.skeleton_rules
	TEST_ASSERT(rule.notifies(JOB_NAME_STATIONENGINEER) && !cook_rule.notifies(JOB_NAME_STATIONENGINEER), "Skeleton access announced outside its department")

	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human/consistent)
	corpse.equipOutfit(/datum/outfit/job/engineer)
	var/obj/item/card/id/corpse_card = corpse.wear_id
	TEST_ASSERT(!(ACCESS_CE in corpse_card.GetAccess()), "Corpse got skeleton access")

	var/obj/item/card/id/doctor_card = allocate(/obj/item/card/id)
	doctor_card.assign_job(SSjob.get_job(JOB_NAME_MEDICALDOCTOR))
	TEST_ASSERT(!(ACCESS_CE in doctor_card.GetAccess()), "Doctor got CE skeleton access")

	var/obj/item/card/id/withheld_card = allocate(/obj/item/card/id)
	withheld_card.assign_job(engineer)
	withheld_card.remove_access(list(ACCESS_CE))
	TEST_ASSERT(ACCESS_CE in withheld_card.GetAccess(), "Removing access outside a console withheld skeleton access")
	withheld_card.remove_console_access(list(ACCESS_CE), "unit test")
	TEST_ASSERT(!(ACCESS_CE in withheld_card.GetAccess()), "Withheld skeleton access still on")

	withheld_card.remove_console_access(list(ACCESS_ATMOSPHERICS), "unit test")
	withheld_card.add_console_access(list(ACCESS_CE, ACCESS_ATMOSPHERICS), "unit test")
	TEST_ASSERT(ACCESS_CE in withheld_card.GetAccess(), "Turned back on CE skeleton access missing")
	TEST_ASSERT(ACCESS_ATMOSPHERICS in withheld_card.GetAccess(), "Turned back on atmos skeleton access missing")
	TEST_ASSERT(!(ACCESS_ATMOSPHERICS in withheld_card.access), "Turned back on atmos skeleton access is permanent")

	var/obj/item/card/id/transfer_card = allocate(/obj/item/card/id)
	transfer_card.assign_job(atmos_tech)
	chief.current_positions = 1
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, chief, allocate(/mob/living/carbon/human/consistent))
	TEST_ASSERT(rule.revoking, "CE latejoin didn't start grace")
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Skeleton access ended before grace")
	card.assign_job(engineer)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Reprinting the same job ended grace early")
	transfer_card.assign_job(engineer)
	TEST_ASSERT(!(ACCESS_CE in transfer_card.GetAccess()), "Card moved into the job during grace got its access")
	rule.finish_revoke()
	TEST_ASSERT(!(ACCESS_CE in card.GetAccess()), "Skeleton access kept after grace")
	TEST_ASSERT(!(ACCESS_CE in withheld_card.GetAccess()), "Turned back on skeleton access outlived its rule")

	SSjob.FreeRole(chief)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Skeleton access didn't return after cryo")

	var/obj/item/card/id/acting_card = allocate(/obj/item/card/id)
	acting_card.assign_job(engineer)
	acting_card.grant_acting_head(chief, "unit test")
	TEST_ASSERT(rule.revoking, "Acting CE didn't start grace")
	acting_card.acting_head.revoke()
	TEST_ASSERT(!rule.revoking, "Acting CE ending didn't cancel grace")

	set_positions(JOB_NAME_ASSISTANT, assistant.current_positions + COMMAND_POPULATION_MINIMUM)
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.revoking, "Crew limit didn't start grace")

	assistant.current_positions = old_positions[JOB_NAME_ASSISTANT]
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(rule.enabled && !rule.revoking, "Dropping under the limit didn't cancel grace")

/// Checks two skeleton rules giving the same access, with their handovers overlapping
/datum/unit_test/job_access/skeleton_crew_overlap

/datum/unit_test/job_access/skeleton_crew_overlap/Run()
	var/datum/job/bartender = SSjob.get_job(JOB_NAME_BARTENDER)
	var/datum/job/assistant = SSjob.get_job(JOB_NAME_ASSISTANT)
	var/datum/skeleton_access/unlock_rule
	for(var/datum/skeleton_access/rule as anything in SSjob.skeleton_rules)
		if(rule.type == /datum/skeleton_access/station_unlock)
			unlock_rule = rule
	var/datum/skeleton_access/bar_rule = locate(/datum/skeleton_access/service/bartender) in SSjob.skeleton_rules
	reset_skeleton_access()
	set_positions(JOB_NAME_BARTENDER, 0)
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(unlock_rule.enabled && bar_rule.enabled, "Station unlock and bartender rules not on")

	var/obj/item/card/id/old_card = allocate(/obj/item/card/id)
	old_card.assign_job(assistant)

	set_positions(JOB_NAME_ASSISTANT, assistant.current_positions + STATION_UNLOCK_POPULATION)
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(unlock_rule.revoking && !bar_rule.revoking, "Crew limit didn't start only the station unlock handover")

	var/obj/item/card/id/late_card = allocate(/obj/item/card/id)
	late_card.assign_job(assistant)
	TEST_ASSERT(!(ACCESS_CREMATORIUM in late_card.GetAccess()), "Latejoiner got access already handing over")
	TEST_ASSERT(ACCESS_BAR in late_card.GetAccess(), "Latejoiner missing access another rule gives")

	bartender.current_positions = 1
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(bar_rule.revoking, "Bartender didn't start the bartender handover")
	TEST_ASSERT(ACCESS_BAR in late_card.GetAccess(), "Latejoiner lost access before its handover ended")
	TEST_ASSERT(ACCESS_BAR in bar_rule.get_changed_access(old_card), "Handover warning left out access both rules are handing over")

	bartender.current_positions = 0
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(!bar_rule.revoking && unlock_rule.revoking, "Bartender leaving didn't cancel only the bartender handover")
	TEST_ASSERT(ACCESS_BAR in bar_rule.get_changed_access(old_card), "Cancelled handover didn't announce access it keeps")

	unlock_rule.finish_revoke()
	TEST_ASSERT(ACCESS_BAR in late_card.GetAccess(), "Latejoiner lost access another rule gives with station unlock")
	TEST_ASSERT(!(ACCESS_BAR in unlock_rule.get_changed_access(old_card)), "Handover announced access another rule keeps")

/// Checks the latejoiner who starts a handover doesn't get the access, and everyone before them keeps it
/datum/unit_test/job_access/skeleton_crew_arrival

/datum/unit_test/job_access/skeleton_crew_arrival/Run()
	var/datum/job/assistant = SSjob.get_job(JOB_NAME_ASSISTANT)
	var/datum/skeleton_access/unlock_rule
	for(var/datum/skeleton_access/rule as anything in SSjob.skeleton_rules)
		if(rule.type == /datum/skeleton_access/station_unlock)
			unlock_rule = rule
	reset_skeleton_access()
	SSjob.refresh_skeleton_access()
	TEST_ASSERT(unlock_rule.enabled, "Station unlock rule not on")

	var/obj/item/card/id/old_card = allocate(/obj/item/card/id)
	old_card.assign_job(assistant)

	var/mob/living/carbon/human/arrival = allocate(/mob/living/carbon/human/consistent)
	arrival.equipOutfit(/datum/outfit/job/assistant)
	var/obj/item/card/id/arrival_card = arrival.wear_id
	arrival_card.assign_job(assistant)
	set_positions(JOB_NAME_ASSISTANT, assistant.current_positions + STATION_UNLOCK_POPULATION)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, assistant, arrival)
	TEST_ASSERT(unlock_rule.revoking, "Latejoin over the crew limit didn't start grace")
	TEST_ASSERT(!(ACCESS_CREMATORIUM in arrival_card.GetAccess()), "Latejoiner got access their arrival is handing over")

	assistant.current_positions = old_positions[JOB_NAME_ASSISTANT]
	SSjob.refresh_skeleton_access()

	var/mob/living/carbon/human/unassigned = allocate(/mob/living/carbon/human/consistent)
	unassigned.equipOutfit(/datum/outfit/job/assistant)
	var/obj/item/card/id/unassigned_card = unassigned.wear_id
	TEST_ASSERT_EQUAL(unassigned_card.job_assignment_id, 0, "Outfit ID already has an assignment")
	assistant.current_positions += STATION_UNLOCK_POPULATION
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, assistant, unassigned)
	TEST_ASSERT(unlock_rule.revoking, "Latejoin over the crew limit didn't start grace")
	TEST_ASSERT(ACCESS_CREMATORIUM in old_card.GetAccess(), "Unassigned arrival ended access for everyone")

/// Checks only head and acting head access can edit IDs
/datum/unit_test/job_access/authority

/datum/unit_test/job_access/authority/Run()
	var/datum/job/engineer = SSjob.get_job(JOB_NAME_STATIONENGINEER)
	var/datum/job/chief = SSjob.get_job(JOB_NAME_CHIEFENGINEER)
	set_positions(JOB_NAME_CHIEFENGINEER, 0)
	SSjob.refresh_skeleton_access()

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.assign_job(engineer)
	var/datum/computer_file/program/card_mod/program = allocate(/datum/computer_file/program/card_mod)
	TEST_ASSERT(ACCESS_CE in card.GetAccess(), "Engineer missing CE access with no CE")
	TEST_ASSERT(!program.authenticate(null, card), "Skeleton access can edit IDs")

	card.grant_temporary_access(list(ACCESS_CE), "unit test")
	TEST_ASSERT(!program.authenticate(null, card), "Console grant can edit IDs")

	card.grant_acting_head(chief, "unit test")
	TEST_ASSERT(program.authenticate(null, card), "Acting CE can't edit IDs")
	card.acting_head.revoke()

/// Checks ID console pay changes need head authority over the department
/datum/unit_test/job_access/console_pay_authority

/datum/unit_test/job_access/console_pay_authority/Run()
	var/obj/machinery/computer/card/console = allocate(/obj/machinery/computer/card)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_HEADS)
	console.inserted_scan_id = card
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Bridge access can change pay")

	card.grant_temporary_access(list(ACCESS_HOP), "unit test")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Console grant can change pay")

	card.access |= ACCESS_HOP
	TEST_ASSERT(console.can_manage_pay(ACCOUNT_SRV_ID), "HoP can't change service pay")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SEC_ID), "HoP can change security pay")

	console.inserted_scan_id = null
	console.authenticated = 1
	console.accessible_dept_payment_bitflag = ACCOUNT_SEC_BITFLAG
	TEST_ASSERT(console.can_manage_pay(ACCOUNT_SEC_ID), "Logged in HoS can't change security pay")
	TEST_ASSERT(!console.can_manage_pay(ACCOUNT_SRV_ID), "Logged in HoS can change service pay")
