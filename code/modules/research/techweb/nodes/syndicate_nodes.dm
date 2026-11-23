/datum/techweb_node/syndicate_basic
	tech_tier = 4
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/adv_weaponry, /datum/techweb_node/explosive_weapons)
	unlocked_designs = list(
		/datum/design/board/advanced_camera,
		/datum/design/ai_cam_upgrade,
		/datum/design/board/amputation_adventure,
		/datum/design/borg_syndicate_module,
		/datum/design/decloner,
		/datum/design/donksoft_refill,
		/datum/design/board/donksofttoyvendor,
		/datum/design/largecrossbow,
		/datum/design/suppressor,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/syndicate_basic/New() //Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	if(!SSearly_assets.initialized)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(register_uplink_items))
	else
		register_uplink_items()

/datum/techweb_node/syndicate_basic/proc/register_uplink_items()
	SIGNAL_HANDLER
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	required_items_to_unlock = list()
	for(var/datum/uplink_item/item_path as anything in subtypesof(/datum/uplink_item))
		if(!initial(item_path.item) || !initial(item_path.illegal_tech))
			continue
		required_items_to_unlock |= initial(item_path.item)

/datum/techweb_node/unregulated_bluespace
	tech_tier = 5
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/bluespace_travel, /datum/techweb_node/syndicate_basic)
	unlocked_designs = list(/datum/design/desynchronizer)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/sticky_basic
	tech_tier = 3
	display_name = "Basic Sticky Technology"
	description = "The only thing left to do after researching this tech is to start printing out a bunch of 'kick me' signs."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/adv_engi, /datum/techweb_node/syndicate_basic)
	unlocked_designs = list(/datum/design/sticky_tape)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/sticky_advanced
	tech_tier = 4
	display_name = "Advanced Sticky Technology"
	description = "Taking a good joke too far? Nonsense!"
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN | TECHWEB_NODE_WAIT_FOR_PREREQS
	prerequisite_nodes = list(/datum/techweb_node/sticky_basic)
	unlocked_designs = list(
		/datum/design/pointy_tape,
		/datum/design/super_sticky_tape,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
