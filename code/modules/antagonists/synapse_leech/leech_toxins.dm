//
// Leech toxins
//
// These are all likely to be very complicated, with multiple stages and a variety of symptoms and effects.
//

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Nocivorant Mycelotoxin//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/// Number of cycles each toxin "stage" lasts. SSmobs ticks every 2s, so 20 cycles = 40s.
#define LEECH_TOXIN_STAGE_CYCLES 20

/datum/reagent/toxin/leech_toxin
	name = "Nocivorant Mycelotoxin"
	description = "A neuro-irritant that spreads through the bloodstream like branching filaments, overwhelming pain pathways and destabilizing motor control."
	color = "#30b300"
	reagent_state = LIQUID
	taste_description = "rotting fungus"
	toxpwr = 0.5
	chemical_flags = CHEMICAL_NOT_SYNTH

	metabolization_rate = 0.15
	/// Cycle threshold at which motor symptoms (drops, blur, jitter) begin.
	var/motor_breakdown_cycle = LEECH_TOXIN_STAGE_CYCLES
	/// Cycle threshold at which severe symptoms (paralysis, unconsciousness) begin.
	var/severe_cycle = LEECH_TOXIN_STAGE_CYCLES * 2
	/// Cycle threshold at which the victim begins falling asleep / dying.
	var/terminal_cycle = LEECH_TOXIN_STAGE_CYCLES * 3

/datum/reagent/toxin/leech_toxin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// Constant low-level pain and stamina drain
	need_mob_update += affected_mob.adjustStaminaLoss(5 * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

	// Phase 1, Pain & disorientation.
	if(DT_PROB(10, delta_time))
		to_chat(affected_mob, span_danger(pick(
			"Branching threads of pain crawl beneath your skin!",
			"Your nerves feel like they're being threaded with hot wire!",
			"A wave of searing pain washes over you!",
			"Something is spreading through your veins!",
		)))
		affected_mob.adjust_dizzy_up_to(6 SECONDS * delta_time, 30 SECONDS)
		if(prob(40))
			affected_mob.emote(pick("groan", "gasp", "twitch"))

	// Phase 2, Motor control breakdown.
	if(current_cycle >= motor_breakdown_cycle)

		// Now we add more stamina damage
		need_mob_update += affected_mob.adjustStaminaLoss(5 * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

		affected_mob.adjust_jitter_up_to(8 SECONDS * delta_time, 60 SECONDS)

		if(DT_PROB(10, delta_time))
			affected_mob.set_eye_blur_if_lower(8 SECONDS)
			to_chat(affected_mob, span_warning("Your vision blurs as your muscles spasm uncontrollably!"))

		if(DT_PROB(5, delta_time))
			affected_mob.drop_all_held_items()
			to_chat(affected_mob, span_warning("Your fingers refuse to obey you!"))

	// Phase 3, Severe neural failure.
	if(current_cycle >= severe_cycle)

		// In stage 3 we double the toxin damage
		need_mob_update += affected_mob.adjustToxLoss(0.5 * delta_time, updating_health = FALSE, required_biotype = affected_biotype)

		if(DT_PROB(15, delta_time))
			to_chat(affected_mob, span_userdanger("Your body locks up as agony rips through you!"))
			affected_mob.emote("scream")
			affected_mob.Paralyze(3 SECONDS * delta_time)

		if(DT_PROB(10, delta_time))
			affected_mob.Unconscious(2 SECONDS * delta_time)

	// Phase 4, Terminal stage.
	if(current_cycle >= terminal_cycle)
		// Not going to wake up from this one.
		affected_mob.SetSleeping(5 SECONDS)

		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10 * delta_time, required_organ_flag = affected_organ_flags)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

#undef LEECH_TOXIN_STAGE_CYCLES

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Corticolytic Paralytide//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/toxin/leech_stun
	name = "Corticolytic Paralytide"
	description = "A nerve-targeting paralytic that collapses motor control and speech in seconds, leaving the victim fully conscious but utterly unable to move or speak."
	color = "#7d2bdb"
	reagent_state = LIQUID
	taste_description = "numb static"
	toxpwr = 0.2
	metabolization_rate = 0.4
	chemical_flags = CHEMICAL_NOT_SYNTH

	/// Stamina loss threshold at which the collapse is triggered.
	var/collapse_threshold = 85
	var/collapse_done = FALSE

/datum/reagent/toxin/leech_stun/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	// Immediate sensory effects but not full paralysis.
	to_chat(affected_mob, span_warning("Your hands tremble as your tongue goes numb."))

	// Straight up not having a good time, man...
	affected_mob.set_jitter_if_lower(10 SECONDS)
	affected_mob.set_stutter_if_lower(10 SECONDS)
	affected_mob.set_dizzy_if_lower(10 SECONDS)
	affected_mob.set_confusion_if_lower(10 SECONDS)

	// Small immediate stamina hit to get them to slow down
	affected_mob.adjustStaminaLoss(20, updating_stamina = FALSE)

/datum/reagent/toxin/leech_stun/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// While the reagent is building up, the victim is jittery and losing stamina.
	if(!collapse_done)

		// Apply flavor
		affected_mob.set_jitter_if_lower(10 SECONDS)
		affected_mob.set_stutter_if_lower(10 SECONDS)
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		affected_mob.set_confusion_if_lower(10 SECONDS)

		// Check for stamina and shut them up if they are about to scream
		var/current_stam_loss = affected_mob.getStaminaLoss()
		// Collapse threshold, the flavor is over, now we fuck them up
		if(current_stam_loss >= collapse_threshold)
			collapse_done = TRUE
			to_chat(affected_mob, span_userdanger("Your legs give out and you collapse as pain tears through you!"))
			affected_mob.Knockdown(6 SECONDS)

		// Apply stam, we haven't had enough yet.
		need_mob_update += affected_mob.adjustStaminaLoss(20 * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)
	else
		// After collapse: sustained, heavy paralysis/stun for the rest of the reagent duration.
		affected_mob.Paralyze(6 SECONDS * delta_time)
		affected_mob.Knockdown(6 SECONDS * delta_time)

		// This is it.
		affected_mob.set_jitter_if_lower(10 SECONDS)
		affected_mob.set_silence_if_lower(10 SECONDS)
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		affected_mob.set_confusion_if_lower(10 SECONDS)

		if(DT_PROB(20, delta_time))
			to_chat(affected_mob, span_warning(pick(
				"Your body refuses to move!",
				"You try to scream, but can't even open your mouth!",
				"You can't feel your legs!",
			)))

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Gliostatic Myelostim////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_organheal
	name = "Gliostatic Myelostim"
	description = "A regenerative stimulant that forces accelerated myelin sheath regrowth, repairing trauma-induced signal loss with unnerving accuracy."
	color = "#a0e8c0"
	reagent_state = LIQUID
	taste_description = "cold metal and moss"
	chemical_flags = CHEMICAL_NOT_SYNTH
	// Slow trickle metabolism - one unit lingers for a long time.
	metabolization_rate = 0.05
	/// Per-second heal applied to the brain.
	var/brain_heal_rate = 0.25
	/// Per-second heal applied to other valid organs.
	var/organ_heal_rate = 0.1

/datum/reagent/medicine/leech_organheal/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	if(!length(affected_mob.internal_organs))
		return

	for(var/obj/item/organ/organ as anything in affected_mob.internal_organs)
		// Skip robotic / frozen organs
		if(organ.organ_flags & (ORGAN_ROBOTIC | ORGAN_FROZEN))
			continue
		if(organ.damage <= 0)
			continue
		var/heal_rate = (organ.slot == ORGAN_SLOT_BRAIN) ? brain_heal_rate : organ_heal_rate
		if(affected_mob.adjustOrganLoss(organ.slot, -heal_rate * delta_time))
			need_mob_update = TRUE

	if(DT_PROB(2, delta_time))
		affected_mob.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY, special_method = TRUE)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Hematodermic Fibrilase//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_bruteburn
	name = "Hematodermic Fibrilase"
	description = "A viscous gel that infiltrates ruptured tissue and forces accelerated fibroblast division, knitting muscle and skin in minutes."
	color = "#e8b87a"
	reagent_state = LIQUID
	taste_description = "copper and warm wax"
	chemical_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/medicine/leech_bruteburn/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	need_mob_update += affected_mob.adjustBruteLoss(-1 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-1 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Xenotrophic Neutralysin/////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_toxpurge
	name = "Xenotrophic Neutralysin"
	description = "A cell-cleansing compound that forces corrupted cells into apoptosis, flushing toxins and halting mutation cascades."
	color = "#c0f0e0"
	reagent_state = LIQUID
	taste_description = "bitter herbs and bleach"
	chemical_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/medicine/leech_toxpurge/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	need_mob_update += affected_mob.adjustToxLoss(-1 * delta_time, forced = TRUE, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustCloneLoss(-1 * delta_time, updating_health = FALSE, required_biotype = affected_biotype)

	// Purge toxin reagents from the bloodstream
	for(var/datum/reagent/toxin/toxin in holder.reagent_list)
		if(toxin == src)
			continue
		holder.remove_reagent(toxin.type, 1 * delta_time)

	// Remove mutations
	if(affected_mob.has_dna())
		affected_mob.dna.remove_all_mutations(mutadone = TRUE)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Adrenalic Surge Polymer/////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_oxyfix
	name = "Adrenalic Surge Polymer"
	description = "A synthetic adrenal analogue that spreads through the endocrine system, restoring consciousness and increasing oxygen absorption."
	color = "#f0d060"
	reagent_state = LIQUID
	taste_description = "sharp citrus and electricity"
	chemical_flags = CHEMICAL_NOT_SYNTH
	metabolized_traits = list(TRAIT_NOCRITDAMAGE)

/datum/reagent/medicine/leech_oxyfix/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	need_mob_update += affected_mob.adjustOxyLoss(-4 * delta_time, updating_health = FALSE, required_biotype = affected_biotype)

	// Reduce suffocation and clear stun to keep the patient functional
	affected_mob.losebreath = max(0, affected_mob.losebreath - (2 * delta_time))
	affected_mob.AdjustAllImmobility(-40 * delta_time)

	// Stabilize someone dying in crit similar to epinephrine
	if(affected_mob.health <= affected_mob.crit_threshold)
		need_mob_update += affected_mob.adjustBruteLoss(-0.5 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustFireLoss(-0.5 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Coagulant Myelofroth////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_bloodclot
	name = "Coagulant Myelofroth"
	description = "A frothing agent that expands into a dense clotting foam, plugging internal and external bleeds with uncanny precision. It rapidly degenerates into an inert, oxygen-carrying blood substrate."
	color = "#f8f0e0"
	reagent_state = LIQUID
	taste_description = "chalk and iron"
	chemical_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/medicine/leech_bloodclot/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// Restore blood volume
	affected_mob.blood_volume = min(BLOOD_VOLUME_NORMAL, affected_mob.blood_volume + (2 * delta_time))

	// Continuous clotting
	affected_mob.cauterise_wounds(BLEED_TINY * delta_time)

	// Minor brute healing
	need_mob_update += affected_mob.adjustBruteLoss(-0.25 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Hypovariant Oligomers//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_reanimant
	name = "Hypovariant Oligomers"
	description = "A last-resort volatile endocrine compound that floods the body with all manners of psychosomatic hormones, boosting clotting and regeneration at the cost of coordination."
	color = "#ff8040"
	reagent_state = LIQUID
	taste_description = "burning plastic and mushroom"
	chemical_flags = CHEMICAL_NOT_SYNTH
	metabolization_rate = REAGENTS_METABOLISM * 1.25

/datum/reagent/medicine/leech_reanimant/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	to_chat(affected_mob, span_userdanger("An explosive surge of heat rushes through your body!"))

	affected_mob.emote("gasp")

	affected_mob.set_jitter_if_lower(15 SECONDS)
	affected_mob.set_stutter_if_lower(10 SECONDS)
	affected_mob.set_eye_blur_if_lower(10 SECONDS)
	// Drop held items
	affected_mob.drop_all_held_items()
	// Immediate clotting burst
	if(iscarbon(affected_mob))
		var/mob/living/carbon/carbon_mob = affected_mob
		carbon_mob.suppress_bloodloss(10)
		carbon_mob.blood_volume = min(BLOOD_VOLUME_NORMAL, carbon_mob.blood_volume + 50)

/datum/reagent/medicine/leech_reanimant/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// Fast all healing
	need_mob_update += affected_mob.adjustBruteLoss(-1 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustFireLoss(-1 * delta_time, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += affected_mob.adjustToxLoss(-1 * delta_time, forced = TRUE, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOxyLoss(-2 * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
	affected_mob.blood_volume = min(BLOOD_VOLUME_NORMAL, affected_mob.blood_volume + (3 * delta_time))
	affected_mob.cauterise_wounds(BLEED_TINY * delta_time)

	// Debuffs
	affected_mob.adjust_jitter_up_to(10 SECONDS * delta_time, 15 SECONDS)
	if(DT_PROB(15, delta_time))
		affected_mob.set_eye_blur_if_lower(6 SECONDS)
		affected_mob.emote("gasp")
	if(DT_PROB(10, delta_time))
		affected_mob.drop_all_held_items()
		affected_mob.emote("cough")

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Heliothene Substrate////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_stunshield
	name = "Heliothene Substrate"
	description = "A pale, waxy secretion that thickens into nerve-sheathing filaments, muting external trauma and shocks."
	color = "#f0f0c8"
	reagent_state = LIQUID
	taste_description = "wax and warm salt"
	chemical_flags = CHEMICAL_NOT_SYNTH
	metabolized_traits = list(TRAIT_STUNIMMUNE)

/datum/reagent/medicine/leech_stunshield/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// Drain existing stun states
	affected_mob.AdjustAllImmobility(-60 * delta_time)

	// Stamina regeneration
	need_mob_update += affected_mob.adjustStaminaLoss(-8 * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Xyrthropenic Lattice Serum//////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/medicine/leech_speedboost
	name = "Xyrthropenic Lattice Serum"
	description = "A shimmering, motile distillate that threads itself through tendons, provoking erratic bursts of exceptional speed."
	color = "#80d8ff"
	reagent_state = LIQUID
	taste_description = "cold static and tin"
	chemical_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/medicine/leech_speedboost/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/xyrthropenic_lattice)

/datum/reagent/medicine/leech_speedboost/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/xyrthropenic_lattice)

/datum/reagent/medicine/leech_speedboost/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	// stamina drain
	affected_mob.adjustStaminaLoss(5 * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Somnic Virellate////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/toxin/leech_fakedeath
	name = "Somnic Virellate"
	description = "A dormancy-triggering fungal polymer that collapses movement and respiration into a faint, cadaverous hush."
	color = "#604060"
	reagent_state = LIQUID
	taste_description = "earthy sweetness and cold"
	toxpwr = 0
	chemical_flags = CHEMICAL_NOT_SYNTH
	metabolized_traits = list(TRAIT_FAKEDEATH)

/datum/reagent/toxin/leech_fakedeath/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	to_chat(affected_mob, span_warning("A cloying numbness spreads through your limbs..."))
	affected_mob.fakedeath(type)

/datum/reagent/toxin/leech_fakedeath/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.cure_fakedeath(type)

/datum/reagent/toxin/leech_fakedeath/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.set_silence_if_lower(6 SECONDS)
