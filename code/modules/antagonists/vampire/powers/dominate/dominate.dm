/datum/discipline/dominate
	name = "Dominate"
	discipline_explanation = "Dominate is a Discipline infuses the vampires will into their voice and presence, forcing victims to think or act according to the vampire's decree."
	icon_state = "dominate"

	// Base only has mez, ventrue get command earlier and can upgrade it
	level_1 = list(/datum/action/vampire/targeted/mesmerize)
	level_2 = list(/datum/action/vampire/targeted/mesmerize/two)
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command)
	level_5 = null

/datum/discipline/dominate/ventrue
	level_3 = list(/datum/action/vampire/targeted/mesmerize/three, /datum/action/vampire/targeted/command)
	level_4 = list(/datum/action/vampire/targeted/mesmerize/four, /datum/action/vampire/targeted/command/two)

// Dominate grants a controlled Voice of God ability as a passive discipline quirk,
// similar to how Potence grants extra punch damage.
/datum/discipline/dominate/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	. = ..()
	clan_owner.grant_power(new /datum/action/vampire/voice_of_domination)

/// Tiny ability datum just to get vampies a voice of god power
/datum/action/vampire/voice_of_domination
	name = "Voice of Domination"
	desc = "Speak with an overwhelmingly dominant voice, forcing mortals to briefly obey your command."
	button_icon_state = "power_command"
	power_explanation = "Activate this power to speak a command using the Voice of God.\n\
		Listeners will be compelled to obey simple commands such as 'stop', 'drop', 'sleep', 'come here', etc.\n\
		This is a weaker version of the divine Voice of God, granted passively by your mastery of Dominate."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 60 SECONDS

/datum/action/vampire/voice_of_domination/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner.get_organ_slot(ORGAN_SLOT_TONGUE))
		owner.balloon_alert(owner, "you have no tongue!")
		return FALSE
	if(carbon_owner.is_mouth_covered() || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "your mouth is blocked.")
		return FALSE
	if(HAS_TRAIT(carbon_owner, TRAIT_MUTE))
		owner.balloon_alert(owner, "you cannot speak!")
		return FALSE
	return TRUE

/datum/action/vampire/voice_of_domination/activate_power()
	var/command = tgui_input_text(owner, "Speak with the Voice of Domination", "Command")
	if(QDELETED(src) || QDELETED(owner) || !command)
		return
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 100, TRUE, 3)
	var/command_cooldown = voice_of_god(command, owner, list("colossus","commands"), base_multiplier = 2)
	cooldown_time = max(command_cooldown, 60 SECONDS)
	. = ..()
	deactivate_power()
