//space pirates from the pirate event.

/obj/effect/mob_spawn/ghost_role/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a space pirate"
	outfit = /datum/outfit/pirate/space
	anchored = TRUE
	density = FALSE
	show_flavor = FALSE //Flavour only exists for spawners menu
	you_are_text = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	spawner_job_path = /datum/job/space_pirate
	banType = ROLE_SPACE_PIRATE
	is_antagonist = TRUE
	///Rank of the pirate on the ship, it's used in generating pirate names!
	var/rank = "Deserter"
	///Whether or not it will spawn a fluff structure upon opening.
	var/spawn_oldpod = TRUE

/obj/effect/mob_spawn/ghost_role/human/pirate/special(mob/living/spawned_mob, mob/mob_possessor)
	. = ..()
	mob_possessor.fully_replace_character_name(mob_possessor.real_name, generate_pirate_name(mob_possessor.gender))
	mob_possessor.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/ghost_role/human/pirate/proc/generate_pirate_name(spawn_gender)
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/ghost_role/human/pirate/Destroy()
	if(spawn_oldpod)
		new /obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/*
/obj/effect/mob_spawn/ghost_role/human/pirate/captain
	rank = "Renegade Leader"
	outfit = /datum/outfit/pirate/space/captain
	assignedrole = "Space Pirate Captain"
*/

/obj/effect/mob_spawn/ghost_role/human/pirate/captain/special(mob/living/spawned_mob, mob/mob_possessor)
	mob_possessor.fully_replace_character_name(mob_possessor.real_name, generate_pirate_name(mob_possessor.gender))
	mob_possessor.mind.add_antag_datum(/datum/antagonist/pirate/captain)

/*
/obj/effect/mob_spawn/ghost_role/human/pirate/gunner
	rank = "Rogue"
*/

//Skeletons

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton
	name = "pirate remains"
	desc = "Some unanimated bones. They feel like they could spring to life any moment!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	spawn_oldpod = FALSE
	prompt_name = "a skeleton pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate
	rank = "Mate"


/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/captain

/obj/effect/mob_spawn/ghost_role/human/pirate/skeleton/gunner
	rank = "Gunner"
