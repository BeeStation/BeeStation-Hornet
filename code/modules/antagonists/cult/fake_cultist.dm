
/datum/antagonist/cult/fake
	name = "Fake Cultist"
	roundend_category = "Fake cultists"
	antagpanel_category = "Cult (FAKE)"
	ui_name = "AntagInfoBloodCult"
	antag_moodlet = null
	banning_key = ROLE_CULTIST
	required_living_playtime = 4
	var/static/fake_cult_team

	vote = null // You have no reason to be the cult leader
	var/datum/action/innate/cult/pretend_ascend/pretend_ascend = new

/datum/antagonist/cult/fake/create_team(datum/team/cult/new_team)
	if(!fake_cult_team)
		cult_team = new /datum/team/cult/fake
		cult_team.setup_objectives()
		fake_cult_team = cult_team
		return
	cult_team = fake_cult_team

/datum/antagonist/cult/fake/greet()
	to_chat(owner, span_clown("You are a FAKE member of the cult!"))
	owner.current.playsound_local(get_turf(owner.current), 'sound/misc/honk_echo_distant.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/cult/fake/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.clear_alert("bloodsense")
	pretend_ascend.Grant(current)
	pretend_ascend.fake_cult_team = fake_cult_team

/datum/antagonist/cult/on_gain()
	. = ..()
	owner.current.log_message("is actually a fake cultist.", LOG_ATTACK, color="#960000")

/datum/antagonist/cult/fake/on_removal()
	silent = TRUE
	to_chat(owner.current, span_clown("You no longer have the fake cult power."))
	pretend_ascend.Remove(owner.current)
	. = ..()

/datum/antagonist/cult/fake/Destroy()
	QDEL_NULL(pretend_ascend)
	return ..()

/datum/team/cult/fake
	name = "Bloodcult (Not real)"

/datum/team/cult/fake/set_blood_target()
	return FALSE

/datum/team/cult/fake/setup_objectives()
	return

/datum/team/cult/fake/roundend_report()
	var/list/parts = list()
	parts += "There was a FAKE Blood Cult."

	if(members.len)
		parts += span_header("The fake cultists were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/action/innate/cult/pretend_ascend
	name = "Pretending Ascend"
	desc = "This makes you looking more obvious cultist. This is not revertable."
	button_icon_state = "summonsoulstone"
	var/datum/team/cult/fake_cult_team
	var/count = 1

/datum/action/innate/cult/pretend_ascend/on_activate()
	if(count--)
		to_chat(owner, span_cultlarge("You are now looking obvious cultist."))
		fake_cult_team.rise(owner)
		return
	to_chat(owner, span_cultlarge("You are now looking terrifying cultist."))
	fake_cult_team.ascend(owner)
	Remove(owner)
