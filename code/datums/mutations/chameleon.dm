//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/chameleon
	name = "Chameleon"
	desc = "A mutation that adapts the user's skin pigmentation to their environment. The adaptation has been observed to be most effective while the user is standing still."
	quality = POSITIVE
	difficulty = 16
	instability = 25
	power_coeff = 1
	/// How much the user's alpha is reduced every life tick they are not moving.
	var/effect_speed = 12.5

/datum/mutation/chameleon/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = 255

/datum/mutation/chameleon/on_life(delta_time, times_fired)
	owner.alpha = max(owner.alpha - (effect_speed * delta_time), 0)

/datum/mutation/chameleon/on_move()
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/on_attack_hand(atom/target, proximity)
	if(proximity) //stops tk from breaking chameleon
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/modify()
	..()
	effect_speed = round(initial(effect_speed) * GET_MUTATION_POWER(src))
