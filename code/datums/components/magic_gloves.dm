/datum/component/wearertargeting/magic_gloves
	signals = list(COMSIG_MOB_ATTACK_RANGED)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(on_ranged_attack)
	valid_slots = ITEM_SLOT_GLOVES
	var/range = 3

/datum/component/wearertargeting/magic_gloves/Initialize()
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))

///Called on COMSIG_LIVING_UNARMED_ATTACK. Yells the warcry and and reduces punch cooldown.
/datum/component/wearertargeting/magic_gloves/proc/on_ranged_attack(mob/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_magik), source, target, modifiers)

/datum/component/wearertargeting/magic_gloves/proc/do_magik(mob/living/user, atom/target, list/modifiers)
	if(get_dist(user, target) <= 1 || !(user in viewers(range, target)))
		return

	user.visible_message(span_danger("[user] waves their hands at [target]"), span_notice("You begin manipulating [target]."))
	new	/obj/effect/temp_visual/telegloves(get_turf(target))
	user.changeNext_move(CLICK_CD_MELEE)
	if(!do_after(user, 0.8 SECONDS, target))
		return

	new /obj/effect/temp_visual/telekinesis(get_turf(user))
	playsound(user, 'sound/weapons/emitter2.ogg', 25, TRUE, -1)
	target.attack_hand(user, modifiers)

/datum/component/wearertargeting/magic_gloves/proc/on_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(!istype(tool, /obj/item/upgradewand))
		return NONE
	var/obj/item/upgradewand/wand = tool
	if(wand.used || range == initial(range))
		return ITEM_INTERACT_BLOCKING

	wand.used = TRUE
	range = 6
	to_chat(user, span_notice("You upgrade the [parent] with the [wand]."))
	playsound(user, 'sound/weapons/emitter2.ogg', 25, TRUE, -1)
	return ITEM_INTERACT_SUCCESS
