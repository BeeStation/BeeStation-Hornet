///Your favourite Jojoke. Used for the gloves of the north star.
/datum/component/wearertargeting/punch_cooldown
	signals = list(COMSIG_LIVING_UNARMED_ATTACK)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(on_unarmed_attack)
	valid_slots = ITEM_SLOT_GLOVES
	/// The warcry this generates
	var/warcry = "AT"
	/// The cooldown we apply to our user
	var/punch_speed = CLICK_CD_RAPID

/datum/component/wearertargeting/punch_cooldown/Initialize(warcry, punch_speed)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	if(warcry)
		src.warcry = warcry
	if(punch_speed)
		src.punch_speed = punch_speed

	if(!isnull(src.warcry))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(change_warcry))

///Called on COMSIG_LIVING_UNARMED_ATTACK. Yells the warcry and and reduces punch cooldown.
/datum/component/wearertargeting/punch_cooldown/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(reduce_cooldown), source, target)

/datum/component/wearertargeting/punch_cooldown/proc/reduce_cooldown(mob/living/user, atom/target)
	if(user.combat_mode && isliving(target))
		user.changeNext_move(punch_speed)
		if(warcry)
			user.say(warcry, ignore_spam = TRUE, forced = "north star warcry")

///Called on COMSIG_ITEM_ATTACK_SELF. Allows you to change the warcry.
/datum/component/wearertargeting/punch_cooldown/proc/change_warcry(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_change_warcry), user)

/datum/component/wearertargeting/punch_cooldown/proc/do_change_warcry(mob/user)
	var/input = tgui_input_text(user, "What do you want your battlecry to be?", "Battle Cry", max_length = 6)
	if(!QDELETED(src) && !QDELETED(user) && !user.Adjacent(parent))
		return
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(user, span_warning("Invalid battlecry, please use another. Battlecry contains prohibited word(s)."))
		return
	warcry = input
