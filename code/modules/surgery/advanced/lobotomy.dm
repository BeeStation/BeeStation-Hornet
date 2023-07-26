/datum/surgery/advanced/lobotomy
	name = "Lobotomy"
	desc = "An invasive surgical procedure which guarantees removal of almost all brain traumas, but might cause another permanent trauma in return."
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/lobotomize,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery/advanced/lobotomy/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/lobotomize
	name = "perform lobotomy"
	implements = list(TOOL_SCALPEL = 85, /obj/item/melee/transforming/energy/sword = 55, /obj/item/kitchen/knife = 35,
		/obj/item/shard = 25, /obj/item = 20)
	time = 100
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/lobotomize/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	return TRUE

/datum/surgery_step/lobotomize/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform a lobotomy on [target]'s brain...</span>",
		"[user] begins to perform a lobotomy on [target]'s brain.",
		"[user] begins to perform surgery on [target]'s brain.")

/datum/surgery_step/lobotomize/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed in lobotomizing [target].</span>",
			"[user] successfully lobotomizes [target]!",
			"[user] completes the surgery on [target]'s brain.")
	target.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	if(target.mind)
		if(target.mind.has_antag_datum(/datum/antagonist/brainwashed))
			unbrainwash(target)
		// Remove abductee objectives.
		var/datum/antagonist/abductee/abductee = target.mind.has_antag_datum(/datum/antagonist/abductee)
		if(abductee && length(abductee.objectives))
			if(istype(target.getorganslot(ORGAN_SLOT_HEART), /obj/item/organ/heart/gland))
				target.visible_message("<span class='warning'>[target]'s facial expression relaxes for a second, before seeming stressed once more.</span>")
				to_chat(target, "<span class='danger'>You feel <span class='hypnophrase'>free</span> from the objective imprinted upon your broken psyche for a second... but it takes hold of you once more.</span>")
			else
				message_admins("[ADMIN_LOOKUPFLW(user)] removed [ADMIN_LOOKUPFLW(target)]'s abductee objectives with a lobotomy.")
				log_game("[key_name(user)] removed [key_name(target)]'s abductee objectives with a lobotomy.")
				for(var/datum/objective/abductee/objective in abductee.objectives)
					abductee.cured_objectives |= objective.explanation_text
				QDEL_LIST(abductee.objectives)
				to_chat(target, "<span class='userdanger'>You're <span class='hypnophrase'>FREE</span>! The obsessions imprinted upon your broken psyche no longer has any hold over you, although you cannot remember any actions you took while under the influence of them...</span>")
				switch(target.stat)
					if(CONSCIOUS)
						// dramatically faint, to give them a bit of time to come to terms with being free.
						target.Unconscious(30 SECONDS)
						target.visible_message("<span class='warning'>[target] suddenly faints, [target.p_their()] body relaxing as if [target.p_theyve()] been freed from a deep stress!</span>")
					if(UNCONSCIOUS)
						target.visible_message("<span class='warning'>[target]'s facial expression relaxes, as if [target.p_theyve()] been freed from a deep stress!</span>")
					else
						SWITCH_EMPTY_STATEMENT // they're dead, how tf you gonna tell?
				target.mind.announce_objectives()
	switch(rand(0, 3))//Now let's see what hopefully-not-important part of the brain we cut off
		if(1)
			target.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(HAS_TRAIT(target, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
		else
			SWITCH_EMPTY_STATEMENT
	return TRUE

/datum/surgery_step/lobotomize/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		display_results(user, target, "<span class='warning'>You remove the wrong part, causing more damage!</span>",
			"[user] successfully lobotomizes [target]!",
			"[user] completes the surgery on [target]'s brain.")
		B.applyOrganDamage(80)
		switch(rand(1,3))
			if(1)
				target.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
			if(2)
				if(HAS_TRAIT(target, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
					target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
				else
					target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
			if(3)
				target.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	return FALSE
