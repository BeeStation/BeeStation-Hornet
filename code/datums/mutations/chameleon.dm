//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/chameleon
	name = "Chameleon"
	desc = "A mutation that adapts the user's skin pigmentation to their environment. The adaptation has been observed to be most effective while the user is standing still."
	quality = POSITIVE
	difficulty = 16
	instability = 25
	var/effect_speed = 25

/datum/mutation/chameleon/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/on_life()
	owner.alpha = max(0, owner.alpha - effect_speed)

/datum/mutation/chameleon/on_move()
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/chameleon/on_attack_hand(atom/target, proximity)
	if(proximity) //stops tk from breaking chameleon
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
		return

/datum/mutation/chameleon/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = 255
