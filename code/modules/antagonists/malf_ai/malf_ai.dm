/// Chance the malf AI gets a single special objective that isn't assassinate.
#define PROB_SPECIAL 30

/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	antagpanel_category = "Malfunctioning AI"
	banning_key = ROLE_MALF
	ui_name = "AntagInfoMalf"
	required_living_playtime = 8
	///the name of the antag flavor this traitor has.
	var/employer
	///assoc list of strings set up after employer is given
	var/list/malfunction_flavor
	/// Should Malf AIs get codewords?
	var/should_give_codewords = TRUE
	///since the module purchasing is built into the antag info, we need to keep track of its compact mode here
	var/module_picker_compactmode = FALSE
	///malf on_gain sound effect.
	var/malf_sound = 'sound/ambience/antag/malf.ogg'

/datum/antagonist/malf_ai/New(give_objectives = TRUE)
	. = ..()
	src.give_objectives = give_objectives

/datum/antagonist/malf_ai/on_gain()
	if(owner.current && !isAI(owner.current))
		return ..()

	owner.special_role = ROLE_MALF
	if(give_objectives)
		forge_objectives()
	if(!employer)
		employer = pick(GLOB.ai_employers)

	malfunction_flavor = strings(MALFUNCTION_FLAVOR_FILE, employer)

	add_law_zero()
	owner.current.grant_language(/datum/language/codespeak, source = LANGUAGE_MALF)

	var/datum/atom_hud/data/hackyhud = GLOB.huds[DATA_HUD_HACKED_APC]
	hackyhud.add_hud_to(owner.current)

	return ..()

/datum/antagonist/malf_ai/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/malf_ai = owner.current
		malf_ai.set_zeroth_law("")
		malf_ai.remove_malf_abilities()
		QDEL_NULL(malf_ai.malf_picker)

	owner.special_role = null
	return ..()

/// Generates a complete set of malf AI objectives up to the traitor objective limit.
/datum/antagonist/malf_ai/proc/forge_objectives()
	if(prob(PROB_SPECIAL))
		forge_special_objective()

	var/objective_limit = CONFIG_GET(number/traitor_objectives_amount)
	var/objective_count = length(objectives)

	// for(in...to) loops iterate inclusively, so to reach objective_limit we need to loop to objective_limit - 1
	// This does not give them 1 fewer objectives than intended.
	for(var/i in objective_count to objective_limit - 1)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		objectives += kill_objective

	var/datum/objective/survive/malf/dont_die_objective = new
	dont_die_objective.owner = owner
	objectives += dont_die_objective

/// Generates a special objective and adds it to the objective list.
/datum/antagonist/malf_ai/proc/forge_special_objective()
	var/special_pick = rand(1,4)
	switch(special_pick)
		if(1)
			var/datum/objective/block/block_objective = new
			block_objective.owner = owner
			objectives += block_objective
		if(2)
			var/datum/objective/purge/purge_objective = new
			purge_objective.owner = owner
			objectives += purge_objective
		if(3)
			var/datum/objective/robot_army/robot_objective = new
			robot_objective.owner = owner
			objectives += robot_objective
		if(4) //Protect and strand a target
			var/datum/objective/protect/yandere_one = new
			yandere_one.owner = owner
			objectives += yandere_one
			yandere_one.find_target()
			var/datum/objective/maroon/yandere_two = new
			yandere_two.owner = owner
			yandere_two.target = yandere_one.target
			yandere_two.update_explanation_text() // normally called in find_target()
			objectives += yandere_two

/datum/antagonist/malf_ai/greet()
	var/list/msg = list()

	msg += span_userdanger("You are the [owner.special_role].")
	msg += span_warning("Use :t to communicate on a secure channel with Syndicate Agents.")
	msg += span_warning("Hack APCs to gain processing time which you can use to unlock powerful Malfunction Abilities.")

	if(malf_sound)
		owner.current.playsound_local(get_turf(owner.current), malf_sound, vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	to_chat(owner.current, examine_block(msg.Join("\n")))

/datum/antagonist/malf_ai/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	message = GLOB.syndicate_code_phrase_regex.Replace(message, span_blue("$1"))
	message = GLOB.syndicate_code_response_regex.Replace(message, span_red("$1"))
	hearing_args[HEARING_RAW_MESSAGE] = message

/datum/antagonist/malf_ai/apply_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current

	if(istype(datum_owner))
		datum_owner.hack_software = TRUE

	if(should_give_codewords)
		RegisterSignal(datum_owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

	add_antag_hud(ANTAG_HUD_TRAITOR, "traitor", datum_owner)

/datum/antagonist/malf_ai/remove_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/silicon/ai/datum_owner = mob_override || owner.current

	if(istype(datum_owner))
		datum_owner.hack_software = FALSE

	UnregisterSignal(mob_override || owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

	remove_antag_hud(ANTAG_HUD_TRAITOR, datum_owner)

/datum/antagonist/malf_ai/proc/add_law_zero()
	var/mob/living/silicon/ai/malf_ai = owner.current

	if(!malf_ai || !istype(malf_ai))
		return

	var/law = malfunction_flavor["zeroth_law"]
	//very purposefully not changing this with flavor, i don't want cyborgs throwing the round for their AI's roleplay suggestion
	var/law_borg = "Accomplish your AI's objectives at all costs."

	malf_ai.set_zeroth_law(law, law_borg)
	malf_ai.set_syndie_radio()

	if(!malf_ai.malf_picker)
		malf_ai.add_malf_picker()

/datum/antagonist/malf_ai/ui_static_data(mob/living/silicon/ai/malf_ai)
	var/list/data = list()

	data["has_codewords"] = should_give_codewords
	if(should_give_codewords)
		data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
		data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["intro"] = malfunction_flavor["introduction"]
	data["allies"] = malfunction_flavor["allies"]
	data["goal"] = malfunction_flavor["goal"]
	data["objectives"] = get_objectives()

	return data

/datum/antagonist/malf_ai/roundend_report()
	var/list/result = list()

	var/malf_ai_won = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(length(objectives)) //If the AI had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				malf_ai_won = FALSE
			objectives_text += "<br><B>Objective #[count]</B>: [objective.get_completion_message()]"
			count++

	result += objectives_text

	if(malf_ai_won)
		result += span_greentext("The name was successful!")
	else
		result += span_redtext("The name has failed!")
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

#undef PROB_SPECIAL
