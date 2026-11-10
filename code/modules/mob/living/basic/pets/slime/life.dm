/mob/living/basic/slime/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(!.) //dead or deleted
		return

	if(transformeffects & SLIME_EFFECT_BLACK)
		alpha = buckled ? 255 : 64

	if(!IS_IN_STASIS(src)) //No hunger in stasis
		handle_nutrition(delta_time)
		if((transformeffects & SLIME_EFFECT_PURPLE) && DT_PROB(16, delta_time))
			adjustBruteLoss(-0.25 * delta_time)
		if((transformeffects & SLIME_EFFECT_RAINBOW) && DT_PROB(5, delta_time))
			random_colour()

	handle_slime_stasis()

	if(slime_type.colour == SLIME_TYPE_RED && burn_damage_stored > 80 * delta_time)
		special_mutation_type = /datum/slime_type/crimson
		visible_message(span_danger("[src] shudders, their red core deepening into an abyssal crimson."))
	burn_damage_stored = 0

/mob/living/basic/slime/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	..()
	if(bodytemperature <= (T0C - 40)) // stun temperature
		apply_status_effect(/datum/status_effect/freon)
	else
		remove_status_effect(/datum/status_effect/freon)

	if(stat == DEAD || !(transformeffects & SLIME_EFFECT_DARK_PURPLE))
		return
	var/plasma_amount = min(life_stage == SLIME_LIFE_STAGE_ADULT ? 30 : 15, environment.moles[/datum/gas/plasma])
	if(!plasma_amount)
		return
	environment.adjust_multiple_gases(list(
		/datum/gas/plasma = -plasma_amount,
		/datum/gas/oxygen = plasma_amount,
	))
	adjustBruteLoss(-2)

///Handles if a slime's environment would cause it to enter stasis. Runs while in stasis, unlike handle_environment()
/mob/living/basic/slime/proc/handle_slime_stasis()
	var/datum/gas_mixture/environment = loc.return_air()
	var/bz_percentage = environment?.total_moles() ? environment.moles[/datum/gas/bz] / environment.total_moles() : 0

	if(bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) //Check if we should be in stasis
		if(!IS_IN_STASIS(src))
			to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
			apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)
			powerlevel = 0
			ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)
	else if(IS_IN_STASIS(src))
		to_chat(src, span_notice("You wake up from the stasis."))
		remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)

///Handles the consumption of nutrition, and growth
/mob/living/basic/slime/proc/handle_nutrition(delta_time = SSMOBS_DT)
	if(hunger_disabled) //God as my witness, I will never go hungry again
		set_nutrition(SLIME_STARTING_NUTRITION)
		return

	if(DT_PROB(7.5, delta_time) && !(transformeffects & SLIME_EFFECT_SILVER))
		adjust_nutrition((life_stage == SLIME_LIFE_STAGE_ADULT ? -1 : -0.5) * delta_time)

	if(nutrition < SLIME_STARVE_NUTRITION)
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_STARVING)

		if(DT_PROB(0.5, delta_time) && LAZYLEN(ai_controller?.blackboard[BB_FRIENDS_LIST]))
			var/your_fault = pick(ai_controller.blackboard[BB_FRIENDS_LIST])
			unfriend(your_fault)

	else if(nutrition < SLIME_HUNGER_NUTRITION || (nutrition < SLIME_GROW_NUTRITION && DT_PROB(25, delta_time)) )
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_HUNGRY)

	else
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_NONE)

	if(nutrition == 0) //adjust nutrition ensures it can't go below 0
		if(DT_PROB(50, delta_time))
			adjustBruteLoss(rand(0,5))
		return

	var/power_gain = (transformeffects & SLIME_EFFECT_YELLOW) ? 3 : 1

	if (SLIME_GROW_NUTRITION <= nutrition)

		if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
			adjust_nutrition(-10 * delta_time)
			amount_grown++

		if(powerlevel < SLIME_MAX_POWER && DT_PROB(30-powerlevel*2, delta_time))
			powerlevel = min(powerlevel + power_gain, SLIME_MAX_POWER)

	else if (powerlevel < SLIME_MEDIUM_POWER && SLIME_HUNGER_NUTRITION <= nutrition && DT_PROB(25-powerlevel*5, delta_time))
		powerlevel = min(powerlevel + power_gain, SLIME_MEDIUM_POWER)

	update_action_buttons_icon()
