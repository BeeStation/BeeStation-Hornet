/*
	Anchor
	Anchors the artifact
*/
/datum/xenoartifact_trait/minor/anchor
	label_name = "Anchor"
	label_desc = "Anchor: The artifact's design seems to incorporate anchoring elements. This will cause the artifact to anchor when triggered, it can also be unanchored with typical tools."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 10
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/minor/anchor/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/atom/movable/movable = component_parent.parent
	if(ismovable(movable))
		RegisterSignal(movable, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(toggle_anchor))

/datum/xenoartifact_trait/minor/anchor/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/atom/movable/movable = component_parent.parent
	if(ismovable(movable))
		movable.anchored = FALSE
	return ..()

/datum/xenoartifact_trait/minor/anchor/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	toggle_anchor()

/datum/xenoartifact_trait/minor/anchor/proc/toggle_anchor(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	var/atom/movable/movable = component_parent?.parent
	//handle being held
	if(isliving(movable.loc))
		var/mob/living/M = movable.loc
		M.dropItemToGround(movable)
	//Anchor
	if(ismovable(movable) && isturf(movable.loc))
		movable.anchored = !movable.anchored
		playsound(get_turf(component_parent?.parent), 'sound/items/handling/wrench_pickup.ogg', 50, TRUE)
	//Message
	movable.visible_message("<span class='warning'>[movable] [movable.anchored ? "anchors to" : "unanchors from"] [get_turf(movable)]!</span>", allow_inside_usr = TRUE)
