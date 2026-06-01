#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

/obj/item/areaeditor
	name = "area modification item"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	attack_verb_continuous = list("attacks", "baps", "hits")
	attack_verb_simple = list("attack", "bap", "hit")
	var/fluffnotice = "Nobody's gonna read this stuff!"
	var/in_use = FALSE

/obj/item/areaeditor/attack_self(mob/user)
	add_fingerprint(user)
	. = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[station_name()] [src.name]</h2> \
				<small>[fluffnotice]</small><hr>"
	switch(get_area_type())
		if(AREA_SPACE)
			. += "<p>According to the [src.name], you are now in an unclaimed territory.</p>"
		if(AREA_SPECIAL)
			. += "<p>This place is not noted on the [src.name].</p>"
	. += "<p><a href='byond://?src=[REF(src)];create_area=1'>Create or modify an existing area</a></p>"


/obj/item/areaeditor/Topic(href, href_list)
	if(..())
		return TRUE
	if(!usr.canUseTopic(src))
		usr << browse(null, "window=blueprints")
		return TRUE
	if(href_list["create_area"])
		if(in_use)
			return
		in_use = TRUE
		create_area(usr)
		in_use = FALSE
	updateUsrDialog()

//Station blueprints!!!
/obj/item/areaeditor/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/image/showing = list()
	var/client/viewing
	var/legend = FALSE	//Viewing the wire legend
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/areaeditor/blueprints/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/trackable)

/obj/item/areaeditor/blueprints/Destroy()
	clear_viewer()
	return ..()

/obj/item/areaeditor/blueprints/attack_self(mob/user)
	. = ..()
	if(!legend)
		var/area/A = get_area(user)
		if(get_area_type() == AREA_STATION)
			. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
			. += "<p><a href='byond://?src=[REF(src)];edit_area=1'>Change area name</a></p>"
		. += "<p><a href='byond://?src=[REF(src)];view_legend=1'>View wire colour legend</a></p>"
		if(!viewing)
			. += "<p><a href='byond://?src=[REF(src)];view_blueprints=1'>View structural data</a></p>"
		else
			. += "<p><a href='byond://?src=[REF(src)];refresh=1'>Refresh structural data</a></p>"
			. += "<p><a href='byond://?src=[REF(src)];hide_blueprints=1'>Hide structural data</a></p>"
	else
		if(legend == TRUE)
			. += "<a href='byond://?src=[REF(src)];exit_legend=1'><< Back</a>"
			. += view_wire_devices(user);
		else
			//legend is a wireset
			. += "<a href='byond://?src=[REF(src)];view_legend=1'><< Back</a>"
			. += view_wire_set(user, legend)
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")


/obj/item/areaeditor/blueprints/Topic(href, href_list)
	if(..())
		return
	if(href_list["edit_area"])
		if(get_area_type()!=AREA_STATION)
			return
		if(in_use)
			return
		in_use = TRUE
		edit_area()
		in_use = FALSE
	if(href_list["exit_legend"])
		legend = FALSE;
	if(href_list["view_legend"])
		legend = TRUE;
	if(href_list["view_wireset"])
		legend = href_list["view_wireset"];
	if(href_list["view_blueprints"])
		set_viewer(usr, span_notice("You flip the blueprints over to view the complex information diagram."))
	if(href_list["hide_blueprints"])
		clear_viewer(usr,span_notice("You flip the blueprints over to view the simple information diagram."))
	if(href_list["refresh"])
		clear_viewer(usr)
		set_viewer(usr)

	attack_self(usr) //this is not the proper way, but neither of the old update procs work! it's too ancient and I'm tired shush.

/obj/item/areaeditor/blueprints/proc/get_images(turf/T, viewsize)
	. = list()
	for(var/turf/TT in range(viewsize, T))
		if(TT.blueprint_data)
			. += TT.blueprint_data

/obj/item/areaeditor/blueprints/proc/set_viewer(mob/user, message = "")
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(user), viewing.view)
		viewing.images |= showing
		if(message)
			to_chat(user, message)

/obj/item/areaeditor/blueprints/proc/clear_viewer(mob/user, message = "")
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()
	if(message)
		to_chat(user, message)

/obj/item/areaeditor/blueprints/dropped(mob/user)
	..()
	clear_viewer()
	legend = FALSE


/obj/item/areaeditor/proc/get_area_type(area/A)
	if (!A)
		A = get_area(usr)
	if(A.outdoors)
		return AREA_SPACE
	var/list/SPECIALS = list(
		/area/shuttle,
		/area/centcom,
		/area/centcom/asteroid,
		/area/centcom/tdome,
		/area/centcom/wizard_station,
		/area/misc/hilbertshotel,
		/area/misc/hilbertshotelstorage
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION

/obj/item/areaeditor/blueprints/proc/view_wire_devices(mob/user)
	var/message = "<br>You examine the wire legend.<br>"
	for(var/wireset in GLOB.wire_color_directory)
		message += "<br><a href='byond://?src=[REF(src)];view_wireset=[wireset]'>[GLOB.wire_name_directory[wireset]]</a>"
	message += "</p>"
	return message

/obj/item/areaeditor/blueprints/proc/view_wire_set(mob/user, wireset)
	//for some reason you can't use wireset directly as a derefencer so this is the next best :/
	for(var/device in GLOB.wire_color_directory)
		if("[device]" == wireset)	//I know... don't change it...
			var/message = "<p><b>[GLOB.wire_name_directory[device]]:</b>"
			for(var/Col in GLOB.wire_color_directory[device])
				var/wire_name = GLOB.wire_color_directory[device][Col]
				if(!findtext(wire_name, WIRE_DUD_PREFIX))	//don't show duds
					message += "<p><span style='color: [Col]'>[Col]</span>: [wire_name]</p>"
			message += "</p>"
			return message
	return ""

/obj/item/areaeditor/proc/edit_area()
	var/area/A = get_area(usr)
	var/prevname = "[A.name]"
	var/str = tgui_input_text(usr,"New area name:", "Area Creation", "", MAX_NAME_LEN)
	if(!str || !length(str)) // no input so we return
		to_chat(usr, span_warning("You need to enter something!"))
		return
	if(str==prevname) // no change
		return
	if(CHAT_FILTER_CHECK(str)) // check for forbidden words
		to_chat(usr, span_warning("The given name contains prohibited word(s)."))
		return

	rename_area(A, str)

	to_chat(usr, span_notice("You rename the '[prevname]' to '[str]'."))
	log_game("[key_name(usr)] has renamed [prevname] to [str]")
	A.update_areasize()
	interact()
	return TRUE

//Blueprint Subtypes

/obj/item/areaeditor/blueprints/cyborg
	name = "station schematics"
	desc = "A digital copy of the station blueprints stored in your memory."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	fluffnotice = "Intellectual Property of Nanotrasen. For use in engineering cyborgs only. Wipe from memory upon departure from the station."
	investigate_flags = NONE

/**
 * rename_area
 * Renames an area to the given new name, updating all machines' names and firedoors
 * to properly ensure alarms and machines are named correctly at all times.
 * Args:
 * - area_to_rename: The area that's being renamed.
 * - new_name: The name we're changing said area to.
 */
/proc/rename_area(area/area_to_rename, new_name)
	var/prevname = "[area_to_rename.name]"
	set_area_machinery_title(area_to_rename, new_name, prevname)
	area_to_rename.name = new_name
	require_area_resort() //area renamed so resort the names

	if(LAZYLEN(area_to_rename.firedoors))
		for(var/obj/machinery/door/firedoor/area_firedoor as anything in area_to_rename.firedoors)
			area_firedoor.calculate_affecting_areas()
	area_to_rename.update_areasize()

/**
 * Renames all machines in a defined area from the old title to the new title.
 * Used when renaming an area to ensure that all machiens are labeled the new area's machine.
 * Args:
 * - area_renaming: The area being renamed, which we'll check turfs from to rename machines in.
 * - title: The new name of the area that we're swapping into.
 * - oldtitle: The old name of the area that we're replacing text from.
 */
/proc/set_area_machinery_title(area/area_renaming, title, oldtitle)
	if(!oldtitle) // or replacetext goes to infinite loop
		return

	//stuff tied to the area to rename
	var/static/list/to_rename = typecacheof(list(
		/obj/machinery/airalarm,
		/obj/machinery/atmospherics/components/unary/vent_scrubber,
		/obj/machinery/atmospherics/components/unary/vent_pump,
		/obj/machinery/door,
		/obj/machinery/firealarm,
		/obj/machinery/light_switch,
		/obj/machinery/power/apc,
	))
	for(var/list/zlevel_turfs as anything in area_renaming.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/machine as anything in typecache_filter_list(area_turf.contents, to_rename))
				machine.name = replacetext(machine.name, oldtitle, title)

#undef AREA_ERRNONE
#undef AREA_STATION
#undef AREA_SPACE
#undef AREA_SPECIAL
