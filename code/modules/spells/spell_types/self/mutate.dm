/// A spell type that adds mutations to the caster temporarily.
/datum/action/spell/apply_mutations
	button_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'

	school = SCHOOL_TRANSMUTATION

	/// A list of all mutations we add on cast
	var/list/mutations_to_add = list()
	/// The duration the mutations will last afetr cast (keep this above the minimum cooldown)
	var/mutation_duration = 10 SECONDS

/datum/action/spell/apply_mutations/New(Target)
	. = ..()
	spell_requirements |= SPELL_REQUIRES_HUMAN // The spell involves mutations, so it always require human / dna

/datum/action/spell/apply_mutations/Remove(mob/living/remove_from)
	remove_mutations(remove_from)
	return ..()

/datum/action/spell/apply_mutations/is_valid_spell(mob/user, atom/target)
	var/mob/living/carbon/human/human_caster = user // Requires human anyways
	return !!human_caster.dna

/datum/action/spell/apply_mutations/on_cast(mob/living/carbon/human/user, atom/target)
	. = ..()
	for(var/mutation in mutations_to_add)
		user.dna.add_mutation(mutation)
	addtimer(CALLBACK(src, PROC_REF(remove_mutations), user), mutation_duration, TIMER_DELETE_ME)

/// Removes the mutations we added from casting our spell
/datum/action/spell/apply_mutations/proc/remove_mutations(mob/living/carbon/human/cast_on)
	if(QDELETED(cast_on) || !is_valid_spell(cast_on))
		return

	for(var/mutation in mutations_to_add)
		cast_on.dna.remove_mutation(mutation)

/datum/action/spell/apply_mutations/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk for a short while."
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS

	invocation = "BIRUZ BENNAR"
	invocation_type = INVOCATION_SHOUT

	mutations_to_add = list(/datum/mutation/hulk)
	mutation_duration = 30 SECONDS
