/datum/action/spell/pointed/projectile/arcane_prison
	name = "Arcane Prison"
	desc = "Trap your target in a sphere of arcane energy for a short while. They will be unable to move or act while inside, but will also be unharmed."
	button_icon_state = "prison_orb0"

	sound = 'sound/magic/forcewall.ogg'
	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS

	invocation = "KA SHAPON!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	base_icon_state = "prison_orb"
	active_msg = "You prepare to cast an arcane prison!"
	deactive_msg = "They will remain free... for now."
	cast_range = 50
	projectile_type = /obj/projectile/magic/prison_orb

/datum/action/spell/pointed/projectile/arcane_prison/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.range = (50)
