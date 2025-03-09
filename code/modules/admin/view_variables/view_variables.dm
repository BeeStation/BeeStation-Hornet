#define ICON_STATE_CHECKED 1 /// this dmi is checked. We don't check this one anymore.
#define ICON_STATE_NULL 2 /// this dmi has null-named icon_state, allowing it to show a sprite on vv editor.

// defines of hints for how a proc should build output data
#define STYLE_DATUM (1)
#define STYLE_APPEARANCE (2)
#define STYLE_READ_ONLY_LIST (3)
#define STYLE_LIST (4)
#define STYLE_SPECIAL_LIST (5)

/client/proc/debug_variables(datum/thing in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder) //This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, span_danger("You need to be an administrator to access this."))
		return

	if(!thing)
		return

	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/simple/vv)
	asset_cache_datum.send(usr)


	// --------------------------------------------------------------
	// ------------         Preparation part             ------------
	// --------------------------------------------------------------

	// vv_ghost part. exotique abyss code.
	var/static/datum/vv_ghost/vv_spectre = new() /// internal purpose
	var/special_list_secure_level /// secure level of a special list
	if(thing == GLOB.vv_ghost)
		if(GLOB.vv_ghost.dmlist_origin_ref)
			thing = vv_spectre.deliver_special()
			special_list_secure_level = GLOB.vv_special_lists[vv_spectre.dmlist_varname]
			if(special_list_secure_level == VV_LIST_PROTECTED) // investigating this is not recommended. force return.
				vv_spectre.reset()
				return
		else if(GLOB.vv_ghost.list_holder)
			thing = vv_spectre.deliver_list()
		else
			return // vv_ghost is not meant to be vv'ed


	// Prepares often-used-values into variables
	var/isappearance = isappearance(thing) // TG has a version of handling /appearance stuff, by mirroring the appearance. Our version is accessing /appearance directly. Just be noted.
	var/islist = islist(thing) || special_list_secure_level // dm internal special list isn't detectable by 'islist()', but having 'secure_level' means it's detected

	if(!islist && !isdatum(thing) && !isappearance)
		return
	
	var/refid = REF(thing)

	// Prepares '/fake_type' for better readibility.
	var/type = \
		isappearance ? "/appearance" \
		: vv_spectre.dmlist_varname ? "/special_list ([vv_spectre.dmlist_varname])" \
		: islist ? /list \
		: thing.type

	// special_list flag
	var/read_only_special_list = (special_list_secure_level && (special_list_secure_level <= VV_LIST_READ_ONLY))
	
	// Hints how this debug proc will write output data
	var/debug_output_style = \
		isappearance ? STYLE_APPEARANCE \
		: read_only_special_list ? STYLE_READ_ONLY_LIST \
		: special_list_secure_level ? STYLE_SPECIAL_LIST \
		: islist ? STYLE_LIST \
		: STYLE_DATUM 


	// ------------------------------------------------------
	// ------------    Building output data   ---------------
	// ------------------------------------------------------

	// Builds text: basic info
	var/title = "[thing] ([refid]) = [type]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")
	var/ref_line = "@[copytext(refid, 2, -1)]" // get rid of the brackets, add a @ prefix for copy pasting in asay

	var/list/header
	switch(debug_output_style)
		if(STYLE_DATUM)
			header = thing.vv_get_header()
		if(STYLE_APPEARANCE)
			header = vv_get_header_appearance(thing)
		if(STYLE_LIST, STYLE_SPECIAL_LIST, STYLE_READ_ONLY_LIST)
			header = list("<b>/list</b>")

	// Builds text: tells if a datum we're editing has some flags
	var/marked_line
	var/tagged_line
	if(holder)
		if(holder.marked_datum && holder.marked_datum == thing)
			marked_line = VV_MSG_MARKED
		if(LAZYFIND(holder.tagged_datums, thing))
			var/tag_index = LAZYFIND(holder.tagged_datums, thing)
			tagged_line = VV_MSG_TAGGED(tag_index)
			
	var/varedited_line
	var/deleted_line
	if(!islist)
		if(thing.datum_flags & DF_VAR_EDITED)
			varedited_line = VV_MSG_EDITED
		if(thing.gc_destroyed)
			deleted_line = VV_MSG_DELETED


	// ------------------------------------------------------
	// Builds icon info: shows icon image on vv window
	var/icon/sprite
	var/no_icon = FALSE

	if(isatom(thing))
		sprite = getFlatIcon(thing)
		if(!sprite)
			no_icon = TRUE

	else if(isimage(thing) || isappearance)
		// icon_state=null shows first image even if dmi has no icon_state for null name.
		// This list remembers which dmi has null icon_state, to determine if icon_state=null should display a sprite
		// (NOTE: icon_state="" is correct, but saying null is obvious)
		var/static/list/dmi_nullstate_checklist = list()

		var/image/image_object = thing
		var/icon_filename_text = "[image_object.icon]" // "icon(null)" type can exist. textifying filters it.
		if(icon_filename_text)
			if(image_object.icon_state)
				sprite = icon(image_object.icon, image_object.icon_state)

			else // it means: icon_state=""
				if(!dmi_nullstate_checklist[icon_filename_text])
					dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_CHECKED
					if("" in icon_states(image_object.icon))
						// this dmi has nullstate. We'll allow "icon_state=null" to show image.
						dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_NULL

				if(dmi_nullstate_checklist[icon_filename_text] == ICON_STATE_NULL)
					sprite = icon(image_object.icon, image_object.icon_state)

	var/sprite_hash
	var/sprite_text
	if(sprite)
		sprite_hash = md5(sprite)
		src << browse_rsc(sprite, "vv[sprite_hash].png")
		sprite_text = no_icon ? "\[NO ICON\]" : "<img src='vv[sprite_hash].png'></td><td>"


	// ------------------------------------------------------
	// Builds dropdown-options
	var/list/dropdown_options
	switch(debug_output_style)
		if(STYLE_DATUM)
			dropdown_options = thing.vv_get_dropdown()
		if(STYLE_APPEARANCE)
			dropdown_options = vv_get_dropdown_appearance(thing)
		if(STYLE_READ_ONLY_LIST)
			dropdown_options = list(
				"---",
				"Show VV To Player" = VV_HREF_SPECIAL_MENU(vv_spectre.dmlist_origin_ref, VV_HK_EXPOSE, vv_spectre.dmlist_varname),
				"---"
			)
		if(STYLE_SPECIAL_LIST)
			dropdown_options = list(
				"---",
				"Add Item" = VV_HREF_SPECIAL_MENU(vv_spectre.dmlist_origin_ref, VV_HK_LIST_ADD, vv_spectre.dmlist_varname),
				"Remove Nulls" = VV_HREF_SPECIAL_MENU(vv_spectre.dmlist_origin_ref, VV_HK_LIST_ERASE_NULLS, vv_spectre.dmlist_varname),
				"Show VV To Player" = VV_HREF_SPECIAL_MENU(vv_spectre.dmlist_origin_ref, VV_HK_EXPOSE, vv_spectre.dmlist_varname),
				"---"
			)
		if(STYLE_LIST)
			dropdown_options = list(
				"---",
				"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
				"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
				"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
				"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
				"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
				"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
				"---"
			)
	// Finalize dropdown-options for /list
	if(islist)
		for(var/idx in 1 to length(dropdown_options))
			var/assoc_key = dropdown_options[idx]
			var/assoc_val = dropdown_options[assoc_key]
			var/href_string = assoc_val ? "value='[assoc_val]'" : null
			dropdown_options[idx] = "<option [href_string]>[assoc_key]</option>"


	// ------------------------------------------------------
	// Builds var-name list: gathers names of each variable in the thing you're editing.
	var/list/varname_list = list()
	switch(debug_output_style)
		if(STYLE_DATUM)
			for(var/each_varname in thing.vars)
				varname_list += each_varname
		if(STYLE_APPEARANCE)
			var/static/list/virtual_appearance_vars = build_virtual_appearance_vars()
			varname_list = virtual_appearance_vars.Copy()
		// Does nothing to LIST STYLE defines

	sleep(1 TICKS)

	var/list/variable_html = list()
	switch(debug_output_style)
		if(STYLE_DATUM)
			varname_list = sort_list(varname_list)
			for(var/each_varname in varname_list)
				if(thing.can_vv_get(each_varname))
					variable_html += thing.vv_get_var(each_varname)
		if(STYLE_APPEARANCE)
			varname_list = sort_list(varname_list)
			for(var/each_varname in varname_list)
				variable_html += debug_variable_appearance(each_varname, thing)
		if(STYLE_LIST, STYLE_SPECIAL_LIST, STYLE_READ_ONLY_LIST)
			// There is only VV_READ_ONLY for now
			var/list_flags = (read_only_special_list ? VV_READ_ONLY : null)
			// If TRUE, instead of sending actual '/special_list' instance, we send 'vv_spectre' which delegates that /special_list
			var/should_delegate_list = (special_list_secure_level ? TRUE : FALSE)
			
			var/list/list_value = thing
			for(var/i in 1 to list_value.len)
				var/key = list_value[i]
				var/value
				if(IS_NORMAL_LIST(list_value) && IS_VALID_ASSOC_KEY(key))
					value = list_value[key]
				variable_html += debug_variable(i, value, 0, (should_delegate_list ? vv_spectre : thing), display_flags = list_flags)

	// ------------------------------------------------------
	// Builds text: 'href string' based on the existence of 'vv_spectre' (which remembers actual refID of a special list)
	var/href_reference_string = \
		vv_spectre.dmlist_varname \
		? "dmlist_origin_ref=[vv_spectre.dmlist_origin_ref];dmlist_varname=[vv_spectre.dmlist_varname]" \
		: "Vars=[refid]"
	/*
		href key "Vars" only does refreshing. I hate that name because it's contextless.
		"dmlist_origin_ref" and "dmlist_varname" must exist at the same time, to access a special list directly, because such special list is not possible to be accessed through 'locate(refID)'
		You can't access /client/images (internal variable) by 'locate(that_client_images_list_ref)'. Yes, This sucks
	*/


	// ------------------------------------------------------
	// Builds html text - finalization
	var/html = {"
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="[SSassets.transport.get_asset_url("view_variables.css")]">
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0) == ' ') c = c.substring(1,c.length);
					if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			var last_filter = "";
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var vars_ol = document.getElementById("vars");

				if (filter === last_filter) {
					// An event triggered an update but nothing has changed.
					return;
				} else if (filter.indexOf(last_filter) === 0) {
					// The new filter starts with the old filter, fast path by removing only.
					var children = vars_ol.childNodes;
					for (var i = children.length - 1; i >= 0; --i) {
						try {
							var li = children\[i];
							if (li.innerText.toLowerCase().indexOf(filter) == -1) {
								vars_ol.removeChild(li);
							}
						} catch(err) {}
					}
				} else {
					// Remove everything and put back what matches.
					while (vars_ol.hasChildNodes()) {
						vars_ol.removeChild(vars_ol.lastChild);
					}

					for (var i = 0; i < complete_list.length; ++i) {
						try {
							var li = complete_list\[i];
							if (!filter || li.innerText.toLowerCase().indexOf(filter) != -1) {
								vars_ol.appendChild(li);
							}
						} catch(err) {}
					}
				}

				last_filter = filter;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);

			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				updateSearch();
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if (value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<br><b><font size='1'>[ref_line]</font></b>
							<span id='marked'>[marked_line]</span>
							<span id='tagged'>[tagged_line]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='byond://?_src_=vars;[HrefToken()];[href_reference_string]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()">
									<option value selected>Select option</option>
									[dropdown_options.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
"}

	// Resets vv_spectre, and shows it to user
	vv_spectre.reset()
	src << browse(html, "window=variables[refid];size=475x650")

/client/proc/vv_update_display(datum/thing, span, content)
	src << output("[span]:[content]", "variables[REF(thing)].browser:replace_span")

#undef ICON_STATE_CHECKED
#undef ICON_STATE_NULL

#undef STYLE_DATUM
#undef STYLE_APPEARANCE
#undef STYLE_READ_ONLY_LIST
#undef STYLE_LIST
#undef STYLE_SPECIAL_LIST
