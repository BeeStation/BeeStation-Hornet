/obj/item/clothing/suit/costume
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'

/obj/item/clothing/suit/hooded/flashsuit
	name = "flashy costume"
	desc = "What did you expect?"
	icon_state = "flashsuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/flashsuit

/obj/item/clothing/suit/costume/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)

/obj/item/clothing/suit/costume/pirate/captain
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = null

/obj/item/clothing/suit/costume/cyborg_suit //unavailable save for adminbus
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	item_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	flags_1 = CONDUCT_1
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/costume/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous" //Needs no fixing
	icon_state = "justice"
	item_state = "justice"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/costume/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes, /obj/item/stack/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/apron/purple_bartender
	name = "purple bartender apron"
	desc = "A fancy purple apron for a stylish person."
	icon_state = "purplebartenderapron"
	item_state = "purplebartenderapron"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/syndicatefake
	name = "black and red space suit replica"
	icon_state = "syndicate-black-red"
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	item_state = "syndicate-black-red"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	desc = "A plastic replica of the Syndicate space suit. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE

/obj/item/clothing/suit/costume/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/hasturhood

/obj/item/clothing/suit/costume/imperium_monk
	name = "\improper Imperium monk suit"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/costume/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/costume/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	item_state = null
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	icon_state = "owl_wings"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = null
	toggle_noun = "wings"
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/suit/toggle/owlwings/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/suit/costume/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
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
	item_state = null
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/costume/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	item_state = null

/obj/item/clothing/suit/costume/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	item_state = null

/obj/item/clothing/suit/costume/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	item_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseparable. Literally."
	icon_state = "ponchoshame"
	item_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/suit/costume/poncho/ponchoshame/outlaw
	desc = "You broke the rules of the duel, and drew your gun before High Noon. This poncho will rest on your shoulders eternally, just like your shame."
	icon_state = "ponchoshame_alt"
	item_state = "ponchoshame_alt"
	armor = list(MELEE = 25,  BULLET = 25, LASER = 25, ENERGY = 20, BOMB = 30, BIO = 30, RAD = 20, FIRE = 0, ACID = 30, STAMINA = 35)
	body_parts_covered = CHEST|GROIN
	allowed = list(/obj/item/gun/ballistic/shotgun/lever_action, /obj/item/gun/ballistic/rifle/leveraction, /obj/item/gun/ballistic/revolver)

/obj/item/clothing/suit/costume/whitedress
	name = "white dress"
	desc = "A fancy white dress."
	icon_state = "white_dress"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	flags_inv = HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = "labcoat"
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
	item_state = "space_suit_syndicate"
	slowdown = 0	//Space carp magic, never stop believing
	armor = list(MELEE = 20,  BULLET = 10, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 75, FIRE = 60, ACID = 75, STAMINA = 40)
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

/obj/item/clothing/suit/hooded/ian_costume	//It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "corgi costume"
	desc = "A costume that looks like someone made a human-like corgi, it won't guarantee belly rubs."
	icon_state = "ian"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = "labcoat"
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
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/suit/hooded/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list()
	actions_types = list(/datum/action/item_action/toggle_human_head)
	hoodtype = /obj/item/clothing/head/hooded/human_head

/obj/item/clothing/suit/costume/striped_sweater
	name = "striped sweater"
	desc = "Reminds you of someone, but you just can't put your finger on it..."
	icon_state = "waldo_shirt"
	item_state = "waldo_shirt"

/obj/item/clothing/suit/costume/dracula
	name = "dracula coat"
	desc = "Looks like this belongs in a very old movie set."
	icon_state = "draculacoat"
	item_state = "draculacoat"

/obj/item/clothing/suit/costume/drfreeze_coat
	name = "doctor freeze's labcoat"
	desc = "A labcoat imbued with the power of features and freezes."
	icon_state = "drfreeze_coat"
	item_state = null

/obj/item/clothing/suit/costume/gothcoat
	name = "gothic coat"
	desc = "Perfect for those who want stalk in a corner of a bar."
	icon_state = "gothcoat"
	item_state = null

/obj/item/clothing/suit/costume/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
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
	armor = list(MELEE = 5,  BULLET = 0, LASER = -5, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 20, ACID = 20, STAMINA = 30)

/obj/item/clothing/suit/costume/joker
	name = "comedian coat"
	desc = "I mean, don't you have to be funny to be a comedian?"
	icon_state = "joker_coat"
