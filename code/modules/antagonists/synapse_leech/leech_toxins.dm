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

		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10 * delta_time)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH

#undef LEECH_TOXIN_STAGE_CYCLES

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Corticolytic Paralytide//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/toxin/leech_paralytide
	name = "Corticolytic Paralytide"
	description = "A nerve-targeting paralytic that collapses motor control and speech in seconds, leaving the victim fully conscious but utterly unable to move or speak."
	color = "#7d2bdb"
	reagent_state = LIQUID
	taste_description = "numb static"
	toxpwr = 0.2
	metabolization_rate = 0.4

	/// Stamina loss threshold at which the collapse is triggered.
	var/collapse_threshold = 85
	var/collapse_done = FALSE

/datum/reagent/toxin/leech_paralytide/on_mob_add(mob/living/affected_mob, amount)
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

/datum/reagent/toxin/leech_paralytide/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
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

/// These toxins are still needed:

// --- Healing
// - Organ Healing (brain focus), also cures brain traumas
// - - Gliostatic Myelostim, Heals all organs, but especially neuronal tissue, with a chance to cure brain traumas. A regenerative stimulant that forces accelerated myelin sheath regrowth, repairing trauma‑induced signal loss with unnerving efficiency.
// - Brute/Burn Healing
// - - Hematodermic Fibrilase, Heals Brute/Burn wounds. A viscous gel that infiltrates ruptured tissue and forces accelerated fibroblast division, knitting muscle and skin in minutes.
// - Toxin/DNA Healing + Poison purge + mutation cure.
// - - Xenotrophic Neutralysin, Heals and purges toxins and mutations, A cell‑cleansing compound that forces corrupted cells into apoptosis, flushing toxins and halting mutation cascades.
// - Suffocation healing, also like epinephrine it should stop the patient from dying
// - - Adrenalic Surge Polymer, Heals suffocation and halts crit-death. A synthetic adrenal analogue that spreads through the endocrine system, restoring consciousness and increasing oxygen absorption.
// - Bleed clotting + Saline-type stuff that heals bloodloss.
// - - Coagulant Myelofroth, Healing bloodloss and clotting bleeding wounds, A frothing agent that expands into a dense clotting foam, plugging internal and external bleeds with uncanny precision. It rapidly degenerates into inert oxygen-carrying blood substrate when not under shock.
// - Emergency Panic chem. Makes them jittery and stutter and blurry vision, also dropping items, but they heal quickly, clot quickly.
// - - Hyphovariant Reanimant, Rapidly heals at the cost of manual dexterity. A last resort, it's a volatile endocrine shock that floods the body with unstable energy, boosting clotting and regeneration at the cost of coordination.

// --- Buffs
// - Stamina boost
// - - Heliothene Substrate, Rendering a person near-immune to stuns, this pale, waxy secretion thickens into nerve‑sheathing filaments, muting external trauma and shocks.
// - Speed boost
// - - Xyrthropenic Lattice Serum, A muscle stimulant promoting rapid speed, this shimmering, motile distillate threads itself through tendons, provoking erratic bursts of motion.
// - Chem to silence them and make them look dead
// - - Somnic Virellate, Puts a victim into a corpse-like slumber, A dormancy‑triggering fungal polymer that collapses movement and respiration into a faint, cadaverous hush.

