
// CHAINSAW
/obj/item/chainsaw
	name = "chainsaw"
	desc = "A versatile power tool. Useful for limbing trees and delimbing humans."
	icon_state = "chainsaw"
	base_icon_state = "chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 13
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	attack_weight = 2
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	custom_materials = list(/datum/material/iron = 13000)
	hitsound = "swing_hit"
	actions_types = list(/datum/action/item_action/startchainsaw)
	toolspeed = 0.5
	item_flags = ISWEAPON

	/// How much damage the chainsaw deals while active
	var/active_force = 24
	/// How much damage the chainsaw deals when thrown, while active
	var/active_throwforce = 14
	/// How much bleed damage the chainsaw deals while active
	var/active_bleedforce = BLEED_DEEP_WOUND
	/// How sharp this is when active
	var/active_sharpness = SHARP_DISMEMBER
	/// The sound this chainsaw makes when attacking something while active
	var/sound/active_hitsound = 'sound/weapons/chainsaw_hit.ogg'
	/// The sound that plays when the chainsaw is enabled
	var/sound/start_sound = 'sound/weapons/chainsaw_on.ogg'
	/// The sound that plays when the chainsaw is turned off
	var/sound/off_sound = 'sound/weapons/chainsaw_off.ogg'

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		_speed = 3 SECONDS, \
		_effectiveness = 100, \
		_bonus_modifier = 0, \
		_butcher_sound = active_hitsound, \
		disabled = TRUE, \
	)

	AddComponent(/datum/component/two_handed, \
		require_twohands = TRUE, \
		block_power_unwielded = block_power, \
		block_power_wielded = block_power, \
		ignore_attack_self = TRUE, \
	)

	AddComponent(/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		bleedforce_on = active_bleedforce, \
		sharpness_on = active_sharpness, \
		hitsound_on = active_hitsound, \
		w_class_on = w_class, \
		attack_verb_continuous_on = list("saws", "tears", "lacerates", "cuts", "chops", "dices"), \
		attack_verb_simple_on = list("saw", "tear", "lacerate", "cut", "chop", "dice"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/obj/item/chainsaw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	to_chat(user, span_notice("As you pull the starting cord dangling from [src], [active ? "it begins to whirr" : "the chain stops moving"]."))

	if(active && start_sound)
		playsound(src, start_sound, 35, TRUE)
	else if(!active && off_sound)
		playsound(src, off_sound, 35, TRUE)

	tool_behaviour = (active ? TOOL_SAW : NONE)

	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = active

	update_appearance(UPDATE_ICON_STATE)

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/chainsaw/proc/on_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	var/datum/component/transforming/T = GetComponent(/datum/component/transforming)
	if(T && T.active)
		SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user)

/obj/item/chainsaw/suicide_act(mob/living/carbon/user)
	var/datum/component/transforming/transforming = src.GetComponent(/datum/component/transforming)

	if(transforming.active)
		user.visible_message(span_suicide("[user] begins to tear [user.p_their()] head off with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(src, active_hitsound, 100, TRUE)

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		myhead?.dismember()

		return BRUTELOSS

// DOOMGUY CHAINSAW
/obj/item/chainsaw/doomslayer
	name = "THE GREAT COMMUNICATOR"
	desc = span_warning("VRRRRRRR!!!")
	armour_penetration = 100
	active_force = 30

/obj/item/chainsaw/doomslayer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		owner.visible_message(span_danger("Ranged attacks just make [owner] angrier!"))
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		return ..()
	return FALSE

// ENERGY CHAINSAW
/obj/item/chainsaw/energy
	name = "energy chainsaw"
	desc = "Become Leatherspace."
	icon_state = "echainsaw"
	base_icon_state = "echainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	actions_types = list(/datum/action/item_action/startchainsaw)
	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_UNBLOCKABLE
	armour_penetration = 50
	light_color = COLOR_RED
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = TRUE
	active_force = 40
	active_hitsound = 'sound/weapons/energychainsaw_hit1.ogg'

/obj/item/chainsaw/Initialize(mapload)
	. = ..()
	var/datum/component/transforming/transforming = src.GetComponent(/datum/component/transforming)

	transforming.attack_verb_continuous_on = list("saws", "shreds", "rends", "guts", "eviscerates")
	transforming.attack_verb_simple_on = list("saw", "shred", "rend", "gut", "eviscerate")

/obj/item/chainsaw/energy/on_transform(obj/item/source, mob/user, active)
	. = ..()
	set_light(active)

/obj/item/chainsaw/energy/doom
	name = "super energy chainsaw"
	desc = "The chainsaw you want when you need to kill every damn thing in the room."
	w_class = WEIGHT_CLASS_LARGE
	block_power = 75
	canblock = TRUE
	attack_weight = 3
	armour_penetration = 75
	light_range = 6
	active_force = 45

	/// How much time someone is knocked down for when attacking them
	var/knockdown_time = 1 SECONDS

/obj/item/chainsaw/energy/doom/attack(mob/living/target)
	. = ..()
	target.Knockdown(knockdown_time)

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"
