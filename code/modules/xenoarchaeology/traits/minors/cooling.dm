/*
	Cooling
	Decreases the artifact's initial cooldown by 5 seconds
*/
/datum/xenoartifact_trait/minor/cooling
	material_desc = "cooling"
	label_name = "Cooling"
	label_desc = "Cooling: The artifact's design seems to incorporate cooling elements. This will cause the artifact to cooldown faster."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = -4 SECONDS //Point of balance
	weight = 15
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/cooling/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_touch_hint()

/datum/xenoartifact_trait/minor/cooling/do_hint(mob/user, atom/item)
	. = ..()
	to_chat(user, "<span class='warning'>[component_parent?.parent] feels cool to the touch!</span>")

/datum/xenoartifact_trait/minor/cooling/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(component_parent?.parent)
	particle_holder.add_emitter(/obj/emitter/snow, "snow", 10)
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/cooling/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/cooling/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_INHAND, XENOA_TRAIT_HINT_APPEARANCE("This trait will make frost particles appear around the artifact."))
