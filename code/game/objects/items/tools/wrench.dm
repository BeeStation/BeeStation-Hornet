/obj/item/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	inhand_icon_state = "wrench"
	worn_icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	custom_materials = list(/datum/material/iron=150)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "whack")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor_type = /datum/armor/item_wrench

/obj/item/wrench/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/datum/armor/item_wrench
	fire = 50
	acid = 30

/obj/item/wrench/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "A brass wrench. It's faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "wrench_brass"
	toolspeed = 0.5

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A medical wrench with common(medical?) uses. Can be found in your hand."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	attack_verb_continuous = list("heals", "medicals", "taps", "pokes", "analyzes") //"cobbyed"
	attack_verb_simple = list("heal", "medical", "tap", "poke", "analyze")
	custom_price = 25 //useless fucking shit items that only serve to suicide
	///var to hold the name of the person who suicided
	var/suicider

/obj/item/wrench/medical/examine(mob/user)
	. = ..()
	if(suicider)
		. += span_notice("For some reason, it reminds you of [suicider].")

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!"))
	// TODO Make them glow with the power of the M E D I C A L W R E N C H
	// during their ascension

	// Stun stops them from wandering off
	user.Stun(100, ignore_canstun = TRUE)
	playsound(loc, 'sound/effects/pray.ogg', 50, 1, -1)

	// Let the sound effect finish playing
	add_fingerprint(user)
	sleep(20)
	if(!user)
		return
	for(var/obj/item/W in user)
		user.dropItemToGround(W)
	suicider = user.real_name
	user.dust()
	return OXYLOSS

/obj/item/wrench/cyborg
	name = "hydraulic wrench"
	desc = "An advanced robotic wrench, powered by internal hydraulics. Twice as fast as the handheld version."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wrench_cyborg"
	toolspeed = 0.5
