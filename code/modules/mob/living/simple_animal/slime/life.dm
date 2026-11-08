
/mob/living/simple_animal/slime/Life(delta_time = SSMOBS_DT, times_fired)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	alpha = 255
	if(transformeffects & SLIME_EFFECT_BLACK)
		alpha = 64
	. = ..()
	if(!.)
		return

	// We get some passive bruteloss healing if we're not dead
	if(stat != DEAD && DT_PROB(16, delta_time))
		var/heal = 0.5
		if(transformeffects & SLIME_EFFECT_PURPLE)
			heal += 0.25
		adjustBruteLoss(-heal * delta_time)
	if((transformeffects & SLIME_EFFECT_RAINBOW) && DT_PROB(5, delta_time))
		random_colour()
	if(isliving(buckled))
		handle_feeding(delta_time, times_fired)
	if(stat != CONSCIOUS) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
		return
	handle_nutrition(delta_time, times_fired)
	if(QDELETED(src)) // Stop if the slime split during handle_nutrition()
		return
	handle_targets(delta_time, times_fired)
	if(ckey)
		return
	handle_mood(delta_time, times_fired)
	handle_speech(delta_time, times_fired)
	if(slime_type.colour == SLIME_TYPE_RED && burn_damage_stored > 80 * delta_time)
		special_mutation = TRUE
		special_mutation_type = /datum/slime_type/crimson
		visible_message(span_danger("[src] shudders, their red core deepening into an abyssal crimson."))
	burn_damage_stored = 0

// Unlike most of the simple animals, slimes support UNCONSCIOUS. This is an ugly hack.
/mob/living/simple_animal/slime/update_stat()
	switch(stat)
		if(UNCONSCIOUS, HARD_CRIT)
			if(health > 0)
				return
	return ..()

/// Runs on SSfastprocess while the slime has a target. Started by set_target() and handle_targets().
/mob/living/simple_animal/slime/process()
	if(stat == DEAD || !Target || client || buckled)
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, chase_step_cooldown))
		return
	COOLDOWN_START(src, chase_step_cooldown, (cached_multiplicative_slowdown > 0 ? cached_multiplicative_slowdown : 1) + 2)

	var/slime_on_target = 0
	if(Target.buckled_mobs?.len && (locate(/mob/living/simple_animal/slime) in Target.buckled_mobs))
		slime_on_target = 1

	if(Target.get_virtual_z_level() == src.get_virtual_z_level() && !is_attack_on_cooldown && get_dist(Target, src) <= 1)
		if(!slime_on_target && can_feed_on(Target))
			if(!Target.client || prob(20))
				start_feeding(Target)
				return PROCESS_KILL
		if((attacked_stacks || rabid) && Adjacent(Target))
			Target.attack_animal(src)
			is_attack_on_cooldown = TRUE
			addtimer(VARSET_CALLBACK(src, is_attack_on_cooldown, FALSE), attack_cooldown_time)
	else if(src in viewers(7, Target))
		if((transformeffects & SLIME_EFFECT_BLUESPACE) && powerlevel >= 5)
			do_teleport(src, get_turf(Target), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
			powerlevel -= 5
		else
			step_to(src, Target)
	else
		set_target(null)
		return PROCESS_KILL

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	var/loc_temp = get_temperature(environment)
	var/divisor = 10 /// The divisor controls how fast body temperature changes, lower causes faster changes

	var/temp_delta = loc_temp - bodytemperature
	if(abs(temp_delta) > 50) // If the difference is great, reduce the divisor for faster stabilization
		divisor = 5

	if(temp_delta < 0) // It is cold here
		if(!on_fire) // Do not reduce body temp when on fire
			adjust_bodytemperature(clamp((temp_delta / divisor) * delta_time, temp_delta, 0))
	else // This is a hot place
		adjust_bodytemperature(clamp((temp_delta / divisor) * delta_time, 0, temp_delta))

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(100 * delta_time)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * delta_time)

	if(stat != DEAD)
		var/bz_percentage = environment.total_moles() ? (environment.moles[/datum/gas/bz] / environment.total_moles()) : 0
		var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) || force_stasis
		if(transformeffects & SLIME_EFFECT_DARK_PURPLE)
			var/amt = (life_stage == SLIME_LIFE_STAGE_ADULT) ? 30 : 15
			var/plas_amt = min(amt, environment.moles[/datum/gas/plasma])
			environment.adjust_multiple_gases(list(
				/datum/gas/plasma = -plas_amt,
				/datum/gas/oxygen = plas_amt,
			))
			adjustBruteLoss(plas_amt ? -2 : 0)

		switch(stat)
			if(CONSCIOUS)
				if(stasis)
					to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
					set_stat(UNCONSCIOUS)
					powerlevel = 0
					rabid = FALSE
					regenerate_icons()
			if(UNCONSCIOUS, HARD_CRIT)
				if(!stasis)
					to_chat(src, span_notice("You wake up from the stasis."))
					set_stat(CONSCIOUS)
					regenerate_icons()

	updatehealth()

///Handles the slime draining the target it is attached to
/mob/living/simple_animal/slime/proc/handle_feeding(delta_time, times_fired)
	alpha = 255
	var/mob/living/M = buckled
	if(transformeffects & SLIME_EFFECT_OIL)
		var/datum/reagent/fuel/fuel = new
		fuel.expose_mob(buckled,TOUCH,20)
		qdel(fuel)
	if(M.stat == DEAD)
		if(client)
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")
		//we go rabid after finishing to feed on a human with a client.
		if(M.client && ishuman(M))
			rabid = TRUE

		set_target(null)
		stop_feeding()
		return

	if(DT_PROB(5, delta_time) && M.client)
		to_chat(M, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
		"You feel like you're about to die!", \
		"You feel every part of your body screaming in agony!", \
		"A low, rolling pain passes through your body!", \
		"Your body feels as if it's falling apart!", \
		"You feel extremely weak!", \
		"A sharp, deep pain bathes every inch of your body!")]</span>")

	var/bonus_damage = 1
	var/need_mob_update
	if(transformeffects & SLIME_EFFECT_RED)
		bonus_damage *= 1.1
	need_mob_update = M.adjustCloneLoss(4 * bonus_damage, updating_health = FALSE)
	need_mob_update += M.adjustToxLoss(2 * bonus_damage, updating_health = FALSE)
	if(ismonkey(M))
		need_mob_update += M.adjustCloneLoss(monkey_bonus_damage*bonus_damage, updating_health = FALSE)

	if(need_mob_update)
		M.updatehealth()

	add_nutrition((15 * CONFIG_GET(number/damage_multiplier)))
	adjustBruteLoss(-2.5 * delta_time)

///Handles the slime's nutirion level
/mob/living/simple_animal/slime/proc/handle_nutrition(delta_time, times_fired)
	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(DT_PROB(7.5, delta_time) && !(transformeffects & SLIME_EFFECT_SILVER))
		adjust_nutrition(-0.5 * (1 + (life_stage == SLIME_LIFE_STAGE_ADULT)) * delta_time)

	if(nutrition <= 0)
		set_nutrition(0)
		adjustBruteLoss(1)
	else if (nutrition >= grow_nutrition && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-10 * delta_time)
		amount_grown++
		update_action_buttons_icon()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(life_stage == SLIME_LIFE_STAGE_ADULT && loc.AllowDrop())
			Reproduce()
		else
			Evolve()

///Adds nutrition to the slime's nutrition level. Has a chance to increase its electric levels.
/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	var/gainpower = (transformeffects & SLIME_EFFECT_YELLOW) ? 3 : 1
	set_nutrition(min((nutrition + nutrition_to_add), max_nutrition))
	if(nutrition >= grow_nutrition)
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel += gainpower
	else if(nutrition >= hunger_nutrition + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel += gainpower
