/atom/proc/investigate_log(message, subject)
	if(!message || !subject || SSticker.current_state == GAME_STATE_FINISHED)
		return
	var/F = file("[GLOB.log_directory]/[subject].html")
	var/source = "[src]"

	if(isliving(src))
		var/mob/living/source_mob = src
		source += " ([source_mob.ckey ? source_mob.ckey : "*no key*"])"

	WRITE_FILE(F, "[time_stamp(format = "YYYY-MM-DD hh:mm:ss")] [REF(src)] ([x],[y],[z]) || [src] [message]<br>")

/client/proc/investigate_show()
	set name = "Investigate"
	set category = "Admin"
	if(!holder)
		return

	var/list/investigates = list(
		INVESTIGATE_ATMOS,
		INVESTIGATE_BOTANY,
		INVESTIGATE_CARGO,
		INVESTIGATE_DEATHS,
		INVESTIGATE_ENGINES,
		INVESTIGATE_EXONET,
		INVESTIGATE_GRAVITY,
		INVESTIGATE_HALLUCINATIONS,
		INVESTIGATE_ITEMS,
		INVESTIGATE_NANITES,
		INVESTIGATE_PORTAL,
		INVESTIGATE_PRESENTS,
		INVESTIGATE_RADIATION,
		INVESTIGATE_RECORDS,
		INVESTIGATE_RESEARCH,
		INVESTIGATE_TELESCI,
		INVESTIGATE_TOOLS,
		INVESTIGATE_WIRES,
	)

	var/list/logs_present = list("notes, memos, watchlist")
	var/list/logs_missing = list("---")

	for(var/subject in investigates)
		var/temp_file = file("[GLOB.log_directory]/[subject].html")
		if(fexists(temp_file))
			logs_present += subject
		else
			logs_missing += "[subject] (empty)"

	var/list/combined = sort_list(logs_present) + sort_list(logs_missing)

	var/selected = tgui_input_list(src, "Investigate what?", "Investigation", combined)
	if(isnull(selected))
		return
	if(!(selected in combined) || selected == "---")
		return

	selected = replacetext(selected, " (empty)", "")

	if(selected == "notes, memos, watchlist" && check_rights(R_ADMIN))
		browse_messages()
		return

	var/filepath = "[GLOB.log_directory]/[selected].html"
	var/F = file(filepath)
	if(!fexists(F))
		to_chat(src, span_danger("No [selected] logfile was found."))
		return

	var/datum/browser/browser = new(usr, "investigate[selected]", "Investigation of [selected]", 800, 300)
	browser.set_content(rustg_file_read(filepath))
	browser.open()
