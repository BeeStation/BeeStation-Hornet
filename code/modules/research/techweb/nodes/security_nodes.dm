/datum/techweb_node/sec_basic
	tech_tier = 1
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	unlocked_designs = list(
		/datum/design/bola_energy,
		/datum/design/evidencebag,
		/datum/design/flashbulb,
		/datum/design/pepperspray,
		/datum/design/seclite,
		/datum/design/zipties,
		/datum/design/board/turnstile,
		/datum/design/board/genpop_interface,
	)
	prerequisite_nodes = list(/datum/techweb_node/base)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/exotic_ammo
	tech_tier = 4
	display_name = "Exotic Shotgun Ammunition"
	description = "They won't know what hit em."
	prerequisite_nodes = list(/datum/techweb_node/adv_weaponry)
	unlocked_designs = list(
		/datum/design/techshell,
		/datum/design/cryostasis_shotgun_dart,
		/datum/design/stunshell,
		/datum/design/shotgun_gold_slug,
		/datum/design/shotgun_bronze_slug,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/tackle_advanced
	display_name = "Advanced Grapple Technology"
	description = "Nanotrasen would like to remind its researching staff that it is never acceptable to \"glomp\" your coworkers, and further \"scientific trials\" on the subject \
		will no longer be accepted in its academic journals."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	unlocked_designs = list(/datum/design/tackle_dolphin, /datum/design/tackle_rocket)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/landmine
	tech_tier = 3
	display_name = "Nonlethal Landmine Technology"
	description = "Our weapons technicians could perhaps work out methods for the creation of nonlethal landmines for security teams."
	prerequisite_nodes = list(/datum/techweb_node/sec_basic)
	unlocked_designs = list(/datum/design/stunmine)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/weaponry
	tech_tier = 3
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new ways to weaponize just about everything now."
	prerequisite_nodes = list(/datum/techweb_node/engineering)
	unlocked_designs = list(
		/datum/design/pin_testing,
		/datum/design/tele_shield,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/smartmine
	tech_tier = 4
	display_name = "Smart Landmine Technology"
	description = "Using IFF technology, we could develop smartmines that do not trigger for those who are mindshielded."
	prerequisite_nodes = list(/datum/techweb_node/engineering, /datum/techweb_node/landmine, /datum/techweb_node/weaponry)
	unlocked_designs = list(/datum/design/adv_stunmine)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/adv_weaponry
	tech_tier = 4
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/pin_mindshield,
		/datum/design/shield_belt,
		/datum/design/c38_hotshot,
		/datum/design/c38_iceblox,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/advmine
	tech_tier = 4
	display_name = "Advanced Landmine Technology"
	description = "We can further develop our smartmines to build some extremely capable designs."
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/smartmine, /datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/lm12_stunmine,
		/datum/design/lm6_stunmine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/electric_weapons
	tech_tier = 4
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prerequisite_nodes = list(/datum/techweb_node/adv_power, /datum/techweb_node/emp_basic, /datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/ioncarbine,
		/datum/design/stunrevolver,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/radioactive_weapons
	tech_tier = 5
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/adv_weaponry)
	unlocked_designs = list(/datum/design/nuclear_gun)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/medical_weapons
	tech_tier = 4
	display_name = "Medical Weaponry"
	description = "Weapons using medical technology."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech, /datum/techweb_node/weaponry)
	unlocked_designs = list(/datum/design/rapidsyringe)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/beam_weapons
	tech_tier = 4
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_weaponry)
	unlocked_designs = list(
		/datum/design/temp_gun,
		/datum/design/xray,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/adv_beam_weapons
	tech_tier = 5
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_weaponry)
	unlocked_designs = list(/datum/design/beamrifle)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/explosive_weapons
	tech_tier = 3
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prerequisite_nodes = list(/datum/techweb_node/adv_weaponry)
	unlocked_designs = list(
		/datum/design/adv_grenade,
		/datum/design/pyro_grenade,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/ballistic_weapons
	tech_tier = 3
	display_name = "Ballistic Weaponry"
	description = "This isn't research.. This is reverse-engineering!"
	prerequisite_nodes = list(/datum/techweb_node/weaponry)
	unlocked_designs = list(
		/datum/design/mag_oldsmg/ap_mag,
		/datum/design/mag_oldsmg/ic_mag,
		/datum/design/mag_oldsmg/rubber,
		/datum/design/mag_oldsmg,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)
