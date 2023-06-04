//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	var/name = "Test Quirk"
	var/desc = "This is a test quirk."
	var/value = 0
	var/list/restricted_mobtypes = list(/mob/living/carbon/human) //specifies valid mobtypes, have a good reason to change this
	var/list/restricted_species //specifies valid species, use /datum/species/ 
	var/species_whitelist = TRUE //whether restricted_species is a whitelist or a blacklist
	var/gain_text
	var/lose_text
	var/medical_record_text //This text will appear on medical records for the quirk. Not yet implemented
	var/mood_quirk = FALSE //if true, this quirk affects mood and is unavailable if moodlets are disabled
	var/mob_trait //if applicable, apply and remove this mob quirk
	var/process = FALSE // Does this quirk use on_process()?
	var/datum/mind/quirk_holder // The mind that contains this quirk
	var/mob/living/quirk_target // The mob that will be affected by this quirk

/datum/quirk/New(datum/mind/quirk_mind, mob/living/quirk_mob, spawn_effects)
	..()
	if(!quirk_mind)
		qdel(src)
		return
	if(!quirk_mob || quirk_mob.has_quirk(type))
		qdel(src)
		return
	quirk_holder = quirk_mind
	quirk_target = quirk_mob
	SSquirks.quirk_objects += src
	to_chat(quirk_target, gain_text)
	quirk_holder.quirks += src
	if(process)
		START_PROCESSING(SSquirks, src)
	RegisterSignal(quirk_holder, COMSIG_PARENT_QDELETING, PROC_REF(handle_holder_del))
	RegisterSignal(quirk_target, COMSIG_PARENT_QDELETING, PROC_REF(handle_mob_del))
	if(!is_valid_quirk_target(quirk_target)) //at this point the quirk is saved to the mind
		return

	if(mob_trait)
		ADD_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
	add()
	if(spawn_effects)
		on_spawn()
		addtimer(CALLBACK(src, PROC_REF(post_spawn)), 30)

/datum/quirk/Destroy()
	if(process)
		STOP_PROCESSING(SSquirks, src)
	if(quirk_holder)
		remove()
		UnregisterSignal(quirk_holder, COMSIG_PARENT_QDELETING)
		if(!QDELETED(quirk_target))
			UnregisterSignal(quirk_target, COMSIG_PARENT_QDELETING)
			to_chat(quirk_target, lose_text)
		quirk_holder.quirks -= src
		if(mob_trait)
			REMOVE_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
		quirk_holder = null
		quirk_target = null
	SSquirks.quirk_objects -= src
	return ..()

/* Don't use this, use the mind's transfer_to proc instead */
/datum/quirk/proc/transfer_mob(mob/living/to_mob)
	UnregisterSignal(quirk_target, COMSIG_PARENT_QDELETING)
	if(is_valid_quirk_target(quirk_target))
		if(mob_trait)
			REMOVE_TRAIT(quirk_target, mob_trait, ROUNDSTART_TRAIT)
		remove()
	quirk_target = to_mob
	if(process)
		START_PROCESSING(SSquirks, src)
	RegisterSignal(quirk_target, COMSIG_PARENT_QDELETING, PROC_REF(handle_mob_del))
	if(is_valid_quirk_target(quirk_target))
		if(mob_trait)
			ADD_TRAIT(to_mob, mob_trait, ROUNDSTART_TRAIT)
		add()
	on_transfer()

// laid out in chronological order
/datum/quirk/proc/add() //special "on add" effects
/datum/quirk/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/quirk/proc/post_spawn() //for text, disclaimers etc. given after you spawn in with the quirk
/datum/quirk/proc/on_process() //process() has some special checks, so this is the actual process
/datum/quirk/proc/on_transfer() //code called right before the quirk is transferred to a new mob
/datum/quirk/proc/remove() //special "on remove" effects

/datum/quirk/proc/handle_holder_del()
	SIGNAL_HANDLER
	qdel(src)

/datum/quirk/proc/handle_mob_del()
	SIGNAL_HANDLER
	UnregisterSignal(quirk_target, COMSIG_PARENT_QDELETING)
	STOP_PROCESSING(SSquirks, src)
	quirk_target = null

/datum/quirk/process(delta_time)
	if(quirk_target.stat == DEAD)
		return
	if(!is_valid_quirk_target(quirk_target))
		return
	on_process(delta_time)

/datum/quirk/proc/is_valid_quirk_target(mob/living/M)
	if(!is_type_in_list(M, restricted_mobtypes))
		return
	if(!restricted_species)
		return TRUE
	else
		var/datum/dna/mob_dna = M.has_dna()
		if(!mob_dna)
			return
		var/isvalid = is_type_in_list(mob_dna.species, restricted_species)
		if(species_whitelist != isvalid)
			return
		return TRUE

/datum/mind/proc/get_quirk_string(medical) //helper string. gets a string of all the quirks the mind has
	var/list/dat = list()
	if(!medical)
		for(var/datum/quirk/T in quirks)
			dat += T.name
		if(!length(dat))
			return "None"
		return dat.Join(", ")
	else
		for(var/datum/quirk/T in quirks)
			dat += T.medical_record_text
		if(!length(dat))
			return "None"
		return dat.Join("<br>")

/*

Commented version of Nearsighted to help you add your own quirks
Use this as a guideline

/datum/quirk/nearsighted
	name = "Nearsighted"
	///The quirk's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the quirk panel

	value = -1
	///If this is above 0, it's a positive quirk; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "HAS_TRAIT_FROM(src, X, sources)" checks around the code to check this; for instance, the Ageusia quirk is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	medical_record_text = "Subject has permanent nearsightedness."
	///These three are self-explanatory

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
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
