/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS

	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = span_info("Your ears begin to resonate with an internal ring sometimes.")
	now_failing = span_warning("You are unable to hear at all!")
	now_fixed = span_info("Noise slowly begins filling your ears once more.")
	low_threshold_cleared = span_info("The ringing in your ears has died down.")

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/ears/on_life(delta_time, times_fired)
	// only inform when things got worse, needs to happen before we heal
	if((damage > low_threshold && prev_damage < low_threshold) || (damage > high_threshold && prev_damage < high_threshold))
		to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))

	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return

	if((organ_flags & ORGAN_FAILING))
		deaf = max(deaf, 1) // if we're failing we always have at least 1 deaf stack (and thus deafness)
	else // only clear deaf stacks if we're not failing
		deaf = max(deaf - (0.5 * delta_time), 0)
		if((damage > low_threshold) && DT_PROB(damage / 60, delta_time))
			adjustEarDamage(0, 4)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

	if(deaf)
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	if(HAS_TRAIT(owner, TRAIT_GODMODE))
		return
	set_organ_damage(clamp(damage + (ddmg * damage_multiplier), 0, maxHealth))
	deaf = max(deaf + (ddeaf * damage_multiplier), 0)

/obj/item/organ/ears/invincible
	damage_multiplier = 0

/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	bang_protect = -2
	//preference = "feature_human_ears"

	dna_block = DNA_EARS_BLOCK

	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears

/// Bodypart overlay for the horrible cat ears
/datum/bodypart_overlay/mutant/cat_ears
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_HAIR
	feature_key = "ears"

	/// Layer upon which we add the inner ears overlay
	var/inner_layer = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/cat_ears/get_global_feature_list()
	return SSaccessories.ears_list

/datum/bodypart_overlay/mutant/cat_ears/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE
	return TRUE

/datum/bodypart_overlay/mutant/cat_ears/get_image(image_layer, obj/item/bodypart/limb)
	var/mutable_appearance/base_ears = ..()
	base_ears.color = (dye_color || draw_color)

	// Only add inner ears on the inner layer
	if(image_layer != bitflag_to_layer(inner_layer))
		return base_ears

	// Construct image of inner ears, apply to base ears as an overlay
	feature_key += "inner"
	var/mutable_appearance/inner_ears = ..()
	feature_key = initial(feature_key)
	var/mutable_appearance/ear_holder = mutable_appearance(layer = image_layer)
	ear_holder.overlays += base_ears
	ear_holder.overlays += inner_ears
	return ear_holder

/datum/bodypart_overlay/mutant/cat_ears/color_image(image/overlay, layer, obj/item/bodypart/limb)
	return // We color base ears manually above in get_image

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."
	var/datum/component/waddle

/obj/item/organ/ears/penguin/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
		waddle = ear_owner.AddComponent(/datum/component/waddling)

/obj/item/organ/ears/penguin/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
		QDEL_NULL(waddle)

/obj/item/organ/ears/bronze
	name = "tin ears"
	desc = "The robust ears of a bronze golem. "
	damage_multiplier = 0.1 //STRONK
	bang_protect = 1 //Fear me weaklings.

/obj/item/organ/ears/robot
	name = "auditory sensors"
	icon_state = "robotic_ears"
	desc = "A pair of microphones intended to be installed in an IPC head, that grant the ability to hear."
	zone = "head"
	slot = "ears"
	gender = PLURAL
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/ears/robot/emp_act(severity)
	. = ..()
	if(prob(30/severity))
		owner.set_jitter_if_lower(60 SECONDS/severity)
		owner.set_dizzy_if_lower(60 SECONDS/severity)
		to_chat(owner, span_warning("Alert: Audio sensors malfunctioning"))


/obj/item/organ/ears/diona
	name = "trichomes"
	icon_state = "diona_ears"
	desc = "A pair of plant matter based ears."
