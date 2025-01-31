/obj/effect/proc_holder/spell/targeted/personality_commune
	name = "Personality Commune"
	desc = "Sends thoughts to your alternate consciousness."
	charge_max = 0
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "telepathy"
	action_background_icon_state = "bg_spell"
	var/datum/brain_trauma/severe/split_personality/trauma
	var/flufftext = "You hear an echoing voice in the back of your head..."

/obj/effect/proc_holder/spell/targeted/personality_commune/New(datum/brain_trauma/severe/split_personality/T)
	. = ..()
	trauma = T

// Pillaged and adapted from telepathy code
/obj/effect/proc_holder/spell/targeted/personality_commune/cast(list/targets, mob/user)
	if(!istype(trauma))
		to_chat(user, span_warning("Something is wrong; Either due a bug or admemes, you are trying to cast this spell without a split personality!"))
		return
	var/msg = stripped_input(usr, "What would you like to tell your other self?", null , "")
	if(!msg)
		charge_counter = charge_max
		return
	if(CHAT_FILTER_CHECK(msg))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	msg = user.treat_message_min(msg)
	to_chat(user, "[span_boldnotice("You concentrate and send thoughts to your other self:")] [span_notice(msg)]")
	to_chat(trauma.owner, "[span_boldnotice(flufftext)] [span_notice(msg)]")
	log_directed_talk(user, trauma.owner, msg, LOG_SAY ,"[name]")
	for(var/ded in GLOB.dead_mob_list)
		if(!isobserver(ded))
			continue
		to_chat(ded, "[FOLLOW_LINK(ded, user)] [span_boldnotice("[user] [name]:")] [span_notice("\"[msg]\" to ")][span_name("[trauma]")]")
