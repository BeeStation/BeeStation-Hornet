/datum/techweb_node/mech
	id = TECHWEB_NODE_MECHA
	tech_tier = 1
	starting_node = TRUE
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	design_ids = list(
		"mech_hydraulic_clamp",
		"mech_recharger",
		"mecha_tracking",
		"mechacontrol",
		"mechapower",
		"ripley_chassis",
		"ripley_left_arm",
		"ripley_left_leg",
		"ripley_main",
		"ripley_peri",
		"ripley_right_arm",
		"ripley_right_leg",
		"ripley_torso",
		"ripleyupgrade",
	)

/datum/techweb_node/mech_tools
	id = TECHWEB_NODE_MECH_TOOLS
	tech_tier = 1
	starting_node = TRUE
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	design_ids = list(
		"mech_drill",
		"mech_extinguisher",
		"mech_mscanner",
	)

/datum/techweb_node/adv_mecha
	id = TECHWEB_NODE_ADV_MECHA
	tech_tier = 3
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prereq_ids = list(TECHWEB_NODE_ADV_ROBOTICS)
	design_ids = list("mech_repair_droid")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_mecha_tools
	id = TECHWEB_NODE_ADV_MECHA_TOOLS
	tech_tier = 3
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list(TECHWEB_NODE_ADV_MECHA)
	design_ids = list(
		"mech_rcd",
		"mech_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/med_mech_tools
	id = TECHWEB_NODE_MED_MECH_TOOLS
	tech_tier = 3
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list(
		"mech_medi_beam",
		"mech_sleeper",
		"mech_syringe_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_modules
	id = TECHWEB_NODE_ADV_MECHA_MODULES
	tech_tier = 3
	display_name = "Simple Exosuit Modules"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_ADV_MECHA, TECHWEB_NODE_BLUESPACE_POWER)
	design_ids = list(
		"mech_ccw_armor",
		"mech_energy_relay",
		"mech_generator_nuclear",
		"mech_proj_armor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_scattershot
	id = TECHWEB_NODE_MECHA_TOOLS
	tech_tier = 4
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BALLISTIC_WEAPONS)
	design_ids = list("mech_scattershot", "mech_scattershot_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_carbine
	id = TECHWEB_NODE_MECH_CARBINE
	tech_tier = 4
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BALLISTIC_WEAPONS)
	design_ids = list("mech_carbine", "mech_carbine_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_ion
	id = TECHWEB_NODE_MMECH_ION
	tech_tier = 4
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_ELECTRONIC_WEAPONS, TECHWEB_NODE_EMP_ADV)
	design_ids = list("mech_ion")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_tesla
	id = TECHWEB_NODE_MECH_TESLA
	tech_tier = 4
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_ELECTRONIC_WEAPONS, TECHWEB_NODE_ADV_POWER)
	design_ids = list("mech_tesla")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_laser
	id = TECHWEB_NODE_MECH_LASER
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BEAM_WEAPONS)
	design_ids = list("mech_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_laser_heavy
	id = TECHWEB_NODE_MECH_LASER_HEAVY
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_ADV_BEAM_WEAPONS)
	design_ids = list("mech_laser_heavy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_disabler
	id = TECHWEB_NODE_MECH_DISABLER
	tech_tier = 4
	display_name =  "Exosuit Weapon (CH-DS \"Peacemaker\" Mounted Disabler)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BEAM_WEAPONS)
	design_ids = list("mech_disabler")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_grenade_launcher
	id = TECHWEB_NODE_MECH_GRENADE_LAUNCHER
	tech_tier = 4
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_EXPLOSIVE_WEAPONS)
	design_ids = list("mech_grenade_launcher", "mech_grenade_launcher_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_missile_rack
	id = TECHWEB_NODE_MECH_MISSILE_RACK
	display_name = "Exosuit Weapon (BRM-6 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_EXPLOSIVE_WEAPONS)
	design_ids = list("mech_missile_rack", "mech_missile_rack_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/clusterbang_launcher
	id = TECHWEB_NODE_CLUSTERBANG_LAUNCHER
	tech_tier = 4
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_EXPLOSIVE_WEAPONS)
	design_ids = list("clusterbang_launcher", "clusterbang_launcher_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_teleporter
	id = TECHWEB_NODE_MECH_TELEPORTER
	tech_tier = 4
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list(TECHWEB_NODE_MICRO_BLUESPACE)
	design_ids = list("mech_teleporter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_wormhole_gen
	id = TECHWEB_NODE_MECH_WORMHOLE_GEN
	tech_tier = 4
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BLUESPACE_TRAVEL)
	design_ids = list("mech_wormhole_gen")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_lmg
	id = TECHWEB_NODE_MECH_LMG
	tech_tier = 4
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list(TECHWEB_NODE_BALLISTIC_WEAPONS)
	design_ids = list("mech_lmg", "mech_lmg_ammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_diamond_drill
	id = TECHWEB_NODE_MECH_DIAMOND_DRILL
	tech_tier = 3
	display_name =  "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list(TECHWEB_NODE_ADV_MINING)
	design_ids = list("mech_diamond_drill")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/odysseus
	id = TECHWEB_NODE_MECHA_ODYSSEUS
	tech_tier = 3
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list(TECHWEB_NODE_BASE)
	design_ids = list(
		"odysseus_chassis",
		"odysseus_head",
		"odysseus_left_arm",
		"odysseus_left_leg",
		"odysseus_main",
		"odysseus_peri",
		"odysseus_right_arm",
		"odysseus_right_leg",
		"odysseus_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/clarke
	id = TECHWEB_NODE_MECHA_CLARKE
	tech_tier = 2
	display_name = "EXOSUIT: Clarke"
	description = "Clarke exosuit designs"
	prereq_ids = list(TECHWEB_NODE_ENGINEERING)
	design_ids = list(
		"clarke_chassis",
		"clarke_torso",
		"clarke_head",
		"clarke_left_arm",
		"clarke_right_arm",
		"clarke_main",
		"clarke_peri"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/gygax
	id = TECHWEB_NODE_MECH_GYGAX
	tech_tier = 4
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list(TECHWEB_NODE_ADV_MECHA, TECHWEB_NODE_WEAPONRY)
	design_ids = list(
		"gygax_armor",
		"gygax_chassis",
		"gygax_head",
		"gygax_left_arm",
		"gygax_left_leg",
		"gygax_main",
		"gygax_peri",
		"gygax_right_arm",
		"gygax_right_leg",
		"gygax_targ",
		"gygax_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/durand
	id = TECHWEB_NODE_MECH_DURAND
	tech_tier = 4
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list(TECHWEB_NODE_ADV_MECHA, TECHWEB_NODE_ADV_WEAPONRY)
	design_ids = list(
		"durand_armor",
		"durand_chassis",
		"durand_head",
		"durand_left_arm",
		"durand_left_leg",
		"durand_main",
		"durand_peri",
		"durand_right_arm",
		"durand_right_leg",
		"durand_targ",
		"durand_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/phazon
	id = TECHWEB_NODE_MECHA_PHAZON
	tech_tier = 5
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list(TECHWEB_NODE_ADV_MECHA, TECHWEB_NODE_MICRO_BLUESPACE, TECHWEB_NODE_WEAPONRY)
	design_ids = list(
		"phazon_chassis",
		"phazon_torso",
		"phazon_head",
		"phazon_left_arm",
		"phazon_right_arm",
		"phazon_left_leg",
		"phazon_right_leg",
		"phazon_main",
		"phazon_peri",
		"phazon_targ",
		"phazon_armor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
