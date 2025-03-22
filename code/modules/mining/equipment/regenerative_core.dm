/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "stabilizing serum"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject certain types of monster organs with this stabilizer to preserve their healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/M, mob/user)
	. = ..()
	var/obj/item/organ/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/regenerative_core))
		to_chat(user, span_warning("The stabilizer only works on certain types of monster organs, generally regenerative in nature."))
		return ..()
	if(C.preserved)
		to_chat(user, span_notice("[M] is already stabilised."))
		return
	if(C.inert)
		to_chat(user, span_notice("[M] is inert, it's not worth it to stabilize a nonfunctional one."))
		return
	C.preserved()
	to_chat(user, span_notice("You inject [M] with the stabilizer. It will no longer go inert."))
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon_state = "roro core 2"
	visual = FALSE
	item_flags = NOBLUDGEON
	organ_flags = null
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/regenerative_core/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(inert_check)), 2400)

/obj/item/organ/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/regenerative_core/proc/preserved(implanted = 0)
	preserved = TRUE
	update_icon()
	desc = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	if(implanted)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "implanted"))
	else
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "stabilizer"))

/obj/item/organ/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "inert"))
	update_icon()

/obj/item/organ/regenerative_core/ui_action_click()
	if(!z == 5 && !preserved)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate without the necropolis' power."))
	else if(inert)
		to_chat(owner, span_notice("[src] breaks down as it tries to activate."))
	else
		owner.apply_status_effect(/datum/status_effect/regenerative_core)
	qdel(src)

/obj/item/organ/regenerative_core/on_life()
	..()
	if(owner.health <= owner.crit_threshold)
		ui_action_click()

///Handles applying the core, logging and status/mood events.
/obj/item/organ/regenerative_core/proc/applyto(atom/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			to_chat(user, span_notice("[src] has decayed and can no longer be used to heal."))
			return
		else
			if(H.stat == DEAD)
				to_chat(user, span_notice("[src] is useless on the dead."))
				return
			if(H != user)
				to_chat(user, span_notice("You begin to rub the regenerative core on [H]..."))
				to_chat(H, span_userdanger("[user] begins to smear the regenerative core all over you..."))
				if(do_after(user, 3 SECONDS, H))
					H.visible_message("[user] forces [H] to apply [src]... [H.p_they()] quickly regenerates all injuries!")
					SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
				else
					return
			else
				to_chat(user, span_notice("You start to smear [src] on yourself. It feels and smells disgusting, but you feel amazingly refreshed in mere moments."))
				SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
			if(HAS_TRAIT(H, TRAIT_NECROPOLIS_INFECTED))
				H.ForceContractDisease(new /datum/disease/transformation/legion())
				to_chat(H, span_userdanger("You feel the necropolis strengthen its grip on your heart and soul... You're powerless to resist for much longer..."))
			H.apply_status_effect(/datum/status_effect/regenerative_core)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman) //Now THIS is a miner buff (fixed - nerf)
			qdel(src)

/obj/item/organ/regenerative_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		applyto(target, user)

/obj/item/organ/regenerative_core/attack_self(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		applyto(user, user)

/obj/item/organ/regenerative_core/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	. = ..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message(span_notice("[src] stabilizes as it's inserted."))

/obj/item/organ/regenerative_core/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	if(!inert && !special)
		owner.visible_message(span_notice("[src] rapidly decays as it's removed."))
		go_inert()
	return ..()

/*************************Legion core********************/
/obj/item/organ/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but, outside of the insulating legion, it will rapidly decay into uselessness, and completely fail to work if not within the vicinity of the Necropolis."
	icon_state = "legion_soul"

/obj/item/organ/regenerative_core/legion/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/organ/regenerative_core/update_icon_state()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	return ..()

/obj/item/organ/regenerative_core/update_overlays()
	. = ..()
	if(!inert && !preserved)
		. += "legion_soul_crackle"

/obj/item/organ/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has lost all of the power of the Necropolis and died."

/obj/item/organ/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. However, if not in vicinity of the Necropolis, its power will be diminished."
