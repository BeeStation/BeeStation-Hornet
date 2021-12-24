//miscellaneous spacesuits
/*
Contains:
 - Captain's spacesuit
 - SWAT suit
 - Officer's beret/spacesuit
 - NASA Voidsuit
 - Father Christmas' magical clothes
 - Pirate's spacesuit
 - EVA spacesuit
 - Freedom's spacesuit (freedom from vacuum's oppression)
 - Emergency skinsuit
*/

//Death squad armored space suits, not hardsuits!


	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical space suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 20XX for military space operations. A tried and true workhorse, it is very difficult to move in but offers robust protection against all threats!"
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 50, "bio" = 90, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 60)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/head/helmet/space/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers. Uses advanced force field technology to protect the head from space."
	icon_state = "dsberet"
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"
	flags_inv = 0
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/officer
	name = "officer's jacket"
	desc = "An armored, space-proof jacket used in special operations."
	icon_state = "specops"
	item_state = "specops"
	blood_overlay_type = "coat"
	slowdown = 0
	flags_inv = 0
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents


	//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75, "stamina" = 20)
	flags_inv = HIDEHAIR
	strip_delay = 40
	equip_delay_other = 20
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/pirate/bandana
	name = "pirate bandana"
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = 0
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)
	slowdown = 0
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75, "stamina" = 20)
	strip_delay = 40
	equip_delay_other = 20

	//Emergency Response Team suits
/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "space"
	item_state = "eva_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 20, "fire" = 50, "acid" = 65, "stamina" = 0)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "space"
	item_state = "eva_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 20, "fire" = 50, "acid" = 65, "stamina" = 0)

/obj/item/clothing/head/helmet/space/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	armor = list("melee" = 20, "bullet" = 40, "laser" = 30, "energy" = 25, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 10)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF

/obj/item/clothing/suit/space/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit and the wings appear to be stuck in 'freedom' mode."
	icon_state = "freedom"
	item_state = "freedom"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 20, "bullet" = 40, "laser" = 30,"energy" = 25, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 10)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF
	slowdown = 0
/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0, "stamina" = 0)
	strip_delay = 65
	flash_protect = 0

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	slowdown = 2
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0, "stamina" = 0)
	strip_delay = 65
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, "<span class='warning'>[src] tears from the damage, breaking the air-tight seal!</span>")
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]"
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)

/obj/item/clothing/suit/space/hunter
	name = "bounty hunting suit"
	desc = "A custom version of the MK.II SWAT suit, modified to look rugged and tough. Works as a space suit, if you can find a helmet."
	icon_state = "hunter"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, stamina = 70)
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/skinsuit
	name = "skinsuit helmet"
	icon = 'icons/obj/clothing/hats.dmi'
	alternate_worn_icon = 'icons/mob/head.dmi'
	icon_state = "skinsuit_helmet"
	item_state = "skinsuit_helmet"
	max_integrity = 200
	desc = "An airtight helmet meant to protect the wearer during emergency situations."
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 20, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = 0
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = STOPSPRESSUREDAMAGE | SHOWEROKAY | SNUG_FIT
	max_heat_protection_temperature = 100
	actions_types = null

/obj/item/clothing/head/helmet/space/skinsuit/attack_self(mob/user)
	return

/obj/item/clothing/head/helmet/space/skinsuit/emp_act(severity)
	return

/obj/item/clothing/suit/space/skinsuit
	name = "skinsuit"
	desc = "A slim, compression-based spacesuit meant to protect the user during emergency situations. It's only a little warmer than your uniform."
	icon = 'icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'icons/mob/suit.dmi'
	icon_state = "skinsuit"
	item_state = "s_suit"
	max_integrity = 200
	slowdown = 3 //Higher is slower
	clothing_flags = STOPSPRESSUREDAMAGE | SHOWEROKAY
	gas_transfer_coefficient = 0.5
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100

/obj/item/clothing/suit/space/skinsuit/attackby(obj/item/I, mob/user, params)
	return
