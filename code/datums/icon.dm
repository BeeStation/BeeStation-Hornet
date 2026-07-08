#define CHECK_NULL(thing) isnull(thing) ? #thing+" = null" : #thing+" = [istext(thing) ? "\"[thing]\"" : thing]"
/icon
	/**
	 * Because icon instances are essentially raw image data, they don't have any extra variables.
	 * So we have to copy the arguments from New() that we care about into our own vars.
	 */

	/// The file this icon is derived from. i.e: 'icons/mob/ai.dmi'
	var/file_reference
	/// The icon_state, dir, frame, and moving vars of this icon in a format used by VV.
	var/state_reference
	/// Used to track the amount of times an icon has been "copied". i.e: icon(icon(icon(icon('some.dmi'))))
	var/revise_count

	/// A fake file name used when browsing this icon in VV. Only set on VV.
	var/vv_rsc_code

// Usually, this is not a good idea to do this, but it's for putting a hint when /icon is created, so that we can investigate what /icon a thing holds.
/icon/New(icon/icon, icon_state, dir, frame, moving)
	. = ..()
	if(is_icondatum(icon) && icon.file_reference)
		revise_count = icon.revise_count+1 // when /icon was created through an /icon, we might want to check the recursive count
		file_reference = icon.file_reference
		state_reference = "<li>[CHECK_NULL(icon_state)]</li><li>[CHECK_NULL(dir)]</li><li>[CHECK_NULL(frame)]</li><li>[CHECK_NULL(moving)]</li>"
	else if(icon_state || dir || frame || moving) // If any of these value is given, DM refuses to save 'something.dmi', and it decides to make a new /icon instance.
		file_reference = "[icon]" || "Error: dmi unknown" // if dmi file name is zero string, we will record the file reference name is not trackable.
		state_reference = "<li>[CHECK_NULL(icon_state)]</li><li>[CHECK_NULL(dir)]</li><li>[CHECK_NULL(frame)]</li><li>[CHECK_NULL(moving)]</li>"

// "[icon_instance]" returns zero string. This suggests a hint at least.
/icon/proc/operator""()
	return "/icon [FAST_REF(src)]"

/icon/proc/get_vv_data()
	return "<ul class='data-column'><li>file: '[file_reference]'</li>[revise_count ? "<li>revise_count = [revise_count]<li>" : ""]</li>[state_reference]</ul>"

// These exist here because long text is difficult to read
#define VV_ICON_VIEW_IMAGE "\[<a href='byond://?_src_="+VV_HK_VIEW_ICON+";[HrefToken()];dm_ref=[FAST_REF(src)];file_ref=[file_reference];'>View icon file</a>\]"
#define VV_ICON_MARK_DATUM "\[<a href='byond://?_src_=vars;[HrefToken()];[VV_HK_TAG]=TRUE;[VV_HK_TARGET]=[FAST_REF(src)];'>Tag datum (this icon)</a>\]"
/icon/proc/write_vv_button()
	return VV_ICON_VIEW_IMAGE + " " + VV_ICON_MARK_DATUM

/proc/send_vv_icon_to_user(mob/user, href, href_list)
	var/dm_ref = href_list["dm_ref"] // used to locate an /icon instance.
	var/file_ref = href_list["file_ref"]  // used to verify vv action - file_ref is to prevent href exploit.
	if(isnull(user) || !istext(dm_ref) || !istext(file_ref))
		return
	var/client/client = user.client
	if(!client)
		return

	// exploit check
	if(!client?.holder?.CheckAdminHref(href, href_list))
		message_admins("[client.key] has attempted to call debug proc : send_vv_icon_to_user()")
		log_admin("[client.key] tried to call debug proc : send_vv_icon_to_user()")
		return

	var/icon/located_icon = locate(dm_ref)
	if(isnull(located_icon) || located_icon.file_reference != file_ref)
		return

	if(isnull(located_icon.vv_rsc_code))
		located_icon.vv_rsc_code = "[FAST_REF(located_icon)][rand(1, 10000)].png"
	user << browse_rsc(located_icon, located_icon.vv_rsc_code)
	user << browse("<!DOCTYPE html><html><head>[located_icon.file_reference]</head></br><body><img class='icon' style='border: 1px solid #000000;' src=\"[located_icon.vv_rsc_code]\"></body></html>","window=[located_icon.vv_rsc_code];size=[max(300, located_icon.Width()+50)]x[max(300, located_icon.Height()+50)]")

#undef CHECK_NULL
#undef VV_ICON_VIEW_IMAGE
#undef VV_ICON_MARK_DATUM
