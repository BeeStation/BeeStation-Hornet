/**********************Lazarus Injector**********************/
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead. Testing has shown inconsistent results and the animals with especially strong wills may attack the person reviving them."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it

/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!loaded)
		return
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, span_info("[src] does not work on this sort of creature."))
				return
			if(M.stat == DEAD)
				loaded = 0
				if(M.mind)
					if(M.suiciding || M.ishellbound())
						user.visible_message(span_notice("[user] injects [M] with [src], but nothing happened."))
						return
					process_revival(M)
					M.AIStatus = AI_OFF // don't let them attack people randomly after revived

					//Try to notify the ghost that they are being revived, but also that they are not loyal to the reviver
					var/mob/ghostmob = M.notify_ghost_cloning("Your body is revived by [user] with a lazarus injector!", source=M)
					if(ghostmob)
						to_chat(ghostmob, span_userdanger("Lazarus does not change your loyalties or force obedience to [user] if you weren't already under their control."))
					log_game("[key_name(user)] has revived a player mob [key_name(target)] with a lazarus injector")

				else // only do this to mindless mobs
					process_revival(M)
					if(ishostile(target))
						var/mob/living/simple_animal/hostile/H = M
						H.faction = list(FACTION_NEUTRAL, "[REF(user)]") //Neutral includes crew and entirely passive mobs
						H.robust_searching = 1
						H.friends += user
						if(malfunctioning)
							H.attack_same = 1 //Will attack all other mobs and crew, but not the person who revived
							log_game("[key_name(user)] has revived hostile mob [key_name(target)] with a malfunctioning lazarus injector")
						else
							H.attack_same = 0 //Will only attack non-passive mobs
							if(prob(10)) //chance of sentience without loyalty
								var/list/candidates = poll_candidates_for_mob("Do you want to play as [H] being revived by [src]?", ROLE_SENTIENCE, null, 15 SECONDS, H)
								if(length(candidates))
									var/mob/dead/observer/C = pick(candidates)
									H.key = C.key
									H.sentience_act()
									to_chat(H, span_userdanger("In a striking moment of clarity you have gained greater intellect. You feel no strong sense of loyalty to anyone or anything, you simply feel... free"))

				user.visible_message(span_notice("[user] injects [M] with [src], reviving it."))
				SSblackbox.record_feedback("tally", "lazarus_injector", 1, M.type)
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, span_info("[src] is only effective on the dead."))
				return
		else
			to_chat(user, span_info("[src] is only effective on lesser beings."))
			return

/obj/item/lazarus_injector/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/proc/process_revival(mob/living/simple_animal/target)
			target.do_jitter_animation(10)
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, do_jitter_animation), 10), 5 SECONDS)
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, revive), TRUE, TRUE), 10 SECONDS)

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += span_info("[src] is empty.")
	if(malfunctioning)
		. += span_info("The display on [src] seems to be flickering.")
