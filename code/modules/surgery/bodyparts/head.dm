/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/human/bodyparts.dmi'
	icon_state = "default_human_head"
	max_damage = 200
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
	plaintext_zone = "head"
	w_class = WEIGHT_CLASS_BULKY //Quite a hefty load
	slowdown = 1 //Balancing measure
	throw_range = 2 //No head bowling
	px_x = 0
	px_y = -8
	stam_damage_coeff = 1
	max_stamina_damage = 100
	is_dimorphic = TRUE
	unarmed_attack_verb = "bite"
	unarmed_attack_effect = ATTACK_EFFECT_BITE
	unarmed_attack_sound = 'sound/weapons/bite.ogg'
	unarmed_miss_sound = 'sound/weapons/bite.ogg'
	unarmed_damage = 3
	bodypart_trait_source = HEAD_TRAIT

	var/mob/living/brain/brainmob //The current occupant.
	var/obj/item/organ/brain/brain //The brain organ
	var/obj/item/organ/eyes/eyes
	var/obj/item/organ/ears/ears
	var/obj/item/organ/tongue/tongue

	/// Do we show the information about missing organs upon being examined? Defaults to TRUE
	var/show_organs_on_examine = TRUE

	//Limb appearance info:
	/// Replacement name
	var/real_name = ""
	/// Flags related to appearance, such as hair, lips, etc
	var/head_flags = HEAD_ALL_FEATURES


	/// Hair style
	var/hair_style = "Bald"
	/// Hair colour and style
	var/hair_color = COLOR_BLACK
	/// Hair alpha
	var/hair_alpha = 255
	/// Is the hair currently hidden by something?
	var/hair_hidden = FALSE
	/// Lazy initialized hashset of all hair masks that should be applied
	var/list/hair_masks

	/// Facial hair style
	var/facial_hairstyle = "Shaved"
	/// Facial hair color
	var/facial_hair_color = COLOR_BLACK
	///Facial hair alpha
	var/facial_hair_alpha = 255
	///Is the facial hair currently hidden by something?
	var/facial_hair_hidden = FALSE
	/// Gradient styles, if any
	var/list/gradient_styles = list(
		"None",	//Hair gradient style
		"None",	//Facial hair gradient style
	)
	/// Gradient colors, if any
	var/list/gradient_colors = list(
		COLOR_BLACK,	//Hair gradient color
		COLOR_BLACK,	//Facial hair gradient color
	)

	/// An override color that can be cleared later, affects both hair and facial hair
	var/override_hair_color = null
	/// An override that cannot be cleared under any circumstances, affects both hair and facial hair
	var/fixed_hair_color = null

	var/lip_style
	var/lip_color
	var/stored_lipstick_trait

	var/mouth = TRUE

	var/is_blushing = FALSE

	/// Offset to apply to equipment worn on the ears
	var/datum/worn_feature_offset/worn_ears_offset
	/// Offset to apply to equipment worn on the eyes
	var/datum/worn_feature_offset/worn_glasses_offset
	/// Offset to apply to equipment worn on the mouth
	var/datum/worn_feature_offset/worn_mask_offset
	/// Offset to apply to equipment worn on the head
	var/datum/worn_feature_offset/worn_head_offset
	/// Offset to apply to overlays placed on the face
	var/datum/worn_feature_offset/worn_face_offset

	/// Draw this head as "debrained"
	VAR_PROTECTED/show_debrained = FALSE

	/// Draw this head as missing eyes
	VAR_PROTECTED/show_eyeless = FALSE

/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in handle_atom_del() below
	QDEL_NULL(brain)
	QDEL_NULL(eyes)
	QDEL_NULL(ears)
	QDEL_NULL(tongue)

	QDEL_NULL(worn_ears_offset)
	QDEL_NULL(worn_glasses_offset)
	QDEL_NULL(worn_mask_offset)
	QDEL_NULL(worn_head_offset)
	QDEL_NULL(worn_face_offset)
	return ..()

/obj/item/bodypart/head/handle_atom_del(atom/A)
	if(A == brain)
		brain = null
		update_icon_dropped()
		if(!QDELETED(brainmob)) //this shouldn't happen without badminnery.
			message_admins("Brainmob: ([ADMIN_LOOKUPFLW(brainmob)]) was left stranded in [src] at [ADMIN_VERBOSEJMP(src)] without a brain!")
			log_game("Brainmob: ([key_name(brainmob)]) was left stranded in [src] at [AREACOORD(src)] without a brain!")
	if(A == brainmob)
		brainmob = null
	if(A == eyes)
		eyes = null
		update_icon_dropped()
	if(A == ears)
		ears = null
	if(A == tongue)
		tongue = null
	return ..()

/obj/item/bodypart/head/examine(mob/user)
	. = ..()
	if(IS_ORGANIC_LIMB(src) && show_organs_on_examine)
		if(!brain)
			. += span_info("The brain has been removed from [src].")
		else if(brain.suicided || brainmob?.suiciding)
			. += span_info("There's a pretty dumb expression on [real_name]'s face; they must have really hated life. There is no hope of recovery.")
		else if(brain.brain_death || brainmob?.health <= HEALTH_THRESHOLD_DEAD)
			. += span_info("It seems to be leaking some kind of... clear fluid? The brain inside must be in pretty bad shape... There is no coming back from that.")
		else if(brainmob) //We only care about the head's brainmob here
			if(brainmob.key || brainmob.get_ghost(FALSE, TRUE))
				. += span_info("Its muscles are still twitching slightly... It still seems to have a bit of life left to it.")
			else
				. += span_info("It seems seems particularly lifeless. Perhaps there'll be a chance for them later.")
		else if(brain?.decoy_override)
			. += span_info("It seems particularly lifeless. Perhaps there'll be a chance for them later.")
		else
			. += span_info("It seems completely devoid of life.")

		if(!eyes)
			. += span_info("[real_name]'s eyes appear to have been removed.")

		if(!ears)
			. += span_info("[real_name]'s ears appear to have been removed.")

		if(!tongue)
			. += span_info("[real_name]'s tongue appears to have been removed.")


/obj/item/bodypart/head/can_dismember(obj/item/I)
	if(owner.stat < HARD_CRIT)
		return FALSE
	return ..()

/obj/item/bodypart/head/drop_organs(mob/user, violent_removal)
	var/atom/drop_loc = drop_location()
	for(var/obj/item/head_item in src)
		if(head_item == brain)
			if(user)
				user.visible_message(span_warning("[user] saws [src] open and pulls out a brain!"), span_notice("You saw [src] open and pull out a brain."))
			if(brainmob)
				brainmob.container = null
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, span_warning("[brain] was damaged in the process!"))
				brain.set_organ_damage(brain.maxHealth)
			brain.forceMove(drop_loc)
			brain = null
			update_icon_dropped()
		else
			if(istype(head_item, /obj/item/reagent_containers/pill))
				for(var/datum/action/item_action/hands_free/activate_pill/AP in head_item.actions)
					qdel(AP)
			else if(isorgan(head_item))
				var/obj/item/organ/organ = head_item
				if(organ.organ_flags & ORGAN_UNREMOVABLE)
					continue
			head_item.forceMove(drop_loc)
	eyes = null
	ears = null
	tongue = null

	return ..()

/obj/item/bodypart/head/update_limb(dropping_limb, is_creating)
	. = ..()
	if(!isnull(owner))
		if(HAS_TRAIT(owner, TRAIT_HUSK))
			real_name = "Unknown"
		else
			real_name = owner.real_name
	if(ishuman(owner)) //No MONKEYS!!!
		update_hair_and_lips(dropping_limb, is_creating)

	is_blushing = HAS_TRAIT(owner, TRAIT_BLUSHING) // Caused by either the *blush emote or the "drunk" mood event

/obj/item/bodypart/head/get_limb_icon(dropped)
	. = ..()

	// Blush emote overlay
	if (is_blushing)
		var/mutable_appearance/blush_overlay = mutable_appearance('icons/mob/human/human_face.dmi', "blush", CALCULATE_MOB_OVERLAY_LAYER(BODY_ADJ_LAYER)) //should appear behind the eyes
		var/blush_color = COLOR_BLUSH_PINK
		if(ishuman(owner))
			var/mob/living/carbon/human/species_human = owner
			if(species_human?.dna?.species.blush_color)
				blush_color = species_human.dna.species.blush_color

		blush_overlay.color = blush_color
		worn_face_offset?.apply_offset(blush_overlay)
		. += blush_overlay

	. += get_hair_and_lips_icon(dropped)

	// We need to get the eyes if we are dropped (ugh)
	if(dropped)
		var/obj/item/organ/eyes/eyes = locate(/obj/item/organ/eyes) in src
		// This is a bit of copy/paste code from eyes.dm:generate_body_overlay
		if(eyes?.eye_icon_state && (head_flags & HEAD_EYESPRITES))
			var/image/eye_left = image(eyes.eye_icon, "[eyes.eye_icon_state]_l", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), dir = SOUTH)
			var/image/eye_right = image(eyes.eye_icon, "[eyes.eye_icon_state]_r", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), dir = SOUTH)
			if(head_flags & HEAD_EYECOLOR)
				if(eyes.eye_color_left)
					eye_left.color = eyes.eye_color_left
				if(eyes.eye_color_right)
					eye_right.color = eyes.eye_color_right
			if(eyes.overlay_ignore_lighting)
				eye_left.overlays += emissive_appearance(eye_left.icon, eye_left.icon_state, alpha = eye_left.alpha)
				eye_right.overlays += emissive_appearance(eye_right.icon, eye_right.icon_state, alpha = eye_right.alpha)
			else if(blocks_emissive != EMISSIVE_BLOCK_NONE)
				eye_left.overlays += emissive_blocker(eye_left.icon, eye_left.icon_state, alpha = eye_left.alpha)
				eye_right.overlays += emissive_blocker(eye_right.icon, eye_right.icon_state, alpha = eye_right.alpha)
			if(worn_face_offset)
				worn_face_offset.apply_offset(eye_left)
				worn_face_offset.apply_offset(eye_right)
			. += eye_left
			. += eye_right
		else if(!eyes && (head_flags & HEAD_EYEHOLES))
			var/image/no_eyes = image('icons/mob/human/human_eyes.dmi', "eyes_missing", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), dir = SOUTH)
			worn_face_offset?.apply_offset(no_eyes)
			. += no_eyes

	return

/obj/item/bodypart/head/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/toy_talk)

/obj/item/bodypart/head/get_voice()
	return "The head of [real_name]"

/obj/item/bodypart/head/monkey
	icon = 'icons/mob/animal_parts.dmi'
	icon_static = 'icons/mob/animal_parts.dmi'
	icon_state = "default_monkey_head"
	limb_id = SPECIES_MONKEY
	bodytype = BODYTYPE_MONKEY | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	dmg_overlay_type = SPECIES_MONKEY
	is_dimorphic = FALSE
	head_flags = HEAD_LIPS|HEAD_DEBRAIN

/obj/item/bodypart/head/monkey/teratoma
	icon_state = "teratoma_head"
	limb_id = "teratoma"
	head_flags = HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES

/obj/item/bodypart/head/alien
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "alien_head"
	limb_id = BODYPART_ID_ALIEN
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 500
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC

/obj/item/bodypart/head/larva
	icon = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/human/species/alien/bodyparts.dmi'
	icon_state = "larva_head"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	bodypart_flags = BODYPART_UNREMOVABLE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
