/datum/techweb_node/clown
	id = TECHWEB_NODE_CLOWN
	tech_tier = 2
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list(TECHWEB_NODE_BASE)
	design_ids = list(
		"clown_car",
		"air_horn",
		"borg_transform_clown",
		"clown_mine",
		"honk_chassis",
		"honk_head",
		"honk_left_arm",
		"honk_left_leg",
		"honk_right_arm",
		"honk_right_leg",
		"honk_torso",
		"honker_main",
		"honker_peri",
		"honker_targ",
		"implant_trombone",
		"mech_banana_mortar",
		"mech_honker",
		"mech_mousetrap_mortar",
		"mech_punching_face",
		"shotgunslughonk",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/janitor
	id = TECHWEB_NODE_JANITOR
	tech_tier = 1
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI)
	design_ids = list(
		"advmop",
		"beartrap",
		"blutrash",
		"buffer",
		"light_replacer_bluespace",
		"spraybottle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/botany
	id = TECHWEB_NODE_BOTANY
	tech_tier = 1
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_BIOTECH)
	design_ids = list(
		"biogenerator",
		"diskplantgene",
		"flora_gun",
		"hydro_tray",
		"plantgenes",
		"portaseeder",
		"seed_extractor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
