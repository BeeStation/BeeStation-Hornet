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
	gain_text = span_warning("You start finding default values very unnerving...")
	lose_text = span_notice("You no longer feel afraid of default values.")
	var/phobia_type
	var/next_check = 0
	var/fearscore = 0
	var/stress = 0
	var/fear_state = PHOBIA_STATE_CALM
	var/stress_check = 0
	var/last_scare = 0
	var/faint_length = 0
	var/cooldown_length = 0 //Grace period between faints caused by high fearscore
	var/list/trigger_words
	//instead of cycling every atom, only cycle the relevant types
	var/list/trigger_mobs
	var/list/trigger_objs //also checked in mob equipment
	var/list/trigger_turfs
	var/list/trigger_species
	COOLDOWN_DECLARE(timer)

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type

	if(!phobia_type)
		phobia_type = pick_weight(SStraumas.phobia_types)

	faint_length=300
	cooldown_length=faint_length*2  //Has to be at least faint_length, else it practically doesnt do anything
	gain_text = span_warning("You start finding [phobia_type] very unnerving...")
	lose_text = span_notice("You no longer feel afraid of [phobia_type].")
	scan_desc += " of [phobia_type]"
	trigger_words = SStraumas.phobia_words[phobia_type]
	trigger_mobs = SStraumas.phobia_mobs[phobia_type]
	trigger_objs = SStraumas.phobia_objs[phobia_type]
	trigger_turfs = SStraumas.phobia_turfs[phobia_type]
	trigger_species = SStraumas.phobia_species[phobia_type]
	fear_state = PHOBIA_STATE_CALM
	..()


/datum/brain_trauma/mild/phobia/on_clone()
	if(CHECK_BITFIELD(trauma_flags, TRAUMA_CLONEABLE))
		return new type(phobia_type)

/datum/brain_trauma/mild/phobia/on_gain()
	if(is_type_in_typecache(owner.dna.species, trigger_species))
		trigger_species -= owner.dna.species.type
	..()

/datum/brain_trauma/mild/phobia/on_life(delta_time, times_fired)
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(owner.is_blind())
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
				for(var/obj/I as() in HU.get_all_worn_items() | HU.held_items)
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
				to_chat(owner, span_notice("You calm down completely."))
		if(3 to 8)
			if(fear_state >= PHOBIA_STATE_UNEASY)
				fear_state = PHOBIA_STATE_EDGY
				owner.remove_movespeed_modifier(/datum/movespeed_modifier/phobia)
				to_chat(owner, span_notice("You manage to calm down a little."))
			if(fear_state == PHOBIA_STATE_CALM)
				fear_state = PHOBIA_STATE_EDGY
				if(prob(stress * 5))
					fearscore = 9
		if(9 to 16)
			if(fear_state >= PHOBIA_STATE_FIGHTORFLIGHT)
				fear_state = PHOBIA_STATE_UNEASY
				to_chat(owner, span_notice("You're safe now... better be careful anyways."))
				owner.add_movespeed_modifier(/datum/movespeed_modifier/phobia)
			if(fear_state <= PHOBIA_STATE_EDGY)
				fear_state = PHOBIA_STATE_UNEASY
				owner.add_movespeed_modifier(/datum/movespeed_modifier/phobia)
				owner.set_jitter_if_lower(10 SECONDS)
				if(prob(stress * 5))
					fearscore = 17
		if(17 to 28)
			if(fear_state >= PHOBIA_STATE_TERROR) //we don't get an adrenaline rush when calming down
				fear_state = PHOBIA_STATE_FIGHTORFLIGHT
				to_chat(owner, span_notice("It's gone for now... Better get out of here before it comes back."))
				owner.add_movespeed_modifier(/datum/movespeed_modifier/phobia/terrified)
			if(fear_state <= PHOBIA_STATE_UNEASY) //ADRENALINE RUSH! You get psychotic brawling, a burst of speed, and some stun avoidance for awhile. If you fail to escape or destroy the threat during an adrenaline rush, you're fucked either way
				fear_state = PHOBIA_STATE_FIGHTORFLIGHT
				to_chat(owner, span_userdanger("YOU HAVE TO GET OUT OF HERE! IT'S DANGEROUS!"))
				owner.add_movespeed_modifier(/datum/movespeed_modifier/phobia/terrified)//while terrified, get a speed boost
				owner.emote("scream")
				if(prob(stress * 5))
					fearscore = 29 //we don't get the adrenaline rush, and keel over like a baby immediately
				owner.adjustStaminaLoss(-75)
				owner.SetStun(0)
				owner.SetKnockdown(0)
				owner.SetImmobilized(0)
				owner.SetParalyzed(0)
				if(owner.handcuffed)
					owner.visible_message(span_danger("[owner] starts frantically wrestling with their restraints!"), span_danger("I'm trapped! I gotta get out, NOW!."))
					stoplag(80)
					owner.uncuff()
				stress ++
		if(29 to 35)
			if(fear_state >= PHOBIA_STATE_FAINT)
				fear_state = PHOBIA_STATE_TERROR
			if(fear_state <= PHOBIA_STATE_FIGHTORFLIGHT)
				fear_state = PHOBIA_STATE_TERROR
				owner.remove_movespeed_modifier(/datum/movespeed_modifier/phobia, TRUE)
				owner.visible_message(span_danger("[owner] collapses into a fetal position and cowers in fear!"), span_userdanger("I'm done for..."))
				owner.Paralyze(80)
				owner.set_jitter_if_lower(16 SECONDS)
				stress++
				if(prob(stress * 5))
					fearscore = 36 //we immediately keel over and faint
		if(36 to INFINITY)
			if(fear_state <= PHOBIA_STATE_TERROR)
				fear_state = PHOBIA_STATE_FAINT
				owner.remove_movespeed_modifier(/datum/movespeed_modifier/phobia, TRUE) //in the case that we get so scared by enough bullshit nearby we skip the last stage
				if(!timer || COOLDOWN_FINISHED(src, timer))
					COOLDOWN_START(src, timer, cooldown_length)
					owner.visible_message(span_danger("[owner] faints in fear!"), span_userdanger("It's too much! You faint!"))
					owner.Sleeping(faint_length)
					fear_state = PHOBIA_STATE_EDGY
					fearscore = 9
					stress++
					if(prob(stress))
						owner.set_heartattack(TRUE)
						to_chat(owner, span_userdanger("Your heart stops!"))
				else
					owner.visible_message(span_danger("[owner] looks ghostly pale, trembling uncontrollably!"), span_userdanger("This is HELL! OUT!! NOW!!!"))
					owner.set_jitter_if_lower(20 SECONDS)
					stress++



/datum/brain_trauma/mild/phobia/handle_hearing(datum/source, list/hearing_args)

	if(!owner.can_hear()) //words can't trigger you if you can't hear them *taps head*
		return
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(hearing_args[HEARING_RAW_MESSAGE], reg))
			if(fear_state <= (PHOBIA_STATE_CALM)) //words can put you on edge, but won't take you over it, unless you have gotten stressed already. don't call freak_out to avoid gaming the adrenaline rush
				fearscore ++
			hearing_args[HEARING_RAW_MESSAGE] = reg.Replace(hearing_args[HEARING_RAW_MESSAGE], span_phobia("$1"))
			break

/datum/brain_trauma/mild/phobia/handle_speech(datum/source, list/speech_args)
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(speech_args[SPEECH_MESSAGE], reg))
			to_chat(owner, span_warning("Saying \"[span_phobia("[word]")]\" puts you on edge!"))
			if(fear_state <= (PHOBIA_STATE_CALM))
				fearscore ++

/datum/brain_trauma/mild/phobia/proc/freak_out(atom/reason, trigger_word, spooklevel = 0)//spooklevel is only used when calculating amount of scary items on a person.
	if(owner.stat >= UNCONSCIOUS)
		return
	if(fear_state >= PHOBIA_STATE_EDGY)
		stress_check = world.time + 3000  //Stress begins to fall after 5 minutes only
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
			owner.set_jitter_if_lower(2 SECONDS)
			if(reason)
				to_chat(owner, span_warning("[reason] sets you on edge..."))
		if(PHOBIA_STATE_UNEASY)
			owner.set_jitter_if_lower(2 SECONDS)
			if(reason)
				to_chat(owner, span_warning("[reason] makes you uneasy..."))
		if(PHOBIA_STATE_FIGHTORFLIGHT)
			owner.adjustStaminaLoss(-10 * (min(1, spooklevel)))
			owner.SetUnconscious(0)
			owner.SetStun(0)
			owner.SetKnockdown(0)
			owner.SetImmobilized(0)
			owner.SetParalyzed(0)
		if(PHOBIA_STATE_TERROR)
			owner.Paralyze(10 * spooklevel)
			owner.set_jitter_if_lower(6 SECONDS)
		if(PHOBIA_STATE_FAINT)
			if(!owner.stat)
				if(!timer || (timer && COOLDOWN_FINISHED(src, timer)))  //If fainting hasnt happened yet, the cooldown timer never havve been created, so we check for that too
					COOLDOWN_START(src, timer, cooldown_length)
					owner.visible_message(span_danger("[owner] faints in fear!"), span_userdanger("It's too much! You faint!"))
					owner.Sleeping(faint_length)
					fear_state = PHOBIA_STATE_EDGY
					fearscore = 9
					stress++


/datum/brain_trauma/mild/phobia/on_lose()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/phobia)
	..()

// Defined phobia types for badminry, not included in the RNG trauma pool to avoid diluting.

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "spiders"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/space
	phobia_type = "space"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/security
	phobia_type = "security"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "clowns"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "greytide"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "lizards"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "skeletons"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "snakes"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "robots"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "doctors"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "authority"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "the supernatural"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "aliens"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "strangers"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "birds"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "falling"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "anime"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "conspiracies"
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

#undef PHOBIA_STATE_CALM
#undef PHOBIA_STATE_EDGY
#undef PHOBIA_STATE_UNEASY
#undef PHOBIA_STATE_FIGHTORFLIGHT
#undef PHOBIA_STATE_TERROR
#undef PHOBIA_STATE_FAINT
