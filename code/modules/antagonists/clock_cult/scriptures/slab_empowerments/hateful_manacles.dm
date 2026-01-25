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

//For the Hateful Manacles scripture; applies replicant handcuffs to the clicked_on.

/datum/clockcult/scripture/slab/hateful_manacles/on_slab_attack(atom/target, mob/user, ranged_attack)
	var/turf/T = user.loc
	if(!isturf(T))
		return FALSE

	if(!iscarbon(target) || ranged_attack)
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(IS_SERVANT_OF_RATVAR(carbon_target))
		to_chat(user, span_neovgre("\"[carbon_target.p_Theyre()] a servant.\""))
		return FALSE
	else if(carbon_target.stat)
		to_chat(user, span_neovgre("\"There is use in shackling the dead, but for examples.\""))
		return FALSE
	else if (istype(carbon_target.handcuffed, /obj/item/restraints/handcuffs/clockwork))
		to_chat(user, span_neovgre("\"[carbon_target.p_Theyre()] already helpless, no?\""))
		return FALSE
	do_cuff(carbon_target, user)
	return TRUE

/datum/clockcult/scripture/slab/hateful_manacles/proc/do_cuff(mob/living/carbon/target, mob/user)
	set waitfor = FALSE
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
	user.visible_message(span_danger("[user] begins forming manacles around [target]'s wrists!"), \
	("<span class='neovgre_small'>You begin shaping replicant alloy into manacles around [target]'s wrists...</span>"))
	to_chat(target, span_userdanger("[user] begins forming manacles around your wrists!"))
	if(do_after(user, 3 SECONDS, target))
		if(!(istype(target.handcuffed, /obj/item/restraints/handcuffs/clockwork)))
			var/obj/item/restraints/handcuffs/clockwork/restraints = new(target)
			if (!restraints.apply_cuffs(target, user))
				qdel(restraints)
				return TRUE
			restraints.item_flags |= DROPDEL

			to_chat(user, "<span class='neovgre_small'>You shackle [target].</span>")
			log_combat(user, target, "handcuffed")
	else
		to_chat(user, span_warning("You fail to shackle [target]."))

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	inhand_icon_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	user.visible_message(("<span class='danger'>[user]'s [name] come apart at the seams!</span>"), \
	("<span class='userdanger'>Your [name] break apart as they're removed!</span>"))
	. = ..()
