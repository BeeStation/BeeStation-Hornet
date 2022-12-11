/obj/item/mob_lasso
	name = "space lasso"
	desc = "Comes standard with every space-cowboy.\nCan be used to tame space carp."
	icon = 'icons/obj/carp_lasso.dmi'
	icon_state = "lasso"
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/simple_animal/mob_target
	///Whitelist of allowed animals
	var/list/whitelist_mobs = list(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/cow, /mob/living/simple_animal/hostile/retaliate/dolphin)

/obj/item/mob_lasso/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target) && check_allowed(target) && !iscarbon(target) && !issilicon(target) && locate(target) in oview(9, get_turf(src)))
		var/mob/living/simple_animal/C = target
		if(IS_DEAD_OR_INCAP(C))
			to_chat(user, "<span class='warning'>[target] is dead.</span>")
			return
		if(user.a_intent == INTENT_HELP && C == mob_target) //if trying to tie up previous target
			to_chat(user, "<span class='notice'>You begin to untie [C]</span>")
			if(proximity_flag && do_after(user, 2 SECONDS, FALSE, target))
				user.faction |= "carpboy_[user]"
				C.faction |= "carpboy_[user]"
				C.faction |= user.faction
				C.transform = transform.Turn(0)
				C.toggle_ai(AI_ON)
				var/datum/component/tamed_command/T = C.AddComponent(/datum/component/tamed_command)
				T.add_ally(user)
				to_chat(user, "<span class='notice'>[C] nuzzles you.</span>")
				UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
				mob_target = null
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
		mob_target = C
		C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
		C.transform = transform.Turn(180)
		C.toggle_ai(AI_OFF)
		RegisterSignal(C, COMSIG_PARENT_QDELETING, .proc/handle_hard_del)
		to_chat(user, "<span class='notice'>You lasso [C]!</span>")
		timer = addtimer(CALLBACK(src, .proc/fail_ally), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back
	else
		to_chat(user, "<span class='notice'>[target] seems a bit big for this...</span>")

/obj/item/mob_lasso/proc/check_allowed(atom/target)
	return (locate(target) in whitelist_mobs)


/obj/item/mob_lasso/proc/fail_ally()
	visible_message("<span class='warning'>[mob_target] breaks free!</span>")
	mob_target?.transform = transform.Turn(0)
	mob_target.toggle_ai(AI_ON)
	UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
	mob_target = null
	timer = null

/obj/item/mob_lasso/proc/handle_hard_del()
	mob_target = null

///Primal version, allows lavaland goobers to tame goliaths
/obj/item/mob_lasso/primal
	name = "primal lasso"
	desc = "Found amongst Ash Walker tools.\nCan be used to tame goliaths."
	whitelist_mobs = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/goldgrub)

/obj/item/mob_lasso/antag
	name = "bluespace lasso"
	desc = "Comes standard with every evil space-cowboy!\nCan be used to tame almost anything."
	///blacklist of disallowed mobs
	var/list/blacklist_mobs = list(/mob/living/simple_animal/hostile/megafauna, /mob/living/simple_animal/hostile/alien, /mob/living/simple_animal/hostile/syndicate)

/obj/item/mob_lasso/antag/check_allowed(atom/target)
	//do type checking becuase I didn't think this through
	for(var/atom/type as () in blacklist_mobs)
		if(istype(target, type))
			return FALSE
	return(!locate(target) in blacklist_mobs)

/obj/item/mob_lasso/antag/debug
	name = "debug lasso"
	desc = "Comes standard with every administrator space-cowboy!\nCan be used to tame anything."
	blacklist_mobs = list() //anything goes

