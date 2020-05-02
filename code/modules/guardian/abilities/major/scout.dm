/datum/guardian_ability/major/scout
	name = "Scout"
	desc = "The guardian can turn near-invisible and invincible and scout the station, although it cannot attack anything."
	cost = 1
	has_mode = TRUE
	recall_mode = TRUE
	mode_on_msg = "<span class='danger'><B>You switch to scout mode.</span></B>"
	mode_off_msg = "<span class='danger'><B>You switch to combat mode.</span></B>"

/datum/guardian_ability/major/scout/Mode()
	if(mode)
		guardian.ranged = 0
		guardian.melee_damage_lower = 0
		guardian.melee_damage_upper = 0
		guardian.obj_damage = 0
		guardian.environment_smash = ENVIRONMENT_SMASH_NONE
		guardian.alpha = 45
		guardian.range = 255
		guardian.do_the_cool_invisible_thing = FALSE
	else
		guardian.ranged = initial(guardian.ranged)
		guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
		guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
		guardian.obj_damage = initial(guardian.obj_damage)
		guardian.environment_smash = initial(guardian.environment_smash)
		guardian.alpha = 255
		guardian.range = initial(guardian.range)
		guardian.do_the_cool_invisible_thing = initial(guardian.do_the_cool_invisible_thing)
		guardian.stats.Apply(guardian)

/datum/guardian_ability/major/scout/Manifest()
	if(mode)
		guardian.incorporeal_move = INCORPOREAL_MOVE_BASIC

/datum/guardian_ability/major/scout/Recall()
	guardian.incorporeal_move = FALSE
