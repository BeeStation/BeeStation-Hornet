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
	custom_materials = list(/datum/material/iron=50)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'

	attack_verb_continuous = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("attack", "bash", "batter", "bludgeon", "whack")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor_type = /datum/armor/item_crowbar
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'

/obj/item/crowbar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/datum/armor/item_crowbar
	fire = 50
	acid = 30

/obj/item/crowbar/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "crowbar_brass"
	worn_icon_state = "crowbar"
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
	custom_materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	worn_icon_state = "crowbar"
	toolspeed = 0.7

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, simple but powerful."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5
