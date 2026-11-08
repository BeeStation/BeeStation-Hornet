//DO NOT ADD MORE TO THIS FILE.
//Use vv_do_topic() for datums!
/client/proc/view_var_Topic(href, href_list, hsrc)
	if( (usr.client != src) || !src.holder || !holder.CheckAdminHref(href, href_list))
		return
	var/target = GET_VV_TARGET
	var/vv_refresh_target /// If this var has a reference, vv window will be auto-refreshed

	vv_do_basic(target, href_list, href)
	// for non-standard special list
	if(href_list["dmlist_origin_ref"])
		var/datum/located = locate(href_list["dmlist_origin_ref"])
		var/dmlist_varname = href_list["dmlist_varname"]
		if(!isdatum(located) || !GLOB.vv_special_lists[dmlist_varname] || !(dmlist_varname in located.vars))
			return
		if(GET_VV_VAR_TARGET || href_list[VV_HK_DO_LIST_EDIT]) // if href_list["targetvar"] exists, we do vv_edit to list. if not, it's just viewing.
			vv_do_list(located.vars[dmlist_varname], href_list)
		GLOB.vv_ghost.mark_special(href_list["dmlist_origin_ref"], dmlist_varname)
		vv_refresh_target = GLOB.vv_ghost
	// for standard /list
	else if(islist(target))
		vv_do_list(target, href_list)
		GLOB.vv_ghost.mark_list(target)
		vv_refresh_target = GLOB.vv_ghost
	// for standard /datum
	else if(istype(target, /datum))
		var/datum/D = target
		D.vv_do_topic(href_list)

	// if there is no `href_list["target"]`, we check `href_list["Vars"]` to see if we want see it
	if(!target && !vv_refresh_target)
		vv_refresh_target = locate(href_list["Vars"])
		// "Vars" means we want to view-variables this thing.

	if(vv_refresh_target)
		debug_variables(vv_refresh_target)
		return

//Stuff below aren't in dropdowns/etc.

	if(check_rights(R_VAREDIT))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and manifest records).

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

			var/mob/living/carbon/human/Mo = locate(href_list["makehuman"]) in GLOB.mob_list
			if(!ismonkey(Mo))
				to_chat(usr, "This can only be done to monkeys")
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
					L.adjustBruteLoss(amount,TRUE,TRUE)
					newamt = L.getBruteLoss()
				if("fire")
					L.adjustFireLoss(amount,TRUE,TRUE)
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
