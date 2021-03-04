/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through."
	school = "transmutation"
	charge_max = 100
	clothes_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	range = -1
	include_user = TRUE
	cooldown_min = 50 //12 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user), summoner = user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST), summoner = user)
		new wall_type(get_step(user, WEST), summoner = user)
	else
		new wall_type(get_step(user, NORTH), summoner = user)
		new wall_type(get_step(user, SOUTH), summoner = user)


/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, ntimeleft, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check(major = FALSE))
			return TRUE
	return FALSE
