/datum/techweb_node/mod_basic
	tech_tier = 1
	display_name = "Basic Modular Suits"
	description = "Specialized back mounted power suits with various different modules."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/mod_boots,
		/datum/design/mod_chestplate,
		/datum/design/mod_gauntlets,
		/datum/design/mod_helmet,
		/datum/design/mod_paint_kit,
		/datum/design/mod_shell,
		/datum/design/mod_plating,
		/datum/design/mod_plating/civilian,
		/datum/design/module/mod_storage,
		/datum/design/module/mod_visor_welding,
		/datum/design/module/mod_mouthhole,
		/datum/design/module/mod_flashlight,
		/datum/design/module/mod_longfall,
		/datum/design/module/mod_thermal_regulator,
		/datum/design/module/mod_plasma_stabilizer,
	)

/datum/techweb_node/mod_advanced
	tech_tier = 2
	display_name = "Advanced Modular Suits"
	description = "More advanced modules, to improve modular suits."
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/module/mod_visor_diaghud,
		/datum/design/modlink_scryer,
		/datum/design/module/mod_gps,
		/datum/design/module/mod_reagent_scanner,
		/datum/design/module/mod_clamp,
		/datum/design/module/mod_drill,
		/datum/design/module/mod_orebag,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mod_engineering
	tech_tier = 2
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prerequisite_nodes = list(/datum/techweb_node/mod_advanced, /datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/mod_plating/engineering,
		/datum/design/module/mod_visor_meson,
		/datum/design/module/mod_t_ray,
		/datum/design/module/mod_magboot,
		/datum/design/module/mod_tether,
		/datum/design/module/mod_constructor,
		/datum/design/module/mister_atmos,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/mod_advanced_engineering
	tech_tier = 4
	display_name = "Advanced Engineering Modular Suits"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prerequisite_nodes = list(/datum/techweb_node/mod_engineering, /datum/techweb_node/adv_engi)
	unlocked_designs = list(
		/datum/design/mod_plating/atmospheric,
		/datum/design/module/mod_jetpack,
		/datum/design/module/mod_rad_protection,
		/datum/design/module/mod_emp_shield,
		/datum/design/module/mod_storage_expanded,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/mod_medical
	tech_tier = 3
	display_name = "Medical Modular Suits"
	description = "Medical suits for quick rescue purposes."
	prerequisite_nodes = list(/datum/techweb_node/mod_advanced, /datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/mod_plating/medical,
		/datum/design/module/mod_visor_medhud,
		/datum/design/module/mod_health_analyzer,
		/datum/design/module/mod_quick_carry,
		/datum/design/module/mod_injector,
		/datum/design/module/mod_organ_thrower,
		/datum/design/module/mod_dna_lock,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/mod_advanced_medical
	display_name = "Advanced Medical Modular Suits"
	description = "Advanced medical suits for quicker rescue purposes."
	prerequisite_nodes = list(/datum/techweb_node/mod_medical, /datum/techweb_node/adv_biotech)
	unlocked_designs = list(
		/datum/design/module/defibrillator,
		/datum/design/module/threadripper,
		/datum/design/module/surgicalprocessor,
		/datum/design/module/statusreadout,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/mod_security
	tech_tier = 3
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prerequisite_nodes = list(/datum/techweb_node/mod_advanced, /datum/techweb_node/sec_basic)
	unlocked_designs = list(
		/datum/design/mod_plating/security,
		/datum/design/module/mod_visor_sechud,
		/datum/design/module/mod_stealth,
		/datum/design/module/mod_mag_harness,
		/datum/design/module/mod_holster,
		/datum/design/module/mod_sonar,
		/datum/design/module/projectile_dampener,
		/datum/design/module/mod_reinforced_plating,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/mod_entertainment
	tech_tier = 2
	display_name = "Entertainment Modular Suits"
	description = "Powered suits for protection against low-humor environments."
	prerequisite_nodes = list(/datum/techweb_node/mod_advanced, /datum/techweb_node/clown)
	unlocked_designs = list(
		/datum/design/mod_plating/cosmohonk,
		/datum/design/module/mod_bikehorn,
		/datum/design/module/mod_microwave_beam,
		/datum/design/module/mod_waddle,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SERVICE)

/datum/techweb_node/mod_anomaly
	display_name = "Anomalock Modular Suits"
	description = "Modules for modular suits that require anomaly cores to function."
	prerequisite_nodes = list(/datum/techweb_node/mod_advanced, /datum/techweb_node/anomaly)
	unlocked_designs = list(
		/datum/design/module/mod_antigrav,
		/datum/design/module/mod_teleporter,
		/datum/design/module/mod_kinesis,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mod_experimental
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits has created these..."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/module/disposal,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
