/client/proc/cinematic()
	set name = "cinematic"
	set category = "Fun"
	set desc = "Shows a cinematic."	// Intended for testing but I thought it might be nice for events on the rare occasion Feel free to comment it out if it's not wanted.
	set hidden = 1
	if(!SSticker)
		return

	var/datum/cinematic/choice = input(src,"Cinematic","Choose",null) as null|anything in sort_list(subtypesof(/datum/cinematic), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(choice)
		message_admins("[key_name_admin(usr)] triggered a cinematic: [choice]")
		log_admin("[key_name(usr)] triggered a cinematic: [choice]")
		Cinematic(initial(choice.id),world,null)
