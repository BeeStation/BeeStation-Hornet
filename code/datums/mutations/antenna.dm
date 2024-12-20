/datum/mutation/antenna
	name = "Antenna"
	desc = "The affected person sprouts an antenna. This is known to allow them to access common radio channels passively."
	quality = POSITIVE
	instability = 5
	difficulty = 8
	layer_used = BODY_LAYER
	var/datum/weakref/radio_weakref

/datum/mutation/antenna/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = new(owner)
	linked_radio.implant(owner, null, TRUE, TRUE)
	radio_weakref = WEAKREF(linked_radio)

/datum/mutation/antenna/on_losing(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = radio_weakref.resolve()
	if(linked_radio)
		QDEL_NULL(linked_radio)

/datum/mutation/antenna/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna"))

/datum/mutation/antenna/get_visual_indicator()
	return visual_indicators[type][1]

/obj/item/implant/radio/antenna
	name = "internal antenna organ"
	desc = "The internal organ part of the antenna. Science has not yet given it a good name."
	icon = 'icons/obj/radio.dmi'//maybe make a unique sprite later. not important
	icon_state = "walkietalkie"

/obj/item/implant/radio/antenna/Initialize(mapload)
	. = ..()
	radio.name = "internal antenna"


/datum/mutation/mindreader
	name = "Mind Reader"
	desc = "The affected person can look into the recent memories of others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You hear distant voices at the corners of your mind.</span>"
	text_lose_indication = "<span class='notice'>The distant voices fade.</span>"
	power_path = /datum/action/spell/pointed/mindread
	instability = 40
	difficulty = 8
	locked = TRUE

/datum/action/spell/pointed/mindread
	name = "Mindread"
	desc = "Read the target's mind."
	button_icon_state = "mindread"
	cooldown_time = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND
	mindbound = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/mindswap_target.dmi'

/datum/action/spell/pointed/mindread/is_valid_spell(mob/user, atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/living_cast_on = target
	if(!living_cast_on.mind)
		to_chat(owner, ("<span class='warning'>[target] has no mind to read!</span>"))
		return FALSE
	if(living_cast_on.stat == DEAD)
		to_chat(owner, ("<span class='warning'>[target] is dead!</span>"))
		return FALSE

	return TRUE

/datum/action/spell/pointed/mindread/on_cast(mob/living/user, mob/living/target)
	. = ..()
	if(target.can_block_magic(MAGIC_RESISTANCE_MIND, 0))
		to_chat(owner, ("<span class='warning'>As you reach into [target]'s mind, \
			you are stopped by a mental blockage. It seems you've been foiled.</span>"))
		return

	if(target == owner)
		to_chat(owner, ("<span class='warning'>You plunge into your mind... Yep, it's your mind.</span>"))
		return

	to_chat(owner, ("<span class='boldnotice'>You plunge into [target]'s mind...</span>"))
	if(prob(20))
		// chance to alert the read-ee
		to_chat(target, ("<span class='danger'>You feel something foreign enter your mind.</span>"))

	/* Uhhhh idk what to put here :3
	var/list/recent_speech = list()
	var/list/say_log = list()
	var/log_source = cast_on.logging
	//this whole loop puts the read-ee's say logs into say_log in an easy to access way
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
*/
