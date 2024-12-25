/****************Explorer's Suit and Mask****************/
/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	item_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor_type = /datum/armor/hooded_explorer
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/pickaxe
	)
	resistance_flags = FIRE_PROOF
	high_pressure_multiplier = 0.4
	flags_inv = HIDEJUMPSUIT


/datum/armor/hooded_explorer
	melee = 30
	bullet = 20
	laser = 20
	energy = 20
	bomb = 50
	rad = 50
	fire = 50
	acid = 50
	stamina = 20
	bleed = 30

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "explorer"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hooded_explorer
	resistance_flags = FIRE_PROOF
	high_pressure_multiplier = 0.4


/datum/armor/hooded_explorer
	melee = 30
	bullet = 20
	laser = 20
	energy = 20
	bomb = 50
	rad = 50
	fire = 50
	acid = 50
	stamina = 20
	bleed = 30

/obj/item/clothing/suit/hooded/explorer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/explorer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	item_state = "explorer_gasmask"
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	actions_types = list(/datum/action/item_action/adjust)
	armor_type = /datum/armor/gas_explorer
	resistance_flags = FIRE_PROOF


/datum/armor/gas_explorer
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	bio = 50
	fire = 20
	acid = 40
	stamina = 10
	bleed = 10

/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/explorer/adjustmask(user)
	..()
	w_class = mask_adjusted ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL

/obj/item/clothing/mask/gas/explorer/folded/Initialize(mapload)
	. = ..()
	adjustmask()

/obj/item/clothing/suit/space/hostile_environment
	name = "H.E.C.K. suit"
	desc = "Hostile Environment Cross-Kinetic Suit: A suit designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "hostile_env"
	item_state = "hostile_env"
	clothing_flags = THICKMATERIAL //not spaceproof
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	slowdown = 0
	armor_type = /datum/armor/space_hostile_environment
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator, /obj/item/pickaxe)
	high_pressure_multiplier = 0.6


/datum/armor/space_hostile_environment
	melee = 70
	bullet = 40
	laser = 20
	energy = 20
	bomb = 50
	rad = 100
	fire = 100
	acid = 100
	stamina = 40
	bleed = 50

/obj/item/clothing/suit/space/hostile_environment/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)

/obj/item/clothing/suit/space/hostile_environment/process(delta_time)
	. = ..()
	var/mob/living/carbon/C = loc
	if(istype(C) && DT_PROB(1, delta_time)) //cursed by bubblegum
		if(DT_PROB(7.5, delta_time))
			new /datum/hallucination/oh_yeah(C)
			to_chat(C, "<span class='colossus'><b>[pick("I AM IMMORTAL.","I SHALL TAKE BACK WHAT'S MINE.","I SEE YOU.","YOU CANNOT ESCAPE ME FOREVER.","DEATH CANNOT HOLD ME.")]</b></span>")
		else
			to_chat(C, "<span class='warning'>[pick("You hear faint whispers.","You smell ash.","You feel hot.","You hear a roar in the distance.")]</span>")

/obj/item/clothing/head/helmet/space/hostile_environment
	name = "H.E.C.K. helmet"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	desc = "Hostile Environiment Cross-Kinetic Helmet: A helmet designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon_state = "hostile_env"
	item_state = "hostile_env"
	w_class = WEIGHT_CLASS_NORMAL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_flags = THICKMATERIAL // no space protection
	armor_type = /datum/armor/space_hostile_environment
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	high_pressure_multiplier = 0.6


/datum/armor/space_hostile_environment
	melee = 70
	bullet = 40
	laser = 20
	energy = 20
	bomb = 50
	rad = 100
	fire = 100
	acid = 100
	stamina = 40
	bleed = 50

/obj/item/clothing/head/helmet/space/hostile_environment/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	update_icon()

/obj/item/clothing/head/helmet/space/hostile_environment/update_icon()
	..()
	cut_overlays()
	var/mutable_appearance/glass_overlay = mutable_appearance(icon, "hostile_env_glass")
	glass_overlay.appearance_flags = RESET_COLOR
	add_overlay(glass_overlay)

/obj/item/clothing/head/helmet/space/hostile_environment/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/M = mutable_appearance('icons/mob/clothing/head/helmet.dmi', "hostile_env_glass", item_layer)
		M.appearance_flags = RESET_COLOR
		. += M
