/datum/techweb_node/base
	tech_tier = 0
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/basic_capacitor,
		/datum/design/basic_cell,
		/datum/design/basic_matter_bin,
		/datum/design/basic_micro_laser,
		/datum/design/basic_scanning,
		/datum/design/beaker,
		/datum/design/bucket,
		/datum/design/board/circuit_imprinter,
		/datum/design/conveyor_belt,
		/datum/design/conveyor_switch,
		/datum/design/dest_tagger,
		/datum/design/board/destructive_analyzer,
		/datum/design/duct_tape,
		/datum/design/paper_reader,
		/datum/design/board/fax,
		/datum/design/glasses_prescription,
		/datum/design/handlabeler,
		/datum/design/large_beaker,
		/datum/design/larryframe,
		/datum/design/light_replacer,
		/datum/design/board/mechfab,
		/datum/design/micro_mani,
		/datum/design/oven_tray,
		/datum/design/package_wrap,
		/datum/design/board/paystand,
		/datum/design/plaglass_alloy,
		/datum/design/plasmarglass_alloy,
		/datum/design/plasteel_alloy,
		/datum/design/plastitanium_alloy,
		/datum/design/plastitaniumglass_alloy,
		/datum/design/plumbing_rcd,
		/datum/design/board/portable_thermomachine,
		/datum/design/board/rdconsole,
		/datum/design/board/rdserver,
		/datum/design/board/rdservercontrol,
		/datum/design/rglass,
		/datum/design/salestagger,
		/datum/design/c38/sec,
		/datum/design/c38b/sec,
		/datum/design/beanbag_slug/sec,
		/datum/design/breaching_slug/sec,
		/datum/design/buckshot_shell/sec,
		/datum/design/buckshot_armour_shell/sec,
		/datum/design/shotgun_dart/sec,
		/datum/design/incendiary_slug/sec,
		/datum/design/rubbershot/sec,
		/datum/design/shotgun_slug/sec,
		/datum/design/tech_disk,
		/datum/design/titaniumglass_alloy,
		/datum/design/xenoartifact_labeller,
		/datum/design/xlarge_beaker,
	)

/datum/techweb_node/basic_tools
	tech_tier = 0
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/airlock_painter,
		/datum/design/analyzer,
		/datum/design/blood_filter,
		/datum/design/cable_coil,
		/datum/design/cautery,
		/datum/design/circular_saw,
		/datum/design/crowbar,
		/datum/design/cultivator,
		/datum/design/airlock_painter/decal,
		/datum/design/discoveryscanner,
		/datum/design/dropper,
		/datum/design/hatchet,
		/datum/design/hemostat,
		/datum/design/mop,
		/datum/design/multitool,
		/datum/design/pipe_painter,
		/datum/design/plant_analyzer,
		/datum/design/retractor,
		/datum/design/scalpel,
		/datum/design/screwdriver,
		/datum/design/shovel,
		/datum/design/spade,
		/datum/design/stethoscope,
		/datum/design/surgical_drapes,
		/datum/design/surgicaldrill,
		/datum/design/syringe,
		/datum/design/airlock_painter/decal/tile,
		/datum/design/tscanner,
		/datum/design/welding_helmet,
		/datum/design/weldingtool,
		/datum/design/wirebrush,
		/datum/design/wirecutters,
		/datum/design/wrench,
	)

/datum/techweb_node/engineering
	tech_tier = 1
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/adv_capacitor,
		/datum/design/adv_matter_bin,
		/datum/design/adv_scanning,
		/datum/design/airalarm_electronics,
		/datum/design/airlock_board,
		/datum/design/board/apc_control,
		/datum/design/board/atmos_control,
		/datum/design/board/atmosalerts,
		/datum/design/board/autolathe,
		/datum/design/board/cell_charger,
		/datum/design/emergency_oxygen_engi,
		/datum/design/emergency_oxygen,
		/datum/design/board/emitter,
		/datum/design/firealarm_electronics,
		/datum/design/firelock_board,
		/datum/design/board/grounding_rod,
		/datum/design/high_cell,
		/datum/design/high_micro_laser,
		/datum/design/board/igniter,
		/datum/design/board/mass_driver,
		/datum/design/mesons,
		/datum/design/nano_mani,
		/datum/design/oxygen_tank,
		/datum/design/board/pacman,
		/datum/design/plasma_tank,
		/datum/design/plasmaman_tank_belt,
		/datum/design/plasmaman_tank,
		/datum/design/apc_board,
		/datum/design/board/powermonitor,
		/datum/design/board/recharger,
		/datum/design/board/recycler,
		/datum/design/researchdisklocator,
		/datum/design/rped,
		/datum/design/board/scanner_gate,
		/datum/design/board/shieldwallgen,
		/datum/design/board/shieldwallgen/atmos,
		/datum/design/board/solarcontrol,
		/datum/design/board/stacking_unit_console,
		/datum/design/board/stacking_machine,
		/datum/design/board/suit_storage_unit,
		/datum/design/board/tesla_coil,
		/datum/design/board/thermomachine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/adv_engi
	tech_tier = 2
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prerequisite_nodes = list(/datum/techweb_node/emp_basic, /datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/engine_goggles,
		/datum/design/magboots,
		/datum/design/ranged_analyzer,
		/datum/design/rcd_loaded,
		/datum/design/rpd,
		/datum/design/welding_mask,
		/datum/design/board/sheetifier,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/high_efficiency
	tech_tier = 3
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prerequisite_nodes = list(/datum/techweb_node/datatheory, /datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/pico_mani,
		/datum/design/super_matter_bin,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/adv_power
	tech_tier = 3
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/hyper_cell,
		/datum/design/board/pacman/mrs,
		/datum/design/board/power_compressor,
		/datum/design/board/turbine_computer,
		/datum/design/board/power_turbine,
		/datum/design/board/smes,
		/datum/design/super_capacitor,
		/datum/design/super_cell,
		/datum/design/board/pacman/super,
		/datum/design/board/cdr,
		/datum/design/board/graviton_target
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/bluespace_power
	tech_tier = 4
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prerequisite_nodes = list(/datum/techweb_node/adv_power, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/bluespace_cell,
		/datum/design/quadratic_capacitor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/micro_bluespace
	tech_tier = 5
	display_name = "Miniaturized Bluespace Research"
	description = "Extreme reduction in space required for bluespace engines, leading to portable bluespace technology."
	prerequisite_nodes = list(/datum/techweb_node/bluespace_travel, /datum/techweb_node/high_efficiency, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/bluespace_matter_bin,
		/datum/design/femto_mani,
		/datum/design/quantum_keycard,
		/datum/design/triphasic_scanning,
		/datum/design/wireless_usb,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/basic_shuttle_tech
	tech_tier = 3
	display_name = "Basic Shuttle Research"
	description = "Research the technology required to create and use basic shuttles."
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/basic_plasma)
	unlocked_designs = list(
		/datum/design/board/shuttle_heater_engine,
		/datum/design/board/shuttle_plasma_engine,
		/datum/design/board/shuttle_flight_control,
		/datum/design/shuttlecreator,
		/datum/design/wingpack,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/emp_basic //EMP tech for some reason
	tech_tier = 2
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/board/holopad,
		/datum/design/holosign,
		/datum/design/holosignatmos,
		/datum/design/holosignengi,
		/datum/design/holosignsec,
		/datum/design/inducer,
		/datum/design/inducer/sci,
		/datum/design/tray_goggles,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/emp_adv
	tech_tier = 3
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prerequisite_nodes = list(/datum/techweb_node/emp_basic)
	unlocked_designs = list(/datum/design/ultra_micro_laser)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/emp_super
	tech_tier = 4
	display_name = "Quantum Electromagnetic Technology"
	description = "Even better electromagnetic technology."
	prerequisite_nodes = list(/datum/techweb_node/emp_adv)
	unlocked_designs = list(/datum/design/quadultra_micro_laser)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/telecomms
	tech_tier = 3
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prerequisite_nodes = list(/datum/techweb_node/bluespace_theory, /datum/techweb_node/comptech)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	unlocked_designs = list(
		/datum/design/board/comm_monitor,
		/datum/design/board/comm_server,
		/datum/design/board/ntnet_relay,
		/datum/design/subspace_amplifier,
		/datum/design/subspace_analyzer,
		/datum/design/subspace_ansible,
		/datum/design/board/subspace_broadcaster,
		/datum/design/board/telecomms_bus,
		/datum/design/subspace_crystal,
		/datum/design/hyperwave_filter,
		/datum/design/board/telecomms_hub,
		/datum/design/board/telecomms_messaging,
		/datum/design/board/telecomms_processor,
		/datum/design/board/subspace_receiver,
		/datum/design/board/telecomms_relay,
		/datum/design/board/telecomms_server,
		/datum/design/subspace_transmitter,
		/datum/design/subspace_treatment,
	)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/comp_recordkeeping
	tech_tier = 2
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prerequisite_nodes = list(/datum/techweb_node/comptech)
	unlocked_designs = list(
		/datum/design/board/announcement_system,
		/datum/design/board/records/medical,
		/datum/design/board/prisonmanage,
		/datum/design/board/secdata,
		/datum/design/board/vendor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/integrated_huds
	tech_tier = 3
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prerequisite_nodes = list(/datum/techweb_node/comp_recordkeeping, /datum/techweb_node/emp_basic)
	unlocked_designs = list(
		/datum/design/diagnostic_hud,
		/datum/design/health_hud,
		/datum/design/sci_goggles,
		/datum/design/security_hud,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/NVGtech
	tech_tier = 3
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prerequisite_nodes = list(
		/datum/techweb_node/adv_engi,
		/datum/techweb_node/emp_adv,
		/datum/techweb_node/integrated_huds,
	)
	unlocked_designs = list(
		/datum/design/diagnostic_hud_night,
		/datum/design/health_hud_night,
		/datum/design/night_vision_goggles,
		/datum/design/nvgmesons,
		/datum/design/security_hud_night,
		/datum/design/scigoggles_night,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/exp_tools
	tech_tier = 3
	display_name = "Experimental Tools"
	description = "Highly advanced tools."
	unlocked_designs = list(
		/datum/design/exwelder,
		/datum/design/handdrill,
		/datum/design/jawsoflife,
		/datum/design/laserscalpel,
		/datum/design/mechanicalpinches,
		/datum/design/searingtool,
		/datum/design/wirebrush_adv,
	)
	prerequisite_nodes = list(/datum/techweb_node/adv_engi)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/rcd_upgrade
	tech_tier = 3
	display_name = "Rapid Device Upgrade Designs"
	description = "Unlocks new designs that improve rapid devices."
	unlocked_designs = list(
		/datum/design/rcd_upgrade/frames,
		/datum/design/rcd_upgrade/furnishing,
		/datum/design/rcd_upgrade/simple_circuits,
		/datum/design/rpd_upgrade/unwrench
	)
	prerequisite_nodes = list(/datum/techweb_node/adv_engi)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/adv_rcd_upgrade
	tech_tier = 4
	display_name = "Advanced RCD Designs Upgrade"
	description = "Unlocks new RCD designs."
	unlocked_designs = list(
		/datum/design/rcd_upgrade/silo_link
	)
	prerequisite_nodes = list(/datum/techweb_node/applied_bluespace, /datum/techweb_node/rcd_upgrade)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)
