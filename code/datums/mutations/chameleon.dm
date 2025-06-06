//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/human/chameleon
	name = "Chameleon"
	desc = "A mutation that adapts the user's skin pigmentation to their environment. The adaptation has been observed to be most effective while the user is standing still."
	quality = POSITIVE
	difficulty = 16
	instability = 25
	power_coeff = 1
	/// How much the user's alpha is reduced every life tick they are not moving.
	var/effect_speed = 12.5

/datum/mutation/human/chameleon/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/datum/mutation/human/chameleon/on_life(delta_time, times_fired)
	owner.alpha = max(owner.alpha - (effect_speed * delta_time), 0)

/datum/mutation/human/chameleon/proc/on_move(atom/movable/source, atom/old_loc, move_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER

	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER

	if(!proximity) //stops tk from breaking chameleon
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/modify()
	..()
	effect_speed = round(initial(effect_speed) * GET_MUTATION_POWER(src))

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = 255
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_UNARMED_ATTACK))
