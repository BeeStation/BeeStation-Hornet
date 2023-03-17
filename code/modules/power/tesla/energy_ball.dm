#define TESLA_DEFAULT_POWER 13826
#define TESLA_MINI_POWER 6913
#define TESLA_MAX_BALLS 10


//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

/// The Tesla engine
/obj/energy_ball
	name = "energy ball"
	desc = "An energy ball."
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_system = MOVABLE_LIGHT
	light_range = 10
	light_power = 10
	light_color = "#5e5edd"
	light_on = FALSE
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	var/energy
	var/target
	var/list/orbiting_balls = list()
	var/miniball = FALSE

	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20
	var/list/shocked_things = list()

/obj/energy_ball/Initialize(mapload, starting_energy = 50, is_miniball = FALSE)
	. = ..()
	energy = starting_energy
	miniball = is_miniball
	START_PROCESSING(SSobj, src)

	if (!is_miniball)
		set_light_on(TRUE)

		var/turf/spawned_turf = get_turf(src)
		message_admins("A tesla has been created at [ADMIN_VERBOSEJMP(spawned_turf)].")
		investigate_log("was created at [AREACOORD(spawned_turf)].", INVESTIGATE_ENGINE)

/obj/energy_ball/Destroy()
	if(orbiting && istype(orbiting.parent, /obj/energy_ball))
		var/obj/energy_ball/parent_energy_ball = orbiting.parent
		parent_energy_ball.orbiting_balls -= src

	QDEL_LIST(orbiting_balls)
	STOP_PROCESSING(SSobj, src)

	return ..()

/obj/energy_ball/ex_act(severity, target)
	return

/obj/energy_ball/process(delta_time)
	if(orbiting)
		energy = 0 // ensure we dont have miniballs of miniballs
	else
		handle_energy(delta_time)

		if(last_move <= world.time + 6 SECONDS)
			last_move = world.time
			move(4 + (orbiting_balls.len * 1.5 ))

			playsound(src.loc, 'sound/magic/lightningbolt.ogg', 70, TRUE, extrarange = 30)

			pixel_x = 0
			pixel_y = 0
			shocked_things.Cut(1, shocked_things.len / 1.3)
			var/list/shocking_info = list()

			//Main one can zap
			//Tesla only zaps if the tick usage isn't over the limit.
			if(!TICK_CHECK)
				tesla_zap(src, 3, TESLA_DEFAULT_POWER, shocked_targets = shocking_info)
			else
				tesla_zap(src, 3, TESLA_DEFAULT_POWER, ZAP_DEFAULT_FLAGS)
				pixel_x = -32
				pixel_y = -32
				return

			pixel_x = -32
			pixel_y = -32
			for (var/ball in orbiting_balls)
				var/range = rand(1, CLAMP(orbiting_balls.len, 2, 7))
				var/list/temp_shock = list()
				//We zap off the main ball instead of ourselves to make things looks proper
				tesla_zap(src, range, TESLA_MINI_POWER/7*range, shocked_targets = temp_shock)
				shocking_info += temp_shock
			shocked_things += shocking_info

/obj/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		. += "There are [orbiting_balls.len] mini-balls orbiting it."


/obj/energy_ball/proc/move(move_amount)
	var/list/dirs = GLOB.alldirs.Copy()
	if(shocked_things.len)
		for (var/i in 1 to 30)
			var/atom/real_thing = pick(shocked_things)
			dirs += get_dir(src, real_thing) //Carry some momentum yeah? Just a bit tho
	for (var/i in 0 to move_amount)
		var/move_dir = pick(dirs) //ensures teslas don't just sit around
		if (target && prob(1)) //Make the energy_ball movement more erratic by lowering the prob
			move_dir = get_dir(src, target)
		var/turf/turf_to_move = get_step(src, move_dir)
		if (can_move(turf_to_move))
			forceMove(turf_to_move)
			setDir(move_dir)
			for (var/mob/living/carbon/mob_to_dust in loc)
				dust_mobs(mob_to_dust)

/obj/energy_ball/proc/can_move(turf/to_move)
	if (!to_move)
		return FALSE

	for (var/_thing in to_move)
		var/atom/thing = _thing
		if (SEND_SIGNAL(thing, COMSIG_ATOM_SINGULARITY_TRY_MOVE) & SINGULARITY_TRY_MOVE_BLOCK)
			return FALSE

	return TRUE

/obj/energy_ball/proc/handle_energy(delta_time)

	if(energy >= energy_to_raise)
		energy_to_lower = energy_to_raise - 20
		energy_to_raise = energy_to_raise * 1.25

		playsound(src.loc, 'sound/magic/lightning_chargeup.ogg', 70, TRUE, extrarange = 30)
		addtimer(CALLBACK(src, PROC_REF(new_mini_ball)), 100)

	else if(energy < energy_to_lower && orbiting_balls.len)
		energy_to_raise = energy_to_raise / 1.25
		energy_to_lower = (energy_to_raise / 1.25) - 20

		var/Orchiectomy_target = pick(orbiting_balls)
		qdel(Orchiectomy_target)

/obj/energy_ball/proc/new_mini_ball()
	if(!loc)
		return
	if(orbiting_balls.len >= TESLA_MAX_BALLS)
		return

	var/obj/energy_ball/miniball = new /obj/energy_ball(
		loc,
		/* starting_energy = */ 10,
		/* is_miniball = */ TRUE
	)

	miniball.transform *= pick(0.3, 0.4, 0.5, 0.6, 0.7)
	var/icon/I = icon(icon, icon_state,dir)

	var/orbitsize = (I.Width() + I.Height()) * pick(0.4, 0.5, 0.6, 0.7, 0.8)
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	miniball.orbit(src, orbitsize, pick(FALSE, TRUE), rand(10, 25), pick(3, 4, 5, 6, 36))

	//Grab_Moths(get_turf(miniball), 10)
	//Hehe, if only...

/obj/energy_ball/Bump(atom/A)
	dust_mobs(A)

/obj/energy_ball/Bumped(atom/movable/AM)
	dust_mobs(AM)

/obj/energy_ball/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(C, "<span class='userdanger'>That was a shockingly dumb idea.</span>")
		var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in C.internal_organs
		C.ghostize(0)
		qdel(rip_u)
		C.death()
		return

/obj/energy_ball/orbit(obj/energy_ball/target)
	if (istype(target))
		target.orbiting_balls += src
	. = ..()

/obj/energy_ball/stop_orbit()
	if (orbiting && istype(orbiting.parent, /obj/energy_ball))
		var/obj/energy_ball/orbitingball = orbiting.parent
		orbitingball.orbiting_balls -= src
	. = ..()
	if (!QDELETED(src))
		qdel(src)

/obj/energy_ball/proc/dust_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.incorporeal_move || L.status_flags & GODMODE)
			return
	if(!iscarbon(A))
		return
	for(var/obj/machinery/power/energy_accumulator/grounding_rod/GR in orange(2, src))
		if(GR.anchored)
			return
	var/mob/living/carbon/C = A
	C.dust()

/proc/tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS | ZAP_GENERATES_POWER | ZAP_MACHINE_EXPLOSIVE, list/shocked_targets = list())
	if(QDELETED(source))
		return
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) //I don't want no null refs in my list yeah?
	. = source.dir
	if(power < 1000)
		return

	/*
	THIS IS SO FUCKING UGLY AND I HATE IT, but I can't make it nice without making it slower, check*N rather then n. So we're stuck with it.
	*/
	var/atom/closest_atom
	var/closest_type = 0
	var/static/list/things_to_shock = zebra_typecacheof(list(
		// Things that we want to shock.
		/obj/machinery = TRUE,
		/mob/living = TRUE,
		/obj/structure = TRUE,
		/obj/vehicle/ridden = TRUE,

		// Things that we don't want to shock.
		/obj/machinery/atmospherics = FALSE,
		/obj/machinery/portable_atmospherics = FALSE,
		/obj/machinery/power/emitter = FALSE,
		/obj/machinery/field/generator = FALSE,
		/obj/machinery/field/containment = FALSE,
		/obj/machinery/camera = FALSE,
		/obj/machinery/gateway = FALSE,
		/mob/living/simple_animal = FALSE,
		/obj/structure/disposalpipe = FALSE,
		/obj/structure/disposaloutlet = FALSE,
		/obj/machinery/disposal/deliveryChute = FALSE,
		/obj/structure/sign = FALSE,
		/obj/structure/lattice = FALSE,
		/obj/structure/grille = FALSE,
		/obj/structure/frame/machine = FALSE,
		/obj/machinery/particle_accelerator = FALSE,
	))

	//Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	//This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	//This also means we have no need to track distance, as the doview() proc does it all for us.

	//Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	//I hate existance
	for(var/a in typecache_filter_list(oview(zap_range+2, source), things_to_shock))
		var/atom/A = a
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		if(closest_type >= BIKE)
			break

		else if(istype(A, /obj/vehicle/ridden/bicycle))//God's not on our side cause he hates idiots.
			var/obj/vehicle/ridden/bicycle/B = A
			if(!(B.obj_flags & BEING_SHOCKED) && B.can_buckle)//Gee goof thanks for the boolean
				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_type = BIKE
				closest_atom = B

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/energy_accumulator/tesla_coil))
			var/obj/machinery/power/energy_accumulator/tesla_coil/C = A
			if(!(C.obj_flags & BEING_SHOCKED))
				closest_type = COIL
				closest_atom = C

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/energy_accumulator/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A,/obj/vehicle/ridden))
			var/obj/vehicle/ridden/R = A
			if(R.can_buckle && !(R.obj_flags & BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !(HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE)) && !(L.flags_1 & SHOCKED_1))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			var/obj/machinery/M = A
			if(!(M.obj_flags & BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			var/obj/structure/blob/B = A
			if(!(B.obj_flags & BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			var/obj/structure/S = A
			if(!(S.obj_flags & BEING_SHOCKED))
				closest_type = STRUCTURE
				closest_atom = A

	//Alright, we've done our loop, now lets see if was anything interesting in range
	if(!closest_atom)
		return
	//common stuff
	source.Beam(closest_atom, icon_state="lightning[rand(1,12)]", time = 5)
	var/zapdir = get_dir(source, closest_atom)
	if(zapdir)
		. = zapdir

	var/next_range = 3
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		closest_mob.set_shocked()
		addtimer(CALLBACK(closest_mob, /mob/living/proc/reset_shocked), 10)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power/600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((zap_flags & ZAP_MOB_STUN) && (zap_flags & ZAP_MOB_DAMAGE))
				S.emp_act(EMP_LIGHT)
			next_range = 5 // metallic folks bounce it further
		else
			next_range = 3
		power /= 1.5

	else
		power = closest_atom.zap_act(power, zap_flags)
	if(prob(20))//I know I know
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_zap(closest_atom, next_range, power * 0.1, zap_flags, shocked_copy)//Normally I'd copy here so grounding rods work properly, but it fucks with movement
		tesla_zap(closest_atom, next_range, power * 0.1, zap_flags, shocked_targets)
		shocked_targets += shocked_copy
	else
		tesla_zap(closest_atom, next_range, power, zap_flags, shocked_targets)

#undef BIKE
#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE
