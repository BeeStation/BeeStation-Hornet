/datum/component/blind_sense
	///The range we can hear-ping things from
	var/hear_range = 8
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users ears
	var/obj/item/organ/ears/ears
	///ref to client for image stuff
	var/client/owner_client
	///What texture we use
	var/masked_texture = "blind_texture_blank"

/datum/component/blind_sense/New(list/raw_args)
	. = ..()
	var/mob/owner
	if(ismob(parent))
		owner = parent

	//Register signal for sensing voices
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, PROC_REF(handle_hear))
	//Register signal for sensing sounds
	RegisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED, PROC_REF(handle_hear))
	//typecast to access client
	owner_client = owner?.client
	//Register ears for people with them - deaf people can't use this component
	if(iscarbon(parent))
		var/mob/living/carbon/C = parent
		ears = locate(/obj/item/organ/ears) in C.internal_organs
		RegisterSignal(ears, COMSIG_QDELETING, PROC_REF(handle_ears))

/datum/component/blind_sense/Destroy(force, silent)
	owner_client = null
	ears = null
	return ..()

/datum/component/blind_sense/ClearFromParent()
	UnregisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED)
	return ..()

/datum/component/blind_sense/proc/handle_hear(datum/source, atom/speaker, message)
	SIGNAL_HANDLER

	//Stop us from hearing ourselves or if we're deaf
	if(parent == speaker || ears?.deaf)
		return
	//Preset types for things without icons / fucky icons
	var/type
	if(isliving(speaker))
		type = "mob"
		if(isfile(message)) //soundfile exclusively from footstep signal
			type = "footstep"
	//Do dist checks
	var/turf/T = get_turf(speaker)
	var/dist = get_dist(get_turf(parent), T)
	if(dist <= hear_range && dist > 1)
		highlight_object(speaker, type, speaker.dir || 1)

/datum/component/blind_sense/proc/highlight_object(atom/target, type, dir)
	var/mob/owner
	if(ismob(parent))
		owner = parent
	if(!owner_client || isdead(parent) || !owner?.client)
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
	var/obj/effect/blind_sense/BS = new /obj/effect/blind_sense(get_turf(target))
	var/image/M = image(I, BS)
	M.plane = BLIND_FEATURE_PLANE
	M.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	M.appearance_flags = KEEP_TOGETHER

	//filter masking
	if(type == "mob")
		//Re-use the blind sense location holder for an appearance
		BS.appearance = target.appearance
		BS.render_target = "[BS]"
		BS.color = "#ffffffff" //what the fuck, setting color and plane doesn't work in the actual path definition, fuck off
		BS.plane = LOWEST_EVER_PLANE
		BS.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		M.filters += filter(type = "alpha", render_source = BS.render_target)
		BS.cut_overlay(GLOB.blind_typing_indicator)

	//Colouring
	var/_color = "#fff"
	if(HAS_TRAIT(parent, TRAIT_PSYCHIC_SENSE) && ishuman(target))
		var/mob/living/carbon/human/H = target
		_color = GLOB.soul_glimmer_colors[H.mind?.soul_glimmer]
	M.color = _color

	//Animate fade & delete
	animate(M, alpha = 0, time = sense_time, easing = QUAD_EASING, flags = EASE_IN)
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
