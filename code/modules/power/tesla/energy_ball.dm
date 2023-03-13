#define TESLA_DEFAULT_POWER 1738260
#define TESLA_MINI_POWER 869130
#define TESLA_MAX_BALLS 10

/obj/anomaly/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1
	var/target
	var/list/orbiting_balls = list()
	dissipate = TRUE //Do we lose energy over time?
	dissipate_delay = 5
	time_since_last_dissipiation = 0
	dissipate_strength = 1
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20

/obj/anomaly/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	. = ..()
	energy = starting_energy
	START_PROCESSING(SSobj, src)
	var/turf/spawned_turf = get_turf(src)
	message_admins("A tesla has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
	investigate_log("(tesla) was created at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINES)

/obj/anomaly/energy_ball/ex_act(severity, target)
	return

/obj/anomaly/energy_ball/Destroy()
	QDEL_LIST(orbiting_balls)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/anomaly/energy_ball/process(delta_time)
	handle_energy(delta_time)

	move_the_basket_ball(4 + orbiting_balls.len * 1.5)

	playsound(src.loc, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

	pixel_x = 0
	pixel_y = 0

	//Main one can zap
	//Tesla only zaps if the tick usage isn't over the limit.
	if(!TICK_CHECK)
		tesla_zap(src, 7, TESLA_DEFAULT_POWER, TESLA_ENERGY_PRIMARY_BALL_FLAGS)
	else
		//Weaker, less intensive zap
		tesla_zap(src, 4, TESLA_DEFAULT_POWER, TESLA_ENERGY_MINI_BALL_FLAGS)
		pixel_x = -32
		pixel_y = -32
		return

	pixel_x = -32
	pixel_y = -32
	for (var/ball in orbiting_balls)
		if(TICK_CHECK)
			return
		var/range = rand(1, CLAMP(orbiting_balls.len, 3, 7))
		//Miniballs don't explode.
		tesla_zap(ball, range, TESLA_MINI_POWER/7*range, TESLA_ENERGY_MINI_BALL_FLAGS)

/obj/anomaly/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		. += "There are [orbiting_balls.len] mini-balls orbiting it."


/obj/anomaly/energy_ball/proc/move_the_basket_ball(var/move_amount)
	//we face the last thing we zapped, so this lets us favor that direction a bit
	var/move_bias = pick(GLOB.alldirs)
	for(var/i in 0 to move_amount)
		var/move_dir = pick(GLOB.alldirs + move_bias) //ensures large-ball teslas don't just sit around
		if(target && prob(10))
			move_dir = get_dir(src,target)
		var/turf/T = get_step(src, move_dir)
		if(can_move(T))
			forceMove(T)
			setDir(move_dir)
			for(var/mob/living/carbon/C in loc)
				dust_mobs(C)


/obj/anomaly/energy_ball/proc/handle_energy(delta_time)
	if(!COOLDOWN_FINISHED(src, RESTART_DISSIPATE))
		return
	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 100, 1, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && orbiting_balls.len)
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

	else if(orbiting_balls.len)
		dissipate(delta_time) //sing code has a much better system.

/obj/anomaly/energy_ball/proc/new_mini_ball()
	if(!loc)
		return
	if(orbiting_balls.len >= TESLA_MAX_BALLS)
		return
	var/obj/effect/energy_ball/EB = new(loc, 0, TRUE)

	EB.transform *= rand(30, 70) * 0.01
	var/icon/I = icon(icon,icon_state,dir)

	var/orbitsize = (I.Width() + I.Height()) * rand(40, 80) * 0.01
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	EB.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

/obj/anomaly/energy_ball/proc/can_move(turf/to_move)
	if (!to_move)
		return FALSE

	for (var/_thing in to_move)
		var/atom/thing = _thing
		if (SEND_SIGNAL(thing, COMSIG_ATOM_SINGULARITY_TRY_MOVE) & SINGULARITY_TRY_MOVE_BLOCK)
			return FALSE
	return TRUE

/obj/anomaly/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/anomaly/energy_ball/Bumped(atom/movable/AM)
	dust_mobs(AM)

/obj/anomaly/energy_ball/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(C, "<span class='userdanger'>That was a shockingly dumb idea.</span>")
		var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in C.internal_organs
		C.ghostize(0)
		qdel(rip_u)
		C.death()

/obj/anomaly/energy_ball/proc/dust_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incorporeal_move || L.status_flags & GODMODE)
			return
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/grounding_rod/GR in orange(2, src))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.dust()

//Less intensive energy ball for the orbiting ones.
/obj/effect/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32

/obj/effect/energy_ball/Destroy(force)
	if(orbiting && istype(orbiting.parent, /obj/anomaly/energy_ball))
		var/obj/anomaly/energy_ball/EB = orbiting.parent
		EB.orbiting_balls -= src
		EB.dissipate_strength = EB.orbiting_balls.len
	. = ..()

/obj/effect/energy_ball/orbit(obj/anomaly/energy_ball/target)
	if (istype(target))
		target.orbiting_balls += src
		target.dissipate_strength = target.orbiting_balls.len
	. = ..()

/obj/effect/energy_ball/stop_orbit()
	. = ..()
	//Qdel handles removing from the parent ball list.
	if(!QDELETED(src))
		qdel(src)

/proc/tesla_zap(atom/source, zap_range = 3, power, tesla_flags = TESLA_DEFAULT_FLAGS, list/shocked_targets)
	. = source.dir
	if(power < 1000)
		return

	var/closest_dist = 0
	var/atom/closest_atom
	var/priority = 7 //Initial Value is always lowest priority + 1
	var/static/things_to_shock = typecacheof(list(/obj/machinery, /mob/living, /obj/structure))
	var/static/blacklisted_tesla_types = typecacheof(list(/obj/machinery/atmospherics,
										/obj/machinery/power/emitter,
										/obj/machinery/field/generator,
										/mob/living/simple_animal,
										/obj/machinery/particle_accelerator/control_box,
										/obj/structure/particle_accelerator/fuel_chamber,
										/obj/structure/particle_accelerator/particle_emitter/center,
										/obj/structure/particle_accelerator/particle_emitter/left,
										/obj/structure/particle_accelerator/particle_emitter/right,
										/obj/structure/particle_accelerator/power_box,
										/obj/structure/particle_accelerator/end_cap,
										/obj/machinery/field/containment,
										/obj/structure/disposalpipe,
										/obj/structure/disposaloutlet,
										/obj/machinery/disposal/deliveryChute,
										/obj/machinery/camera,
										/obj/structure/sign,
										/obj/machinery/gateway,
										/obj/structure/lattice,
										/obj/structure/grille,
										/obj/machinery/the_singularitygen/tesla,
										/obj/structure/frame/machine))

	for(var/atom/A as() in oview(zap_range+2, source))
		//typecache_filter_multi_list_exclusion has been inlined to minimize lag.
		if(!things_to_shock[A.type] || blacklisted_tesla_types[A.type] || (!(tesla_flags & TESLA_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A)))
			continue
		if(istype(A, /obj/machinery/power/tesla_coil))
			var/obj/o = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 1)) && !(o.obj_flags & BEING_SHOCKED))
				closest_atom = A
				closest_dist = dist
				priority = 1
			continue
		else if(priority == 1) //i hate to do it like that but my original plan to handle this didn't work so back we go to additional else if
			continue
		else if(priority >= 2 && istype(A, /obj/machinery/power/grounding_rod))
			var/obj/o = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 2)) && !(o.obj_flags & BEING_SHOCKED))
				closest_atom = A
				closest_dist = dist
				priority = 2
			continue
		else if(priority <= 2)
			continue
		else if(priority >= 3 && isliving(A))
			var/mob/living/L = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 3)) && L.stat != DEAD && !(L.flags_1 & TESLA_IGNORE_1))
				closest_atom = A
				closest_dist = dist
				priority = 3
			continue
		else if(priority <= 3)
			continue
		else if(priority >= 4 && istype(A, /obj/machinery))
			var/obj/o = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 4)) && !(o.obj_flags & BEING_SHOCKED))
				closest_atom = A
				closest_dist = dist
				priority = 4
			continue
		else if(priority <= 4)
			continue
		else if(priority >= 5 && istype(A, /obj/structure/blob))
			var/obj/o = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 5)) && !(o.obj_flags & BEING_SHOCKED))
				closest_atom = A
				closest_dist = dist
				priority = 5
			continue
		else if(priority <= 5)
			continue
		else if(priority >= 6 && istype(A, /obj/structure))
			var/obj/o = A
			var/dist = get_dist(source, A)
			if(dist <= zap_range && (dist < closest_dist || !(priority == 6)) && !(o.obj_flags & BEING_SHOCKED))
				closest_atom = A
				closest_dist = dist
				priority = 6

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(closest_atom)
		//common stuff
		source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", time=5, maxdistance = INFINITY)
		if(!(tesla_flags & TESLA_ALLOW_DUPLICATES))
			LAZYSET(shocked_targets, closest_atom, TRUE)
		var/zapdir = get_dir(source, closest_atom)
		if(zapdir)
			. = zapdir

	//per type stuff:
		if(priority == 3)
			var/mob/living/m = closest_atom
			var/shock_damage = (tesla_flags & TESLA_MOB_DAMAGE)? (min(round(power/600), 90) + rand(-5, 5)) : 0
			m.electrocute_act(shock_damage, source, 1, tesla_shock = 1, stun = (tesla_flags & TESLA_MOB_STUN))
			if(issilicon(m))
				if((tesla_flags & TESLA_MOB_STUN) && (tesla_flags & TESLA_MOB_DAMAGE))
					m.emp_act(EMP_LIGHT)
				tesla_zap(m, 7, power / 1.5, tesla_flags, shocked_targets) // metallic folks bounce it further
			else
				tesla_zap(m, 5, power / 1.5, tesla_flags, shocked_targets)
		else
			var/obj/o = closest_atom
			o.tesla_act(power, tesla_flags, shocked_targets)
#undef TESLA_MAX_BALLS
