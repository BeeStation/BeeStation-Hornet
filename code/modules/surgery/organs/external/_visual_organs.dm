/*
System for drawing organs with overlays. These overlays are drawn directly on the bodypart, attached to a person or not
Works in tandem with the /datum/sprite_accessory datum to generate sprites
Unlike normal organs, we're actually inside a persons limbs at all times
*/
/obj/item/organ
	///The overlay datum that actually draws stuff on the limb
	var/datum/bodypart_overlay/mutant/bodypart_overlay

	/// The savefile_key of the preference this relates to. Used for the preferences UI.
	var/preference
	///With what DNA block do we mutate in mutate_feature() ? For genetics
	var/dna_block

	///Set to EXTERNAL_BEHIND, EXTERNAL_FRONT or EXTERNAL_ADJACENT if you want to draw one of those layers as the object sprite. FALSE to use your own
	///This will not work if it doesn't have a limb to generate its icon with
	var/use_mob_sprite_as_obj_sprite = FALSE

	///Does this organ have any bodytypes to pass to its bodypart_owner?
	var/external_bodytypes = NONE

	///Which flags does a 'modification tool' need to have to restyle us, if it all possible (located in code/_DEFINES/mobs)
	//var/restyle_flags = NONE

	///If not null, overrides the appearance with this sprite accessory datum
	var/sprite_accessory_override

//TEMP - kl remove
///The limb we draw on. Organs sit in nullspace and are tracked by reference, so there's no stored
///limb to read - we resolve it from the owner instead. Pass owner_override when calling from a
///removal hook, where owner has already been cleared.
/obj/item/organ/proc/get_bodypart_owner(mob/living/carbon/owner_override)
	RETURN_TYPE(/obj/item/bodypart)
	var/mob/living/carbon/resolved_owner = owner_override || owner
	return resolved_owner?.get_bodypart(deprecise_zone(zone))

/**accessory_type is optional if you haven't set sprite_datums for the object, and is used mostly to generate sprite_datums from a persons DNA
* For _mob_sprite we make a distinction between "Round Snout" and "round". Round Snout is the name of the sprite datum, while "round" would be part of the sprite
* I'm sorry
*/
/obj/item/organ/proc/setup_bodypart_overlay(accessory_type)
	bodypart_overlay = new bodypart_overlay(src)

	accessory_type = accessory_type ? accessory_type : sprite_accessory_override
	var/update_overlays = TRUE
	if(accessory_type)
		bodypart_overlay.set_appearance(accessory_type)
		bodypart_overlay.imprint_on_next_insertion = FALSE
	else if(loc) //we've been spawned into the world, and not in nullspace to be added to a limb (yes its fucking scuffed)
		bodypart_overlay.randomize_appearance()
	else
		update_overlays = FALSE

	if(use_mob_sprite_as_obj_sprite && update_overlays)
		update_appearance(UPDATE_OVERLAYS)

	//if(restyle_flags)
	//	RegisterSignal(src, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle))

/// Some sanity checks, but mostly to check if the person has their preference/dna set to load
/proc/should_visual_organ_apply_to(obj/item/organ/organpath, mob/living/carbon/target)
	if(!initial(organpath.bodypart_overlay))
		return TRUE

	if(isnull(organpath) || isnull(target))
		stack_trace("passed a null path or mob to 'should_visual_organ_apply_to'")
		return FALSE

	var/datum/bodypart_overlay/mutant/bodypart_overlay = initial(organpath.bodypart_overlay)
	var/feature_key = !isnull(bodypart_overlay) && initial(bodypart_overlay.feature_key)
	if(isnull(feature_key))
		return TRUE

	if(target.dna.features[feature_key] != SPRITE_ACCESSORY_NONE)
		return TRUE
	return FALSE

///Update our features after something changed our appearance
/obj/item/organ/proc/mutate_feature(features, mob/living/carbon/human/human)
	if(!dna_block)
		return

	var/list/feature_list = bodypart_overlay.get_global_feature_list()

	bodypart_overlay.set_appearance_from_name(feature_list[deconstruct_block(get_uni_feature_block(features, dna_block), feature_list.len)])

///If you need to change an external_organ for simple one-offs, use this. Pass the accessory type : /datum/accessory/something
/obj/item/organ/proc/simple_change_sprite(accessory_type)
	var/datum/sprite_accessory/typed_accessory = accessory_type //we only take types for maintainability

	bodypart_overlay.set_appearance(typed_accessory)

	if(owner && !(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS)) //are we a person?
		owner.update_body_parts()
	else
		get_bodypart_owner()?.update_icon_dropped() //are we in a limb?

/obj/item/organ/update_overlays()
	. = ..()

	if(!use_mob_sprite_as_obj_sprite)
		return

	//Build the mob sprite and use it as our overlay
	for(var/external_layer in bodypart_overlay.all_layers)
		if(bodypart_overlay.layers & external_layer)
			. += bodypart_overlay.get_overlay(external_layer, get_bodypart_owner())
