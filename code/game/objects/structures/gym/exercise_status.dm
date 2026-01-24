/// How much stun resistance you gain every time you exercise
#define EXERCISE_INCREMENT 0.001
/// The max amount that you can be improved by exercise
#define EXERCISE_LIMIT 0.5
/// How much exercise effect you lose every second.
/// Each exercise will last 10 seconds.
/// Maximum exercise lasts 1000 seconds, or about 16 minutes.
#define EXERCISE_STEP 0.0005
/// The minimum that exercise needs to change before we step (Rounded to percentages so 1%)
#define EXERCISE_VISUAL_DELTA 0.005

/datum/status_effect/exercised
	id = "exericsed"
	status_type = STATUS_EFFECT_MERGE
	tick_interval = ((1 SECONDS) * EXERCISE_VISUAL_DELTA) / EXERCISE_STEP
	alert_type = /atom/movable/screen/alert/status_effect/exercised
	var/applied_amount = 0
	var/exercise_amount = 0

/datum/status_effect/exercised/on_creation(mob/living/new_owner, exercise_amount)
	src.exercise_amount = exercise_amount * EXERCISE_INCREMENT
	return ..()

/datum/status_effect/exercised/merge(exercise_amount)
	src.exercise_amount = min(src.exercise_amount + exercise_amount * EXERCISE_INCREMENT, EXERCISE_LIMIT)
	update_exercise()

/datum/status_effect/exercised/on_apply()
	update_exercise()
	return TRUE

/datum/status_effect/exercised/on_remove()
	if (ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.stun_add += applied_amount
		applied_amount = 0

/datum/status_effect/exercised/tick()
	exercise_amount -= EXERCISE_VISUAL_DELTA
	update_exercise()
	return ..()

/datum/status_effect/exercised/proc/update_exercise()
	if (exercise_amount <= 0)
		qdel(src)
		return
	if (ishuman(owner))
		var/delta = exercise_amount - applied_amount
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.stun_add -= delta
		human_owner.physiology.stamina_mod -= delta
		applied_amount = exercise_amount

/datum/status_effect/exercised/get_examine_text()
	switch (exercise_amount)
		if (0.3 to 0.5)
			return span_warning("[owner.p_They()] seem[owner.p_s()] exceptionally strong!")
		if (0.1 to 0.3)
			return span_warning("[owner.p_They()] seem[owner.p_s()] very strong!")
		else
			return span_warning("[owner.p_They()] seem[owner.p_s()] strong!")

/datum/status_effect/exercised/update_shown_duration()
	linked_alert?.maptext = MAPTEXT("[round(100 * exercise_amount / EXERCISE_LIMIT, 1)]%")

/atom/movable/screen/alert/status_effect/exercised
	name = "Exercised"
	desc = "You have worked out recently, making you stronger and more resistant to being brought down by stunning weapons."
	icon_state = "weights"

#undef EXERCISE_INCREMENT
#undef EXERCISE_LIMIT
#undef EXERCISE_STEP
#undef EXERCISE_VISUAL_DELTA
