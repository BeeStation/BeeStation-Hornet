//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	var/name = "Test Quirk"
	var/desc = "This is a test quirk."
	var/value = 0
	var/human_only = TRUE
	var/gain_text
	var/lose_text
	var/medical_record_text //This text will appear on medical records for the trait. Not yet implemented
	var/mood_quirk = FALSE //if true, this quirk affects mood and is unavailable if moodlets are disabled
	var/mob_trait //if applicable, apply and remove this mob trait
	var/process = FALSE // Does this quirk use on_process()?
	var/mob/living/quirk_holder

/datum/quirk/New(mob/living/quirk_mob, spawn_effects)
	..()
	if(!quirk_mob || (human_only && !ishuman(quirk_mob)) || quirk_mob.has_quirk(type))
		qdel(src)
		return
	quirk_holder = quirk_mob
	SSquirks.quirk_objects += src
	to_chat(quirk_holder, gain_text)
	quirk_holder.roundstart_quirks += src
	if(mob_trait)
		ADD_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
	if(process)
		START_PROCESSING(SSquirks, src)
	RegisterSignal(quirk_holder, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))
	add()
	if(spawn_effects)
		on_spawn()
		addtimer(CALLBACK(src, PROC_REF(post_add)), 30)

/datum/quirk/Destroy()
	if(process)
		STOP_PROCESSING(SSquirks, src)
	if(quirk_holder)
		remove()
		UnregisterSignal(quirk_holder, COMSIG_PARENT_QDELETING)
		if(!QDELETED(quirk_holder))
			to_chat(quirk_holder, lose_text)
		quirk_holder.roundstart_quirks -= src
		if(mob_trait)
			REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
		quirk_holder = null
	SSquirks.quirk_objects -= src
	return ..()

/datum/quirk/proc/transfer_mob(mob/living/to_mob)
	quirk_holder.roundstart_quirks -= src
	UnregisterSignal(quirk_holder, COMSIG_PARENT_QDELETING)
	to_mob.roundstart_quirks += src
	if(mob_trait)
		REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
		ADD_TRAIT(to_mob, mob_trait, ROUNDSTART_TRAIT)
	quirk_holder = to_mob
	on_transfer()
	RegisterSignal(quirk_holder, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/datum/quirk/proc/add() //special "on add" effects
/datum/quirk/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/quirk/proc/remove() //special "on remove" effects
/datum/quirk/proc/on_process() //process() has some special checks, so this is the actual process
/datum/quirk/proc/post_add() //for text, disclaimers etc. given after you spawn in with the trait
/datum/quirk/proc/on_transfer() //code called when the trait is transferred to a new mob

/datum/quirk/proc/clone_data() //return additional data that should be remembered by cloning
/datum/quirk/proc/on_clone(data) //create the quirk from clone data

/datum/quirk/proc/handle_parent_del()
	SIGNAL_HANDLER
	qdel(src)

/datum/quirk/process(delta_time)
	if(quirk_holder.stat == DEAD)
		return
	on_process(delta_time)

/mob/living/proc/get_trait_string(medical) //helper string. gets a string of all the traits the mob has
	var/list/dat = list()
	if(!medical)
		for(var/datum/quirk/T as() in roundstart_quirks)
			dat += T.name
		if(!length(dat))
			return "None"
		return dat.Join(", ")
	else
		for(var/datum/quirk/T as() in roundstart_quirks)
			dat += T.medical_record_text
		if(!length(dat))
			return "None"
		return dat.Join("<br>")

/mob/living/proc/cleanse_trait_datums() //removes all trait datums
	for(var/datum/quirk/T as() in roundstart_quirks)
		qdel(T)

/mob/living/proc/transfer_trait_datums(mob/living/to_mob)
	for(var/datum/quirk/T as() in roundstart_quirks)
		T.transfer_mob(to_mob)

/*

Commented version of Nearsighted to help you add your own traits
Use this as a guideline

/datum/quirk/nearsighted
	name = "Nearsighted"
	///The trait's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the trait panel

	value = -1
	///If this is above 0, it's a positive trait; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "HAS_TRAIT_FROM(src, X, sources)" checks around the code to check this; for instance, the Ageusia trait is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Subject has permanent nearsightedness."
	///These three are self-explanatory

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, ITEM_SLOT_EYES)
	H.regenerate_icons()

//This whole proc is called automatically
//It spawns a set of prescription glasses on the user, then attempts to put it into their hands, then attempts to make them equip it.
//This means that if they fail to equip it, they glasses spawn in their hands, and if they fail to be put into the hands, they spawn on the ground
//Hooray for fallbacks!
//If you don't need any special effects like spawning glasses, then you don't need an add()

*/
