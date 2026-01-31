/obj/item/clothing/suit/costume
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'

/obj/item/clothing/suit/hooded/flashsuit
	name = "flashy costume"
	desc = "What did you expect?"
	icon_state = "flashsuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/flashsuit

/obj/item/clothing/suit/costume/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
		/obj/item/melee/energy/sword/pirate,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/reagent_containers/cup/glass/bottle/rum
		)

/obj/item/clothing/suit/costume/pirate/captain
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/cyborg_suit //unavailable save for adminbus
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	flags_1 = CONDUCT_1
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/costume/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous" //Needs no fixing
	icon_state = "justice"
	inhand_icon_state = "justice"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/costume/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	inhand_icon_state = "judge"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes, /obj/item/stack/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	inhand_icon_state = "overalls"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/apron/purple_bartender
	name = "purple bartender apron"
	desc = "A fancy purple apron for a stylish person."
	icon_state = "purplebartenderapron"
	inhand_icon_state = "purplebartenderapron"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/syndicatefake
	name = "black and red space suit replica"
	icon_state = "syndicate-black-red"
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	inhand_icon_state = "syndicate-black-red"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	desc = "A plastic replica of the Syndicate space suit. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT
	custom_price = 75

/obj/item/clothing/suit/costume/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/hasturhood

/obj/item/clothing/suit/costume/imperium_monk
	name = "\improper Imperium monk suit"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	inhand_icon_state = "imperium_monk"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/cup/glass/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/costume/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	inhand_icon_state = "chickensuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/costume/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	icon_state = "owl_wings"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	toggle_noun = "wings"
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/suit/toggle/owlwings/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	inhand_icon_state = "griffin_wings"

/obj/item/clothing/suit/costume/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	inhand_icon_state = "cardborg"
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/costume/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING)
		disguise(user)

/obj/item/clothing/suit/costume/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/costume/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/costume/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/costume/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.add_overlay(mutable_appearance('icons/mob/robots.dmi', "robot_e")) //gotta look realistic
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "standard_borg_disguise", I) //you look like a robot to robots! (including yourself because you're totally a robot)


/obj/item/clothing/suit/costume/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/costume/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseparable. Literally."
	icon_state = "ponchoshame"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/suit/costume/poncho/ponchoshame/outlaw
	desc = "You broke the rules of the duel, and drew your gun before High Noon. This poncho will rest on your shoulders eternally, just like your shame."
	icon_state = "ponchoshame_alt"
	inhand_icon_state = "ponchoshame_alt"
	armor_type = /datum/armor/ponchoshame_outlaw
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/gun/ballistic/shotgun/lever_action, /obj/item/gun/ballistic/rifle/leveraction, /obj/item/gun/ballistic/revolver)


/datum/armor/ponchoshame_outlaw
	melee = 25
	bullet = 25
	laser = 25
	energy = 20
	bomb = 30
	bio = 30
	acid = 30
	stamina = 35

/obj/item/clothing/suit/costume/whitedress
	name = "white dress"
	desc = "A fancy white dress."
	icon_state = "white_dress"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	flags_inv = HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT	//Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/pneumatic_cannon/speargun)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

//Carpsuit, bestsuit, lovesuit

/obj/item/clothing/suit/hooded/carp_costume/spaceproof
	name = "carp space suit"
	desc = "A slimming piece of dubious space carp technology."
	icon_state = "carp_suit"
	inhand_icon_state = "space_suit_syndicate"
	slowdown = 0	//Space carp magic, never stop believing
	armor_type = /datum/armor/carp_costume_spaceproof
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/pneumatic_cannon/speargun,
		/obj/item/toy/plush/carpplushie/dehy_carp,
		/obj/item/toy/plush/carpplushie,
		/obj/item/food/fishmeat/carp
	)//I'm giving you a hint here
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	hoodtype = /obj/item/clothing/head/hooded/carp_hood/spaceproof
	resistance_flags = NONE


/datum/armor/carp_costume_spaceproof
	melee = 20
	bullet = 10
	laser = 20
	energy = 20
	bomb = 30
	bio = 100
	fire = 60
	acid = 75
	stamina = 40

/obj/item/clothing/suit/hooded/ian_costume	//It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "corgi costume"
	desc = "A costume that looks like someone made a human-like corgi, it won't guarantee belly rubs."
	icon_state = "ian"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	//cold_protection = CHEST|GROIN|ARMS
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/ian_hood
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/hooded/bee_costume // It's Hip!
	name = "bee costume"
	desc = "Bee the true Queen!"
	icon_state = "bee"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/suit/hooded/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list()
	actions_types = list(/datum/action/item_action/toggle_human_head)
	hoodtype = /obj/item/clothing/head/hooded/human_head

/obj/item/clothing/suit/costume/striped_sweater
	name = "striped sweater"
	desc = "Reminds you of someone, but you just can't put your finger on it..."
	icon_state = "waldo_shirt"
	inhand_icon_state = "waldo_shirt"

/obj/item/clothing/suit/costume/dracula
	name = "dracula coat"
	desc = "Looks like this belongs in a very old movie set."
	icon_state = "draculacoat"
	inhand_icon_state = "draculacoat"

/obj/item/clothing/suit/costume/drfreeze_coat
	name = "doctor freeze's labcoat"
	desc = "A labcoat imbued with the power of features and freezes."
	icon_state = "drfreeze_coat"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/gothcoat
	name = "gothic coat"
	desc = "Perfect for those who want stalk in a corner of a bar."
	icon_state = "gothcoat"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	inhand_icon_state = "xenos_helm"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/clothing/mask/facehugger/toy)

/obj/item/clothing/suit/costume/nemes
	name = "pharoah tunic"
	desc = "Lavish space tomb not included."
	icon_state = "pharoah"
	icon_state = null
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/costume/bronze
	name = "bronze suit"
	desc = "A big and clanky suit made of bronze that offers no protection and looks very unfashionable. Nice."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass_old"
	armor_type = /datum/armor/costume_bronze


/obj/item/clothing/suit/costume/joker
	name = "comedian coat"
	desc = "I mean, don't you have to be funny to be a comedian?"
	icon_state = "joker_coat"
