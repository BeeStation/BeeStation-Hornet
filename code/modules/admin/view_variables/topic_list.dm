//LISTS - CAN NOT DO VV_DO_TOPIC BECAUSE LISTS AREN'T DATUMS :(
/client/proc/vv_do_list(list/target, href_list)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_adminprefix("Advanced ProcCall detected - You shouldn't call /vv_do_list() directly."))
		return
	var/target_index = text2num(GET_VV_VAR_TARGET)
	if(check_rights(R_VAREDIT))
		var/dmlist_varname = href_list["dmlist_varname"]
		if(dmlist_varname)
			var/dmlist_secure_level = GLOB.vv_special_lists[dmlist_varname]
			if(isnull(dmlist_secure_level)) // href protection to make sure
				log_admin("[key_name(src)] attempted to edit a special list ([dmlist_varname]), but this doesn't exist.")
				return
			else if(dmlist_secure_level == VV_LIST_EDITABLE)
				log_world("### vv_do_list() called: [src] attempted to edit a special list ([dmlist_varname]) Security-level:[dmlist_secure_level](allowed)")
				log_admin("[key_name(src)] attempted to edit a special list ([dmlist_varname]) Security-level:[dmlist_secure_level](allowed)")
			else // fuck you exploiters
				log_world("### vv_do_list() called: [src] attempted to edit a special list ([dmlist_varname]), but denied due to the Security-level:[dmlist_secure_level]")
				log_admin("[key_name(src)] attempted to edit a special list ([dmlist_varname]), but denied due to the Security-level:[dmlist_secure_level]")
				message_admins("[key_name_admin(src)] attempted to edit a special list ([dmlist_varname]), but denied due to the Security-level:[dmlist_secure_level]. Bonk this guy.")
				return
		if(target_index)
			if(href_list[VV_HK_LIST_EDIT])
				mod_list(target, null, "list", "contents", target_index, autodetect_class = TRUE)
			if(href_list[VV_HK_LIST_CHANGE])
				mod_list(target, null, "list", "contents", target_index, autodetect_class = FALSE)
			if(href_list[VV_HK_LIST_REMOVE])
				var/variable = target[target_index]
				var/prompt = alert("Do you want to remove item number [target_index] from list?", "Confirm", "Yes", "No")
				if (prompt != "Yes")
					return
				target.Cut(target_index, target_index+1)
				log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")
				log_admin("[key_name(src)] modified list's contents: REMOVED=[variable]")
				message_admins("[key_name_admin(src)] modified list's contents: REMOVED=[variable]")
		if(href_list[VV_HK_LIST_ADD])
			mod_list_add(target, null, "list", "contents")
		if(href_list[VV_HK_LIST_ERASE_DUPES])
			unique_list_in_place(target)
			log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")
			log_admin("[key_name(src)] modified list's contents: CLEAR DUPES")
			message_admins("[key_name_admin(src)] modified list's contents: CLEAR DUPES")
		if(href_list[VV_HK_LIST_ERASE_NULLS])
			list_clear_nulls(target)
			log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")
			log_admin("[key_name(src)] modified list's contents: CLEAR NULLS")
			message_admins("[key_name_admin(src)] modified list's contents: CLEAR NULLS")
		if(href_list[VV_HK_LIST_SET_LENGTH])
			var/value = vv_get_value(VV_NUM)
			if (value["class"] != VV_NUM || value["value"] > max(50000, target.len))			//safety - would rather someone not put an extra 0 and erase the server's memory lmao.
				return
			target.len = value["value"]
			log_world("### ListVarEdit by [src]: /list len: [target.len]")
			log_admin("[key_name(src)] modified list's len: [target.len]")
			message_admins("[key_name_admin(src)] modified list's len: [target.len]")
		if(href_list[VV_HK_LIST_SHUFFLE])
			shuffle_inplace(target)
			log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")
			log_admin("[key_name(src)] modified list's contents: SHUFFLE")
			message_admins("[key_name_admin(src)] modified list's contents: SHUFFLE")
