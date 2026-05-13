//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	species_allowed = list(SPECIES_HUMAN) //no skeleton/lizard hulk
	mobtypes_allowed = list(/mob/living/carbon/human)
	health_req = 25
	instability = 40
	locked = TRUE
	traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE,
		TRAIT_FAST_CUFF_REMOVAL
	)

/datum/mutation/hulk/New(class, timer, datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = list("." = "!"), end_string = "!!", uppercase = TRUE)

/datum/mutation/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	ADD_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		part.variable_color = "#00aa00"
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_HULK)
	owner.update_body_parts()

/datum/mutation/hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/hulk/on_life(delta_time, times_fired)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))

/datum/mutation/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		part.variable_color = null
	owner.update_body_parts()
