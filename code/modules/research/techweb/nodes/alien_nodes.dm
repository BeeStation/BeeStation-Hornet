/datum/techweb_node/alien
	abstract_type = /datum/techweb_node/alien
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	tech_tier = 5

/datum/techweb_node/alien/New()
	. = ..()
	required_items_to_unlock += subtypesof(/obj/item/abductor)
	required_items_to_unlock += subtypesof(/obj/item/circuitboard/machine/abductor)

/datum/techweb_node/alien/base //AYYYYYYYYLMAOO tech
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prerequisite_nodes = list(/datum/techweb_node/biotech, /datum/techweb_node/engineering)
	required_items_to_unlock = list(
		/obj/item/stack/sheet/mineral/abductor,
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	unlocked_designs = list(
		/datum/design/alienalloy,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/alien/base/on_station_research(atom/research_source) //Unlocks the Zeta shuttle for purchase
	. = ..()
	SSshuttle.shuttle_purchase_requirements_met |= SHUTTLE_UNLOCK_ALIENTECH

/datum/techweb_node/alien/bio
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prerequisite_nodes = list(/datum/techweb_node/adv_biotech, /datum/techweb_node/alien/base)
	unlocked_designs = list(
		/datum/design/aliencautery,
		/datum/design/aliendrill,
		/datum/design/alienhemostat,
		/datum/design/alienretractor,
		/datum/design/aliensaw,
		/datum/design/alienscalpel,
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
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/alien/engi
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/alien/base)
	unlocked_designs = list(
		/datum/design/aliencrowbar,
		/datum/design/alienmultitool,
		/datum/design/alienscrewdriver,
		/datum/design/alienwelder,
		/datum/design/alienwirecutters,
		/datum/design/alienwrench,
	)
	required_items_to_unlock = list(
		/obj/item/crowbar/abductor,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/alien/surgery
	display_name = "Alien Surgery"
	description = "Anything from brainwashing to reviving the dead. Alien technology."
	prerequisite_nodes = list(/datum/techweb_node/alien/base, /datum/techweb_node/exp_surgery)
	unlocked_designs = list(
		/datum/design/surgery/brainwashing,
		/datum/design/surgery/healing/combo_upgrade_2,
		/datum/design/surgery/necrotic_revival,
	)
	required_items_to_unlock = list(
		/obj/item/cautery/alien,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/alien/nullspacebreaching
	display_name = "Nullspace Breaching"
	description = "Research into voidspace tunnelling, allowing us to significantly reduce flight times."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/alien/base, /datum/techweb_node/basic_shuttle_tech)
	unlocked_designs = list(
		/datum/design/board/shuttle_void_engine,
		/datum/design/wingpack_alien,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)
