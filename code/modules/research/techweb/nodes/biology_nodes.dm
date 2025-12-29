/datum/techweb_node/biotech
	id = "biotech"
	tech_tier = 1
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list(
		"beer_dispenser",
		"chem_dispenser",
		"chem_heater",
		"chem_master",
		"defibmount",
		"defibrillator",
		"genescanner",
		"medipen_atropine",
		"medipen_dex",
		"medipen_epi",
		"medspray",
		"minor_botanical_dispenser",
		"operating",
		"pandemic",
		"sleeper",
		"soda_dispenser",
		"blood_pack",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	tech_tier = 2
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list(
		"crewpinpointer",
		"defibrillator_compact",
		"harvester",
		"holobarrier_med",
		"limbgrower",
		"meta_beaker",
		"piercesyringe",
		"plasmarefiller",
		"smoke_machine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/bio_process
	id = "bio_process"
	tech_tier = 1
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list(
		"deepfryer",
		"dish_drive",
		"fat_sucker",
		"gibber",
		"griddle",
		"microwave",
		"monkey_recycler",
		"oven",
		"processor",
		"reagentgrinder",
		"smartfridge",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
