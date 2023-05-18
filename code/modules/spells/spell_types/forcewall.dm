/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through."
	school = "transmutation"
	charge_max = 100
	clothes_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = INVOCATION_SHOUT
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	range = -1
	include_user = TRUE
	cooldown_min = 50 //12 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user), null, user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST), null, user)
		new wall_type(get_step(user, WEST), null, user)
	else
		new wall_type(get_step(user, NORTH), null, user)
		new wall_type(get_step(user, SOUTH), null, user)


/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, ntimeleft, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == wizard)
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.anti_magic_check(major = FALSE))
			return TRUE
