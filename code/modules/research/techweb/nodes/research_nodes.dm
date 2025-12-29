/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	tech_tier = 1
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/anomaly
	id = "anomaly_research"
	tech_tier = 4
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prereq_ids = list(
		"adv_engi",
		"practical_bluespace",
	)
	design_ids = list(
		"anomaly_neutralizer",
		"reactive_armour",
		"xenoa_gloves",
		"xenoa_list_console",
		"xenoa_scale",
		"xenoa_conductor",
		"xenoa_calibrator",
		"xenoa_tracker",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	tech_tier = 4
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list(
		"beacon",
		"bluespace_crystal",
		"dragnetbeacon",
		"telesci_gps",
		"xenobioconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	tech_tier = 4
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list(
		"bluespace_basic",
		"engineering",
	)
	design_ids = list(
		"bluespacebeaker",
		"bluespacesyringe",
		"bluespace_capsule",
		"bs_rped",
		"minerbag_holding",
		"ore_silo",
		"phasic_scanning",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	tech_tier = 5
	display_name = "Bluespace Travel"
	description = "Application of Bluespace for static teleportation technology."
	prereq_ids = list("practical_bluespace")
	design_ids = list(
		"bluespace_pod",
		"launchpad_console",
		"launchpad",
		"quantumpad",
		"tele_hub",
		"tele_station",
		"teleconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/bluespace_stabilisation
	id = "bluespace_anchor"
	tech_tier = 5
	display_name = "Bluespace Stabilisation"
	description = "Analyse and disrupt nearby bluespace instabilities, preventing anomalous translation."
	prereq_ids = list("micro_bluespace")
	design_ids = list("bsanchor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	hidden = TRUE

/datum/techweb_node/bag_of_holding
	id = "bagofholding"
	tech_tier = 5
	display_name = "Bag of Holding"
	description = "Portable bluespace technology allows the production of backpacks that can store a greater volume of items than the volume of the bag."
	prereq_ids = list("micro_bluespace")
	design_ids = list("bag_holding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/wormhole_gun
	id = "wormholegun"
	tech_tier = 5
	display_name = "Bluespace Wormhole Projector"
	description = "Develop the research required to create a miniaturized bluespace wormhole projector, allowing you to jump between two places instantly."
	prereq_ids = list("micro_bluespace")
	design_ids = list("wormholeprojector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	hidden = TRUE

/datum/techweb_node/gravity_gun
	id = "gravity_gun"
	tech_tier = 5
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prereq_ids = list(
		"adv_weaponry",
		"bluespace_travel",
	)
	design_ids = list(
		"gravitygun",
		"mech_gravcatapult",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/quantum_spin
	id = "qswapper"
	tech_tier = 5
	display_name = "Quantum Spin Inverter"
	description = "Research the ability to create an experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	prereq_ids = list("micro_bluespace")
	design_ids = list("swapper")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
