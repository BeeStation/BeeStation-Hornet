//==================================//
// !       Hateful Manacles       ! //
//==================================//
/datum/clockcult/scripture/slab/hateful_manacles
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs, restraining the target."
	tip = "Handcuff a target at close range."
	button_icon_state = "Hateful Manacles"
	power_cost = 25
	invokation_time = 15
	invokation_text = list("Shackle the heretic...", "...Break them in body and spirit!")
	slab_overlay = "hateful_manacles"
	use_time = 200
	cogs_required = 0
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/hateful_manacles/apply_effects(atom/A)
	. = ..()
	var/mob/living/carbon/M = A
	if(!istype(M))
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(M.handcuffed)
		to_chat(invoker, "<span class='brass'>[M] is already restrained!</span>")
		return FALSE
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	M.visible_message("<span class='danger'>[invoker] forms a well of energy around [M], brass appearing at their wrists!</span>",\
						"<span class='userdanger'>[invoker] is trying to restrain you!</span>")
	if(do_after(invoker, 50, target=M))
		if(M.handcuffed)
			return FALSE
		//Todo, update with custom cuffs
		M.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(M)
		M.update_handcuffed()
		return TRUE
	return FALSE
