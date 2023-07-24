/datum/component/blind_sense
	///The range we can hear-ping things from
	var/hear_range = 8
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users ears
	var/obj/item/organ/ears/ears
	///Type casted to access client, owner
	var/mob/owner
	///What texture we use
	var/masked_texture = "blind_texture_blank"
	///Do we bloom?
	var/bloom = TRUE

/datum/component/blind_sense/New(list/raw_args)
	. = ..()
	//Register signal for sensing voices
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, PROC_REF(handle_hear))
	//Register signal for sensing sounds
	RegisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED, PROC_REF(handle_hear))
	//typecast to access client
	owner = parent
	//Register ears for people with them - deaf people can't use this component
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		ears = locate(/obj/item/organ/ears) in C.internal_organs
		RegisterSignal(ears, COMSIG_PARENT_QDELETING, PROC_REF(handle_ears))

/datum/component/blind_sense/RemoveComponent()
	. = ..()

/datum/component/blind_sense/proc/handle_hear(datum/source, atom/speaker, message)
	SIGNAL_HANDLER

	//Stop us from hearing ourselves or if we're deaf
	if(owner == speaker || ears?.deaf)
		return
	//Preset types for things without icons / fucky icons
	var/type
	if(isliving(speaker))
		type = "mob"
		if(isfile(message)) //soundfile exclusively from footstep signal
			type = "footstep"
	//Do dist checks
	var/turf/T = get_turf(speaker)
	var/dist = get_dist(get_turf(owner), T)
	if(dist <= hear_range && dist > 1)
		highlight_object(speaker, type, speaker.dir || 1)

/datum/component/blind_sense/proc/highlight_object(atom/target, type, dir)
	//setup icon
	var/icon/I = icon('icons/mob/blind.dmi', masked_texture)

	//mask icon
	var/icon/mask = icon('icons/mob/blind.dmi', type || "sound", dir)
	//If the mob has an icon we can use, use it
	if(type == "mob" && target.icon && (target.icon_state || initial(target.icon_state)))
		mask = icon(target.icon, (target.icon_state || initial(target.icon_state)), target.dir)
	I.AddAlphaMask(mask)

	//Setup display image
	var/image/M = image(I, target, layer = HUD_LAYER)
	M.plane = HUD_PLANE
	if(bloom)
		M.filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	M.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	//Animate fade & delete
	animate(M, alpha = 0, time = sense_time + 1 SECONDS, easing = QUAD_EASING, flags = EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(handle_image), M), sense_time)

	//Add image to client
	owner.client?.images += M

//handle deleting the image from client
/datum/component/blind_sense/proc/handle_image(image/image_ref)
	SIGNAL_HANDLER

	owner.client?.images -= image_ref
	qdel(image_ref)

//Handle eyes deleting
/datum/component/blind_sense/proc/handle_ears()
	SIGNAL_HANDLER

	ears = null
