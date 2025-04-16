
/obj/item/clothing/gloves
	var/transfer_blood = 0


/obj/item/reagent_containers/cup/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 5
	has_variable_transfer_amount = FALSE
	volume = 5
	spillable = FALSE

/obj/item/reagent_containers/cup/rag/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is smothering [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/reagent_containers/cup/rag/afterattack(atom/A as obj|turf|area, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(iscarbon(A) && A.reagents && reagents.total_volume)
		var/mob/living/carbon/C = A
		var/reagentlist = pretty_string_from_reagent_list(reagents)
		var/log_object = "containing [reagentlist]"
		if(user.combat_mode && !C.is_mouth_covered())
			reagents.expose(C, INGEST)
			reagents.trans_to(C, reagents.total_volume, transfered_by = user)
			C.visible_message(span_danger("[user] has smothered \the [C] with \the [src]!"), span_userdanger("[user] has smothered you with \the [src]!"), span_italics("You hear some struggling and muffled cries of surprise."))
			log_combat(user, C, "smothered", src, log_object)
		else
			reagents.expose(C, TOUCH)
			reagents.clear_reagents()
			C.visible_message(span_notice("[user] has touched \the [C] with \the [src]."))
			log_combat(user, C, "touched", src, log_object)

	else if(istype(A) && (src in user))
		user.visible_message("[user] starts to wipe down [A] with [src]!", span_notice("You start to wipe down [A] with [src]..."))
		if(do_after(user,30, target = A))
			user.visible_message("[user] finishes wiping off [A]!", span_notice("You finish wiping off [A]."))
			A.wash(CLEAN_SCRUB)
			A.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			if(isclothing(A) && HAS_TRAIT(A, TRAIT_SPRAYPAINTED))
				var/obj/item/clothing/C = A
				var/mob/living/carbon/human/H = user
				C.flash_protect -= 1
				C.tint -= 2
				H.update_tint()
				REMOVE_TRAIT(A, TRAIT_SPRAYPAINTED, CRAYON_TRAIT)
