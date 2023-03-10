GLOBAL_LIST(admin_objective_list) //Prefilled admin assignable objective list

/datum/objective
	var/datum/mind/owner				//The primary owner of the objective. !!SOMEWHAT DEPRECATED!! Prefer using 'team' for new code.
	var/datum/team/team					//An alternative to 'owner': a team. Use this when writing new code.
	var/name = "generic objective" 		//Name for admin prompts
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/team_explanation_text			//For when there are multiple owners.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.
	var/martyr_compatible = 0			//If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	var/optional = FALSE				//Whether the objective should show up as optional in the roundend screen
	var/murderbone_flag = FALSE			//Used to check if obj owner can buy murderbone stuff

/datum/objective/New(var/text)
	if(text)
		explanation_text = text

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	set_target(null)
	if(team)
		team.objectives -= src
	for(var/datum/mind/own as() in get_owners())
		for(var/datum/antagonist/A as() in own.antag_datums)
			A.objectives -= src
		own.crew_objectives -= src
	return ..()

/datum/objective/proc/get_owners() // Combine owner and team into a single list.
	. = (team && team.members) ? team.members.Copy() : list()
	if(owner)
		. += owner

/datum/objective/proc/admin_edit(mob/admin)
	return

//Shared by few objective types
/datum/objective/proc/admin_simple_target_pick(mob/admin)
	var/list/possible_targets = list()
	var/def_value
	for(var/datum/mind/possible_target as() in SSticker.minds)
		if ((possible_target != src) && ishuman(possible_target.current))
			possible_targets += possible_target.current


	if(target?.current)
		def_value = target.current

	var/mob/new_target = input(admin,"Select target:", "Objective target", def_value) as null|anything in (sortNames(possible_targets) | list("Free objective","Random"))
	if (!new_target)
		return

	if (new_target == "Free objective")
		set_target(null)
	else if (new_target == "Random")
		find_target()
	else
		set_target(new_target.mind)

	update_explanation_text()

/datum/objective/proc/considered_escaped(datum/mind/M)
	if(!considered_alive(M))
		return FALSE
	if(M.force_escaped)
		return TRUE
	if(SSticker.force_ending || SSticker.mode.station_was_nuked) // Just let them win.
		return TRUE
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/turf/location = get_turf(M.current)
	if(!location || istype(location, /turf/open/floor/plasteel/shuttle/red) || istype(location, /turf/open/floor/mineral/plastitanium/red/brig)) // Fails if they are in the shuttle brig
		return FALSE
	return location.onCentCom() || location.onSyndieBase()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/is_unique_objective(datum/mind/possible_target, list/dupe_search_range)
	if(!islist(dupe_search_range))
		stack_trace("Non-list passed as duplicate objective search range")
		dupe_search_range = list(dupe_search_range)

	for(var/A in dupe_search_range)
		var/list/objectives_to_compare
		if(istype(A,/datum/mind))
			var/datum/mind/M = A
			objectives_to_compare = M.get_all_objectives()
		else if(istype(A,/datum/antagonist))
			var/datum/antagonist/G = A
			objectives_to_compare = G.objectives
		else if(istype(A,/datum/team))
			var/datum/team/T = A
			objectives_to_compare = T.objectives
		for(var/datum/objective/O as() in objectives_to_compare)
			if(istype(O, type) && O.get_target() == possible_target)
				return FALSE
	return TRUE

/datum/objective/proc/get_target()
	return target

/datum/objective/proc/set_target(datum/mind/new_target)
	if(target)
		UnregisterSignal(target, COMSIG_MIND_CRYOED)
	target = new_target
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_CRYOED, PROC_REF(on_target_cryo))
		target.isAntagTarget = TRUE

/datum/objective/proc/unset_target()
	if(target)
		UnregisterSignal(target, COMSIG_MIND_CRYOED)
		target = null

/datum/objective/proc/get_crewmember_minds()
	. = list()
	for(var/datum/data/record/R as() in GLOB.data_core.locked)
		var/datum/mind/M = R.fields["mindref"]
		if(M)
			. += M

//dupe_search_range is a list of antag datums / minds / teams
/datum/objective/proc/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/preferred_targets = list()
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	var/owner_is_exploration_crew = FALSE
	var/owner_is_shaft_miner = FALSE
	for(var/datum/mind/O as() in get_owners())
		if(O.late_joiner)
			try_target_late_joiners = TRUE
		if(O.assigned_role == JOB_NAME_EXPLORATIONCREW)
			owner_is_exploration_crew = TRUE
		if(O.assigned_role == JOB_NAME_SHAFTMINER)
			owner_is_shaft_miner = TRUE
	for(var/datum/mind/possible_target as() in get_crewmember_minds())
		if(!is_valid_target(possible_target))
			continue
		if(!is_unique_objective(possible_target,dupe_search_range))
			continue
		if(possible_target in blacklist)
			continue

		if(possible_target.assigned_role == JOB_NAME_EXPLORATIONCREW)
			if(owner_is_exploration_crew)
				preferred_targets += possible_target
			else
				//Reduced chance to get people off station
				if(prob(70) && !owner_is_shaft_miner)
					continue
		else if(possible_target.assigned_role == JOB_NAME_SHAFTMINER)
			if(owner_is_shaft_miner)
				preferred_targets += possible_target
			else
				//Reduced chance to get people off station
				if(prob(70) && !owner_is_exploration_crew)
					continue

		possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/PT as() in all_possible_targets)
			if(!PT.late_joiner)
				possible_targets -= PT
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	//30% chance to go for a preferred target
	if(preferred_targets.len > 0 && prob(30))
		set_target(pick(preferred_targets))
	else if(possible_targets.len > 0)
		set_target(pick(possible_targets))
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/proc/is_valid_target(datum/mind/possible_target)
	if(possible_target in get_owners())
		return FALSE
	if(!ishuman(possible_target.current))
		return FALSE
	if(possible_target.current.stat == DEAD)
		return FALSE
	var/target_area = get_area(possible_target.current)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(target_area, /area/shuttle/arrival))
		return FALSE
	return TRUE

/datum/objective/proc/find_target_by_role(role, role_type=FALSE,invert=FALSE)//Option sets either to check assigned role or special role. Default to assigned., invert inverts the check, eg: "Don't choose a Ling"
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as() in get_crewmember_minds())
		if(is_valid_target(possible_target))
			var/is_role = FALSE
			if(role_type)
				if(possible_target.special_role == role)
					is_role = TRUE
			else
				if(possible_target.assigned_role == role)
					is_role = TRUE
			if(is_role && !invert || !is_role && invert)
				possible_targets += possible_target
	if(length(possible_targets))
		set_target(pick(possible_targets))
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/proc/update_explanation_text()
	if(team_explanation_text && LAZYLEN(get_owners()) > 1)
		explanation_text = team_explanation_text

/datum/objective/proc/give_special_equipment(list/special_equipment)
	var/datum/mind/receiver = pick(get_owners())
	if(receiver && receiver.current)
		if(ishuman(receiver.current))
			var/mob/living/carbon/human/H = receiver.current
			var/static/list/slots = list(
				"backpack" = ITEM_SLOT_BACKPACK,
				"left pocket" = ITEM_SLOT_LPOCKET,
				"right pocket" = ITEM_SLOT_RPOCKET,
				"hands" = ITEM_SLOT_HANDS)
			for(var/eq_path in special_equipment)
				var/obj/O = new eq_path(get_turf(receiver.current))
				H.equip_in_one_of_slots(O, slots)

/datum/objective/proc/on_target_cryo()
	SIGNAL_HANDLER

	find_target(null, list(target))
	if(!target)
		if(team)
			team.objectives -= src
		for(var/datum/mind/own as() in get_owners())
			for(var/datum/antagonist/A as() in own.antag_datums)
				A.objectives -= src
			own.crew_objectives -= src

			to_chat(own.current, "<BR><span class='userdanger'>Your target is no longer within reach. Objective removed!</span>")
			own.announce_objectives()
		qdel(src)
	else
		update_explanation_text()
		for(var/datum/mind/own as() in get_owners())
			to_chat(own.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
			own.announce_objectives()

/datum/objective/assassinate
	name = "assasinate"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/assassinate/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/assassinate/check_completion()
	return ..() || (!considered_alive(target) || considered_afk(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/assassinate/incursion
	name = "eliminate"

/datum/objective/assassinate/incursion/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "[target.name], the [!target_role_type ? target.assigned_role : target.special_role] has been declared an ex-communicate of the syndicate. Eliminate them."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/internal
	var/stolen = 0 		//Have we already eliminated this target?

/datum/objective/assassinate/internal/update_explanation_text()
	..()
	if(target && !target.current)
		explanation_text = "Assassinate [target.name], who was obliterated"

/datum/objective/mutiny
	name = "mutiny"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/mutiny/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/mutiny/check_completion()
	if(!target || !considered_alive(target) || considered_afk(target))
		return TRUE
	var/turf/T = get_turf(target.current)
	return ..() || !T || !is_station_level(T.z)

/datum/objective/mutiny/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Assassinate or exile [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/mutiny/on_target_cryo()
	set_target(null)
	team.objectives -= src
	for(var/datum/mind/M as() in team.members)
		var/datum/antagonist/rev/R = M.has_antag_datum(/datum/antagonist/rev)
		if(R)
			R.objectives -= src
			to_chat(M.current, "<BR><span class='userdanger'>Your target is no longer within reach. Objective removed!</span>")
			M.announce_objectives()
	qdel(src)

/datum/objective/maroon
	name = "maroon"
	var/target_role_type=FALSE
	martyr_compatible = 1

/datum/objective/maroon/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/maroon/check_completion()
	return ..() || !target || !considered_alive(target) || (!target.current.onCentCom() && !target.current.onSyndieBase())

/datum/objective/maroon/update_explanation_text()
	if(target && target.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role : target.special_role], from escaping alive."
	else
		explanation_text = "Free Objective"

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/debrain
	name = "debrain"
	var/target_role_type=0

/datum/objective/debrain/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return TRUE
	if(!target.current || !isbrain(target.current))
		return ..()
	var/atom/A = target.current

	while(A.loc) // Check to see if the brainmob is on our person
		A = A.loc
		for(var/datum/mind/M as() in get_owners())
			if(M.current && M.current.stat != DEAD && A == M.current)
				return TRUE
	return ..()

/datum/objective/debrain/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/debrain/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/protect//The opposite of killing a dude.
	name = "protect"
	martyr_compatible = 1
	var/target_role_type = FALSE
	var/human_check = TRUE

/datum/objective/protect/find_target_by_role(role, role_type=FALSE,invert=FALSE)
	if(!invert)
		target_role_type = role_type
	..()

/datum/objective/protect/check_completion()
	var/obj/item/organ/brain/brain_target
	if(human_check)
		brain_target = target?.current.getorganslot(ORGAN_SLOT_BRAIN)
	if(..() || !target)
		return TRUE
	if(considered_alive(target, enforce_human = human_check))
		return TRUE
	//Protect will always suceed when someone suicides
	return (human_check && brain_target) ? brain_target.suicided : FALSE

/datum/objective/protect/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"

/datum/objective/protect/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/protect/nonhuman
	name = "protect nonhuman"
	human_check = FALSE

/datum/objective/hijack
	name = "hijack"
	explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols using the shuttle computer."
	team_explanation_text = "Hijack the emergency shuttle by overriding the navigation protocols, using the shuttle computer. Leave no team member behind."
	martyr_compatible = FALSE //Technically you won't get both anyway.
	/// Overrides the hijack speed of any antagonist datum it is on ONLY, no other datums are impacted.
	var/hijack_speed_override = 1
	murderbone_flag = TRUE

/datum/objective/hijack/check_completion() // Requires all owners to escape.
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.is_hijacked() || ..()

/datum/objective/gimmick
	name = "gimmick"
	martyr_compatible = TRUE
	optional = TRUE

/datum/objective/gimmick/update_explanation_text()
	var/selected_department = pick(list( //Select a department for department-based objectives
		DEPT_SCIENCE,
		DEPT_ENGINEERING,
		DEPT_SECURITY,
		DEPT_MEDICAL,
		DEPT_SERVICE,
		DEPT_SUPPLY,
		DEPT_COMMAND
	))

	var/list/gimmick_list = world.file2list(GIMMICK_OBJ_FILE) //gimmick_objectives.txt is for objectives without a specific target/department/etc
	gimmick_list.Add(world.file2list(DEPT_GIMMICK_OBJ_FILE))
	if(target?.current)
		gimmick_list.Add(world.file2list(TARGET_GIMMICK_OBJ_FILE))

	var/selected_gimmick = pick(gimmick_list)
	selected_gimmick = replacetext(selected_gimmick, "%DEPARTMENT", selected_department)
	if(!findtext(selected_gimmick, "%TARGET"))
		unset_target()
	if(target?.current)
		selected_gimmick = replacetext(selected_gimmick, "%TARGET", target.name)

	explanation_text = "[selected_gimmick]"

/datum/objective/gimmick/check_completion()
	return TRUE

/datum/objective/gimmick/admin_edit(mob/admin)
	update_explanation_text()

/datum/objective/elimination
	name = "elimination"
	explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle."
	team_explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle. Leave no team member behind."
	martyr_compatible = FALSE
	murderbone_flag = TRUE

/datum/objective/elimination/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.elimination_hijack() || ..()

/datum/objective/elimination/highlander
	name="highlander elimination"
	explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."

/datum/objective/elimination/highlander/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return ..()
	return SSshuttle.emergency.elimination_hijack(filter_by_human = FALSE, solo_hijack = TRUE) || ..()

/datum/objective/block
	name = "no organics on shuttle"
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."
	martyr_compatible = 1
	murderbone_flag = TRUE

/datum/objective/block/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind && player.stat != DEAD && !issilicon(player))
			if(get_area(player) in SSshuttle.emergency.shuttle_areas)
				return ..()
	return TRUE

/datum/objective/purge
	name = "no mutants on shuttle"
	explanation_text = "Ensure no mutant humanoid species are present aboard the escape shuttle."
	martyr_compatible = 1

/datum/objective/purge/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if((get_area(player) in SSshuttle.emergency.shuttle_areas) && player.mind && player.stat != DEAD && ishuman(player))
			var/mob/living/carbon/human/H = player
			if(H.dna.species.id != SPECIES_HUMAN)
				return ..()
	return TRUE

/datum/objective/robot_army
	name = "robot army"
	explanation_text = "Have at least eight active cyborgs synced to you."
	martyr_compatible = 0

/datum/objective/robot_army/check_completion()
	var/counter = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M.current || !isAI(M.current))
			continue
		var/mob/living/silicon/ai/A = M.current
		for(var/mob/living/silicon/robot/R as() in A.connected_robots)
			if(R.stat != DEAD)
				counter++
	return (counter >= 8) || ..()

/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/escape/check_completion()
	// Require all owners escape safely.
	for(var/datum/mind/M as() in get_owners())
		if(!considered_escaped(M))
			return ..()
	return TRUE

/datum/objective/escape/single
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have at least one of your members escape on the shuttle or escape pod alive and without being in custody."

/datum/objective/escape/single/check_completion()
	// Require all owners escape safely.
	for(var/datum/mind/M as() in get_owners())
		if(considered_escaped(M))
			return TRUE
	return ..()

/datum/objective/escape/escape_with_identity
	name = "escape with identity"
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round
	var/target_missing_id

/datum/objective/escape/escape_with_identity/is_valid_target(datum/mind/possible_target)
	for(var/datum/mind/M as() in get_owners())
		var/datum/antagonist/changeling/C = M.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			continue
		var/datum/mind/T = possible_target
		if(!istype(T) || !C.can_absorb_dna(T.current, verbose=FALSE))
			return FALSE
	return ..()

/datum/objective/escape/escape_with_identity/update_explanation_text()
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role]"
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(H && H.get_id_name() != target_real_name)
			target_missing_id = 1
		else
			explanation_text += " while wearing their identification card"
		explanation_text += "." //Proper punctuation is important!
	else
		explanation_text = "Free Objective."

/datum/objective/escape/escape_with_identity/check_completion()
	if(!target || !target_real_name)
		return TRUE
	for(var/datum/mind/M as() in get_owners())
		if(!ishuman(M.current) || !considered_escaped(M))
			continue
		var/mob/living/carbon/human/H = M.current
		if(H.dna.real_name == target_real_name && (H.get_id_name() == target_real_name || target_missing_id))
			return TRUE
	return ..()

/datum/objective/escape/escape_with_identity/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/survive
	name = "survive"
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M))
			return ..()
	return TRUE

/datum/objective/survive/exist //Like survive, but works for silicons and zombies and such.
	name = "survive nonhuman"

/datum/objective/survive/exist/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!considered_alive(M, FALSE))
			return ..()
	return TRUE

/datum/objective/martyr
	name = "martyr"
	explanation_text = "Die a glorious death."
	murderbone_flag = TRUE

/datum/objective/martyr/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(considered_alive(M))
			return ..()
		if(M.current?.suiciding) //killing yourself ISN'T glorious.
			return ..()
	return TRUE

/datum/objective/nuclear
	name = "nuclear"
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = 1
	murderbone_flag = TRUE

/datum/objective/nuclear/check_completion()
	if(SSticker && SSticker.mode && SSticker.mode.station_was_nuked)
		return TRUE
	return ..()

GLOBAL_LIST_EMPTY(possible_items)
/datum/objective/steal
	name = "steal"
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).
	martyr_compatible = 0

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/New()
	..()
	if(!GLOB.possible_items.len)//Only need to fill the list when it's needed.
		for(var/I in subtypesof(/datum/objective_item/steal))
			new I

/datum/objective/steal/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	check_items:
		for(var/datum/objective_item/possible_item in GLOB.possible_items)
			if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
				continue
			for(var/datum/mind/M as() in get_owners())
				if(M.current.mind.assigned_role in possible_item.excludefromjob)
					continue check_items
			approved_targets += possible_item
	return set_steal_target(safepick(approved_targets))

/datum/objective/steal/proc/set_steal_target(datum/objective_item/item)
	if(item)
		targetinfo = item
		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]"
		give_special_equipment(targetinfo.special_equipment)
		return steal_target
	else
		explanation_text = "Free objective"
		return

/datum/objective/steal/admin_edit(mob/admin)
	var/list/possible_items_all = GLOB.possible_items
	var/new_target = input(admin,"Select target:", "Objective target", steal_target) as null|anything in sortNames(possible_items_all)+"custom"
	if (!new_target)
		return

	if (new_target == "custom") //Can set custom items.
		var/custom_path = input(admin,"Search for target item type:","Type") as null|text
		if (!custom_path)
			return
		var/obj/item/custom_target = pick_closest_path(custom_path, make_types_fancy(subtypesof(/obj/item)))
		var/custom_name = initial(custom_target.name)
		custom_name = stripped_input(admin,"Enter target name:", "Objective target", custom_name)
		if (!custom_name)
			return
		steal_target = custom_target
		explanation_text = "Steal [custom_name]."

	else
		set_steal_target(new_target)

/datum/objective/steal/check_completion()
	if(!steal_target)
		return TRUE
	for(var/datum/mind/M as() in get_owners())
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

		for(var/obj/I in all_items) //Check for items
			if(istype(I, steal_target))
				if(!targetinfo) //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
					return TRUE
				else if(targetinfo.check_special_completion(I))//Returns 1 by default. Items with special checks will return 1 if the conditions are fulfilled.
					return TRUE

			if(targetinfo && (I.type in targetinfo.altitems)) //Ok, so you don't have the item. Do you have an alternative, at least?
				if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
					return TRUE
	return ..()

GLOBAL_LIST_EMPTY(possible_items_special)
/datum/objective/steal/special //ninjas are so special they get their own subtype good for them
	name = "steal special"

/datum/objective/steal/special/New()
	..()
	if(!GLOB.possible_items_special.len)
		for(var/I in subtypesof(/datum/objective_item/special) + subtypesof(/datum/objective_item/stack))
			new I

/datum/objective/steal/special/find_target(list/dupe_search_range, list/blacklist)
	return set_steal_target(pick(GLOB.possible_items_special))

/datum/objective/steal/exchange
	name = "exchange"
	martyr_compatible = 0

/datum/objective/steal/exchange/admin_edit(mob/admin)
	return

/datum/objective/steal/exchange/proc/set_faction(faction, datum/mind/otheragent)
	set_target(otheragent)
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_blue
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_red
	explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
	steal_target = targetinfo.targetitem


/datum/objective/steal/exchange/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Acquire [targetinfo.name] held by [target.name], the [target.assigned_role] and syndicate agent"
	else
		explanation_text = "Free Objective"


/datum/objective/steal/exchange/backstab
	name = "prevent exchange"

/datum/objective/steal/exchange/backstab/set_faction(faction)
	if(faction == "red")
		targetinfo = new/datum/objective_item/unique/docs_red
	else if(faction == "blue")
		targetinfo = new/datum/objective_item/unique/docs_blue
	explanation_text = "Do not give up or lose [targetinfo.name]."
	steal_target = targetinfo.targetitem


/datum/objective/download
	name = "download"

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(20,40)
	update_explanation_text()
	return target_amount

/datum/objective/download/update_explanation_text()
	..()
	explanation_text = "Download [target_amount] research node\s."

/datum/objective/download/check_completion()
	var/datum/techweb/checking = new
	for(var/datum/mind/owner as() in get_owners())
		if(ismob(owner.current))
			var/mob/M = owner.current			//Yeah if you get morphed and you eat a quantum tech disk with the RD's latest backup good on you soldier.
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H && (H.stat != DEAD) && istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
					var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
					S.stored_research.copy_research_to(checking)
			var/list/otherwise = M.GetAllContents()
			for(var/obj/item/disk/tech_disk/TD in otherwise)
				TD.stored_research.copy_research_to(checking)
	return (checking.researched_nodes.len >= target_amount) || ..()

/datum/objective/download/admin_edit(mob/admin)
	var/count = input(admin,"How many nodes ?","Nodes",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/capture
	name = "capture"

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	update_explanation_text()
	return target_amount

/datum/objective/capture/update_explanation_text()
	. = ..()
	explanation_text = "Capture [target_amount] lifeform\s with an energy net. Live, rare specimens are worth more."

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = GLOB.areas_by_type[/area/centcom/holding]
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat == DEAD)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat == DEAD)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(istype(M, /mob/living/carbon/alien/humanoid/royal/queen))//Queens are worth three times as much as humans.
			if(M.stat == DEAD)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat == DEAD)
			captured_amount+=1
			continue
		captured_amount+=2
	return (captured_amount >= target_amount) || ..()

/datum/objective/capture/admin_edit(mob/admin)
	var/count = input(admin,"How many mobs to capture ?","capture",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/protect_object
	name = "protect object"
	var/obj/protect_target

/datum/objective/protect_object/proc/set_protect_target(obj/O)
	protect_target = O
	update_explanation_text()

/datum/objective/protect_object/update_explanation_text()
	. = ..()
	if(protect_target)
		explanation_text = "Protect \the [protect_target] at all costs."
	else
		explanation_text = "Free objective."

/datum/objective/protect_object/check_completion()
	return !QDELETED(protect_target) || ..()

//Changeling Objectives

/datum/objective/absorb
	name = "absorb"

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	var/list/datum/mind/owners = get_owners()
	if (SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/dead/new_player/P in GLOB.player_list)
			if(P.client && P.ready == PLAYER_READY_TO_PLAY && !(P.mind in owners))
				n_p ++
	else if (SSticker.IsRoundInProgress())
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(P.client && !(P.mind.has_antag_datum(/datum/antagonist/changeling)) && !(P.mind in owners))
				n_p ++
	target_amount = min(target_amount, n_p)

	update_explanation_text()
	return target_amount

/datum/objective/absorb/update_explanation_text()
	. = ..()
	explanation_text = "Extract [target_amount] compatible genome\s."

/datum/objective/absorb/admin_edit(mob/admin)
	var/count = input(admin,"How many people to absorb?","absorb",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/absorb/check_completion()
	var/absorbedcount = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbedcount += changeling.absorbedcount
	return (absorbedcount >= target_amount) || ..()

/datum/objective/absorb_most
	name = "absorb most"
	explanation_text = "Extract more compatible genomes than any other Changeling."

/datum/objective/absorb_most/check_completion()
	var/absorbedcount = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbedcount += changeling.absorbedcount

	for(var/datum/antagonist/changeling/changeling2 in GLOB.antagonists)
		if(!changeling2.owner || changeling2.owner == owner || !changeling2.stored_profiles || changeling2.absorbedcount < absorbedcount)
			continue
		return ..()
	return TRUE

//Teratoma objective

/datum/objective/chaos
	name = "spread chaos"
	explanation_text = "Spread misery and chaos upon the station."

/datum/objective/chaos/check_completion()
	return TRUE
//End Changeling Objectives

/datum/objective/destroy
	name = "destroy AI"
	martyr_compatible = 1

/datum/objective/destroy/find_target(list/dupe_search_range, list/blacklist)
	var/list/possible_targets = list()
	for(var/mob/living/silicon/ai/A as() in active_ais(TRUE))
		if(A.mind in blacklist)
			continue
		possible_targets += A
	if(possible_targets.len)
		var/mob/living/silicon/ai/target_ai = pick(possible_targets)
		set_target(target_ai.mind)
	else
		set_target(null)
	update_explanation_text()
	return target

/datum/objective/destroy/check_completion()
	if(target && target.current)
		return target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey || ..()//Borgs/brains/AIs count as dead for traitor objectives.
	return TRUE

/datum/objective/destroy/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free Objective"

/datum/objective/destroy/admin_edit(mob/admin)
	var/list/possible_targets = active_ais(1)
	if(possible_targets.len)
		var/mob/new_target = input(admin,"Select target:", "Objective target") as null|anything in sortNames(possible_targets)
		set_target(new_target.mind)
	else
		to_chat(admin, "No active AIs with minds")
	update_explanation_text()

/datum/objective/destroy/internal
	var/stolen = FALSE 		//Have we already eliminated this target?

/datum/objective/steal_five_of_type
	name = "steal five of"
	explanation_text = "Steal at least five items!"
	var/list/wanted_items = list()

/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_five_of_type/check_completion()
	var/stolen_count = 0
	for(var/datum/mind/M as() in get_owners())
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(is_type_in_typecache(I, wanted_items))
				stolen_count++
	return (stolen_count >= 5) || ..()

/datum/objective/steal_five_of_type/summon_guns
	name = "steal guns"
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)

/datum/objective/steal_five_of_type/summon_magic
	name = "steal magic"
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()

/datum/objective/steal_five_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()

/datum/objective/steal_five_of_type/summon_magic/check_completion()
	var/stolen_count = 0
	for(var/datum/mind/M as() in get_owners())
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/book/granter/spell))
				var/obj/item/book/granter/spell/spellbook = I
				if(!spellbook.used || !spellbook.oneuse) //if the book still has powers...
					stolen_count++ //it counts. nice.
			else if(is_type_in_typecache(I, wanted_items))
				stolen_count++
	return (stolen_count >= 5) || ..()

//Created by admin tools
/datum/objective/custom
	name = "custom"

/datum/objective/custom/plus_murderbone
	name = "custom (+murderbone pass)"
	murderbone_flag = TRUE

/datum/objective/custom/admin_edit(mob/admin)
	var/expl = stripped_input(admin, "Custom objective:", "Objective", explanation_text)
	if(expl)
		explanation_text = expl

//Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	GLOB.admin_objective_list = list()

	var/list/allowed_types = sortList(list(
		/datum/objective/assassinate,
		/datum/objective/maroon,
		/datum/objective/debrain,
		/datum/objective/protect,
		/datum/objective/destroy,
		/datum/objective/hijack,
		/datum/objective/gimmick,
		/datum/objective/escape,
		/datum/objective/survive,
		/datum/objective/martyr,
		/datum/objective/steal,
		/datum/objective/download,
		/datum/objective/nuclear,
		/datum/objective/capture,
		/datum/objective/absorb,
		/datum/objective/custom,
		/datum/objective/custom/plus_murderbone
	),GLOBAL_PROC_REF(cmp_typepaths_asc))

	for(var/datum/objective/X as() in allowed_types)
		GLOB.admin_objective_list[initial(X.name)] = X

/datum/objective/contract
	var/payout = 0
	var/payout_bonus = 0
	var/area/dropoff = null

/datum/objective/contract/on_target_cryo()
	set_target(null)
	var/datum/antagonist/traitor/affected_traitor = owner.has_antag_datum(/datum/antagonist/traitor)
	if(!affected_traitor?.contractor_hub)
		return
	var/datum/contractor_hub/hub = affected_traitor.contractor_hub
	for(var/datum/syndicate_contract/affected_contract as() in hub.assigned_contracts)
		if(affected_contract.contract == src)
			affected_contract.generate(hub.assigned_targets)
			hub.assigned_targets.Add(affected_contract.contract.target)
			to_chat(owner.current, "<BR><span class='userdanger'>Contract target out of reach. Contract rerolled.")
			break

// Generate a random valid area on the station that the dropoff will happen.
/datum/objective/contract/proc/generate_dropoff()
	var/found = FALSE
	while (!found)
		var/area/dropoff_area = pick(GLOB.sortedAreas)
		if(dropoff_area && is_station_level(dropoff_area.z) && !dropoff_area.outdoors)
			dropoff = dropoff_area
			found = TRUE

// Check if both the contractor and contract target are at the dropoff point.
/datum/objective/contract/proc/dropoff_check(mob/user, mob/target)
	var/area/user_area = get_area(user)
	var/area/target_area = get_area(target)

	return (istype(user_area, dropoff) && istype(target_area, dropoff))
