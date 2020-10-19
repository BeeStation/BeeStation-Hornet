/datum/guardian_ability
	var/name = "ERROR"
	var/desc = "You should not see this!"
	var/cost = 0
	var/ui_icon
	var/spell_type
	var/obj/effect/proc_holder/spell/spell
	var/datum/guardian_stats/master_stats
	var/mob/living/simple_animal/hostile/guardian/guardian
	var/arrow_weight = 1

// note -- all guardian abilities should be able to have Apply() ran multiple times with no problems.
/datum/guardian_ability/proc/Apply()
	if(spell_type && !spell)
		spell = new spell_type
	if(spell && !(spell in guardian.mob_spell_list))
		guardian.AddSpell(spell)

/datum/guardian_ability/proc/Remove()
	if(spell)
		guardian.RemoveSpell(spell)

/datum/guardian_ability/proc/CanBuy()
	return TRUE

/datum/guardian_ability/proc/Stat()

// major abilities have a mode usually
/datum/guardian_ability/major
	var/has_mode = FALSE
	var/mode = FALSE
	var/recall_mode = FALSE
	var/mode_on_msg = ""
	var/mode_off_msg = ""

/datum/guardian_ability/major/proc/Attack(atom/target)

/datum/guardian_ability/major/proc/RangedAttack(atom/target)

/datum/guardian_ability/major/proc/AfterAttack(atom/target)

/datum/guardian_ability/major/proc/Manifest()

/datum/guardian_ability/major/proc/Recall()

/datum/guardian_ability/major/proc/Mode()

/datum/guardian_ability/major/proc/Health(amount)

/datum/guardian_ability/major/proc/AltClickOn(atom/A)

/datum/guardian_ability/major/proc/CtrlClickOn(atom/A)

/datum/guardian_ability/major/proc/Berserk()

/datum/guardian_ability/major/special

// minor ability stub
/datum/guardian_ability/minor
