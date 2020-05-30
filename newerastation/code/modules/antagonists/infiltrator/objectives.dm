//originally yoinked from hippie (infiltrators)
//(comments are both from hippie and new era)
#define MIN_POWER_DRAIN 25000000
#define MAX_POWER_DRAIN 100000000
#define MIN_TECH_DRAIN 10000
#define MAX_TECH_DRAIN 20000

GLOBAL_LIST_INIT(infiltrator_kidnap_areas, typecacheof(list(/area/shuttle/hippie/stealthcruiser, /area/hippie/infiltrator_base)))

/datum/objective/infiltrator
	name = "Generic Infiltrator Objective (you shouldn't see this)"
	explanation_text = "Generic Infiltrator Objective!"
	martyr_compatible = FALSE
	var/item_type
	var/linked_gear = list() //Saved infiltrator powersinks or miners to change their target var in case an admin edits the objectives.

/datum/objective/infiltrator/New()
	..()
	if(item_type)
		for(var/turf/T in GLOB.infiltrator_objective_items)
			if(!(item_type in T.contents))
				new item_type(T)

/datum/objective/infiltrator/exploit
	name = "infiltrator exploit"
	explanation_text = "Ensure there is at least 1 hijacked AI."
	item_type = /obj/item/ai_hijack_device

/datum/objective/infiltrator/exploit/find_target(dupe_search_range)
	var/list/possible_targets = active_ais()
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/infiltrator/exploit/admin_edit(mob/admin)
	var/list/possible_targets = active_ais(1)
	if(possible_targets.len)
		var/mob/new_target = input(admin,"Select target:", "Objective target") as null|anything in possible_targets
		target = new_target.mind
	else
		to_chat(admin, "No active AIs with minds, defaulting to any.")
	update_explanation_text()

/datum/objective/infiltrator/exploit/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Hijack [station_name()]'s AI unit, [target.name]."
	else
		explanation_text = "Ensure there is at least 1 hijacked AI on [station_name()]. Remember: If there is no AI, you can build one!"

/datum/objective/infiltrator/exploit/check_completion()
	if(!target)
		return LAZYLEN(get_antag_minds(/datum/antagonist/hijacked_ai))
	if(istype(target, /datum/mind))
		var/datum/mind/A = target
		return A && A.has_antag_datum(/datum/antagonist/hijacked_ai)
	return FALSE


/datum/objective/infiltrator/power
	name = "infiltrator power sink"
	explanation_text = "Drain power from the station with a power sink."

/datum/objective/infiltrator/power/New()
	target_amount = rand(MIN_POWER_DRAIN, MAX_POWER_DRAIN) //I don't do this in find_target(), because that is done AFTER New().
	for(var/turf/T in GLOB.infiltrator_objective_items)
		if(!(item_type in T.contents))
			var/obj/item/powersink/infiltrator/PS = new(T)
			PS.target = target_amount
			linked_gear += PS
	update_explanation_text()

/datum/objective/infiltrator/power/admin_edit(mob/admin)
	var/new_amount = input(admin,"Select target amount IN WATTS:", "Power sink target") as null|num
	target_amount = max(0, new_amount) //don't know what would happen with a negative value, and don't want to find out.
	for(var/obj/item/infiltrator_miner/O in linked_gear)
		O.target = target_amount
	update_explanation_text()

/datum/objective/infiltrator/power/find_target(dupe_search_range, blacklist) //needed because find_target() is called in infiltrator/team.dm
	return //and the found target would otherwise pop up in the pinpointer. bad.

/datum/objective/infiltrator/power/update_explanation_text()
	..()
	if(target_amount)
		explanation_text = "Drain [DisplayPower(target_amount)] from [station_name()]'s powernet with a special transmitter powersink. You do not need to bring the powersink back once the objective is complete."
	else
		explanation_text = "You were supposed to drain some power from the station, but something went wrong. Here, have a free objective!"

/datum/objective/infiltrator/power/check_completion()
	return !target_amount || (GLOB.powersink_transmitted >= target_amount)


/datum/objective/infiltrator/miner
	name = "infiltrator miner"
	explanation_text = "Steal some sweet-ass nanotrasen technology."
	item_type = /obj/item/infiltrator_miner

/datum/objective/infiltrator/miner/New()
	target_amount = rand(MIN_TECH_DRAIN, MAX_TECH_DRAIN)
	for(var/turf/T in GLOB.infiltrator_objective_items)
		if(!(item_type in T.contents))
			var/obj/item/infiltrator_miner/M = new(T)
			M.target = target_amount
			linked_gear += M
	update_explanation_text()

/datum/objective/infiltrator/miner/admin_edit(mob/admin)
	var/new_amount = input(admin,"Select target tech points:", "Mining some bitcoin, are we?") as null|num
	target_amount = max(0, new_amount)
	for(var/obj/item/infiltrator_miner/O in linked_gear)
		O.target = target_amount
	update_explanation_text()

/datum/objective/infiltrator/miner/update_explanation_text()
	..()
	if(target_amount)
		explanation_text = "Intercept [target_amount] technology points from [station_name()]'s research network."
	else
		explanation_text = "You were supposed to steal some sweet-ass nanotrasen technology, but something went wrong."

/datum/objective/infiltrator/miner/find_target(dupe_search_range, blacklist)
	return

/datum/objective/infiltrator/miner/check_completion()
	return !target_amount || (GLOB.infil_miner_transmitted >= target_amount)


/datum/objective/infiltrator/kidnap
	name = "infiltrator kidnap"
	explanation_text = "You were supposed to kidnap someone, but we couldn't find anyone to kidnap!"


/datum/objective/infiltrator/kidnap/find_target(dupe_search_range)
	var/list/possible_targets = SSjob.get_living_heads()
	for(var/datum/mind/M in SSticker.minds)
		if(!M || !considered_alive(M) || considered_afk(M) || !M.current || !M.current.client)
			continue
		if("Head of Security" in get_department_heads(M.assigned_role))
			possible_targets += M
	target = pick(possible_targets)
	update_explanation_text()
	return target

/datum/objective/infiltrator/kidnap/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/infiltrator/kidnap/update_explanation_text()
	if(target && target.current)
		explanation_text = "Kidnap [target.name], the [target.assigned_role], and hold [target.current.p_them()] on the shuttle or base."
	else
		explanation_text = "You were supposed to kidnap someone, but we couldn't find anyone to kidnap! Here, have a free objective!"

/datum/objective/infiltrator/kidnap/check_completion()
	if (!target)
		return TRUE
	var/target_area = get_area(target.current)
	return (target.current && target.current.suiciding) || ((considered_alive(target) || issilicon(target.current)) && is_type_in_typecache(target_area, GLOB.infiltrator_kidnap_areas))
