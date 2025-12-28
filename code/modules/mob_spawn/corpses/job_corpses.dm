
//jobs from ss13 but DEAD.

/obj/effect/mob_spawn/corpse/human/cargo_tech
	name = "Cargo Tech"
	outfit = /datum/outfit/job/cargo_technician

/obj/effect/mob_spawn/ghost_role/human/cook
	name = JOB_NAME_COOK
	outfit = /datum/outfit/job/cook

/obj/effect/mob_spawn/ghost_role/human/doctor
	name = "Doctor"
	outfit = /datum/outfit/job/medical_doctor

/obj/effect/mob_spawn/ghost_role/human/geneticist
	name = "Geneticist"
	outfit = /datum/outfit/job/geneticist

/obj/effect/mob_spawn/ghost_role/human/engineer
	name = "Engineer"
	outfit = /datum/outfit/job/engineer/gloved

/obj/effect/mob_spawn/ghost_role/human/engineer/mod
	outfit = /datum/outfit/job/engineer/mod

/obj/effect/mob_spawn/ghost_role/human/clown
	name = JOB_NAME_CLOWN
	outfit = /datum/outfit/job/clown

/obj/effect/mob_spawn/ghost_role/human/scientist
	name = JOB_NAME_SCIENTIST
	outfit = /datum/outfit/job/scientist

/obj/effect/mob_spawn/ghost_role/human/miner
	name = JOB_NAME_SHAFTMINER
	outfit = /datum/outfit/job/miner

/obj/effect/mob_spawn/ghost_role/human/miner/mod
	outfit = /datum/outfit/job/miner/equipped/mod

/obj/effect/mob_spawn/ghost_role/human/miner/explorer
	outfit = /datum/outfit/job/miner/equipped

/obj/effect/mob_spawn/ghost_role/human/plasmaman
	mob_species = /datum/species/plasmaman
	outfit = /datum/outfit/plasmaman

/obj/effect/mob_spawn/corpse/human/assistant
	name = JOB_NAME_ASSISTANT
	outfit = /datum/outfit/job/assistant

/obj/effect/mob_spawn/corpse/human/assistant/beesease_infection/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/beesease)

/obj/effect/mob_spawn/corpse/human/assistant/brainrot_infection/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/brainrot)

/obj/effect/mob_spawn/corpse/human/assistant/spanishflu_infection/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/fluspanish)
