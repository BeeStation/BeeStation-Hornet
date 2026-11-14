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
		return

	if(initial(organpath.sprite_accessory_override))
		return TRUE

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

	if(!use_mob_sprite_as_obj_sprite || isnull(bodypart_overlay))
		return

	. += bodypart_overlay.get_all_overlays(bodypart_owner)

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
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		)
	feature_key = FEATURE_HORNS
	dyable = TRUE
	draw_on_husks = HUSK_OVERLAY_NORMAL

/datum/bodypart_overlay/mutant/horns/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !is_obscured(bodypart_owner, HIDEHAIR)

/datum/bodypart_overlay/mutant/horns/get_global_feature_list()
	return GLOB.horns_list

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
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
		)
	feature_key = FEATURE_FRILLS

/datum/bodypart_overlay/mutant/frills/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !is_obscured(bodypart_owner, HIDEHAIR)

/datum/bodypart_overlay/mutant/frills/icon_render_key(obj/item/bodypart/limb)
	. = ..()
	var/obj/item/bodypart/head/head = limb
	if(istype(head) && LAZYLEN(head.hair_masks))
		. += jointext(head.hair_masks, ",")

/datum/bodypart_overlay/mutant/frills/get_image(obj/item/bodypart/limb, layer_index, layer_real)
	var/obj/item/bodypart/head/head = limb
	if(!istype(head) || !LAZYLEN(head.hair_masks))
		return ..()

	var/list/hair_masks_to_use = head.hair_masks
	var/icon_state_to_use = build_icon_state(layer_index, limb)
	var/frill_cache_key = "[sprite_datum.type]-[icon_state_to_use]-[jointext(hair_masks_to_use, ",")]"
	var/static/list/cached_frill_icons
	var/icon/cached_icon = LAZYACCESS(cached_frill_icons, frill_cache_key)
	if(isnull(cached_icon))
		cached_icon = icon(sprite_datum.icon, icon_state_to_use)
		for(var/datum/hair_mask/mask as anything in hair_masks_to_use)
			cached_icon.Blend(icon(mask::icon, mask::icon_state), ICON_ADD)
		LAZYSET(cached_frill_icons, frill_cache_key, cached_icon)

	var/mutable_appearance/uncached_appearance = mutable_appearance(cached_icon, layer = layer_real)
	uncached_appearance.alpha = sprite_datum.overlay_alpha
	if(sprite_datum.center)
		center_image(uncached_appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)
	return uncached_appearance

/datum/bodypart_overlay/mutant/frills/get_global_feature_list()
	return GLOB.frills_list

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
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_SNOUT
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE

/datum/bodypart_overlay/mutant/snout/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDESNOUT)

/datum/bodypart_overlay/mutant/snout/get_global_feature_list()
	return GLOB.snouts_list

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

	if(heal_flags & (HEAL_LIMBS|HEAL_ORGANS))
		restore_antennae()

///Unburn our antennae
/obj/item/organ/antennae/proc/restore_antennae()
	var/datum/bodypart_overlay/mutant/antennae/antennae = bodypart_overlay
	antennae.burnt = FALSE
	burnt = FALSE

///Moth antennae datum, with full burning functionality
/datum/bodypart_overlay/mutant/antennae
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER
	)
	feature_key = FEATURE_MOTH_ANTENNAE
	dyable = TRUE
	overlay_flags = parent_type::overlay_flags | LIMB_OVERLAY_HARDLIGHT
	///Accessory datum of the burn sprite
	var/datum/sprite_accessory/burn_datum = /datum/sprite_accessory/moth_antennae/punished
	///Are we burned? If so we draw differently
	var/burnt = FALSE

/datum/bodypart_overlay/mutant/antennae/New()
	. = ..()

	burn_datum = fetch_sprite_datum(burn_datum) //turn the path into the singleton instance

/datum/bodypart_overlay/mutant/antennae/get_global_feature_list()
	return GLOB.moth_antennae_list

/datum/bodypart_overlay/mutant/antennae/get_base_icon_state()
	return burnt ? burn_datum.icon_state : sprite_datum.icon_state

/datum/bodypart_overlay/mutant/antennae/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !is_obscured(bodypart_owner, HIDEANTENNAE)

///An apid's antennae
/obj/item/organ/apid_antenna
	name = "apid antennae"
	desc = "A pair of apid antennae. They still twitch at the smell of pollen."
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANTENNAE

	dna_block = DNA_APID_ANTENNA_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/apid_antenna

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/apid_antenna
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_APID_ANTENNA
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE
	overlay_flags = parent_type::overlay_flags | LIMB_OVERLAY_HARDLIGHT

/datum/bodypart_overlay/mutant/apid_antenna/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !is_obscured(bodypart_owner, HIDEHAIR)

/datum/bodypart_overlay/mutant/apid_antenna/get_global_feature_list()
	return GLOB.apid_antenna_list

///The coloured chitin on an apid's head
/obj/item/organ/apid_headstripes
	name = "apid headstripes"
	desc = "A patch of striped chitin from an apid's head."
	icon = 'icons/mob/human/species/apid/apid_head.dmi'
	icon_state = "m_apid_headstripes_thick_ADJ"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HEADSTRIPES

	dna_block = DNA_APID_HEADSTRIPES_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/apid_headstripes

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/apid_headstripes
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_APID_HEADSTRIPES
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE

/datum/bodypart_overlay/mutant/apid_headstripes/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner)
	return ..() && !(bodypart_owner.owner?.obscured_slots & HIDEEYES)

/datum/bodypart_overlay/mutant/apid_headstripes/get_global_feature_list()
	return GLOB.apid_headstripes_list

///The coloured chitin on an apid's body
/obj/item/organ/apid_stripes
	name = "apid stripes"
	desc = "A sheet of striped chitin from an apid's body."
	icon = 'icons/mob/human/species/apid/apid_body.dmi'
	icon_state = "m_apid_stripes_thick_ADJ"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_STRIPES

	dna_block = DNA_APID_STRIPES_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/apid_stripes

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/apid_stripes
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_APID_STRIPES
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE

/datum/bodypart_overlay/mutant/apid_stripes/get_global_feature_list()
	return GLOB.apid_stripes_list

///A psyphoza's mushroom cap
/obj/item/organ/psyphoza_cap
	name = "psyphoza cap"
	desc = "The mushroom cap of a psyphoza. Its shape is said to decide its owner's luck."
	icon = 'icons/mob/psyphoza_caps.dmi'
	icon_state = "m_psyphoza_cap_wide_ADJ"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_PSYPHOZA_CAP

	dna_block = DNA_PSYPHOZA_CAP_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_PLANT

	bodypart_overlay = /datum/bodypart_overlay/mutant/psyphoza_cap

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/psyphoza_cap
	layers = list(EXTERNAL_ADJACENT = BODY_ADJ_LAYER)
	feature_key = FEATURE_PSYPHOZA_CAP
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE

/datum/bodypart_overlay/mutant/psyphoza_cap/get_global_feature_list()
	return GLOB.psyphoza_cap_list
