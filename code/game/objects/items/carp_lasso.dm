/obj/item/carp_lasso
	name = "carp lasso"
	desc = "Comes standard with every space-cowboy."
	icon = 'icons/obj/carp_lasso.dmi'
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/simple_animal/hostile/carp/carp_target

/obj/item/carp_lasso/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/carp))
		var/mob/living/simple_animal/hostile/carp/C = target
		if(user.a_intent == INTENT_HELP && C == carp_target) //if trying to tie up previous target
			to_chat(user, "<span class='notice'>You begin to untie the [C]</span>")
			if(proximity_flag && do_after(user, 2 SECONDS, FALSE, target))
				user.faction |= "carpboy_[user]"
				C.faction |= "carpboy_[user]"
				C.faction |= user.faction
				C.transform = transform.Turn(0)
				C.tame = TRUE
				C.toggle_ai(AI_ON)
				C.carp_command_comp = C.AddComponent(/datum/component/carp_command)
				C.carp_command_comp.cares_about_ally |= user
				C.carp_command_comp.update_ally()
				C.ghetto_processing()
				to_chat(user, "<span class='notice'>The [C] nuzzles you.</span>")
				UnregisterSignal(carp_target, COMSIG_PARENT_QDELETING)
				carp_target = null
				if(timer)
					deltimer(timer)
					timer = null
				return
		else if(timer) //if trying to add new target while old target is still flipped
			to_chat(user, "<span class='warning'>You can't do that right now!</span>")
			return
		//Do lasso/beam for style points
		var/datum/beam/B = new(loc, C, time=1 SECONDS, beam_icon='icons/effects/beam.dmi', beam_icon_state="carp_lasso", btype=/obj/effect/ebeam)
		INVOKE_ASYNC(B, /datum/beam/.proc/Start)
		C.unbuckle_all_mobs()
		carp_target = C
		C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
		C.transform = transform.Turn(180)
		C.toggle_ai(AI_OFF)
		RegisterSignal(C, COMSIG_PARENT_QDELETING, .proc/handle_hard_del)
		to_chat(user, "<span class='notice'>You lasso the [C]!</span>")
		timer = addtimer(CALLBACK(src, .proc/fail_ally), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back

/obj/item/carp_lasso/proc/fail_ally()
	visible_message("<span class='warning'>The [carp_target] breaks free!</span>")
	carp_target?.transform = transform.Turn(0)
	carp_target.toggle_ai(AI_ON)
	UnregisterSignal(carp_target, COMSIG_PARENT_QDELETING)
	carp_target = null
	timer = null

/obj/item/carp_lasso/proc/handle_hard_del()
	carp_target = null
