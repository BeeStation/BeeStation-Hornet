/datum/xenoartifact_trait/misc
	flags = null
	register_targets = FALSE
	weight = 0
	conductivity = 0
	contribute_calibration = FALSE
	can_pearl = FALSE
	flags = XENOA_MISC_TRAIT | XENOA_HIDE_TRAIT

/*
	Objective trait for exploration artifacts
*/

/datum/xenoartifact_trait/misc/objective
	blacklist_traits = list(/datum/xenoartifact_trait/minor/delicate)

/datum/xenoartifact_trait/misc/objective/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/atom/A = component_parent.parent
	A.AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

/datum/xenoartifact_trait/misc/objective/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	var/atom/A = component_parent.parent
	var/datum/component/gps/G = A.GetComponent(/datum/component/gps)
	qdel(G)
	return ..()

/*
	Special activator for closets
*/

/datum/xenoartifact_trait/activator/weighted/closet
	material_desc = null
	flags = XENOA_MISC_TRAIT | XENOA_HIDE_TRAIT

/datum/xenoartifact_trait/activator/weighted/closet/New(atom/_parent)
	. = ..()
	if(!component_parent?.parent || !istype(component_parent.parent, /obj/structure/closet))
		return FALSE

/datum/xenoartifact_trait/activator/weighted/closet/trigger_artifact(atom/target, type = XENOA_ACTIVATION_CONTACT, force)
	var/obj/structure/closet/C = component_parent.parent
	//Trait check - This is different from an anti artifact check and should be done here to avoid activations, this trait is a helper essentially
	if(target && HAS_TRAIT(target, TRAIT_ARTIFACT_IGNORE))
		return FALSE
	//Stop traits that don't register targets activating when we feel them
	if(component_parent.anti_check(target, type))
		return FALSE
	//Door check
	if(!C.opened)
		return FALSE
	//Collect targets
	var/turf/T = get_turf(C)
	for(var/atom/movable/movable in T?.contents)
		component_parent.register_target(movable, force, XENOA_ACTIVATION_CONTACT)
	component_parent.trigger()
	return TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/closet/artifact)

/obj/structure/closet/artifact
	name = "The Bishop" //Proper name

/obj/structure/closet/artifact/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material, list(/datum/xenoartifact_trait/activator/weighted/closet, /datum/xenoartifact_trait/minor/charged, /datum/xenoartifact_trait/minor/cooling, /datum/xenoartifact_trait/minor/capacitive, /datum/xenoartifact_trait/major/animalize), FALSE, FALSE)
