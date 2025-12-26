/*
	If your trait specifically interacts with the fruit datum's fruit, you'll want it to be a subtype of this
*/
/datum/plant_trait/fruit
	plant_feature_compat = /datum/plant_feature/fruit
	///Reference to our awesome fruit, atom, owner
	var/obj/item/fruit_parent
	///Archive of our fruit parent's trait power, for when we live on a fruit
	var/trait_power
	///Extra text that shows up on fruit with this trait
	var/examine_line = ""

/datum/plant_trait/fruit/setup_parent(_parent)
	. = ..()
	trait_power = parent?.trait_power

/datum/plant_trait/fruit/setup_component_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/fruit/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	. = ..()
	var/datum/plant_trait/fruit/new_trait = .
	//Pre-flight checks
	new_trait.fruit_parent = _parent
	if(!istype(new_trait.fruit_parent))
		new_trait.fruit_parent = null
		return
	//Setup this trait to be associated with an item
	new_trait?.trait_power = trait_power
	if(new_trait.fruit_parent)
		new_trait.setup_fruit_parent()

///Use this to add your changes to the fruit item
/datum/plant_trait/fruit/proc/setup_fruit_parent()
	RegisterSignal(fruit_parent, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(fruit_parent, COMSIG_QDELETING, PROC_REF(catch_qdel))

/datum/plant_trait/fruit/proc/catch_fruit(datum/source, obj/item/fruit)
	SIGNAL_HANDLER

	copy(fruit)

/datum/plant_trait/fruit/proc/catch_examine(datum/source, mob/looker, list/examine_text)
	SIGNAL_HANDLER

	examine_text += examine_line

/datum/plant_trait/fruit/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	if(!QDELING(src))
		qdel(src)

/datum/plant_trait/fruit/proc/catch_activate(datum/source)
	SIGNAL_HANDLER

	return
