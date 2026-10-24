/*
System for drawing organs with overlays. These overlays are drawn directly on the bodypart, attached to a person or not
Works in tandem with the /datum/sprite_accessory datum to generate sprites
Unlike normal organs, we're actually inside a persons limbs at all times
*/
/obj/item/organ
	///The overlay datum that actually draws stuff on the limb
	var/datum/bodypart_overlay/mutant/bodypart_overlay

	///With what DNA block do we mutate in mutate_feature() ? For genetics
	var/dna_block

	///Set to EXTERNAL_BEHIND, EXTERNAL_FRONT or EXTERNAL_ADJACENT if you want to draw one of those layers as the object sprite. FALSE to use your own
	///This will not work if it doesn't have a limb to generate its icon with
	var/use_mob_sprite_as_obj_sprite = FALSE

	///Does this organ have any bodytypes to pass to its bodypart_owner?
	var/external_bodytypes = NONE
	///Does this organ have any bodyshapes to pass to its bodypart_owner?
	var/external_bodyshapes = NONE

	///Which flags does a 'modification tool' need to have to restyle us, if it all possible (located in code/_DEFINES/mobs)
	var/restyle_flags = NONE

	///If not null, overrides the appearance with this sprite accessory datum
	var/sprite_accessory_override

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

	if(restyle_flags)
		RegisterSignal(src, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle))

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
		bodypart_owner?.update_icon_dropped() //are we in a limb?

/obj/item/organ/update_overlays()
	. = ..()

	if(!use_mob_sprite_as_obj_sprite)
		return

	//Build the mob sprite and use it as our overlay
	for(var/external_layer in bodypart_overlay.all_layers)
		if(bodypart_overlay.layers & external_layer)
			. += bodypart_overlay.get_overlay(external_layer, bodypart_owner, bodypart_owner?.is_husked)

///The horns of a lizard!
/obj/item/organ/horns
	name = "horns"
	desc = "Why do lizards even have horns? Well, this one obviously doesn't."
	icon_state = "horns"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	dna_block = DNA_HORNS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_ENAMEL

	bodypart_overlay = /datum/bodypart_overlay/mutant/horns

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/horns
	layers = EXTERNAL_ADJACENT
	feature_key = FEATURE_HORNS
	dyable = TRUE
	draw_on_husks = HUSK_OVERLAY_NORMAL

/datum/bodypart_overlay/mutant/horns/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEHAIR)

///The frills of a lizard (like weird fin ears)
/obj/item/organ/frills
	name = "frills"
	desc = "Ear-like external organs often seen on aquatic reptilians."
	icon_state = "frills"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_FRILLS

	dna_block = DNA_FRILLS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/frills
	layers = EXTERNAL_ADJACENT
	feature_key = FEATURE_FRILLS

/datum/bodypart_overlay/mutant/frills/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEEARS)

///Guess what part of the lizard this is?
/obj/item/organ/snout
	name = "lizard snout"
	desc = "Take a closer look at that snout!"
	icon_state = "snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT

	external_bodyshapes = BODYSHAPE_SNOUTED

	dna_block = DNA_SNOUT_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

	/// Offset to apply to equipment worn on the mouth we give to the head.
	var/datum/worn_feature_offset/worn_mask_offset

/obj/item/organ/snout/on_bodypart_insert(obj/item/bodypart/head/limb)
	. = ..()
	if(isnull(limb.worn_mask_offset))
		worn_mask_offset = limb.worn_mask_offset = new(
			attached_part = limb,
			feature_key = OFFSET_FACEMASK,
			offset_x = list("east" = 1, "west" = -1),
		)

/obj/item/organ/snout/on_bodypart_remove(obj/item/bodypart/head/limb, movement_flags)
	if(worn_mask_offset)
		QDEL_NULL(worn_mask_offset)
		limb.worn_mask_offset = null
	return ..()

/datum/bodypart_overlay/mutant/snout
	layers = EXTERNAL_ADJACENT
	feature_key = FEATURE_SNOUT
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE

/datum/bodypart_overlay/mutant/snout/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDESNOUT)

///A moth's antennae
/obj/item/organ/antennae
	name = "moth antennae"
	desc = "A moths antennae. What is it telling them? What are they sensing?"
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	dna_block = DNA_MOTH_ANTENNAE_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/antennae

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

	///Are we burned?
	var/burnt = FALSE
	///Store our old datum here for if our antennae are healed
	var/original_sprite_datum

/obj/item/organ/antennae/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()

	RegisterSignal(receiver, COMSIG_HUMAN_BURNING, PROC_REF(try_burn_antennae))
	RegisterSignal(receiver, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(heal_antennae))

/obj/item/organ/antennae/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL))

///check if our antennae can burn off ;_;
/obj/item/organ/antennae/proc/try_burn_antennae(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious antennae burn to a crisp!"))

		burn_antennae()
		human.update_body_parts()

///Burn our antennae off ;_;
/obj/item/organ/antennae/proc/burn_antennae()
	var/datum/bodypart_overlay/mutant/antennae/antennae = bodypart_overlay
	antennae.burnt = TRUE
	burnt = TRUE

///heal our antennae back up!!
/obj/item/organ/antennae/proc/heal_antennae(datum/source, heal_flags)
	SIGNAL_HANDLER

	if(!burnt)
		return

	if(heal_flags & (HEAL_LIMBS|HEAL_ORGANS))
		var/datum/bodypart_overlay/mutant/antennae/antennae = bodypart_overlay
		antennae.burnt = FALSE
		burnt = FALSE

///Moth antennae datum, with full burning functionality
/datum/bodypart_overlay/mutant/antennae
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = FEATURE_MOTH_ANTENNAE
	dyable = TRUE
	///Accessory datum of the burn sprite
	var/datum/sprite_accessory/burn_datum = /datum/sprite_accessory/moth_antennae/punished
	///Are we burned? If so we draw differently
	var/burnt = FALSE

/datum/bodypart_overlay/mutant/antennae/New()
	. = ..()

	burn_datum = fetch_sprite_datum(burn_datum) //turn the path into the singleton instance

/datum/bodypart_overlay/mutant/antennae/get_base_icon_state()
	return burnt ? burn_datum.icon_state : sprite_datum.icon_state

/datum/bodypart_overlay/mutant/antennae/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEANTENNAE)
