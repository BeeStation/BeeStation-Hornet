/datum/action/spell/pointed/projectile/death
	name = "Instant Death"
	desc = "This spell will forcibly separate body and soul"
	button_icon_state = "death0"

	sound = 'sound/magic/wandodeath.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 90 SECONDS
	cooldown_reduction_per_rank = 15 SECONDS // 40s cd at max rank

	invocation = "ADABA KEVRA!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_WIZARD_GARB

	base_icon_state = "death"
	active_msg = "You prepare to cast a bolt of death!"
	deactive_msg = "You release your grip on the magic of death for now."
	cast_range = 8
	projectile_type = /obj/projectile/magic/death

/datum/action/spell/pointed/projectile/fireball/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.range = (6 + 2 * spell_level)
