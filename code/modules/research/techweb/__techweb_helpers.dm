/proc/count_unique_techweb_nodes()
	var/static/list/L = typesof(/datum/techweb_node)
	return L.len

/proc/count_unique_techweb_designs()
	var/static/list/L = typesof(/datum/design)
	return L.len

/proc/techweb_item_boost_check(obj/item/I)			//Returns an associative list of techweb node datums with values of the boost it gives.	var/list/returned = list()
	. = list()
	if(SSresearch.techweb_boost_items[I.type])
		. += SSresearch.techweb_boost_items[I.type]		//It should already be formatted in node datum = list(point type = value)
	if(I.item_flags & ILLEGAL)
		. |= "syndicate_basic"

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]

/proc/techweb_point_display_generic(pointlist, join = TRUE)
	var/list/ret = list()
	for(var/i in pointlist)
		if(SSresearch.point_types[i])
			ret += "[SSresearch.point_types[i]]: [pointlist[i]]"
		else
			ret += "ERRORED POINT TYPE: [pointlist[i]]"
	if(join)
		return ret.Join("<BR>")
	else
		return ret

/proc/techweb_point_display_rdconsole(pointlist, last_pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		ret += "[SSresearch.point_types[i] || "ERRORED POINT TYPE"]: [pointlist[i]] (+[(last_pointlist[i]) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
	return ret.Join("<BR>")
