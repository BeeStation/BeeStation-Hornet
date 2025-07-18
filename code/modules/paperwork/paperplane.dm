/obj/item/origami/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon_state = "paperplane"
	custom_fire_overlay = "paperplane_onfire"
	throw_range = 7

	var/hit_probability = 2 //%

/obj/item/origami/paperplane/syndicate
	desc = "Paper, masterfully folded in the shape of a plane."
	throwforce = 20 //same as throwing stars, but no chance of embedding.
	hit_probability = 100 //guaranteed to cause eye damage when it hits a mob.

/obj/item/origami/paperplane/suicide_act(mob/living/user)
	var/obj/item/organ/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	user.Stun(200)
	user.visible_message(span_suicide("[user] jams [src] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!"))
	user.adjust_blurriness(6)
	if(eyes)
		eyes.applyOrganDamage(rand(6,8))
	sleep(10)
	return BRUTELOSS

/obj/item/origami/paperplane/update_icon()
	cut_overlays()
	for(var/stamp in internalPaper.stamp_cache)
		add_overlay("paperplane_[stamp]")

/obj/item/origami/paperplane/attack_self(mob/user)
	to_chat(user, span_notice("You unfold [src]."))
	var/obj/item/paper/internal_paper_tmp = internalPaper
	internal_paper_tmp.forceMove(loc)
	internalPaper = null
	qdel(src)
	user.put_in_hands(internal_paper_tmp)

/obj/item/origami/paperplane/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(burn_paper_product_attackby_check(P, user))
		return
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, span_notice("You should unfold [src] before changing it."))
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on a paperplane
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()
		add_fingerprint(user)
		return

	return ..()

/obj/item/origami/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE, datum/callback/callback, quickstart = TRUE)
	. = ..(target, range, speed, thrower, FALSE, diagonals_first, callback, quickstart = quickstart)


/obj/item/origami/paperplane/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		if(C.can_catch_item(TRUE))
			var/datum/action/innate/origami/origami_action = locate() in C.actions
			if(origami_action?.is_active()) //if they're a master of origami and have the ability turned on, force throwmode on so they'll automatically catch the plane.
				C.throw_mode_on(THROW_MODE_TOGGLE)

	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	var/mob/living/carbon/human/H = hit_atom
	var/obj/item/organ/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
	if(prob(hit_probability))
		if(H.is_eyes_covered())
			return
		visible_message(span_danger("\The [src] hits [H] in the eye!"))
		H.adjust_blurriness(6)
		eyes.applyOrganDamage(rand(6,8))
		H.Paralyze(40)
		H.emote("scream")
