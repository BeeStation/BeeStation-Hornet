/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Misc
 */

/*
 * Lasertag
 */
/obj/item/clothing/suit/bluetag
	name = "blue laser tag armor"
	desc = "A piece of plastic armor. It has sensors that react to red light." //Lasers are concentrated light
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/bluetag)
	resistance_flags = NONE

/obj/item/clothing/suit/redtag
	name = "red laser tag armor"
	desc = "A piece of plastic armor. It has sensors that react to blue light."
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/redtag)
	resistance_flags = NONE

// Aristocrat Coats

/obj/item/clothing/suit/aristo_orange
	name = "orange aristocrat coat"
	desc = "A fancy coat made of silk. This one is orange."
	icon_state = "aristo_orange"
	item_state = "aristo_orange"

/obj/item/clothing/suit/aristo_red
	name = "red aristocrat coat"
	desc = "A fancy coat made of silk. This one is red."
	icon_state = "aristo_red"
	item_state = "aristo_red"

/obj/item/clothing/suit/aristo_brown
	name = "brown aristocrat coat"
	desc = "A fancy coat made of silk. This one is brown."
	icon_state = "aristo_brown"
	item_state = "aristo_brown"

/obj/item/clothing/suit/aristo_blue
	name = "blue aristocrat coat"
	desc = "A fancy coat made of silk. This one is blue."
	icon_state = "aristo_blue"
	item_state = "aristo_blue"

/*
 * Costume
 */
/obj/item/clothing/suit/hooded/flashsuit
	name = "flashy costume"
	desc = "What did you expect?"
	icon_state = "flashsuit"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/flashsuit

/obj/item/clothing/suit/hooded/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/hasturhood

/obj/item/clothing/head/hooded/flashsuit
	name = "flash button"
	desc = "You will learn to fear the flash."
	icon_state = "flashsuit"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACIALHAIR|HIDEFACE|HIDEMASK

/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	allowed = list(/obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)

/obj/item/clothing/suit/pirate/captain
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	item_state = "death"
	flags_1 = CONDUCT_1
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous" //Needs no fixing
	icon_state = "justice"
	item_state = "justice"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/judgerobe
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
	item_state = "syndicate-black-red"
	desc = "A plastic replica of the Syndicate space suit. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE

/obj/item/clothing/suit/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "\improper Imperium monk suit"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)


/obj/item/clothing/suit/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	icon_state = "owl_wings"
	item_state = "owl_wings"
	togglename = "wings"
	body_parts_covered = ARMS|CHEST
	actions_types = list(/datum/action/item_action/toggle_wings)

/obj/item/clothing/suit/toggle/owlwings/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING)
		disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.add_overlay(mutable_appearance('icons/mob/robots.dmi', "robot_e")) //gotta look realistic
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "standard_borg_disguise", I) //you look like a robot to robots! (including yourself because you're totally a robot)


/obj/item/clothing/suit/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	item_state = "snowman"
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	item_state = "classicponcho"

/obj/item/clothing/suit/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	item_state = "greenponcho"

/obj/item/clothing/suit/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	item_state = "redponcho"

/obj/item/clothing/suit/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseparable. Literally."
	icon_state = "ponchoshame"
	item_state = "ponchoshame"

/obj/item/clothing/suit/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/suit/whitedress
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
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT	//Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/pneumatic_cannon/speargun)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

/obj/item/clothing/head/hooded/carp_hood
	name = "carp hood"
	desc = "A hood attached to a carp costume."
	icon_state = "carp_casual"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/head/hooded/hasturhood
	name = "hastur's hood"
	desc = "It's <i>unspeakably</i> stylish."
	icon_state = "hasturhood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/carp_hood/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/hooded/carp_hood/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/suit/hooded/ian_costume	//It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "corgi costume"
	desc = "A costume that looks like someone made a human-like corgi, it won't guarantee belly rubs."
	icon_state = "ian"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	//cold_protection = CHEST|GROIN|ARMS
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/ian_hood
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/head/hooded/ian_hood
	name = "corgi hood"
	desc = "A hood that looks just like a corgi's head, it won't guarantee dog biscuits."
	icon_state = "ian"
	body_parts_covered = HEAD
	//cold_protection = HEAD
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/bee_costume // It's Hip!
	name = "bee costume"
	desc = "Bee the true Queen!"
	icon_state = "bee"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/head/hooded/bee_hood
	name = "bee hood"
	desc = "A hood attached to a bee costume."
	icon_state = "bee"
	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEHAIR|HIDEEARS
	dynamic_hair_suffix = ""

/obj/item/clothing/suit/hooded/bee_costume/syndie
	name = "BLF costume"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20,"energy" = 40, "bomb" = 0, "bio" = 60, "rad" = 0, "fire" = 0, "acid" = 50, "stamina" = 40)
	hoodtype = /obj/item/clothing/head/hooded/bee_hood/syndie

/obj/item/clothing/head/hooded/bee_hood/syndie
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20,"energy" = 40, "bomb" = 0, "bio" = 60, "rad" = 0, "fire" = 0, "acid" = 50, "stamina" = 40)

/obj/item/clothing/suit/hooded/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list()
	actions_types = list(/datum/action/item_action/toggle_human_head)
	hoodtype = /obj/item/clothing/head/hooded/human_head


/obj/item/clothing/head/hooded/human_head
	name = "bloated human head"
	desc = "A horribly bloated and mismatched human head."
	icon_state = "lingspacehelmet"
	body_parts_covered = HEAD
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/suit/security/officer/russian
	name = "\improper Russian officer's jacket"
	desc = "This jacket is for those special occasions when a russian officer isn't required to wear their armor."
	icon_state = "officertanjacket"
	item_state = "officertanjacket"
	body_parts_covered = CHEST|ARMS

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/suit/delinquent
	name = "deliquent jacket"
	desc = "Yare yare daze."
	icon_state = "jocoat"

/obj/item/clothing/suit/madsci
	name = "mad scientist labcoat"
	desc = "El psy congroo."
	icon_state = "madsci"

/obj/item/clothing/suit/hooded/renault_costume
	name = "renault costume"
	desc = "The cutest pair of pajamas you've ever seen."
	icon_state = "renault_suit"
	hoodtype = /obj/item/clothing/head/hooded/renault_hood

/obj/item/clothing/head/hooded/renault_hood
	name = "renault hoodie"
	desc = "An adorable hoodie vaguely resembling renault."
	icon_state = "renault_hoodie"
	flags_inv = HIDEEARS

/obj/item/clothing/suit/retro_jacket
	name = "retro jacket"
	desc = "Do you like hurting other people?"
	icon_state = "retro_jacket"

/*
 * Misc
 */

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer. Manufactured by Antyphun Corp." //Straight jacket is antifun
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	equip_delay_self = 50
	strip_delay = 60
	breakouttime = 3000
	pocket_storage_component_path = FALSE

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"

/obj/item/clothing/suit/nerdshirt
	name = "gamer shirt"
	desc = "A baggy shirt with vintage game character Phanic the Weasel. Why would anyone wear this?"
	icon_state = "nerdshirt"
	item_state = "nerdshirt"

/obj/item/clothing/suit/vapeshirt //wearing this is asking to get beat.
	name = "Vape Naysh shirt"
	desc = "A cheap white T-shirt with a big tacky \"VN\" on the front, Why would you wear this unironically?"
	icon_state = "vapeshirt"
	item_state = "vapeshirt"

/obj/item/clothing/suit/striped_sweater
	name = "striped sweater"
	desc = "Reminds you of someone, but you just can't put your finger on it..."
	icon_state = "waldo_shirt"
	item_state = "waldo_shirt"

/obj/item/clothing/suit/jacket
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomberjacket"
	item_state = "brownjsuit"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/radio)
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	item_state = "hostrench"
	resistance_flags = NONE
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/gun/ballistic/revolver/detective, /obj/item/radio)

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "leather overcoat"
	desc = "That's a damn fine coat."
	icon_state = "leathercoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/jacket/puffer
	name = "puffer jacket"
	desc = "A thick jacket with a rubbery, water-resistant shell."
	icon_state = "pufferjacket"
	item_state = "hostrench"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/jacket/puffer/vest
	name = "puffer vest"
	desc = "A thick vest with a rubbery, water-resistant shell."
	icon_state = "puffervest"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 30, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/jacket/miljacket
	name = "military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/radio)

/obj/item/clothing/suit/jacket/letterman
	name = "letterman jacket"
	desc = "A classic brown letterman jacket. Looks pretty hot and heavy."
	icon_state = "letterman"
	item_state = "letterman"

/obj/item/clothing/suit/jacket/letterman_red
	name = "red letterman jacket"
	desc = "A letterman jacket in a sick red color. Radical."
	icon_state = "letterman_red"
	item_state = "letterman_red"

/obj/item/clothing/suit/jacket/letterman_syndie
	name = "blood-red letterman jacket"
	desc = "Oddly, this jacket seems to have a large S on the back..."
	icon_state = "letterman_s"
	item_state = "letterman_s"

/obj/item/clothing/suit/jacket/letterman_nanotrasen
	name = "blue letterman jacket"
	desc = "A blue letterman jacket with a proud Nanotrasen N on the back. The tag says that it was made in Space China."
	icon_state = "letterman_n"
	item_state = "letterman_n"

/obj/item/clothing/suit/dracula
	name = "dracula coat"
	desc = "Looks like this belongs in a very old movie set."
	icon_state = "draculacoat"
	item_state = "draculacoat"

/obj/item/clothing/suit/drfreeze_coat
	name = "doctor freeze's labcoat"
	desc = "A labcoat imbued with the power of features and freezes."
	icon_state = "drfreeze_coat"
	item_state = "drfreeze_coat"

/obj/item/clothing/suit/gothcoat
	name = "gothic coat"
	desc = "Perfect for those who want stalk in a corner of a bar."
	icon_state = "gothcoat"
	item_state = "gothcoat"

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/clothing/mask/facehugger/toy)

/obj/item/clothing/suit/nemes
	name = "pharoah tunic"
	desc = "Lavish space tomb not included."
	icon_state = "pharoah"
	icon_state = "pharoah"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/caution
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	custom_price = 10
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN
	attack_verb = list("warned", "cautioned", "smashed")
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)



// WINTER COATS

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	item_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A cozy winter hood attached to a heavy winter jacket."
	icon_state = "winterhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "coatcentcom"
	item_state = "coatcentcom"
	armor = list("melee" = 35, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 60, "stamina" = 25)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize()
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "winterhood_centcom"
	armor = list("melee" = 35, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 60, "stamina" = 25)

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	desc = "A luxurious winter coat, stuffed with the down of the endangered Uka bird and trimmed with genuine sable. The fabric is an indulgently soft micro-fiber,\
					and the deep ultramarine colour is only one that could be achieved with minute amounts of crystalline bluespace dust woven into the thread between the plectrums.\
					Extremely lavish, and extremely durable."
	icon_state = "coatcaptain"
	item_state = "coatcaptain"
	armor = list("melee" = 25, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50, "stamina" = 20)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

// SERVICE
/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personnel's winter coat"
	desc = "A cozy winter coat, covered in thick fur. The breast features a proud yellow chevron, reminding everyone that you're the second banana."
	icon_state = "coathop"
	item_state = "coathop"
	armor = list("melee" = 10, "bullet" = 15, "laser" = 15, "energy" = 25, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 35, "stamina" = 15)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop

/obj/item/clothing/head/hooded/winterhood/hop
	icon_state = "winterhood_hop"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	desc = "A green and blue winter coat. The zipper tab looks like the flower from a member of Rosa Hesperrhodos, a pretty pink-and-white rose. The colours absolutely clash."
	icon_state = "coathydro"
	item_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants, /obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	desc = "A green winter coat hood."
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/janitor
	name = "janitors winter coat"
	desc = "A purple-and-beige winter coat that smells of space cleaner."
	icon_state = "coatjanitor"
	item_state = "coatjanitor"
	allowed = list(/obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/storage/fancy/cigarettes, /obj/item/lighter,/obj/item/grenade/chem_grenade,/obj/item/lightreplacer,/obj/item/flashlight,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/spray,/obj/item/soap,/obj/item/holosign_creator,/obj/item/key/janitor,/obj/item/melee/flyswatter,/obj/item/paint/paint_remover,/obj/item/storage/bag/trash,/obj/item/reagent_containers/glass/bucket)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/janitor

/obj/item/clothing/head/hooded/winterhood/janitor
	desc = "A purple hood that smells of space cleaner."
	icon_state = "winterhood_janitor"

// SECURITY

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	desc = "A red, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority.  The zipper tab is a pair of jingly little handcuffs that get annoying after the first ten seconds."
	icon_state = "coatsecurity"
	item_state = "coatsecurity"
	armor = list("melee" = 25, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 20)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	desc = "A red, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/security/hos
	name = "head of security's winter coat"
	desc = "A red, armour-padded winter coat, lovingly woven with a Kevlar interleave and reinforced with semi-ablative polymers and a silver azide fill material. The zipper tab looks like a tiny replica of Beepsky."
	icon_state = "coathos"
	item_state = "coathos"
	armor = list("melee" = 35, "bullet" = 25, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 55, "stamina" = 30)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/hos

/obj/item/clothing/head/hooded/winterhood/security/hos
	desc = "A red, armour-padded winter hood, lovingly woven with a Kevlar interleave. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "winterhood_hos"

// MEDICAL

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	desc = "An arctic white winter coat with a small blue caduceus instead of a plastic zipper tab. Snazzy."
	icon_state = "coatmedical"
	item_state = "coatmedical"
	allowed = list(/obj/item/analyzer, /obj/item/sensor_device, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	desc = "A white winter coat hood."
	icon_state = "winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "chief medical officer's winter coat"
	desc = "A winter coat in a vibrant shade of blue with a small silver caduceus instead of a plastic zipper tab. The normal liner is replaced with an exceptionally thick, soft layer of fur."
	icon_state = "coatcmo"
	item_state = "coatcmo"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 20, "acid" = 30, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	desc = "A blue winter coat hood."
	icon_state = "winterhood_cmo"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 20, "acid" = 30, "stamina" = 0)

/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry
	name = "chemistry winter coat"
	desc = "A lab-grade winter coat made with acid resistant polymers. For the enterprising chemist who was exiled to a frozen wasteland on the go."
	icon_state = "coatchemistry"
	item_state = "coatchemistry"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/chemistry

/obj/item/clothing/head/hooded/winterhood/medical/chemistry
	desc = "A white winter coat hood."
	icon_state = "winterhood_chemistry"

/obj/item/clothing/suit/hooded/wintercoat/medical/viro
	name = "virology winter coat"
	desc = "A white winter coat with green markings. Warm, but wont fight off the common cold or any other disease. Might make people stand far away from you in the hallway. The zipper tab looks like an oversized bacteriophage."
	icon_state = "coatviro"
	item_state = "coatviro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/viro

/obj/item/clothing/head/hooded/winterhood/medical/viro
	desc = "A white winter coat hood with green markings."
	icon_state = "winterhood_viro"

/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "coatparamed"
	item_state = "coatparamed"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/paramedic

/obj/item/clothing/head/hooded/winterhood/medical/paramedic
	desc = "A white winter coat hood with blue markings."
	icon_state = "winterhood_paramed"

// SCIENCE

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	desc = "A white winter coat with an outdated atomic model instead of a plastic zipper tab."
	icon_state = "coatscience"
	item_state = "coatscience"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 0, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

/obj/item/clothing/head/hooded/winterhood/science
	desc = "A white winter coat hood. This one will keep your brain warm. About as much as the others, really."
	icon_state = "winterhood_science"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/hooded/wintercoat/science/rd
	name = "research director's winter coat"
	desc = "A thick arctic winter coat with an outdated atomic model instead of a plastic zipper tab. Most in the know are heavily aware that Bohr's model of the atom was outdated by the time of the 1930s when the Heisenbergian and Schrodinger models were generally accepted for true. Nevertheless, we still see its use in anachronism, roleplaying, and, in this case, as a zipper tab. At least it should keep you warm on your ivory pillar."
	icon_state = "coatrd"
	item_state = "coatrd"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 0, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

/obj/item/clothing/head/hooded/winterhood/science/rd
	desc = "A white winter coat hood. It smells faintly of hair gel."
	icon_state = "winterhood_rd"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/hooded/wintercoat/science/robotics
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "coatrobotics"
	item_state = "coatrobotics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/robotics

/obj/item/clothing/head/hooded/winterhood/science/robotics
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "winterhood_robotics"

/obj/item/clothing/suit/hooded/wintercoat/science/genetics
	name = "genetics winter coat"
	desc = "A white winter coat with a DNA helix for the zipper tab."
	icon_state = "coatgenetics"
	item_state = "coatgenetics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/genetics

/obj/item/clothing/head/hooded/winterhood/science/genetics
	desc = "A white winter coat hood. It's warm."
	icon_state = "winterhood_genetics"

// ENGINEERING

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective orange stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "coatengineer"
	item_state = "coatengineer"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 45, "stamina" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering

/obj/item/clothing/head/hooded/winterhood/engineering
	desc = "A yellow winter coat hood. Definitely not a replacement for a hard hat."
	icon_state = "winterhood_engineer"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 45, "stamina" = 0)

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer's winter coat"
	desc = "A white winter coat with reflective green and yellow stripes. Stuffed with asbestos, treated with fire retardant PBDE, lined with a micro thin sheet of lead foil and snugly fitted to your body's measurements. This baby's ready to save you from anything except the thyroid cancer and systemic fibrosis you'll get from wearing it. The zipper tab is a tiny golden wrench."
	icon_state = "coatce"
	item_state = "coatce"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 10)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	desc = "A white winter coat hood. Feels surprisingly heavy. The tag says that it's not child safe."
	icon_state = "winterhood_ce"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 10)

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	desc = "A yellow and blue winter coat. The zipper pull-tab is made to look like a miniature breath mask."
	icon_state = "coatatmos"
	item_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	desc = "A yellow and blue winter coat hood."
	icon_state = "winterhood_atmos"

// SUPPLY

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A tan-and-grey winter coat. The zipper tab is a small pin resembling a MULE. It fills you with the warmth of a fierce independence."
	icon_state = "coatcargo"
	item_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo

/obj/item/clothing/head/hooded/winterhood/cargo
	desc = "A grey hood for a winter coat."
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/qm
	name = "quartermaster's winter coat"
	desc = "A dark brown winter coat that has a golden crate pin for its zipper pully."
	icon_state = "coatqm"
	item_state = "coatqm"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/qm

/obj/item/clothing/head/hooded/winterhood/qm
	desc = "A dark brown winter hood."
	icon_state = "winterhood_qm"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A dusty button up winter coat. The zipper tab looks like a tiny pickaxe."
	icon_state = "coatminer"
	item_state = "coatminer"
	allowed = list(/obj/item/pickaxe, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A dusty winter coat hood."
	icon_state = "winterhood_miner"

//Old winter coats

/obj/item/clothing/suit/hooded/wintercoat/old
	name = "nostalgic winter coat"
	desc = "A well-worn heavy jacket made from 'synthetic' animal furs."
	icon_state = "old_coatwinter"

/obj/item/clothing/head/hooded/winterhood/old
	name = "winter hood"
	desc = "An old hood attached to a well-worn heavy winter jacket."
	icon_state = "old_winterhood"

/obj/item/clothing/suit/hooded/wintercoat/security/old
	name = "nostalgic security winter coat"
	icon_state = "old_coatsecurity"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/old

/obj/item/clothing/suit/hooded/wintercoat/security/old/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security/old
	icon_state = "old_winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/medical/old
	name = "nostalgic medical winter coat"
	icon_state = "old_coatmedical"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/old

/obj/item/clothing/head/hooded/winterhood/medical/old
	icon_state = "old_winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/science/old
	name = "nostalgic science winter coat"
	icon_state = "old_coatscience"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/old

/obj/item/clothing/head/hooded/winterhood/science/old
	icon_state = "old_winterhood_science"

/obj/item/clothing/suit/hooded/wintercoat/engineering/old
	name = "nostalgic engineering winter coat"
	icon_state = "old_coatengineer"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/old

/obj/item/clothing/head/hooded/winterhood/engineering/old
	icon_state = "old_winterhood_engineer"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos/old
	name = "nostalgic atmospherics winter coat"
	icon_state = "old_coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos/old

/obj/item/clothing/head/hooded/winterhood/engineering/atmos/old
	icon_state = "old_winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro/old
	name = "nostalgic hydroponics winter coat"
	icon_state = "old_coathydro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro/old

/obj/item/clothing/head/hooded/winterhood/hydro/old
	icon_state = "old_winterhood_hydro"

//end of winter coats

/obj/item/clothing/suit/spookyghost
	name = "spooky ghost"
	desc = "This is obviously just a bedsheet, but maybe try it on?"
	icon_state = "bedsheet"
	user_vars_to_edit = list("name" = "Spooky Ghost", "real_name" = "Spooky Ghost" , "incorporeal_move" = INCORPOREAL_MOVE_BASIC, "appearance_flags" = KEEP_TOGETHER|TILE_BOUND, "alpha" = 150)
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER //so the bedsheet goes over everything but fire

/obj/item/clothing/suit/bronze
	name = "bronze suit"
	desc = "A big and clanky suit made of bronze that offers no protection and looks very unfashionable. Nice."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass_old"
	armor = list("melee" = 5, "bullet" = 0, "laser" = -5, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20, "stamina" = 30)

/obj/item/clothing/suit/ghost_sheet
	name = "ghost sheet"
	desc = "The hands float by themselves, so it's extra spooky."
	icon_state = "ghost_sheet"
	item_state = "ghost_sheet"
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEGLOVES|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	alternate_worn_layer = UNDER_HEAD_LAYER

/obj/item/clothing/under/costume/joker
	name = "comedian suit"
	desc = "The worst part of having a mental illness is people expect you to behave as if you don't."
	icon_state = "joker"
	item_state = "joker"
	can_adjust = FALSE

/obj/item/clothing/suit/joker
	name = "comedian coat"
	desc = "I mean, don't you have to be funny to be a comedian?"
	icon_state = "joker_coat"
	item_state = "joker_coat"

/obj/item/clothing/suit/toggle/softshell
	name = "softshell jacket"
	desc = "A Nanotrasen-branded softshell jacket."
	icon_state = "softshell"
	item_state = "softshell"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/radio)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 30, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	togglename = "zipper"
	body_parts_covered = CHEST|GROIN|ARMS
