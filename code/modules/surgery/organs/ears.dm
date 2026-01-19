/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	visual = FALSE
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
	if(!iscarbon(owner))
		return
	..()
	var/mob/living/carbon/C = owner
	if((damage < maxHealth) && (organ_flags & ORGAN_FAILING))	//ear damage can be repaired from the failing condition
		organ_flags &= ~ORGAN_FAILING
	// genetic deafness prevents the body from using the ears, even if healthy
	if(HAS_TRAIT(C, TRAIT_DEAF))
		deaf = max(deaf, 1)
	else if(!(organ_flags & ORGAN_FAILING)) // if this organ is failing, do not clear deaf stacks.
		deaf = max(deaf - (0.5 * delta_time), 0)
		if((damage > low_threshold) && DT_PROB(damage / 60, delta_time))
			adjustEarDamage(0, 4)
			SEND_SOUND(C, sound('sound/weapons/flash_ring.ogg'))
			to_chat(C, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))
	else if((organ_flags & ORGAN_FAILING) && (deaf == 0))
		deaf = 1	//stop being not deaf you deaf idiot

/obj/item/organ/ears/proc/restoreEars()
	deaf = 0
	damage = 0
	organ_flags &= ~ORGAN_FAILING

	var/mob/living/carbon/C = owner

	if(iscarbon(owner) && HAS_TRAIT(C, TRAIT_DEAF))
		deaf = 1

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	damage = max(damage + (ddmg*damage_multiplier), 0)
	deaf = max(deaf + (ddeaf*damage_multiplier), 0)

/obj/item/organ/ears/proc/minimumDeafTicks(value)
	deaf = max(deaf, value)

/obj/item/organ/ears/invincible
	damage_multiplier = 0


/mob/proc/restoreEars()

/mob/living/carbon/restoreEars()
	var/obj/item/organ/ears/ears = get_organ_by_type(/obj/item/organ/ears)
	if(ears)
		ears.restoreEars()

/mob/proc/adjustEarDamage()

/mob/living/carbon/adjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/ears/ears = get_organ_by_type(/obj/item/organ/ears)
	if(ears)
		ears.adjustEarDamage(ddmg, ddeaf)
		if(ears.deaf)
			SEND_SOUND(src, sound(null))

/mob/proc/minimumDeafTicks()

/mob/living/carbon/minimumDeafTicks(value)
	var/obj/item/organ/ears/ears = get_organ_by_type(/obj/item/organ/ears)
	if(ears)
		ears.minimumDeafTicks(value)


/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	bang_protect = -2

/obj/item/organ/ears/cat/on_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = "Cat"
		ear_owner.update_body()

/obj/item/organ/ears/cat/on_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = "None"
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."
	var/datum/component/waddle

/obj/item/organ/ears/penguin/on_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
		waddle = ear_owner.AddComponent(/datum/component/waddling)

/obj/item/organ/ears/penguin/on_remove(mob/living/carbon/human/ear_owner)
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
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

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
