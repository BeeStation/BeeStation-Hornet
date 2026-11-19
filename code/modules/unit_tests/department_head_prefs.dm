/// Heads of staff must be their own department head in the job preferences menu,
/// otherwise the TGUI job list won't highlight them / sort them to the top of their department.
/datum/unit_test/department_head_prefs

/datum/unit_test/department_head_prefs/Run()
	var/list/heads = list(
		/datum/job/chief_engineer,
		/datum/job/chief_medical_officer,
		/datum/job/research_director,
		/datum/job/head_of_security,
		/datum/job/quartermaster,
	)

	for (var/head_type in heads)
		var/datum/job/job = SSjob.get_job_type(head_type)
		TEST_ASSERT_NOTNULL(job, "Could not find job [head_type]")
		TEST_ASSERT_EQUAL(job.department_head_for_prefs, job.title, "[job.title] must set department_head_for_prefs to its own title so it is highlighted in the job preferences menu.")
