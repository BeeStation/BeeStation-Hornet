/datum/discipline/potence
	name = "Potence"
	discipline_explanation = "Potence is the Discipline that endows vampires with physical vigor and preternatural strength.\n\
		Vampires with the Potence Discipline possess physical prowess beyond mortal bounds."
	icon_state = "potence"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/targeted/brawn, /datum/action/vampire/targeted/lunge)
	level_2 = list(/datum/action/vampire/targeted/brawn/two, /datum/action/vampire/targeted/lunge/two)
	level_3 = list(/datum/action/vampire/targeted/brawn/three, /datum/action/vampire/targeted/lunge/three)
	level_4 = list(/datum/action/vampire/targeted/brawn/four, /datum/action/vampire/targeted/lunge/four)
	level_5 = null

/datum/discipline/potence/brujah
	level_1 = list(/datum/action/vampire/targeted/brawn/brash, /datum/action/vampire/targeted/lunge)
	level_2 = list(/datum/action/vampire/targeted/brawn/brash/two, /datum/action/vampire/targeted/lunge/two)
	level_3 = list(/datum/action/vampire/targeted/brawn/brash/three, /datum/action/vampire/targeted/lunge/three)
	level_4 = list(/datum/action/vampire/targeted/brawn/brash/four, /datum/action/vampire/targeted/lunge/four)
	level_5 = list(/datum/action/vampire/targeted/brawn/brash/five, /datum/action/vampire/targeted/lunge/four)

// Extra damage. Will end at around
/datum/discipline/potence/apply_discipline_quirks(datum/antagonist/vampire/clan_owner)
	. = ..()
	var/mob/living/carbon/human/stronkman = clan_owner.owner.current
	if(istype(stronkman))
		var/datum/species/vamp_species = stronkman.dna.species
		vamp_species.punchdamage += 8
	return
