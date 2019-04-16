/datum/admins/Topic(href, href_list)
	..()

	if(href_list["modantagtokens"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_tokens(C, href_list["modantagtokens"])
		show_player_panel(M)
