/*
	Sticky
	The artifact briefly becomes sticky when activated
*/
/datum/xenoartifact_trait/minor/sticky
	material_desc = "sticky"
	label_name = "Sticky"
	label_desc = "Sticky: The artifact's design seems to incorporate sticky elements. This will cause the artifact to briefly become sticky, when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	weight = 10
	conductivity = 15
	///Max amount of time we can be sticky for
	var/sticky_time = 25 SECONDS
	var/sticky_timer

/datum/xenoartifact_trait/minor/sticky/remove_parent(datum/source, pensive)
	var/atom/movable/movable = component_parent?.parent
	if(!movable)
		return ..()
	REMOVE_TRAIT(movable, TRAIT_NODROP, "[REF(src)]")
	deltimer(sticky_timer)
	return ..()

/datum/xenoartifact_trait/minor/sticky/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/atom/movable/movable = component_parent.parent
	movable.visible_message("<span class='warning'>[movable] starts secreting a sticky substance!</span>", TRUE, allow_inside_usr = TRUE)
	if(HAS_TRAIT_FROM(movable, TRAIT_NODROP, "[REF(src)]"))
		return
	ADD_TRAIT(movable, TRAIT_NODROP, "[REF(src)]")
	sticky_timer = addtimer(CALLBACK(src, PROC_REF(unstick)), sticky_time, TIMER_STOPPABLE)

/datum/xenoartifact_trait/minor/sticky/proc/unstick()
	var/atom/movable/movable = component_parent.parent
	REMOVE_TRAIT(movable, TRAIT_NODROP, "[REF(src)]")
