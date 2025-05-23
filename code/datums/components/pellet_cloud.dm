/*
	* This component is used when you want to create a bunch of shrapnel or projectiles (say, shrapnel from a fragmentation grenade, or buckshot from a shotgun) from a central point,
	* without necessarily printing a separate message for every single impact. This component should be instantiated right when you need it (like the moment of firing), then activated
	* by signal.
	*
	* Pellet cloud currently works on two classes of sources: directed (ammo casings), and circular (grenades, landmines).
	*	-Directed: This means you're shooting multiple pellets, like buckshot. If an ammo casing is defined as having multiple pellets, it will automatically create a pellet cloud
	*		and call COMSIG_PELLET_CLOUD_INIT (see [/obj/item/ammo_casing/proc/fire_casing]). Thus, the only projectiles fired will be the ones fired here.
	*		The magnitude var controls how many pellets are created.
	*	-Circular: This results in a big spray of shrapnel flying all around the detonation point when the grenade fires COMSIG_GRENADE_PRIME or landmine triggers COMSIG_MINE_TRIGGERED.
	*		The magnitude var controls how big the detonation radius is (the bigger the magnitude, the more shrapnel is created). Grenades can be covered with bodies to reduce shrapnel output.
	*
	* Once all of the fired projectiles either hit a target or disappear due to ranging out/whatever else, we resolve the list of all the things we hit and print aggregate messages so we get
	* one "You're hit by 6 buckshot pellets" vs 6x "You're hit by the buckshot blah blah" messages.
	*
	* Note that this is how all guns handle shooting ammo casings with multiple pellets, in case such a thing comes up.
*/

/datum/component/pellet_cloud
	/// What's the projectile path of the shrapnel we're shooting?
	var/projectile_type

	/// How many shrapnel projectiles are we responsible for tracking? May be reduced for grenades if someone dives on top of it. Defined by ammo casing for casings, derived from magnitude otherwise
	var/num_pellets
	/// For grenades/landmines, how big is the radius of turfs we're targeting? Note this does not effect the projectiles range, only how many we generate
	var/radius = 4

	/// The list of pellets we're responsible for tracking, once these are all accounted for, we finalize.
	var/list/pellets = list()
	/// An associated list with the atom hit as the key and how many pellets they've eaten for the value, for printing aggregate messages
	var/list/targets_hit = list()
	/// For grenades, any /mob/living's the grenade is moved onto, see [/datum/component/pellet_cloud/proc/handle_martyrs()]
	var/list/bodies

	/// For grenades, tracking how many pellets are removed due to martyrs and how many pellets are added due to the last person to touch it being on top of it
	var/pellet_delta = 0
	/// how many pellets ranged out without hitting anything
	var/terminated
	/// how many pellets impacted something
	var/hits
	/// If the parent tried deleting and we're not done yet, we send it to nullspace then delete it after
	var/queued_delete = FALSE

	/// for if we're an ammo casing being fired
	var/mob/living/shooter


/datum/component/pellet_cloud/Initialize(projectile_type=/obj/item/shrapnel, magnitude=5)
	if(magnitude < 1)
		stack_trace("Invalid magnitude [magnitude] < 1 on pellet_cloud, parent: [parent]")
		magnitude = 1

	src.projectile_type = projectile_type

	if(isammocasing(parent))
		num_pellets = magnitude
	else if(isgrenade(parent) || islandmine(parent))
		radius = magnitude
	else
		radius = magnitude
		create_blast_pellets(null, null)

/datum/component/pellet_cloud/Destroy(force, silent)
	pellets = null
	targets_hit = null
	bodies = null
	return ..()

/datum/component/pellet_cloud/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, PROC_REF(nullspace_parent))
	if(isammocasing(parent))
		RegisterSignal(parent, COMSIG_PELLET_CLOUD_INIT, PROC_REF(create_casing_pellets))
	else if(isgrenade(parent))
		RegisterSignal(parent, COMSIG_GRENADE_ARMED, PROC_REF(grenade_armed))
		RegisterSignal(parent, COMSIG_GRENADE_PRIME, PROC_REF(create_blast_pellets))
	else if(islandmine(parent))
		RegisterSignal(parent, COMSIG_MINE_TRIGGERED, PROC_REF(create_blast_pellets))

/datum/component/pellet_cloud/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_PELLET_CLOUD_INIT, COMSIG_GRENADE_PRIME, COMSIG_GRENADE_ARMED, COMSIG_MOVABLE_MOVED, COMSIG_MINE_TRIGGERED, COMSIG_ITEM_DROPPED))

/**
  * create_casing_pellets() is for directed pellet clouds for ammo casings that have multiple pellets (buckshot and scatter lasers for instance)
  *
  * Honestly this is mostly just a rehash of [/obj/item/ammo_casing/proc/fire_casing()] for pellet counts > 1, except this lets us tamper with the pellets and hook onto them for tracking purposes.
  * The arguments really don't matter, this proc is triggered by COMSIG_PELLET_CLOUD_INIT which is only for this really, it's just a big mess of the state vars we need for doing the stuff over here.
  */
/datum/component/pellet_cloud/proc/create_casing_pellets(obj/item/ammo_casing/shell, atom/target, mob/living/user, fired_from, randomspread, spread, zone_override, params)
	SIGNAL_HANDLER

	shooter = user
	var/turf/targloc = get_turf(target)
	if(!zone_override)
		zone_override = shooter.get_combat_bodyzone(target)

	for(var/i in 1 to num_pellets)
		shell.ready_proj(target, user, SUPPRESSED_VERY, zone_override, fired_from)
		var/bullet_angle = spread
		if(randomspread)
			bullet_angle = round((rand() - 0.5) * spread)
		else //Smart spread
			bullet_angle = round((i / num_pellets - 0.5) * spread)

		RegisterSignal(shell.BB, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(pellet_hit))
		RegisterSignals(shell.BB, list(COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PARENT_QDELETING), PROC_REF(pellet_range))
		pellets += shell.BB
		var/turf/current_loc = get_turf(user)
		if(!istype(targloc) || !istype(current_loc))
			return
		INVOKE_ASYNC(shell, TYPE_PROC_REF(/obj/item/ammo_casing, throw_proj), target, targloc, shooter, params, bullet_angle)
		if(i != num_pellets)
			shell.newshot()

/**
  * create_blast_pellets() is for when we have a central point we want to shred the surroundings of with a ring of shrapnel, namely frag grenades and landmines.
  *
  * Note that grenades have extra handling for someone throwing themselves/being thrown on top of it, while landmines do not (obviously, it's a landmine!). See [/datum/component/pellet_cloud/proc/handle_martyrs()]
  */
/datum/component/pellet_cloud/proc/create_blast_pellets(obj/O, mob/living/lanced_by)
	SIGNAL_HANDLER

	var/atom/A = parent

	if(isgrenade(parent)) // handle_martyrs can reduce the radius and thus the number of pellets we produce if someone dives on top of a frag grenade
		INVOKE_ASYNC(src, PROC_REF(handle_martyrs), lanced_by) // note that we can modify radius in this proc

	if(radius < 1)
		return

	var/list/all_the_turfs_were_gonna_lacerate = RANGE_TURFS(radius, A) - RANGE_TURFS(radius-1, A)
	num_pellets = all_the_turfs_were_gonna_lacerate.len + pellet_delta

	for(var/T in all_the_turfs_were_gonna_lacerate)
		var/turf/shootat_turf = T
		INVOKE_ASYNC(src, PROC_REF(pew), shootat_turf)

/**
  * handle_martyrs() is used for grenades that shoot shrapnel to check if anyone threw themselves/were thrown on top of the grenade, thus absorbing a good chunk of the shrapnel
  *
  * Between the time the grenade is armed and the actual detonation, we set var/list/bodies to the list of mobs currently on the new tile, as if the grenade landed on top of them, tracking if any of them move off the tile and removing them from the "under" list
  * Once the grenade detonates, handle_martyrs() is called and gets all the new mobs on the tile, and add the ones not in var/list/bodies to var/list/martyrs
  * We then iterate through the martyrs and reduce the shrapnel magnitude for each mob on top of it, shredding each of them with some of the shrapnel they helped absorb. This can snuff out all of the shrapnel if there's enough bodies
  *
  */
/datum/component/pellet_cloud/proc/handle_martyrs(mob/living/lanced_by)
	var/magnitude_absorbed
	var/list/martyrs = list()

	var/self_harm_radius_mult = 3

	if(lanced_by && prob(60))
		to_chat(lanced_by, span_userdanger("Your plan to whack someone with a grenade on a stick backfires on you, literally!"))
		self_harm_radius_mult = 1 // we'll still give the guy who got hit some extra shredding, but not 3*radius
		pellet_delta += radius
		for(var/i in 1 to radius)
			pew(lanced_by) // thought you could be tricky and lance someone with no ill effects!!

	for(var/mob/living/body in get_turf(parent))
		if(body == shooter)
			pellet_delta += radius * self_harm_radius_mult
			for(var/i in 1 to radius * self_harm_radius_mult)
				pew(body) // free shrapnel if it goes off in your hand, and it doesn't even count towards the absorbed. fun!
		else if(!(body in bodies))
			martyrs += body // promoted from a corpse to a hero

	for(var/M in martyrs)
		var/mob/living/martyr = M
		if(radius > 4)
			martyr.visible_message("<b>[span_danger("[martyr] heroically covers \the [parent] with [martyr.p_their()] body, absorbing a load of the shrapnel!")]</b>", span_userdanger("You heroically cover \the [parent] with your body, absorbing a load of the shrapnel!"))
			magnitude_absorbed += round(radius * 0.5)
		else if(radius >= 2)
			martyr.visible_message("<b>[span_danger("[martyr] heroically covers \the [parent] with [martyr.p_their()] body, absorbing some of the shrapnel!")]</b>", span_userdanger("You heroically cover \the [parent] with your body, absorbing some of the shrapnel!"))
			magnitude_absorbed += 2
		else
			martyr.visible_message("<b>[span_danger("[martyr] heroically covers \the [parent] with [martyr.p_their()] body, snuffing out the shrapnel!")]</b>", span_userdanger("You heroically cover \the [parent] with your body, snuffing out the shrapnel!"))
			magnitude_absorbed = radius

		var/pellets_absorbed = (radius ** 2) - ((radius - magnitude_absorbed - 1) ** 2)
		radius -= magnitude_absorbed
		pellet_delta -= round(pellets_absorbed * 0.5)

		if(martyr.stat != DEAD && martyr.client)
			RegisterSignal(martyr, COMSIG_PARENT_QDELETING, PROC_REF(on_target_qdel), override=TRUE)

		for(var/i in 1 to round(pellets_absorbed * 0.5))
			pew(martyr)

		if(radius < 1)
			break

///One of our pellets hit something, record what it was and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_hit(obj/projectile/P, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	pellets -= P
	terminated++
	hits++
	var/damage = TRUE
	/* WOUNDS
	if(iscarbon(target) && hit_zone)
		var/mob/living/carbon/hit_carbon = target
		hit_part = hit_carbon.get_bodypart(hit_zone)
		if(hit_part)
			target = hit_part
			if(P.wound_bonus != CANT_WOUND) // handle wounding
				// unfortunately, due to how pellet clouds handle finalizing only after every pellet is accounted for, that also means there might be a short delay in dealing wounds if one pellet goes wide
				// while buckshot may reach a target or miss it all in one tick, we also have to account for possible ricochets that may take a bit longer to hit the target
				if(isnull(wound_info_by_part[hit_part]))
					wound_info_by_part[hit_part] = list(0, 0, 0)
				wound_info_by_part[hit_part][CLOUD_POSITION_DAMAGE] += P.damage // these account for decay
				wound_info_by_part[hit_part][CLOUD_POSITION_W_BONUS] += P.wound_bonus
				wound_info_by_part[hit_part][CLOUD_POSITION_BW_BONUS] += P.bare_wound_bonus
				P.wound_bonus = CANT_WOUND // actual wounding will be handled aggregate
	*/
	if(isobj(target))
		var/obj/hit_object = target
		if(hit_object.damage_deflection > P.damage || !P.damage)
			damage = FALSE

	LAZYADDASSOC(targets_hit[target], "hits", 1)
	LAZYSET(targets_hit[target], "damage", damage)
	if(targets_hit[target]["hits"] == 1)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_qdel), override=TRUE)
	UnregisterSignal(P, list(COMSIG_PARENT_QDELETING, COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PROJECTILE_SELF_ON_HIT))
	if(terminated == num_pellets)
		finalize()

///One of our pellets disappeared due to hitting their max range (or just somehow got qdel'd), remove it from our list and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_range(obj/projectile/P)
	SIGNAL_HANDLER
	pellets -= P
	terminated++
	UnregisterSignal(P, list(COMSIG_PARENT_QDELETING, COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PROJECTILE_SELF_ON_HIT))
	if(terminated == num_pellets)
		finalize()

/// Minor convenience function for creating each shrapnel piece with circle explosions, mostly stolen from the MIRV component
/datum/component/pellet_cloud/proc/pew(atom/target, spread=0)
	var/obj/projectile/P = new projectile_type(get_turf(parent))

	//Shooting Code:
	P.spread = 0
	P.original = target
	P.fired_from = parent
	P.firer = parent // don't hit ourself that would be really annoying
	P.impacted = list(parent = TRUE) // don't hit the target we hit already with the flak
	P.suppressed = SUPPRESSED_VERY // set the projectiles to make no message so we can do our own aggregate message
	P.preparePixelProjectile(target, parent)
	RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(pellet_hit))
	RegisterSignals(P, list(COMSIG_PROJECTILE_RANGE_OUT, COMSIG_PARENT_QDELETING), PROC_REF(pellet_range))
	pellets += P
	P.fire()

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/finalize()
	var/obj/projectile/P = projectile_type
	var/proj_name = initial(P.name)

	for(var/atom/target in targets_hit)
		var/num_hits = targets_hit[target]["hits"]
		var/damage = targets_hit[target]["damage"]
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
		var/obj/item/bodypart/hit_part
		if(isbodypart(target))
			hit_part = target
			if(!hit_part.owner) //only bother doing the thing if it was a limb just laying on the ground lol.
				hit_part = null //so the visible_message later on doesn't generate extra text.
			else
				target = hit_part.owner

		var/limb_hit_text = ""
		if(hit_part)
			limb_hit_text = " in the [hit_part.plaintext_zone]"

		if(num_hits > 1)
			target.visible_message(span_danger("[target] is hit by [num_hits] [proj_name][plural_s(proj_name)][limb_hit_text][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE, target)
			to_chat(target, span_userdanger("You're hit by [num_hits] [proj_name]s[limb_hit_text]!"))
		else
			target.visible_message(span_danger("[target] is hit by a [proj_name][limb_hit_text][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE, target)
			to_chat(target, span_userdanger("You're hit by a [proj_name][limb_hit_text]!"))

	UnregisterSignal(parent, COMSIG_PARENT_PREQDELETED)
	if(queued_delete)
		qdel(parent)
	qdel(src)

/// Look alive, we're armed! Now we start watching to see if anyone's covering us
/datum/component/pellet_cloud/proc/grenade_armed(obj/item/nade)
	SIGNAL_HANDLER

	if(ismob(nade.loc))
		shooter = nade.loc
	LAZYINITLIST(bodies)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(grenade_dropped))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(grenade_moved))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED =PROC_REF(grenade_uncrossed),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/// Someone dropped the grenade, so set them to the shooter in case they're on top of it when it goes off
/datum/component/pellet_cloud/proc/grenade_dropped(obj/item/nade, mob/living/slick_willy)
	SIGNAL_HANDLER

	shooter = slick_willy
	grenade_moved()

/// Our grenade has moved, reset var/list/bodies so we're "on top" of any mobs currently on the tile
/datum/component/pellet_cloud/proc/grenade_moved()
	SIGNAL_HANDLER

	LAZYCLEARLIST(bodies)
	for(var/mob/living/L in get_turf(parent))
		RegisterSignal(L, COMSIG_PARENT_QDELETING, PROC_REF(on_target_qdel), override=TRUE)
		bodies += L

/// Someone who was originally "under" the grenade has moved off the tile and is now eligible for being a martyr and "covering" it
/datum/component/pellet_cloud/proc/grenade_uncrossed(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	bodies -= gone

/// Our grenade or landmine or caseless shell or whatever tried deleting itself, so we intervene and nullspace it until we're done here
/datum/component/pellet_cloud/proc/nullspace_parent()
	SIGNAL_HANDLER

	var/atom/movable/AM = parent
	AM.moveToNullspace()
	queued_delete = TRUE
	return TRUE

/// Someone who was originally "under" the grenade has moved off the tile and is now eligible for being a martyr and "covering" it
/datum/component/pellet_cloud/proc/on_target_qdel(atom/target)
	SIGNAL_HANDLER

	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	targets_hit -= target
	LAZYREMOVE(bodies, target)
