/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(src.owner)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(src.owner)] clicked an href with [msg] authorization key! [href]")

/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		message_admins("[usr.key] has attempted to override the admin panel!")
		log_admin("[key_name(src.owner)] tried to use the admin panel without authorization.")
		return

	if(!CheckAdminHref(href, href_list))
		return

	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN, TRUE))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/help_ticket/admin/AH = locate(ahelp_ref)
		if(istype(AH))
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "Ticket [ahelp_ref] has been deleted!")

	else if(href_list["ahelp_tickets"])
		GLOB.ahelp_tickets.BrowseTickets(usr)

	else if(href_list["stickyban"])
		stickyban(href_list["stickyban"],href_list)

	else if(href_list["getplaytimewindow"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["getplaytimewindow"]) in GLOB.mob_list
		if(!M)
			to_chat(usr, span_danger("ERROR: Mob not found."))
			return
		cmd_show_exp_panel(M.client)

	else if(href_list["forceevent"])
		if(!check_rights(R_FUN))
			return
		var/datum/round_event_control/E = locate(href_list["forceevent"]) in SSevents.control
		if(E)
			E.admin_setup(usr)
			var/datum/round_event/event = E.runEvent()
			if(event.announceWhen>0)
				event.processing = FALSE
				var/prompt = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No", "Cancel")
				switch(prompt)
					if("Yes")
						event.announceChance = 100
					if("Cancel")
						event.kill()
						return
					if("No")
						event.announceChance = 0
				event.on_admin_trigger()
				event.processing = TRUE
			message_admins("[key_name_admin(src.owner)] has triggered an event. ([E.name])")
			log_admin("[key_name(src.owner)] has triggered an event. ([E.name])")
		return

	else if(href_list["editrightsbrowser"])
		edit_admin_permissions(0)

	else if(href_list["editrightsbrowserlog"])
		edit_admin_permissions(1, href_list["editrightstarget"], href_list["editrightsoperation"], href_list["editrightspage"])

	if(href_list["editrightsbrowsermanage"])
		if(href_list["editrightschange"])
			change_admin_rank(ckey(href_list["editrightschange"]), href_list["editrightschange"], TRUE)
		else if(href_list["editrightsremove"])
			remove_admin(ckey(href_list["editrightsremove"]), href_list["editrightsremove"], TRUE)
		else if(href_list["editrightsremoverank"])
			remove_rank(href_list["editrightsremoverank"])
		edit_admin_permissions(2)

	else if(href_list["editrights"])
		edit_rights_topic(href_list)

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["call_shuttle"])
			if("1")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				SSshuttle.emergency.request()
				log_admin("[key_name(src.owner)] called the Emergency Shuttle.")
				message_admins(span_adminnotice("[key_name_admin(src.owner)] called the Emergency Shuttle to the station."))

			if("2")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_CALL)
						SSshuttle.emergency.cancel()
						log_admin("[key_name(src.owner)] sent the Emergency Shuttle back.")
						message_admins(span_adminnotice("[key_name_admin(src.owner)] sent the Emergency Shuttle back."))
					else
						SSshuttle.emergency.cancel()
						log_admin("[key_name(src.owner)] called the Emergency Shuttle.")
						message_admins(span_adminnotice("[key_name_admin(src.owner)] called the Emergency Shuttle to the station."))



	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))
			return

		var/timer = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", SSshuttle.emergency.timeLeft() ) as num|null
		if(!timer)
			return
		SSshuttle.emergency.setTimer(timer*10)
		log_admin("[key_name(src.owner)] edited the Emergency Shuttle's timeleft to [timer] seconds.")
		minor_announce("The emergency shuttle will reach its destination in [round(SSshuttle.emergency.timeLeft(600))] minutes.")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] edited the Emergency Shuttle's timeleft to [timer] seconds."))
	else if(href_list["trigger_centcom_recall"])
		if(!check_rights(R_ADMIN))
			return

		usr.client.trigger_centcom_recall()

	else if(href_list["delay_round_end"])
		if(!check_rights(R_ADMIN))
			return
		delay_round_end()

	else if(href_list["end_round"])
		if(!check_rights(R_ADMIN))
			return

		message_admins(span_adminnotice("[key_name_admin(src.owner)] is considering ending the round."))
		if(alert(usr, "This will end the round, are you SURE you want to do this?", "Confirmation", "Yes", "No") == "Yes")
			if(alert(usr, "Final Confirmation: End the round NOW?", "Confirmation", "Yes", "No") == "Yes")
				message_admins(span_adminnotice("[key_name_admin(src.owner)] has ended the round."))
				SSticker.force_ending = ADMIN_FORCE_END_ROUND //Yeah there we go APC destroyed mission accomplished
				return
			else
				message_admins(span_adminnotice("[key_name_admin(src.owner)] decided against ending the round."))
		else
			message_admins(span_adminnotice("[key_name_admin(src.owner)] decided against ending the round."))

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		var/delmob = FALSE
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")
				return
			if("Yes")
				delmob = TRUE

		log_admin("[key_name(src.owner)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]].; deletemob=[delmob]")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]].; deletemob=[delmob]"))
		switch(href_list["simplemake"])
			if("observer")
				M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/queen , null, null, delmob )
			if("praetorian")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/praetorian , null, null, delmob )
			if("sentinel")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")
				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")
				var/posttransformoutfit = usr.client.robust_dress_shop()
				if (!posttransformoutfit)
					return
				var/mob/living/carbon/human/newmob = M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
				if(posttransformoutfit && istype(newmob))
					newmob.equipOutfit(posttransformoutfit)
			if("slime")
				M.change_mob_type( /mob/living/simple_animal/slime , null, null, delmob )
			if("monkey")
				M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")
				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")
				M.change_mob_type( /mob/living/basic/pet/cat , null, null, delmob )
			if("runtime")
				M.change_mob_type( /mob/living/basic/pet/cat/runtime , null, null, delmob )
			if("corgi")
				M.change_mob_type( /mob/living/basic/pet/dog/corgi , null, null, delmob )
			if("ian")
				M.change_mob_type( /mob/living/basic/pet/dog/corgi/ian , null, null, delmob )
			if("pug")
				M.change_mob_type( /mob/living/basic/pet/dog/pug , null, null, delmob )
			if("crab")
				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")
				M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")
				M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")
				M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructjuggernaut")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/juggernaut , null, null, delmob )
			if("constructartificer")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/artificer , null, null, delmob )
			if("constructwraith")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/wraith , null, null, delmob )
			if("shade")
				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )

	else if(href_list["boot2"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["boot2"])
		if(ismob(M))
			if(!check_if_greater_rights_than(M.client))
				to_chat(usr, span_danger("Error: They have more rights than you do."))
				return
			if(alert(usr, "Kick [key_name(M)]?", "Confirm", "Yes", "No") != "Yes")
				return
			if(!M)
				to_chat(usr, span_danger("Error: [M] no longer exists!"))
				return
			if(!M.client)
				to_chat(usr, span_danger("Error: [M] no longer has a client!"))
				return
			to_chat(M, span_danger("You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"]."))
			log_admin("[key_name(src.owner)] kicked [key_name(M)].")
			message_admins(span_adminnotice("[key_name_admin(src.owner)] kicked [key_name_admin(M)]."))
			qdel(M.client)

	else if(href_list["addmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addmessage"]
		create_message("message", target_key, secret = 0)

	else if(href_list["addnote"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addnote"]
		create_message("note", target_key)

	else if(href_list["addwatch"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addwatch"]
		create_message("watchlist entry", target_key, secret = 1)

	else if(href_list["addmemo"])
		if(!check_rights(R_ADMIN))
			return
		create_message("memo", secret = 0, browse = 1)

	else if(href_list["addmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("message", secret = 0)

	else if(href_list["addnoteempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("note")

	else if(href_list["addwatchempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("watchlist entry", secret = 1)

	else if(href_list["deletemessage"])
		if(!check_rights(R_ADMIN))
			return
		var/safety = alert("Delete message/note?",,"Yes","No");
		if (safety == "Yes")
			var/message_id = href_list["deletemessage"]
			delete_message(message_id)

	else if(href_list["deletemessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/safety = alert("Delete message/note?",,"Yes","No");
		if (safety == "Yes")
			var/message_id = href_list["deletemessageempty"]
			delete_message(message_id, browse = TRUE)

	else if(href_list["editmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessage"]
		edit_message(message_id)

	else if(href_list["editmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageempty"]
		edit_message(message_id, browse = 1)

	else if(href_list["editmessageexpiry"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageexpiry"]
		edit_message_expiry(message_id)

	else if(href_list["editmessageexpiryempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageexpiryempty"]
		edit_message_expiry(message_id, browse = 1)

	else if(href_list["editmessageseverity"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageseverity"]
		edit_message_severity(message_id)

	else if(href_list["secretmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["secretmessage"]
		toggle_message_secrecy(message_id)

	else if(href_list["searchmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["searchmessages"]
		browse_messages(index = target)

	else if(href_list["nonalpha"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["nonalpha"]
		target = text2num(target)
		browse_messages(index = target)

	else if(href_list["showmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessages"]
		browse_messages(index = target)

	else if(href_list["showmemo"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("memo")

	else if(href_list["showwatch"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry")

	else if(href_list["showwatchfilter"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry", filter = 1)

	else if(href_list["showmessageckey"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessageckey"]
		var/agegate = TRUE
		if (href_list["showall"])
			agegate = FALSE
		browse_messages(target_ckey = target, agegate = agegate)

	else if(href_list["showmessageckeylinkless"])
		var/target = href_list["showmessageckeylinkless"]
		browse_messages(target_ckey = target, linkless = 1)

	else if(href_list["messageedits"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/db_query/query_get_message_edits = SSdbcore.NewQuery(
			"SELECT edits FROM [format_table_name("messages")] WHERE id = :message_id",
			list("message_id" = href_list["messageedits"])
		)
		if(!query_get_message_edits.warn_execute())
			qdel(query_get_message_edits)
			return
		if(query_get_message_edits.NextRow())
			var/edit_log = query_get_message_edits.item[1]
			if(!QDELETED(usr))
				var/datum/browser/browser = new(usr, "Note edits", "Note edits")
				browser.set_content(jointext(edit_log, ""))
				browser.open()
		qdel(query_get_message_edits)

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))
			return
		cmd_admin_mute(href_list["mute"], text2num(href_list["mute_type"]))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		log_admin("[key_name(src.owner)] attempting to monkeyize [key_name(H)].")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] attempting to monkeyize [key_name_admin(H)]."))
		H.monkeyize()

	else if(href_list["humanone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/monkey/Mo = locate(href_list["humanone"])
		if(!istype(Mo))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/monkey.")
			return

		log_admin("[key_name(src.owner)] attempting to humanize [key_name(Mo)].")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] attempting to humanize [key_name_admin(Mo)]."))
		Mo.humanize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/C = locate(href_list["corgione"])
		if(!istype(C))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon.")
			return

		log_admin("[key_name(src.owner)] attempting to corgize [key_name(C)].")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] attempting to corgize [key_name_admin(C)]."))
		C.corgize()


	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob.")

		var/speech = input("What will [key_name(M)] say?", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		M.say(speech, forced = "admin speech")
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(src.owner)] forced [key_name(M)] to say: [speech]")
		message_admins(span_adminnotice("[key_name_admin(src.owner)] forced [key_name_admin(M)] to say: [speech]"))

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return

		if(tgui_alert(usr, "Send [key_name(M)] to Prison?", "Message", list("Yes", "No")) != "Yes")
			return

		M.forceMove(pick(GLOB.prisonwarp))
		to_chat(M, span_adminnotice("You have been sent to Prison!"))

		log_admin("[key_name(src.owner)] has sent [key_name(M)] to Prison!")
		message_admins("[key_name_admin(src.owner)] has sent [key_name_admin(M)] to Prison!")

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendbacktolobby"])

		if(!isobserver(M))
			to_chat(usr, span_notice("You can only send ghost players back to the Lobby."))
			return

		if(!M.client)
			to_chat(usr, span_warning("[M] doesn't seem to have an active client."))
			return

		if(tgui_alert(usr, "Send [key_name(M)] back to Lobby?", "Message", list("Yes", "No")) != "Yes")
			return

		log_admin("[key_name(src.owner)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name(src.owner)] has sent [key_name(M)] back to the Lobby.")

		var/mob/dead/new_player/authenticated/NP = new()
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome1))
		spawn(50)
			to_chat(L, span_adminnotice("You have been sent to the Thunderdome."))
		log_admin("[key_name(src.owner)] has sent [key_name(L)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(src.owner)] has sent [key_name_admin(L)] to the thunderdome. (Team 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome2))
		spawn(50)
			to_chat(L, span_adminnotice("You have been sent to the Thunderdome."))
		log_admin("[key_name(src.owner)] has sent [key_name(L)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(src.owner)] has sent [key_name_admin(L)] to the thunderdome. (Team 2)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeadmin))
		spawn(50)
			to_chat(L, span_adminnotice("You have been sent to the Thunderdome."))
		log_admin("[key_name(src.owner)] has sent [key_name(L)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(src.owner)] has sent [key_name_admin(L)] to the thunderdome. (Admin.)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))
			return

		if(tgui_alert(usr, "Confirm?", "Message", list("Yes", "No")) != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		if(ishuman(L))
			var/mob/living/carbon/human/observer = L
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit/black(observer), ITEM_SLOT_ICLOTHING)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(observer), ITEM_SLOT_FEET)
		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeobserve))
		spawn(50)
			to_chat(L, span_adminnotice("You have been sent to the Thunderdome."))
		log_admin("[key_name(src.owner)] has sent [key_name(L)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(src.owner)] has sent [key_name_admin(L)] to the thunderdome. (Observer.)")

	else if(href_list["revive"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living.")
			return

		// We query the admin who sent the adminheal if they are sure
		if(tgui_alert(usr, "A full adminheal was called on [src], approve or deny?", "Aheal Query", buttons = list("Approve", "Deny")) != "Approve")
			return
		L.revive(ADMIN_HEAL_ALL)
		message_admins(span_danger("Admin [key_name_admin(src.owner)] healed / revived [key_name_admin(L)]!"))
		log_admin("[key_name(src.owner)] healed / Revived [key_name(L)].")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		message_admins(span_danger("Admin [key_name_admin(src.owner)] AIized [key_name_admin(H)]!"))
		log_admin("[key_name(src.owner)] AIized [key_name(H)].")
		H.AIize(TRUE, H.client)

	else if(href_list["makepai"])
		if(!check_rights(R_SPAWN))
			return
		var/mob/H = locate(href_list["makepai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		message_admins(span_danger("Admin [key_name_admin(src.owner)] PAI'd [key_name_admin(H)]!"))
		log_admin("[key_name(src.owner)] PAI'd [key_name(H)].")
		H.makePAI(TRUE)

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makeblob"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeblob"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_blobize(H)

	else if(href_list["makecluwne"])
		if(!check_rights(R_SPAWN))
			return
		var/mob/living/carbon/human/H = locate(href_list["makecluwne"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return
		message_admins("[key_name(src.owner)] cluwned [key_name(H)]")
		log_admin("[key_name(src.owner)] cluwned [key_name(H)]")
		H.cluwne()

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "This cannot be used on instances of type /mob/dead/new_player.")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservefollow"])
		admin_follow(locate(href_list["adminplayerobservefollow"]))

	else if(href_list["admingetmovable"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["admingetmovable"])
		if(QDELETED(AM))
			return
		AM.forceMove(get_turf(usr))

	else if(href_list["adminplayerobservecoodjump"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))
			C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		if(!check_rights(R_ADMIN))
			return
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		admin_more_info(locate(href_list["adminmoreinfo"]) in GLOB.mob_list)

	else if(href_list["addjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["addjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				job.total_positions += 1
				break

		src.manage_free_slots()


	else if(href_list["customjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["customjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				var/newtime = null
				newtime = input(usr, "How many jebs do you want?", "Add wanted posters", "[newtime]") as num|null
				if(!newtime)
					to_chat(src.owner, "Setting to amount of positions filled for the job")
					job.total_positions = job.current_positions
					break
				job.total_positions = newtime

		src.manage_free_slots()

	else if(href_list["removejobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Remove = href_list["removejobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Remove && job.get_spawn_position_count() - job.current_positions > 0)
				job.total_positions -= 1
				break

		src.manage_free_slots()

	else if(href_list["unlimitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Unlimit = href_list["unlimitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Unlimit)
				job.total_positions = -1
				break

		src.manage_free_slots()

	else if(href_list["limitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Limit = href_list["limitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Limit)
				job.total_positions = job.current_positions
				break

		src.manage_free_slots()


	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human.")
			return

		H.give_cookie(usr)
		SSblackbox.record_feedback("amount", "admin_cookies_spawned", 1)

	else if(href_list["adminsmite"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminsmite"]) in GLOB.mob_list
		if(!H || !istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.smite(H)

	else if(href_list["CentComReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["CentComReply"])
		usr.client.admin_headset_message(M, RADIO_CHANNEL_CENTCOM)

	else if(href_list["SyndicateReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["SyndicateReply"])
		usr.client.admin_headset_message(M, RADIO_CHANNEL_SYNDICATE)

	else if(href_list["HeadsetMessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["HeadsetMessage"])
		usr.client.admin_headset_message(M)

	else if(href_list["reject_custom_name"])
		if(!check_rights(R_ADMIN))
			return
		var/obj/item/station_charter/charter = locate(href_list["reject_custom_name"])
		if(istype(charter))
			charter.reject_proposed(usr)
	else if(href_list["jumpto"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["individuallog"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return

		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])
	else if(href_list["languagemenu"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["languagemenu"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		M.get_language_holder().open_language_menu(usr)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.HasRoundStarted())
			tgui_alert(usr,"The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			var/datum/mind/D = M
			if(!istype(D))
				to_chat(usr, "This can only be used on instances of type /mob and /mind")
				return
			else
				D.traitor_panel()
		else
			show_traitor_panel(M)

	else if(href_list["borgpanel"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["borgpanel"])
		if(!iscyborg(M))
			to_chat(usr, "This can only be used on cyborgs")
		else
			open_borgopanel(M)

	else if(href_list["initmind"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["initmind"])
		if(!ismob(M) || M.mind)
			to_chat(usr, "This can only be used on instances on mindless mobs")
			return
		M.mind_initialize()

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))
			return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))
			return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))
			return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))
			return
		return create_mob(usr)

	else if(href_list["dupe_marked_datum"])
		if(!check_rights(R_SPAWN))
			return
		return DuplicateObject(marked_datum, perfectcopy=1, newloc=get_turf(usr))

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			tgui_alert(usr,"The path list you sent is empty.")
			return
		if(length(paths) > 5)
			tgui_alert(usr, "Select fewer object types, (max 5).")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = clamp(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/obj_dir = text2num(href_list["object_dir"])
		if(obj_dir && !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = null
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","frompod","inhand","inmarked") ))
			where = "onfloor"


		switch(where)
			if("inhand")
				if (!iscarbon(usr) && !iscyborg(usr))
					to_chat(usr, "Can only spawn in hand when you're a carbon mob or cyborg.")
					where = "onfloor"
				target = usr

			if("onfloor", "frompod")
				switch(href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "You don't have any object marked. Abandoning spawn.")
					return
				else if(!istype(marked_datum, /atom))
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return
				else
					target = marked_datum

		var/obj/structure/closet/supplypod/centcompod/pod

		if(target)
			if(where == "frompod")
				pod = new()

			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O
						if(where == "frompod")
							O = new path(pod)
						else
							O = new path(target)

						if(!QDELETED(O))
							O.flags_1 |= ADMIN_SPAWNED_1
							if(obj_dir)
								O.setDir(obj_dir)
							if(obj_name)
								O.name = obj_name
								if(ismob(O))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(iscyborg(L))
									var/mob/living/silicon/robot/robot = L
									if(robot.model)
										robot.model.add_module(I, TRUE, TRUE)
										robot.activate_module(I)

		if(pod)
			new /obj/effect/pod_landingzone(target, pod)

		var/turf/T = get_turf(usr.loc) // get admin's LOC as a turf

		if (number == 1)
			log_admin("[key_name(src.owner)] created a [english_list(paths)] at [AREACOORD(T)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(src.owner)] created a [english_list(paths)]")
					break
		else
			log_admin("[key_name(src.owner)] created [number]ea [english_list(paths)] at [AREACOORD(T)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(src.owner)] created [number]ea [english_list(paths)]")
					break
		return

	else if(href_list["check_antagonist"])
		if(!check_rights(R_ADMIN))
			return
		usr.client.check_antagonists()

	else if(href_list["kick_all_from_lobby"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker.IsRoundInProgress())
			var/afkonly = text2num(href_list["afkonly"])
			if(tgui_alert(usr,"Are you sure you want to kick all [afkonly ? "AFK" : ""] clients from the lobby??","Message",list("Yes","Cancel")) != "Yes")
				to_chat(usr, "Kick clients from lobby aborted")
				return
			var/list/listkicked = kick_clients_in_lobby(span_danger("You were kicked from the lobby by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"]."), afkonly)

			var/strkicked = ""
			for(var/name in listkicked)
				strkicked += "[name], "
			message_admins("[key_name_admin(src.owner)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
			log_admin("[key_name(src.owner)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
		else
			to_chat(usr, "You may only use this when the game is running.")

	else if(href_list["set_selfdestruct_code"])
		if(!check_rights(R_ADMIN))
			return
		var/code = random_code(5)
		for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
			SD.r_code = code
		message_admins("[key_name_admin(src.owner)] has set the self-destruct \
			code to \"[code]\".")

	else if(href_list["add_station_goal"])
		if(!check_rights(R_ADMIN))
			return
		var/list/type_choices = typesof(/datum/station_goal)
		var/picked = input("Choose goal type") in type_choices|null
		if(!picked)
			return
		var/datum/station_goal/G = new picked()
		if(picked == /datum/station_goal)
			var/newname = capped_input(usr, "Enter goal name:")
			if(!newname)
				return
			G.name = newname
			var/description = capped_multiline_input(usr, "Enter CentCom message contents:")
			if(!description)
				return
			G.report_message = description
		message_admins("[key_name(src.owner)] created \"[G.name]\" station goal.")
		modify_goals()

	else if(href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, span_warning("That runtime viewer no longer exists."))
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])

	else if(href_list["showrelatedacc"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["client"]) in GLOB.clients_unsafe
		var/thing_to_check
		if(href_list["showrelatedacc"] == "cid")
			thing_to_check = C.related_accounts_cid
		else
			thing_to_check = C.related_accounts_ip
		thing_to_check = splittext(thing_to_check, ", ")


		var/list/dat = list("Related accounts by [uppertext(href_list["showrelatedacc"])]:")
		dat += thing_to_check

		var/datum/browser/browser = new(usr, "related_[C]", "[C.ckey] Related Accounts", 420, 300)
		browser.set_content(dat.Join("<br>"))
		browser.open()

	else if(href_list["centcomlookup"])
		if(!check_rights(R_ADMIN))
			return

		if(!CONFIG_GET(string/centcom_ban_db))
			to_chat(usr, span_warning("CentCom Galactic Ban DB is disabled!"))
			return

		var/ckey = href_list["centcomlookup"]

		// Make the request
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
		request.begin_async()
		UNTIL(request.is_complete() || !usr)
		if (!usr)
			return
		var/datum/http_response/response = request.into_response()

		var/list/bans

		var/list/dat = list()

		if(response.errored)
			dat += "<br>Failed to connect to CentCom."
		else if(response.status_code != 200)
			dat += "<br>Failed to connect to CentCom. Status code: [response.status_code]"
		else
			if(response.body == "[]")
				dat += "<center><b>0 bans detected for [ckey]</b></center>"
			else
				bans = json_decode(response.body)
				dat += "<center><b>[bans.len] ban\s detected for [ckey]</b></center>"
				for(var/list/ban in bans)
					dat += "<b>Server: </b> [sanitize(ban["sourceName"])]<br>"
					dat += "<b>RP Level: </b> [sanitize(ban["sourceRoleplayLevel"])]<br>"
					dat += "<b>Type: </b> [sanitize(ban["type"])]<br>"
					dat += "<b>Banned By: </b> [sanitize(ban["bannedBy"])]<br>"
					dat += "<b>Reason: </b> [sanitize(ban["reason"])]<br>"
					dat += "<b>Datetime: </b> [sanitize(ban["bannedOn"])]<br>"
					var/expiration = ban["expires"]
					dat += "<b>Expires: </b> [expiration ? "[sanitize(expiration)]" : "Permanent"]<br>"
					if(ban["type"] == "job")
						dat += "<b>Jobs: </b> "
						var/list/jobs = ban["jobs"]
						dat += sanitize(jobs.Join(", "))
						dat += "<br>"
					dat += "<hr>"

		var/datum/browser/popup = new(usr, "centcomlookup-[ckey]", "<div align='center'>Central Command Galactic Ban Database</div>", 700, 600)
		popup.set_content(dat.Join())
		popup.open(FALSE)

	else if(href_list["modantagrep"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_rep(C, href_list["modantagrep"])
		show_player_panel(M)

	else if(href_list["slowquery"])
		if(!check_rights(R_ADMIN))
			return

		var/answer = href_list["slowquery"]
		if(answer == "yes")
			log_query_debug("[usr.key] | Reported a server hang")
			if(tgui_alert(usr, "Did you just press any admin buttons?", "Query server hang report", list("Yes", "No")) == "Yes")
				var/response = input(usr,"What were you just doing?","Query server hang report") as null|text
				if(response)
					log_query_debug("[usr.key] | [response]")
		else if(answer == "no")
			log_query_debug("[usr.key] | Reported no server hang")

	else if(href_list["ctf_toggle"])
		if(!check_rights(R_ADMIN))
			return
		toggle_id_ctf(usr, "centcom")

	else if(href_list["rebootworld"])
		if(!check_rights(R_ADMIN))
			return
		var/confirm = tgui_alert(usr,"Are you sure you want to reboot the server?", "Confirm Reboot", list("Yes", "No"))
		if(confirm != "Yes")
			return
		restart()

	else if(href_list["check_teams"])
		if(!check_rights(R_ADMIN))
			return
		check_teams()

	else if(href_list["team_command"])
		if(!check_rights(R_ADMIN))
			return
		switch(href_list["team_command"])
			if("create_team")
				admin_create_team(usr)
			if("rename_team")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_rename(usr)
			if("communicate")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_communicate(usr)
			if("delete_team")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_delete(usr)
			if("add_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_add_objective(usr)
			if("edit_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/objective/O = locate(href_list["tobjective"]) in T.objectives
				if(O)
					T.admin_edit_objective(usr,O)
			if("remove_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/objective/O = locate(href_list["tobjective"]) in T.objectives
				if(O)
					T.admin_remove_objective(usr,O)
			if("add_member")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_add_member(usr)
			if("remove_member")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/mind/M = locate(href_list["tmember"]) in T.members
				if(M)
					T.admin_remove_member(usr,M)
		check_teams()

	else if(href_list["newbankey"])
		var/player_key = href_list["newbankey"]
		var/player_ip = href_list["newbanip"]
		var/player_cid = href_list["newbancid"]
		ban_panel(player_key, player_ip, player_cid)

	else if(href_list["intervaltype"]) //check for ban panel, intervaltype is used as it's the only value which will always be present
		if(href_list["roleban_delimiter"])
			ban_parse_href(href_list)
		else
			ban_parse_href(href_list, TRUE)

	else if(href_list["searchunbankey"] || href_list["searchunbanadminkey"] || href_list["searchunbanip"] || href_list["searchunbancid"])
		var/player_key = href_list["searchunbankey"]
		var/admin_key = href_list["searchunbanadminkey"]
		var/player_ip = href_list["searchunbanip"]
		var/player_cid = href_list["searchunbancid"]
		unban_panel(player_key, admin_key, player_ip, player_cid)

	else if(href_list["unbanpagecount"])
		var/page = href_list["unbanpagecount"]
		var/player_key = href_list["unbankey"]
		var/admin_key = href_list["unbanadminkey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		unban_panel(player_key, admin_key, player_ip, player_cid, page)

	else if(href_list["editbanid"])
		var/edit_id = href_list["editbanid"]
		var/player_key = href_list["editbankey"]
		var/player_ip = href_list["editbanip"]
		var/player_cid = href_list["editbancid"]
		var/role = href_list["editbanrole"]
		var/duration = href_list["editbanduration"]
		var/applies_to_admins = text2num(href_list["editbanadmins"])
		var/reason = rustg_url_decode(href_list["editbanreason"])
		var/page = href_list["editbanpage"]
		var/admin_key = href_list["editbanadminkey"]
		old_ban_panel(player_key, player_ip, player_cid, role, duration, applies_to_admins, reason, edit_id, page, admin_key)

	else if(href_list["unbanid"])
		var/ban_id = href_list["unbanid"]
		var/player_key = href_list["unbankey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		var/role = href_list["unbanrole"]
		var/page = href_list["unbanpage"]
		var/admin_key = href_list["unbanadminkey"]
		unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)

	else if(href_list["unbanlog"])
		var/ban_id = href_list["unbanlog"]
		ban_log(ban_id)

	else if(href_list["modantagtokens"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_tokens(C, href_list["modantagtokens"])
		show_player_panel(M)


	else if(href_list["retrieveboh"])
		var/obj/boh_tear/tear = locate(href_list["retrieveboh"])
		if(!tear)
			to_chat(usr, "Either items were already retrieved or 10 minutes have passed and they were deleted.")
			return
		var/confirm = alert("This will teleport all items consumed to the BoH tear back to the BoH tear original location, and delete the BoH if it still exists. Are you sure?", "Confirm Damage Control", "Yes", "No")
		if(confirm != "Yes")
			return
		var/turf/T = get_turf(tear.old_loc)
		message_admins("The items consumed by the BoH tear at [ADMIN_VERBOSEJMP(T)] were retrieved by [key_name_admin(src.owner)].")
		tear.investigate_log("Items consumed at [AREACOORD(T)] retrieved by [key_name(src.owner)].", INVESTIGATE_ENGINES)
		tear.retrieve_consumed_items()

	else if(href_list["beakerpanel"])
		beaker_panel_act(href_list)

	else if(href_list["reloadpolls"])
		GLOB.polls.Cut()
		GLOB.active_polls.Cut()
		GLOB.poll_options.Cut()
		load_poll_data()
		poll_list_panel()

	else if(href_list["newpoll"])
		poll_management_panel()

	else if(href_list["editpoll"])
		var/datum/poll_question/poll = locate(href_list["editpoll"]) in GLOB.polls
		poll_management_panel(poll)

	else if(href_list["deletepoll"])
		var/datum/poll_question/poll = locate(href_list["deletepoll"]) in GLOB.polls
		poll.delete_poll()
		poll_list_panel()

	else if(href_list["resultspoll"])
		var/datum/poll_question/poll = locate(href_list["resultspoll"]) in GLOB.polls
		var/start_index = text2num(href_list["startat"]) || 0
		poll_results_panel(poll, start_index)

	else if(href_list["initializepoll"])
		poll_parse_href(href_list)

	else if(href_list["submitpoll"])
		var/datum/poll_question/poll = locate(href_list["submitpoll"]) in GLOB.polls
		poll_parse_href(href_list, poll)

	else if(href_list["clearpollvotes"])
		var/datum/poll_question/poll = locate(href_list["clearpollvotes"]) in GLOB.polls
		poll.clear_poll_votes()
		poll_management_panel(poll)

	else if(href_list["addpolloption"])
		var/datum/poll_question/poll = locate(href_list["addpolloption"]) in GLOB.polls
		poll_option_panel(poll)

	else if(href_list["editpolloption"])
		var/datum/poll_option/option = locate(href_list["editpolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["parentpoll"]) in GLOB.polls
		poll_option_panel(poll, option)

	else if(href_list["deletepolloption"])
		var/datum/poll_option/option = locate(href_list["deletepolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = option.delete_option()
		poll_management_panel(poll)

	else if(href_list["submitoption"])
		var/datum/poll_option/option = locate(href_list["submitoption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["submitoptionpoll"]) in GLOB.polls
		poll_option_parse_href(href_list, poll, option)

	else if (href_list["interview"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/interview/I = locate(href_list["interview"])
		if (I)
			I.ui_interact(usr)

	else if (href_list["interview_man"])
		if(!check_rights(R_ADMIN))
			return
		GLOB.interviews.ui_interact(usr)

	else if(href_list["tag_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_tag = locate(href_list["tag_datum"])
		if(!datum_to_tag)
			return
		return add_tagged_datum(datum_to_tag)

	else if(href_list["del_tag"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_remove = locate(href_list["del_tag"])
		if(!datum_to_remove)
			return
		return remove_tagged_datum(datum_to_remove)

	else if(href_list["show_tags"])
		if(!check_rights(R_ADMIN))
			return
		return display_tags()

	else if(href_list["mark_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_mark = locate(href_list["mark_datum"])
		if(!datum_to_mark)
			return
		return usr.client?.mark_datum(datum_to_mark)

	else if(href_list["backstory_select"])
		if(!check_rights(R_ADMIN))
			return
		var/list/L = locate(href_list["backstory_select"])
		var/choice = input(usr, "Select backstory to use", "Select backstory") as null|anything in L
		if(choice != null)
			GLOB.fugitive_backstory_selection = list(choice)
			message_admins("[key_name_admin(src.owner)] selected backstory: [choice]")
			log_admin("[key_name(src.owner)] selected backstory: [choice]")

	else if(href_list["show_paper"])
		if(!check_rights(R_ADMIN))
			return

		var/obj/item/paper/paper_to_show = locate(href_list["show_paper"])
		if(!istype(paper_to_show))
			return
		paper_to_show.ui_interact(usr)

	else if(href_list["force_cryo"])
		if(!check_rights(R_ADMIN))
			return
		var/param = href_list["force_cryo"]
		// If it's a direct reference to a mob, use that.
		var/mob/living/target = locate(param)
		if(!istype(target))
			// Might be a ckey? Let's see.
			target = get_ckey_last_living(target)
			if(!istype(target))
				to_chat(usr, span_warning("This can only be used on instances of type /mob/living."))
				return
		var/method = tgui_alert(usr, "Select force-cryo method", "Cryo Express", list("Centcom Pod (recommended)", "Instant", "Cancel"))
		switch(method)
			if("Centcom Pod (recommended)")
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(force_cryo), target)
			if("Instant")
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(instant_force_cryo), target)
			else
				return
		message_admins("[key_name_admin(src.owner)] force-cryoed [ADMIN_LOOKUPFLW(target)]].")
		log_admin("[key_name(src.owner)] force-cryoed [key_name(target)]].")
