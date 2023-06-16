
/datum/issue_reporter
	var/client/owner

/datum/issue_reporter/New(client/user)
	if (!user)
		terminate_reporter()
		CRASH("Issue reporter created with no client.")
	. = ..()
	owner = user
	ui_interact(user.mob)
	// Clear references to the client
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(terminate_reporter))

/datum/issue_reporter/Destroy(force, ...)
	owner = null
	return ..()

/datum/issue_reporter/ui_state(mob/user)
	return GLOB.always_state

/datum/issue_reporter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IssueReporter")
		ui.open()

/datum/issue_reporter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	// This could result in some horrible exploits if there is another exploit involved
	if (usr.client != owner)
		return
	if (action != "submit")
		return
	var/githuburl = CONFIG_GET(string/githuburl)
	if (!githuburl)
		tgui_alert_async(usr, "The Github URL is not set in the server configuration.", "Configuration Error")
		return
	// This will open on the users own browser.
	var/isRegression = params["isRegression"]
	var/title = params["title"]
	var/expected = params["expected"]
	var/actual = params["actual"]
	var/replicationSteps = params["replicationSteps"]
	var/template_path = CONFIG_GET(string/issue_template)
	var/body = rustg_file_read(template_path)
	if (!body)
		// /Default body
		body = @{"## Occurance Details

**Round Date:** %DATE%

**Round ID:** %ROUNDID%

**Testmerges**:
%TESTMERGES%

## Bug Details

### Expected Behaviour:

%EXPECTED%

### Actual Behaviour:

%ACTUAL%

### Reproduction:

%REPRODUCTION%
"}
	var/servername = CONFIG_GET(string/servername)
	body = replacetext(body, "%DATE%", time2text(world.timeofday,"DD-MM-YYYY hh:mm:ss"))
	body = replacetext(body, "%ROUNDID%", "[GLOB.round_id ? " Round ID: [GLOB.round_id][servername ? " ([servername])" : ""]" : servername]")
	body = replacetext(body, "%EXPECTED%", expected)
	body = replacetext(body, "%ACTUAL%", actual)
	body = replacetext(body, "%REPRODUCTION%", replicationSteps)
	// Fetch testmerge info
	var/testmerge_info = "- None"
	if (length(GLOB.revdata.testmerge))
		var/list/testmerge_line = list()
		for (var/datum/tgs_revision_information/test_merge/tm in GLOB.revdata.testmerge)
			testmerge_line += "- #[tm.number] commit [tm.head_commit]"
		testmerge_info = jointext(testmerge_line, "\n")
	body = replacetext(body, "%TESTMERGES%", testmerge_info)

	var/issue_label = CONFIG_GET(string/default_issue_label)
	var/list/labels = list()
	if (issue_label)
		labels += issue_label
	var/regression_label = CONFIG_GET(string/regression_issue_label)
	if (regression_label && isRegression)
		labels += regression_label
	DIRECT_OUTPUT(owner, link("[githuburl]/issues/new?body=[rustg_url_encode(body)][length(labels) ? "&labels=[rustg_url_encode(jointext(labels, ","))]" : ""]"))

/datum/issue_reporter/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	terminate_reporter()

/datum/issue_reporter/proc/terminate_reporter()
	qdel(src)
