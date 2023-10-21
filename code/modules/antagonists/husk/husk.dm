//Living husk mob made for Spooktober 2023
/mob/living/simple_animal/husk
	name = "living husk"
	real_name = "living husk"
	desc = "A shell of a human being, blood pouring out of many holes in its body. Its face an shapeless gaping hole."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/human.dmi'
	icon_state = "husk"
	icon_living = "husk"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	bloodcrawl = BLOODCRAWL
	faction = list("hostile")
	maxHealth = 45
	health = 45
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //to test
	obj_damage = 15
	melee_damage = 15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hardattacks = TRUE
	var/playstyle_string = "<span class='big bold'>You are a living husk,</span><B> the animated defiled remains of a past crewmember. You have a single desire: To take revenge on the living.  \
							You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and disappearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, sending them to a realm of despair and agony. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"

	mobchatspan = "cultmobsay"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart)
	deathmessage = "wails in anger as it collapses into a puddle of viscera!"
	var/reincarnate_husk = TRUE //Admins can turn this false if they want to stop reincarnations
	del_on_death = TRUE


/mob/living/simple_animal/husk/Initialize(mapload)
	..()
	var/obj/effect/dummy/phased_mob/slaughter/holder = new /obj/effect/dummy/phased_mob/slaughter(src.loc)
	forceMove(holder)
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodwalk = new
	var/obj/effect/proc_holder/spell/aoe_turf/conjure/blood/gibs/spread_blood = new
	AddSpell(spread_blood)
	AddSpell(bloodwalk)
	bloodwalk.phased = TRUE
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a living husk?", ROLE_REVENANT, /datum/role_preference/midround_ghost/revenant, 10 SECONDS, ignore_category = null, flashwindow = TRUE, req_hours = 0)
	//get the list of candidates
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		key = C.key
	else
		message_admins("No ghosts have volunteered to take the living husk!")

/mob/living/simple_animal/husk/mind_initialize()
	. = ..()
	to_chat(src, playstyle_string)

/mob/living/simple_animal/husk/death()
	new /obj/effect/gibspawner/blood_puddle(src)
	deathsound = 'sound/magic/demon_dies.ogg'
	if(reincarnate_husk)
		new /obj/effect/husk_handler()
	..()

/obj/effect/husk_handler
	name = "husk respawn handler"
	anchored = TRUE
	vis_flags = VIS_INHERIT_PLANE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/husk_handler/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(reincarnate)), 30 SECONDS)

//if the mob dies
//after 30 seconds
//respawn the mob (phased)
//then remove the respawn handler
/obj/effect/husk_handler/proc/reincarnate()
	new /mob/living/simple_animal/husk/(pick(GLOB.xeno_spawn))
	qdel(src)

