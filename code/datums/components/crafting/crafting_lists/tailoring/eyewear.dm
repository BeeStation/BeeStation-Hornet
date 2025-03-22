
/// eyewear stuff crafting

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/hud/security = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/security/sunglasses/degraded)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/health/sunglasses/degraded)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/hud/diagnostic = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	blacklist = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/degraded)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/beergoggles
	name = "Beer Goggles"
	result = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/science = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/beergogglesremoval
	name = "Beer Goggles removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/advanced/reagent = 1)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/sunhudscience
	name = "Science Sunglasses"
	result = /obj/item/clothing/glasses/science/sciencesun
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/science = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/sunhudscienceremoval
	name = "Science Sunglasses removal"
	result = /obj/item/clothing/glasses/sunglasses/advanced
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science/sciencesun = 1)
	blacklist = list(/obj/item/clothing/glasses/science/sciencesun/degraded)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudpresmed
	name = "Prescription Medical HUDglasses"
	result = /obj/item/clothing/glasses/hud/health/prescription
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/clothing/glasses/regular/ = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudpressec
	name = "Prescription Security HUDglasses"
	result = /obj/item/clothing/glasses/hud/security/prescription
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
		/obj/item/clothing/glasses/regular/ = 1,
		/obj/item/stack/cable_coil = 5)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudpressci
	name = "Prescription Science Goggles"
	result = /obj/item/clothing/glasses/science/prescription
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/science = 1,
		/obj/item/clothing/glasses/regular/ = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudpresmeson
	name = "Prescription Meson Scanner"
	result = /obj/item/clothing/glasses/meson/prescription
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/meson = 1,
		/obj/item/clothing/glasses/regular/ = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/hudpresdiag
	name = "Prescription Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/prescription
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/hud/diagnostic = 1,
		/obj/item/clothing/glasses/regular/ = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT
