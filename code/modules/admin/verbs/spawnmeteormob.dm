/datum/admins/proc/spawn_mobmeteor(object as text)
	set category = "Adminbus"
	set desc = "Spawn mob-meteor (enter /obj/effect/meteor here)"
	set name = "Spawn marked mob in meteor"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/obj/effect)))

	if (!chosen)
		return
	if(!marked_datum)
		to_chat(usr, "You need to mark something first!")
		return
	if (!istype(marked_datum, /mob))
		to_chat(usr, "Your marked object needs to be a mob!")
		return
	var/mob/Package = marked_datum
	//var/mob/living/simple_animal/hostile/mimic/copy/basemob = /mob/living/simple_animal/hostile/mimic/copy

	var/obj/chosen_obj = text2path(chosen)

	var/list/settings = list(
    "mainsettings" = list(
      //"name" = list("desc" = "Name", "type" = "string", "value" = "Default"),
	  "meteortype" = list("desc" = "Meteor type", "type" = "datum", "path" = "/obj/effect/meteor", "value" = "[chosen]"),
	  "do_announcement" = list("desc" = "Make Announcement", "type" = "boolean", "value" = "No"),
	  "announcement_text" = list("desc" = "Announcement Text", "type" = "string", "value" = "A meteor has been detected on collision course with the station."),
	  "announcement_title" = list("desc" = "Announcement Title", "type" = "string", "value" = "Meteor Alert"),
	  "falling" = list("desc" = "Make it a falling meteor (always spawns under mob)", "type" = "boolean", "value" = "No"),
	  "autofly" = list("desc" = "Automatically throw at station", "type" = "boolean", "value" = "Yes"),
	  //"autoteleport" = list("desc" = "Automatically teleport mob", "type" = "boolean", "value" = "Yes"),
	  "spawnunder" = list("desc" = "Spawn meter under current mob", "type" = "boolean", "value" = "No"),
			/*"maxhealth" = list("desc" = "Max. health", "type" = "number", "value" = 100),
      "access" = list("desc" = "Access ID", "type" = "datum", "path" = "/obj/item/card/id", "value" = "Default"),
			"googlyeyes" = list("desc" = "Googly eyes", "type" = "boolean", "value" = "No"),
			"disableai" = list("desc" = "Disable AI", "type" = "boolean", "value" = "Yes"),
			"idledamage" = list("desc" = "Damaged while idle", "type" = "boolean", "value" = "No"),
			"dropitem" = list("desc" = "Drop obj on death", "type" = "boolean", "value" = "Yes"),
			"mobtype" = list("desc" = "Base mob type", "type" = "datum", "path" = "/mob/living/simple_animal/hostile/mimic/copy", "value" = "/mob/living/simple_animal/hostile/mimic/copy"),
			"ckey" = list("desc" = "ckey", "type" = "ckey", "value" = "none"),*/
    )
	)

	var/list/prefreturn = presentpreflikepicker(usr,"Customize meteor", "Customize meteor", Button1="Create", width = 600, StealFocus = 1,Timeout = 0, settings=settings)
	if (prefreturn["button"] == 1)
		settings = prefreturn["settings"]
		var/mainsettings = settings["mainsettings"]
		chosen_obj = text2path(mainsettings["objtype"]["value"])

		//basemob = text2path(mainsettings["meteortype"]["value"])
		if (!ispath(chosen_obj, /obj/effect/meteor))
			to_chat(usr, "Meteor path invalid")

		//basemob = new basemob(get_turf(usr), new chosen_obj(get_turf(usr)), usr, mainsettings["dropitem"]["value"] == "Yes" ? FALSE : TRUE, (mainsettings["googlyeyes"]["value"] == "Yes" ? FALSE : TRUE))

		if (mainsettings["do_announcement"]["value"] == "Yes")
			priority_announce("[html_decode(mainsettings["announcement_text"]["value"])]", "[html_decode(mainsettings["announcement_title"]["value"])]", ANNOUNCER_METEORS)

		var/turf/T = get_turf(usr)
		if (mainsettings["spawnunder"]["value"] == "No")
			var/turf/pickedstart
			var/max_i = 10//number of tries to spawn meteor.
			while(!isspaceturf(pickedstart))
				var/startSide = pick(GLOB.cardinals)
				pickedstart = spaceDebrisStartLoc(startSide, 2)
				max_i--
				if(max_i<=0)
					to_chat(usr, "Could not find a suitable spawn location for the meteor, aborting.")
					return
			T = pickedstart
		if (mainsettings["falling"]["value"] == "Yes")
			var/obj/effect/falling_meteor/M = new /obj/effect/falling_meteor(get_turf(usr), chosen_obj)
			M.contained_meteor.carrier = TRUE
			Package.status_flags |= GODMODE
			Package.forceMove(M.contained_meteor)
			message_admins("[key_name(usr)] created a [chosen_obj] with [marked_datum] inside at [AREACOORD(M)]")
		else
			var/obj/effect/meteor/M = new chosen_obj(T)
			M.carrier = TRUE
			Package.status_flags |= GODMODE
			Package.forceMove(M)
			message_admins("[key_name(usr)] created a [chosen_obj] with [marked_datum] inside at [AREACOORD(M)]")
		//log_admin("[key_name(usr)] spawned a sentient object-mob [basemob] from [chosen_obj] at [AREACOORD(usr)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn mob in meteor") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
