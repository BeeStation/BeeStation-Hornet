/datum/techweb_node/biotech
	tech_tier = 1
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prerequisite_nodes = list(/datum/techweb_node/base)
	unlocked_designs = list(
		/datum/design/board/beer_dispenser,
		/datum/design/board/chem_dispenser,
		/datum/design/board/chem_heater,
		/datum/design/board/chem_master,
		/datum/design/defibrillator_mount,
		/datum/design/defibrillator,
		/datum/design/genescanner,
		/datum/design/medipen_atropine,
		/datum/design/medipen_dex,
		/datum/design/medipen_epi,
		/datum/design/medspray,
		/datum/design/board/minor_botanical_dispenser,
		/datum/design/board/operating,
		/datum/design/board/pandemic,
		/datum/design/board/sleeper,
		/datum/design/board/soda_dispenser,
		/datum/design/blood_pack,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_biotech
	tech_tier = 2
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prerequisite_nodes = list(/datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/crewpinpointer,
		/datum/design/defibrillator_compact,
		/datum/design/board/harvester,
		/datum/design/holobarrier_med,
		/datum/design/board/limbgrower,
		/datum/design/meta_beaker,
		/datum/design/piercesyringe,
		/datum/design/plasmarefiller,
		/datum/design/board/smoke_machine,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/bio_process
	tech_tier = 1
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prerequisite_nodes = list(/datum/techweb_node/biotech)
	unlocked_designs = list(
		/datum/design/board/deepfryer,
		/datum/design/board/dish_drive,
		/datum/design/board/fat_sucker,
		/datum/design/board/gibber,
		/datum/design/board/griddle,
		/datum/design/board/microwave,
		/datum/design/board/monkey_recycler,
		/datum/design/board/oven,
		/datum/design/board/processor,
		/datum/design/board/reagentgrinder,
		/datum/design/board/smartfridge,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)
