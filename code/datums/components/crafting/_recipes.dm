
/datum/crafting_recipe
	///in-game display name -  Optional, if not set uses result name
	var/name = ""
	///type paths of items consumed associated with how many are needed
	var/list/reqs[] = list()
	//type paths of items explicitly not allowed as an ingredient
	var/list/blacklist[] = list()
	//type path of item resulting from this craft
	var/result
	//type paths of items needed but not consumed
	var/list/tools[] = list()
	//time in Seconds
	var/time = 3 SECONDS
	//type paths of items that will be placed in the result
	var/list/parts[] = list()
	//type paths of reagents that will be placed in the result
	var/list/chem_catalysts[] = list()
	//where it shows up in the crafting UI, as well it's subcategory
	var/category = CAT_NONE
	var/subcategory = CAT_NONE
	//Set to FALSE if it needs to be learned first.
	var/always_available = TRUE
	///Should only one object exist on the same turf?
	var/one_per_turf = FALSE
	/// Should admins be notified about this getting created by a non-antagonist?
	var/dangerous_craft = FALSE

/datum/crafting_recipe/New()
	if(!(result in reqs))
		blacklist += result

/**
  * Run custom pre-craft checks for this recipe
  *
  * user: the /mob that initiated the crafting
  * collected_requirements: A list of lists of /obj/item instances that satisfy reqs. Top level list is keyed by requirement path.
  */
/datum/crafting_recipe/proc/check_requirements(mob/user, list/collected_requirements)
	return TRUE

/datum/crafting_recipe/proc/on_craft_completion(mob/user, atom/result)
	return
