/*
	Hypodermic
	Injects the target with a random, safe, chemical
*/
/datum/xenoartifact_trait/major/chem
	label_name = "Hypodermic"
	label_desc = "Hypodermic: The artifact seems to contain chemical components. Triggering these components will inject the target with a chemical."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	///What category of random chems are we pulling from?
	var/chem_category = CHEMICAL_RNG_GENERAL
	///What chemical we're injecting
	var/datum/reagent/formula
	///max amount we can inject people with
	var/formula_amount
	var/generic_amount = 11

/datum/xenoartifact_trait/major/chem/New(atom/_parent)
	. = ..()
	formula = get_random_reagent_id(chem_category)
	formula_amount = (initial(formula.overdose_threshold) || generic_amount) - 1

/datum/xenoartifact_trait/major/chem/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(target.reagents)
			playsound(get_turf(target), pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE)
			var/datum/reagents/R = target.reagents
			R.add_reagent(formula, formula_amount*(component_parent.trait_strength/100))
			var/atom/log_atom = component_parent.parent
			log_game("[component_parent] in [log_atom] injected [key_name_admin(target)] with [formula_amount*(component_parent.trait_strength/100)]u of [formula] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		unregister_target(target)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/chem/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("inject the target with a random generic chemical"))

//Evil jonkler version
/datum/xenoartifact_trait/major/chem/fun
	label_name = "Hypodermic Δ"
	label_desc = "Hypodermic Δ: The artifact seems to contain chemical components. Triggering these components will inject the target with a chemical."
	chem_category = CHEMICAL_RNG_FUN
	rarity = XENOA_TRAIT_WEIGHT_RARE
	conductivity = 3

/datum/xenoartifact_trait/major/chem/fun/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("inject the target with a random fun chemical"))
