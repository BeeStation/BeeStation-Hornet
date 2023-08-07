/*
 * BYOND moment
 * Byond has verbs stored on /client and /atom, but they are a different variable,
 * So we have to make an override for /atom and /client that do exactly the same thing but affect a different variable.
 * Seriously, why wouldn't they all just be on client?
 *
 * Update:
 * Apparently client.verbs is always empty, but adding and removing from it still works?
 * Just going to use winset instead, since that seems to work.
 */

/datum
	var/list/sorted_verbs
	var/list/verbs_to_sort

/datum/proc/add_verb(new_verbs)
	//Nooooo!!!!!
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!islist(new_verbs))
		new_verbs = list(new_verbs)
	if(!islist(verbs_to_sort))
		verbs_to_sort = list()
	verbs_to_sort += new_verbs

/datum/proc/sort_verbs()
	if(!islist(sorted_verbs))
		sorted_verbs = list()
	if(!islist(verbs_to_sort))
		verbs_to_sort = list()
	for(var/verb_in_list in verbs_to_sort)
		var/procpath/V = verb_in_list
		if(!V.category)
			continue
		if(islist(sorted_verbs["[V.category]"]))
			if(V in sorted_verbs[V.category])
				continue
			//Binary insert at the correct position
			var/list/verbs = sorted_verbs["[V.category]"]
			BINARY_INSERT_TEXT(V, verbs, procpath, name)
			sorted_verbs["[V.category]"] = verbs
		else
			//Add category with verb
			sorted_verbs["[V.category]"] = list(V)
	sort_list(sorted_verbs)
	verbs_to_sort.Cut()

/datum/proc/remove_verb(old_verbs)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(length(verbs_to_sort))
		sort_verbs()
	if(!sorted_verbs)
		return
	if(!islist(old_verbs))
		old_verbs = list(old_verbs)
	for(var/verb_in_list in old_verbs)
		var/procpath/V = verb_in_list
		//Find our category
		if("[V.category]" in sorted_verbs)
			//Remove the verb
			sorted_verbs["[V.category]"] -= V
			//Remove the category if necessary
			if(!LAZYLEN(sorted_verbs["[V.category]"]))
				sorted_verbs.Remove("[V.category]")

/atom/add_verb(new_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!tgui_only)
		verbs += new_verbs
	return ..(new_verbs)

/atom/remove_verb(old_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!tgui_only)
		verbs -= old_verbs
	return ..(old_verbs)

/obj/item/remove_verb(new_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	//If we lose an old verb while in someone's inventory, remove it frmo their panel.
	if(item_flags & PICKED_UP)
		var/mob/living/L = loc
		if(istype(L) && L.client)
			L.client.remove_verbs(new_verbs)
	return ..(new_verbs)

/obj/item/add_verb(new_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	//If we get a new verb while in someone's inventory, add it to their panel.
	if(item_flags & PICKED_UP)
		var/mob/living/L = loc
		if(istype(L) && L.client)
			L.client.add_verbs(new_verbs)
	return ..(new_verbs)

/client/add_verb(new_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!tgui_only)
		verbs += new_verbs
	add_verbs(new_verbs)
	return ..(new_verbs)

/client/remove_verb(old_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(!tgui_only)
		verbs -= old_verbs
	remove_verbs(old_verbs)
	return ..(old_verbs)

/mob/remove_verb(old_verbs, tgui_only = FALSE)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(client)
		client.remove_verbs(old_verbs)
	return ..()

/mob/add_verb(new_verbs, tgui_only)
	if(IS_ADMIN_ADVANCED_PROC_CALL)
		message_admins("[key_name(usr)] attempted to edit their verbs.")
		log_game("[key_name(usr)] attempted to edit their verbs.")
		return
	if(client)
		client.add_verbs(new_verbs)
	return ..()

/client/proc/remove_verbs(old_verbs)
	if(!islist(old_verbs))
		old_verbs = list(old_verbs)
	var/list/removed_verbs = list()
	for(var/pp in old_verbs)
		var/procpath/P = pp
		if(!P)
			continue
		if(!islist(removed_verbs[P.category]))
			removed_verbs[P.category] = list()
		removed_verbs[P.category] += "[P.name]"
	tgui_panel.remove_verbs(removed_verbs)

/client/proc/add_verbs(new_verbs)
	if(!islist(new_verbs))
		new_verbs = list(new_verbs)
	var/list/added_verbs = list()
	for(var/pp in new_verbs)
		var/procpath/P = pp
		if(!P)
			continue
		if((!mob && P.invisibility) || (mob && P.invisibility > mob.see_invisible))
			continue
		if(!islist(added_verbs[P.category]))
			added_verbs[P.category] = list()
		added_verbs[P.category]["[P.name]"] = list(
			action = "verb",
			params = list("verb" = P.name),
			type = STAT_VERB,
		)
	tgui_panel.add_verbs(added_verbs)

/proc/cmp_verb_des(procpath/a,procpath/b)
	return sorttext(b.name, a.name)
