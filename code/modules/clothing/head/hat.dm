/obj/item/clothing/head/hats
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'

/obj/item/clothing/head/hats/centhat
	name = "\improper CentCom hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "that"
	flags_inv = NONE
	armor_type = /datum/armor/hats_centhat
	strip_delay = 80
	clothing_flags = SNUG_FIT // prevents bypassing the strip delay


/datum/armor/hats_centhat
	melee = 30
	bullet = 15
	laser = 30
	energy = 10
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30

/obj/item/clothing/head/hats/centcom_cap
	name = "\improper CentCom commander cap"
	icon_state = "centcom_cap"
	desc = "Worn by the finest of CentCom commanders. Inside the lining of the cap, lies two faint initials."
	item_state = "that"
	flags_inv = 0
	armor_type = /datum/armor/hats_centcom_cap
	strip_delay = (8 SECONDS)


/datum/armor/hats_centcom_cap
	melee = 30
	bullet = 15
	laser = 30
	energy = 10
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30

/obj/item/clothing/head/costume/canada
	name = "striped red tophat"
	desc = "It smells like fresh donut holes. / <i>Il sent comme des trous de beignets frais.</i>"
	icon_state = "canada"
	item_state = null

/obj/item/clothing/head/costume/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/costume/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

/obj/item/clothing/head/costume/plague
	name = "plague doctor's hat"
	desc = "These were once used by plague doctors. They're pretty much useless."
	item_state = "that"
	icon_state = "plaguedoctor"
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT
	armor_type = /datum/armor/costume_plague
	flags_inv = HIDEHAIR


/datum/armor/costume_plague
	bio = 100

/obj/item/clothing/head/costume/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	dynamic_hair_suffix = ""
	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/hats/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = null
	dynamic_hair_suffix = ""

/obj/item/clothing/head/costume/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "beret_flat"
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state_preview = "beret_flat"
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#8F7654"
	item_state = null

/obj/item/clothing/head/costume/santa
	name = "santa hat"
	desc = "On the first day of christmas my employer gave to me!"
	icon_state = "santahatnorm"
	item_state = "that"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/head/costume/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merriness to the suit."
	icon_state = "jester_hat"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/costume/jester/alt
	icon_state = "jester2"

/obj/item/clothing/head/costume/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"

/obj/item/clothing/head/costume/lizard
	name = "lizardskin cloche hat"
	desc = "How many lizards died to make this hat? Not enough."
	icon_state = "lizard"

/obj/item/clothing/head/costume/scarecrow_hat
	name = "scarecrow hat"
	desc = "A simple straw hat."
	icon_state = "scarecrow_hat"

/obj/item/clothing/head/costume/pharaoh
	name = "pharaoh hat"
	desc = "Walk like an Egyptian."
	icon_state = "pharoah_hat"
	icon_state = "pharoah_hat"

/obj/item/clothing/head/costume/nemes
	name = "headdress of Nemes"
	desc = "Lavish space tomb not included."
	icon_state = "nemes_headdress"
	icon_state = "nemes_headdress"

/obj/item/clothing/head/costume/delinquent
	name = "delinquent hat"
	desc = "Good grief."
	icon_state = "delinquent"

/obj/item/clothing/head/hats/intern
	name = "\improper CentCom Head Intern beancap"
	desc = "A horrifying mix of beanie and softcap in CentCom green. You'd have to be pretty desperate for power over your peers to agree to wear this."
	icon_state = "intern_hat"
	item_state = null

/obj/item/clothing/head/costume/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = null
	flags_inv = HIDEEARS|HIDEHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/ushanka
	//Are the flaps down?
	var/earflaps_down = TRUE

/obj/item/clothing/head/costume/ushanka/attack_self(mob/user)
	if(earflaps_down)
		icon_state = "ushankaup"
		item_state = "ushankaup"
		earflaps_down = FALSE
		to_chat(user, span_notice("You raise the ear flaps on the ushanka."))
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		earflaps_down = TRUE
		to_chat(user, span_notice("You lower the ear flaps on the ushanka."))
