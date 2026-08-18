/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	desc = "If left untreated the subject will become very weak, and may vomit often."
	danger = DISEASE_MEDIUM
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organ = ORGAN_SLOT_APPENDIX
	bypasses_immunity = TRUE // Immunity is based on not having an appendix; this isn't a virus

/datum/disease/appendicitis/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/appendix/A = affected_mob.get_organ_by_type(/obj/item/organ/appendix)
			if(A)
				A.inflamed = 1
				A.update_appearance()
			if(DT_PROB(1.5, delta_time))
				to_chat(affected_mob, span_warning("You feel a stabbing pain in your abdomen!"))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 5)
				affected_mob.Stun(rand(40, 60))
				affected_mob.adjustToxLoss(1, forced = TRUE)
		if(3)
			if(DT_PROB(0.5, delta_time))
				affected_mob.vomit(95)
				affected_mob.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 15)

/datum/disease/appendicitis/cure(add_resistance)
	var/obj/item/organ/appendix/A = affected_mob.get_organ_by_type(/obj/item/organ/appendix)
	if(A)
		A.inflamed = FALSE
		A.update_icon()
	return ..()
