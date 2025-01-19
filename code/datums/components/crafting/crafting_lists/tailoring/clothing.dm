
/// clothing stuff crafting

/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 5,
		/obj/item/stack/sheet/leather = 4)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = /obj/item/clothing/head/helmet/durathread
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4,
		/obj/item/stack/sheet/leather = 5)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = /obj/item/clothing/under/color/durathread
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpskirt
	name = "Durathread Jumpskirt"
	result = /obj/item/clothing/under/color/jumpskirt/durathread
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_hoodie
	name = "Durathread Hoodie"
	result = /obj/item/clothing/suit/hooded/hoodie/durathread
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 5)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = /obj/item/clothing/head/beret/durathread
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 2)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = /obj/item/clothing/head/beanie/durathread
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 2)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = /obj/item/clothing/mask/bandana/durathread
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 1)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = /obj/item/storage/belt/fannypack
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 2,
		/obj/item/stack/sheet/leather = 1
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/voice_modulator
	name = "Voice Modulator Mask"
	result = /obj/item/clothing/mask/gas/old/modulator
	time = 4 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(
		/obj/item/clothing/mask/gas/old = 1,
		/obj/item/assembly/voice = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = /obj/item/clothing/suit/costume/ghost_sheet
	time = 0.5 SECONDS
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/foilhat
	name = "Tinfoil Hat"
	result = /obj/item/clothing/head/costume/foilhat
	time = 3 SECONDS
	tools = list(TOOL_CROWBAR, TOOL_WIRECUTTER)
	reqs = list(/obj/item/stack/sheet/iron = 3)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/foilenvirohelm
	name = "Ghetto Envirosuit Helmet"
	result = /obj/item/clothing/head/costume/foilhat/plasmaman
	time = 5 SECONDS
	tools = list(TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/clothing/head/costume/foilhat = 1,
		/obj/item/stack/package_wrap = 10,
		/obj/item/stack/cable_coil = 15,
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/head/utility/hardhat = 1,
		/obj/item/stack/sheet/glass = 1
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/rainbowbunchcrown
	name = "Rainbow Flower Crown"
	result = /obj/item/clothing/head/flowercrown/rainbowbunch
	time = 2.5 SECONDS
	reqs = list(
		/obj/item/food/grown/flower/rainbow = 5,
		/obj/item/stack/cable_coil = 3
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/sunflowercrown
	name = "Sunflower Crown"
	result = /obj/item/clothing/head/flowercrown/sunflower
	time = 2.5 SECONDS
	reqs = list(
		/obj/item/grown/sunflower = 5,
		/obj/item/stack/cable_coil = 3
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/poppycrown
	name = "Poppy Crown"
	result = /obj/item/clothing/head/flowercrown/poppy
	time = 2.5 SECONDS
	reqs = list(
		/obj/item/food/grown/flower/poppy = 5,
		/obj/item/stack/cable_coil = 3
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/lilycrown
	name = "Lily Crown"
	result = /obj/item/clothing/head/flowercrown/lily
	time = 2.5 SECONDS
	reqs = list(
		/obj/item/food/grown/flower/lily = 3,
		/obj/item/stack/cable_coil = 3
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/mummy
	name = "Mummification Bandages (Mask)"
	result = /obj/item/clothing/mask/mummy
	time = 2 SECONDS
	tools = list(/obj/item/nullrod/egyptian)
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 2)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/mummy/body
	name = "Mummification Bandages (Body)"
	result = /obj/item/clothing/under/costume/mummy
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 5)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/chaplain_hood
	name = "Follower Hoodie"
	result = /obj/item/clothing/suit/hooded/chaplain_hoodie
	time = 3 SECONDS
	tools = list(/obj/item/clothing/suit/hooded/chaplain_hoodie, /obj/item/storage/book/bible)
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 4)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/insulated_boxing_gloves
	name = "Insulated Boxing Gloves"
	result = /obj/item/clothing/gloves/boxing/yellow/insulated
	time = 6 SECONDS
	reqs = list(
		/obj/item/clothing/gloves/boxing = 1,
		/obj/item/clothing/gloves/color/yellow = 1
	)
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING

/datum/crafting_recipe/gripperoffbrand
	name = "Improvised Gripper Gloves"
	reqs = list(
			/obj/item/clothing/gloves/fingerless = 1,
			/obj/item/stack/sticky_tape = 1)
	result = /obj/item/clothing/gloves/tackler/offbrand
	category = CAT_TAILORING
	subcategory = CAT_CLOTHING
