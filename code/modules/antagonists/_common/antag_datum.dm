GLOBAL_LIST_EMPTY(antagonists)
GLOBAL_LIST(admin_antag_list)

/datum/antagonist
	var/tips
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"				//Section of roundend report, datums with same category will be displayed together, also default header for the section
	var/show_in_roundend = TRUE								//Set to false to hide the antagonists from roundend report
	var/prevent_roundtype_conversion = TRUE		//If false, the roundtype will still convert with this antag active
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	/// The ROLE_X key used for this antagonist.
	var/banning_key
	/// Required living playtime to be included in the rolling for this antagonist
	var/required_living_playtime = 0
	var/give_objectives = TRUE //Should the default objectives be generated?
	var/replace_banned = TRUE //Should replace jobbanned player with ghosts if granted.
	var/list/objectives = list()
	var/delay_roundend = TRUE
	var/antag_memory = ""//These will be removed with antag datum
	var/antag_moodlet //typepath of moodlet that the mob will gain with their status
	var/ui_name = "AntagInfoGeneric"

	var/can_elimination_hijack = ELIMINATION_NEUTRAL //If these antags are alone when a shuttle elimination happens.
	/// If above 0, this is the multiplier for the speed at which we hijack the shuttle. Do not directly read, use hijack_speed().
	var/hijack_speed = 0
	var/count_against_dynamic_roll_chance = TRUE
	//Antag panel properties
	var/show_in_antagpanel = TRUE	//This will hide adding this antag type in antag panel, use only for internal subtypes that shouldn't be added directly but still show if possessed by mind
	var/antagpanel_category = "Uncategorized"	//Antagpanel will display these together, REQUIRED
	var/show_name_in_check_antagonists = FALSE //Will append antagonist name in admin listings - use for categories that share more than one antag type
	var/show_to_ghosts = FALSE // Should this antagonist be shown as antag to ghosts? Shouldn't be used for stealthy antagonists like traitors

	/// Weakref to button to access antag interface
	var/datum/weakref/info_button_ref

/datum/antagonist/proc/show_tips(fileid)
	if(!owner || !owner.current || !owner.current.client)
		return
	var/datum/asset/stuff = get_asset_datum(/datum/asset/simple/bee_antags)
	stuff.send(owner.current.client)
	var/datum/browser/popup = new(owner.current, "antagTips", null, 600, 400)
	popup.set_window_options("titlebar=1;can_minimize=0;can_resize=0")
	//Replaces traitor.png with the appropriate hashed url
	popup.set_content(replacetext(rustg_file_read("html/antagtips/[html_encode(fileid)].html"), regex("\\w*.png", "gm"), /datum/antagonist/proc/get_asset_url_from))
	popup.open(FALSE)

/datum/antagonist/proc/get_asset_url_from(match)
	return SSassets.transport.get_asset_url(match)

/datum/antagonist/New()
	GLOB.antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

//This will be called in add_antag_datum before owner assignment.
//Should return antag datum without owner.
/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

///Called by the transfer_to() mind proc after the mind (mind.current and new_character.mind) has moved but before the player (key and client) is transfered.
/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	SHOULD_CALL_PARENT(TRUE)
	remove_innate_effects(old_body)
	if(old_body.stat != DEAD && !LAZYLEN(old_body.mind?.antag_datums))
		old_body.remove_from_current_living_antags()
	var/datum/action/antag_info/info_button = info_button_ref?.resolve()
	if(info_button)
		info_button.Remove(old_body)
		info_button.Grant(new_body)
	apply_innate_effects(new_body)
	if(count_against_dynamic_roll_chance && new_body.stat != DEAD)
		new_body.add_to_current_living_antags()

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	return

//Assign default team and creates one for one of a kind team antagonists
/datum/antagonist/proc/create_team(datum/team/team)
	return

///Called by the add_antag_datum() mind proc after the instanced datum is added to the mind's antag_datums list.
/datum/antagonist/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		CRASH("[src] ran on_gain() without a mind")
	if(!owner.current)
		CRASH("[src] ran on_gain() on a mind without a mob")
	var/datum/action/antag_info/info_button = make_info_button()
	if(!silent)
		if(tips)
			show_tips(tips)
		if(ui_name)
			to_chat(owner.current, "<span class='boldnotice'>For more info, read the panel. \
				You can always come back to it using the button in the top left.</span>")
			info_button?.Trigger()
	greet()
	apply_innate_effects()
	give_antag_moodies()
	if(is_banned(owner.current) && replace_banned)
		replace_banned_player()
	else if(owner.current.client?.holder && (CONFIG_GET(flag/auto_deadmin_antagonists) || owner.current.client.prefs?.toggles & PREFTOGGLE_DEADMIN_ANTAGONIST))
		owner.current.client.holder.auto_deadmin()
	if(count_against_dynamic_roll_chance && owner.current.stat != DEAD && owner.current.client)
		owner.current.add_to_current_living_antags()

//in the future, this should entirely replace greet.
/datum/antagonist/proc/make_info_button()
	if(!ui_name)
		return
	var/datum/action/antag_info/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/antagonist/proc/is_banned(mob/M)
	if(!M)
		return FALSE
	. = (is_banned_from(M.ckey, banning_key) || QDELETED(M))

/datum/antagonist/proc/replace_banned_player()
	set waitfor = FALSE

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [name]?", banning_key, null, 7.5 SECONDS, owner.current, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(owner)]) to replace a jobbanned player.")
		owner.current.ghostize(FALSE)
		owner.current.key = C.key
	else
		owner.current.playable_bantype = banning_key
		owner.current.ghostize(FALSE,SENTIENCE_FORCE)

///Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/proc/on_removal()
	SHOULD_CALL_PARENT(TRUE)
	remove_innate_effects()
	clear_antag_moodies()
	if(info_button_ref)
		QDEL_NULL(info_button_ref)
	if(owner)
		LAZYREMOVE(owner.antag_datums, src)
		if(!LAZYLEN(owner.antag_datums))
			owner.current.remove_from_current_living_antags()
		if(!silent && owner.current)
			farewell()
	var/datum/team/team = get_team()
	if(team)
		team.remove_member(owner)
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return

/// gets antag name for orbit category. Reasoning is described in each subtype
/datum/antagonist/proc/get_antag_name()
	return name

/datum/antagonist/proc/give_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "antag_moodlet", antag_moodlet)

/datum/antagonist/proc/clear_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "antag_moodlet")

//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return

//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/proc/roundend_report_header()
	return 	"<span class='header'>The [roundend_category] were:</span><br>"

//Displayed at the end of roundend_category section
/datum/antagonist/proc/roundend_report_footer()
	return

///ANTAGONIST UI STUFF

/datum/antagonist/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name, name)
		ui.open()

/datum/antagonist/ui_state(mob/user)
	return GLOB.always_state

///generic helper to send objectives as data through tgui.
/datum/antagonist/proc/get_objectives()
	var/objective_count = 1
	var/list/objective_data = list()
	//all obj
	for(var/datum/objective/objective in objectives)
		objective_data += list(list(
			"count" = objective_count,
			"name" = objective.name,
			"explanation" = objective.explanation_text,
			"complete" = objective.completed,
			"optional" = objective.optional,
		))
		objective_count++
	return objective_data

/datum/antagonist/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bee_antags),
	)

//ADMIN TOOLS

//Called when using admin tools to give antag status
/datum/antagonist/proc/admin_add(datum/mind/new_owner,mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

//Called when removing antagonist using admin tools
/datum/antagonist/proc/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

//gamemode/proc/is_mode_antag(antagonist/A) => TRUE/FALSE

//Additional data to display in antagonist panel section
//nuke disk code, genome count, etc
/datum/antagonist/proc/antag_panel_data()
	return ""

// List if ["Command"] = CALLBACK(), user will be appeneded to callback arguments on execution
/datum/antagonist/proc/get_admin_commands()
	. = list()

/datum/antagonist/Topic(href,href_list)
	if(!check_rights(R_ADMIN))
		return
	//Antag memory edit
	if (href_list["memory_edit"])
		edit_memory(usr)
		owner.traitor_panel()
		return

	//Some commands might delete/modify this datum clearing or changing owner
	var/datum/mind/persistent_owner = owner

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			persistent_owner.traitor_panel()
			return

/datum/antagonist/proc/edit_memory(mob/user)
	var/new_memo = stripped_multiline_input(user, "Write new memory", "Memory", antag_memory, MAX_MESSAGE_LEN)
	if (isnull(new_memo))
		return
	antag_memory = new_memo

/// Gets how fast we can hijack the shuttle, return 0 for can not hijack. Defaults to hijack_speed var, override for custom stuff like buffing hijack speed for hijack objectives or something.
/datum/antagonist/proc/hijack_speed()
	var/datum/objective/hijack/H = locate() in objectives
	return H?.hijack_speed_override || hijack_speed

//This one is created by admin tools for custom objectives
/datum/antagonist/custom
	antagpanel_category = "Custom"
	show_name_in_check_antagonists = TRUE //They're all different
	var/datum/team/custom_team

/datum/antagonist/custom/create_team(datum/team/team)
	custom_team = team

/datum/antagonist/custom/get_team()
	return custom_team

/datum/antagonist/custom/admin_add(datum/mind/new_owner,mob/admin)
	var/custom_name = stripped_input(admin, "Custom antagonist name:", "Custom antag", "Antagonist")
	if(custom_name)
		name = custom_name
	else
		return
	..()

/proc/generate_admin_antag_list()
	GLOB.admin_antag_list = list()

	var/list/allowed_types = list(
		/datum/antagonist/traitor,
		/datum/antagonist/blob,
		/datum/antagonist/changeling,
		/datum/antagonist/devil,
		/datum/antagonist/ninja,
		/datum/antagonist/nukeop,
		/datum/antagonist/wizard,
	)

	for(var/T in allowed_types)
		var/datum/antagonist/A = T
		GLOB.admin_antag_list[initial(A.name)] = T

// Adds the specified antag hud to the player. Usually called in an antag datum file
/datum/antagonist/proc/add_antag_hud(antag_hud_type, antag_hud_name, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(mob_override)
	set_antag_hud(mob_override, antag_hud_name)


// Removes the specified antag hud from the player. Usually called in an antag datum file
/datum/antagonist/proc/remove_antag_hud(antag_hud_type, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(mob_override)
	set_antag_hud(mob_override, null)

// Handles adding and removing the clumsy mutation from clown antags. Gets called in apply/remove_innate_effects
/datum/antagonist/proc/handle_clown_mutation(mob/living/mob_override, message, removing = TRUE)
	var/mob/living/carbon/C = mob_override
	if(C && istype(C) && C.has_dna() && owner.assigned_role == JOB_NAME_CLOWN)
		if(removing) // They're a clown becoming an antag, remove clumsy
			C.dna.remove_mutation(CLOWNMUT)
			if(!silent && message)
				to_chat(C, "<span class='boldnotice'>[message]</span>")
		else
			C.dna.add_mutation(CLOWNMUT) // We're removing their antag status, add back clumsy

//button for antags to review their descriptions/info
/datum/action/antag_info
	name = "Open Special Role Information:"
	button_icon_state = "round_end"

/datum/action/antag_info/New(Target)
	. = ..()
	name = "Open [target] Information"

/datum/action/antag_info/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	target.ui_interact(owner)

/datum/action/antag_info/IsAvailable(feedback = FALSE)
	if(!target)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind || !(target in owner.mind.antag_datums))
		return FALSE
	return TRUE
