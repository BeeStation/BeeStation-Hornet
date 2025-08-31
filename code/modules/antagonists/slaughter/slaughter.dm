//////////////////The Monster

/mob/living/simple_animal/hostile/imp/slaughter/
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speed = 1
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list(FACTION_HELL)
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tear into"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage = 30
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	bloodcrawl = BLOODCRAWL_EAT
	hardattacks = TRUE
	var/playstyle_string = span_bigbold("You are a slaughter demon,") + "<B> a terrible creature from another realm. You have a single desire: To kill.  \
	You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and disappearing from the station at will. \
	Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
	You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish.</B> \
	" + span_warning("You cannot re-enter the living world until you've rested for five seconds in the sea of blood.")

	mobchatspan = "cultmobsay"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart/demon)
	// Keep the people we hug!
	var/list/consumed_mobs = list()
	del_on_death = TRUE
	var/crawl_type = /datum/action/spell/jaunt/bloodcrawl/slaughter_demon
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"
	discovery_points = 3000

	var/revive_eject = FALSE

/mob/living/simple_animal/hostile/imp/slaughter/Initialize(mapload)
	. = ..()
	var/datum/action/spell/jaunt/bloodcrawl/slaughter_demon/crawl = new crawl_type(src)
	crawl.Grant(src)
	RegisterSignal(src, list(COMSIG_MOB_ENTER_JAUNT, COMSIG_MOB_AFTER_EXIT_JAUNT), PROC_REF(on_crawl))

/// Whenever we enter or exit blood crawl, reset our bonus and hitstreaks.
/mob/living/simple_animal/hostile/imp/slaughter/proc/on_crawl(datum/source)
	SIGNAL_HANDLER

	// Grant us a speed boost if we're on the mortal plane
	if(isturf(loc))
		add_movespeed_modifier(/datum/movespeed_modifier/slaughter)
		addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier), /datum/movespeed_modifier/slaughter), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)


/mob/living/simple_animal/hostile/imp/slaughter/Destroy()
	var/turf/cur_loc = get_turf(src)
	playsound(cur_loc, feast_sound, 50, 1, -1)
	for(var/mob/living/stored_mob in consumed_mobs)
		stored_mob.forceMove(cur_loc)

		if(!revive_eject)
			continue
		if(!stored_mob.revive(HEAL_ALL))
			continue
		stored_mob.grab_ghost(force = TRUE)
		to_chat(stored_mob, span_clowntext("You leave [src]'s warm embrace, and feel ready to take on the world."))

	consumed_mobs.Cut()
	consumed_mobs = null

	return ..()

/obj/effect/decal/cleanable/blood/innards
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "innards"
	random_icon_states = null




//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/heart/demon/update_icon()
	return //always beating visually

/obj/item/organ/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"), \
						span_danger("An unnatural hunger consumes you. You raise [src] your mouth and devour it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

	if(locate(/datum/action/spell/jaunt/bloodcrawl) in user.actions)
		to_chat(user, ("<span class='warning'>...and you don't feel any different.</span>"))
		qdel(src)
		return

	user.visible_message(span_warning("[user]'s eyes flare a deep crimson!"), \
						span_userdanger("You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/heart/demon/on_mob_insert(mob/living/carbon/heart_owner)
	..()
	// Gives a non-eat-people crawl to the new owner
	var/datum/action/spell/jaunt/bloodcrawl/crawl = new(heart_owner)
	crawl.Grant(heart_owner)

/obj/item/organ/heart/demon/on_mob_remove(mob/living/carbon/heart_owner, special = FALSE, movement_flags)
	..()
	var/datum/action/spell/jaunt/bloodcrawl/crawl = locate() in heart_owner.actions
	qdel(crawl)

/obj/item/organ/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/hostile/imp/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles","titters","chuckles")
	emote_hear = list("guffaws","laughs")
	response_help_continuous = "hugs"
	attack_verb_continuous = "wildly tickles"
	attack_verb_simple = "wildly tickle"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	deathsound = 'sound/misc/sadtrombone.ogg'

	icon_state = "honkmon"
	icon_living = "honkmon"
	deathmessage = "fades out, as all of its friends are released from its \
		prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})
	crawl_type = /datum/action/spell/jaunt/bloodcrawl/slaughter_demon/funny

	playstyle_string = span_bigbold("You are a laughter demon") + "\
	<B> a wonderful creature from another realm. You have a single \
	desire: " + span_clowntext("To hug and tickle.") + "<BR>\
	You may use the \"Blood Crawl\" ability near blood pools to travel \
	through them, appearing and disappearing from the station at will. \
	" + span_warning("You cannot re-enter the living world until you've rested for five seconds in the sea of blood.") + "\
	Pulling a dead or unconscious mob while you enter a pool will pull \
	them in with you, allowing you to hug them and regain your health.<BR> \
	You move quickly upon leaving a pool of blood, but the material world \
	will soon sap your strength and leave you sluggish.<BR>\
	What makes you a little sad is that people seem to die when you tickle \
	them; but don't worry! When you die, everyone you hugged will be \
	released and fully healed, because in the end it's just a jape, \
	sibling!</B>"
	revive_eject = TRUE

/mob/living/simple_animal/hostile/imp/slaughter/laughter/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			investigate_log("has died from a devastating explosion.", INVESTIGATE_DEATHS)
			death()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)
