/datum/component/blind_sense
	///The range we can hear-ping things from
	var/hear_range = 8
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users ears
	var/obj/item/organ/ears/ears
	///Type casted
	var/mob/owner
	var/client/owner_client
	///What texture we use
	var/masked_texture = "blind_texture_blank"

/datum/component/blind_sense/New(list/raw_args)
	. = ..()
	//Register signal for sensing voices
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, PROC_REF(handle_hear))
	//Register signal for sensing sounds
	RegisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED, PROC_REF(handle_hear))
	//typecast to access client
	owner = parent
	owner_client = owner?.client
	//Register ears for people with them - deaf people can't use this component
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		ears = locate(/obj/item/organ/ears) in C.internal_organs
		RegisterSignal(ears, COMSIG_PARENT_QDELETING, PROC_REF(handle_ears))

/datum/component/blind_sense/Destroy(force, silent)
	owner = null
	owner_client = null
	ears = null
	return ..()

/datum/component/blind_sense/RemoveComponent()
	UnregisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED)
	return ..()

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
	if(!owner_client || isdead(owner) || !owner?.client)
		owner_client = owner?.client
		return
	
	//setup icon
	var/icon/I = icon('icons/mob/blind.dmi', masked_texture)

	//icon masking
	var/icon/mask
	if(type != "mob")
		mask = icon('icons/mob/blind.dmi', type || "sound", dir)
		I.AddAlphaMask(mask)

	//Setup display image
	var/obj/effect/blind_sense/BS = new(get_turf(target))
	var/image/M = image(I, BS)
	M.plane = BLIND_FEATURE_PLANE
	M.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	//filter masking
	if(type == "mob")
		//Re-use the blind sense location holder for an appearance
		BS.appearance = target.appearance
		BS.render_target = "[WEAKREF(BS)]"
		BS.color = "#fff" //what the fuck, setting color and plane doesn't work in the actual path definition, fuck off
		BS.plane = ANTI_PSYCHIC_PLANE
		M.filters += filter(type = "alpha", render_source = BS.render_target)

	//Colouring
	var/_color = "#fff"
	if(HAS_TRAIT(owner, TRAIT_PSYCHIC_SENSE) && ishuman(target))
		var/mob/living/carbon/human/H = target
		_color = GLOB.SOUL_GLIMMER_COLORS[H.mind?.soul_glimmer]
	M.color = _color

	//Animate fade & delete
	animate(M, alpha = 0, time = sense_time + 1 SECONDS, easing = QUAD_EASING, flags = EASE_IN)
	addtimer(CALLBACK(src, PROC_REF(handle_image), M, BS), sense_time)

	//Add image to client
	owner_client?.images += M

//handle deleting the image from client
/datum/component/blind_sense/proc/handle_image(image_ref, BS)
	SIGNAL_HANDLER

	owner_client?.images -= image_ref
	qdel(BS)
	qdel(image_ref)

//Handle eyes deleting
/datum/component/blind_sense/proc/handle_ears()
	SIGNAL_HANDLER

	ears = null

//Anchor for the thing
/obj/effect/blind_sense
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
