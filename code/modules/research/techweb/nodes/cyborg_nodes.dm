/datum/techweb_node/mmi
	id = TECHWEB_NODE_MMI
	tech_tier = 1
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	design_ids = list(
		"mmi",
	)

/datum/techweb_node/cyborg
	id = TECHWEB_NODE_CYBORG
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
	id = TECHWEB_NODE_CYBORG_UPG_UTIL
	tech_tier = 3
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cyborgs."
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"borg_upgrade_circuitapp",
		"borg_upgrade_expand",
		"borg_upgrade_holding",
		"borg_upgrade_lavaproof",
		"borg_upgrade_rped",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_med
	id = TECHWEB_NODE_CYBORG_UPG_MED
	tech_tier = 3
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list(
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_pinpointer",
		"borg_upgrade_surgicalprocessor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_combat
	id = TECHWEB_NODE_CYBORG_UPG_COMBAT
	tech_tier = 3
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_ADV_ROBOTICS, TECHWEB_NODE_WEAPONRY)
	design_ids = list("borg_upgrade_vtec")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upg_service
	id = TECHWEB_NODE_CYBORG_UPG_SERVICE
	tech_tier = 3
	display_name = "Cyborg Upgrades: Service"
	description = "Allows service borgs to specialize with various modules."
	prereq_ids = list(TECHWEB_NODE_CYBORG_UPG_UTIL)
	design_ids = list(
		"borg_upgrade_botany",
		"borg_upgrade_casino",
		"borg_upgrade_kitchen",
		"borg_upgrade_party",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/subdermal_implants
	id = TECHWEB_NODE_SUBDERMAL_IMPLANTS
	tech_tier = 4
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list(TECHWEB_NODE_BIOTECH)
	design_ids = list(
		"c38_trac",
		"implant_chem",
		"implant_tracking",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/cyber_organs
	id = TECHWEB_NODE_CYBER_ORGANS
	tech_tier = 4
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list(
		"cybernetic_heart",
		"cybernetic_liver",
		"cybernetic_lungs",
		"cybernetic_stomach",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber_organs_upgraded
	id = TECHWEB_NODE_CYBER_ORGANS_UPGRADED
	tech_tier = 5
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list(TECHWEB_NODE_CYBER_ORGANS)
	design_ids = list(
		"cybernetic_heart_u",
		"cybernetic_liver_u",
		"cybernetic_lungs_u",
		"cybernetic_stomach_u",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/ipc_organs
	id = TECHWEB_NODE_IPC_ORGANS
	tech_tier = 3
	display_name = "IPC Parts"
	description = "We have the technology to replace him."
	prereq_ids = list(TECHWEB_NODE_CYBER_ORGANS, TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"power_cord",
		"robotic_ears",
		"robotic_eyes",
		"robotic_heart",
		"robotic_liver",
		"robotic_stomach",
		"robotic_tongue",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyber_implants
	id = TECHWEB_NODE_CYBER_IMPLANTS
	tech_tier = 4
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH, TECHWEB_NODE_DATATHEORY)
	design_ids = list(
		"ci-breather",
		"ci-diaghud",
		"ci-gloweyes",
		"ci-medhud",
		"ci-nutriment",
		"ci-sechud",
		"ci-welding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_cyber_implants
	id = TECHWEB_NODE_ADV_CYBER_IMPLANTS
	tech_tier = 5
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list(TECHWEB_NODE_CYBER_IMPLANTS, TECHWEB_NODE_INTEGRATED_HUDS, TECHWEB_NODE_NEURAL_PROGRAMMING)
	design_ids = list(
		"ci-botany",
		"ci-janitor",
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-surgery",
		"ci-toolset",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/combat_cyber_implants
	id = TECHWEB_NODE_COMBAT_CYBER_IMPLANTS
	tech_tier = 5
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list(TECHWEB_NODE_ADV_CYBER_IMPLANTS, TECHWEB_NODE_HIGH_EFFICIENCY, TECHWEB_NODE_NVGTECH, TECHWEB_NODE_WEAPONRY)
	design_ids = list(
		"ci-antidrop",
		"ci-antistun",
		"ci-thermals",
		"ci-thrusters",
		"ci-xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_combat_cyber_implants
	id = TECHWEB_NODE_ADV_COMBAT_CYBER_IMPLANTS
	tech_tier = 5
	display_name = "Advanced Combat Cybernetic Implants"
	description = "Experimental military cybernetic weapons."
	prereq_ids = list(TECHWEB_NODE_ADV_CYBER_IMPLANTS, TECHWEB_NODE_SYNDICATE_BASIC)
	design_ids = list("hydraulic_blade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/linkedsurgery_implant
	id = TECHWEB_NODE_LINKEDSURGERY_IMPLANT
	tech_tier = 5
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	prereq_ids = list(TECHWEB_NODE_EXP_SURGERY, TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("ci-linkedsurgery")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
