/*
	Charged
	Increases the artifact trait strength by 25%
*/
/datum/xenoartifact_trait/minor/charged
	material_desc = "charged"
	label_name = "Charged"
	label_desc = "Charged: The artifact's design seems to incorporate looping elements. This will cause the artifact to produce more powerful effects."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 10
	conductivity = 15
	///Reference to our particle holder
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/charged/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	component_parent.trait_strength *= 1.25
	setup_generic_touch_hint()

/datum/xenoartifact_trait/minor/charged/remove_parent(datum/source, pensive)
	if(!component_parent)
		return ..()
	component_parent.trait_strength /= 1.25
	return ..()

/datum/xenoartifact_trait/minor/charged/do_hint(mob/user, atom/item)
	. = ..()
	to_chat(user, "<span class='warning'>Your hair stands on end!</span>")

/datum/xenoartifact_trait/minor/charged/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(component_parent?.parent)
	particle_holder.add_emitter(/obj/emitter/electrified, "electrified", 10)
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/charged/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/charged/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_INHAND, XENOA_TRAIT_HINT_APPEARANCE("This trait will make static particles appear around the artifact."))
