/*
	Impulsing
	The artifact dashes away when activated
*/
/datum/xenoartifact_trait/minor/impulse
	label_name = "Impulsing"
	label_desc = "Impulsing: The artifact's design seems to incorporate impulsing elements. This will cause the artifact to have a impulsing away from its current position, when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 10
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Max force we can use, aka how far we throw things
	var/max_force = 7

/datum/xenoartifact_trait/minor/impulse/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_edge_target_turf(get_turf(component_parent.parent), pick(NORTH, EAST, SOUTH, WEST))
	var/atom/movable/movable = component_parent.parent
	//handle being held
	if(isliving(movable.loc))
		var/mob/living/L = movable.loc
		L.dropItemToGround(movable)
	//Get the fuck outta dodge
	component_parent.cooldown_override = TRUE
	movable.throw_at(T, max_force*(component_parent.trait_strength/100), 4)
	component_parent.cooldown_override = FALSE
