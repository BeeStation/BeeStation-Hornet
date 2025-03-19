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

/obj/item/organ/ears/on_life()
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
		deaf = max(deaf - 1, 0)
		if(prob(damage / 20) && (damage > low_threshold))
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
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.restoreEars()

/mob/proc/adjustEarDamage()

/mob/living/carbon/adjustEarDamage(ddmg, ddeaf)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.adjustEarDamage(ddmg, ddeaf)
		if(ears.deaf)
			SEND_SOUND(src, sound(null))

/mob/proc/minimumDeafTicks()

/mob/living/carbon/minimumDeafTicks(value)
	var/obj/item/organ/ears/ears = getorgan(/obj/item/organ/ears)
	if(ears)
		ears.minimumDeafTicks(value)


/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	bang_protect = -2

/obj/item/organ/ears/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	..()
	if(pref_load)
		H.update_body()
		return
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = H.dna.species.mutant_bodyparts["ears"] = "Cat"
		H.update_body()

/obj/item/organ/ears/cat/Remove(mob/living/carbon/human/H, special = 0, pref_load = FALSE)
	..()
	if(pref_load && istype(H))
		H.update_body()
		return
	if(istype(H))
		color = H.hair_color
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."
	var/datum/component/waddle

/obj/item/organ/ears/penguin/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE, pref_load = FALSE)
	. = ..()
	if(istype(H))
		to_chat(H, span_notice("You suddenly feel like you've lost your balance."))
		waddle = H.AddComponent(/datum/component/waddling)

/obj/item/organ/ears/penguin/Remove(mob/living/carbon/human/H,  special = 0, pref_load = FALSE)
	. = ..()
	if(istype(H))
		to_chat(H, span_notice("Your sense of balance comes back to you."))
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
		owner.Jitter(30/severity)
		owner.Dizzy(30/severity)
		to_chat(owner, span_warning("Alert: Audio sensors malfunctioning"))


/obj/item/organ/ears/diona
	name = "trichomes"
	icon_state = "diona_ears"
	desc = "A pair of plant matter based ears."
