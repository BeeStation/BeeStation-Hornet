/mob/living/simple_animal/hostile/retaliate/bat
	name = "Space Bat"
	desc = "A rare breed of bat which roosts in spaceships, probably not vampiric."
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	turns_per_move = 1
	response_help = "brushes aside"
	response_disarm = "flails at"
	response_harm = "hits"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_chance = 0
	maxHealth = 15
	health = 15
	spacewalk = TRUE
	see_in_dark = 10
	melee_damage = 6
	attacktext = "bites"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	pass_flags = PASSTABLE
	faction = list("hostile")
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	movement_type = FLYING
	speak_emote = list("squeaks")
	var/max_co2 = 0 //to be removed once metastation map no longer use those for Sgt Araneus
	var/min_oxy = 0
	var/max_tox = 0


	//Space bats need no air to fly in.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0


/mob/living/simple_animal/hostile/retaliate/bat/vampire
	desc = "A rare breed of bat which roosts in spaceships.\nLooks a little... bloody."
	speed = -1.5


/mob/living/simple_animal/hostile/retaliate/bat/sgt_araneus //Despite being a bat for... reasons, this is now a spider, and is one of the HoS' pets.
	name = "Sergeant Araneus"
	real_name = "Sergeant Araneus"
	desc = "A fierce companion of the Head of Security, this spider has been carefully trained by Nanotrasen specialists. Its beady, staring eyes send shivers down your spine."
	emote_hear = list("chitters")
	faction = list("spiders")
	icon_dead = "guard_dead"
	icon_gib = "guard_dead"
	icon_living = "guard"
	icon_state = "guard"
	maxHealth = 250
	health = 250
	max_co2 = 5
	max_tox = 2
	melee_damage = 15
	min_oxy = 5
	movement_type = GROUND
	response_help = "pets"
	turns_per_move = 10
