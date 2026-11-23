/datum/techweb_node/nanite_base
	tech_tier = 2
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	prerequisite_nodes = list(/datum/techweb_node/datatheory)
	unlocked_designs = list(
		/datum/design/nanites/access,
		/datum/design/nanites/monitoring,
		/datum/design/board/nanite_chamber_control,
		/datum/design/board/nanite_chamber,
		/datum/design/board/nanite_cloud_control,
		/datum/design/nanite_disk,
		/datum/design/board/nanite_program_hub,
		/datum/design/board/nanite_programmer,
		/datum/design/nanite_remote,
		/datum/design/nanite_comm_remote,
		/datum/design/nanite_scanner,
		/datum/design/board/public_nanite_chamber,
		/datum/design/nanites/reduced_diagnostics,
		/datum/design/nanites/relay,
		/datum/design/nanites/relay_repeater,
		/datum/design/nanites/repairing,
		/datum/design/nanites/repeater,
		/datum/design/nanites/research,
		/datum/design/nanites/researchplus,
		/datum/design/nanites/sensor_nanite_volume,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_smart
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prerequisite_nodes = list(/datum/techweb_node/nanite_base, /datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/nanites/memory_leak,
		/datum/design/nanites/metabolic_synthesis,
		/datum/design/nanites/purging,
		/datum/design/nanites/sensor_voice,
		/datum/design/nanites/stealth,
		/datum/design/nanites/voice,
		/datum/design/nanites/sensor_receiver,
		/datum/design/nanites/signaler,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_mesh
	tech_tier = 2
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prerequisite_nodes = list(/datum/techweb_node/engineering, /datum/techweb_node/nanite_base)
	unlocked_designs = list(
		/datum/design/nanites/conductive,
		/datum/design/nanites/cryo,
		/datum/design/nanites/dermal_button,
		/datum/design/nanites/emp,
		/datum/design/nanites/hardening,
		/datum/design/nanites/refractive,
		/datum/design/nanites/shock,
		/datum/design/nanites/temperature,
		/datum/design/nanites/dermal_toggle,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_bio
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prerequisite_nodes = list(/datum/techweb_node/biotech, /datum/techweb_node/nanite_base)
	unlocked_designs = list(
		/datum/design/nanites/blood_restoring,
		/datum/design/nanites/coagulating,
		/datum/design/nanites/flesh_eating,
		/datum/design/nanites/poison,
		/datum/design/nanites/regenerative,
		/datum/design/nanites/sensor_crit,
		/datum/design/nanites/sensor_damage,
		/datum/design/nanites/sensor_death,
		/datum/design/nanites/sensor_health,
		/datum/design/nanites/sensor_nutrition,
		/datum/design/nanites/sensor_blood,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_neural
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prerequisite_nodes = list(/datum/techweb_node/nanite_bio)
	unlocked_designs = list(
		/datum/design/nanites/bad_mood,
		/datum/design/nanites/brain_heal,
		/datum/design/nanites/good_mood,
		/datum/design/nanites/nervous,
		/datum/design/nanites/paralyzing,
		/datum/design/nanites/self_scan,
		/datum/design/nanites/stun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_synaptic
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prerequisite_nodes = list(/datum/techweb_node/nanite_neural, /datum/techweb_node/neural_programming)
	unlocked_designs = list(
		/datum/design/nanites/blinding,
		/datum/design/nanites/hallucination,
		/datum/design/nanites/mute,
		/datum/design/nanites/pacifying,
		/datum/design/nanites/sleepy,
		/datum/design/nanites/speech,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_cc
	tech_tier = 5
	display_name = "Classified Nanites"
	description = "Highly confidential nanite programs from CC. Report usage to your nearest administraitor."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/nanite_neural, /datum/techweb_node/neural_programming)
	unlocked_designs = list(
		/datum/design/nanites/mindshield,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_harmonic
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology. Passively increases nanite regeneration rate for all clouds upon researching."
	prerequisite_nodes = list(/datum/techweb_node/nanite_bio, /datum/techweb_node/nanite_mesh, /datum/techweb_node/nanite_smart)
	unlocked_designs = list(
		/datum/design/nanites/adrenaline,
		/datum/design/nanites/aggressive_replication,
		/datum/design/nanites/brain_heal_advanced,
		/datum/design/nanites/defib,
		/datum/design/nanites/fake_death,
		/datum/design/nanites/purging_advanced,
		/datum/design/nanites/regenerative_advanced,
		/datum/design/nanites/sensor_species,
		/datum/design/nanites/vampire,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_replication_protocols
	tech_tier = 4
	display_name = "Nanite Replication Protocols"
	description = "Protocols that overwrite the default nanite replication routine to achieve more efficiency in certain circumstances."
	prerequisite_nodes = list(/datum/techweb_node/nanite_smart)
	unlocked_designs = list(
		/datum/design/nanites/factory,
		/datum/design/nanites/kickstart,
		/datum/design/nanites/offline,
		/datum/design/nanites/pyramid,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_storage_protocols
	tech_tier = 4
	display_name = "Nanite Storage Protocols"
	description = "Protocols that overwrite the default nanite storage routine to achieve more efficiency or greater capacity."
	prerequisite_nodes = list(/datum/techweb_node/nanite_smart)
	unlocked_designs = list(
		/datum/design/nanites/free_range,
		/datum/design/nanites/zip,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/nanite_combat
	tech_tier = 5
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/nanite_harmonic, /datum/techweb_node/syndicate_basic)
	unlocked_designs = list(
		/datum/design/nanites/explosive,
		/datum/design/nanites/haste,
		/datum/design/nanites/meltdown,
		/datum/design/nanites/nanite_sting,
		/datum/design/nanites/pyro,
		/datum/design/nanites/viral,
		/datum/design/nanites/armblade,
		/datum/design/nanites/unsafe_storage,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/nanite_hazard
	tech_tier = 5
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced nanite programs using knowledge gained from advanced alien technology."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/alien/base, /datum/techweb_node/nanite_harmonic)
	unlocked_designs = list(
		/datum/design/nanites/mind_control,
		/datum/design/nanites/mitosis,
		/datum/design/nanites/spreading,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS, TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS)
