/* How it works:
The shuttle arrives at CentCom dock and calls sell(), which recursively loops through all the shuttle contents that are unanchored.

Each object in the loop is checked for applies_to() of various export datums, except the invalid ones.
*/

/* The rule in figuring out item export cost:
Export cost of goods in the shipping crate must be always equal or lower than:
	packcage cost - crate cost - manifest cost
Crate cost is 500cr for a regular plasteel crate and 100cr for a large wooden one. Manifest cost is always 200cr.
This is to avoid easy cargo points dupes.

Credit dupes that require a lot of manual work shouldn't be removed, unless they yield too much profit for too little work.
For example, if some player buys iron and glass sheets and uses them to make and sell reinforced glass:

100 glass + 50 iron -> 100 reinforced glass
(1500cr -> 1600cr)

then the player gets the profit from selling his own wasted time.
*/

// Simple holder datum to pass export results around
/datum/export_report
	var/list/exported_atoms = list()	//names of atoms sold/deleted by export
	var/list/total_amount = list()		//export instance => total count of sold objects of its type, only exists if any were sold
	var/list/total_value = list()		//export instance => total value of sold objects

// external_report works as "transaction" object, pass same one in if you're doing more than one export in single go
/proc/export_item_and_contents(atom/movable/AM, allowed_categories = EXPORT_CARGO, delete_unsold = TRUE, dry_run=FALSE, datum/export_report/external_report)
	if(!GLOB.exports_list.len)
		setupExports()

	var/list/contents = AM.GetAllContents()

	var/datum/export_report/report = external_report

	if(!report) //If we don't have any longer transaction going on
		report = new

	// We go backwards, so it'll be innermost objects sold first
	for(var/i in reverse_range(contents))
		var/atom/movable/thing = i
		var/sold = FALSE

		for(var/datum/export/E in GLOB.exports_list)
			if(!E)
				continue
			if(E.applies_to(thing, allowed_categories))
				sold = E.sell_object(thing, report, dry_run, allowed_categories)
				report.exported_atoms += " [thing.name]"
				break

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_SOLD, thing, sold)

		if(!dry_run && (sold || delete_unsold))
			if(ismob(thing))
				thing.investigate_log("deleted through cargo export",INVESTIGATE_CARGO)
			qdel(thing)

	return report

/proc/export_contents(atom/movable/AM, allowed_categories = EXPORT_CARGO, delete_unsold = TRUE, dry_run=FALSE, datum/export_report/external_report)
	if(!GLOB.exports_list.len)
		setupExports()

	var/list/contents = AM.GetAllContents() - AM

	var/datum/export_report/report = external_report
	if(!report) //If we don't have any longer transaction going on
		report = new

	// We go backwards, so it'll be innermost objects sold first
	for(var/i in reverse_range(contents))
		var/atom/movable/thing = i
		var/sold = FALSE
		for(var/datum/export/E in GLOB.exports_list)
			if(!E)
				continue
			if(E.applies_to(thing, allowed_categories))
				sold = E.sell_object(thing, report, dry_run, allowed_categories)
				report.exported_atoms += " [thing.name]"
				break

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_SOLD, thing, sold)

		if(!dry_run && (sold || delete_unsold))
			if(ismob(thing))
				thing.investigate_log("deleted through cargo export",INVESTIGATE_CARGO)
			qdel(thing)

	return report

/datum/export
	var/unit_name = ""				// Unit name. Only used in "Received [total_amount] [name]s [message]." message
	var/message = ""
	var/cost = 100					// Cost of item, in cargo credits. Must not alow for infinite price dupes, see above.
	var/list/export_types = list()	// Type of the exported object. If none, the export datum is considered base type.
	var/include_subtypes = TRUE		// Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types = list()	// Types excluded from export

	//cost includes elasticity, this does not.
	var/init_cost

	//All these need to be present in export call parameter for this to apply.
	var/export_category = EXPORT_CARGO

/datum/export/item_price
	cost = 0	// This is defined later based on custom prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	export_types = list(/obj) // catch-all

/datum/export/item_price/applies_to(obj/O, allowed_categories = NONE)
	if(!(O.custom_price || O.custom_premium_price))
		return FALSE
	return TRUE

/datum/export/New()
	..()
	START_PROCESSING(SSprocessing, src)
	init_cost = cost
	export_types = typecacheof(export_types)
	exclude_types = typecacheof(exclude_types)

/datum/export/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/export/proc/get_cost(obj/O, allowed_categories = NONE)
	var/amount = get_amount(O)
	if(amount <= 0)
		return 0

	// Determine base price and markdown
	var/base_price = 0
	var/markdown = 1
	if(O.custom_premium_price)
		base_price = O.custom_premium_price
		markdown = PREMIUM_MARKDOWN
	else if(O.custom_price)
		base_price = O.custom_price
		markdown = NORMAL_MARKDOWN
	else
		base_price = init_cost  // fallback for legacy datum/export items

	base_price *= markdown

	// Grab demand state for this object type
	var/datum/obj_demand_state/state = get_obj_demand_state(O.type)
	var/demand_ratio = state.current_demand / state.max_demand
	demand_ratio = max(demand_ratio, state.min_price_factor)

	// Scale price by
	if(base_price)	// Makes sure items that HAVE a value don't get completely dogged by the calculations causing it to return 0
		return max(1, round(base_price * amount * demand_ratio))
	else
		return round(base_price * amount * demand_ratio)

// Checks the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
// Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
/datum/export/proc/get_amount(obj/O)
	return 1

// Checks if the item is fit for export datum.
/datum/export/proc/applies_to(obj/O, allowed_categories = NONE)
	if(O.is_contraband)
		export_category = EXPORT_CONTRABAND
	if((allowed_categories & export_category) != export_category)
		return FALSE
	if(!include_subtypes && !(O.type in export_types))
		return FALSE
	if(include_subtypes && (!is_type_in_typecache(O, export_types) || is_type_in_typecache(O, exclude_types)))
		return FALSE
	if(!get_cost(O, allowed_categories))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE

/**
  * Calculates the exact export value of the object, while factoring in all the relivant variables.
  *
  * Called only once, when the object is actually sold by the datum.
  * Adds item's cost and amount to the current export cycle.
  * get_cost, get_amount and applies_to do not neccesary mean a successful sale.
  *
  */
/datum/export/proc/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO)
	///This is the value of the object, as derived from export datums.
	var/the_cost = get_cost(O, allowed_categories)
	///Quantity of the object in question.
	var/amount = get_amount(O)
	if(!unit_name)
		unit_name = O.name
	if(amount <=0 || the_cost <=0)
		return FALSE

	report.total_value[src] += the_cost

	if(istype(O, /datum/export/material))
		report.total_amount[src] += amount*MINERAL_MATERIAL_AMOUNT
	else
		report.total_amount[src] += amount
	if(!dry_run)
		var/datum/obj_demand_state/state = get_obj_demand_state(O.type)
		state.current_demand = max(0, state.current_demand - amount)
		SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[O.type]", "[the_cost]"))
	return TRUE

// Total printout for the cargo console.
// Called before the end of current export cycle.
// It must always return something if the datum adds or removes any credts.
/datum/export/proc/total_printout(datum/export_report/ex, notes = TRUE)
	if(!ex.total_amount[src] || !ex.total_value[src])
		return ""

	var/total_value = ex.total_value[src]
	var/total_amount = ex.total_amount[src]

	var/msg = "[total_value] credits: Received [total_amount] "
	if(total_value > 0)
		msg = "+" + msg

	if(unit_name)
		msg += unit_name
		if(total_amount > 1)
			msg += "s"
		if(message)
			msg += " "

	if(message)
		msg += message

	msg += "."
	return msg

GLOBAL_LIST_EMPTY(exports_list)

/proc/setupExports()
    var/list/catchalls = list()

    for(var/subtype in subtypesof(/datum/export))
        var/datum/export/E = new subtype
        if(!E.export_types?.len)
            continue

        // Detect catch-all
        if(istype(E, /datum/export/item_price))
            catchalls += E
        else
            GLOB.exports_list += E

    // Now append catch-alls so they run last
    GLOB.exports_list += catchalls
