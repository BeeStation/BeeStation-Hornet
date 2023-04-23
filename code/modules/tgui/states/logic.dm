/**
 * tgui state: logic_state
 *
 * Compares multiple states with boolean logic
 */

GLOBAL_LIST_EMPTY(logic_states)

/datum/ui_state/logic
	/// Either STATE_AND or STATE_OR, whichever you want to check with
	var/op = STATE_AND
	var/list/states = list()

/datum/ui_state/logic/New(op, states)
	..()
	src.op = op
	src.states = states

/datum/ui_state/logic/can_use_topic(src_object, mob/user)
	if(!LAZYLEN(states))
		return UI_INTERACTIVE
	for(var/s in states)
		var/datum/ui_state/state = s
		if(!state || !istype(state))
			continue
		if(isnull(.))
			. = state.can_use_topic(src_object, user)
		else
			switch(op)
				if(STATE_AND)
					. =  min(., state.can_use_topic(src_object, user))
				if(STATE_OR)
					. = max(., state.can_use_topic(src_object, user))
				else
					SWITCH_EMPTY_STATEMENT


/proc/logic_state(op, states = list())
	var/state_hash = hash_logic_state(op, states)
	if(GLOB.logic_states[state_hash])
		return GLOB.logic_states[state_hash]
	var/datum/ui_state/logic/logic_state = new(op, states)
	GLOB.logic_states[state_hash] = logic_state
	return logic_state

/proc/hash_logic_state(op, states = list())
	var/string = "[op]"
	for(var/s in states)
		var/datum/ui_state/state = s
		if(!state || !istype(state))
			continue
		string += REF(state)
	return rustg_hash_string(RUSTG_HASH_XXH64, string)
