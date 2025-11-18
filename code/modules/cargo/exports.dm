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
	/// Associative list of [export instance => list of exported atoms]
	var/list/list/exported_atoms = list()
	/// Associative list of [export instance => total count of sold items]
	var/list/total_amount = list()
	/// Associative list of [export instance => total value of sold items]
	var/list/total_value = list()

// external_report works as "transaction" object, pass same one in if you're doing more than one export in single go
/proc/export_item_and_contents(atom/movable/AM, allowed_categories = EXPORT_CARGO, delete_unsold = FALSE, dry_run=FALSE, datum/export_report/external_report)
	var/list/contents = AM.GetAllContents()

	var/datum/export_report/report = external_report

	if(!report) //If we don't have any longer transaction going on
		report = new

	// We go backwards, so it'll be innermost objects sold first. We also make sure nothing is accidentally delete before everything is sold.
	var/list/to_delete = list()
	for(var/atom/movable/thing as anything in reverse_range(contents))
		var/sold = FALSE

		var/should_catchall = TRUE
		for(var/datum/export/export as anything in GLOB.exports_list)
			if(export.catchall)
				continue
			if(export.applies_to(thing, allowed_categories))
				should_catchall = FALSE

				if(!dry_run && (SEND_SIGNAL(thing, COMSIG_ITEM_PRE_EXPORT) & COMPONENT_STOP_EXPORT))
					break

				sold = export.sell_object(thing, report, dry_run, allowed_categories)
				if(!(thing.trade_flags & (TRADE_DELETE_UNSOLD | TRADE_NOT_SELLABLE)))
					// append the atom itself
					if(!islist(report.exported_atoms[export]))
						report.exported_atoms[export] = list(thing)
					else
						report.exported_atoms[export] += thing

				break

		// Snowflake code my beloved
		if(should_catchall)
			for(var/datum/export/export as anything in GLOB.exports_list)
				if(!export.catchall)
					continue
				if(export.applies_to(thing, allowed_categories))
					should_catchall = FALSE

					if(!dry_run && (SEND_SIGNAL(thing, COMSIG_ITEM_PRE_EXPORT) & COMPONENT_STOP_EXPORT))
						break

					sold = export.sell_object(thing, report, dry_run, allowed_categories)
					if(!(thing.trade_flags & (TRADE_DELETE_UNSOLD | TRADE_NOT_SELLABLE)))
						// append the atom itself
						if(!islist(report.exported_atoms[export]))
							report.exported_atoms[export] = list(thing)
						else
							report.exported_atoms[export] += thing

					break

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_SOLD, thing, sold)

		if(!dry_run && (sold || delete_unsold || thing.trade_flags & TRADE_DELETE_UNSOLD))
			if(ismob(thing))
				thing.investigate_log("deleted through cargo export",INVESTIGATE_CARGO)
			to_delete += thing

	for(var/atom/movable/thing as anything in to_delete)
		if(!QDELETED(thing))
			qdel(thing)

	return report

/datum/export
	/// Unit name. Only used in "Received [total_amount] [name]s [message]."
	var/unit_name = ""
	/// Message appended to the sale report
	var/message = ""
	/// Cost of item, in cargo credits. Must not allow for infinite price dupes, see above.
	var/cost = 1
	/// whether this export can have a negative impact on the cargo budget or not
	var/allow_negative_cost = FALSE
	/// The multiplier of the amount sold shown on the report. Useful for exports, such as material, which costs are not strictly per single units sold.
	var/amount_report_multiplier = 1
	/// Type of the exported object. If none, the export datum is considered base type.
	var/list/export_types = list()
	/// Set to FALSE to make the datum apply only to a strict type.
	var/include_subtypes = TRUE
	/// Are we a "catch-all" export type? This means we prioritize all non-catchall exports first, then fall back to these.
	var/catchall = FALSE

	//All these need to be present in export call parameter for this to apply.
	var/export_category = EXPORT_CARGO

/datum/export/New()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	export_types = string_assoc_list(zebra_typecacheof(export_types, only_root_path = !include_subtypes))

/datum/export/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/export/proc/get_cost(obj/object, allowed_categories = NONE)
	var/amount = get_amount(object)
	if(amount <= 0)
		return 0

	// Grab demand state for this object type
	var/datum/demand_state/state = SSdemand.get_demand_state(object.type)

	// Determine base price
	var/base_price = state.generated_price || cost

	var/demand_ratio = state.current_demand / state.max_demand
	demand_ratio = max(demand_ratio, state.min_price_factor)

	if(state.current_demand == 0)
		// If we at CC are at full stock then this item is worth 0 thus, won't be sold
		base_price = 0
	if(object.trade_flags & TRADE_NOT_SELLABLE)
		base_price = 0

	// Scale price by
	if(base_price)	// Makes sure items that HAVE a value don't get completely dogged by the calculations causing it to return 0
		return max(1, round(base_price * amount * demand_ratio))
	else
		return round(base_price * amount * demand_ratio)

// Checks the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
// Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
/datum/export/proc/get_amount(obj/thing)
	return 1

// Checks if the item is fit for export datum.
/datum/export/proc/applies_to(obj/thing, allowed_categories = NONE)
	var/category_to_use = export_category

	if(thing.trade_flags & TRADE_CONTRABAND)
		category_to_use = EXPORT_CONTRABAND
	if((allowed_categories & category_to_use) != category_to_use)
		return FALSE
	if(!is_type_in_typecache(thing, export_types))
		return FALSE
	if(!get_cost(thing, allowed_categories))
		return FALSE
	if(thing.flags_1 & HOLOGRAM_1)
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
/datum/export/proc/sell_object(obj/sold_item, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO)
	///This is the value of the object, as derived from export datums.
	var/export_value = get_cost(sold_item, allowed_categories)
	///Quantity of the object in question.
	var/export_amount = get_amount(sold_item)
	if(!unit_name)
		unit_name = sold_item.name

	if(export_amount <= 0 || (export_value <= 0 && !allow_negative_cost))
		return FALSE

	// If we're not doing a dry run, send COMSIG_ITEM_EXPORTED to the sold item
	var/export_result
	if(!dry_run)
		export_result = SEND_SIGNAL(sold_item, COMSIG_ITEM_EXPORTED, src, report, export_value)

	// If the signal handled adding it to the report, don't do it now
	if(!(export_result & COMPONENT_STOP_EXPORT_REPORT))
		report.total_value[src] += export_value
		report.total_amount[src] += export_amount * amount_report_multiplier

	if(!dry_run)
		var/datum/demand_state/state = SSdemand.get_demand_state(sold_item.type)
		state.current_demand = max(0, state.current_demand - export_amount)
		SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[sold_item.type]", "[export_value]"))
	return TRUE

// Total printout for the cargo console.
// Called before the end of current export cycle.
// It must always return something if the datum adds or removes any credts.
/datum/export/proc/total_printout(datum/export_report/report, notes = TRUE)
	if(!report.total_amount[src] || !report.total_value[src])
		return ""

	var/total_value = report.total_value[src]
	var/msg = "[total_value] credits: Received "
	if(total_value > 0)
		msg = "+" + msg

	// Count occurrences using associative list
	var/list/counts = list()
	for(var/atom/thing in report.exported_atoms)
		if(thing.name)
			counts[thing.name] = (counts[thing.name] || 0) + 1

	// Turn our list into a nice string
	var/list/item_strings = list()
	for(var/name in counts)
		var/count = counts[name]
		if(count > 1)
			item_strings += "[count] [name]s"
		else
			item_strings += name

	// Join with commas, last item with "and"
	var/item_msg = ""
	var/counter = 0
	for(var/item in item_strings)
		counter += 1
		if(counter == 1)
			item_msg = item
		else if(counter == item_strings.len)
			item_msg = item_msg + " and " + item
		else
			item_msg = item_msg + ", " + item

	msg += item_msg

	// If our export has a custom message, add it to the end.
	if(message)
		msg += " [message]"

	msg += "."
	return msg

GLOBAL_LIST_INIT(exports_list, setup_exports())

/proc/setup_exports()
	var/list/datum/export/exports = list()
	for(var/datum/export/subtype as anything in subtypesof(/datum/export))
		var/datum/export/current_export = new subtype
		if(!length(current_export.export_types))
			continue

		exports += current_export

	return exports
