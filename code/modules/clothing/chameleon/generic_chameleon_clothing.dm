/// Makes an item broken. Adds EMP protection to prevent being unbroken
#define BREAK_CHAMELEON_ACTION(item) \
do { \
	var/datum/action/item_action/chameleon/change/_action = locate() in item.actions; \
	_action?.emp_randomise(INFINITY); \
	item.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF); \
} while(FALSE)

/obj/item/clothing/under/chameleon
	name = "black jumpsuit"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor_type = /datum/armor/under_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/jumpsuit)

/datum/armor/under_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/under/chameleon/broken

/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/under/chameleon/envirosuit
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy. It has a small dial on the wrist."
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	resistance_flags = FIRE_PROOF
	envirosealed = TRUE
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/chameleon/envirosuit/ratvar
	name = "ratvarian engineer's envirosuit"
	desc = "A tough envirosuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	inhand_icon_state = "engineer_envirosuit"

/obj/item/clothing/under/chameleon/ratvar
	name = "ratvarian engineer's jumpsuit"
	desc = "A tough jumpsuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	inhand_icon_state = "engi_suit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor_type = /datum/armor/suit_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/suit)

/datum/armor/suit_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed //should at least act like a vest

/obj/item/clothing/suit/chameleon/broken

/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	armor_type = /datum/armor/glasses_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/glasses)

/datum/armor/glasses_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/glasses/chameleon/broken

/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/glasses/chameleon/flashproof
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	inhand_icon_state = "welding-g"
	flash_protect = 3
	actions_types = list(/datum/action/item_action/chameleon/change/glasses)

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	worn_icon_state = "ygloves"
	resistance_flags = NONE
	armor_type = /datum/armor/gloves_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/gloves)

/datum/armor/gloves_chameleon
	melee = 10
	bullet = 10
	laser = 10
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/gloves/chameleon/broken

/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/gloves/chameleon/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "cgloves"
	inhand_icon_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	armor_type = /datum/armor/chameleon_combat

/datum/armor/chameleon_combat
	melee = 10
	bullet = 10
	laser = 10
	bio = 50
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	clothing_flags = SNUG_FIT
	icon_state = "greysoft"
	resistance_flags = NONE
	armor_type = /datum/armor/head_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/hat)

/datum/armor/head_chameleon
	melee = 5
	bullet = 5
	laser = 5
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/chameleon/broken

/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/head/chameleon/envirohelm
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	inhand_icon_state = "mime_envirohelm"
	resistance_flags = FIRE_PROOF
	strip_delay = 80
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	bang_protect = 1
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/chameleon/envirohelm/ratvar
	name = "ratvarian engineer's envirosuit helmet"
	desc = "A tough envirohelm woven from alloy threads. It can take on the appearance of other headgear."
	//icon_state = "engineer_envirohelm"
	inhand_icon_state = "engineer_envirohelm"
	flash_protect = FLASH_PROTECTION_FLASH

/obj/item/clothing/head/chameleon/drone
	clothing_flags = SNUG_FIT // The camohat, I mean, holographic hat projection, is part of the drone itself.
	armor_type = /datum/armor/none // which means it offers no protection, it's just air and light
	actions_types = list(
		/datum/action/item_action/chameleon/change/hat,
		/datum/action/item_action/chameleon/drone/togglehatmask,
		/datum/action/item_action/chameleon/drone/randomise,
	)

/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	var/datum/action/item_action/chameleon/change/hat/hat = locate() in actions
	hat?.random_look()

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	armor_type = /datum/armor/mask_chameleon
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	gas_transfer_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	actions_types = list(
		/datum/action/item_action/chameleon/change/mask,
		/datum/action/item_action/chameleon/tongue_change,
	)

/datum/armor/mask_chameleon
	melee = 5
	bullet = 5
	laser = 5
	bio = 100
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	var/on = (TRAIT_VOICE_MATCHES_ID in clothing_traits)
	if(on)
		detach_clothing_traits(TRAIT_VOICE_MATCHES_ID)
	else
		attach_clothing_traits(TRAIT_VOICE_MATCHES_ID)
	on = !on
	to_chat(user, span_notice("The voice changer is now [on ? "on" : "off"]!"))

/obj/item/clothing/mask/chameleon/broken

/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/mask/chameleon/drone
	actions_types = list(
		/datum/action/item_action/chameleon/change/mask,
		/datum/action/item_action/chameleon/drone/togglehatmask,
		/datum/action/item_action/chameleon/drone/randomise,
	)
	item_flags = DROPDEL
	//Same as the drone chameleon hat, undroppable and no protection
	armor_type = /datum/armor/none
	clothing_traits = null

/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	var/datum/action/item_action/chameleon/change/mask/mask = locate() in actions
	mask?.random_look()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, span_notice("[src] does not have a voice changer."))

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	desc = "A pair of black shoes."
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/shoes)

/datum/armor/shoes_chameleon
	melee = 10
	bullet = 10
	laser = 10
	bio = 90
	fire = 50
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/shoes/chameleon/broken

/obj/item/clothing/shoes/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/shoes/chameleon/noslip
	clothing_flags = NOSLIP | NOSLIP_ALL_WALKING
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	actions_types = list(/datum/action/item_action/chameleon/change/backpack)

/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	actions_types = list(/datum/action/item_action/chameleon/change/belt)

/obj/item/storage/belt/chameleon/Initialize(mapload)
	. = ..()
	atom_storage.silent = TRUE

/obj/item/storage/belt/chameleon/broken

/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/radio/headset/chameleon
	name = "radio headset"
	actions_types = list(/datum/action/item_action/chameleon/change/headset)

/obj/item/radio/headset/chameleon/broken

/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/radio/headset/chameleon/bowman
	name = "bowman headset"
	icon_state = "syndie_headset"
	inhand_icon_state = "syndie_headset"
	bang_protect = 3

/obj/item/modular_computer/tablet/pda/preset/chameleon
	name = "PDA"
	actions_types = list(/datum/action/item_action/chameleon/change/pda)

/obj/item/modular_computer/tablet/pda/preset/chameleon/broken

/obj/item/modular_computer/tablet/pda/preset/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/stamp/chameleon
	icon_state = "stamp-syndicate"
	actions_types = list(/datum/action/item_action/chameleon/change/stamp)

/obj/item/stamp/chameleon/broken

/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "blacktie"
	resistance_flags = NONE
	armor_type = /datum/armor/neck_chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/neck)

/datum/armor/neck_chameleon
	fire = 50
	acid = 50

/obj/item/clothing/neck/chameleon/broken

/obj/item/clothing/neck/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)

