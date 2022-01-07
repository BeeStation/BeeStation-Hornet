#define AI_DOWNLOAD_PER_PROCESS 0.5

/obj/machinery/computer/ai_control_console
	name = "\improper AI control console"
	desc = "Used for accessing the central AI repository from which AIs can be downloaded or uploaded."
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	var/authenticated = FALSE

	var/obj/item/aicard/intellicard

	var/mob/living/silicon/ai/downloading
	var/mob/user_downloading
	var/download_progress = 0
	var/download_warning = FALSE

	circuit = /obj/item/circuitboard/computer/ai_upload_download

/obj/machinery/computer/ai_control_console/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/aicard))
		if(intellicard)
			to_chat(user, "<span class = 'warning'><There's already an IntelliCard inserted!/span>")
			return ..()
		to_chat(user, "<span class = 'notice'>You insert [W].</span>")
		W.forceMove(src)
		intellicard = W
		return FALSE
	if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/brain = W
		if(!brain.brainmob)
			to_chat(user, "<span class = 'warning'>[W] is not active!</span>")
			return ..()
		SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)
		if(!istype(brain.laws, /datum/ai_laws/ratvar))
			remove_servant_of_ratvar(brain.brainmob, TRUE)
		var/mob/living/silicon/ai/A = null

		var/datum/ai_laws/laws = new
		laws.set_laws_config()

		if (brain.overrides_aicore_laws)
			A = new /mob/living/silicon/ai(loc, brain.laws, brain.brainmob)
		else
			A = new /mob/living/silicon/ai(loc, laws, brain.brainmob)

		A.relocate(TRUE)

		if(brain.force_replace_ai_name)
			A.fully_replace_character_name(A.name, brain.replacement_ai_name())
		SSblackbox.record_feedback("amount", "ais_created", 1)
		qdel(W)
		to_chat(user, "<span class = 'notice'>AI succesfully uploaded.</span>")
		return FALSE

	return ..()

/obj/machinery/computer/ai_control_console/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class = 'warning'>You bypass the access restrictions</span>")
	authenticated = TRUE
	obj_flags |= EMAGGED

/obj/machinery/computer/ai_control_console/process()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return

	if(downloading && download_progress >= 50 && !download_warning)
		var/turf/T = get_turf(src)
		to_chat(downloading, "<span class = 'userdanger'>Warning! Download is 50% completed! Download location: [get_area(src)] ([T.x], [T.y], [T.z])!</span>")
		download_warning = TRUE
	if(downloading && download_progress >= 100)
		finish_download()

	if(downloading)
		if(!downloading.can_download)
			stop_download()
			return
		download_progress += AI_DOWNLOAD_PER_PROCESS * downloading.downloadSpeedModifier


/obj/machinery/computer/ai_control_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiControlPanel", name)
		ui.open()

/obj/machinery/computer/ai_control_console/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["authenticated"] = authenticated

	if(issilicon(user))
		var/mob/living/silicon/borg = user
		data["username"] = borg.name
		data["has_access"] = TRUE

	if(IsAdminGhost(user))
		data["username"] = user.client.holder.admin_signature
		data["has_access"] = TRUE

	if(ishuman(user) && !(obj_flags & EMAGGED))
		var/username = user.get_authentification_name("Unknown")
		data["username"] = user.get_authentification_name("Unknown")
		if(username != "Unknown")
			var/datum/data/record/record
			for(var/RP in GLOB.data_core.general)
				var/datum/data/record/R = RP

				if(!istype(R))
					continue
				if(R.fields["name"] == username)
					record = R
					break
			if(record)
				if(istype(record.fields["photo_front"], /obj/item/photo))
					var/obj/item/photo/P1 = record.fields["photo_front"]
					var/icon/picture = icon(P1.picture.picture_image)
					picture.Crop(10, 32, 22, 22)
					var/md5 = md5(fcopy_rsc(picture))

					if(!SSassets.cache["photo_[md5]_cropped.png"])
						SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
					SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))

					data["user_image"] = SSassets.transport.get_asset_url("photo_[md5]_cropped.png")
		data["has_access"] = check_access(user.get_idcard())

	if(obj_flags & EMAGGED)
		data["username"] = "ERROR"
		data["has_access"] = TRUE

	if(!authenticated)
		return data

	data["intellicard"] = intellicard
	if(intellicard && intellicard.AI)
		data["intellicard_ai"] = intellicard.AI.real_name
		data["intellicard_ai_health"] = intellicard.AI.health
	else
		data["intellicard_ai"] = null
		data["intellicard_ai_health"] = 0

	data["can_upload"] = available_ai_cores()

	if(downloading)
		data["downloading"] = downloading.real_name
		data["download_progress"] = download_progress
		data["downloading_ref"] = REF(downloading)
	else
		data["downloading"] = null
		data["download_progress"] = 0

	data["ais"] = list()
	data["current_ai_ref"] = null
	if(isAI(user))
		data["current_ai_ref"] = REF(user)

	return data

/obj/machinery/computer/ai_control_console/proc/finish_download()
	if(intellicard)
		downloading.transfer_ai(AI_TRANS_TO_CARD, user_downloading, null, intellicard)
		intellicard.forceMove(get_turf(src))
		intellicard = null
	stop_download(TRUE)

/obj/machinery/computer/ai_control_console/proc/stop_download(silent = FALSE)
	if(downloading)
		if(!silent)
			to_chat(downloading, "<span class = 'userdanger'>Download stopped.</span>")
		downloading = null
		user_downloading = null
		download_progress = 0
		download_warning = FALSE

/obj/machinery/computer/ai_control_console/proc/upload_ai(silent = FALSE)
	to_chat(intellicard.AI, "<span class = 'userdanger'>You are being uploaded. Please stand by...</span>")
	intellicard.AI.radio_enabled = TRUE
	intellicard.AI.control_disabled = FALSE
	intellicard.AI.relocate(TRUE)
	intellicard.AI = null

/obj/machinery/computer/ai_control_console/ui_act(action, params)
	if(..())
		return

	if(!authenticated)
		if(action == "log_in")
			if(issilicon(usr))
				authenticated = TRUE
				return

			if(IsAdminGhost(usr))
				authenticated = TRUE

			if(obj_flags & EMAGGED)
				authenticated = TRUE

			var/mob/living/carbon/human/H = usr
			if(!istype(H))
				return

			if(check_access(H.get_idcard()))
				authenticated = TRUE
		return

	switch(action)
		if("log_out")
			authenticated = FALSE
			. = TRUE
		if("upload_intellicard")
			if(!intellicard || downloading)
				return
			if(!intellicard.AI)
				return
			upload_ai()

		if("eject_intellicard")
			if(issilicon(usr))
				to_chat(usr, "<span class = 'warning'>You're unable to remotely eject the IntelliCard!</span>")
				return
			stop_download()
			intellicard.forceMove(get_turf(src))
			intellicard = null

		if("stop_download")
			if(isAI(usr))
				to_chat("<span class = 'warning'>You need physical access to stop the download!</span>")
				return
			stop_download()

		if("start_download")
			if(!intellicard || downloading)
				return
			var/mob/living/silicon/ai/target = locate(params["download_target"])
			if(!target || !istype(target))
				return
			if(!istype(target.loc, /obj/machinery/ai/data_core))
				return
			if(!target.can_download)
				return
			downloading = target
			to_chat(downloading, "<span class = 'userdanger'>Warning! Someone is attempting to download you from [get_area(src)]!</span>")
			user_downloading = usr
			download_progress = 0
			. = TRUE
		if("skip_download")
			if(!downloading)
				return
			if(usr == downloading)
				finish_download()

#undef AI_DOWNLOAD_PER_PROCESS
