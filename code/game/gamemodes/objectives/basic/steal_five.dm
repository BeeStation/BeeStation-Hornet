/datum/objective/steal_five_of_type
	name = "steal five of"
	explanation_text = "Steal at least five items!"
	var/list/wanted_items = list()
	var/stolen_count = 0
	var/thing_name = "item"

/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_five_of_type/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(is_type_in_typecache(I, wanted_items))
				stolen_count++
	return (stolen_count >= 5) || ..()

/datum/objective/steal_five_of_type/summon_guns
	name = "steal guns"
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)
	thing_name = "gun"

/datum/objective/steal_five_of_type/summon_magic
	name = "steal magic"
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()
	thing_name = "magical artifact"

/datum/objective/steal_five_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()

/datum/objective/steal_five_of_type/summon_magic/check_completion()
	for(var/datum/mind/M as() in get_owners())
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/book/granter/spell))
				var/obj/item/book/granter/spell/spellbook = I
				if(!spellbook.used || !spellbook.oneuse) //if the book still has powers...
					stolen_count++ //it counts. nice.
			else if(is_type_in_typecache(I, wanted_items))
				stolen_count++
	return (stolen_count >= 5) || ..()

/datum/objective/steal_five_of_type/summon_magic/get_completion_message()
	var/span = check_completion() ? "grentext" : "redtext"
	return "[explanation_text] <span class='[span]'>[stolen_count] [thing_name]\s stolen!</span>"
