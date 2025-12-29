/datum/techweb_node/mmi
	id = "mmi"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	design_ids = list(
		"mmi",
	)

/datum/techweb_node/cyborg
	id = "cyborg"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"borg_suit",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
		"borgupload",
		"cyborgrecharger",
		"robocontrol",
		"sflash",
	)

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cyborgs."
	prereq_ids = list("engineering")
	design_ids = list(
		"borg_upgrade_circuitapp",
		"borg_upgrade_expand",
		"borg_upgrade_holding",
		"borg_upgrade_lavaproof",
		"borg_upgrade_rped",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cyborg_upg_med
	id = "cyborg_upg_med"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_pinpointer",
		"borg_upgrade_surgicalprocessor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cyborg_upg_combat
	id = "cyborg_upg_combat"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prereq_ids = list(
		"adv_engi",
		"adv_robotics",
		"weaponry",
	)
	design_ids = list("borg_upgrade_vtec")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/cyborg_upg_service
	id = "cyborg_upg_service"
	tech_tier = 3
	display_name = "Cyborg Upgrades: Service"
	description = "Allows service borgs to specialize with various modules."
	prereq_ids = list("cyborg_upg_util")
	design_ids = list(
		"borg_upgrade_botany",
		"borg_upgrade_casino",
		"borg_upgrade_kitchen",
		"borg_upgrade_party",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	tech_tier = 4
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list(
		"c38_trac",
		"implant_chem",
		"implant_tracking",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	tech_tier = 4
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"cybernetic_heart",
		"cybernetic_liver",
		"cybernetic_lungs",
		"cybernetic_stomach",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	tech_tier = 5
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("cyber_organs")
	design_ids = list(
		"cybernetic_heart_u",
		"cybernetic_liver_u",
		"cybernetic_lungs_u",
		"cybernetic_stomach_u",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/ipc_organs
	id = "ipc_organs"
	tech_tier = 3
	display_name = "IPC Parts"
	description = "We have the technology to replace him."
	prereq_ids = list(
		"cyber_organs",
		"robotics",
	)
	design_ids = list(
		"power_cord",
		"robotic_ears",
		"robotic_eyes",
		"robotic_heart",
		"robotic_liver",
		"robotic_stomach",
		"robotic_tongue",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	tech_tier = 4
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list(
		"adv_biotech",
		"datatheory",
	)
	design_ids = list(
		"ci-breather",
		"ci-diaghud",
		"ci-gloweyes",
		"ci-medhud",
		"ci-nutriment",
		"ci-sechud",
		"ci-welding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	tech_tier = 5
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list(
		"cyber_implants",
		"integrated_HUDs",
		"neural_programming",
	)
	design_ids = list(
		"ci-botany",
		"ci-janitor",
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-surgery",
		"ci-toolset",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	tech_tier = 5
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list(
		"adv_cyber_implants",
		"high_efficiency",
		"NVGtech",
		"weaponry",
	)
	design_ids = list(
		"ci-antidrop",
		"ci-antistun",
		"ci-thermals",
		"ci-thrusters",
		"ci-xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/adv_combat_cyber_implants
	id = "adv_combat_cyber_implants"
	tech_tier = 5
	display_name = "Advanced Combat Cybernetic Implants"
	description = "Experimental military cybernetic weapons."
	prereq_ids = list(
		"adv_cyber_implants",
		"syndicate_basic",
	)
	design_ids = list("hydraulic_blade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	hidden = TRUE

/datum/techweb_node/linkedsurgery_implant
	id = "linkedsurgery_implant"
	tech_tier = 5
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	prereq_ids = list(
		"exp_surgery",
		"micro_bluespace",
	)
	design_ids = list("ci-linkedsurgery")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	hidden = TRUE
