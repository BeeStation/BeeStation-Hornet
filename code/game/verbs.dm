/*
 * BYOND moment
 * Byond has verbs stored on /client and /atom, but they are a different variable,
 * So we have to make an override for /atom and /client that do exactly the same thing but affect a different variable.
 * Seriously, why wouldn't they all just be on client?
 */

/datum
	var/list/sorted_verbs

/datum/proc/add_verb(new_verbs)
	if(!islist(new_verbs))
		new_verbs = list(new_verbs)
	if(!islist(sorted_verbs))
		sorted_verbs = list()
	for(var/verb_in_list in new_verbs)
		var/procpath/V = verb_in_list
		if(V.category)
			if(V.category in sorted_verbs)
				//Add verb
				sorted_verbs["[V.category]"] |= V
			else
				//Add category with verb
				sorted_verbs["[V.category]"] = list(V)

/datum/proc/remove_verb(old_verbs)
	if(!sorted_verbs)
		CRASH("Remove verb called on atom ([src]) with no verbs.")
	if(!islist(old_verbs))
		old_verbs = list(old_verbs)
	for(var/verb_in_list in old_verbs)
		var/procpath/V = verb_in_list
		//Find our category
		if(V.category in sorted_verbs)
			//Remove the verb
			sorted_verbs["[V.category]"] -= V
			//Remove the category if necessary
			if(!LAZYLEN(sorted_verbs["[V.category]"]))
				sorted_verbs.Remove("[V.category]")

/atom/add_verb(new_verbs)
	verbs |= new_verbs
	. = ..()

/atom/remove_verb(old_verbs)
	verbs -= old_verbs
	. = ..()

/client/add_verb(new_verbs)
	verbs |= new_verbs
	. = ..()

/client/remove_verb(old_verbs)
	verbs -= old_verbs
	. = ..()
