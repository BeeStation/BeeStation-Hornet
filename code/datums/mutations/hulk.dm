//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	species_allowed = list(SPECIES_HUMAN) //no skeleton/lizard hulk
	health_req = 25
	instability = 40
	traits = list(
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE,
		TRAIT_FAST_CUFF_REMOVAL,
		TRAIT_CHUNKYFINGERS
	)
	var/scream_delay = 50
	var/last_scream = 0

/datum/mutation/hulk/New(class, timer, datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = list("." = "!"), end_string = "!!", uppercase = TRUE)

/datum/mutation/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	for(var/obj/item/bodypart/part as anything in owner.get_bodyparts())
		part.variable_color = COLOR_DARK_LIME
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/datum/mutation/hulk/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!source.combat_mode || !proximity || LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE
	if(!source.can_unarmed_attack())
		return COMPONENT_SKIP_ATTACK
	if(!target.attack_hulk(owner))
		return NONE

	if(world.time > (last_scream + scream_delay))
		last_scream = world.time
		INVOKE_ASYNC(src, PROC_REF(scream_attack), source)
	log_combat(source, target, "punched", "hulk powers")
	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	source.changeNext_move(CLICK_CD_MELEE)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/mutation/hulk/proc/scream_attack(mob/living/carbon/human/source)
	source.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced="hulk")

/datum/mutation/hulk/on_life(delta_time, times_fired)
	if(owner.health < owner.crit_threshold)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))
		qdel(src)

/datum/mutation/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	REMOVE_TRAIT(owner, TRAIT_HULK, SOURCE_HULK)
	for(var/obj/item/bodypart/part as anything in owner.get_bodyparts())
		part.variable_color = null
	owner.update_body_parts()
	UnregisterSignal(owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK)
