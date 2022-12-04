///A list of generated images from psychic sight. Saves us generating more than once.

/datum/component/blind_sense
	///The range we can hear-ping things from
	var/hear_range = 9
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users ears
	var/obj/item/organ/ears/ears
	///
	var/mob/owner

/datum/component/blind_sense/New(list/raw_args)
	. = ..()
	//Register signal for sensing voices
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, .proc/handle_hear)
	//Register signal for sensing sounds
	RegisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED, .proc/handle_hear)
	//typecast to access client
	owner = parent

/datum/component/blind_sense/proc/handle_hear(datum/source, atom/speaker, message)
	SIGNAL_HANDLER

	//Stop us from hearing ourselves
	if(owner == speaker)
		return
	//Preset types for things without icons / fucky icons
	var/type
	if(isliving(speaker))
		type = "mob"
	if(istype(speaker, /turf)) //becuase turfs play the footstep sound
		type = "footstep"
	//Do dist checks
	var/turf/T = get_turf(speaker)
	var/dist = get_dist(get_turf(owner), T)
	if(dist <= hear_range && dist > 1)
		highlight_object(speaker, type)

/datum/component/blind_sense/proc/highlight_object(atom/target, type)
	//setup icon
	var/icon/I = icon('icons/mob/psychic.dmi', "texture_2")
	//mask icon
	var/icon/mask = icon('icons/mob/psychic.dmi', type)
	//gen mask if we dont have one
	if((istype(target, /mob) || istype(target, /obj)))
		if((!target.icon || !(target.icon_state || initial(target.icon_state))))
			if(!type)
				mask = icon('icons/mob/psychic.dmi', "sound")
		else
			mask = icon(target.icon, target.icon_state)
	I.AddAlphaMask(mask)
	//Setup display image
	var/image/M = image(I, target, layer = BLIND_LAYER+1, pixel_x = target.pixel_x, pixel_y = target.pixel_y)
	M.plane = FULLSCREEN_PLANE+1
	M.filters += filter(type = "bloom", size = 6, threshold = rgb(1,1,1))
	//Animate fade & delete
	animate(M, alpha = 0, time = sense_time + 1 SECONDS, easing = QUAD_EASING, flags = EASE_IN)
	addtimer(CALLBACK(src, .proc/handle_image, M), sense_time)
	//Add image to client
	owner.client?.images += M

/datum/component/blind_sense/proc/handle_image(image/image_ref)
	SIGNAL_HANDLER

	owner.client?.images -= image_ref
	qdel(image_ref)
