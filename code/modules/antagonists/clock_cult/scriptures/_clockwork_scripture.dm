/datum/clockcult/scripture
	var/name = ""
	var/desc = ""
	var/tip = ""
	var/power_cost = 0
	var/vitality_cost = 0
	var/cogs_required = 0
	var/invokation_time = 0
	var/list/invokation_text = list()	//This is all translated to rat'var so doesn't matter if its cringey or doesn't make sense, since most people can't read it
	var/button_icon_state = "telerune"
	var/invokers_required = 1
	var/category = SPELLTYPE_ABSTRACT
	var/end_on_invokation = TRUE	//Only set to false if you call end_invoke somewhere in your sciprture

	var/mob/living/invoker
	var/obj/item/clockwork/clockwork_slab/invoking_slab

	var/invokation_chant_timer = null
	var/qdel_on_completion = FALSE

	var/sound/recital_sound = null

/datum/clockcult/scripture/proc/invoke()
	if(GLOB.clockcult_power < power_cost || GLOB.clockcult_vitality < vitality_cost)
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
		end_invoke()
		return
	GLOB.clockcult_power -= power_cost
	GLOB.clockcult_vitality -= vitality_cost
	invoke_success()

/datum/clockcult/scripture/proc/invoke_success()
	return TRUE

/datum/clockcult/scripture/proc/invoke_fail()
	return TRUE

/datum/clockcult/scripture/proc/recital()
	if(!LAZYLEN(invokation_text))
		return
	var/steps = invokation_text.len
	var/time_between_say = invokation_time / (steps + 1)
	if(invokation_chant_timer)
		deltimer(invokation_chant_timer)
		invokation_chant_timer = null
	recite(1, time_between_say, steps)

/datum/clockcult/scripture/proc/recite(text_point, wait_time, stop_at = 0)
	if(QDELETED(src))
		return
	invokation_chant_timer = null
	if(!invoking_slab || !invoking_slab.invoking_scripture)
		return
	var/invokers_left = invokers_required
	if(invokers_left > 1)
		for(var/mob/living/M in viewers(invoker))
			if(M.stat)
				continue
			if(!invokers_left)
				break
			if(is_servant_of_ratvar(M))
				clockwork_say(M, text2ratvar(invokation_text[text_point]), TRUE)
				invokers_left--
	else
		clockwork_say(invoker, text2ratvar(invokation_text[text_point]), TRUE)
	if(recital_sound)
		SEND_SOUND(invoker, recital_sound)
	if(text_point < stop_at)
		invokation_chant_timer = addtimer(CALLBACK(src, .proc/recite, text_point+1, wait_time, stop_at), wait_time, TIMER_STOPPABLE)

/datum/clockcult/scripture/proc/check_special_requirements(mob/user)
	if(!invoker || !invoking_slab)
		message_admins("No invoker for [name]")
		return FALSE
	if(invoker.get_active_held_item() != invoking_slab && !iscyborg(invoker))
		to_chat(invoker, "<span class='brass'>You fail to invoke [name].</span>")
		return FALSE
	var/invokers
	for(var/mob/living/M in viewers(invoker))
		if(M.stat)
			continue
		if(is_servant_of_ratvar(M))
			invokers++
	if(invokers < invokers_required)
		to_chat(invoker, "<span class='brass'>You need [invokers_required] servants to channel [name]!</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/proc/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks = FALSE)
	if(M.get_active_held_item() != slab && !iscyborg(M))
		to_chat(M, "<span class='brass'>You need to have the [slab.name] in your active hand to recite scriptures.</span>")
		return
	slab.invoking_scripture = src
	invoker = M
	invoking_slab = slab
	if(!(type in slab.purchased_scriptures) && !bypass_unlock_checks)
		log_runtime("CLOCKCULT: Attempting to invoke a scripture that has not been unlocked. Either there is a bug, or [ADMIN_LOOKUP(invoker)] is using some wacky exploits.")
		end_invoke()
		return
	if(!check_special_requirements(M))
		end_invoke()
		return
	recital()
	if(do_after(M, invokation_time, target=M, extra_checks=CALLBACK(src, .proc/check_special_requirements, M)))
		invoke()
		to_chat(M, "<span class='brass'>You invoke [name].</span>")
		if(end_on_invokation)
			end_invoke()
	else
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
		end_invoke()

/datum/clockcult/scripture/proc/end_invoke()
	invoking_slab.invoking_scripture = null
	if(qdel_on_completion)
		qdel(src)

//==================================//
// !      Structure Creation      ! //
//==================================//
/datum/clockcult/scripture/create_structure
	var/summoned_structure

/datum/clockcult/scripture/create_structure/check_special_requirements(mob/user)
	if(!..())
		return FALSE
	for(var/obj/structure/destructible/clockwork/structure in get_turf(invoker))
		to_chat(invoker, "<span class='brass'>You cannot invoke that here, the tile is occupied by [structure].</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/create_structure/invoke_success()
	var/created_structure = new summoned_structure(get_turf(invoker))
	var/obj/structure/destructible/clockwork/clockwork_structure = created_structure
	if(istype(clockwork_structure))
		clockwork_structure.owner = invoker.mind


//==================================//
// !       Slab Empowerment       ! //
//==================================//
//For scriptures that charge the slab, and the slab will affect something
//(stunning etc.)

/datum/clockcult/scripture/slab
	name = "Charge Slab"
	var/use_time = 10
	var/slab_overlay = "volt"
	var/datum/progressbar/progress
	var/uses = 1
	var/after_use_text = ""
	end_on_invokation = FALSE

	var/obj/effect/proc_holder/slab/PH

	var/uses_left
	var/time_left = 0
	var/loop_timer_id

/datum/clockcult/scripture/slab/New()
	PH = new
	PH.parent_scripture = src
	..()

/datum/clockcult/scripture/slab/Destroy()
	if(progress)
		qdel(progress)
	if(PH && !QDELETED(PH))
		PH.remove_ranged_ability()
		QDEL_NULL(PH)

/datum/clockcult/scripture/slab/invoke()
	progress = new(invoker, use_time)
	uses_left = uses
	time_left = use_time
	invoking_slab.charge_overlay = slab_overlay
	invoking_slab.update_icon()
	invoking_slab.active_scripture = src
	PH.add_ranged_ability(invoker, "<span class='brass'>You prepare [name]. <b>Click on a target to use.</b></span>")
	count_down()
	invoke_success()

/datum/clockcult/scripture/slab/proc/count_down()
	if(QDELETED(src))
		return
	progress.update(time_left)
	time_left --
	loop_timer_id = null
	if(time_left > 0)
		loop_timer_id = addtimer(CALLBACK(src, .proc/count_down), 1, TIMER_STOPPABLE)
	else
		end_invokation()

/datum/clockcult/scripture/slab/proc/click_on(atom/A)
	if(!invoker.can_interact_with(A))
		return
	if(apply_effects(A))
		uses_left --
		if(uses_left <= 0)
			if(after_use_text)
				clockwork_say(invoker, text2ratvar(after_use_text), TRUE)
			end_invokation()

/datum/clockcult/scripture/slab/proc/end_invokation()
	//Remove the timer if there is one currently active
	if(loop_timer_id)
		deltimer(loop_timer_id)
		loop_timer_id = null
	to_chat(invoker, "<span class='brass'>You are no longer invoking <b>[name]</b></span>")
	qdel(progress)
	PH.remove_ranged_ability()
	invoking_slab.charge_overlay = null
	invoking_slab.update_icon()
	invoking_slab.active_scripture = null
	end_invoke()

/datum/clockcult/scripture/slab/proc/apply_effects(atom/A)
	return TRUE

/obj/effect/proc_holder/slab
	var/datum/clockcult/scripture/slab/parent_scripture

/obj/effect/proc_holder/slab/InterceptClickOn(mob/living/caller, params, atom/A)
	parent_scripture?.click_on(A)

//==================================//
// !       Quick bind spell       ! //
//==================================//

/datum/action/innate/clockcult
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	background_icon_state = "bg_clock"
	buttontooltipstyle = "brass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/clockcult/quick_bind
	name = "Quick Bind"
	button_icon_state = "telerune"
	desc = "A quick bound spell."
	var/obj/item/clockwork/clockwork_slab/activation_slab
	var/datum/clockcult/scripture/scripture

/datum/action/innate/clockcult/quick_bind/Destroy()
	Remove(owner)
	. = ..()

/datum/action/innate/clockcult/quick_bind/Grant(mob/living/M)
	name = scripture.name
	desc = scripture.tip
	button_icon_state = scripture.button_icon_state
	if(scripture.power_cost)
		desc += "<br>Draws <b>[scripture.power_cost]W</b> from the ark per use."
	..(M)
	button.locked = TRUE
	button.ordered = TRUE

/datum/action/innate/clockcult/quick_bind/Remove(mob/M)
	if(activation_slab.invoking_scripture == scripture)
		activation_slab.invoking_scripture = null
	..(M)

/datum/action/innate/clockcult/quick_bind/IsAvailable()
	if(!is_servant_of_ratvar(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockcult/quick_bind/Activate()
	if(!activation_slab)
		return
	if(!activation_slab.invoking_scripture)
		scripture.begin_invoke(owner, activation_slab)
	else
		to_chat(owner, "<span class='brass'>You fail to invoke [name].</span>")

//==================================//
// !     Hierophant Transmit      ! //
//==================================//
/datum/action/innate/clockcult/transmit
	name = "Hierophant Transmit"
	button_icon_state = "hierophant"
	desc = "Transmit a message to your allies through the Hierophant."

/datum/action/innate/clockcult/transmit/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		Remove(owner)
		return FALSE
	if(owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockcult/transmit/Activate()
	hierophant_message(stripped_input(owner, "What do you want to tell your allies?", "Hierophant Transmit", ""), owner, "<span class='brass'>")

/datum/action/innate/clockcult/transmit/Grant(mob/M)
	..(M)
	button.locked = TRUE
	button.ordered = TRUE
