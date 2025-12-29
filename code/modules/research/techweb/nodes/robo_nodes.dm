/datum/techweb_node/mmi
	id = "mmi"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	design_ids = list("mmi")

/datum/techweb_node/robotics
	id = "robotics"
	tech_tier = 2
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list("paicard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	tech_tier = 3
	display_name = "Advanced Robotics Research"
	description = "It can even do the dishes!"
	prereq_ids = list("robotics")
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_diamonddrill",
		"borg_upgrade_trashofholding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/neural_programming
	id = "neural_programming"
	tech_tier = 2
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list(
		"biotech",
		"datatheory",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("neural_programming")
	design_ids = list("mmi_posi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/ai
	id = "ai"
	tech_tier = 3
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list(
		"posibrain",
		"robotics",
	)
	design_ids = list(
		"aicore",
		"aifixer",
		"aiupload",
		"asimov_module",
		"borg_ai_control",
		"corporate_module",
		"default_module",
		"drone_module",
		"freeform_module",
		"intellicard",
		"mecha_tracking_ai_control",
		"nutimov_module",
		"oxygen_module",
		"paladin_module",
		"protectstation_module",
		"quarantine_module",
		"remove_module",
		"reset_module",
		"robocop_module",
		"safeguard_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/ai_laws
	id = "ai_laws"
	tech_tier = 4
	display_name = "Advanced AI Laws"
	description = "Delving into sophisticated AI directives, with hopes that they won't lead to humanity's extinction."
	prereq_ids = list("ai")
	design_ids = list(
		"antimov_module",
		"asimovpp_module",
		"crewsimov_module",
		"balance_module",
		"damaged_module",
		"dadbot_module",
		"dungeon_master_module",
		"freeformcore_module",
		"hippocratic_module",
		"hulkamania_module",
		"liveandletlive_module",
		"efficiency_module",
		"onehuman_module",
		"overlord_module",
		"painter_module",
		"paladin_devotion_module",
		"peacekeeper_module",
		"purge_module",
		"reporter_module",
		"ten_commandments_module",
		"thermodynamic_module",
		"thinkermov_module",
		"tyrant_module",
		"yesman_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
