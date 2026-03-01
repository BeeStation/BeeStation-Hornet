/*
	Edible
	This trait activates the artifact when it is eaten
*/
/datum/xenoartifact_trait/activator/edible
	material_desc = "edible"
	label_name = "Edible"
	label_desc = "Edible: The artifact seems to be made of an edible material. This material seems to be triggered by being consumed."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 16
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///What reagents does this artifact provide when eaten?
	var/food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	///How long does it take us to bite thise?
	var/bite_time = 4 SECONDS
	///How many reagents do we get per bite, maximum
	var/max_bite_reagents = 2

/datum/xenoartifact_trait/activator/edible/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	component_parent.parent.AddComponent(/datum/component/edible,\
		initial_reagents = food_reagents,\
		foodtypes = RAW | MEAT | GORE,\
		volume = INFINITY,\
		pre_eat = CALLBACK(src, PROC_REF(pre_eat)),\
		after_eat = CALLBACK(src, PROC_REF(after_eat)),\
		eat_time = bite_time,\
		bite_consumption = (max_bite_reagents * (component_parent.trait_strength/100)))
	RegisterSignal(component_parent?.parent, COMSIG_ATOM_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/edible/remove_parent(datum/source, pensive = TRUE)
	if(!component_parent?.parent)
		return ..()
	var/datum/component/edible/E = component_parent.parent.GetComponent(/datum/component/edible)
	qdel(E)
	return ..()

/datum/xenoartifact_trait/activator/edible/translation_type_b(datum/source, atom/item, atom/target)
	do_hint(target, item)

/datum/xenoartifact_trait/activator/edible/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TWIN,  XENOA_TRAIT_HINT_DETECT("health analyzer"), XENOA_TRAIT_HINT_TWIN_VARIANT("start with nutrients"))

/datum/xenoartifact_trait/activator/edible/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/healthanalyzer))
		var/message = ""
		var/index = 0
		for(var/datum/reagent/r as() in food_reagents)
			message = "[message][initial(r.name)][index+1 < length(food_reagents) ? ", " : ""]"
			index += 1
		to_chat(user, "<span class='notice'>[item] detects [message].</span>")
		return ..()

/datum/xenoartifact_trait/activator/edible/proc/pre_eat(eater, feeder)
	return TRUE

/datum/xenoartifact_trait/activator/edible/proc/after_eat(mob/living/eater, mob/feeder, bitecount, bitesize)
	trigger_artifact(eater, XENOA_ACTIVATION_CONTACT)

//CRAZY WACKY VARIANT!
/datum/xenoartifact_trait/activator/edible/random
	label_name = "Edible Δ"
	label_desc = "Edible Δ: The artifact seems to be made of an edible material. This material seems to be triggered by being consumed."
	bite_time = 6 SECONDS
	food_reagents = list()
	conductivity = 8
	///How many random reaagents we're rocking with
	var/random_reagents

/datum/xenoartifact_trait/activator/edible/random/register_parent(datum/source)
	random_reagents = rand(1, 3)
	for(var/i in 1 to random_reagents)
		food_reagents += list(get_random_reagent_id(CHEMICAL_RNG_GENERAL) = 300/random_reagents)
	max_bite_reagents = random_reagents * 2
	return ..()

/datum/xenoartifact_trait/activator/edible/random/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_DETECT("health analyzer"), XENOA_TRAIT_HINT_TWIN_VARIANT("start with 1-3 random chemicals"))

/datum/xenoartifact_trait/activator/edible/random/after_eat(mob/living/eater, mob/feeder, bitecount, bitesize)
	. = ..()
	var/atom/atom_parent = component_parent.parent
	for(var/datum/reagent/R in atom_parent.reagents.reagent_list)
		if(R.type in food_reagents)
			R.volume = 300/random_reagents
	atom_parent.reagents.update_total()
