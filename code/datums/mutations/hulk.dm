//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
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
		TRAIT_CONFUSEIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE,
		TRAIT_FAST_CUFF_REMOVAL
	)
	var/scream_delay = 50
	var/last_scream = 0

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	ADD_VALUE_TRAIT(owner, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_HULK, "00aa00", SKIN_PRIORITY_HULK)
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/hulk/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!source.combat_mode || !proximity || LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE
	if(!source.can_unarmed_attack())
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!target.attack_hulk(owner))
		return NONE

	if(world.time > (last_scream + scream_delay))
		last_scream = world.time
		INVOKE_ASYNC(src, PROC_REF(scream_attack), source)
	log_combat(source, target, "punched", "hulk powers")
	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	source.changeNext_move(CLICK_CD_MELEE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/mutation/human/hulk/proc/scream_attack(mob/living/carbon/human/source)
	source.say("WAAAAAAAAAAAAAAGH!", forced="hulk")

/datum/mutation/human/hulk/on_life(delta_time, times_fired)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	REMOVE_TRAIT(owner, TRAIT_OVERRIDE_SKIN_COLOUR, SOURCE_HULK)
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	UnregisterSignal(owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK)
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/hulk/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH
