/obj/item/clothing/suit/hooded/hoodie
	name = "white hoodie"
	desc = "A casual hoodie to keep you warm and comfy."
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	icon_state = "hoodie"
	item_state = "hoodie"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/hoodie

/obj/item/clothing/head/hooded/hoodie
	name = "white hoodie hood"
	desc = "A hood attached to your hoodie, simple as."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	icon_state = "hoodie"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/hoodie/blue
	name = "blue hoodie"
	color = "#52aecc"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/blue

/obj/item/clothing/head/hooded/hoodie/blue
	name = "blue hoodie hood"
	color = "#52aecc"

/obj/item/clothing/suit/hooded/hoodie/green
	name = "green hoodie"
	color = "#9ed63a"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/green

/obj/item/clothing/head/hooded/hoodie/green
	name = "green hoodie hood"
	color = "#9ed63a"

/obj/item/clothing/suit/hooded/hoodie/orange
	name = "orange hoodie"
	color = "#ff8c19"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/orange

/obj/item/clothing/head/hooded/hoodie/orange
	name = "orange hoodie hood"
	color = "#ff8c19"

/obj/item/clothing/suit/hooded/hoodie/pink
	name = "pink hoodie"
	desc = "<i>fabulous</i> feels."
	color = "#ffa69b"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/pink

/obj/item/clothing/head/hooded/hoodie/pink
	name = "pink hoodie hood"
	color = "#ffa69b"

/obj/item/clothing/suit/hooded/hoodie/red
	name = "red hoodie"
	color = "#c42822"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/red

/obj/item/clothing/head/hooded/hoodie/red
	name = "red hoodie hood"
	color = "#c42822"

/obj/item/clothing/suit/hooded/hoodie/black
	name = "black hoodie"
	color = "#2e2e2e"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/black

/obj/item/clothing/head/hooded/hoodie/black
	name = "black hoodie hood"
	color = "#2e2e2e"

/obj/item/clothing/suit/hooded/hoodie/yellow
	name = "yellow hoodie"
	color = "#ffe14d"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/yellow

/obj/item/clothing/head/hooded/hoodie/yellow
	name = "yellow hoodie hood"
	color = "#ffe14d"

/obj/item/clothing/suit/hooded/hoodie/darkblue
	name = "dark blue hoodie"
	color = "#3285ba"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/darkblue

/obj/item/clothing/head/hooded/hoodie/darkblue
	name = "dark blue hoodie hood"
	color = "#3285ba"

/obj/item/clothing/suit/hooded/hoodie/teal
	name = "teal hoodie"
	color = "#77f3b7"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/teal

/obj/item/clothing/head/hooded/hoodie/teal
	name = "teal hoodie hood"
	color = "#77f3b7"

/obj/item/clothing/suit/hooded/hoodie/purple
	name = "purple hoodie"
	color = "#73479c"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/purple

/obj/item/clothing/head/hooded/hoodie/purple
	name = "purple hoodie hood"
	color = "#73479c"

/obj/item/clothing/suit/hooded/hoodie/brown
	name = "brown hoodie"
	color = "#a17229"
	hoodtype = /obj/item/clothing/head/hooded/hoodie/brown

/obj/item/clothing/head/hooded/hoodie/brown
	name = "brown hoodie"
	color = "#a17229"

/obj/item/clothing/suit/hooded/hoodie/durathread
	name = "durathread hoodie"
	desc = "A hoodie made from durathread, its resilient fibres provide some protection to the wearer."
	color = "#8291a1"
	armor = list(MELEE = 15, BULLET = 25, LASER = 10, FIRE = 40, ACID = 10, BOMB = 5, STAMINA = 30)
	hoodtype = /obj/item/clothing/head/hooded/hoodie/durathread

/obj/item/clothing/head/hooded/hoodie/durathread
	name = "durathread hoodie hood"
	desc = "A duratread hood attached to your hoodie, robust as."
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, FIRE = 20, ACID = 5, BOMB = 5, STAMINA = 15)
	color = "#8291a1"
