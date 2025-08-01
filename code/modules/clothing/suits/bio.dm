//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	desc = "A hood that protects the head and face from biological contaminants."
	icon = 'icons/obj/clothing/head/bio.dmi'
	worn_icon = 'icons/mob/clothing/head/bio.dmi'
	icon_state = "bio"
	item_state = "bio_hood"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT
	armor_type = /datum/armor/head_bio_hood
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	resistance_flags = ACID_PROOF
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH


/datum/armor/head_bio_hood
	bio = 100
	rad = 80
	fire = 30
	acid = 100
	bleed = 5

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon = 'icons/obj/clothing/suits/bio.dmi'
	icon_state = "bio"
	worn_icon = 'icons/mob/clothing/suits/bio.dmi'
	item_state = "bio_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 1
	allowed = list(/obj/item/tank/internals, /obj/item/pen, /obj/item/flashlight/pen, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray)
	armor_type = /datum/armor/suit_bio_suit
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = ACID_PROOF


/datum/armor/suit_bio_suit
	bio = 100
	rad = 80
	fire = 30
	acid = 100
	bleed = 5

/obj/item/clothing/suit/bio_suit/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 75)

//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio"

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio"

//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"

//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	armor_type = /datum/armor/bio_hood_security
	icon_state = "bio_security"


/datum/armor/bio_hood_security
	melee = 25
	bullet = 15
	laser = 25
	energy = 10
	bomb = 25
	bio = 100
	rad = 80
	fire = 30
	acid = 100
	stamina = 20
	bleed = 10

/obj/item/clothing/suit/bio_suit/security
	armor_type = /datum/armor/bio_suit_security
	icon_state = "bio_security"


//Janitor's biosuit, grey with purple arms

/datum/armor/bio_suit_security
	melee = 25
	bullet = 15
	laser = 25
	energy = 10
	bomb = 25
	bio = 100
	rad = 80
	fire = 30
	acid = 100
	stamina = 20
	bleed = 10

/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"
	allowed = list(/obj/item/storage/bag/trash)

//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"


//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	strip_delay = 40
	equip_delay_other = 20
