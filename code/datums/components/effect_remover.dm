/*
 * Simple component for something that is able to destroy
 * certain effects (such as cult runes) in one attack.
 */
/datum/component/effect_remover
	/// Line sent to the user on successful removal.
	var/success_feedback
	/// Line forcesaid by the user on successful removal.
	var/success_forcesay
	/// Callback invoked with removal is done.
	var/datum/callback/on_clear_callback
	/// A typecache of all effects we can clear with our item.
	var/list/obj/effect/effects_we_clear

/datum/component/effect_remover/Initialize(
	success_forcesay,
	success_feedback,
	on_clear_callback,
	effects_we_clear,
	)

	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!effects_we_clear)
		stack_trace("[type] was instantiated without any valid removable effects!")
		return COMPONENT_INCOMPATIBLE

	src.success_feedback = success_feedback
	src.success_forcesay = success_forcesay
	src.on_clear_callback = on_clear_callback
	src.effects_we_clear = typecacheof(effects_we_clear)

/datum/component/effect_remover/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_EFFECT, PROC_REF(try_remove_effect))

/datum/component/effect_remover/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_EFFECT)

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_EFFECT].
 */
/datum/component/effect_remover/proc/try_remove_effect(datum/source, obj/effect/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	if(effects_we_clear[target.type]) // Make sure we get all subtypes and everything
		INVOKE_ASYNC(src, PROC_REF(do_remove_effect), target, user)
		return COMPONENT_NO_AFTERATTACK

/*
 * Actually removes the effect, invoking our on_clear_callback before it's deleted.
 */
/datum/component/effect_remover/proc/do_remove_effect(obj/effect/target, mob/living/user)
	var/obj/item/item_parent = parent
	if(success_forcesay)
		user.say(success_forcesay, forced = item_parent.name)
	if(success_feedback)
		var/real_feedback = replacetext(success_feedback, "%THEEFFECT", "[target]")
		real_feedback = replacetext(real_feedback, "%THEWEAPON", "[item_parent]")
		to_chat(user, "<span class='notice'>[real_feedback]</span>")
	on_clear_callback?.Invoke(target, user)
	qdel(target)
