GLOBAL_LIST_INIT(creamable, typecacheof(list(
	/mob/living/carbon/human,
	/mob/living/basic/pet/dog/corgi,
	/mob/living/silicon/ai,
)))

/**
  * # Creamed component
  *
  * For when you have pie on your face
  */
/datum/component/creamed
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mutable_appearance/creamface

/datum/component/creamed/Initialize()
	if(!is_type_in_typecache(parent, GLOB.creamable))
		return COMPONENT_INCOMPATIBLE

	creamface = mutable_appearance('icons/effects/creampie.dmi')

	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent
		if(islizard(H))
			creamface.icon_state = "creampie_lizard"
		else if(H.bodyshape & BODYSHAPE_MONKEY)
			creamface.icon_state = "creampie_monkey"
		else
			creamface.icon_state = "creampie_human"
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "creampie", /datum/mood_event/creampie)
	else if(iscorgi(parent))
		creamface.icon_state = "creampie_corgi"
	else if(isAI(parent))
		creamface.icon_state = "creampie_ai"

	var/atom/A = parent
	A.add_overlay(creamface)

/datum/component/creamed/Destroy(force, silent)
	var/atom/A = parent
	A.cut_overlay(creamface)
	qdel(creamface)
	if(ishuman(A))
		var/mob/living/carbon/human/human_parent = A
		SEND_SIGNAL(human_parent, COMSIG_CLEAR_MOOD_EVENT, "creampie")
	return ..()

/datum/component/creamed/RegisterWithParent()
	RegisterSignals(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT),
		PROC_REF(clean_up))

/datum/component/creamed/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT))

///Callback to remove pieface
/datum/component/creamed/proc/clean_up(datum/source, clean_types)
	if(clean_types & CLEAN_TYPE_BLOOD)
		qdel(src)
		return TRUE
