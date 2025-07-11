/obj/item/bodypart/head
	name = BODY_ZONE_HEAD
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'icons/mob/species/human/bodyparts.dmi'
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
	unarmed_damage_low = 1
	unarmed_damage_high = 3
	bodypart_trait_source = HEAD_TRAIT

	var/mob/living/brain/brainmob //The current occupant.
	var/obj/item/organ/internal/brain/brain //The brain organ
	var/obj/item/organ/internal/eyes/eyes
	var/obj/item/organ/internal/ears/ears
	var/obj/item/organ/internal/tongue/tongue

	/// Do we show the information about missing organs upon being examined? Defaults to TRUE, useful for Dullahan heads.
	var/show_organs_on_examine = TRUE

	//Limb appearance info:
	/// Replacement name
	var/real_name = ""
	/// Flags related to appearance, such as hair, lips, etc
	var/head_flags = HEAD_ALL_FEATURES

	/// Hair style
	var/hairstyle = "Bald"
	/// Hair colour and style
	var/hair_color = "#000000"
	/// Hair alpha
	var/hair_alpha = 255
	/// Is the hair currently hidden by something?
	var/hair_hidden = FALSE

	///Facial hair style
	var/facial_hairstyle = "Shaved"
	///Facial hair color
	var/facial_hair_color = "#000000"
	///Facial hair alpha
	var/facial_hair_alpha = 255
	///Is the facial hair currently hidden by something?
	var/facial_hair_hidden = FALSE

	/// Gradient styles, if any
	var/list/gradient_styles = null
	/// Gradient colors, if any
	var/list/gradient_colors = null

	/// An override color that can be cleared later, affects both hair and facial hair
	var/override_hair_color = null
	/// An override that cannot be cleared under any circumstances, affects both hair and facial hair
	var/fixed_hair_color = null

	///Type of lipstick being used, basically
	var/lip_style
	///Lipstick color
	var/lip_color
	///Current lipstick trait, if any (such as TRAIT_KISS_OF_DEATH)
	var/stored_lipstick_trait

	var/mouth = TRUE

	/// Draw this head as "debrained"
	VAR_PROTECTED/show_debrained = FALSE
	/// Draw this head as missing eyes
	VAR_PROTECTED/show_eyeless = FALSE

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

/obj/item/bodypart/head/Destroy()
	QDEL_NULL(brainmob) //order is sensitive, see warning in Exited() below
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
	if(show_organs_on_examine && IS_ORGANIC_LIMB(src))
		if(!brain)
			. += span_info("The brain has been removed from [src].")
		else if(brain.suicided || brainmob?.suiciding)
			. += span_info("There's a pretty dumb expression on [real_name]'s face; they must have really hated life. There is no hope of recovery.")
		else if(brain.brain_death || brainmob?.health <= HEALTH_THRESHOLD_DEAD)
			. += span_info("It seems to be leaking some kind of... clear fluid? The brain inside must be in pretty bad shape... There is no coming back from that.")
		else if(brainmob)
			if(!brainmob.soul_departed())
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
	var/turf/T = get_turf(src)
	for(var/obj/item/I in src)
		if(I == brain)
			if(user)
				user.visible_message(span_warning("[user] saws [src] open and pulls out a brain!"), span_notice("You saw [src] open and pull out a brain."))
			if(brainmob)
				brainmob.container = null
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(violent_removal && prob(rand(80, 100))) //ghetto surgery can damage the brain.
				to_chat(user, span_warning("[brain] was damaged in the process!"))
				brain.set_organ_damage(brain.maxHealth)
			brain.forceMove(T)
			brain = null
			update_icon_dropped()
		else
			if(istype(I, /obj/item/reagent_containers/pill))
				for(var/datum/action/item_action/hands_free/activate_pill/AP in I.actions)
					qdel(AP)
			else if(isorgan(I))
				var/obj/item/organ/organ = I
				if(organ.organ_flags & ORGAN_UNREMOVABLE)
					continue
			I.forceMove(T)
	eyes = null
	ears = null
	tongue = null
	update_limb()
	return ..()

/obj/item/bodypart/head/update_limb(dropping_limb, is_creating)
	. = ..()
	real_name = owner.real_name
	if(HAS_TRAIT(owner, TRAIT_HUSK))
		real_name = "Unknown"

	if(ishuman(owner)) //No MONKEYS!!!
		update_hair_and_lips(dropping_limb, is_creating)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/bodypart/head/get_limb_icon(dropped)
	. = ..()

	. += get_hair_and_lips_icon(dropped)
	// We need to get the eyes if we are dropped (ugh)
	if(dropped)
		// This is a bit of copy/paste code from eyes.dm:generate_body_overlay
		if(eyes?.eye_icon_state && (head_flags & HEAD_EYESPRITES))
			var/image/eyes_overlay = image('icons/mob/species/human/human_face.dmi', "[eyes.eye_icon_state]", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), dir = SOUTH)
			if(head_flags & HEAD_EYECOLOR)
				if(eyes.eye_color)
					eyes_overlay.color = eyes.eye_color
			if(eyes.overlay_ignore_lighting)
				eyes_overlay.overlays += emissive_appearance(eyes_overlay.icon, eyes_overlay.icon_state, src, alpha = eyes_overlay.alpha)
			else if(blocks_emissive)
				var/atom/location = loc || owner || src
				eyes_overlay.overlays += emissive_blocker(eyes_overlay.icon, eyes_overlay.icon_state, location, alpha = eyes_overlay.alpha)
			if(worn_face_offset)
				worn_face_offset.apply_offset(eyes_overlay)
			. += eyes_overlay
		else if(!eyes && (head_flags & HEAD_EYEHOLES))
			var/image/no_eyes = image('icons/mob/species/human/human_face.dmi', "eyes_missing", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER), dir = SOUTH)
			worn_face_offset?.apply_offset(no_eyes)
			. += no_eyes

	return

/obj/item/bodypart/head/talk_into(mob/holder, message, channel, spans, datum/language/language, list/message_mods)
	var/mob/headholder = holder
	if(istype(headholder))
		headholder.log_talk(message, LOG_SAY, tag = "beheaded talk")

	say(message, language, sanitize = FALSE)
	return NOPASS

/obj/item/bodypart/head/GetVoice()
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

/obj/item/bodypart/head/alien
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "alien_head"
	limb_id = BODYPART_ID_ALIEN
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	max_damage = 500
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ALIEN | BODYTYPE_ORGANIC

/obj/item/bodypart/head/larva
	icon = 'icons/mob/species/alien/bodyparts.dmi'
	icon_static = 'icons/mob/species/alien/bodyparts.dmi'
	icon_state = "larva_head"
	limb_id = BODYPART_ID_LARVA
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	px_x = 0
	px_y = 0
	dismemberable = FALSE
	max_damage = 50
	bodytype = BODYTYPE_LARVA_PLACEHOLDER | BODYTYPE_ORGANIC
