/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 50
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = /obj/item/clothing/head/helmet/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = /obj/item/clothing/under/color/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpskirt
	name = "Durathread Jumpskirt"
	result = /obj/item/clothing/under/color/jumpskirt/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_hoodie
	name = "Durathread Hoodie"
	result = /obj/item/clothing/suit/hooded/hoodie/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 5)
	time = 50
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = /obj/item/clothing/head/beret/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = /obj/item/clothing/head/beanie/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = /obj/item/clothing/mask/bandana/durathread
	reqs = list(/obj/item/stack/sheet/cotton/cloth/durathread = 1)
	time = 25
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = /obj/item/storage/belt/fannypack
	reqs = list(/obj/item/stack/sheet/cotton/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 20
	category = CAT_CLOTHING

/datum/crafting_recipe/voice_modulator
	name = "Voice Modulator Mask"
	result = /obj/item/clothing/mask/gas/old/modulator
	time = 45
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(/obj/item/clothing/mask/gas/old = 1,
				  /obj/item/assembly/voice = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/security/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/health/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/beergoggles
	name = "Beer Goggles"
	result = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/beergogglesremoval
	name = "Beer Goggles removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/advanced/reagent = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/sunhudscience
	name = "Science Sunglasses"
	result = /obj/item/clothing/glasses/science/sciencesun
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses/advanced = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/sunhudscienceremoval
	name = "Science Sunglasses removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science/sciencesun = 1)
	blacklist = list(/obj/item/clothing/glasses/science/sciencesun/degraded)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunsec
	name = "Degraded Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunsecremoval
	name = "Degraded Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunmed
	name = "Degraded Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsunmedremoval
	name = "Degraded Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsundiag
	name = "Degraded Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/deghudsundiagremoval
	name = "Degraded Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/degsunhudscience
	name = "Degraded Science Sunglasses"
	result = /obj/item/clothing/glasses/science/sciencesun/degraded
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/degsunhudscienceremoval
	name = "Degraded Science Sunglasses removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science/sciencesun/degraded = 1)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresmed
	name = "Prescription Medical HUDglasses"
	result = /obj/item/clothing/glasses/hud/health/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpressec
	name = "Prescription Security HUDglasses"
	result = /obj/item/clothing/glasses/hud/security/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpressci
	name = "Prescription Science Goggles"
	result = /obj/item/clothing/glasses/science/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresmeson
	name = "Prescription Meson Scanner"
	result = /obj/item/clothing/glasses/meson/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/hudpresdiag
	name = "Prescription Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/prescription
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/regular/ = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_EYEWEAR

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = /obj/item/clothing/suit/ghost_sheet
	time = 5
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/foilhat
	name = "Tinfoil Hat"
	result = /obj/item/clothing/head/foilhat
	time = 5
	tools = list(TOOL_CROWBAR)
	reqs = list(/obj/item/stack/sheet/iron = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/foilenvirohelm
	name = "Ghetto Envirosuit Helmet"
	result = /obj/item/clothing/head/foilhat/plasmaman
	time = 40
	tools = list(TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	reqs = list(/obj/item/clothing/head/foilhat = 1,
				/obj/item/stack/package_wrap = 10,
				/obj/item/stack/cable_coil = 15,
				/obj/item/clothing/glasses/meson = 1,
				/obj/item/flashlight = 1,
				/obj/item/clothing/head/hardhat = 1,
				/obj/item/stack/sheet/glass = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/rainbowbunchcrown
	name = "Rainbow Flower Crown"
	result = /obj/item/clothing/head/flowercrown/rainbowbunch
	time = 20
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/flower/rainbow = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/sunflowercrown
	name = "Sunflower Crown"
	result = /obj/item/clothing/head/flowercrown/sunflower
	time = 20
	reqs = list(/obj/item/grown/sunflower = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/poppycrown
	name = "Poppy Crown"
	result = /obj/item/clothing/head/flowercrown/poppy
	time = 20
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/flower/poppy = 5,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/lilycrown
	name = "Lily Crown"
	result = /obj/item/clothing/head/flowercrown/lily
	time = 20
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/flower/lily = 3,
				/obj/item/stack/cable_coil = 3)
	category = CAT_CLOTHING
