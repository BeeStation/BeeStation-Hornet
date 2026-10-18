#define SUMMON_POSSIBILITIES 3

/datum/objective/sacrifice
	var/sacced = FALSE
	var/icon/sac_image

/datum/objective/sacrifice/proc/make_image()
	var/icon/reshape
	if(target)
		for(var/datum/record/locked/R as anything in GLOB.manifest.locked)
			var/datum/mind/M = R.weakref_mind.resolve()
			if(target == M)
				reshape = R.character_appearance
				break
	if(!reshape)
		reshape = icon('icons/mob/observer.dmi', "ghost", SOUTH)
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	sac_image = reshape

/datum/objective/sacrifice/find_target(list/dupe_search_range, list/blacklist)
	if(!istype(team, /datum/team/cult))
		return
	var/list/target_candidates = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(is_valid_target(possible_target) && !is_convertable_to_cult(possible_target.current) && !(possible_target in blacklist))
			target_candidates += possible_target
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/datum/mind/possible_target in get_crewmember_minds())
			if(is_valid_target(possible_target) && !(possible_target in blacklist))
				target_candidates += possible_target
	list_clear_nulls(target_candidates)
	if(LAZYLEN(target_candidates))
		set_target(pick(target_candidates))
	else
		message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. WELP!")
		set_target(null)
	update_explanation_text()

/datum/objective/sacrifice/set_target(datum/mind/new_target)
	..()
	make_image()
	for(var/datum/mind/M in get_owners())
		if(M.current)
			M.current.clear_alert("bloodsense")
			M.current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)

/datum/objective/sacrifice/on_target_cryo()
	find_target(null, list(target))
	update_explanation_text()
	var/message
	if(!target)
		message = "<BR>[span_userdanger("Your target is no longer within reach. The veil is now weak enough to proceed to the final objective.")]"
	else
		message = "<BR>[span_userdanger("You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")].")]"
	for(var/datum/mind/own as anything in get_owners())
		to_chat(own.current, message)
		own.announce_objectives()

/datum/objective/sacrifice/is_valid_target(datum/mind/possible_target)
	if(!istype(possible_target) || !possible_target.current)
		return FALSE
	if(isipc(possible_target.current))
		return FALSE
	if(possible_target.has_antag_datum(/datum/antagonist/cult))
		return FALSE
	return ..()

/datum/objective/sacrifice/check_completion()
	//Target's a clockie
	if(target?.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		return TRUE
	return sacced || !target || ..()

/datum/objective/sacrifice/update_explanation_text()
	if(target)
		explanation_text = "Sacrifice [target], the [target.assigned_role.title] via invoking a Sacrifice rune with [target.p_them()] on it and three acolytes around it."
	else
		explanation_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon_area = pick(GLOB.areas - summon_spots)
		if(summon_area && is_station_level(summon_area.z) && (summon_area.area_flags & VALID_TERRITORY))
			summon_spots += summon_area
		sanity++
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon Nar'Sie by invoking the rune 'Summon Nar'Sie'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	return summoned || ..()

#undef SUMMON_POSSIBILITIES
