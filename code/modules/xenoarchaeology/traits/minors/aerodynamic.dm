/*
	Aerodynamic
	Makes the artifact easy to throw
*/
/datum/xenoartifact_trait/minor/aerodynamic
	material_desc = "aerodynamic"
	label_name = "Aerodynamic"
	label_desc = "Aerodynamic: The artifact's design seems to incorporate aerodynamicded elements. This will allow the artifact to be thrown further."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = -5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old throw range
	var/old_throw_range

/datum/xenoartifact_trait/minor/aerodynamic/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/atom/movable/movable = component_parent.parent
	if(ismovable(movable))
		old_throw_range = movable.throw_range
		movable.throw_range = 9

/datum/xenoartifact_trait/minor/aerodynamic/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/atom/movable/movable = component_parent.parent
	if(ismovable(movable))
		movable.throw_range = old_throw_range
	return ..()

/datum/xenoartifact_trait/minor/aerodynamic/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
