/*
	Capacitive
	Gives the artifact extra uses
*/
/datum/xenoartifact_trait/minor/capacitive
	material_desc = "capacitive"
	label_name = "Capacitive"
	label_desc = "Capacitive: The artifact's design seems to incorporate a capacitive elements. This will cause the artifact to have more uses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 30
	///How many extra charges do we get?
	var/max_charges = 2
	///How many extra charges do we have?
	var/current_charge

/datum/xenoartifact_trait/minor/capacitive/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	current_charge = max_charges
	component_parent.cooldown_disabled = TRUE
	setup_generic_item_hint()

/datum/xenoartifact_trait/minor/capacitive/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(current_charge)
		component_parent.reset_timer()
		current_charge -= 1
		component_parent.cooldown_disabled = TRUE
	else
		playsound(get_turf(component_parent?.parent), 'sound/machines/capacitor_charge.ogg', 50, TRUE)
		current_charge = max_charges
		component_parent.cooldown_disabled = FALSE

/datum/xenoartifact_trait/minor/capacitive/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='warning'>[item] detects [current_charge] additional charges!</span>")
		return ..()

/datum/xenoartifact_trait/minor/capacitive/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_DETECT("multitool, which will also reveal the artifact's additional charges."))
