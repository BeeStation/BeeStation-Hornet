/obj/item/clothing/suit/jacket
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio
	)
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	inhand_icon_state = "hostrench"
	resistance_flags = NONE
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/gun/ballistic/revolver/detective, /obj/item/radio)

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "leather overcoat"
	desc = "That's a damn fine coat."
	icon_state = "leathercoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/jacket/bomber
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomberjacket"
	inhand_icon_state = "brownjsuit"

/obj/item/clothing/suit/jacket/puffer
	name = "puffer jacket"
	desc = "A thick jacket with a rubbery, water-resistant shell."
	icon_state = "pufferjacket"
	inhand_icon_state = "hostrench"
	armor_type = /datum/armor/jacket_puffer


/datum/armor/jacket_puffer
	bio = 50

/obj/item/clothing/suit/jacket/puffer/vest
	name = "puffer vest"
	desc = "A thick vest with a rubbery, water-resistant shell."
	icon_state = "puffervest"
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN
	armor_type = /datum/armor/puffer_vest


/datum/armor/puffer_vest
	bio = 30

/obj/item/clothing/suit/jacket/miljacket
	name = "military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable."
	icon_state = "militaryjacket"
	inhand_icon_state = null
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/radio)

/obj/item/clothing/suit/jacket/letterman
	name = "letterman jacket"
	desc = "A classic brown letterman jacket. Looks pretty hot and heavy."
	icon_state = "letterman"
	inhand_icon_state = "letterman"

/obj/item/clothing/suit/jacket/letterman_red
	name = "red letterman jacket"
	desc = "A letterman jacket in a sick red color. Radical."
	icon_state = "letterman_red"
	inhand_icon_state = "letterman_red"

/obj/item/clothing/suit/jacket/letterman_syndie
	name = "blood-red letterman jacket"
	desc = "Oddly, this jacket seems to have a large S on the back..."
	icon_state = "letterman_s"
	inhand_icon_state = "letterman_s"

/obj/item/clothing/suit/jacket/letterman_nanotrasen
	name = "blue letterman jacket"
	desc = "A blue letterman jacket with a proud Nanotrasen N on the back. The tag says that it was made in Space China."
	icon_state = "letterman_n"
	inhand_icon_state = "letterman_n"

//Aristocrat coats

/obj/item/clothing/suit/jacket/aristocrat
	name = "orange aristocrat coat"
	desc = "A fancy coat made of silk. This one is orange."
	icon_state = "aristo_orange"
	inhand_icon_state = "aristo_orange"

/obj/item/clothing/suit/jacket/aristocrat/red
	name = "red aristocrat coat"
	desc = "A fancy coat made of silk. This one is red."
	icon_state = "aristo_red"
	inhand_icon_state = "aristo_red"

/obj/item/clothing/suit/jacket/aristocrat/brown
	name = "brown aristocrat coat"
	desc = "A fancy coat made of silk. This one is brown."
	icon_state = "aristo_brown"
	inhand_icon_state = "aristo_brown"

/obj/item/clothing/suit/jacket/aristocrat/blue
	name = "blue aristocrat coat"
	desc = "A fancy coat made of silk. This one is blue."
	icon_state = "aristo_blue"
	inhand_icon_state = "aristo_blue"

// New COOL jackets
/obj/item/clothing/suit/jacket/undergroundserpents //www.youtube.com/watch?v=S0ximxe4XtU&t=61s
	name = "Underground Serpents jacket"
	desc = "Underground Serpents Jacket rules, we are the underground serpents. That's us, and we rule! ."
	icon_state = "userpents_jacket"
	inhand_icon_state = "userpents_jacket"

/obj/item/clothing/suit/jacket/teenbiker
	name = "Teen biker jacket"
	desc = "A red jacket with a pill on its back."
	icon_state = "teenbiker_jacket"
	inhand_icon_state = "teenbiker_jacket"

/obj/item/clothing/suit/jacket/driver
	name = "Driver jacket"
	desc = "A white and black jacket with a golden scorpion on its back. Perfect for driving through the night."
	icon_state = "driver_jacket"
	inhand_icon_state = "driver_jacket"

/obj/item/clothing/suit/jacket/lieutenant
	name = "Lieutenant Vest"
	desc = "A short orange vest that once belonged to a lieutenant."
	icon_state = "lieutenant_jacket"
	inhand_icon_state = "lieutenant_jacket"
