//Gravity
/mob/living/simple_animal/hostile/guardian/gravity
	melee_damage_lower = 5
	melee_damage_upper = 5
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	range = 13
	playstyle_string = "<span class='holoparasite'>As an <b>Gravity</b> type, you have moderate close combat abilities, pin targets to the ground on attack and are capable of creating gravitational anomalies via alt clicking yourself (THIS AFFECTS YOUR HOST TOO).</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Scientist, master of gravitational death.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Gravity modules active. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! Caught one! It's an Gravity carp! Succ goes the fishy.</span>"
	var/gravity_well_CD = 0

/mob/living/simple_animal/hostile/guardian/gravity/Stat()
	..()
	if(statpanel("Status"))
		if(gravity_well_CD >= world.time)
			stat(null, "Gravity Anomaly Cooldown Remaining: [DisplayTimeText(gravity_well_CD - world.time)]")

/mob/living/simple_animal/hostile/guardian/gravity/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/M = target
		if(!M.anchored && M != summoner && !hasmatchingsummoner(M))
			new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
			for(var/mob/living/L in range(1, M))
				if(hasmatchingsummoner(L)) //if the summoner matches don't hurt them
					continue
				if(L != src && L != summoner)
					L.apply_damage(70, STAMINA)
					L.apply_damage(2, BRUTE)

/mob/living/simple_animal/hostile/guardian/gravity/AltClick()
	if(loc == summoner)
		to_chat(src, "<span class='danger'><B>You must be manifested to create gravitational anomalies!</B></span>")
		return
	if(gravity_well_CD <= world.time && !stat)
		var/obj/guardian_gravity/B = new /obj/guardian_gravity(get_turf(src.loc))
		to_chat(src, "<span class='danger'><B>Success! Gravitational Anomaly placed!</B></span>")
		gravity_well_CD = world.time + 200
		B.spawner = src
	else
		to_chat(src, "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between Gravitational Anomalies.</B></span>")

/obj/guardian_gravity
	name = "Gravity Well"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/simple_animal/hostile/guardian/spawner
	var/turf/T
	var/list/thrown_items = list()

/obj/guardian_gravity/proc/disguise(obj/A)
	A.forceMove(src)
	stored_obj = A
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/guardian_gravity/Initialize()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, 4))
		if(A.anchored || thrown_items[A])
			continue
		if(ismob(A))
			var/mob/M = A
			if(M.mob_negates_gravity())
				continue
		A.safe_throw_at(get_edge_target_turf(A, pick(GLOB.cardinals)), 2+1, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
		thrown_items[A] = A
	for(var/turf/Z in range(T,3))
		new /obj/effect/temp_visual/gravpush(Z)

/obj/guardian_gravity/proc/create(obj/A)
	addtimer(CALLBACK(src, .proc/disable), 600)

/obj/guardian_gravity/proc/disable()
	qdel(src)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/guardian_gravity/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		to_chat(user, "<span class='holoparasite'>It glows with a strange, gravitational <font color=\"[spawner.namedatum.colour]\">distortion</font>!</span>")
