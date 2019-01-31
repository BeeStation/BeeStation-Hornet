/*
	Ported from yogs: https://github.com/yogstation13/Yogstation-TG/blob/master/yogstation/code/modules/mob/dead/new_player/new_player.dm
*/

/mob/dead/new_player/LateChoices()
	var/dat = "<div class='notice'>Round Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>"

	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				dat += "<div class='notice red'>The station has been evacuated.</div><br>"
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"

	var/available_job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobUnavailable(job.title, TRUE) == JOB_AVAILABLE)
			available_job_count++;
			break;

	if(!available_job_count)
		dat += "<div class='notice red'>There are currently no open positions!</div>"

	else

	// if(length(SSjob.prioritized_jobs))
	// 	dat += "<div class='notice red'>The station has flagged these jobs as high priority:<br>"
	// 	for(var/datum/job/a in SSjob.prioritized_jobs)
	// 		dat += " [a.title], "
	// 	dat += "</div>"

		dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
		var/list/categorizedJobs = list(
			"Command" = list(jobs = list(), titles = GLOB.command_positions, color = "#aac1ee"),
			"Engineering" = list(jobs = list(), titles = GLOB.engineering_positions, color = "#ffd699"),
			"Supply" = list(jobs = list(), titles = GLOB.supply_positions, color = "#ead4ae"),
			"Miscellaneous" = list(jobs = list(), titles = list(), color = "#ffffff", colBreak = TRUE),
			"Synthetic" = list(jobs = list(), titles = GLOB.nonhuman_positions, color = "#ccffcc"),
			"Service" = list(jobs = list(), titles = GLOB.civilian_positions, color = "#cccccc"),
			"Medical" = list(jobs = list(), titles = GLOB.medical_positions, color = "#99ffe6", colBreak = TRUE),
			"Science" = list(jobs = list(), titles = GLOB.science_positions, color = "#e6b3e6"),
			"Security" = list(jobs = list(), titles = GLOB.security_positions, color = "#ff9999"),
		)
		for(var/datum/job/job in SSjob.occupations)
			if(job && IsJobUnavailable(job.title, TRUE) == JOB_AVAILABLE)
				var/categorized = FALSE
				for(var/jobcat in categorizedJobs)
					var/list/jobs = categorizedJobs[jobcat]["jobs"]
					if(job.title in categorizedJobs[jobcat]["titles"])
						categorized = TRUE
						if(jobcat == "Command")

							if(job.title == "Captain") // Put captain at top of command jobs
								jobs.Insert(1, job)
							else
								jobs += job
						else // Put heads at top of non-command jobs
							if(job.title in GLOB.command_positions)
								jobs.Insert(1, job)
							else
								jobs += job
				if(!categorized)
					categorizedJobs["Miscellaneous"]["jobs"] += job

		dat += "<table><tr><td valign='top'>"
		for(var/jobcat in categorizedJobs)
			if(categorizedJobs[jobcat]["colBreak"])
				dat += "</td><td valign='top'>"
			if(length(categorizedJobs[jobcat]["jobs"]) < 1)
				continue
			var/color = categorizedJobs[jobcat]["color"]
			dat += "<fieldset style='border: 2px solid [color]; display: inline'>"
			dat += "<legend align='center' style='color: [color]'>[jobcat]</legend>"
			for(var/datum/job/job in categorizedJobs[jobcat]["jobs"])
				var/position_class = "otherPosition"
				if(job.title in GLOB.command_positions)
					position_class = "commandPosition"
				if(job in SSjob.prioritized_jobs)
					dat += "<a class='[position_class]' style='display:block;width:170px' href='byond://?src=[REF(src)];SelectedJob=[job.title]'><font color='lime'><b>[job.title] ([job.current_positions])</b></font></a>"
				else
					dat += "<a class='[position_class]' style='display:block;width:170px' href='byond://?src=[REF(src)];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a>"
			dat += "</fieldset><br>"


		dat += "</td></tr></table></center>"
		dat += "</div></div>"

	// Removing the old window method but leaving it here for reference
	//src << browse(dat, "window=latechoices;size=300x640;can_close=1")

	// Added the new browser window method
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 680, 580)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open(FALSE) // 0 is passed to open so that it doesn't use the onclose() proc
