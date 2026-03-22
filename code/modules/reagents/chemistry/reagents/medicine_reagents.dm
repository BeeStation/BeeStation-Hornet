
//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	name = "Medicine"
	chemical_flags = CHEMICAL_NOT_DEFINED
	taste_description = "bitterness"

/datum/reagent/medicine/New()
	. = ..()
	// All medicine metabolizes out slower / stay longer if you have a better metabolism
	chemical_flags |= REAGENT_REVERSE_METABOLISM

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Leporazine will effectively regulate a patient's body temperature, ensuring it never leaves safe levels."
	color = "#DB90C6"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/target_temp = affected_mob.get_body_temp_normal(apply_change = FALSE)
	if(affected_mob.bodytemperature > target_temp)
		affected_mob.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, target_temp)
	else if(affected_mob.bodytemperature < (target_temp + 1))
		affected_mob.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 0, target_temp)

	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		if(affected_human.coretemperature > target_temp)
			affected_human.adjust_coretemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, target_temp)
		else if(affected_human.coretemperature < (target_temp + 1))
			affected_human.adjust_coretemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 0, target_temp)

/datum/reagent/medicine/leporazine/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.adjust_bodytemperature((prob(50) ? 200 : -200), 0)

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#E0BB00" //golden for the gods
	chemical_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "badmins"
	/// Flags to fullheal every metabolism tick
	var/full_heal_flags = ~(HEAL_BRUTE|HEAL_BURN|HEAL_TOX|HEAL_RESTRAINTS|HEAL_ORGANS)

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.heal_bodypart_damage(brute = 5 * REM * delta_time, burn = 5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustToxLoss(-5 * REM * delta_time, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
	// Heal everything! That we want to. But really don't heal reagents. Otherwise we'll lose ... us.
	affected_mob.fully_heal(full_heal_flags & ~HEAL_ALL_REAGENTS)

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rare and experimental particles, that apparently swap the user's body with one from an alternate dimension where it's completely healthy."
	taste_description = "science"

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Increases resistance to stuns as well as reducing drowsiness and hallucinations."
	color = COLOR_MAGENTA
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	affected_mob.AdjustAllImmobility(-20 * REM * delta_time)

	if(affected_mob.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
		affected_mob.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * delta_time)

	affected_mob.adjust_hallucinations(-20 SECONDS * REM * delta_time)
	if(DT_PROB(16, delta_time))
		if(affected_mob.adjustToxLoss(1, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_drowsiness(-10 SECONDS * REM * delta_time)
	if(affected_mob.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
		affected_mob.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5 * REM * delta_time)
	if(affected_mob.reagents.has_reagent(/datum/reagent/toxin/histamine))
		affected_mob.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5 * REM * delta_time)
	. = ..()
	affected_mob.adjust_hallucinations(-20 SECONDS * REM * delta_time)
	if(DT_PROB(16, delta_time))
		if(affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Rapidly repairs damage to the patient's ears to cure deafness, assuming the source of said deafness isn't from genetic mutations, chronic deafness, or a total defecit of ears." //by "chronic" deafness, we mean people with the "deaf" quirk
	color = "#606060" //inacusiate is light grey, oculine is dark grey
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/obj/item/organ/ears/ears = affected_mob.get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		return
	ears.adjustEarDamage(-4 * REM * delta_time, -4 * REM * delta_time)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the patient's body temperature must be under 270K for it to metabolise correctly."
	color = "#0000C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "blue"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (affected_mob.bodytemperature ** 2) + 0.5)
	if(affected_mob.bodytemperature >= T0C || !HAS_TRAIT(affected_mob, TRAIT_KNOCKEDOUT))
		return

	var/power = -0.00003 * (affected_mob.bodytemperature ** 2) + 3
	var/need_mob_update
	need_mob_update = affected_mob.adjustOxyLoss(-3 * power * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustBruteLoss(-power * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-power * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(-power * REM * delta_time, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype) //heals TOXINLOVERs
	need_mob_update += affected_mob.adjustCloneLoss(-power * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	/*
	for(var/datum/wound/iter_wound in affected_mob.all_wounds)
		iter_wound.on_xadone(power * REM * delta_time)
	*/
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "A chemical that derives from Cryoxadone. It specializes in healing clone damage, but nothing else. Requires very cold temperatures to properly metabolize, and metabolizes quicker than cryoxadone."
	color = "#3D3DC6"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "muscle"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.bodytemperature < T0C)
		if(affected_mob.adjustCloneLoss((0.00006 * (affected_mob.bodytemperature ** 2) - 6) * REM * delta_time, updating_health = FALSE))
			. = UPDATE_MOB_HEALTH
		REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)

	// Metabolism rate is reduced in colder body temps making it more effective
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (affected_mob.bodytemperature ** 2) + 0.75)

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "A mixture of cryoxadone and slime jelly, that apparently inverses the requirement for its activation."
	color = "#f7832a"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "spicy jelly"

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		var/power = 0
		switch(affected_mob.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(affected_mob.on_fire)
			power *= 2

		var/need_mob_update
		need_mob_update = affected_mob.adjustOxyLoss(-2 * power * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-power * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1.5 * power * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustToxLoss(-power * REM * delta_time, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustCloneLoss(-power * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		if(need_mob_update)
			. = UPDATE_MOB_HEALTH
		/*
		for(var/datum/wound/iter_wound in affected_mob.all_wounds)
			iter_wound.on_xadone(power * REM * delta_time)
		*/
		REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	taste_description = "fish"

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that. // No such luck so far
	need_mob_update += affected_mob.heal_bodypart_damage(brute = 1 * REM * delta_time, burn = 1 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_biotype)
	if(need_mob_update)
		. = UPDATE_MOB_HEALTH
	REMOVE_TRAIT(affected_mob, TRAIT_DISFIGURED, TRAIT_GENERIC)

/datum/reagent/medicine/rezadone/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.set_dizzy_if_lower(10 SECONDS * REM * delta_time)
	affected_mob.set_jitter_if_lower(10 SECONDS * REM * delta_time)

/datum/reagent/medicine/rezadone/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	. = ..()
	if(iscarbon(exposed_mob))
		var/mob/living/carbon/patient = exposed_mob
		if(reac_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, "burn") && patient.getFireLoss() < THRESHOLD_UNHUSK) //One carp yields 12u rezadone.
			patient.cure_husk("burn")
			patient.visible_message(span_nicegreen("[patient]'s body rapidly absorbs moisture from the environment, taking on a more healthy appearance."))

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Spaceacillin will prevent a patient from conventionally spreading any diseases they are currently infected with."
	color = "#E1F2E6"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.
/datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	description = "If used in patch-based applications, immediately restores burn wounds as well as restoring more over time. If ingested through other means, deals minor toxin damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 100
	metabolite = /datum/reagent/metabolite/medicine/silver_sulfadiazine

/datum/reagent/medicine/silver_sulfadiazine/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1, touch_protection, obj/item/bodypart/affecting)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			exposed_mob.adjustToxLoss(0.5 * reac_volume, required_biotype = affected_biotype)
			if(show_message)
				to_chat(exposed_mob, span_warning("You don't feel so good..."))
		else if(exposed_mob.getFireLoss() && method == PATCH)
			if(affecting.heal_damage(burn = reac_volume))
				exposed_mob.update_damage_overlays()
			exposed_mob.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(exposed_mob, span_danger("You feel your burns healing! It stings like hell!"))
			exposed_mob.emote("scream")
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/silver_sulfadiazine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustOxyLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Stimulates the healing of severe burns. Overdosing will double the effectiveness of healing the burns while also dealing toxin and liver damage"
	reagent_state = LIQUID
	color = "#1E8BFF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustFireLoss(-4 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(affected_mob.getFireLoss() != 0)
		need_mob_update += affected_mob.adjustStaminaLoss(3 * REM * delta_time, updating_stamina = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update += affected_mob.adjustFireLoss(-3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	description = "If used in patch-based applications, immediately restores bruising. If ingested through other means, deals minor toxin damage."
	reagent_state = LIQUID
	color = "#FF9696"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 100
	metabolite = /datum/reagent/metabolite/medicine/styptic_powder

/datum/reagent/medicine/styptic_powder/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1, touch_protection, obj/item/bodypart/affecting)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			exposed_mob.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(exposed_mob, span_warning("You don't feel so good..."))
		else if(exposed_mob.getBruteLoss() && method == PATCH)
			if(affecting.heal_damage(reac_volume))
				exposed_mob.update_damage_overlays()
			exposed_mob.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(exposed_mob, span_danger("You feel your bruises healing! It stings like hell!"))
			exposed_mob.emote("scream")
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)

/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/styptic_powder/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustOxyLoss(1 * REM * delta_time, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Has a 33% chance per metabolism cycle to heal brute and burn damage. Can be used as a temporary blood substitute."
	reagent_state = LIQUID
	color = "#DCDCDC"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "sweetness and salt"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10 //So that normal blood regeneration can continue with salglu active

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	if(last_added)
		affected_mob.blood_volume -= last_added
		last_added = 0
	if(affected_mob.blood_volume < maximum_reachable) //Can only up to double your effective blood level.
		var/amount_to_add = min(affected_mob.blood_volume, 5 * volume)
		var/new_blood_level = min(affected_mob.blood_volume + amount_to_add, maximum_reachable)
		last_added = new_blood_level - affected_mob.blood_volume
		affected_mob.blood_volume = new_blood_level
	if(DT_PROB(18, delta_time))
		need_mob_update = affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_biotype)
		need_mob_update += affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	if(DT_PROB(1.5, delta_time))
		to_chat(affected_mob, span_warning("You feel salty."))
		affected_mob.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 1)
		affected_mob.reagents.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(DT_PROB(1.5, delta_time))
		to_chat(affected_mob, span_warning("You feel sweet."))
		affected_mob.reagents.add_reagent(/datum/reagent/consumable/sugar, 1)
		affected_mob.reagents.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(DT_PROB(18, delta_time))
		need_mob_update = affected_mob.adjustBruteLoss(0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_biotype)
		need_mob_update += affected_mob.adjustFireLoss(0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "A powerful painkiller. Restores bruising and burns in addition to making the patient believe they are fully healed."
	reagent_state = LIQUID
	color = "#6D6374"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-0.25 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-0.25 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mine_salve/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1)
	. = ..()
	if(iscarbon(exposed_mob) && exposed_mob.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			exposed_mob.adjust_nutrition(-5)
			if(show_message)
				to_chat(exposed_mob, span_warning("Your stomach feels empty and cramps!"))
		else
			var/mob/living/carbon/exposed_carbon = exposed_mob
			for(var/datum/surgery/surgery in exposed_carbon.surgeries)
				surgery.speed_modifier = max(0.1, surgery.speed_modifier)
				// +10% surgery speed on each step, useful while operating in less-than-perfect conditions

			if(show_message)
				to_chat(exposed_carbon, span_danger("You feel your wounds fade away to nothing!") )

/datum/reagent/medicine/mine_salve/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	description = "Has a 100% chance of instantly healing brute and burn damage. One unit of the chemical will heal one point of damage. Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 125

/datum/reagent/medicine/synthflesh/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1, touch_protection, obj/item/bodypart/affecting)
	. = ..()
	if(iscarbon(exposed_mob))
		if(exposed_mob.stat == DEAD)
			show_message = FALSE
		if(method == PATCH)
			//you could be targeting a limb that doesnt exist while applying the patch, so lets avoid a runtime
			if(affecting.heal_damage(brute = reac_volume, burn = reac_volume))
				exposed_mob.update_damage_overlays()
			exposed_mob.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(exposed_mob, span_danger("You feel your burns and bruises healing! It stings like hell!"))
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
			exposed_mob.emote("scream")
			//Has to be at less than THRESHOLD_UNHUSK burn damage and have at least 100 synthflesh (currently inside the body + amount now being applied). Corpses dont metabolize.
			if(HAS_TRAIT_FROM(exposed_mob, TRAIT_HUSK, "burn") && exposed_mob.getFireLoss() < THRESHOLD_UNHUSK && (exposed_mob.reagents.get_reagent_amount(/datum/reagent/medicine/synthflesh) + reac_volume) >= 100)
				exposed_mob.cure_husk("burn")
				exposed_mob.visible_message(span_nicegreen("You successfully replace most of the burnt off flesh of [exposed_mob]."))

/datum/reagent/medicine/synthflesh/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/synthflesh/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/charcoal
	name = "Charcoal"
	description = "Heals mild toxin damage as well as slowly removing any other chemicals the patient has in their bloodstream."
	reagent_state = LIQUID
	color = COLOR_BLACK
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = REAGENTS_METABOLISM
	taste_description = "ash"
	process_flags = ORGANIC
	affected_biotype = MOB_ORGANIC

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	for(var/datum/reagent/reagent in affected_mob.reagents.reagent_list)
		if(reagent == src)
			continue
		affected_mob.reagents.remove_reagent(reagent.type, 0.75 * REM * delta_time)

	if(affected_mob.adjustToxLoss(-1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizes harmful chemical compounds inside synthetic systems."
	reagent_state = LIQUID
	color = "#F1C40F"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	process_flags = SYNTHETIC
	affected_biotype = MOB_ROBOTIC

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	for(var/datum/reagent/reagent in affected_mob.reagents.reagent_list)
		if(reagent == src)
			continue

		affected_mob.reagents.remove_reagent(reagent.type, 1 * REM * delta_time)

	if(HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		var/datum/component/irradiated/irradiated_component = affected_mob.GetComponent(/datum/component/irradiated)
		irradiated_component.adjust_intensity(irradiated_component.intensity * -0.1)
	if(affected_mob.adjustToxLoss(-2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Repairs brain damage in synthetics."
	color = "#727272"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "metallic"
	process_flags = SYNTHETIC
	affected_biotype = MOB_ROBOTIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3 * REM)
	affected_mob.adjust_hallucinations(-20 SECONDS)

	if(prob(30) && affected_mob.has_trauma_type(BRAIN_TRAUMA_SPECIAL))
		affected_mob.cure_trauma_type(BRAIN_TRAUMA_SPECIAL)
	if(prob(10) && affected_mob.has_trauma_type(BRAIN_TRAUMA_MILD))
		affected_mob.cure_trauma_type(BRAIN_TRAUMA_MILD)

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Slowly heals all damage types. Overdose will cause damage in all types instead."
	reagent_state = LIQUID
	color = "#DCDCDC"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	var/healing = 0.5

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(-healing * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(-healing * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustBruteLoss(-healing * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-healing * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/omnizine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(1.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(1.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustBruteLoss(1.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(1.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Quickly purges the body of all chemicals. Toxin damage is dealt if the patient is in good condition."
	reagent_state = LIQUID
	color = "#19C832"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "acid"

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	for(var/datum/reagent/reagent in affected_mob.reagents.reagent_list)
		if(reagent == src)
			continue
		affected_mob.reagents.remove_reagent(reagent.type, 2.5 * REM * delta_time)

	if(affected_mob.health > 20)
		if(affected_mob.adjustToxLoss(2.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Heals low toxin damage while the patient is irradiated, and will halt the damaging effects of radiation."
	reagent_state = LIQUID
	color = "#BAA15D"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 2 * REAGENTS_METABOLISM
	metabolized_traits = list(TRAIT_HALT_RADIATION_EFFECTS)

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		return

	var/datum/component/irradiated/irradiated_component = affected_mob.GetComponent(/datum/component/irradiated)
	irradiated_component.adjust_intensity(-1 * REM * delta_time)

	if(affected_mob.adjustToxLoss(-1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Reduces massive amounts of toxin damage while purging other chemicals from the body."
	reagent_state = LIQUID
	color = "#E6FFF0"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	metabolized_traits = list(TRAIT_HALT_RADIATION_EFFECTS)

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	for(var/datum/reagent/reagent in affected_mob.reagents.reagent_list)
		if(reagent == src)
			continue
		affected_mob.reagents.remove_reagent(reagent.type, 2 * REM * delta_time)

	if(HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		var/datum/component/irradiated/irradiated_component = affected_mob.GetComponent(/datum/component/irradiated)
		irradiated_component.adjust_intensity(-2 * REM * delta_time)

	if(affected_mob.adjustToxLoss(-2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	description = "Stimulates the healing of severe bruises. Overdosing will double the effectiveness of healing the bruises while also dealing toxin and liver damage."
	reagent_state = LIQUID
	color = "#D2D2D2"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(affected_mob.getBruteLoss() != 0)
		need_mob_update = affected_mob.adjustStaminaLoss(3 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(-3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent."
	reagent_state = LIQUID
	color = COLOR_CYAN
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	overdose_threshold = 25
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOxyLoss(-3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	if(affected_mob.losebreath >= 4)
		affected_mob.losebreath -= 2 * REM * delta_time
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/salbutamol/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.reagents.add_reagent(/datum/reagent/toxin/histamine, 1)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/salbutamol, 1)

/datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	description = "Extremely rapidly restores oxygen deprivation, but causes minor toxin damage. Overdose causes significant damage to the lungs."
	reagent_state = LIQUID
	color = "#FF6464"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, -2)
	need_mob_update += affected_mob.adjustOxyLoss(-10 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/perfluorodecalin/overdose_process(mob/living/carbon/affected_mob)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 2))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Increases stun resistance and movement speed. Overdose deals toxin damage and inhibits breathing."
	reagent_state = LIQUID
	color = "#D2FFFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_types = list(/datum/addiction/stimulants = 4) //1.6 per 2 seconds

/datum/reagent/medicine/ephedrine/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)//mildly slower than meth

/datum/reagent/medicine/ephedrine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ephedrine)

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(10, delta_time))
		var/obj/item/held_item = affected_mob.get_active_held_item()
		if(held_item && affected_mob.dropItemToGround(held_item))
			to_chat(affected_mob, span_notice("Your hands spaz out and you drop what you were holding!"))
			affected_mob.set_jitter_if_lower(20 SECONDS)

	affected_mob.AdjustAllImmobility(-20 * REM * delta_time)
	if(affected_mob.adjustStaminaLoss(-10 * REM * delta_time, updating_stamina = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(1, delta_time))
		affected_mob.ForceContractDisease(new /datum/disease/heart_failure)
		to_chat(affected_mob, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
		affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, 0)

	if(DT_PROB(3.5, delta_time))
		to_chat(affected_mob, span_notice(pick("Your head pounds.", "You feel a tight pain in your chest.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")))

	if(DT_PROB(18, delta_time))
		affected_mob.losebreath++
		if(affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Rapidly purges the body of Histamine and reduces jitteriness. Slight chance of causing drowsiness."
	reagent_state = LIQUID
	color = "#64FFE6"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(5, delta_time))
		affected_mob.adjust_drowsiness(2 SECONDS)
	affected_mob.adjust_jitter(-2 SECONDS * REM * delta_time)
	affected_mob.reagents.remove_reagent(/datum/reagent/toxin/histamine, 3 * REM * delta_time)

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "A painkiller that allows the patient to move at full speed even in bulky objects. Causes drowsiness and eventually unconsciousness in high doses. Overdose will cause a variety of effects, ranging from minor to lethal."
	reagent_state = LIQUID
	color = "#A9FBFB"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_types = list(/datum/addiction/opioids = 10)

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	switch(current_cycle)
		if(11)
			to_chat(affected_mob, span_warning("You start to feel tired...") )
		if(12 to 24)
			affected_mob.adjust_drowsiness(2 SECONDS * REM * delta_time)
		if(24 to INFINITY)
			affected_mob.Sleeping(4 SECONDS * REM * delta_time)

/datum/reagent/medicine/morphine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(18, delta_time))
		affected_mob.drop_all_held_items()
		affected_mob.set_dizzy_if_lower(4 SECONDS)
		affected_mob.set_jitter_if_lower(4 SECONDS)

/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#404040" //ucline is dark grey, inacusiate is light grey
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "dull toxin"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/obj/item/organ/eyes/eyes = affected_mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return

	eyes.apply_organ_damage(-2 * REM * delta_time)
	if(HAS_TRAIT_FROM(affected_mob, TRAIT_BLIND, EYE_DAMAGE))
		if(DT_PROB(10, delta_time))
			to_chat(affected_mob, span_warning("Your vision slowly returns..."))
			affected_mob.cure_blind(EYE_DAMAGE)
			affected_mob.cure_nearsighted(EYE_DAMAGE)
			affected_mob.set_eye_blur_if_lower(70 SECONDS)
	else if(HAS_TRAIT_FROM(affected_mob, TRAIT_NEARSIGHT, EYE_DAMAGE))
		to_chat(affected_mob, span_warning("The blackness in your peripheral vision fades."))
		affected_mob.cure_nearsighted(EYE_DAMAGE)
		affected_mob.set_eye_blur_if_lower(20 SECONDS)
	else if(affected_mob.is_blind() || affected_mob.has_status_effect(/datum/status_effect/eye_blur))
		affected_mob.set_blindness(0)
		affected_mob.remove_status_effect(/datum/status_effect/eye_blur)

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "If a patient is in critical condition, rapidly heals all damage types as well as regulating oxygen in the body. Excellent for stabilizing wounded patients. Has the side effects of causing minor confusion."
	reagent_state = LIQUID
	color = "#1D3535" //slightly more blue, like epinephrine
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 15

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.health <= 20)
		var/need_mob_update
		need_mob_update = affected_mob.adjustToxLoss(-4 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-4 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-4 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		if(need_mob_update)
			. = UPDATE_MOB_HEALTH
	affected_mob.losebreath = 0

	if(DT_PROB(10, delta_time))
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		affected_mob.set_jitter_if_lower(10 SECONDS)
		affected_mob.drop_all_held_items()

/datum/reagent/medicine/atropine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.reagents.add_reagent(/datum/reagent/toxin/histamine, 3 * REM * delta_time)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/atropine, 2 * REM * delta_time)
	affected_mob.set_dizzy_if_lower(2 SECONDS * REM * delta_time)
	affected_mob.set_jitter_if_lower(2 SECONDS * REM * delta_time)

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Minor boost to stun resistance. Slowly heals damage if a patient is in critical condition, as well as regulating oxygen loss. Overdose causes weakness and toxin damage."
	reagent_state = LIQUID
	color = "#D2FFFA"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	metabolized_traits = list(TRAIT_NOCRITDAMAGE)

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()

	var/need_mob_update
	if(affected_mob.health <= affected_mob.crit_threshold)
		need_mob_update = affected_mob.adjustToxLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)

	if(affected_mob.losebreath >= 4)
		affected_mob.losebreath -= 2 * REM * delta_time
		need_mob_update = TRUE

	if(affected_mob.losebreath < 0)
		affected_mob.losebreath = 0
		need_mob_update = TRUE

	need_mob_update += affected_mob.adjustStaminaLoss(-0.5 * REM * delta_time, updating_stamina = FALSE)

	if(DT_PROB(10, delta_time))
		affected_mob.AdjustAllImmobility(-20)
		need_mob_update = TRUE

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(18, delta_time))
		var/need_mob_update
		need_mob_update = affected_mob.adjustStaminaLoss(2.5 * REM * delta_time, updating_stamina = FALSE)
		need_mob_update += affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		if(need_mob_update)
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "A miracle drug capable of bringing the dead back to life. Only functions when applied by patch or spray, if the target has less than 100 brute and burn damage (independent of one another) and hasn't been husked. Causes slight damage to the living."
	reagent_state = LIQUID
	color = "#A0E85E"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "magnets"

/datum/reagent/medicine/strange_reagent/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	. = ..()
	if(exposed_mob.stat == DEAD)
		if(exposed_mob.suiciding) //they are never coming back
			exposed_mob.visible_message(span_warning("[exposed_mob]'s body does not react..."))
			return
		if(exposed_mob.getBruteLoss() >= 100 || exposed_mob.getFireLoss() >= 100 || HAS_TRAIT(exposed_mob, TRAIT_HUSK)) //body is too damaged to be revived
			exposed_mob.visible_message(span_warning("[exposed_mob]'s body convulses a bit, and then falls still once more."))
			exposed_mob.do_jitter_animation(10)
			return
		else
			exposed_mob.visible_message(span_warning("[exposed_mob]'s body starts convulsing!"))
			exposed_mob.notify_ghost_cloning(source = exposed_mob)
			exposed_mob.do_jitter_animation(10)
			addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 10), 40) //jitter immediately, then again after 4 and 8 seconds
			addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 10), 80)
			addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, revive), FALSE, FALSE), 100)

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Efficiently restores brain damage."
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE

/datum/reagent/medicine/mannitol/on_mob_add(mob/living/carbon/affected_mob)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_BRAIN_TUMOR))
		overdose_threshold = 35 // special overdose to brain tumor quirker

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_BRAIN_TUMOR)) // to brain tumor quirk holder
		SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "brain_tumor", /datum/mood_event/brain_tumor_mannitol)
		if(!overdosed)
			affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.5 * REM * delta_time)
	else // to ordinary people
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2 * REM * delta_time)

/datum/reagent/medicine/mannitol/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(HAS_TRAIT(affected_mob, TRAIT_BRAIN_TUMOR) && DT_PROB(10, delta_time))
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.1 * REM)

/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Reacts with neural tissue, helping reform damaged connections. Can cure minor traumas and treat seizure disorders."
	color = COLOR_SILVER //ditto
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	added_traits = list(TRAIT_ANTICONVULSANT)

/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		affected_mob.reagents.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5 * REM * delta_time)

	if(DT_PROB(8, delta_time))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Removes jitteriness and restores genetic defects."
	color = "#5096C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	taste_description = "acid"

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/jitter)
	if(affected_mob.has_dna())
		affected_mob.dna.remove_all_mutations(mutadone = TRUE)

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects. Less effective in light drinkers."
	color = "#00B4C8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "raw egg"
	/// All status effects we remove on metabolize.
	/// Does not include drunk (despite what you may thing) as that's decreased gradually
	var/static/list/status_effects_to_clear = list(
		/datum/status_effect/confusion,
		/datum/status_effect/dizziness,
		/datum/status_effect/drowsiness,
		/datum/status_effect/speech/slurring/drunk,
	)

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_LIGHT_DRINKER))
		for(var/effect in status_effects_to_clear)
			affected_mob.remove_status_effect(effect)
	affected_mob.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3 * REM * delta_time, FALSE, TRUE)
	if(affected_mob.adjustToxLoss(-0.2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH
	affected_mob.adjust_drunk_effect(-10 * REM * delta_time)

//Stimulants. Used in Adrenal Implant
/datum/reagent/medicine/amphetamine
	name = "Amphetamine"
	description = "Increases stun resistance and movement speed in addition to restoring minor damage and weakness. Overdose causes weakness and toxin damage."
	color = "#78008C"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

/datum/reagent/medicine/amphetamine/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/amphetamine)

/datum/reagent/medicine/amphetamine/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/amphetamine)

/datum/reagent/medicine/amphetamine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	affected_mob.AdjustAllImmobility(-60 * REM * delta_time)
	need_mob_update = affected_mob.adjustStaminaLoss(-35 * REM * delta_time, updating_stamina = FALSE)

	if(affected_mob.health <= 50 && affected_mob.health > 0)
		need_mob_update += affected_mob.adjustOxyLoss(-1 * REM * delta_time, updating_health = FALSE)
		need_mob_update += affected_mob.adjustToxLoss(-1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustBruteLoss(-1 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-1 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/amphetamine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(18, delta_time))
		var/need_mob_update
		need_mob_update = affected_mob.adjustStaminaLoss(2.5, updating_stamina = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustToxLoss(1, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		if(need_mob_update)
			return UPDATE_MOB_HEALTH

//Pump-Up for Pump-Up Stimpack
/datum/reagent/medicine/pumpup
	name = "Pump-Up"
	description = "Makes you immune to damage slowdown, resistant to all other kinds of slowdown and gives a minor speed boost. Overdose causes weakness and toxin damage."
	color = "#78008C"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	metabolized_traits = list(TRAIT_SLEEPIMMUNE, TRAIT_BATON_RESISTANCE, TRAIT_IGNOREDAMAGESLOWDOWN)
	addiction_types = list(/datum/addiction/stimulants = 6) //2.6 per 2 seconds

/datum/reagent/medicine/pumpup/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.AdjustAllImmobility(-80, FALSE)
	affected_mob.adjustStaminaLoss(-80, updating_stamina = FALSE)
	affected_mob.set_jitter_if_lower(20 SECONDS * REM * delta_time)

/datum/reagent/drug/pumpup/overdose_start(mob/living/affected_mob)
	. = ..()
	to_chat(affected_mob, span_userdanger("You can't stop shaking, your heart beats faster and faster..."))

/datum/reagent/medicine/pumpup/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(33, delta_time))
		var/need_mob_update
		need_mob_update = affected_mob.adjustStaminaLoss(2.5 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		affected_mob.losebreath++
		if(need_mob_update)
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#FFFFF0"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.AdjustSleeping(-20 * REM * delta_time)
	affected_mob.reagents.remove_reagent(/datum/reagent/consumable/sugar, 3 * REM * delta_time)

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.
/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	description = "Restores bruising. Overdose causes liver damage."
	reagent_state = LIQUID
	color = "#bf0000"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	metabolite = /datum/reagent/metabolite/medicine/bicaridine
	overdose_threshold = 30

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustBruteLoss(-1 * REM * delta_time / METABOLITE_PENALTY(metabolite), updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.reagents.add_reagent(metabolite, 1)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/bicaridine, 1)
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1 * REM * delta_time))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/dexalin
	name = "Dexalin"
	description = "Restores oxygen loss. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#0080FF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30

/datum/reagent/medicine/dexalin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustOxyLoss(-1.5 * REM * delta_time, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/dexalin/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 2 * REM * delta_time))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/dexalinp
	name = "Dexalin Plus"
	description = "Restores oxygen loss. Overdose causes large amounts of damage to the heart. It is highly effective."
	reagent_state = LIQUID
	color = "#0040FF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 25

/datum/reagent/medicine/dexalinp/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/mob_update_required
	mob_update_required = affected_mob.adjustOxyLoss(-3 * REM * delta_time, updating_health = FALSE)
	if(affected_mob.getOxyLoss() != 0)
		mob_update_required += affected_mob.adjustStaminaLoss(3 * REM * delta_time, updating_stamina = FALSE)
	if(mob_update_required)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/dexalinp/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 4 * REM * delta_time)

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	description = "Restores fire damage. Overdose causes liver damage."
	reagent_state = LIQUID
	color = "#FFa800"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	metabolite = /datum/reagent/metabolite/medicine/kelotane
	overdose_threshold = 30

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustFireLoss((-1 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_bodytype = affected_bodytype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/kelotane/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.reagents.add_reagent(metabolite, 1)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/kelotane, 1)
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1 * REM * delta_time, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/antitoxin
	name = "Anti-Toxin"
	description = "Heals toxin damage and removes toxins in the bloodstream. Overdose causes liver damage."
	reagent_state = LIQUID
	color = "#00a000"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "a roll of gauze"
	metabolite = /datum/reagent/metabolite/medicine/antitoxin
	overdose_threshold = 30

/datum/reagent/medicine/antitoxin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss((-1 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/antitoxin/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.reagents.add_reagent(metabolite, 1)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/antitoxin, 1)
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1 * REM * delta_time, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/carthatoline
	name = "Carthatoline"
	description = "Carthatoline is strong evacuant used to treat severe poisoning."
	reagent_state = LIQUID
	color = "#225722"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	overdose_threshold = 25

/datum/reagent/medicine/carthatoline/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(-3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		. = UPDATE_MOB_HEALTH

	if(affected_mob.getToxLoss() && DT_PROB(5, delta_time))
		affected_mob.vomit(1)

	for(var/datum/reagent/toxin/reagent in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(reagent.type, 1)

/datum/reagent/medicine/carthatoline/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time, required_organ_flag = affected_organ_flags)

/datum/reagent/medicine/meclizine
	name = "Meclizine"
	description = "A medicine which prevents vomiting."
	reagent_state = LIQUID
	color = "#cecece"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	metabolized_traits = list(TRAIT_NOVOMIT)

/datum/reagent/medicine/meclizine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(5, delta_time))
		if(affected_mob.adjustToxLoss(-1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/medicine/meclizine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/mob_update_required
	mob_update_required = affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	mob_update_required += affected_mob.adjustOrganLoss(ORGAN_SLOT_STOMACH, 2 * REM * delta_time, required_organ_flag = affected_organ_flags)
	if(mob_update_required)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/hepanephrodaxon
	name = "Hepanephrodaxon"
	description = "Used to repair the common tissues involved in filtration."
	taste_description = "glue"
	reagent_state = LIQUID
	color = "#D2691E"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE
	metabolization_rate = REM * 3.75
	overdose_threshold = 10

/datum/reagent/medicine/hepanephrodaxon/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/repair_strength = 1
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver.damage > 0)
		liver.damage = max(liver.damage - 4 * repair_strength, 0)
		affected_mob.set_confusion_if_lower(2 SECONDS)
	if(affected_mob.adjustToxLoss(-6 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/hepanephrodaxon/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_confusion_if_lower(2 SECONDS)
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	description = "Stabilizes the breathing of patients. Good for those in critical condition."
	reagent_state = LIQUID
	color = "#A4D8D8"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.losebreath >= 5)
		affected_mob.losebreath -= 5 * REM * delta_time

/datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	description = "Has a high chance to heal all types of damage. Overdose causes toxin damage and liver damage."
	reagent_state = LIQUID
	color = "#707A00" //tricord's component chems mixed together, olive.
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 3 * REAGENTS_METABOLISM
	overdose_threshold = 30
	taste_description = "grossness"
	metabolite = /datum/reagent/metabolite/medicine/tricordrazine

/datum/reagent/medicine/tricordrazine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss((-2 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss((-2 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss((-2 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss((-2 * REM * delta_time) / METABOLITE_PENALTY(metabolite), updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/tricordrazine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * delta_time, required_organ_flag = affected_organ_flags)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy."
	reagent_state = LIQUID
	color = "#CC23FF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "jelly"

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustBruteLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustOxyLoss(-0.5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	affected_mob.adjustToxLoss(-0.5 * REM * delta_time, updating_health = FALSE, forced = TRUE, required_biotype = affected_biotype)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Miniature medical robots that swiftly restore bodily damage."
	reagent_state = SOLID
	color = "#555555"
	chemical_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustBruteLoss(-5 * REM * delta_time, updating_health = FALSE) //A ton of healing - this is a 50 telecrystal investment.
	affected_mob.adjustFireLoss(-5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOxyLoss(-15 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustToxLoss(-5 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustCloneLoss(-3 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15 * REM * delta_time)

	if(affected_mob.blood_volume < BLOOD_VOLUME_NORMAL)
		affected_mob.blood_volume = max(affected_mob.blood_volume, min(affected_mob.blood_volume + 4, BLOOD_VOLUME_NORMAL))

	return UPDATE_MOB_HEALTH

//wtb flavortext messages that hint that you're vomitting up robots
/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(DT_PROB(13, delta_time))
		affected_mob.reagents.remove_reagent(type, metabolization_rate * 15) // ~5 units at a rate of 0.4 but i wanted a nice number in code
		affected_mob.vomit(20) // nanite safety protocols make your body expel them to prevent harmies

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain."
	color = "#FFAF00"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 25
	addiction_types = list(/datum/addiction/hallucinogens = 14)

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustBruteLoss(-3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(-3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustOxyLoss(-15 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	affected_mob.adjustToxLoss(-3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * delta_time, 150, required_organ_flag = affected_organ_flags) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	affected_mob.adjustCloneLoss(-1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	affected_mob.adjustStaminaLoss(-30 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
	affected_mob.adjust_jitter_up_to(6 SECONDS * REM * delta_time, 1 MINUTES)
	affected_mob.druggy = clamp(affected_mob.druggy + (10 * REM * delta_time), 0, 15 * REM * delta_time) //See above
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * delta_time, 120 SECONDS)
	affected_mob.adjustToxLoss(5 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Increases depletion rates for most stimulating/hallucinogenic drugs. Reduces druggy effects and jitteriness. Severe stamina regeneration penalty, causes drowsiness. Small chance of brain damage."
	reagent_state = LIQUID
	color = "#27870a"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()

	for(var/datum/reagent/drug/drug in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(drug.type, 5 * REM * delta_time)
	affected_mob.adjust_drowsiness(4 SECONDS * REM * delta_time)

	if(affected_mob.get_timed_status_effect_duration(/datum/status_effect/jitter) >= 6 SECONDS)
		affected_mob.adjust_jitter(-6 SECONDS * REM * delta_time)

	if (affected_mob.get_timed_status_effect_duration(/datum/status_effect/hallucination) >= 10 SECONDS)
		affected_mob.adjust_hallucinations(-10 SECONDS * REM * delta_time)

	var/need_mob_update = FALSE
	if(DT_PROB(10, delta_time))
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1, 50, required_organ_flag = affected_organ_flags)
	need_mob_update += affected_mob.adjustStaminaLoss(2.5 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/lavaland_extract
	name = "Lavaland Extract"
	description = "An extract of lavaland atmospheric and mineral elements. Heals the user in small doses, but is extremely toxic otherwise."
	color = "#6B372E" //dark and red like lavaland
	chemical_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 3 //To prevent people stacking massive amounts of a very strong healing reagent

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.heal_bodypart_damage(5 * REM * delta_time, 5 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustBruteLoss(3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustFireLoss(3 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjustToxLoss(3 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	return UPDATE_MOB_HEALTH

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Reduces the duration of unconsciousness, knockdown and stuns. Restores stamina, but deals toxin damage when overdosed."
	color = "#C1151D"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.AdjustAllImmobility(-20 * REM * delta_time)
	affected_mob.adjustStaminaLoss(-20 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	return UPDATE_MOB_HEALTH

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Drastically increases movement speed."
	color = "#AE151D"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 2.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/corazone
	// Heart attack code will not do damage if corazone is present
	// because it's SPACE MAGIC ASPIRIN
	name = "Corazone"
	description = "A medication used to assist in healing the heart and to stabalize the heart and liver."
	color = "#F49797"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 20
	self_consuming = TRUE
	metabolized_traits = list(TRAIT_STABLEHEART, TRAIT_STABLELIVER)

/datum/reagent/medicine/corazone/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, -1.5)

/datum/reagent/medicine/corazone/overdose_process(mob/living/affected_mob)
	. = ..()
	affected_mob.reagents.add_reagent(/datum/reagent/toxin/histamine, 1)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/corazone, 1)

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "A potent chemical that allows someone under its influence to be at full physical ability even when under massive amounts of pain."
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	addiction_types = list(/datum/addiction/stimulants = 4) //0.8 per 2 seconds

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Long-lasting sleep suppressant that very slightly reduces stun and knockdown times. Overdosing has horrendous side effects and deals lethal oxygen damage, will knock you unconscious if not dealt with."
	reagent_state = LIQUID
	color = "#BEF7D8" // palish blue white
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "salt" // it actually does taste salty
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)

	// to track overdose progress
	var/overdose_progress = 0

/datum/reagent/medicine/modafinil/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/modafil)

/datum/reagent/medicine/modafinil/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/modafil)

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(!overdosed) // We do not want any effects on OD
		overdose_threshold = overdose_threshold + ((rand(-10, 10) / 10) * REM * delta_time) // for extra fun
		affected_mob.AdjustAllImmobility(-20 * REM * delta_time)
		affected_mob.adjustStaminaLoss(-15 * REM * delta_time, updating_stamina = FALSE)
		affected_mob.set_jitter_if_lower(1 SECONDS * REM * delta_time)
		metabolization_rate = 0.005 * REAGENTS_METABOLISM * rand(5, 20) // randomizes metabolism between 0.02 and 0.08 per second
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/modafinil/overdose_start(mob/living/affected_mob)
	to_chat(affected_mob, span_userdanger("You feel awfully out of breath and jittery!"))
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.005 per second on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	. = ..()
	overdose_progress++

	switch(overdose_progress)
		if(1 to 40)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * delta_time, 20 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * delta_time, 20 SECONDS)
			affected_mob.set_dizzy_if_lower(10 SECONDS * REM * delta_time)
			if(DT_PROB(30, delta_time))
				affected_mob.losebreath++
		if(41 to 80)
			affected_mob.adjustOxyLoss(0.1 * REM * delta_time, updating_health = FALSE)
			affected_mob.adjustStaminaLoss(0.1 * REM * delta_time, updating_stamina = FALSE)
			affected_mob.adjust_jitter_up_to(2 SECONDS * REM * delta_time, 40 SECONDS)
			affected_mob.adjust_stutter_up_to(2 SECONDS * REM * delta_time, 40 SECONDS)
			affected_mob.set_dizzy_if_lower(20 SECONDS * REM * delta_time)
			if(DT_PROB(30, delta_time))
				affected_mob.losebreath++
			if(DT_PROB(10, delta_time))
				to_chat(affected_mob, "You have a sudden fit!")
				affected_mob.emote("moan")
				affected_mob.Paralyze(20) // you should be in a bad spot at this point unless epipen has been used
			. = UPDATE_MOB_HEALTH
		if(81)
			to_chat(affected_mob, "You feel too exhausted to continue!") // at this point you will eventually die unless you get charcoal
			affected_mob.adjustOxyLoss(0.1 * REM * delta_time, updating_health = FALSE)
			affected_mob.adjustStaminaLoss(0.1 * REM * delta_time, updating_stamina = FALSE)
			. = UPDATE_MOB_HEALTH
		if(82 to INFINITY)
			affected_mob.Sleeping(100 * REM * delta_time)
			affected_mob.adjustOxyLoss(1.5 * REM * delta_time, updating_health = FALSE)
			affected_mob.adjustStaminaLoss(1.5 * REM * delta_time, updating_stamina = FALSE)
			. = UPDATE_MOB_HEALTH

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Suppresses anxiety and other various forms of mental distress. Overdose causes hallucinations and minor toxin damage."
	reagent_state = LIQUID
	color = "#07E79E"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	metabolized_traits = list(TRAIT_FEARLESS)

	var/dosage

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	dosage++
	affected_mob.adjust_jitter(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_dizzy(-12 SECONDS * REM * delta_time)
	affected_mob.adjust_confusion(-6 SECONDS * REM * delta_time)
	affected_mob.disgust = max(affected_mob.disgust - (6 * REM * delta_time), 0)
	var/datum/component/mood/mood = affected_mob.GetComponent(/datum/component/mood)
	if(mood?.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		mood.setSanity(min(mood.sanity + (5 * REM * delta_time), SANITY_NEUTRAL)) // set minimum to prevent unwanted spiking over neutral

/datum/reagent/medicine/psicodine/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjust_hallucinations_up_to(10 SECONDS * REM * delta_time, 120 SECONDS)
	if(affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "A thistle derrived hepatoprotective flavolignan mixture that help reverse damage to the liver."
	reagent_state = SOLID
	color = "#FFFFD0"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, -2 * REM * delta_time)//Add a chance to cure liver trauma once implemented.

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "A purple mixture of short polyelectrolyte chains not easily synthesized in the laboratory. It is a powerful pharmaceutical drug which provides minor healing and prevents bloodloss, making it incredibly useful for the synthesis of other drugs."
	reagent_state = SOLID
	color = "#9423FF"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "numbing bitterness"

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25 * REM * delta_time, required_organ_flag = affected_organ_flags)
	need_mob_update += affected_mob.adjustBruteLoss(-0.35 * REM * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)

	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		affected_human.cauterise_wounds(0.1)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/polypyr/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume)
	. = ..()
	if(method == TOUCH || method == VAPOR)
		if(ishuman(exposed_mob) && reac_volume >= 0.5)
			var/mob/living/carbon/human/exposed_human = exposed_mob
			exposed_human.hair_color = "#9922ff"
			exposed_human.facial_hair_color = "#9922ff"
			exposed_human.update_hair()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * REM * delta_time, required_organ_flag = affected_organ_flags))
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/stabilizing_nanites
	name = "Stabilizing nanites"
	description = "Rapidly heals a patient out of crit by regenerating damaged cells and causing blood to clot, preventing bleeding. Nanites distribution in the blood makes them ineffective against moderately healthy targets."
	reagent_state = LIQUID
	color = COLOR_BLACK
	chemical_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 15
	metabolized_traits = list(TRAIT_NO_BLEEDING)

/datum/reagent/medicine/stabilizing_nanites/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.losebreath = 0

	if(affected_mob.health <= 80)
		var/need_mob_update
		need_mob_update = affected_mob.adjustToxLoss(-4 * REM * delta_time, updating_health = FALSE)
		need_mob_update += affected_mob.adjustBruteLoss(-4 * REM * delta_time, updating_health = FALSE)
		need_mob_update += affected_mob.adjustFireLoss(-4 * REM * delta_time, updating_health = FALSE)
		need_mob_update += affected_mob.adjustOxyLoss(-5 * REM * delta_time, updating_health = FALSE)
		if(need_mob_update)
			return UPDATE_MOB_HEALTH

	if(DT_PROB(10, delta_time))
		affected_mob.set_jitter_if_lower(10 SECONDS)

	if(affected_mob.blood_volume < BLOOD_VOLUME_SAFE)
		affected_mob.blood_volume = max(affected_mob.blood_volume, (min(affected_mob.blood_volume + 4, BLOOD_VOLUME_SAFE) * REM * delta_time))
