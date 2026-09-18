//THE DRIP

/obj/item/clothing/suit/hooded/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/hooded_cultrobes
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie

/obj/item/clothing/suit/hooded/cultrobes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/datum/armor/hooded_cultrobes
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/head/hooded/cult_hoodie
	name = "ancient cultist hood"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/hooded_cult_hoodie
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT


/datum/armor/hooded_cult_hoodie
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/head/hooded/cult_hoodie/alt
	name = "cultist hood"
	desc = "An armored hood worn by the followers of Nar'Sie."
	icon_state = "cult_hoodalt"
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/cultrobes/alt
	name = "cultist robes"
	desc = "An armored set of robes worn by the followers of Nar'Sie."
	icon_state = "cultrobesalt"
	inhand_icon_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/alt

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/head/wizard/magus
	name = "magus helm"
	icon_state = "magus"
	inhand_icon_state = null
	desc = "A helm worn by the followers of Nar'Sie."
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor_type = /datum/armor/wizard_magus
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH


/datum/armor/wizard_magus
	melee = 50
	bullet = 30
	laser = 50
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 50
	bleed = 50

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar'Sie."
	icon_state = "magusred"
	icon = 'icons/obj/clothing/suits/wizard.dmi'
	worn_icon = 'icons/mob/clothing/suits/wizard.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/suit_magusred
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/datum/armor/suit_magusred
	melee = 50
	bullet = 30
	laser = 50
	energy = 20
	bomb = 25
	bio = 10
	fire = 10
	acid = 10
	stamina = 50
	bleed = 20

/obj/item/sharpener/cult
	name = "eldritch whetstone"
	desc = "A block, empowered by dark magic. Sharp weapons will be enhanced when used on the stone."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cult_sharpener"
	used = 0
	increment = 5
	max = 30
	prefix = "darkened"

/obj/item/sharpener/cult/update_icon()
	icon_state = "cult_sharpener[used ? "_used" : ""]"

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "A set of runed armour scribbed with blood rites which shimmer in the light, reflecting projectiles."
	icon_state = "cult_armor"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/cultrobes_cult_shield
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	/// if anyone can equip this. used by the prefs menu
	var/allow_any = FALSE


/datum/armor/cultrobes_cult_shield
	melee = 40
	bullet = 30
	laser = 40
	energy = 30
	bomb = 50
	bio = 30
	fire = 50
	acid = 60
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/anyone
	allow_any = TRUE

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/Initialize(mapload)
	. = ..()
	// note that these charges don't regenerate
	AddComponent(/datum/component/shielded, \
		max_integrity = 100, \
		charge_recovery = 0 SECONDS, \
		shield_icon_file = 'icons/effects/cult_effects.dmi', \
		shield_icon = "shield-cult", \
		shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES, \
		shield_alpha = 120, \
		run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)) \
		)

/// A proc for callback when the shield breaks, since cult robes are stupid and have different effects
/obj/item/clothing/suit/hooded/cultrobes/cult_shield/proc/shield_damaged(mob/living/wearer, attack_text, current_integrity)
	wearer.visible_message(span_danger("[wearer]'s robes neutralize [attack_text] in a burst of blood-red sparks!"))
	new /obj/effect/temp_visual/cult/sparks(get_turf(wearer))
	if(current_integrity == 0)
		wearer.visible_message(span_danger("The runed shield around [wearer] suddenly disappears!"))

/obj/item/clothing/head/hooded/cult_hoodie/cult_shield
	name = "empowered cultist helmet"
	desc = "A runed helmet scribbed with blood rites which shimmer in the light, reflecting projectiles."
	icon_state = "cult_hoodalt"
	armor_type = /datum/armor/cult_hoodie_cult_shield


/datum/armor/cult_hoodie_cult_shield
	melee = 40
	bullet = 30
	laser = 40
	energy = 30
	bomb = 50
	bio = 100
	fire = 50
	acid = 60
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user) && !allow_any)
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of reduced protection."
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor_type = /datum/armor/cultrobes_berserker
	slowdown = -0.4
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/berserkerhood


/datum/armor/cultrobes_berserker
	melee = 10
	bullet = 20
	laser = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/head/hooded/cult_hoodie/berserkerhood
	name = "flagellant's hood"
	desc = "Blood-soaked hood infused with dark magic."
	armor_type = /datum/armor/cult_hoodie_berserkerhood


/datum/armor/cult_hoodie_berserkerhood
	melee = 10
	bullet = 20
	laser = 10
	stamina = 40
	bleed = 20

/obj/item/clothing/suit/hooded/cultrobes/berserker/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"I wouldn't advise that.\""))
		to_chat(user, span_warning("An overwhelming sense of nausea overpowers you!"))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)

/obj/item/clothing/glasses/hud/health/night/cultblind
	desc = "may Nar'Sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	inhand_icon_state = "blindfold"
	flash_protect = FLASH_PROTECTION_FLASH
	clothing_traits = list(TRAIT_NEARSIGHTED_CORRECTED)

/obj/item/clothing/glasses/hud/health/night/cultblind/equipped(mob/living/user, slot)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"You want to be blind, do you?\""))
		user.dropItemToGround(src, TRUE)
		user.set_dizzy_if_lower(1 MINUTES)
		user.Paralyze(100)
		user.adjust_temp_blindness(60 SECONDS)
