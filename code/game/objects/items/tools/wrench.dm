/obj/item/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	block_upgrade_walk = 1
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	materials = list(/datum/material/iron=150)

	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0)

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

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
	attack_verb = list("healed", "medicaled", "tapped", "poked", "analyzed") //"cobbyed"
	///var to hold the name of the person who suicided
	var/suicider

/obj/item/wrench/medical/examine(mob/user)
	. = ..()
	if(suicider)
		. += "<span class='notice'>For some reason, it reminds you of [suicider].</span>"

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!</span>")
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
