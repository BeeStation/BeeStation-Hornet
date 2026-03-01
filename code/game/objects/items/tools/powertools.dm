/obj/item/powertool
	name = "Power tool"
	desc = "A basic powertool that does nothing."
	icon = 'icons/obj/tools.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25) //done for balance reasons, making them high value for research, but harder to get
	armor_type = /datum/armor/item_powertool
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	toolspeed = 0.7
	//Forgot to set your tool?
	var/tool_act_off = TOOL_BIKEHORN
	var/tool_act_on = TOOL_BIKEHORN
	var/action_off = "honk1"
	var/action_on = "honk2"
	var/powertool_hitsound = 'sound/vox_fem/honk.ogg'
	custom_price = 50


/datum/armor/item_powertool
	fire = 50
	acid = 30

/obj/item/powertool/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	tool_behaviour = tool_act_off

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between crowbar and wirecutters and gives feedback to the user.
 */
/obj/item/powertool/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? tool_act_on : tool_act_off)
	if(user)
		balloon_alert(user, "attached [active ? "[action_off]" : "[action_on]"]")
	playsound(user ? user : src, 'sound/items/change_jaws.ogg', 50, TRUE)
	hitsound = powertool_hitsound
	return COMPONENT_NO_DEFAULT_MESSAGE

//Hand Drill

/obj/item/powertool/hand_drill
	name = "hand drill"
	desc = "A simple powered hand drill. It's fitted with a screw bit."
	icon_state = "drill"
	inhand_icon_state = "drill"
	worn_icon_state = "drill"

	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb_continuous = list("drills", "screws", "jabs", "whacks")
	attack_verb_simple = list("drill", "screw", "jab", "whack")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'

	tool_act_off = TOOL_SCREWDRIVER
	tool_act_on = TOOL_WRENCH
	action_off = "bolt driver"
	action_on = "screw driver"

/obj/item/powertool/hand_drill/suicide_act(mob/living/user)
	if(tool_behaviour == TOOL_SCREWDRIVER)
		user.visible_message(span_suicide("[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is pressing [src] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

//Jaws of life

/obj/item/powertool/jaws_of_life
	name = "jaws of life"
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
	usesound = 'sound/items/jaws_pry.ogg'
	icon_state = "jaws"
	inhand_icon_state = "jawsoflife"
	worn_icon_state = "jawsoflife"

	force = 15
	throwforce = 7
	attack_verb_continuous = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("attack", "bash", "batter", "bludgeon", "whack")

	tool_act_off = TOOL_CROWBAR
	tool_act_on = TOOL_WIRECUTTER
	action_on = "prying jaws"
	action_off = "cutting jaws"

/obj/item/powertool/jaws_of_life/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, TRAIT_JAWS_OF_LIFE)

/obj/item/powertool/jaws_of_life/suicide_act(mob/living/user)
	if(tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_suicide("[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	else
		user.visible_message(span_suicide("[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!"))
		playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
			if(BP)
				BP.drop_limb()
				playsound(loc,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, 1, -1)
	return BRUTELOSS

/obj/item/powertool/jaws_of_life/attack(mob/living/carbon/C, mob/living/user)
	if(tool_behaviour == TOOL_WIRECUTTER && istype(C) && C.handcuffed)
		user.visible_message(span_notice("[user] cuts [C]'s restraints with [src]!"))
		log_combat(user, C, "cut handcuffs from", important = FALSE)
		qdel(C.handcuffed)
		return
	else
		..()
