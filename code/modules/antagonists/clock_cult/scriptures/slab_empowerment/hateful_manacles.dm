/datum/clockcult/scripture/slab/hateful_manacles
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs, restraining the target."
	tip = "Handcuff a target at close range to subdue them for conversion or vitality extraction."
	invokation_text = list("Shackle the heretic...", "Break them in body and spirit!")
	invokation_time = 1.5 SECONDS
	max_time = 2 SECONDS
	button_icon_state = "Hateful Manacles"
	slab_overlay = "hateful_manacles"
	power_cost = 25
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/hateful_manacles/apply_effects(atom/target_atom)
	. = ..()
	if(!iscarbon(target_atom))
		return FALSE

	var/mob/living/carbon/carbon_target = target_atom

	if(IS_SERVANT_OF_RATVAR(carbon_target))
		return FALSE
	if(carbon_target.handcuffed)
		invoker.balloon_alert(invoker, "already restrained!")
		return FALSE

	// Flavor
	playsound(carbon_target, 'sound/weapons/handcuffs.ogg', 30, TRUE, -2)
	carbon_target.visible_message(
		span_danger("[invoker] forms a well of energy around [carbon_target], brass appearing at their wrists!"),
		span_userdanger("[invoker] is trying to restrain you!")
	)

	// Try to cuff target
	if(!do_after(invoker, 3 SECONDS, target = carbon_target))
		return FALSE

	if(carbon_target.handcuffed)
		return FALSE

	// Cuff target
	var/obj/item/restraints/handcuffs/clockwork/restraints = new(carbon_target)
	if(!restraints.apply_cuffs(carbon_target, invoker))
		qdel(restraints)
		return

	log_combat(invoker, carbon_target, "handcuffed", src)

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	inhand_icon_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	. = ..()
	user.visible_message(
		span_danger("[user]'s [name] come apart at the seams!"),
		span_userdanger("Your [name] break apart as they're removed!")
	)
