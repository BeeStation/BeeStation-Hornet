/obj/item/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON

/obj/item/rag/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)
	AddComponent(/datum/component/cleaner, 3 SECONDS, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)))

/obj/item/rag/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is smothering [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/rag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target) || !reagents?.total_volume)
		return
	var/mob/living/carbon/carbon_target = target
	var/log_object = "containing [pretty_string_from_reagent_list(reagents)]"
	if(!carbon_target.is_mouth_covered())
		reagents.expose(carbon_target, INGEST)
		reagents.trans_to(carbon_target, reagents.total_volume, transfered_by = user)
		carbon_target.visible_message(
			span_danger("[user] smothers \the [carbon_target] with \the [src]!"),
			span_userdanger("[user] smothers you with \the [src]!"), span_hear("You hear some struggling and muffled cries of surprise."),
		)
		log_combat(user, carbon_target, "smothered", src, log_object)
	else
		reagents.expose(carbon_target, TOUCH)
		reagents.clear_reagents()
		carbon_target.visible_message(span_notice("[user] touches \the [carbon_target] with \the [src]."))
		log_combat(user, carbon_target, "touched", src, log_object)

///Checks whether or not we should clean.
/obj/item/rag/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(cleaner.combat_mode && ismob(atom_to_clean))
		return CLEAN_BLOCKED
	return CLEAN_ALLOWED
