/**
 * Global Science techweb for RND consoles
 */
/datum/techweb/science
	id = "SCIENCE"
	organization = "Nanotrasen"
	should_generate_points = TRUE

/datum/techweb/science/New()
	. = ..()
	// Start with discovery points
	adjust_points(TECHWEB_POINT_TYPE_DISCOVERY, TECHWEB_TIER_2_POINTS)

/datum/techweb/science/node_added(datum/techweb_node/node, atom/research_source)
	node.on_station_research(research_source)

/datum/techweb/oldstation
	id = "CHARLIE"
	organization = "Nanotrasen"
	should_generate_points = TRUE

/datum/techweb/oldstation/New()
	. = ..()
	research_node(/datum/techweb_node/oldstation_surgery, force = TRUE, apply_cost = TRUE)

/datum/techweb/golem
	id = "GOLEM"
	organization = "Free Golems"
	should_generate_points = TRUE

GLOBAL_LIST_EMPTY(autounlock_techwebs)

/**
 * Techweb node that automatically unlocks a given buildtype.
 * Saved in GLOB.autounlock_techwebs and used to prevent
 * creating new ones each time it's needed.
 */
/datum/techweb/autounlocking
	///The buildtype we will automatically unlock.
	var/allowed_buildtypes = ALL
	///Designs that are only available when the printer is hacked.
	var/list/hacked_designs = list()

/datum/techweb/autounlocking/New()
	. = ..()
	for(var/design_path, _design in SSresearch.techweb_designs)
		var/datum/design/design = _design
		if(RND_CATEGORY_INITIAL in design.category)
			add_design(design)
		if(RND_CATEGORY_HACKED in design.category)
			add_design(design, add_to = hacked_designs)

/datum/techweb/autounlocking/is_valid_design(datum/design/design)
	return (design.build_type & allowed_buildtypes)

/datum/techweb/autounlocking/autolathe
	allowed_buildtypes = AUTOLATHE

/datum/techweb/autounlocking/limbgrower
	allowed_buildtypes = LIMBGROWER

/datum/techweb/autounlocking/biogenerator
	allowed_buildtypes = BIOGENERATOR

/datum/techweb/autounlocking/smelter
	allowed_buildtypes = SMELTER
