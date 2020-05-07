/datum/clockcult/scripture
	var/name = ""
	var/desc = ""
	var/tip = ""
	var/power_cost = 0
	var/invokation_time = 0
	var/list/invokation_text = list()
	var/button_icon_state = "telerune"

	var/mob/living/invoker
	var/obj/item/clockwork/clockwork_slab/invoking_slab

	var/invokation_chant_timer = null

/datum/clockcult/scripture/proc/invoke()
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
	invokation_chant_timer = null
	if(!invoking_slab || !invoking_slab.invoking_scripture)
		return
	clockwork_say(invoker, text2ratvar(invokation_text[text_point]), TRUE)
	if(text_point < stop_at)
		invokation_chant_timer = addtimer(CALLBACK(src, .proc/recite, text_point+1, wait_time, stop_at), wait_time)

/datum/clockcult/scripture/proc/check_special_requirements()
	if(!invoker || !invoking_slab)
		message_admins("No invoker for [name]")
		return FALSE
	if(invoker.get_active_held_item() != invoking_slab)
		to_chat(invoker, "<span class='brass'>You fail to invoke [name].</span>")
		return FALSE
	return TRUE

/datum/clockcult/scripture/proc/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab)
	if(M.get_active_held_item() != slab)
		to_chat(M, "<span class='brass'>You need to have the [slab.name] in your active hand to recite scriptures.</span>")
		return
	slab.invoking_scripture = src
	invoker = M
	invoking_slab = slab
	recital()
	if(do_after(M, invokation_time, target=M/*, extra_checks=CALLBACK(src, .proc/check_special_requirements)*/))
		invoke()
		to_chat(M, "<span class='brass'>You invoke [name].</span>")
	else
		invoke_fail()
		if(invokation_chant_timer)
			deltimer(invokation_chant_timer)
			invokation_chant_timer = null
	slab.invoking_scripture = null

//==================================//
// !       Structure Creation       ! //
//==================================//

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

	var/obj/effect/proc_holder/slab/PH

	var/uses_left
	var/time_left = 0
	var/loop_timer_id

/datum/clockcult/scripture/slab/New()
	PH = new
	PH.parent_scripture = src
	..()

/datum/clockcult/scripture/slab/Destroy()
	if(PH && !QDELETED(PH))
		QDEL_NULL(PH)

/datum/clockcult/scripture/slab/invoke()
	progress = new(invoker, use_time)
	uses_left = uses
	time_left = use_time
	invoking_slab.charge_overlay = slab_overlay
	invoking_slab.update_icon()
	PH.add_ranged_ability(invoker, "<span class='brass'>You prepare [name]. <b>Click on a target to use.</b></span>")
	count_down()
	invoke_success()

/datum/clockcult/scripture/slab/proc/count_down()
	progress.update(time_left)
	time_left --
	loop_timer_id = null
	if(time_left > 0)
		loop_timer_id = addtimer(CALLBACK(src, .proc/count_down), 1)
	else
		end_invokation()

/datum/clockcult/scripture/slab/proc/click_on(atom/A)
	if(apply_affects(A))
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
	qdel(progress)
	PH.remove_ranged_ability()
	invoking_slab.charge_overlay = null
	invoking_slab.update_icon()

/datum/clockcult/scripture/slab/proc/apply_affects(atom/A)
	return TRUE

/obj/effect/proc_holder/slab
	var/datum/clockcult/scripture/slab/parent_scripture

/obj/effect/proc_holder/slab/InterceptClickOn(mob/living/caller, params, atom/A)
	parent_scripture?.click_on(A)

//==================================//
// !       Quick bind spell       ! //
//==================================//

/datum/action/innate/clockcult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "brass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/clockcult/quick_bind
	name = "Quick Bind"
	button_icon_state = "telerune"
	desc = "A quick bound spell."
	var/obj/item/clockwork/clockwork_slab/activation_slab
	var/datum/clockcult/scripture/scripture

/datum/action/innate/clockcult/quick_bind/Grant(mob/living/M)
	name = scripture.name
	desc = scripture.tip
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
		to_chat(owner, "<span class='brass'>DEBUG: You fail to invoke [name].</span>")
