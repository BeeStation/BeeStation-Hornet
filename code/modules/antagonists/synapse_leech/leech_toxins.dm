// Leech Toxin. Their primary method of attack and self-defense.
// Causes intense pain, toxin buildup, dizziness, and eventually unconsciousness and death if untreated.
//
// Tuning notes:
// - Each leech bite injects LEECH_TOXIN_PER_ATTACK of this reagent.
// - Metabolism is set so a single 5u dose clears in ~30 seconds (one "stage").
// - SSmobs ticks every 2s, so a stage = 15 cycles. The leech can stack stages
//   by biting again before the previous dose clears, escalating the victim
//   from pain (stage 1) -> motor breakdown (stage 2) -> severe failure (stage 3)
//   -> terminal (stage 4, death by ~2 minutes of sustained envenomation).

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
	need_mob_update += affected_mob.adjustStaminaLoss(8 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

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
		need_mob_update += affected_mob.adjustStaminaLoss(12 * REM * delta_time, updating_stamina = FALSE, required_biotype = affected_biotype)

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
