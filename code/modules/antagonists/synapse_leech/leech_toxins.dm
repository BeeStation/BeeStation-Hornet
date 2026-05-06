//
// Leech toxins
//
// These are all likely to be very complicated, with multiple stages and a variety of symptoms and effects.
//

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////Nocivorant Mycelotoxin//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

/// Number of cycles each toxin "stage" lasts. SSmobs ticks every 2s, so 15 cycles = 30s.
#define LEECH_TOXIN_STAGE_CYCLES 15

/datum/reagent/toxin/leech_toxin
	name = "Nocivorant Mycelotoxin"
	description = "A neuro-irritant that spreads through the bloodstream like branching filaments, overwhelming pain pathways and destabilizing motor control."
	color = "#30b300"
	reagent_state = LIQUID
	taste_description = "rotting fungus"
	toxpwr = 0.5
	// metabolization_rate is in units-per-second, so a single 5u clears in roughly one stage ~30 seconds.
	metabolization_rate = 0.15
	/// Cycle threshold at which motor symptoms (drops, blur, jitter) begin. (~30s of sustained exposure)
	var/motor_breakdown_cycle = LEECH_TOXIN_STAGE_CYCLES
	/// Cycle threshold at which severe symptoms (paralysis, unconsciousness) begin. (~60s)
	var/severe_cycle = LEECH_TOXIN_STAGE_CYCLES * 2
	/// Cycle threshold at which the victim begins falling asleep / dying. (~90s)
	var/terminal_cycle = LEECH_TOXIN_STAGE_CYCLES * 3

/datum/reagent/toxin/leech_toxin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// Constant low-level pain and stamina drain
	need_mob_update += affected_mob.adjustStaminaLoss(10 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

	// Phase 1, Pain & disorientation.
	if(DT_PROB(12, delta_time))
		to_chat(affected_mob, span_danger(pick(
			"Branching threads of pain crawl beneath your skin!",
			"Your nerves feel like they're being threaded with hot wire!",
			"A wave of searing pain washes over you!",
			"Something is spreading through your veins!",
		)))
		affected_mob.adjust_dizzy_up_to(6 SECONDS * REM * delta_time, 30 SECONDS)
		if(prob(40))
			affected_mob.emote(pick("groan", "gasp", "twitch"))

	// Phase 2, Motor control breakdown.
	if(current_cycle >= motor_breakdown_cycle)
		affected_mob.adjust_jitter_up_to(8 SECONDS * REM * delta_time, 60 SECONDS)
		if(DT_PROB(10, delta_time))
			affected_mob.set_eye_blur_if_lower(8 SECONDS)
			to_chat(affected_mob, span_warning("Your vision blurs as your muscles spasm uncontrollably!"))
		if(DT_PROB(6, delta_time))
			affected_mob.drop_all_held_items()
			to_chat(affected_mob, span_warning("Your fingers refuse to obey you!"))
		need_mob_update += affected_mob.adjustStaminaLoss(20 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

	// Phase 3, Severe neural failure.
	if(current_cycle >= severe_cycle)
		if(DT_PROB(8, delta_time))
			to_chat(affected_mob, span_userdanger("Your body locks up as agony rips through you!"))
			affected_mob.emote("scream")
			affected_mob.Paralyze(3 SECONDS * REM * delta_time)
		if(DT_PROB(5, delta_time))
			affected_mob.Unconscious(2 SECONDS * REM * delta_time)
		need_mob_update += affected_mob.adjustToxLoss(1 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)

	// Phase 4, Terminal stage. Without treatment, the victim rapidly slips away.
	// Brain has 200 HP and dies at BRAIN_DAMAGE_DEATH. With SSmobs ticking ~every 2s
	// and REM = 0.5, 20 * REM * delta_time ~= 20 brain damage per tick, killing an
	// otherwise undamaged brain in roughly 10 seconds of sustained phase 4 exposure.
	if(current_cycle >= terminal_cycle)
		affected_mob.Sleeping(20 * REM * delta_time)
		need_mob_update += affected_mob.adjustToxLoss(2 * REM * delta_time, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20 * REM * delta_time)

	if(need_mob_update)
		return UPDATE_MOB_HEALTH



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
	metabolization_rate = 0.3 // 60 seconds at standard dose of 20u

	/// Stamina loss threshold at which silence is pre-emptively applied to prevent screaming into stam crit
	var/silence_threshold = 70
	/// Stamina loss threshold at which the collapse is triggered. Should be above silence_threshold
	/// but below stam crit (mob.maxHealth, typically 100) so the fall is clean and silent.
	var/collapse_threshold = 85
	var/collapse_done = FALSE
	var/collapse_stamina = 100

/datum/reagent/toxin/leech_paralytide/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	// Immediate sensory effects but not full paralysis.
	to_chat(affected_mob, span_warning("Your hands tremble as your tongue goes numb."))
	affected_mob.adjust_jitter_up_to(8 SECONDS, 30 SECONDS)
	affected_mob.adjust_stutter_up_to(8 SECONDS, 30 SECONDS)
	// Small immediate stamina hit to get them to slow down
	affected_mob.adjustStaminaLoss(20, updating_stamina = FALSE)

/datum/reagent/toxin/leech_paralytide/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	var/need_mob_update = FALSE

	// While the reagent is building up, the victim is jittery and losing stamina slowly.
	if(!collapse_done)

		// Apply flavor
		affected_mob.adjust_jitter_up_to(8 SECONDS * REM * delta_time, 30 SECONDS)
		affected_mob.adjust_stutter_up_to(8 SECONDS * REM * delta_time, 30 SECONDS)

		// Check for stamina and shut them up if they are about to scream
		var/current_stam_loss = affected_mob.getStaminaLoss()
		if(current_stam_loss >= silence_threshold)
			affected_mob.adjust_silence_up_to(8 SECONDS * REM * delta_time, 30 SECONDS)

		// Apply stam. If they're about to scream from this, we've already silenced them.
		need_mob_update += affected_mob.adjustStaminaLoss(50 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

		// Collapse threshold, the flavor is over, now we fuck them up
		if(current_stam_loss >= collapse_threshold)
			collapse_done = TRUE
			need_mob_update = affected_mob.adjustStaminaLoss(collapse_stamina, updating_stamina = FALSE)
			to_chat(affected_mob, span_userdanger("Your legs give out and you collapse as pain tears through you!"))
			affected_mob.Knockdown(6 SECONDS)

	else
		// After collapse: sustained, heavy paralysis/stun for the rest of the reagent duration.
		affected_mob.Paralyze(6 SECONDS * REM * delta_time)
		affected_mob.Knockdown(6 SECONDS * REM * delta_time)
		affected_mob.adjust_silence_up_to(8 SECONDS * REM * delta_time, 30 SECONDS)
		affected_mob.adjust_jitter_up_to(4 SECONDS * REM * delta_time, 30 SECONDS)
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
// - Brute/Burn Healing
// - Toxin/Clone Healing + Poison purge + mutation cure.
// - Suffocation healing, also like epinephrine it should stop the patient from dying
// - Bleed clotting + Saline-type stuff that heals bloodloss.
// - Emergency Panic chem. Makes them jittery and stutter and blurry vision, also dropping items, but they heal quickly, clot quickly.

// --- Buffs
// - Stamina boost
// - Speed boost
// - Chem to silence them and make them look dead
