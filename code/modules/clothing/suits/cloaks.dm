//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "brown cloak"
	desc = "It's a cape that can be worn around your neck."
	icon = 'icons/obj/clothing/cloaks.dmi'
	icon_state = "qmcloak"
	inhand_icon_state = "qmcloak"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cloak/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/exo/cloak)

/obj/item/clothing/neck/cloak/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/clothing/neck/cloak/hos
	name = "head of security's cloak"
	desc = "Worn by Securistan, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/qm
	name = "quartermaster's cloak"
	desc = "Worn by Cargonia, supplying the station with the necessary tools for survival."

/obj/item/clothing/neck/cloak/cmo
	name = "chief medical officer's cloak"
	desc = "Worn by Meditopia, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/ce
	name = "chief engineer's cloak"
	desc = "Worn by Engitopia, wielders of an unlimited power."
	icon_state = "cecloak"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/cloak/rd
	name = "research director's cloak"
	desc = "Worn by Sciencia, thaumaturges and researchers of the universe."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/cap
	name = "captain's cloak"
	desc = "Worn by the commander of Space Station 13."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/hop
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/suit/hooded/cloak
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/head/hooded/cloakhood
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'

/obj/item/clothing/suit/hooded/cloak/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/spear/bonespear, /obj/item/organ/regenerative_core/legion, /obj/item/knife/combat/bone, /obj/item/knife/combat/survival)
	armor_type = /datum/armor/cloak_goliath
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath
	body_parts_covered = CHEST|GROIN|ARMS
	resistance_flags = FIRE_PROOF


/datum/armor/cloak_goliath
	melee = 50
	bullet = 10
	laser = 25
	energy = 10
	bomb = 25
	fire = 60
	acid = 60
	stamina = 30
	bleed = 20

/obj/item/clothing/head/hooded/cloakhood/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	desc = "A protective & concealing hood."
	armor_type = /datum/armor/cloakhood_goliath
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK
	resistance_flags = FIRE_PROOF


/datum/armor/cloakhood_goliath
	melee = 50
	bullet = 10
	laser = 25
	energy = 10
	bomb = 25
	fire = 60
	acid = 60
	stamina = 30
	bleed = 30

/obj/item/clothing/suit/hooded/cloak/drake
	name = "drake armour"
	icon_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor_type = /datum/armor/cloak_drake
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES
	high_pressure_multiplier = 0.4
	custom_price = 10000
	max_demand = 10


/datum/armor/cloak_drake
	melee = 70
	bullet = 30
	laser = 50
	energy = 40
	bomb = 70
	bio = 60
	fire = 100
	acid = 100
	stamina = 30
	bleed = 50

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "drake helm"
	icon_state = "dragon"
	desc = "The skull of a dragon."
	armor_type = /datum/armor/cloakhood_drake
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	high_pressure_multiplier = 0.4


/datum/armor/cloakhood_drake
	melee = 70
	bullet = 30
	laser = 50
	energy = 40
	bomb = 70
	bio = 60
	fire = 100
	acid = 100
	stamina = 30
	bleed = 50

/obj/item/clothing/suit/hooded/cloak/bone
	name = "Heavy bone armor"
	icon_state = "hbonearmor"
	desc = "A tribal armor plate, crafted from animal bone. A heavier variation of standard bone armor."
	armor_type = /datum/armor/cloak_bone
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/bone
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	resistance_flags = NONE
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES


/datum/armor/cloak_bone
	melee = 40
	bullet = 25
	laser = 30
	energy = 30
	bomb = 30
	fire = 50
	acid = 50
	stamina = 20
	bleed = 70

/obj/item/clothing/head/hooded/cloakhood/bone
	name = "bone helmet"
	icon_state = "hskull"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	armor_type = /datum/armor/cloakhood_bone
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	resistance_flags = NONE
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES


/datum/armor/cloakhood_bone
	melee = 35
	bullet = 25
	laser = 25
	energy = 10
	bomb = 25
	fire = 50
	acid = 50
	stamina = 20
	bleed = 50

/obj/item/clothing/neck/cloak/chap/bishop
	name = "bishop's cloak"
	desc = "Become the space pope."
	icon_state = "bishopcloak"

/obj/item/clothing/neck/cloak/chap/bishop/black
	name = "black bishop's cloak"
	icon_state = "blackbishopcloak"

/obj/item/clothing/neck/cloak/fakehalo //I made it a cloak so you can wear spooky hats, also because the hat version kept removing hair and I'm lazy.
	name = "toy halo"
	desc = "A cheap plastic replica of a cult halo. Produced by THE ARM Toys, Inc.\nDisclaimer - This item may get you prematurely lynched by trigger happy security, wear at your own risk."
	icon = 'icons/obj/cult.dmi'
	icon_state = "fakehalo"

/obj/item/clothing/neck/cloak/fakehalo/mob_can_equip(mob/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped)
	if(iscarbon(M))
		var/mob/living/carbon/carbon_wearer = M
		if(carbon_wearer.overlays_standing[HALO_LAYER])
			to_chat(carbon_wearer, span_warning("You already have a halo!"))
			return FALSE
	return ..()

/obj/item/clothing/neck/cloak/fakehalo/equipped(mob/user, slot, initial = FALSE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(slot == ITEM_SLOT_NECK)
			if(carbon_user.overlays_standing[HALO_LAYER])
				to_chat(carbon_user, span_warning("You already have a halo!"))
				return
			carbon_user.overlays_standing[HALO_LAYER] = mutable_appearance('icons/effects/32x64.dmi', "halo_static", CALCULATE_MOB_OVERLAY_LAYER(HALO_LAYER))
			carbon_user.apply_overlay(HALO_LAYER)
	return ..()

/obj/item/clothing/neck/cloak/fakehalo/dropped(mob/user, silent = FALSE)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		var/datum/antagonist/cult/cultist = IS_CULTIST(carbon_user)
		if(!cultist?.cult_team?.cult_ascendent && carbon_user.overlays_standing[HALO_LAYER])
			carbon_user.remove_overlay(HALO_LAYER)
