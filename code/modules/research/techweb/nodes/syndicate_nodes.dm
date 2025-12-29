/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	tech_tier = 4
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list(
		"adv_engi",
		"adv_weaponry",
		"explosive_weapons",
	)
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"arcade_amputation",
		"borg_syndicate_module",
		"decloner",
		"donksoft_refill",
		"donksofttoyvendor",
		"largecrossbow",
		"suppressor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	hidden = TRUE

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
	id = "unregulated_bluespace"
	tech_tier = 5
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list(
		"bluespace_travel",
		"syndicate_basic",
	)
	design_ids = list("desynchronizer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/sticky_basic
	id = "sticky_basic"
	tech_tier = 3
	display_name = "Basic Sticky Technology"
	description = "The only thing left to do after researching this tech is to start printing out a bunch of 'kick me' signs."
	prereq_ids = list(
		"adv_engi",
		"syndicate_basic",
	)
	design_ids = list("sticky_tape")

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/sticky_advanced
	id = "sticky_advanced"
	tech_tier = 4
	display_name = "Advanced Sticky Technology"
	description = "Taking a good joke too far? Nonsense!"
	prereq_ids = list("sticky_basic")
	design_ids = list(
		"pointy_tape",
		"super_sticky_tape",
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	hidden = TRUE
