/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_off"
	w_class = WEIGHT_CLASS_NORMAL
	var/braintype = JOB_NAME_CYBORG
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/vehicle/sealed/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = FALSE // Whether the laws on the MMI, if any, override possible pre-existing laws loaded on the AI core.
	///Used to reserve an "original" cyborg name. When this mmi first becomes a cyborg, their name will be stored here in case of deconstruction.
	var/original_name

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.set_broadcasting(FALSE) //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/Destroy()
	if(iscyborg(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	set_mecha(null)
	QDEL_NULL(brainmob)
	QDEL_NULL(brain)
	QDEL_NULL(radio)
	QDEL_NULL(laws)
	return ..()

/obj/item/mmi/update_icon()
	if(!brain)
		icon_state = "mmi_off"
		return
	if(istype(brain, /obj/item/organ/brain/alien))
		icon_state = "mmi_brain_alien"
		braintype = "Xenoborg" //HISS....Beep.
	if(istype(brain, /obj/item/organ/brain/positron))
		icon_state = "mmi_brain_IPC"
	else
		icon_state = "mmi_brain"
		braintype = "Cyborg"
	if(brainmob && brainmob.stat != DEAD)
		add_overlay("mmi_alive")
	else
		add_overlay("mmi_dead")

/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			to_chat(user, span_warning("There's already a brain in the MMI!"))
			return
		if(!newbrain.brainmob)
			to_chat(user, span_warning("You aren't sure where this brain came from, but you're pretty sure it's a useless brain!"))
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
		user.visible_message("[user] sticks \a [newbrain] into [src].", span_notice("[src]'s indicator light turn on as you insert [newbrain]."))
		log_attack("[key_name(user)] inserted [newbrain] into \the [src] at [AREACOORD(src)].")

		SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, newbrain.brainmob)
		set_brainmob(newbrain.brainmob)
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.brain_death && newbrain.suicided && brainmob.suiciding //brain is damaged beyond repair or from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
			brainmob.remove_from_dead_mob_list()
			brainmob.add_to_alive_mob_list()
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [newbrain] for damage."))
			playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
		else
			to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [newbrain] again."))
			playsound(src, "sound/weapons/smg_empty_alarm.ogg", 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain
		brain.organ_flags |= ORGAN_FROZEN

		name = "[initial(name)]: [brainmob.real_name]"
		update_icon()

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()


/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.set_on(!radio.is_on())
		to_chat(user, span_notice("You toggle [src]'s radio system [radio.is_on() == TRUE ? "on" : "off"]."))
	else
		log_attack("[key_name(user)] ejected \the [brainmob] from \the [src] at [AREACOORD(src)].")
		eject_brain(user)
		update_icon()
		name = initial(name)
		to_chat(user, span_notice("You unlock and upend [src], spilling the brain onto the floor."))

/obj/item/mmi/proc/eject_brain(mob/user)
	brainmob.container = null //Reset brainmob mmi var.
	brainmob.forceMove(brain) //Throw mob into brain.
	brainmob.set_stat(DEAD)
	brainmob.emp_damage = 0
	brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
	brainmob.remove_from_alive_mob_list() //Get outta here
	brainmob.add_to_dead_mob_list()
	brain.brainmob = brainmob //Set the brain to use the brainmob
	brainmob = null //Set mmi brainmob var to null
	if(user)
		user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
	else
		brain.forceMove(get_turf(src))
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here


/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.

	//both of these need to be created so we can't keep either
	if(brain)
		QDEL_NULL(brain)
	if(brainmob)
		QDEL_NULL(brainmob)

	var/obj/item/organ/BR = L.get_organ_by_type(/obj/item/organ/brain)
	if(BR)
		brain = new BR.type (src)
	else
		brain = new(src)
	brain.organ_flags |= ORGAN_FROZEN

	brain.transfer_identity(L)
	set_brainmob(brain.brainmob)
	brainmob.container = src

	brain.name = "[L.real_name]'s brain"
	name = "[initial(name)]: [brainmob.real_name]"
	update_icon()
	return

/// Proc to hook behavior associated to the change in value of the [/obj/item/mmi/var/brainmob] variable.
/obj/item/mmi/proc/set_brainmob(mob/living/brain/new_brainmob)
	if(brainmob == new_brainmob)
		return FALSE
	. = brainmob
	brainmob = new_brainmob
	if(new_brainmob)
		if(mecha)
			REMOVE_TRAIT(new_brainmob, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
			REMOVE_TRAIT(new_brainmob, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)
		else
			ADD_TRAIT(new_brainmob, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
			ADD_TRAIT(new_brainmob, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)
	if(.)
		var/mob/living/brain/old_brainmob = .
		ADD_TRAIT(old_brainmob, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
		ADD_TRAIT(old_brainmob, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)


/// Proc to hook behavior associated to the change in value of the [obj/vehicle/sealed/var/mecha] variable.
/obj/item/mmi/proc/set_mecha(obj/vehicle/sealed/mecha/new_mecha)
	if(mecha == new_mecha)
		return FALSE
	. = mecha
	mecha = new_mecha
	if(new_mecha)
		if(!. && brainmob) // There was no mecha, there now is, and we have a brain mob that is no longer unaided.
			REMOVE_TRAIT(brainmob, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
			REMOVE_TRAIT(brainmob, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)
	else if(. && brainmob) // There was a mecha, there no longer is one, and there is a brain mob that is now again unaided.
		ADD_TRAIT(brainmob, TRAIT_IMMOBILIZED, BRAIN_UNAIDED)
		ADD_TRAIT(brainmob, TRAIT_HANDS_BLOCKED, BRAIN_UNAIDED)

/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
	if(!radio.is_on())
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.set_listening(!radio.get_listening())
	to_chat(brainmob, span_notice("Radio is [radio.get_listening() ? "now" : "no longer"] receiving broadcast."))

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	. += span_notice("There is a switch to toggle the radio system [radio.is_on() ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]")
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += span_warning("The MMI indicates the brain is completely unresponsive.")

		else if(!B.client)
			. += span_warning("The MMI indicates the brain is currently inactive; it might change.")

		else
			. += span_notice("The MMI indicates the brain is active.")

/obj/item/mmi/relaymove(mob/living/user, direction)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/brain_check(mob/user)
	var/mob/living/brain/B = brainmob
	if(!B)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that there is no brain present!"))
		return FALSE
	if(!B.key || !B.mind)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is completely unresponsive!"))
		return FALSE
	if(!B.client)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is currently inactive."))
		return FALSE
	if(B.suiciding || brain?.suicided)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind has no will to live!"))
		return FALSE
	if(B.stat == DEAD)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is dead!"))
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is damaged!"))
		return FALSE
	return TRUE

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	overrides_aicore_laws = TRUE

/obj/item/mmi/syndie/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.set_on(FALSE)
