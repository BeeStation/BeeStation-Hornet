#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.005 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Pairing suggestion: chianti and fava beans."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

	var/alcohol_tolerance = ALCOHOL_RATE//affects how much damage the liver takes from alcohol
	/// The maximum volume of toxins the liver will quickly purge
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE
	/// Scaling factor for how much damage toxins deal to the liver
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY
	var/filterToxins = TRUE //whether to filter toxins

#define HAS_SILENT_TOXIN 0 //don't provide a feedback message if this is the only toxin present
#define HAS_NO_TOXIN 1
#define HAS_PAINFUL_TOXIN 2

/obj/item/organ/liver/on_life(delta_time, times_fired)
	var/mob/living/carbon/C = owner
	..() //perform general on_life()
	if(istype(C))
		if(!(organ_flags & ORGAN_FAILING) && !HAS_TRAIT(C, TRAIT_NOMETABOLISM))//can't process reagents with a failing liver

			var/provide_pain_message = HAS_NO_TOXIN
			if(filterToxins && !HAS_TRAIT(owner, TRAIT_TOXINLOVER))
				//handle liver toxin filtration
				for(var/datum/reagent/toxin/T in C.reagents.reagent_list)
					var/thisamount = C.reagents.get_reagent_amount(T.type)
					if (thisamount && thisamount <= toxTolerance)
						C.reagents.remove_reagent(T.type, 0.5 * delta_time)
					else
						damage += (thisamount * toxLethality * delta_time)
						if(provide_pain_message != HAS_PAINFUL_TOXIN)
							provide_pain_message = T.silent_toxin ? HAS_SILENT_TOXIN : HAS_PAINFUL_TOXIN

			//metabolize reagents
			C.reagents.metabolize(C, delta_time, times_fired, can_overdose=TRUE)

			if(provide_pain_message && damage > 10 && DT_PROB(damage/6, delta_time)) //the higher the damage the higher the probability
				to_chat(C, span_warning("You feel a dull pain in your abdomen."))

		else //for when our liver's failing
			C.liver_failure(delta_time, times_fired)

	if(damage > maxHealth)//cap liver damage
		damage = maxHealth

#undef HAS_SILENT_TOXIN
#undef HAS_NO_TOXIN
#undef HAS_PAINFUL_TOXIN

/obj/item/organ/liver/get_availability(datum/species/S)
	return !(TRAIT_NOMETABOLISM in S.species_traits)

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "liver-p"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/alien
	name = "alien liver" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "A liver that used to belong to a killer alien, who knows what it used to eat."
	toxTolerance = 15 // complete toxin immunity like xenos have would be too powerful
	toxLethality = 2.5 * LIVER_DEFAULT_TOX_LETHALITY // rejects its owner early after too much punishment

/obj/item/organ/liver/cybernetic
	name = "cybernetic liver"
	icon_state = "liver-c"
	desc = "An electronic device designed to mimic the functions of a human liver. Handles toxins slightly better than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = 1.1 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 3.3
	toxLethality = 0.8 * LIVER_DEFAULT_TOX_LETHALITY //20% less damage than a normal liver

/obj/item/organ/liver/cybernetic/upgraded
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An upgraded version of the cybernetic liver, designed to improve further upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 15 //can shrug off up to 15u of toxins
	toxLethality = 0.8 * LIVER_DEFAULT_TOX_LETHALITY //20% less damage than a normal liver

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		damage += (30/severity)

/obj/item/organ/liver/cybernetic/upgraded/ipc
	name = "substance processor"
	icon_state = "substance_processor"
	attack_verb_continuous = list("processes")
	attack_verb_simple = list("process")
	desc = "A machine component, installed in the chest. This grants the Machine the ability to process chemicals that enter its systems."
	alcohol_tolerance = 0
	toxTolerance = -1
	toxLethality = 0
	status = ORGAN_ROBOTIC

/obj/item/organ/liver/cybernetic/upgraded/ipc/emp_act(severity)
	if(prob(30/severity))
		to_chat(owner, span_warning("Alert: Your Substance Processor has been damaged. An internal chemical leak is affecting performance."))
		owner.adjustToxLoss(8/severity)

/obj/item/organ/liver/diona
	name = "liverwort"
	desc = "A mass of plant vines and leaves, seeming to be responsible for chemical digestion."
	icon_state = "diona_liver"

#undef LIVER_DEFAULT_TOX_TOLERANCE
#undef LIVER_DEFAULT_TOX_LETHALITY
