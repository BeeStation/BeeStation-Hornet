/// Returns as a text format of a list to tell what's inside of the list
/// * list/L: Put a list to investigate. You only need this.
/// * level: Don't give any value. (This is used when this proc calls itself recursively to build whitespaces.)
/proc/investigate_list(list/L, level=0)
	if(!L || !islist(L))
		return "(This is null, or not a list)"

	var/whitespaces = ""
	for(var/i in 0 to level)
		whitespaces += "	"
	. = "list(\n"
	. += "[whitespaces](depth: [level],	length: [length(L)])\n"
	for(var/idx in 1 to length(L))
		var/datum/key = L[idx]
		var/datum/item
		if(istext(key) || istype(key))
			item = L[key]

		if(islist(key))
			. += "[whitespaces]idx\[[idx]\] 	[investigate_list(key, level+1)]"
		else
			. += "[whitespaces]idx\[[idx]\]"
			if(isnull(item))
				. += " 	[type_check(key)]" // Note: It's not possible to tell if a key is associated with null
			else if(islist(item))
				. += " 	{ [type_check(key)] = [investigate_list(item, level+1)] }"
			else
				. += " 	{ [type_check(key)] = [type_check(item)] }"

		if(idx < length(L))
			. += ", \n"

	whitespaces = ""
	for(var/i in 1 to level)
		whitespaces += "	"
	. += "\n[whitespaces])"

/// returns which type a variable has as a form of text. Used to debug.
/proc/type_check(datum/V)
	. = "[V]::ERROR"
	if(isnull(V))
		return "null::null"
	else if(isnum(V))
		return "[V]::num"
	else if(istext(V))
		return "[V]::text"
	else if(islist(V))
		return "(list)"
	else if(ispath(V))
		return "[V]::typepath"
	else if(istype(V))
		return "[V]::[V.type]"
	else
		return "[V]::Unknown"
