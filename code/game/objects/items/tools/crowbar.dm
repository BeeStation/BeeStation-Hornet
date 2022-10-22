/obj/item/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=50)

	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0)

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "crowbar_brass"
	toolspeed = 0.5

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1


/obj/item/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because it's big."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	item_state = "crowbar"
	toolspeed = 0.7

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, simple but powerful."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5

/obj/item/crowbar/sledgehammer
	name = "sledgehammer"
	desc = "It's a big hammer and crowbar in one tool. It doesn't fit in your pockets, because it's big."
	force = 14
	icon_state = "sledgehammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	throwforce = 15
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 2
	throw_range = 3
	materials = list(/datum/material/iron=140)
	item_state = "sledgehammer"
	toolspeed = 0.7
	sharpness = IS_BLUNT

/obj/item/crowbar/sledgehammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=14, force_wielded=20, block_power_wielded=15, icon_wielded="sledgehammer1")

/obj/item/crowbar/sledgehammer/attack(mob/living/target, mob/living/user)
	. = ..()
	user.changeNext_move(CLICK_CD_SLOW)
	return

/obj/item/crowbar/sledgehammer/attack(mob/living/target, mob/living/user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You hit yourself over the head.</span>")

		user.apply_effect(200,EFFECT_KNOCKDOWN)
		user.SetSleeping(100)

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(1,1*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(1,1*force)
		return
	else
		if((ishuman(target)) && (user.zone_selected == BODY_ZONE_HEAD) && prob(45))
			target.apply_effect(200,EFFECT_KNOCKDOWN)
			target.SetSleeping(100)
		return ..()