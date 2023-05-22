/datum/admins/proc/spawn_mobmeteor(object as text)
	set category = "Adminbus"
	set desc = "Spawn mob-meteor (enter /obj/effect/meteor here)"
	set name = "Spawn Marked Mob In Meteor"

	spawn_mob_as_meteor(object)

/proc/spawn_mob_as_meteor(object as text)

	var/client/C = usr.client
	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/obj/effect)))

	if (!chosen)
		return
	//if(!C?.holder?.marked_datum)
		//to_chat(usr, "You need to mark something first!")
		//return
	if (!istype(C?.holder?.marked_datum, /mob))
		to_chat(usr, "Your marked object needs to be a mob!")
		return
	//var/mob/Package = C?.holder?.marked_datum

	var/obj/chosen_obj = text2path(chosen)

	var/list/settings = list(
	"mainsettings" = list(

		"meteortype" = list("desc" = "Meteor type", "type" = "datum", "path" = "/obj/effect/meteor", "value" = "[chosen]"),
		"do_announcement" = list("desc" = "Make Announcement", "type" = "boolean", "value" = "No"),
		"announcement_text" = list("desc" = "Announcement Text", "type" = "string", "value" = "A meteor has been detected on collision course with the station."),
		"announcement_title" = list("desc" = "Announcement Title", "type" = "string", "value" = "Meteor Alert"),
		"autofly" = list("desc" = "Automatically throw at station", "type" = "boolean", "value" = "Yes"),
		"spawnunder" = list("desc" = "Spawn meter under current mob", "type" = "boolean", "value" = "No"),
    )
	)

	var/list/prefreturn = presentpreflikepicker(usr,"Customize meteor", "Customize meteor", Button1="Create", width = 600, StealFocus = 1,Timeout = 0, settings=settings)
	if (prefreturn["button"] == 1)
		settings = prefreturn["settings"]
		var/mainsettings = settings["mainsettings"]
		chosen_obj = text2path(mainsettings["meteortype"]["value"])

		if (!ispath(chosen_obj, /obj/effect/meteor))
			to_chat(usr, "Meteor path invalid")

		if (mainsettings["do_announcement"]["value"] == "Yes")
			priority_announce("[html_decode(mainsettings["announcement_text"]["value"])]", "[html_decode(mainsettings["announcement_title"]["value"])]", ANNOUNCER_METEORS)

		var/turf/T = get_turf(usr)
		var/turf/Target = null
		if (mainsettings["spawnunder"]["value"] == "No")
			var/turf/pickedstart
			var/turf/pickedgoal
			var/max_i = 10//number of tries to spawn meteor.
			while(!isspaceturf(pickedstart))
				var/startSide = pick(GLOB.cardinals)
				pickedstart = aimbotDebrisStartLoc(startSide, 2)
				pickedgoal = aimbotDebrisFinishLoc(startSide, 2)
				max_i--
				if(max_i<=0)
					to_chat(usr, "Could not find a suitable spawn location for the meteor, aborting.")
					return
			T = pickedstart
			Target = pickedgoal
		if(mainsettings["autofly"]["value"] == "Yes")
			var/obj/effect/meteor/M = new chosen_obj(T, Target)
			//M.carrier = TRUE
			//M.carried = WEAKREF(Package)
			message_admins("[key_name(usr)] created a [chosen_obj] with [C?.holder?.marked_datum] inside at [AREACOORD(M)]")
		else
			var/obj/effect/meteor/M = new chosen_obj(T)
			//M.carrier = TRUE
			//M.carried = WEAKREF(Package)
			message_admins("[key_name(usr)] created a [chosen_obj] with [C?.holder?.marked_datum] inside at [AREACOORD(M)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn mob in meteor") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/mob/proc/delayed_teleport(var/turf/T)
	sleep(2 SECONDS)
	src.forceMove(T)
