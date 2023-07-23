/// Inflicts crippling brain damage on the target
/datum/smite/apply_brain_damage
	name = "Brain damage"

/datum/smite/apply_brain_damage/effect(client/user, mob/living/target)
	. = ..()
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH - 1, BRAIN_DAMAGE_DEATH - 1)
