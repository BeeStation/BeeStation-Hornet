/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful"
	message_param = "give daps to %t"
	restraint_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow"

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hand"
	message_param = "shakes hands with %t"
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself"
	message_param = "hugs %t"
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	// MonkeStation Edit Start
	// Alternative Scream Hook
	if(H.alternative_screams.len)
		return pick(H.alternative_screams)
	// MonkeStation Edit End
	if(H.mind?.miming)
		return
	// MonkeStation Edit Start
	//Ease of adding new emotes to species
	H.adjustOxyLoss(5)
	var/species = H.dna.species.id
	var/list/options
	if(user.gender == FEMALE)
		if(!GLOB.female_screams.Find(species))
			options = GLOB.female_screams["human"]
			return pick(options)
		options = GLOB.female_screams[species]
		return pick(options)
	if(!GLOB.male_screams.Find(species))
		options = GLOB.male_screams["human"]
		return pick(options)
	options = GLOB.male_screams[species]
	return pick(options)
	//MonkeStation Edit End

// MonkeStation Edit Start
//Reworks the laugh emote
/datum/emote/living/carbon/human/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs"
	message_mime = "laughs silently"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/human/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		return !C.silent

/datum/emote/living/carbon/human/laugh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	// Alternative Laugh Hook
	if(H.alternative_laughs.len)
		return pick(H.alternative_laughs)
	//Laugh changes for alternative species
	var/species = H.dna.species.id
	var/list/options
	if(user.gender == FEMALE)
		if(!GLOB.female_laughs.Find(species))
			options = GLOB.female_laughs["human"]
			return pick(options)
		options = GLOB.female_laughs[species]
		return pick(options)
	if(!GLOB.male_laughs.Find(species))
		options = GLOB.male_laughs["human"]
		return pick(options)
	options = GLOB.male_laughs[species]
	return pick(options)
// MonkeStation Edit End

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second"

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand"
	restraint_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes"
	message_param = "salutes to %t"
	restraint_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs"

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wagging their tail" //MonkeStation Edit: Toggled Wagging

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
//MonkeStation Edit Start: Tail Overhaul. Yes, you read that right. We here have the best god damn tails you can find. Please kill me.
		to_chat(user, "<span class='notice'>You don't have a tail!</span>")
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tail/tail_finder = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail_finder.wagging_mutant_name)
		return //because certain tails literally don't have animations.
	if(!tail_finder.wagging) //Start Wagging
		tail_finder.wagging = TRUE
		H.dna.species.mutant_bodyparts += tail_finder.wagging_mutant_name
		H.dna.species.mutant_bodyparts -= tail_finder.mutant_bodypart_name
	else //Stop wagging
		tail_finder.wagging = FALSE
		H.dna.species.mutant_bodyparts -= tail_finder.wagging_mutant_name
		H.dna.species.mutant_bodyparts += tail_finder.mutant_bodypart_name
	H.update_body()
//MonkeStation Edit End

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
//MonkeStation Edit Start
	var/obj/item/organ/tail/tail_finder = H.getorganslot(ORGAN_SLOT_TAIL)
	return tail_finder

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tail/tail_finder = H.getorganslot(ORGAN_SLOT_TAIL)
	if(tail_finder)
		switch(tail_finder.wagging)
			if(TRUE)
				. = "stops [message]"
			if(FALSE)
				. = "starts [message]"
//MonkeStation Edit End

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings"

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		H.Togglewings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(("wings" in H.dna.species.mutant_bodyparts) || ("moth_wings" in H.dna.species.mutant_bodyparts))
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species)
		if(H.dna.features["wings"] != "None")
			return TRUE
		if(H.dna.features["moth_wings"] != "None")
			var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
			if(istype(wings))
				if(wings.flight_level >= WINGS_FLYING)
					return TRUE

/mob/living/carbon/human/proc/Togglewings()
	if(!dna || !dna.species)
		return FALSE
	var/obj/item/organ/wings/wings = getorganslot(ORGAN_SLOT_WINGS)
	if(istype(wings))
		if(wings.toggleopen(src))
			return TRUE
	return FALSE


/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

//MonkeStation Edit Start
//Butt-Based Farts
/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(user.stat == CONSCIOUS)
		if(!user.getorgan(/obj/item/organ/butt) || !ishuman(user))
			to_chat(user, "<span class='warning'>You don't have a butt!</span>")
			return
		var/obj/item/organ/butt/booty = user.getorgan(/obj/item/organ/butt)
		if(!booty.cooling_down)
			booty.On_Fart(user)
//MonkeStation Edit End

//Ayy lmao

// Robotic Tongue emotes. Beep!

/datum/emote/living/carbon/human/robot_tongue/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/obj/item/organ/tongue/T = user.getorganslot("tongue")
	if(T.status == ORGAN_ROBOTIC)
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps"
	message_param = "beeps at %t"

/datum/emote/living/carbon/human/robot_tongue/beep/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/twobeep.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes"
	message_param = "buzzes at %t"

/datum/emote/living/carbon/human/robot_tongue/buzz/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/buzz2
	key = "buzz2"
	message = "buzzes twice"

/datum/emote/living/carbon/human/robot_tongue/buzz2/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/buzz-two.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes"

/datum/emote/living/carbon/human/robot_tongue/chime/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/chime.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings"
	message_param = "pings at %t"

/datum/emote/living/carbon/human/robot_tongue/ping/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/ping.ogg', 50)

 // Clown Robotic Tongue ONLY. Henk.

/datum/emote/living/carbon/human/robot_tongue/clown/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	if(user.mind.assigned_role == "Clown")
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/clown/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks"

/datum/emote/living/carbon/human/robot_tongue/clown/honk/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/items/bikehorn.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/clown/sad
	key = "sad"
	key_third_person = "plays a sad trombone"
	message = "plays a sad trombone"

/datum/emote/living/carbon/human/robot_tongue/clown/sad/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/misc/sadtrombone.ogg', 50)
