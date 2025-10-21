// A buff given to people sacrificed to help them survive.

/// Screen alert for the below status effect.
/atom/movable/screen/alert/status_effect/unholy_determination
	name = "Unholy Determination"
	desc = "You appear in a unfamiliar room. The darkness begins to close in. Panic begins to set in. There is no time. Fight on, or die!"
	icon_state = "regenerative_core"

/// The buff given to people within the shadow realm to assist them in surviving.
/datum/status_effect/unholy_determination
	id = "unholy_determination"
	duration = 3 MINUTES // Given a default duration so no one gets to hold onto this buff forever by accident.
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/unholy_determination

/datum/status_effect/unholy_determination/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/unholy_determination/on_apply()
	initial_heal()
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, type)
	ADD_TRAIT(owner, TRAIT_NOBREATH, type)
	return TRUE

/datum/status_effect/unholy_determination/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, type)
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, type)
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, type)

/datum/status_effect/unholy_determination/tick(seconds_between_ticks)
	// The amount we heal of each damage type per tick. If we're missing legs we heal better because we can't dodge.
	var/healing_amount = 1 + (2 - owner.usable_legs)

	// In softcrit you're, strong enough to stay up.
	if(owner.health <= owner.crit_threshold && owner.health >= HEALTH_THRESHOLD_FULLCRIT)
		if(prob(5))
			to_chat(owner, span_hypnophrase("Your body feels like giving up, but you fight on!"))
		healing_amount *= 2
	// ...But reach hardcrit and you're done. You now die faster.
	if (owner.health < HEALTH_THRESHOLD_FULLCRIT)
		if(prob(5))
			to_chat(owner, span_big("[span_hypnophrase("You can't hold on for much longer...")]"))
		healing_amount *= -0.5

	if(owner.health > owner.crit_threshold && prob(4))
		owner.set_jitter_if_lower(20 SECONDS)
		owner.set_dizzy_if_lower(10 SECONDS)
		owner.adjust_hallucinations_up_to(6 SECONDS, 48 SECONDS)

	if(prob(2))
		playsound(owner, pick(GLOB.creepy_ambience), 50, TRUE)

	adjust_all_damages(healing_amount)
	adjust_temperature()
	adjust_bleed_wounds()

/*
 * Initially heals the owner a bit, ensuring they have no suffocation and no immobility.
*/
/datum/status_effect/unholy_determination/proc/initial_heal()
	owner.ExtinguishMob()
	// catch your breath
	owner.losebreath = 0
	owner.setOxyLoss(0, FALSE)
	// get back on your feet
	owner.resting = FALSE
	owner.setStaminaLoss(0)
	owner.SetSleeping(0)
	owner.SetUnconscious(0)
	owner.SetAllImmobility(0, TRUE)

/*
 * Heals up all the owner a bit, fire stacks and losebreath included.
 */
/datum/status_effect/unholy_determination/proc/adjust_all_damages(amount)

	owner.fire_stacks = max(owner.fire_stacks - 1, 0)
	owner.losebreath = max(owner.losebreath - 0.5, 0)

	owner.adjustToxLoss(-amount, FALSE, TRUE)
	owner.adjustOxyLoss(-amount, FALSE)
	owner.adjustBruteLoss(-amount, FALSE)
	owner.adjustFireLoss(-amount)

/*
 * Adjust the owner's temperature up or down to standard body temperatures.
 */
/datum/status_effect/unholy_determination/proc/adjust_temperature()
	var/target_temp = BODYTEMP_NORMAL
	if(owner.bodytemperature > target_temp)
		owner.adjust_bodytemperature(-50 * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)
	else if(owner.bodytemperature < (target_temp + 1))
		owner.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT, target_temp)

/*
 * Slow and stop any blood loss the owner's experiencing.
 */
/datum/status_effect/unholy_determination/proc/adjust_bleed_wounds()
	if(!iscarbon(owner) || !owner.blood_volume)
		return

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = owner.blood_volume + 2
