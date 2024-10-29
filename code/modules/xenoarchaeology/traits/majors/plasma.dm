/*
	Electrified
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	label_name = "Electrified"
	label_desc = "Electrified: The artifact seems to contain electrifying components. Triggering these components will shock the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 27
	///max damage
	var/max_damage = 25
	///Max cable charge
	var/max_cable_charge = 50000

/datum/xenoartifact_trait/major/shock/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(component_parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	do_sparks(3, FALSE, component_parent.parent)
	//electrocute targets
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.electrocute_act(max_damage*(component_parent.trait_strength/100), component_parent.parent, 1, 1) //Deal a max of 25
		else if(istype(target, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((component_parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
		var/atom/log_atom = component_parent.parent
		log_game("[component_parent] in [log_atom] electrocuted [key_name_admin(target)] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
	//If there's an exposed cable below us, charge it
	var/obj/structure/cable/C = locate(/obj/structure/cable) in get_turf(component_parent.parent)
	if(C?.invisibility <= UNDERFLOOR_HIDDEN)
		C.powernet?.newavail += max_cable_charge*(component_parent.trait_strength/100)
	//Get rid of anything else, since we can't interact with it
	dump_targets()
	//Tidy up focus too
	clear_focus()

/*
	Barreled Δ
	Barreled but scary
*/
/datum/xenoartifact_trait/major/projectile/unsafe
	material_desc = "barreled"
	label_name = "Barreled Δ"
	label_desc = "Barreled Δ: The artifact seems to contain projectile components. Triggering these components will produce an unsafe projectile."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	possible_projectiles = list(/obj/projectile/beam/laser, /obj/projectile/bullet/c38, /obj/projectile/energy/tesla)
	conductivity = 3

/datum/xenoartifact_trait/major/projectile/unsafe/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce an unsafe projectile"))

/*
	EMP
	Creates an EMP effect at the position of the artfiact
*/
/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The artifact seems to contain electromagnetic pulsing components. Triggering these components will create an EMP."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	rarity = XENOA_TRAIT_WEIGHT_MYTHIC //Fuck this trait
	weight = 9
	conductivity = 36

/datum/xenoartifact_trait/major/emp/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(do_emp)) //empluse() calls stoplag(), which calls sleep()

/datum/xenoartifact_trait/major/emp/proc/do_emp()
	var/turf/T = get_turf(component_parent.parent)
	if(!T)
		return
	playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)
	empulse(T, max(1, component_parent.trait_strength*0.03), max(1, component_parent.trait_strength*0.05, 1))
	var/atom/log_atom = component_parent.parent
	log_game("[component_parent] in [log_atom] made an EMP at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")

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

/*
	Combusting
	Ignites the target
*/
/datum/xenoartifact_trait/major/combusting
	label_name = "Combusting"
	label_desc = "Combusting: The artifact seems to contain combusting components. Triggering these components will ignite the target."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 24
	weight = 12
	///max fire stacks
	var/max_stacks = 6

/datum/xenoartifact_trait/major/combusting/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.adjust_fire_stacks(max_stacks*(component_parent.trait_strength/100))
			victim.IgniteMob()
		else
			target.fire_act(1000, 500)
	dump_targets()
	clear_focus()

/*
	Freezing
	Freezes the target
*/
/datum/xenoartifact_trait/major/freezing
	label_name = "Freezing"
	label_desc = "Freezing: The artifact seems to contain freezing components. Triggering these components will freeze the target."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	conductivity = 12
	weight = 24

/datum/xenoartifact_trait/major/freezing/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		//Pretty much copied from the wizard traps
		to_chat(target, "<span class='danger'><B>You're frozen solid!</B></span>")
		target.Paralyze(20)
		target.adjust_bodytemperature(-300)
		target.apply_status_effect(/datum/status_effect/freon)
	dump_targets()
	clear_focus()
