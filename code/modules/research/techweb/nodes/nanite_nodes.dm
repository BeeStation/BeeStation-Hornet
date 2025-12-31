/datum/techweb_node/nanite_base
	id = TECHWEB_NODE_NANITE_BASE
	tech_tier = 2
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	prereq_ids = list(TECHWEB_NODE_DATATHEORY)
	design_ids = list(
		"access_nanites",
		"monitoring_nanites",
		"nanite_chamber_control",
		"nanite_chamber",
		"nanite_cloud_control",
		"nanite_disk",
		"nanite_program_hub",
		"nanite_programmer",
		"nanite_remote",
		"nanite_comm_remote",
		"nanite_scanner",
		"public_nanite_chamber",
		"red_diag_nanites",
		"relay_nanites",
		"relay_repeater_nanites",
		"repairing_nanites",
		"repeater_nanites",
		"research_nanites",
		"researchplus_nanites",
		"sensor_nanite_volume",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_smart
	id = TECHWEB_NODE_NANITE_SMART
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list(TECHWEB_NODE_NANITE_BASE, TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"memleak_nanites",
		"metabolic_nanites",
		"purging_nanites",
		"sensor_voice_nanites",
		"stealth_nanites",
		"voice_nanites",
		"sensor_receiver_nanites",
		"remote_signal_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_mesh
	id = TECHWEB_NODE_NANITE_MESH
	tech_tier = 2
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prereq_ids = list(TECHWEB_NODE_ENGINEERING, TECHWEB_NODE_NANITE_BASE)
	design_ids = list(
		"conductive_nanites",
		"cryo_nanites",
		"dermal_button_nanites",
		"emp_nanites",
		"hardening_nanites",
		"refractive_nanites",
		"shock_nanites",
		"temperature_nanites",
		"dermal_toggle_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_bio
	id = TECHWEB_NODE_NANITE_BIO
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list(TECHWEB_NODE_BIOTECH, TECHWEB_NODE_NANITE_BASE)
	design_ids = list(
		"bloodheal_nanites",
		"coagulating_nanites",
		"flesheating_nanites",
		"poison_nanites",
		"regenerative_nanites",
		"sensor_crit_nanites",
		"sensor_damage_nanites",
		"sensor_death_nanites",
		"sensor_health_nanites",
		"sensor_nutrition_nanites",
		"sensor_blood_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_neural
	id = TECHWEB_NODE_NANITE_NEURAL
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list(TECHWEB_NODE_NANITE_BIO)
	design_ids = list(
		"bad_mood_nanites",
		"brainheal_nanites",
		"good_mood_nanites",
		"nervous_nanites",
		"paralyzing_nanites",
		"selfscan_nanites",
		"stun_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_synaptic
	id = TECHWEB_NODE_NANITE_SYNAPTIC
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list(TECHWEB_NODE_NANITE_NEURAL, TECHWEB_NODE_NEURAL_PROGRAMMING)
	design_ids = list(
		"blinding_nanites",
		"hallucination_nanites",
		"mute_nanites",
		"pacifying_nanites",
		"sleep_nanites",
		"speech_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_cc
	id = TECHWEB_NODE_NANITE_CC
	tech_tier = 5
	display_name = "Classified Nanites"
	description = "Highly confidential nanite programs from CC. Report usage to your nearest administraitor."
	prereq_ids = list(TECHWEB_NODE_NANITE_NEURAL, TECHWEB_NODE_NEURAL_PROGRAMMING)
	design_ids = list(
		"mindshield_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_2_POINTS)
	hidden = TRUE
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_harmonic
	id = TECHWEB_NODE_NANITE_HARMONIC
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology. Passively increases nanite regeneration rate for all clouds upon researching."
	prereq_ids = list(TECHWEB_NODE_NANITE_BIO, TECHWEB_NODE_NANITE_MESH, TECHWEB_NODE_NANITE_SMART)
	design_ids = list(
		"adrenaline_nanites",
		"aggressive_nanites",
		"brainheal_plus_nanites",
		"defib_nanites",
		"fakedeath_nanites",
		"purging_plus_nanites",
		"regenerative_plus_nanites",
		"sensor_species_nanites",
		"vampire_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_replication_protocols
	id = TECHWEB_NODE_NANITE_REPLICATION_PROTOCOLS
	tech_tier = 4
	display_name = "Nanite Replication Protocols"
	description = "Protocols that overwrite the default nanite replication routine to achieve more efficiency in certain circumstances."
	prereq_ids = list(TECHWEB_NODE_NANITE_SMART)
	design_ids = list(
		"factory_nanites",
		"kickstart_nanites",
		"offline_nanites",
		"pyramid_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_storage_protocols
	id = TECHWEB_NODE_NANITE_STORAGE_PROTOCOLS
	tech_tier = 4
	display_name = "Nanite Storage Protocols"
	description = "Protocols that overwrite the default nanite storage routine to achieve more efficiency or greater capacity."
	prereq_ids = list(TECHWEB_NODE_NANITE_SMART)
	design_ids = list(
		"free_range_nanites",
		"zip_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_combat
	id = TECHWEB_NODE_NANITE_MILITARY
	tech_tier = 5
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list(TECHWEB_NODE_NANITE_HARMONIC, TECHWEB_NODE_SYNDICATE_BASIC)
	design_ids = list(
		"explosive_nanites",
		"haste_nanites",
		"meltdown_nanites",
		"nanite_sting_nanites",
		"pyro_nanites",
		"viral_nanites",
		"armblade_nanites",
		"unsafe_storage_nanites",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	hidden = TRUE

/datum/techweb_node/nanite_hazard
	id = TECHWEB_NODE_NANITE_HAZARD
	tech_tier = 5
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced nanite programs using knowledge gained from advanced alien technology."
	prereq_ids = list(TECHWEB_NODE_ALIENTECH, TECHWEB_NODE_NANITE_HARMONIC)
	design_ids = list(
		"mindcontrol_nanites",
		"mitosis_nanites",
		"spreading_nanites"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
	hidden = TRUE
