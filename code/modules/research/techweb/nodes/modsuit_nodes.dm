/datum/techweb_node/mod_basic
	id = "mod"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Basic Modular Suits"
	description = "Specialized back mounted power suits with various different modules."
	design_ids = list(
		"mod_boots",
		"mod_chestplate",
		"mod_gauntlets",
		"mod_helmet",
		"mod_paint_kit",
		"mod_shell",
		"mod_plating_standard",
		"mod_plating_civilian",
		"mod_storage",
		"mod_welding",
		"mod_mouthhole",
		"mod_flashlight",
		"mod_longfall",
		"mod_thermal_regulator",
		"mod_plasma",
	)

/datum/techweb_node/mod_advanced
	id = "mod_advanced"
	tech_tier = 2
	display_name = "Advanced Modular Suits"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list("robotics")
	design_ids = list(
		"mod_visor_diaghud",
		"mod_gps",
		"mod_reagent_scanner",
		"mod_clamp",
		"mod_drill",
		"mod_orebag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_engineering
	id = "mod_engineering"
	tech_tier = 2
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list("mod_advanced", "engineering")
	design_ids = list(
		"mod_plating_engineering",
		"mod_visor_meson",
		"mod_t_ray",
		"mod_magboot",
		"mod_tether",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_advanced_engineering
	id = "mod_advanced_engineering"
	tech_tier = 4
	display_name = "Advanced Engineering Modular Suits"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list("mod_engineering", "adv_engi")
	design_ids = list(
		"mod_plating_atmospheric",
		"mod_jetpack",
		"mod_rad_protection",
		"mod_emp_shield",
		"mod_storage_expanded",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)

/datum/techweb_node/mod_medical
	id = "mod_medical"
	tech_tier = 3
	display_name = "Medical Modular Suits"
	description = "Medical suits for quick rescue purposes."
	prereq_ids = list("mod_advanced", "biotech")
	design_ids = list(
		"mod_plating_medical",
		"mod_visor_medhud",
		"mod_health_analyzer",
		"mod_quick_carry",
		"mod_injector",
		"mod_organ_thrower",
		"mod_dna_lock",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_advanced_medical
	id = "mod_advanced_medical"
	display_name = "Advanced Medical Modular Suits"
	description = "Advanced medical suits for quicker rescue purposes."
	prereq_ids = list("mod_medical", "adv_biotech")
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)

/datum/techweb_node/mod_security
	id = "mod_security"
	tech_tier = 3
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list("mod_advanced", "sec_basic")
	design_ids = list(
		"mod_plating_security",
		"mod_visor_sechud",
		"mod_stealth",
		"mod_mag_harness",
		"mod_holster",
		"mod_sonar",
		"mod_projectile_dampener",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_entertainment
	id = "mod_entertainment"
	tech_tier = 2
	display_name = "Entertainment Modular Suits"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list("mod_advanced", "clown")
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_anomaly
	id = "mod_anomaly"
	display_name = "Anomalock Modular Suits"
	description = "Modules for modular suits that require anomaly cores to function."
	prereq_ids = list("mod_advanced", "anomaly_research")
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_anomaly_engi
	id = "mod_anomaly_engi"
	display_name = "Engineering Anomalock Modular Suits"
	description = "Advanced modules for modular suits, using anomaly cores to become even better engineers."
	prereq_ids = list("mod_advanced_engineering", "mod_anomaly")
	design_ids = list(
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/mod_experimental
	id = "mod_experimental"
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits has created these..."
	prereq_ids = list("base")
	design_ids = list(
		"mod_disposal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
