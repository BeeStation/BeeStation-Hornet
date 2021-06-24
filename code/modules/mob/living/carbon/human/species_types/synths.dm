/datum/species/synth
	name = "Synth" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	species_traits = list(NOTRANSSTING, NOZOMBIE, REVIVESBYHEALING, NOHUSK, NO_DNA_COPY) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_NOBREATH, TRAIT_NOHUNGER, TRAIT_TOXIMMUNE, TRAIT_NOCRITDAMAGE)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	meat = null
	damage_overlay_type = "synth"
	limbs_id = "synth"
	var/disguise_fail_health = 75 //When their health gets to this level their synthflesh partially falls off (this doesnt work)
	var/datum/species/fake_species //a species to do most of our work for us, unless we're damaged
	var/list/initial_species_traits = list() //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits = list()
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	species_language_holder = /datum/language_holder/synthetic

/datum/species/synth/New()
	initial_species_traits = species_traits.Copy()
	initial_inherent_traits = inherent_traits.Copy()
	..()

/datum/species/synth/military
	name = "Military Synth"
	id = "military_synth"
	armor = 25
	punchdamage = 14
	inherent_traits = list(TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_NOBREATH, TRAIT_NOHUNGER, TRAIT_TOXIMMUNE, TRAIT_NOSTAMCRIT, TRAIT_STRONG_GRABBER)
	disguise_fail_health = 50 //This literally does nothing. This doesnt work.
	changesource_flags = MIRROR_BADMIN | WABBAJACK

/datum/species/synth/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	if (H.dna.features["legs"] == "Digitigrade Legs") //I fucking hate this.
		initial_species_traits |= DIGITIGRADE //If the target has digitigrade legs, store them for later
	..()
	assume_disguise(old_species, H)
	RegisterSignal(H, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/species/synth/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	UnregisterSignal(H, COMSIG_MOB_SAY)

/datum/species/synth/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(istype(R, /datum/reagent/medicine/synthflesh))
		R.reaction_mob(H, TOUCH, 2, 0) //heal a little
		H.reagents.remove_reagent(R.type, REAGENTS_METABOLISM)
	else
		H.reagents.del_reagent(R.type) //Not synth flesh? eat shit and die
	return FALSE

/datum/species/synth/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.health <= 0 && H.stat != DEAD) // So they die eventually instead of being stuck in crit limbo, due to not taking OXY damage.
		H.adjustFireLoss(6)
		if(prob(5))
			to_chat(H, "<span class='warning'>Warning: Critical damage sustained. Full unit shutdown imminent.</span>")

/datum/species/synth/proc/assume_disguise(datum/species/S, mob/living/carbon/human/H)
	if(S && !istype(S, type))
		name = S.name
		say_mod = S.say_mod
		sexes = S.sexes
		species_traits = initial_species_traits.Copy()
		inherent_traits = initial_inherent_traits.Copy()
		species_traits |= S.species_traits
		inherent_traits |= S.inherent_traits
		attack_verb = S.attack_verb
		attack_sound = S.attack_sound
		miss_sound = S.miss_sound
		meat = S.meat
		mutant_bodyparts = S.mutant_bodyparts.Copy()
		mutant_organs = S.mutant_organs.Copy()
		default_features = S.default_features.Copy()
		forced_features = S.forced_features.Copy()
		nojumpsuit = S.nojumpsuit
		no_equip = S.no_equip.Copy()
		limbs_id = S.limbs_id
		use_skintones = S.use_skintones
		fixed_mut_color = S.fixed_mut_color
		hair_color = S.hair_color
		fake_species = new S.type
		handle_snowflake_code(H, S)
	else
		name = initial(name)
		say_mod = initial(say_mod)
		species_traits = initial_species_traits.Copy()
		inherent_traits = initial_inherent_traits.Copy()
		attack_verb = initial(attack_verb)
		attack_sound = initial(attack_sound)
		miss_sound = initial(miss_sound)
		mutant_bodyparts = list()
		default_features = list()
		forced_features = list()
		nojumpsuit = initial(nojumpsuit)
		no_equip = list()
		qdel(fake_species)
		fake_species = null
		meat = initial(meat)
		limbs_id = "synth"
		use_skintones = 0
		sexes = 0
		fixed_mut_color = ""
		hair_color = ""
	for(var/X in H.bodyparts) //propagates the damage_overlay changes
		var/obj/item/bodypart/BP = X
		BP.update_limb()
	H.update_body_parts() //to update limb icon cache with the new damage overlays

//Proc redirects:
//Passing procs onto the fake_species, to ensure we look as much like them as possible

/datum/species/synth/handle_hair(mob/living/carbon/human/H, forced_colour)
	if(fake_species)
		fake_species.handle_hair(H, forced_colour)
	else
		return ..()


/datum/species/synth/handle_body(mob/living/carbon/human/H)
	if(fake_species)
		fake_species.handle_body(H)
	else
		return ..()


/datum/species/synth/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	if(fake_species)
		fake_species.handle_mutant_bodyparts(H,forced_colour)
	else
		return ..()


/datum/species/synth/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if (isliving(source)) // yeah it's gonna be living but just to be clean
		var/mob/living/L = source
		if(fake_species && L.health > disguise_fail_health)
			switch (fake_species.type)
				if (/datum/species/golem/bananium)
					speech_args[SPEECH_SPANS] |= SPAN_CLOWN
				if (/datum/species/golem/clockwork)
					speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/species/synth/spec_revival(mob/living/carbon/human/H)
	H.grab_ghost()
	H.visible_message("<span class='notice'>[H]'s eyes snap open!</span>", "<span class ='boldwarning'>You can feel your limbs responding again!</span>")

/datum/species/synth/proc/handle_snowflake_code(mob/living/carbon/human/H, datum/species/S) //I LITERALLY FUCKING HATE ALL OF YOU. I HATE THE FACT THIS NEEDS TO EXIST.
	switch(S.id)
		if("felinid")
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Cat"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Cat"
			if(H.dna.features["ears"] == "Cat")
				var/obj/item/organ/ears/cat/ears = new
				ears.Insert(H, drop_if_replaced = FALSE)
			else
				mutantears = /obj/item/organ/ears
			if(H.dna.features["tail_human"] == "Cat")
				var/obj/item/organ/tail/cat/tail = new
				tail.Insert(H, drop_if_replaced = FALSE)
			else
				mutanttail = null
		if("lizard")
			if(DIGITIGRADE in species_traits)
				var/mob/living/carbon/C = H
				default_features["legs"] = "Digitigrade Legs"
				C.Digitigrade_Leg_Swap(FALSE)
