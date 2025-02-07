
/obj/item/camera/siliconcam
	name = "silicon photo camera"
	var/in_camera_mode = FALSE
	var/list/datum/picture/stored = list()

/obj/item/camera/siliconcam/ai_camera
	name = "AI photo camera"
	flash_enabled = FALSE

/obj/item/camera/siliconcam/proc/toggle_camera_mode(mob/user)
	if(in_camera_mode)
		camera_mode_off(user)
	else
		camera_mode_on(user)

/obj/item/camera/siliconcam/burn()
	return

/obj/item/camera/siliconcam/proc/camera_mode_off(mob/user)
	in_camera_mode = FALSE
	to_chat(user, "<B>Camera Mode deactivated</B>")

/obj/item/camera/siliconcam/proc/camera_mode_on(mob/user)
	in_camera_mode = TRUE
	to_chat(user, "<B>Camera Mode activated</B>")

/obj/item/camera/siliconcam/proc/selectpicture(mob/user, title = "Select Photo", button_text = "Select")
	if(!length(stored))
		to_chat(user, span_boldannounce("No images saved."))
		return
	return tgui_select_picture(user, stored, title = title, button_text = button_text)

/obj/item/camera/siliconcam/proc/viewpictures(mob/user)
	var/datum/picture/selection = selectpicture(user, button_text = "View")
	if(istype(selection))
		show_picture(user, selection)

/obj/item/camera/siliconcam/ai_camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	var/number = stored.len
	picture.picture_name = "Image [number] (taken by [loc.name])"
	stored[picture] = TRUE
	to_chat(usr, span_unconscious("Image recorded."))

/obj/item/camera/siliconcam/robot_camera
	name = "Cyborg photo camera"
	var/printcost = 2

/obj/item/camera/siliconcam/robot_camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	var/mob/living/silicon/robot/C = loc
	if(istype(C) && istype(C.connected_ai))
		var/number = C.connected_ai.aicamera.stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		C.connected_ai.aicamera.stored[picture] = TRUE
		to_chat(usr, span_unconscious("Image recorded and saved to remote database."))
	else
		var/number = stored.len
		picture.picture_name = "Image [number] (taken by [loc.name])"
		stored[picture] = TRUE
		to_chat(usr, span_unconscious("Image recorded and saved to local storage. Upload will happen automatically if unit is lawsynced."))

/obj/item/camera/siliconcam/robot_camera/selectpicture(mob/user, title = "Select Photo", button_text = "Select")
	var/mob/living/silicon/robot/R = loc
	if(istype(R) && R.connected_ai)
		R.picturesync()
		return R.connected_ai.aicamera.selectpicture(user, title, button_text)
	else
		return ..()

/obj/item/camera/siliconcam/robot_camera/proc/borgprint(mob/user)
	var/mob/living/silicon/robot/C = loc
	if(!istype(C) || C.toner < 20)
		to_chat(user, span_warning("Insufficent toner to print image."))
		return
	var/datum/picture/selection = selectpicture(user, button_text = "Print")
	if(!istype(selection))
		to_chat(user, span_warning("Invalid Image."))
		return
	var/obj/item/photo/p = new /obj/item/photo(C.loc, selection)
	p.pixel_x = p.base_pixel_x + rand(-10, 10)
	p.pixel_y = p.base_pixel_y + rand(-10, 10)
	C.toner -= printcost	 //All fun allowed.
	visible_message("[C.name] spits out a photograph from a narrow slot on its chassis.", span_notice("You print a photograph."))

/obj/item/camera/siliconcam/proc/paiprint(mob/user)
	var/mob/living/silicon/pai/paimob = loc
	var/datum/picture/selection = selectpicture(user)
	if(!istype(selection))
		to_chat(user, span_warning("Invalid Image."))
		return
	printpicture(user,selection)
	user.visible_message(span_notice("A picture appears on top of the chassis of [paimob.name]!"), span_notice("You print a photograph."))
