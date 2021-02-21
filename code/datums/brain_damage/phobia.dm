#define PHOBIA_STATE_CALM 0
#define PHOBIA_STATE_EDGY 1
#define PHOBIA_STATE_UNEASY 2
#define PHOBIA_STATE_FIGHTORFLIGHT 3
#define PHOBIA_STATE_TERROR 4
#define PHOBIA_STATE_FAINT 5

/datum/brain_trauma/mild/phobia
	name = "Phobia"
	desc = "Patient is unreasonably afraid of something."
	scan_desc = "phobia"
	gain_text = "<span class='warning'>You start finding default values very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of default values.</span>"
	var/phobia_type
	var/next_check = 0
	var/fearscore = 0
	var/stress = 0
	var/fear_state = PHOBIA_STATE_CALM
	var/stress_check = 0
	var/last_scare = 0
	var/datum/martial_art/psychotic_brawling/psychotic_brawling //this is for fight-or-flight panic
	var/list/trigger_words
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs
	var/list/trigger_objs //also checked in mob equipment
	var/list/trigger_turfs
	var/list/trigger_species

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type

	if(!phobia_type)
		phobia_type = pick(SStraumas.phobia_types)

	gain_text = "<span class='warning'>You start finding [phobia_type] very unnerving...</span>"
	lose_text = "<span class='notice'>You no longer feel afraid of [phobia_type].</span>"
	scan_desc += " of [phobia_type]"
	trigger_words = SStraumas.phobia_words[phobia_type]
	trigger_mobs = SStraumas.phobia_mobs[phobia_type]
	trigger_objs = SStraumas.phobia_objs[phobia_type]
	trigger_turfs = SStraumas.phobia_turfs[phobia_type]
	trigger_species = SStraumas.phobia_species[phobia_type]
	..()


/datum/brain_trauma/mild/phobia/on_clone()
	if(clonable)
		return new type(phobia_type)

/datum/brain_trauma/mild/phobia/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(is_blind(owner))
		return
	if(owner.stat >= UNCONSCIOUS)
		return
	if(world.time > next_check) //Even though it's clunky to only check every five seconds, it's far easier on the server than doing all this shit during every single proc of on_life()
		next_check = world.time + 50
		var/list/seen_atoms = view(7, owner)
		seen_atoms -= owner //make sure they aren't afraid of themselves.

		if(LAZYLEN(trigger_objs))
			for(var/obj/O in seen_atoms)
				if(is_type_in_typecache(O, trigger_objs))
					freak_out(O)

			for(var/mob/living/carbon/human/HU in seen_atoms) //check equipment for trigger items
				var/spook = 0
				for(var/X in HU.get_all_slots() | HU.held_items)
					var/obj/I = X
					if(!QDELETED(I) && is_type_in_typecache(I, trigger_objs))
						spook ++
				if(spook)
					freak_out(HU, spooklevel = spook)

		if(LAZYLEN(trigger_turfs))
			for(var/turf/T in seen_atoms)
				if(is_type_in_typecache(T, trigger_turfs))
					freak_out(T)

		if(LAZYLEN(trigger_mobs) || LAZYLEN(trigger_species))
			for(var/mob/M in seen_atoms)
				if(is_type_in_typecache(M, trigger_mobs))
					freak_out(M)

				else if(ishuman(M)) //check their species
					var/mob/living/carbon/human/H = M

					if(LAZYLEN(trigger_species) && H.dna && H.dna.species && is_type_in_typecache(H.dna.species, trigger_species))
						freak_out(H)

	if(fearscore && world.time > last_scare)//when we aren't being actively terrified, calm down
		fearscore --
	else if(stress && world.time > stress_check) //if we go long enough without fearing something, we begin to lose stress.
		stress --
		stress_check = world.time + min(3000, (600 * stress))
	switch(fearscore) //updating the fear state is handled in mob_life, as well as effects like adrenaline rush, handled when the state changes. other things are handled lower
		if(-INFINITY to 2) //there is a bit of a grace period before you begin to get scared
			if(fear_state > PHOBIA_STATE_CALM)
				fear_state = PHOBIA_STATE_CALM
				to_chat(owner, "<span class ='notice'>You calm down completely.</span>")
		if(3 to 8)
			if(fear_state >= PHOBIA_STATE_UNEASY)
				fear_state = PHOBIA_STATE_EDGY
				owner.remove_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE)
				to_chat(owner, "<span class ='notice'>you manage to calm down a little.</span>")
			if(fear_state == PHOBIA_STATE_CALM)
				fear_state = PHOBIA_STATE_EDGY
				if(prob(stress * 10))
					fearscore = 9
		if(9 to 16)
			if(fear_state >= PHOBIA_STATE_FIGHTORFLIGHT)
				fear_state = PHOBIA_STATE_UNEASY
				to_chat(owner, "<span class ='notice'>You're safe now... better be careful anyways.</span>")
				owner.add_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE, 100, override=TRUE, multiplicative_slowdown = 1)
				psychotic_brawling.remove(owner)
			if(fear_state <= PHOBIA_STATE_EDGY)
				fear_state = PHOBIA_STATE_UNEASY
				owner.add_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE, 100, override=TRUE, multiplicative_slowdown = 1)
				owner.Jitter(5)
				if(prob(stress * 10))
					fearscore = 17
		if(17 to 28)
			if(fear_state >= PHOBIA_STATE_TERROR) //we don't get an adrenaline rush when calming down
				fear_state = PHOBIA_STATE_FIGHTORFLIGHT
				to_chat(owner, "<span class ='notice'>It's gone for now... Better get out of here before it comes back.</span>")
				owner.add_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE, 100, override=TRUE, multiplicative_slowdown = -0.4)
			if(fear_state <= PHOBIA_STATE_UNEASY) //ADRENALINE RUSH! You get psychotic brawling, a burst of speed, and some stun avoidance for awhile. If you fail to escape or destroy the threat during an adrenaline rush, you're fucked either way
				fear_state = PHOBIA_STATE_FIGHTORFLIGHT
				to_chat(owner, "<span class ='userdanger'>YOU HAVE TO GET OUT OF HERE! IT'S DANGEROUS!</span>")
				owner.add_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE, 100, override=TRUE, multiplicative_slowdown = -0.4)//while terrified, get a speed boost
				owner.emote("scream")
				if(prob(stress * 10))
					fearscore = 27 //we don't get the adrenaline rush, and keel over like a baby immediately
				psychotic_brawling = new(null)
				psychotic_brawling.teach(owner, TRUE)
				owner.adjustStaminaLoss(-75)
				owner.SetStun(0)
				owner.SetKnockdown(0)
				owner.SetImmobilized(0)
				owner.SetParalyzed(0)
				if(owner.handcuffed)
					owner.visible_message("<span class ='danger'>[owner] starts frantically wrestling with their restraints!</span>", "<span class ='danger'>I'm trapped! I gotta get out, NOW!.</span>")
					stoplag(80)
					owner.uncuff()
				stress ++
		if(29 to 35)
			if(fear_state >= PHOBIA_STATE_FAINT)
				fear_state = PHOBIA_STATE_TERROR
			if(fear_state <= PHOBIA_STATE_FIGHTORFLIGHT)
				fear_state = PHOBIA_STATE_TERROR
				owner.remove_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE)
				owner.visible_message("<span class ='danger'>[owner] collapses into a fetal position and cowers in fear!</span>", "<span class ='userdanger'>I'm done for...</span>")
				owner.Paralyze(80)
				owner.Jitter(8)
				psychotic_brawling.remove(owner)
				stress++
				if(prob(stress * 10))
					fearscore = 36 //we immediately keel over and faint
		if(36 to INFINITY)
			if(fear_state <= PHOBIA_STATE_TERROR)
				fear_state = PHOBIA_STATE_FAINT
				owner.remove_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE) //in the case that we get so scared by enough bullshit nearby we skip the last stage
				psychotic_brawling.remove(owner)//ditto
				owner.Sleeping(300)
				owner.visible_message("<span class ='danger'>[owner] faints in fear!.</span>", "<span class ='userdanger'>It's too much! you faint!</span>")
				if(prob(stress * 3))
					owner.set_heartattack(TRUE)
					to_chat(owner, "<span class='userdanger'>Your heart stops!</span>")
				stress++



/datum/brain_trauma/mild/phobia/on_hear(message, speaker, message_language, raw_message, radio_freq)

	if(!owner.can_hear()) //words can't trigger you if you can't hear them *taps head*
		return message
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return message
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(raw_message, reg))
			if(fear_state <= (PHOBIA_STATE_CALM)) //words can put you on edge, but won't take you over it, unless you have gotten stressed already. don't call freak_out to avoid gaming the adrenaline rush
				fearscore ++
			message = reg.Replace(message, "<span class='phobia'>$1</span>")
			break
	return message

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(speech_args[SPEECH_MESSAGE], reg))
			to_chat(owner, "<span class='warning'>Saying \"<span class='phobia'>[word]</span>\" puts you on edge!</span>")
			if(fear_state <= (PHOBIA_STATE_CALM))
				fearscore ++

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word, spooklevel = 0)//spooklevel is only used when calculating amount of scary items on a person.
	if(owner.stat >= UNCONSCIOUS)
		return
	if(fear_state >= PHOBIA_STATE_EDGY)
		stress_check = world.time + 3000
		last_scare = world.time + 100
	if(reason)
		if(isliving(reason))
			var/mob/living/L = reason
			if(spooklevel)
				if(L.stat)
					if(fear_state <= (PHOBIA_STATE_EDGY))
						fearscore += spooklevel
				else
					fearscore += spooklevel * 2
			else if(L.stat)
				if(fear_state <= (PHOBIA_STATE_EDGY))
					fearscore += 2
			else
				fearscore += 4//this is for simplemobs, but also dependent on species

		else if(fear_state <= (PHOBIA_STATE_CALM)) //inanimate objects won't trigger you too much
			fearscore ++
		fearscore += stress
	else
		fearscore ++ //I have no idea how this would happen. just increase fear by one, with no cap
	switch(fear_state)//only happens once every five or so seconds, while scared
		if(PHOBIA_STATE_EDGY)
			owner.Jitter(1)
			if(reason)
				to_chat(owner, "<span class ='warning'>[reason] sets you on edge...</span>")
		if(PHOBIA_STATE_UNEASY)
			owner.Jitter(1)
			if(reason)
				to_chat(owner, "<span class ='warning'>[reason] makes you uneasy...</span>")
		if(PHOBIA_STATE_FIGHTORFLIGHT)
			owner.adjustStaminaLoss(-10 * (min(1, spooklevel)))
			owner.SetUnconscious(0)
			owner.SetStun(0)
			owner.SetKnockdown(0)
			owner.SetImmobilized(0)
			owner.SetParalyzed(0)
		if(PHOBIA_STATE_TERROR)
			owner.Paralyze(10 * spooklevel)
			owner.Jitter(3)
		if(PHOBIA_STATE_FAINT)
			if(!owner.stat)
				owner.Sleeping(300)

/datum/brain_trauma/mild/phobia/on_lose()
	owner.remove_movespeed_modifier(MOVESPEED_ID_PHOBIA, TRUE)
	psychotic_brawling.remove(owner)
	QDEL_NULL(psychotic_brawling)
	..()

// Defined phobia types for badminry, not included in the RNG trauma pool to avoid diluting.

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "spiders"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/space
	phobia_type = "space"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/security
	phobia_type = "security"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "clowns"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "greytide"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "lizards"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "skeletons"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "snakes"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "robots"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "doctors"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "authority"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "the supernatural"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "aliens"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "strangers"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "birds"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "falling"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "anime"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "conspiracies"
	random_gain = FALSE

#undef PHOBIA_STATE_CALM
#undef PHOBIA_STATE_EDGY
#undef PHOBIA_STATE_UNEASY
#undef PHOBIA_STATE_FIGHTORFLIGHT
#undef PHOBIA_STATE_TERROR
#undef PHOBIA_STATE_FAINT