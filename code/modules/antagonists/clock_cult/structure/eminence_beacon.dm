/obj/structure/destructible/clockwork/eminence_beacon
	name = "eminence spire"
	desc = "An ancient, brass spire which holds the spirit of a powerful entity conceived by Rat'var to oversee his faithful servants."
	icon_state = "tinkerers_daemon"
	resistance_flags = INDESTRUCTIBLE
	var/used = FALSE
	var/vote_active = FALSE
	var/vote_timer

/obj/structure/destructible/clockwork/eminence_beacon/attack_hand(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	if(vote_active)
		deltimer(vote_timer)
		vote_timer = null
		vote_active = FALSE
		hierophant_message("[user] has cancelled the Eminence vote.")
		return
	if(used)
		to_chat(user, "<span class='brass'>The Eminence has already been released.</span>")
		return
	var/option = alert(user,"Who shall control the Eminence?",,"Yourself","A ghost", "Cancel")
	if(option != "A ghost")
		return
	else if(option == "Yourself")
		hierophant_message("[user] has elected themselves to become the Eminence. Interact with [src] to object.", span="<span=large_brass>")
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed), user), 600, TIMER_STOPPABLE)
	else if(option == "A ghost")
		hierophant_message("[user] has elected for a ghost to become the Eminence. Interact with [src] to object.")
		vote_timer = addtimer(CALLBACK(src, PROC_REF(vote_succeed)), 600, TIMER_STOPPABLE)
	vote_active = TRUE

/obj/structure/destructible/clockwork/eminence_beacon/proc/vote_succeed(mob/eminence)
	vote_active = FALSE
	used = TRUE
	if(!eminence)
		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the eminence?", ROLE_SERVANT_OF_RATVAR, /datum/role_preference/antagonist/clock_cultist, 10 SECONDS)
		if(LAZYLEN(candidates))
			eminence = pick(candidates)
	else
		eminence.dust()
	if(!(eminence?.client))
		hierophant_message("The Eminence remains in slumber, for now, try waking it again soon.")
		used = FALSE
		return
	var/mob/new_mob = new /mob/living/simple_animal/eminence(get_turf(src))
	new_mob.key = eminence.key
	hierophant_message("The Eminence has risen!")
