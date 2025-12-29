/datum/techweb_node/sec_basic
	id = "sec_basic"
	tech_tier = 1
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	design_ids = list(
		"bola_energy",
		"evidencebag",
		"flashbulb",
		"pepperspray",
		"seclite",
		"zipties",
		"turnstile",
		"genpop_interface",
	)
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/exotic_ammo
	id = "exotic_ammo"
	tech_tier = 4
	display_name = "Exotic Shotgun Ammunition"
	description = "They won't know what hit em."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"techshotshell",
		"shotgundartcryostasis",
		"stunshell",
		"shotgunsluggold",
		"shotgunslugbronze",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/tackle_advanced
	id = "tackle_advanced"
	display_name = "Advanced Grapple Technology"
	description = "Nanotrasen would like to remind its researching staff that it is never acceptable to \"glomp\" your coworkers, and further \"scientific trials\" on the subject \
		will no longer be accepted in its academic journals."
	design_ids = list("tackle_dolphin", "tackle_rocket")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/landmine
	id = "nonlethal_mines"
	tech_tier = 3
	display_name = "Nonlethal Landmine Technology"
	description = "Our weapons technicians could perhaps work out methods for the creation of nonlethal landmines for security teams."
	prereq_ids = list("sec_basic")
	design_ids = list("stunmine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/weaponry
	id = "weaponry"
	tech_tier = 3
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new ways to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list(
		"pin_testing",
		"tele_shield",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/smartmine
	id = "smart_mines"
	tech_tier = 4
	display_name = "Smart Landmine Technology"
	description = "Using IFF technology, we could develop smartmines that do not trigger for those who are mindshielded."
	prereq_ids = list(
		"engineering",
		"nonlethal_mines",
		"weaponry",
	)
	design_ids = list("stunmine_adv")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	tech_tier = 4
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prereq_ids = list(
		"adv_engi",
		"weaponry",
	)
	design_ids = list(
		"pin_loyalty",
		"shieldbelt",
		"c38_hotshot",
		"c38_iceblox",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/advmine
	id = "adv_mines"
	tech_tier = 4
	display_name = "Advanced Landmine Technology"
	description = "We can further develop our smartmines to build some extremely capable designs."
	prereq_ids = list(
		"adv_engi",
		"smart_mines",
		"weaponry",
	)
	design_ids = list(
		"stunmine_heavy",
		"stunmine_rapid",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	tech_tier = 4
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list(
		"adv_power",
		"emp_basic",
		"weaponry",
	)
	design_ids = list(
		"ioncarbine",
		"stunrevolver",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	tech_tier = 5
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list(
		"adv_engi",
		"adv_weaponry",
	)
	design_ids = list("nuclear_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/medical_weapons
	id = "medical_weapons"
	tech_tier = 4
	display_name = "Medical Weaponry"
	description = "Weapons using medical technology."
	prereq_ids = list(
		"adv_biotech",
		"weaponry",
	)
	design_ids = list("rapidsyringe")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	tech_tier = 4
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"temp_gun",
		"xray_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	tech_tier = 5
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list("beamrifle")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	tech_tier = 3
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"adv_Grenade",
		"pyro_Grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/ballistic_weapons
	id = "ballistic_weapons"
	tech_tier = 3
	display_name = "Ballistic Weaponry"
	description = "This isn't research.. This is reverse-engineering!"
	prereq_ids = list("weaponry")
	design_ids = list(
		"mag_oldsmg_ap",
		"mag_oldsmg_ic",
		"mag_oldsmg_rubber",
		"mag_oldsmg",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
