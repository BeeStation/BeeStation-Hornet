/mob/living/basic/synapse_leech/Life(delta_time, times_fired)
	. = ..()

	// Saturation drain comes in two flavors:
	//
	//   1. FORCED drains: caused by player decisions (hiding, attacking, etc). These ignore the
	//      metabolic limit.
	//
	//   2. PASSIVE drains: background systems (substrate conversion, healing, etc)
	//      These collectively share a single metabolic budget per tick. We first
	//      ask each passive system whether it intends to run, divide the budget
	//      equally between the ones that do, and let each one spend up to its share.
	process_forced_drains(delta_time)
	process_passive_drains(delta_time)

	if(nested && host)
		process_host_effects(delta_time)

	if(!matured)
		process_maturity(delta_time)

/// Drains that are not subject to the metabolic limit.
/mob/living/basic/synapse_leech/proc/process_forced_drains(delta_time)
	// Hiding drains saturation constantly. If we run out, unhide automatically.
	if(hidden)
		if(saturation <= LEECH_MIN_SATURATION)
			balloon_alert(src, "too hungry!")
			hidden = FALSE
			layer = initial(layer)
			visible_message(
				span_notice("[src] uncoils back to its full height."),
				span_notice("You rise back up."),
			)
			// Sync the HUD button icon back to off
			var/datum/hud/leech/leech_hud = hud_used
			if(leech_hud?.hide_button)
				leech_hud.hide_button.icon_state = "hide_off"
		else
			adjust_saturation(-LEECH_HIDE_SATURATION_DRAIN * delta_time)

/// Runs all passive saturation consumers, sharing a fixed metabolic budget between them.
/mob/living/basic/synapse_leech/proc/process_passive_drains(delta_time)
	if(saturation <= LEECH_MIN_SATURATION)
		return

	// Decide which passive systems intend to run this tick.
	var/wants_substrate = (substrate < max_substrate)
	var/wants_healing = (health < maxHealth)

	var/active_count = wants_substrate + wants_healing
	if(!active_count)
		return

	// Total saturation that passive systems are allowed to spend this tick.
	var/total_budget = (0.5 + (maturity / 200)) * delta_time
	// Don't let passive drains push us below the minimum saturation.
	total_budget = min(total_budget, saturation - LEECH_MIN_SATURATION)
	if(total_budget <= 0)
		return

	// Equal allocation per active system.
	var/per_system_budget = total_budget / active_count

	if(wants_substrate)
		run_substrate_conversion(delta_time, per_system_budget)
	if(wants_healing)
		run_passive_healing(delta_time, per_system_budget)

/// Converts saturation to substrate, capped by the per-system metabolic allocation.
/mob/living/basic/synapse_leech/proc/run_substrate_conversion(delta_time, budget)
	var/substrate_space = max_substrate - substrate
	if(substrate_space <= 0 || budget <= 0)
		return

	// Each point of saturation produces SUBSTRATE_CONVERSION_RATIO points of substrate.
	// Cap by: metabolic budget, remaining substrate space (in saturation units), and conversion speed.
	var/saturation_to_spend = min( \
		budget, \
		substrate_space / SUBSTRATE_CONVERSION_RATIO, \
		SUBSTRATE_CONVERSION_SPEED * delta_time, \
	)
	if(saturation_to_spend <= 0)
		return

	adjust_saturation(-saturation_to_spend)
	adjust_substrate(saturation_to_spend * SUBSTRATE_CONVERSION_RATIO)

/// Converts saturation to HP, capped by the per-system metabolic allocation.
/mob/living/basic/synapse_leech/proc/run_passive_healing(delta_time, budget)
	var/missing_health = maxHealth - health
	if(missing_health <= 0 || budget <= 0)
		return

	// Each point of saturation restores LEECH_HEAL_PER_SATURATION HP.
	// Cap by: metabolic budget, healing speed, and missing HP (in saturation units).
	var/saturation_to_spend = min( \
		budget, \
		LEECH_HEAL_SATURATION_DRAIN * delta_time, \
		missing_health / LEECH_HEAL_PER_SATURATION, \
	)
	if(saturation_to_spend <= 0)
		return

	adjust_saturation(-saturation_to_spend)
	adjust_health(-saturation_to_spend * LEECH_HEAL_PER_SATURATION)

/mob/living/basic/synapse_leech/proc/process_host_effects(delta_time)
	// If the leech is burrowed it has various effects. Mature leeches are more impactful.
	var/datum/status_effect/leech_familiarity/familiarity = host.has_status_effect(/datum/status_effect/leech_familiarity)
	if(!familiarity)
		familiarity = host.apply_status_effect(/datum/status_effect/leech_familiarity)

	switch(maturity)
		if(0 to 25)
			// Host feels a faint tingling sensation, but it quickly fades.
			if(DT_PROB(10,delta_time))
				to_chat(host, "Weee")
		if(26 to 50)
			// Host feels a persistent itch, like something is crawling under their skin. It's distracting, but not debilitating.
			return
		if(51 to 75)
			// Host feels a strong discomfort, like something is gnawing at their insides. It's hard to focus on anything else.
			return
		if(76 to 100)
			// Host is in agony, feeling like their insides are being torn apart. They can barely function.
			return

/mob/living/basic/synapse_leech/proc/process_maturity(delta_time)
	if(nested && host)
		// Both can give up to 1 point bonus
		var/saturation_factor = saturation / max_saturation
		var/host_health_factor = host.health / host.maxHealth

		// Max is 0.05 per second, which leads to approximately 30 minutes with perfect conditions.
		var/maturity_gain = clamp((saturation_factor + host_health_factor / 36) * delta_time, 0, 0.05)

		maturity += maturity_gain
		if(maturity >= 100)
			reach_full_maturity()

	// We have a cooldown just to make sure we don't spam this.
	if(COOLDOWN_FINISHED(src, maturity_update_cooldown))

		// First, we update max health.
		// A lil leech at 0 maturity has 20 max HP, and a fully mature leech has 50 max HP.
		var/calculated_max_health = 20 + (30 * (maturity / 100))
		if(maxHealth != calculated_max_health)
			var/health_percent = health / maxHealth
			maxHealth = calculated_max_health
			health = maxHealth * health_percent

		// Saturation
		// A lil leech at 0 maturity has 50 max saturation, and a fully mature leech has 200 max saturation.
		var/calculated_max_saturation = 50 + (150 * (maturity / 100))
		if(max_saturation != calculated_max_saturation)
			max_saturation = calculated_max_saturation

		// Substrate
		// 0 maturity has 20 max, fully mature leech has 100 max.
		var/calculated_max_substrate = 20 + (80 * (maturity / 100))
		if(max_substrate != calculated_max_substrate)
			max_substrate = calculated_max_substrate

		update_leech_hud()
		COOLDOWN_START(src, maturity_update_cooldown, 5 SECONDS)
