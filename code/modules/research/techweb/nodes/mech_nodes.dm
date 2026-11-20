/datum/techweb_node/mech
	tech_tier = 1
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/mech_recharger,
		/datum/design/mecha_tracking,
		/datum/design/board/mechacontrol,
		/datum/design/board/mechapower,
		/datum/design/ripley_chassis,
		/datum/design/ripley_left_arm,
		/datum/design/ripley_left_leg,
		/datum/design/board/ripley_main,
		/datum/design/board/ripley_peri,
		/datum/design/ripley_right_arm,
		/datum/design/ripley_right_leg,
		/datum/design/ripley_torso,
		/datum/design/ripleyupgrade,
		/datum/design/mech_hydraulic_clamp,
		/datum/design/mech_radio,
		/datum/design/mech_air_tank,
		/datum/design/mech_thrusters,
	)

/datum/techweb_node/mech_tools
	tech_tier = 1
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/mech_drill,
		/datum/design/mech_extinguisher,
		/datum/design/mech_mining_scanner,
	)

/datum/techweb_node/adv_mecha
	tech_tier = 3
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prerequisite_nodes = list(/datum/techweb_node/adv_robotics)
	unlocked_designs = list(/datum/design/mech_repair_droid)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_mecha_tools
	tech_tier = 3
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prerequisite_nodes = list(/datum/techweb_node/adv_mecha)
	unlocked_designs = list(
		/datum/design/mech_rcd,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/med_mech_tools
	tech_tier = 3
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech)
	unlocked_designs = list(
		/datum/design/mech_medical_beamgun,
		/datum/design/mech_sleeper,
		/datum/design/mech_syringe_gun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_modules
	tech_tier = 3
	display_name = "Simple Exosuit Modules"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/adv_mecha, /datum/techweb_node/bluespace_power)
	unlocked_designs = list(
		/datum/design/mech_ccw_armor,
		/datum/design/mech_generator_nuclear,
		/datum/design/mech_proj_armor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_scattershot
	tech_tier = 4
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/ballistic_weapons)
	unlocked_designs = list(/datum/design/mech_scattershot, /datum/design/mech_scattershot_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_carbine
	tech_tier = 4
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/ballistic_weapons)
	unlocked_designs = list(/datum/design/mech_carbine, /datum/design/mech_carbine_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_ion
	tech_tier = 4
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/electric_weapons, /datum/techweb_node/emp_adv)
	unlocked_designs = list(/datum/design/mech_ion)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_tesla
	tech_tier = 4
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/electric_weapons, /datum/techweb_node/adv_power)
	unlocked_designs = list(/datum/design/mech_tesla)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_laser
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/beam_weapons)
	unlocked_designs = list(/datum/design/mech_laser)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unhide_from_prereqs = TRUE

/datum/techweb_node/mech_laser_heavy
	tech_tier = 4
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_beam_weapons)
	unlocked_designs = list(/datum/design/mech_laser_heavy)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unhide_from_prereqs = TRUE

/datum/techweb_node/mech_disabler
	tech_tier = 4
	display_name =  "Exosuit Weapon (CH-DS \"Peacemaker\" Mounted Disabler)"
	description = "A basic piece of mech weaponry"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/beam_weapons)
	unlocked_designs = list(/datum/design/mech_disabler)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unhide_from_prereqs = TRUE

/datum/techweb_node/mech_grenade_launcher
	tech_tier = 4
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/explosive_weapons)
	unlocked_designs = list(/datum/design/mech_grenade_launcher, /datum/design/mech_grenade_launcher_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_missile_rack
	display_name = "Exosuit Weapon (BRM-6 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/explosive_weapons)
	unlocked_designs = list(/datum/design/mech_missile_rack, /datum/design/mech_missile_rack_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/clusterbang_launcher
	tech_tier = 4
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/explosive_weapons)
	unlocked_designs = list(/datum/design/clusterbang_launcher, /datum/design/clusterbang_launcher_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_teleporter
	tech_tier = 4
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prerequisite_nodes = list(/datum/techweb_node/micro_bluespace)
	unlocked_designs = list(/datum/design/mech_teleporter)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_wormhole_gen
	tech_tier = 4
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/bluespace_travel)
	unlocked_designs = list(/datum/design/mech_wormhole_gen)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_lmg
	tech_tier = 4
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prerequisite_nodes = list(/datum/techweb_node/ballistic_weapons)
	unlocked_designs = list(/datum/design/mech_lmg, /datum/design/mech_lmg_ammo)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_diamond_drill
	tech_tier = 3
	display_name =  "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prerequisite_nodes = list(/datum/techweb_node/adv_mining)
	unlocked_designs = list(/datum/design/mech_diamond_drill)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/odysseus
	tech_tier = 3
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/odysseus_chassis,
		/datum/design/odysseus_head,
		/datum/design/odysseus_left_arm,
		/datum/design/odysseus_left_leg,
		/datum/design/board/odysseus_main,
		/datum/design/board/odysseus_peri,
		/datum/design/odysseus_right_arm,
		/datum/design/odysseus_right_leg,
		/datum/design/odysseus_torso,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/clarke
	tech_tier = 2
	display_name = "EXOSUIT: Clarke"
	description = "Clarke exosuit designs"
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/clarke_chassis,
		/datum/design/clarke_torso,
		/datum/design/clarke_head,
		/datum/design/clarke_left_arm,
		/datum/design/clarke_right_arm,
		/datum/design/board/clarke_main,
		/datum/design/board/clarke_peri
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/gygax
	tech_tier = 4
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prerequisite_nodes = list(/datum/techweb_node/adv_mecha, /datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/gygax_armor,
		/datum/design/gygax_chassis,
		/datum/design/gygax_head,
		/datum/design/gygax_left_arm,
		/datum/design/gygax_left_leg,
		/datum/design/board/gygax_main,
		/datum/design/board/gygax_peri,
		/datum/design/gygax_right_arm,
		/datum/design/gygax_right_leg,
		/datum/design/board/gygax_targ,
		/datum/design/gygax_torso,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/durand
	tech_tier = 4
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prerequisite_nodes = list(/datum/techweb_node/adv_mecha, /datum/techweb_node/adv_weaponry)
	unlocked_designs = list(
		/datum/design/durand_armor,
		/datum/design/durand_chassis,
		/datum/design/durand_head,
		/datum/design/durand_left_arm,
		/datum/design/durand_left_leg,
		/datum/design/board/durand_main,
		/datum/design/board/durand_peri,
		/datum/design/durand_right_arm,
		/datum/design/durand_right_leg,
		/datum/design/board/durand_targ,
		/datum/design/durand_torso,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/phazon
	tech_tier = 5
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_mecha, /datum/techweb_node/micro_bluespace, /datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/phazon_chassis,
		/datum/design/phazon_torso,
		/datum/design/phazon_head,
		/datum/design/phazon_left_arm,
		/datum/design/phazon_right_arm,
		/datum/design/phazon_left_leg,
		/datum/design/phazon_right_leg,
		/datum/design/board/phazon_main,
		/datum/design/board/phazon_peri,
		/datum/design/board/phazon_targ,
		/datum/design/phazon_armor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
