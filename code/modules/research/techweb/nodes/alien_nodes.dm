// Simple define to avoid copy-pasting the same code 3 times
#define ABDUCTOR_SUBTYPE_UNLOCKS(X) \
	##X/New() { \
		. = ..(); \
		required_items_to_unlock += subtypesof(/obj/item/abductor); \
		required_items_to_unlock += subtypesof(/obj/item/circuitboard/machine/abductor); \
	}

/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = TECHWEB_NODE_ALIENTECH
	tech_tier = 5
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list(TECHWEB_NODE_BIOTECH, TECHWEB_NODE_ENGINEERING)
	required_items_to_unlock = list(
		/obj/item/melee/baton/abductor,
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	design_ids = list(
		"alienalloy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE


ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alientech)

/datum/techweb_node/alientech/on_station_research() //Unlocks the Zeta shuttle for purchase
	SSshuttle.shuttle_purchase_requirements_met |= SHUTTLE_UNLOCK_ALIENTECH

/datum/techweb_node/alien_bio
	id = TECHWEB_NODE_ALIEN_BIO
	tech_tier = 5
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH, TECHWEB_NODE_ALIENTECH)
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
	)
	required_items_to_unlock = list(
		/obj/item/melee/baton/abductor,
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alien_bio)

/datum/techweb_node/alien_engi
	id = TECHWEB_NODE_ALIEN_ENGI
	tech_tier = 5
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list(TECHWEB_NODE_ADV_ENGI, TECHWEB_NODE_ALIENTECH)
	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
	)
	required_items_to_unlock = list(
		/obj/item/melee/baton/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE

ABDUCTOR_SUBTYPE_UNLOCKS(/datum/techweb_node/alien_engi)

/datum/techweb_node/alien_surgery
	id = TECHWEB_NODE_ALIEN_SURGERY
	tech_tier = 5
	display_name = "Alien Surgery"
	description = "Anything from brainwashing to reviving the dead. Alien technology."
	prereq_ids = list(TECHWEB_NODE_ALIENTECH, TECHWEB_NODE_EXP_SURGERY)
	design_ids = list(
		"surgery_brainwashing",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/nullspacebreaching
	id = TECHWEB_NODE_NULLSPACEBREACHING
	display_name = "Nullspace Breaching"
	description = "Research into voidspace tunnelling, allowing us to significantly reduce flight times."
	prereq_ids = list(TECHWEB_NODE_ALIENTECH, TECHWEB_NODE_BASIC_SHUTTLE)
	design_ids = list(
		"engine_void",
		"wingpack_ayy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
