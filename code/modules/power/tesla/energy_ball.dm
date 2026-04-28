//Zap constants, speeds up targeting
#define BIKE (COIL + 1)
#define COIL (ROD + 1)
#define ROD (RIDE + 1)
#define RIDE (LIVING + 1)
#define LIVING (MACHINERY + 1)
#define MACHINERY (BLOB + 1)
#define BLOB (STRUCTURE + 1)
#define STRUCTURE (1)

#define TESLA_DEFAULT_ENERGY 1738260
#define TESLA_MINI_ENERGY 869130
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
	zmm_flags = ZMM_WIDE_LOAD
	light_range = 6
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	dissipate = TRUE //Do we lose energy over time?
	dissipate_delay = 5
	time_since_last_dissipiation = 0
	dissipate_strength = 1

	var/target
	var/list/orbiting_balls = list()
	var/produced_power
	var/energy_to_raise = 32
	var/energy_to_lower = -20

CREATION_TEST_IGNORE_SUBTYPES(/obj/anomaly/energy_ball)

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

	playsound(src, 'sound/magic/lightningbolt.ogg', 100, 1, extrarange = 30)

	pixel_x = 0
	pixel_y = 0

	//Main one can zap
	//Tesla only zaps if the tick usage isn't over the limit.
	if(!TICK_CHECK)
		tesla_zap(src, 7, TESLA_DEFAULT_ENERGY, zap_flags = ZAP_TESLA_LARGE_FLAGS)
	else
		//Weaker, less intensive zap
		tesla_zap(src, 4, TESLA_DEFAULT_ENERGY, zap_flags = ZAP_TESLA_SMALL_FLAGS)
		pixel_x = -32
		pixel_y = -32
		return

	pixel_x = -32
	pixel_y = -32
	for(var/ball in orbiting_balls)
		if(TICK_CHECK)
			return
		var/range = rand(1, clamp(length(orbiting_balls), 3, 7))
		// Miniballs don't explode.
		tesla_zap(ball, range, TESLA_MINI_ENERGY / 7 * range, zap_flags = ZAP_TESLA_SMALL_FLAGS)

/obj/anomaly/energy_ball/examine(mob/user)
	. = ..()
	if(orbiting_balls.len)
		. += "There are [orbiting_balls.len] mini-balls orbiting it."


/obj/anomaly/energy_ball/proc/move_the_basket_ball(move_amount)
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
	if(!COOLDOWN_FINISHED(src, dissipation_cooldown))
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
	var/list/icon_dimensions = get_icon_dimensions(icon)

	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * rand(40, 80) * 0.01
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
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a shockingly dumb idea."))
	var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in jedi.internal_organs
	jedi.ghostize(jedi)
	if(rip_u)
		qdel(rip_u)
	jedi.investigate_log("had [jedi.p_their()] brain dusted by touching [src] with telekinesis.", INVESTIGATE_DEATHS)
	jedi.death()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/anomaly/energy_ball/proc/dust_mobs(atom/target_atom)
	if(!iscarbon(target_atom))
		return

	var/mob/living/carbon/carbon_target = target_atom
	if(carbon_target.incorporeal_move || HAS_TRAIT(carbon_target, TRAIT_GODMODE))
		return

	for(var/obj/machinery/power/energy_accumulator/grounding_rod/rod in orange(2, src))
		if(rod.anchored)
			return

	carbon_target.investigate_log("has been dusted by an energy ball.", INVESTIGATE_DEATHS)
	carbon_target.dust()

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

/proc/tesla_zap(atom/source, zap_range = 3, power, cutoff = 4e5, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list())
	if(QDELETED(source))
		return
	if(!(zap_flags & ZAP_ALLOW_DUPLICATES))
		LAZYSET(shocked_targets, source, TRUE) //I don't want no null refs in my list yeah?
	. = source.dir
	if(power < cutoff)
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
		/obj/structure/disposalpipe = FALSE,
		/obj/structure/disposaloutlet = FALSE,
		/obj/machinery/disposal/deliveryChute = FALSE,
		/obj/structure/sign = FALSE,
		/obj/structure/lattice = FALSE,
		/obj/structure/grille = FALSE,
		/obj/structure/frame/machine = FALSE,
		/obj/machinery/the_singularitygen/tesla = FALSE,
		/obj/structure/particle_accelerator = FALSE,
	))

	//Ok so we are making an assumption here. We assume that view() still calculates from the center out.
	//This means that if we find an object we can assume it is the closest one of its type. This is somewhat of a speed increase.
	//This also means we have no need to track distance, as the doview() proc does it all for us.

	//Darkness fucks oview up hard. I've tried dview() but it doesn't seem to work
	//I hate existence
	for(var/atom/A in typecache_filter_list(oview(zap_range+2, source), things_to_shock))
		if(!(zap_flags & ZAP_ALLOW_DUPLICATES) && LAZYACCESS(shocked_targets, A))
			continue
		// NOTE: these type checks are safe because CURRENTLY the range family of procs returns turfs in least to greatest distance order
		// This is unspecified behavior tho, so if it ever starts acting up just remove these optimizations and include a distance check
		if(closest_type >= BIKE)
			break

		else if(istype(A, /obj/vehicle/ridden/bicycle))//God's not on our side cause he hates idiots.
			var/obj/vehicle/ridden/bicycle/B = A
			if(!HAS_TRAIT(B, TRAIT_BEING_SHOCKED) && B.can_buckle)//Gee goof thanks for the boolean
				//we use both of these to save on istype and typecasting overhead later on
				//while still allowing common code to run before hand
				closest_type = BIKE
				closest_atom = B

		else if(closest_type >= COIL)
			continue //no need checking these other things

		else if(istype(A, /obj/machinery/power/energy_accumulator/tesla_coil))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = COIL
				closest_atom = A

		else if(closest_type >= ROD)
			continue

		else if(istype(A, /obj/machinery/power/energy_accumulator/grounding_rod))
			closest_type = ROD
			closest_atom = A

		else if(closest_type >= RIDE)
			continue

		else if(istype(A,/obj/vehicle/ridden))
			var/obj/vehicle/ridden/R = A
			if(R.can_buckle && !HAS_TRAIT(R, TRAIT_BEING_SHOCKED))
				closest_type = RIDE
				closest_atom = A

		else if(closest_type >= LIVING)
			continue

		else if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD && !HAS_TRAIT(L, TRAIT_TESLA_SHOCKIMMUNE) && !HAS_TRAIT(L, TRAIT_BEING_SHOCKED))
				closest_type = LIVING
				closest_atom = A

		else if(closest_type >= MACHINERY)
			continue

		else if(ismachinery(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = MACHINERY
				closest_atom = A

		else if(closest_type >= BLOB)
			continue

		else if(istype(A, /obj/structure/blob))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
				closest_type = BLOB
				closest_atom = A

		else if(closest_type >= STRUCTURE)
			continue

		else if(isstructure(A))
			if(!HAS_TRAIT(A, TRAIT_BEING_SHOCKED))
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

	var/next_range = 2
	if(closest_type == COIL)
		next_range = 5

	if(closest_type == LIVING)
		var/mob/living/closest_mob = closest_atom
		ADD_TRAIT(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
		addtimer(TRAIT_CALLBACK_REMOVE(closest_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
		var/shock_damage = (zap_flags & ZAP_MOB_DAMAGE) ? (min(round(power / 600), 90) + rand(-5, 5)) : 0
		closest_mob.electrocute_act(shock_damage, source, 1, SHOCK_TESLA | ((zap_flags & ZAP_MOB_STUN) ? NONE : SHOCK_NOSTUN))
		if(issilicon(closest_mob))
			var/mob/living/silicon/S = closest_mob
			if((zap_flags & ZAP_MOB_STUN) && (zap_flags & ZAP_MOB_DAMAGE))
				S.emp_act(EMP_LIGHT)
			next_range = 7 // metallic folks bounce it further
		else
			next_range = 5
		power /= 1.5

	else
		power = closest_atom.zap_act(power, zap_flags)

	if(prob(20))//I know I know
		var/list/shocked_copy = shocked_targets.Copy()
		tesla_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_copy)
		tesla_zap(source = closest_atom, zap_range = next_range, power = power * 0.5, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)
		shocked_targets += shocked_copy
	else
		tesla_zap(source = closest_atom, zap_range = next_range, power = power, cutoff = cutoff, zap_flags = zap_flags, shocked_targets = shocked_targets)

#undef BIKE
#undef COIL
#undef ROD
#undef RIDE
#undef LIVING
#undef MACHINERY
#undef BLOB
#undef STRUCTURE

#undef TESLA_DEFAULT_ENERGY
#undef TESLA_MINI_ENERGY
#undef TESLA_MAX_BALLS
