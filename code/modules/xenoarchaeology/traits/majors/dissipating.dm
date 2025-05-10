/*
	Dissipating
	The artifact spawns a cloud of smoke
*/
/datum/xenoartifact_trait/major/smoke
	label_name = "Dissipating"
	label_desc = "Dissipating: The artifact seems to contain dissipating components. Triggering these components will cause the artifact to create a cloud of smoke."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 6
	///The maximum size of our smoke stack in turfs, I think
	var/max_size = 3

/datum/xenoartifact_trait/major/smoke/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce a harmless cloud of smoke"))

/datum/xenoartifact_trait/major/smoke/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	make_smoke()

/datum/xenoartifact_trait/major/smoke/proc/make_smoke()
	var/datum/effect_system/smoke_spread/E = new()
	E.set_up(max_size*(component_parent.trait_strength/100), get_turf(component_parent.parent))
	E.start()

//Foam variant
/datum/xenoartifact_trait/major/smoke/foam
	label_name = "Dissipating Σ"
	label_desc = "Dissipating: The artifact seems to contain dissipating components. Triggering these components will cause the artifact to create a body of foam."
	max_size = 5
	conductivity = 3

/datum/xenoartifact_trait/major/smoke/foam/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce a harmless body of foam"))

/datum/xenoartifact_trait/major/smoke/foam/make_smoke()
	var/datum/effect_system/foam_spread/E = new()
	E.set_up(max_size*(component_parent.trait_strength/100), get_turf(component_parent.parent))
	E.start()

//Chem smoke variant
/datum/xenoartifact_trait/major/smoke/chem
	label_name = "Dissipating Δ"
	label_desc = "Dissipating Δ: The artifact seems to contain dissipating components. Triggering these components will cause the artifact to create a cloud of smoke containing a random chemical."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 12
	///What chemical we're injecting
	var/datum/reagent/formula
	///max amount we can inject people with
	var/formula_amount
	var/generic_amount = 11

/datum/xenoartifact_trait/major/smoke/chem/New(atom/_parent)
	. = ..()
	formula = get_random_reagent_id(CHEMICAL_RNG_GENERAL)
	formula_amount = (initial(formula.overdose_threshold) || generic_amount) - 1

/datum/xenoartifact_trait/major/smoke/chem/make_smoke()
	var/datum/effect_system/smoke_spread/chem/E = new()
	var/datum/reagents/R = new(formula_amount)
	R.add_reagent(formula, formula_amount)
	E.set_up(R, max_size*(component_parent.trait_strength/100), get_turf(component_parent.parent))
	E.start()

/datum/xenoartifact_trait/major/smoke/chem/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("create a cloud of smoke containing a random chemical"), XENOA_TRAIT_HINT_RANDOMISED)


//Chem foam variant
/datum/xenoartifact_trait/major/smoke/chem/foam
	label_name = "Dissipating Ω"
	label_desc = "Dissipating Ω: The artifact seems to contain dissipating components. Triggering these components will cause the artifact to create a body of foam containing a random chemical."
	max_size = 5
	conductivity = 21

/datum/xenoartifact_trait/major/smoke/chem/foam/make_smoke()
	var/datum/effect_system/foam_spread/E = new()
	var/datum/reagents/R = new(formula_amount)
	R.add_reagent(formula, formula_amount)
	E.set_up(max_size*(component_parent.trait_strength/100), get_turf(component_parent.parent), R)
	E.start()

/datum/xenoartifact_trait/major/smoke/chem/foam/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("create a body of foam containing a random chemical"), XENOA_TRAIT_HINT_RANDOMISED)
