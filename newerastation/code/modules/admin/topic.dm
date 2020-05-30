//yoinked from hippie (infiltrators)
/datum/admins/Topic(href, href_list)
	..()

	hippieTopic(href, href_list)

/datum/admins/proc/hippieTopic(href, href_list)
	if(href_list["makeAntag"] == "infiltrator")
		hippie_makeInfiltrators(src)
	//there would be a lotta elifs here if I didn't yoink only infiltrators, but hey, modularization!

/datum/admins/proc/hippie_makeInfiltrators(datum/admins/src)
	message_admins("[key_name(usr)] is creating an infiltration team...")
	if(src.makeInfiltratorTeam())
		message_admins("[key_name(usr)] created an infiltration team.")
		log_admin("[key_name(usr)] created an infiltration team.")
	else
		message_admins("[key_name_admin(usr)] tried to create an infiltration team. Unfortunately, there were not enough candidates available.")
		log_admin("[key_name(usr)] failed to create an infiltration team.")
