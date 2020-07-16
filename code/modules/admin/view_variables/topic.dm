//DO NOT ADD MORE TO THIS FILE.
//Use vv_do_topic() for datums!
/client/proc/view_var_Topic(href, href_list, hsrc)
	if( (usr.client != src) || !src.holder || !holder.CheckAdminHref(href, href_list))
		return
	var/target = GET_VV_TARGET
	vv_do_basic(target, href_list, href)
	if(istype(target, /datum))
		var/datum/D = target
		D.vv_do_topic(href_list)
	else if(islist(target))
		vv_do_list(target, href_list)
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

//Stuff below aren't in dropdowns/etc.

	if(check_rights(R_VAREDIT))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).

		if(href_list["rename"])
			if(!check_rights(NONE))
				return

			var/mob/M = locate(href_list["rename"]) in GLOB.mob_list
			if(!istype(M))
				to_chat(usr, "This can only be used on instances of type /mob")
				return

			var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
			if( !new_name || !M )
				return

			message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
			M.fully_replace_character_name(M.real_name,new_name)
			vv_update_display(M, "name", new_name)
			vv_update_display(M, "real_name", M.real_name || "No real name")

		else if(href_list["rotatedatum"])
			if(!check_rights(NONE))
				return

			var/atom/A = locate(href_list["rotatedatum"])
			if(!istype(A))
				to_chat(usr, "This can only be done to instances of type /atom")
				return

			switch(href_list["rotatedir"])
				if("right")
					A.setDir(turn(A.dir, -45))
				if("left")
					A.setDir(turn(A.dir, 45))
			vv_update_display(A, "dir", dir2text(A.dir))


		else if(href_list["makehuman"])
			if(!check_rights(R_SPAWN))
				return

			var/mob/living/carbon/monkey/Mo = locate(href_list["makehuman"]) in GLOB.mob_list
			if(!istype(Mo))
				to_chat(usr, "This can only be done to instances of type /mob/living/carbon/monkey")
				return

			if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
				return
			if(!Mo)
				to_chat(usr, "Mob doesn't exist anymore")
				return
			holder.Topic(href, list("humanone"=href_list["makehuman"]))

		else if(href_list["adjustDamage"] && href_list["mobToDamage"])
			if(!check_rights(NONE))
				return

			var/mob/living/L = locate(href_list["mobToDamage"]) in GLOB.mob_list
			if(!istype(L))
				return

			var/Text = href_list["adjustDamage"]

			var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

			if(!L)
				to_chat(usr, "Mob doesn't exist anymore")
				return

			var/newamt
			switch(Text)
				if("brute")
					L.adjustBruteLoss(amount)
					newamt = L.getBruteLoss()
				if("fire")
					L.adjustFireLoss(amount)
					newamt = L.getFireLoss()
				if("toxin")
					L.adjustToxLoss(amount)
					newamt = L.getToxLoss()
				if("oxygen")
					L.adjustOxyLoss(amount)
					newamt = L.getOxyLoss()
				if("brain")
					L.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount)
					newamt = L.getOrganLoss(ORGAN_SLOT_BRAIN)
				if("clone")
					L.adjustCloneLoss(amount)
					newamt = L.getCloneLoss()
				if("stamina")
					L.adjustStaminaLoss(amount)
					newamt = L.getStaminaLoss()
				else
					to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
					return

			if(amount != 0)
				var/log_msg = "[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]"
				message_admins("[key_name(usr)] dealt [amount] amount of [Text] damage to [ADMIN_LOOKUPFLW(L)]")
				log_admin(log_msg)
				admin_ticket_log(L, "<font color='blue'>[log_msg]</font>")
				vv_update_display(L, Text, "[newamt]")


	//Finally, refresh if something modified the list.
	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(istype(DAT, /datum) || istype(DAT, /client))
			debug_variables(DAT)

/datum/trigg_variables/proc/view_var_Topic2(action, list/params)
	if( (usr.client != C) || !C.holder )
		return //This is VV, not meant to be called by anything else.

	params["admin_token"]=RawHrefToken() // Think there have already been enough permission and sanity checks to safely do this
	var/target = GET_VV_TARGET2
	C.vv_do_basic2(target, action, params)

	// This goes only one of two ways, partner:
	// Ya either gave me some type of datum,
	// in which case we take advantage of
	// Object Oriented Programming...
	// Or ya gave me a list, which ain't a datum.
	if(istype(target, /datum))
		var/datum/D = target
		D.vv_do_topic2(action, params)
	else if(islist(target))
		C.vv_do_list2(target, action, params)

	switch(action)
		if("refresh")
			update_static_data(usr)
			return TRUE

		if("view")
			C.trigg_VV(target)

	//Actions below aren't in dropdowns/etc.
	if(check_rights(R_VAREDIT))
		switch(action)
			//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
			if("rename")
				if(!check_rights(NONE))
					return

				var/mob/M = target
				if(!istype(M))
					to_chat(usr, "This can only be used on instances of type /mob")
					return

				var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
				if( !new_name || !M )
					return

				message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
				M.fully_replace_character_name(M.real_name,new_name)
				// C.vv_update_display(M, "name", new_name)
				// C.vv_update_display(M, "real_name", M.real_name || "No real name")
				return TRUE

			if("rotate")
				if(!check_rights(NONE))
					return

				var/atom/A = D
				if(!istype(A))
					to_chat(usr, "This can only be done to instances of type /atom")
					return

				switch(params["dir"])
					if("right")
						A.setDir(turn(A.dir, -45))
					if("left")
						A.setDir(turn(A.dir, 45))
				// C.vv_update_display(A, "dir", dir2text(A.dir))
				return TRUE

			if("adjustdamage")
				if(!check_rights(NONE))
					return

				var/mob/living/L = target
				if(!istype(L))
					return

				var/Text = params["type"]
				var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

				if(!L)
					to_chat(usr, "This Mob doesn't exist anymore.")
					return

				switch(Text)
					if("brute")
						L.adjustBruteLoss(amount, forced=TRUE)
					if("fire")
						L.adjustFireLoss(amount, forced=TRUE)
					if("toxin")
						L.adjustToxLoss(amount, forced=TRUE)
					if("oxygen")
						L.adjustOxyLoss(amount, forced=TRUE)
					if("brain")
						L.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount)
					if("clone")
						L.adjustCloneLoss(amount, forced=TRUE)
					if("stamina")
						L.adjustStaminaLoss(amount, forced=TRUE)
					else
						to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
						return

				if(amount != 0)
					var/log_msg = "[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]"
					message_admins("[key_name(usr)] dealt [amount] amount of [Text] damage to [ADMIN_LOOKUPFLW(L)]")
					log_admin(log_msg)
					admin_ticket_log(L, "<font color='blue'>[log_msg]</font>")
					return TRUE


	//Finally, refresh if something modified the list.
	/*
	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(istype(DAT, /datum) || istype(DAT, /client))
			debug_variables(DAT)
	*/
