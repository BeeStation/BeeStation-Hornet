//Not using datum.vv_do_topic for very basic/low level debug things, incase the datum's vv_do_topic is runtiming/whatnot.
/client/proc/vv_do_basic(datum/target, href_list)
	var/target_var = GET_VV_VAR_TARGET
	if(check_rights(R_VAREDIT))
		if(target_var)
			if(href_list[VV_HK_BASIC_EDIT])
				if(!modify_variables(target, target_var, 1))
					return
				switch(target_var)
					if("name")
						vv_update_display(target, "name", "[target]")
					if("dir")
						var/atom/A = target
						if(istype(A))
							vv_update_display(target, "dir", dir2text(A.dir) || A.dir)
					if("ckey")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "ckey", L.ckey || "No ckey")
					if("real_name")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "real_name", L.real_name || "No real name")
			if(href_list[VV_HK_BASIC_CHANGE])
				modify_variables(target, target_var, 0)
			if(href_list[VV_HK_BASIC_MASSEDIT])
				cmd_mass_modify_object_variables(target, target_var)

	if(check_rights(R_DEBUG) && href_list[VV_HK_EXPOSE])
		var/value = vv_get_value(VV_CLIENT)
		if(value["class"] != VV_CLIENT)
			return
		var/client/C = value["value"]
		if(!C)
			return
		if(!target)
			to_chat(usr, span_warning("The object you tried to expose to [C] no longer exists (nulled or hard-deled)"))
			return
		message_admins("[key_name_admin(usr)] Showed [key_name_admin(C)] a <a href='byond://?_src_=vars;Vars=[REF(target)]'>VV window</a>")
		log_admin("Admin [key_name(usr)] Showed [key_name(C)] a VV window of a [target]")
		to_chat(C, "[holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window")
		C.debug_variables(target)

	if(check_rights(R_DEBUG) && href_list[VV_HK_DELETE])
		var/X
		var/Y
		var/Z
		if(isturf(target))
			var/turf/T = target
			X = T.x
			Y = T.y
			Z = T.z
		if(!usr.client.admin_delete(target))
			return
		if(X)	// Enough to check if we had a turf
			usr.client.debug_variables(locate(X,Y,Z)) // Show the turf that replaced it

	if(href_list[VV_HK_MARK] && check_rights(R_VAREDIT))
		usr.client.mark_datum(target)
	if(href_list[VV_HK_TAG])
		usr.client.tag_datum(target)
	if(href_list[VV_HK_ADDCOMPONENT])
		if(!check_rights(R_VAREDIT))
			return
		var/list/names = list()
		var/list/componentsubtypes = sort_list(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))

		var/result = tgui_input_list(usr, "Choose a component/element to add", "Add Component", names)
		if(isnull(result))
			return
		if(!usr || result == "---Components---" || result == "---Elements---")
			return

		if(QDELETED(target))
			to_chat(usr, "That thing doesn't exist anymore!")
			return

		var/list/lst = get_callproc_args()
		if(!lst)
			return

		var/datumname = "error"
		lst.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(lst)
		else
			datumname = "element"
			target._AddElement(lst)
		log_admin("[key_name(usr)] has added [result] [datumname] to [target].")
		message_admins(span_notice("[key_name_admin(usr)] has added [result] [datumname] to [target]."))

	if(href_list[VV_HK_MODIFY_GREYSCALE] && check_rights(NONE))
		var/datum/greyscale_modify_menu/menu = new(target, usr, SSgreyscale.configurations)
		menu.Unlock()
		menu.ui_interact(usr)

	if(href_list[VV_HK_CALLPROC])
		usr.client.callproc_datum(target)

