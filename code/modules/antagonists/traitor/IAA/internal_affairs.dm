#define PINPOINTER_MINIMUM_RANGE 15
#define PINPOINTER_EXTRA_RANDOM_RANGE 10
#define PINPOINTER_PING_TIME 40
#define PROB_ACTUAL_TRAITOR 20
#define TRAITOR_AGENT_ROLE "Syndicate External Affairs Agent"

/datum/antagonist/traitor/internal_affairs
	name = "Internal Affairs Agent"
	employer = "Nanotrasen"
	special_role = "internal affairs agent"
	antagpanel_category = "IAA"
	var/syndicate = FALSE

/datum/antagonist/traitor/internal_affairs/proc/give_pinpointer()
	if(owner?.current)
		owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer)

/datum/antagonist/traitor/internal_affairs/apply_innate_effects()
	.=..() //in case the base is used in future
	if(owner?.current)
		give_pinpointer(owner.current)

/datum/antagonist/traitor/internal_affairs/remove_innate_effects()
	.=..()
	if(owner?.current)
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer)

/datum/status_effect/agent_pinpointer
	id = "agent_pinpointer"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	var/range_fuzz_factor = PINPOINTER_EXTRA_RANDOM_RANGE
	var/mob/scan_target = null
	var/range_mid = 8
	var/range_far = 16

/atom/movable/screen/alert/status_effect/agent_pinpointer
	name = "Internal Affairs Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range + rand(0, range_fuzz_factor))
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		var/dist = (get_dist(here, there))
		if(dist >= 1 && dist <= range_mid)
			linked_alert.icon_state = "pinonclose"
		else if(dist > range_mid && dist <= range_far)
			linked_alert.icon_state = "pinonmedium"
		else if(dist > range_far)
			linked_alert.icon_state = "pinonfar"

/datum/status_effect/agent_pinpointer/proc/scan_for_target()
	scan_target = null
	if(owner)
		if(owner.mind)
			for(var/datum/objective/objective_ in owner.mind.get_all_objectives())
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				var/mob/current = objective.target.current
				if(current&&current.stat!=DEAD)
					scan_target = current
				break

/datum/status_effect/agent_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()


/proc/is_internal_objective(datum/objective/O)
	return (istype(O, /datum/objective/assassinate/internal)||istype(O, /datum/objective/destroy/internal))

/datum/antagonist/traitor/internal_affairs/proc/forge_iaa_objectives()
	if(SSticker.mode.target_list.len && SSticker.mode.target_list[owner]) // Is a double agent
		// Assassinate
		var/datum/mind/target_mind = SSticker.mode.target_list[owner]
		if(issilicon(target_mind.current))
			var/datum/objective/destroy/internal/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.target = target_mind
			destroy_objective.update_explanation_text()
			add_objective(destroy_objective)
		else
			var/datum/objective/assassinate/internal/kill_objective = new
			kill_objective.owner = owner
			kill_objective.target = target_mind
			kill_objective.update_explanation_text()
			add_objective(kill_objective)

		//Optional traitor objective
		if(prob(PROB_ACTUAL_TRAITOR))
			employer = "The Syndicate"
			owner.special_role = TRAITOR_AGENT_ROLE
			special_role = TRAITOR_AGENT_ROLE
			syndicate = TRUE
			forge_single_objective()

/datum/antagonist/traitor/internal_affairs/forge_traitor_objectives()
	forge_iaa_objectives()

	var/objtype = traitor_kind == TRAITOR_HUMAN ? /datum/objective/escape : /datum/objective/survive/exist
	var/datum/objective/escape_objective = new objtype
	escape_objective.owner = owner
	add_objective(escape_objective)

/datum/antagonist/traitor/internal_affairs/proc/greet_iaa()
	var/crime = pick("distribution of contraband" , "unauthorized erotic action on duty", "embezzlement", "piloting under the influence", "dereliction of duty", "syndicate collaboration", "mutiny", "multiple homicides", "corporate espionage", "receiving bribes", "malpractice", "worship of prohibited life forms", "possession of profane texts", "murder", "arson", "insulting their manager", "grand theft", "conspiracy", "attempting to unionize", "vandalism", "gross incompetence")

	to_chat(owner.current, "<span class='userdanger'>You are the [special_role].</span>")
	if(syndicate)
		to_chat(owner.current, "<span class='userdanger'>Your target has been framed for [crime], and you have been tasked with eliminating them to prevent them defending themselves in court.</span>")
		to_chat(owner.current, "<B><font size=5 color=red>Any damage you cause will be a further embarrassment to Nanotrasen, so you have no limits on collateral damage.</font></B>")
		to_chat(owner.current, "<span class='userdanger'> You have been provided with a standard uplink to accomplish your task. </span>")
	else
		to_chat(owner.current, "<span class='userdanger'>Your target is suspected of [crime], and you have been tasked with eliminating them by any means necessary to avoid a costly and embarrassing public trial.</span>")
		to_chat(owner.current, "<B><font size=5 color=red>While you have a license to kill, you should try to not cause too much attention, though this is optional</font></B>")
		to_chat(owner.current, "<span class='userdanger'>For the sake of plausible deniability, you have been equipped with an array of captured Syndicate weaponry available via uplink.</span>")

	to_chat(owner.current, "<span class='userdanger'>Finally, watch your back. Your target has friends in high places, and intel suggests someone may have taken out a contract of their own to protect them.</span>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("[syndicate ? "External Affairs" : "Internal Affairs"]",
		"[syndicate?"Eliminate your target and cause as much damage to Nanotrasen property as you see fit."\
		: "Eliminate your target without drawing too much attention to yourself, but watch your back since somebody is after you."]")

/datum/antagonist/traitor/internal_affairs/greet()
	greet_iaa()

#undef PROB_ACTUAL_TRAITOR
#undef PINPOINTER_EXTRA_RANDOM_RANGE
#undef PINPOINTER_MINIMUM_RANGE
#undef PINPOINTER_PING_TIME
