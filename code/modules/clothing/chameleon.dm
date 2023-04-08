#define BROKEN_SUBTYPE(X) ##X/broken/ComponentInitialize(){\
	. = ..();\
	var/datum/component/chameleon/chameleon = GetComponent(/datum/component/chameleon);\
	chameleon.emp_randomize(INFINITY);\
}

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
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
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)

/obj/item/clothing/under/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/jumpsuit)

BROKEN_SUBTYPE(/obj/item/clothing/under/chameleon)

/obj/item/clothing/under/chameleon/envirosuit
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy. It has a small dial on the wrist."
	icon_state = "plasmaman"
	item_state = "plasmaman"
	resistance_flags = FIRE_PROOF
	envirosealed = TRUE
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/chameleon/ratvar
	name = "ratvarian engineer's jumpsuit"
	desc = "A tough jumpsuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	icon_state = "engine"
	item_state = "engi_suit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/chameleon/envirosuit/ratvar
	name = "ratvarian engineer's envirosuit"
	desc = "A tough envirosuit woven from alloy threads. It can take on the appearance of other jumpsuits."
	icon_state = "engineer_envirosuit"
	item_state = "engineer_envirosuit"


/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)

/obj/item/clothing/suit/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/suit, on_disguise=CALLBACK(src, PROC_REF(on_disguise)))

/obj/item/clothing/suit/chameleon/proc/on_disguise(datum/component/chameleon/suit/source, old_disguise_path, new_disguise_path)
	if(ispath(new_disguise_path, /obj/item/clothing/suit/toggle))
		verbs |= /obj/item/clothing/suit/chameleon/proc/toggle_suit_style
	else
		verbs -= /obj/item/clothing/suit/chameleon/proc/toggle_suit_style

/obj/item/clothing/suit/chameleon/proc/toggle_suit_style()
	set name = "Toggle Suit Style"
	set category = "Object"
	set src in usr

	if(!can_use(usr))
		return FALSE

	var/datum/component/chameleon/chameleon = GetComponent(/datum/component/chameleon)
	if(!chameleon || !chameleon.current_disguise || !ispath(chameleon.current_disguise, /obj/item/clothing/suit/toggle))
		return FALSE
	var/obj/item/clothing/suit/toggle/toggle_suit = chameleon.current_disguise
	to_chat(usr, "<span class='notice'>You toggle [src]'s [initial(toggle_suit.togglename)].</span>")
	if(suittoggled)
		icon_state = "[initial(toggle_suit.icon_state)]"
		if(worn_icon_state)
			worn_icon_state = "[initial(toggle_suit.icon_state)]"
		suittoggled = FALSE
	else
		icon_state = "[initial(toggle_suit.icon_state)]_t"
		if(worn_icon_state)
			worn_icon_state = "[initial(toggle_suit.icon_state)]_t"
		suittoggled = TRUE
	usr.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

BROKEN_SUBTYPE(/obj/item/clothing/suit/chameleon)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	resistance_flags = NONE
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)

/obj/item/clothing/glasses/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/glasses)

BROKEN_SUBTYPE(/obj/item/clothing/glasses/chameleon)

/obj/item/clothing/glasses/chameleon/flashproof
	name = "welding goggles"
	desc = "Protects the eyes from welders; approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	flash_protect = 3

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	worn_icon_state = "ygloves"

	resistance_flags = NONE
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)

/obj/item/clothing/gloves/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/gloves)

BROKEN_SUBTYPE(/obj/item/clothing/gloves/chameleon)

/obj/item/clothing/gloves/chameleon/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "cgloves"
	item_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	clothing_flags = SNUG_FIT
	icon_state = "greysoft"

	resistance_flags = NONE
	armor = list(MELEE = 5,  BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)


/obj/item/clothing/head/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/hat)

BROKEN_SUBTYPE(/obj/item/clothing/head/chameleon)

/obj/item/clothing/head/chameleon/envirohelm
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon_state = "plasmaman-helm"
	item_state = "plasmaman-helm"
	resistance_flags = FIRE_PROOF
	strip_delay = 80
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
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
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	flash_protect = 1

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	clothing_flags = SNUG_FIT
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	// which means it offers no protection, it's just air and light

/*/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()*/

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	item_state = "gas_alt"
	resistance_flags = NONE
	armor = list(MELEE = 5,  BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	var/vchange = 1

/obj/item/clothing/mask/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/mask)

BROKEN_SUBTYPE(/obj/item/clothing/mask/chameleon)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	vchange = !vchange
	to_chat(user, "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>")

/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	// Can drones use the voice changer part? Let's not find out.
	vchange = 0

/*
/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.UpdateButtonIcon()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.UpdateButtonIcon()
*/

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, "<span class='notice'>[src] does not have a voice changer.</span>")

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	desc = "A pair of black shoes."
	permeability_coefficient = 0.05
	resistance_flags = NONE
	armor = list(MELEE = 10,  BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 10)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/shoes)

/obj/item/clothing/shoes/chameleon/noslip
	clothing_flags = NOSLIP
	can_be_bloody = FALSE

BROKEN_SUBTYPE(/obj/item/clothing/shoes/chameleon)
BROKEN_SUBTYPE(/obj/item/clothing/shoes/chameleon/noslip)

/obj/item/storage/backpack/chameleon
	name = "backpack"

/obj/item/storage/backpack/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/backpack)

BROKEN_SUBTYPE(/obj/item/storage/backpack/chameleon)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."

/obj/item/storage/belt/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/belt)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

BROKEN_SUBTYPE(/obj/item/storage/belt/chameleon)

/obj/item/radio/headset/chameleon
	name = "radio headset"

/obj/item/radio/headset/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/headset)

BROKEN_SUBTYPE(/obj/item/radio/headset/chameleon)

/obj/item/radio/headset/chameleon/bowman
	name = "bowman headset"
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	bang_protect = 3

/obj/item/modular_computer/tablet/pda/chameleon
	name = "tablet"

/obj/item/modular_computer/tablet/pda/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/pda)

BROKEN_SUBTYPE(/obj/item/modular_computer/tablet/pda/chameleon)

/obj/item/stamp/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/stamp)

BROKEN_SUBTYPE(/obj/item/stamp/chameleon)

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "blacktie"
	resistance_flags = NONE
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 0)

/obj/item/clothing/neck/chameleon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/chameleon/neck)

BROKEN_SUBTYPE(/obj/item/clothing/neck/chameleon)

#undef BROKEN_SUBTYPE
