//==================================//
// !       Hateful Manacles       ! //
//==================================//
/datum/clockcult/scripture/slab/hateful_manacles
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs, restraining the target."
	tip = "Handcuff a target at close range to subdue them for conversion or vitality extraction."
	button_icon_state = "Hateful Manacles"
	power_cost = 25
	invokation_time = 15
	invokation_text = list("Shackle the heretic...", "Break them in body and spirit!")
	slab_overlay = "hateful_manacles"
	use_time = 200
	cogs_required = 0
	category = SPELLTYPE_SERVITUDE
	empowerment = "manacles"

//For the Hateful Manacles scripture; applies replicant handcuffs to the clicked_on.

/obj/item/clockwork/clockwork_slab/proc/hateful_manacles(mob/living/caller, atom/clicked_on)
	empowerment = null
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(iscarbon(clicked_on) && clicked_on.Adjacent(caller))
		var/mob/living/carbon/L = clicked_on
		if(is_servant_of_ratvar(L))
			to_chat(caller, span_neovgre("\"[L.p_theyre(TRUE)] a servant.\""))
			return FALSE
		else if(L.stat)
			to_chat(caller, span_neovgre("\"There is use in shackling the dead, but for examples.\""))
			return FALSE
		else if (istype(L.handcuffed, /obj/item/restraints/handcuffs/clockwork))
			to_chat(caller, span_neovgre("\"[L.p_theyre(TRUE)] already helpless, no?\""))
			return FALSE

		playsound(caller.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
		caller.visible_message(span_danger("[caller] begins forming manacles around [L]'s wrists!"), \
		"[span_neovgre_small("You begin shaping replicant alloy into manacles around [L]'s wrists...")]")
		to_chat(L, span_userdanger("[caller] begins forming manacles around your wrists!"))
		if(do_after(caller, 3 SECONDS, L))
			if(!(istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork)))
				L.set_handcuffed(new /obj/item/restraints/handcuffs/clockwork(L))
				L.update_handcuffed()
				to_chat(caller, "[span_neovgre_small("You shackle [L].")]")
				log_combat(caller, L, "handcuffed")
		else
			to_chat(caller, span_warning("You fail to shackle [L]."))
	return TRUE

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	item_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	user.visible_message(span_danger("[user]'s [name] come apart at the seams!"), \
	span_userdanger("Your [name] break apart as they're removed!"))
	. = ..()
