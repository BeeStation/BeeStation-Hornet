/obj/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	armour_penetration = 100
	armor_flag = NONE
	martial_arts_no_deflect = TRUE
	/// determines what type of antimagic can block the spell projectile
	var/antimagic_flags = MAGIC_RESISTANCE
	/// determines the drain cost on the antimagic item
	var/antimagic_charge_cost = 1

/obj/projectile/magic/prehit_pierce(atom/target)
	. = ..()

	if(isliving(target))
		var/mob/living/victim = target
		if(victim.can_block_magic(antimagic_flags))
			visible_message(("<span class='warning'>[src] fizzles on contact with [victim]!</span>"))
			return PROJECTILE_DELETE_WITHOUT_HITTING

/obj/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/death/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		M.death(0)

/obj/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	. = ..()
	if(isliving(target))
		if(target.ishellbound())
			return BULLET_ACT_BLOCK
		if(target.can_block_magic(antimagic_flags))
			target.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.regenerate_limbs()
			C.regenerate_organs()
		if(target.revive(full_heal = 1))
			target.grab_ghost(force = TRUE) // even suicides
			to_chat(target, span_notice("You rise with a start, you're alive!!!"))
		else if(target.stat != DEAD)
			to_chat(target, span_notice("You feel great!"))

/obj/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/projectile/magic/teleport/on_hit(mob/target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] fizzles on contact with [target]!"))
			return BULLET_ACT_BLOCK
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc && !isobserver(stuff))
			if(do_teleport(stuff, stuff, 10, channel = TELEPORT_CHANNEL_MAGIC))
				teleammount++
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(max(round(4 - teleammount),0), stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
				smoke.start()

/obj/projectile/magic/safety
	name = "bolt of safety"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/safety/on_hit(atom/target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] fizzles on contact with [target]!"))
			return BULLET_ACT_BLOCK
	if(isturf(target))
		return BULLET_ACT_HIT

	var/turf/origin_turf = get_turf(target)
	var/turf/destination_turf = find_safe_turf()

	if(do_teleport(target, destination_turf, channel=TELEPORT_CHANNEL_MAGIC))
		for(var/t in list(origin_turf, destination_turf))
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(0, t)
			smoke.start()

/obj/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = TRUE
	var/list/door_types = list(/obj/structure/mineral_door/wood, /obj/structure/mineral_door/iron, /obj/structure/mineral_door/copper, /obj/structure/mineral_door/silver, /obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium, /obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/plasma, /obj/structure/mineral_door/transparent/diamond)

/obj/projectile/magic/door/on_hit(atom/target)
	. = ..()
	if(istype(target, /obj/machinery/door))
		OpenDoor(target)
	else
		var/turf/T = get_turf(target)
		if(isclosedturf(T) && !isindestructiblewall(T))
			CreateDoor(T)

/obj/projectile/magic/door/proc/CreateDoor(turf/T)
	var/door_type = pick(door_types)
	var/obj/structure/mineral_door/D = new door_type(T)
	T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	D.Open()

/obj/projectile/magic/door/proc/OpenDoor(var/obj/machinery/door/D)
	if(istype(D, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = D
		A.locked = FALSE
	D.open()

/obj/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/change/on_hit(atom/change)
	. = ..()
	if(ismob(change))
		var/mob/M = change
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] fizzles on contact with [M]!"))
			qdel(src)
			return BULLET_ACT_BLOCK
	wabbajack(change)
	qdel(src)

/proc/wabbajack(mob/living/M)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags))
		return

	if(SEND_SIGNAL(M, COMSIG_LIVING_PRE_WABBAJACKED) & STOP_WABBAJACK)
		return

	M.notransform = TRUE
	ADD_TRAIT(M, TRAIT_IMMOBILIZED, MAGIC_TRAIT)
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, MAGIC_TRAIT)
	M.icon = null
	M.cut_overlays()
	M.invisibility = INVISIBILITY_ABSTRACT

	var/list/contents = M.contents.Copy()
	if(issilicon(M)) // silicons should not drop internal parts since they are supposed to be unobtainable
		for(var/obj/item/W in contents)
			qdel(W)
		if(iscyborg(M))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.deployed || Robot.mainframe)
				Robot.undeploy() // disconnect any AI shells first
			if(Robot.mmi)
				qdel(Robot.mmi)
			Robot.notify_ai(NEW_BORG)
	else
		for(var/obj/item/W in contents)
			if(!M.dropItemToGround(W))
				qdel(W)

	var/mob/living/new_mob

	var/randomize = pick("monkey","robot","slime","xeno","humanoid","animal")
	switch(randomize)
		if("monkey")
			new_mob = new /mob/living/carbon/monkey(M.loc)

		if("robot")
			var/robot = pick(200;/mob/living/silicon/robot,
							/mob/living/silicon/robot/modules/syndicate,
							/mob/living/silicon/robot/modules/syndicate/medical,
							/mob/living/silicon/robot/modules/syndicate/saboteur,
							200;/mob/living/simple_animal/drone/polymorphed)
			new_mob = new robot(M.loc)
			if(issilicon(new_mob))
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = JOB_NAME_CYBORG
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.lawupdate = FALSE
				Robot.connected_ai = null
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
				Robot.clear_inherent_laws(0)
				Robot.clear_zeroth_law(0)

		if("slime")
			new_mob = new /mob/living/simple_animal/slime/random(M.loc)

		if("xeno")
			var/Xe
			if(M.ckey)
				Xe = pick(/mob/living/carbon/alien/humanoid/hunter,/mob/living/carbon/alien/humanoid/sentinel)
			else
				Xe = pick(/mob/living/carbon/alien/humanoid/hunter,/mob/living/simple_animal/hostile/alien/sentinel)
			new_mob = new Xe(M.loc)

		if("animal")
			var/path = pick(/mob/living/simple_animal/hostile/carp,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/mushroom,
							/mob/living/simple_animal/hostile/statue,
							/mob/living/simple_animal/hostile/retaliate/bat,
							/mob/living/simple_animal/hostile/retaliate/goat,
							/mob/living/simple_animal/hostile/killertomato,
							/mob/living/simple_animal/hostile/poison/giant_spider,
							/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
							/mob/living/simple_animal/hostile/blob/blobbernaut/independent,
							/mob/living/simple_animal/hostile/carp/ranged,
							/mob/living/simple_animal/hostile/carp/ranged/chaos,
							/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
							/mob/living/simple_animal/hostile/asteroid/goliath/beast,
							/mob/living/simple_animal/hostile/headcrab,
							/mob/living/simple_animal/hostile/morph,
							/mob/living/simple_animal/hostile/stickman,
							/mob/living/simple_animal/hostile/stickman/dog,
							/mob/living/simple_animal/hostile/megafauna/dragon/lesser,
							/mob/living/simple_animal/hostile/gorilla,
							/mob/living/simple_animal/parrot,
							/mob/living/basic/pet/dog/corgi,
							/mob/living/simple_animal/crab,
							/mob/living/basic/pet/dog/pug,
							/mob/living/simple_animal/pet/cat,
							/mob/living/simple_animal/mouse,
							/mob/living/simple_animal/chicken,
							/mob/living/simple_animal/cow,
							/mob/living/simple_animal/hostile/lizard,
							/mob/living/simple_animal/pet/fox,
							/mob/living/simple_animal/butterfly,
							/mob/living/simple_animal/pet/cat/cak,
							/mob/living/simple_animal/chick)
			new_mob = new path(M.loc)

		if("humanoid")
			var/mob/living/carbon/human/new_human = new(M.loc)

			if(prob(50))
				var/list/chooseable_races = list()
				for(var/speciestype in subtypesof(/datum/species))
					var/datum/species/S = speciestype
					if(initial(S.changesource_flags) & WABBAJACK)
						chooseable_races += speciestype

				if(chooseable_races.len)
					new_human.set_species(pick(chooseable_races))

			// Randomize everything but the species, which was already handled above.
			new_human.randomize_human_appearance(~RANDOMIZE_SPECIES)
			new_human.update_hair()
			new_human.update_body() // is_creating = TRUE
			new_human.dna.update_dna_identity()
			new_mob = new_human

	if(!new_mob)
		return
	new_mob.grant_language(/datum/language/common)

	// Some forms can still wear some items
	for(var/obj/item/W in contents)
		new_mob.equip_to_appropriate_slot(W)

	M.log_message("became [new_mob.real_name]", LOG_ATTACK, color="orange")

	SEND_SIGNAL(M, COMSIG_LIVING_ON_WABBAJACKED, new_mob)

	new_mob.set_combat_mode(TRUE)

	M.wabbajack_act(new_mob)

	to_chat(new_mob, span_warning("Your form morphs into that of a [randomize]."))

	var/poly_msg = CONFIG_GET(string/policy_polymorph)
	if(poly_msg)
		to_chat(new_mob, poly_msg)

	M.transfer_observers_to(new_mob, TRUE)

	qdel(M)
	return new_mob

/obj/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

/obj/projectile/magic/animate/on_hit(atom/target, blocked = FALSE)
	target.animate_atom_living(firer)
	..()

/atom/proc/animate_atom_living(var/mob/living/owner = null)
	if((isitem(src) || isstructure(src)) && !is_type_in_list(src, GLOB.protected_objects))
		if(istype(src, /obj/structure/statue/petrified))
			var/obj/structure/statue/petrified/P = src
			if(P.petrified_mob)
				var/mob/living/L = P.petrified_mob
				var/mob/living/simple_animal/hostile/statue/S = new(P.loc, owner)
				S.name = "statue of [L.name]"
				if(owner)
					S.faction = list("[REF(owner)]")
				S.icon = P.icon
				S.icon_state = P.icon_state
				S.copy_overlays(P, TRUE)
				S.color = P.color
				S.atom_colours = P.atom_colours.Copy()
				if(L.mind)
					L.mind.transfer_to(S)
					if(owner)
						to_chat(S, span_userdanger("You are an animate statue. You cannot move when monitored, but are nearly invincible and deadly when unobserved! Do not harm [owner], your creator."))
				P.forceMove(S)
				return
		else
			var/obj/O = src
			if(istype(O, /obj/item/gun))
				new /mob/living/simple_animal/hostile/mimic/copy/ranged(loc, src, owner)
			else
				new /mob/living/simple_animal/hostile/mimic/copy(loc, src, owner)

	else if(istype(src, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = src
		if(owner)
			C.ChangeOwner(owner)

/obj/projectile/magic/spellblade
	name = "blade energy"
	icon_state = "lavastaff"
	damage = 15
	damage_type = BURN
	dismemberment = 50
	nodamage = FALSE
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/spellblade/on_hit(target)
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			qdel(src)
			return BULLET_ACT_BLOCK
	. = ..()

/obj/projectile/magic/arcane_barrage
	name = "arcane bolt"
	icon_state = "arcane_barrage"
	damage = 20
	damage_type = BURN
	nodamage = FALSE
	hitsound = 'sound/weapons/barragespellhit.ogg'
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/arcane_barrage/on_hit(target)
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			qdel(src)
			return
	. = ..()


/obj/projectile/magic/locker
	name = "locker bolt"
	icon_state = "locker"
	nodamage = TRUE
	martial_arts_no_deflect = FALSE
	var/weld = TRUE
	var/created = FALSE //prevents creation of more then one locker if it has multiple hits
	var/locker_suck = TRUE


/obj/projectile/magic/locker/prehit_pierce(atom/A)
	. = ..()
	if(isliving(A) && locker_suck)
		var/mob/living/M = A
		if(M.can_block_magic(antimagic_flags))			// no this doesn't check if ..() returned to phase through do I care no it's magic ain't gotta explain shit
			M.visible_message(span_warning("[src] vanishes on contact with [A]!"))
			return PROJECTILE_DELETE_WITHOUT_HITTING
		if(M.incorporeal_move || M.mob_size > MOB_SIZE_HUMAN || LAZYLEN(contents)>=5)
			return
		M.forceMove(src)
		return PROJECTILE_PIERCE_PHASE

/obj/projectile/magic/locker/on_hit(target)
	if(created)
		return ..()
	var/obj/structure/closet/decay/C = new(get_turf(src))
	if(LAZYLEN(contents))
		for(var/atom/movable/AM in contents)
			AM.forceMove(C)
		C.welded = TRUE
		C.update_icon()
	created = TRUE
	return ..()

/obj/projectile/magic/locker/Destroy()
	locker_suck = FALSE
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(src))
	. = ..()

/obj/structure/closet/decay
	breakout_time = 600
	icon_welded = null
	material_drop_amount = 0
	var/magic_icon = "cursed"
	var/weakened_icon = "decursed"
	icon_door = "cursed"
	var/weakened_icon_door = "decursed"

/obj/structure/closet/decay/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(locker_magic_timer)), 5)

/obj/structure/closet/decay/proc/locker_magic_timer()
	if(welded)
		addtimer(CALLBACK(src, PROC_REF(bust_open)), 5 MINUTES)
		icon_state = magic_icon
		update_icon()
	else
		addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/structure/closet/decay/after_weld(weld_state)
	if(weld_state)
		unmagify()

/obj/structure/closet/decay/proc/decay()
	animate(src, alpha = 0, time = 30)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 30)

/obj/structure/closet/decay/open(mob/living/user)
	. = ..()
	if(.)
		if(icon_state == magic_icon) //check if we used the magic icon at all before giving it the lesser magic icon
			unmagify()
		else
			addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/structure/closet/decay/proc/unmagify()
	icon_state = weakened_icon
	icon_door = weakened_icon_door
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(decay)), 15 SECONDS)

/obj/projectile/magic/flying
	name = "bolt of flying"
	icon_state = "flight"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/flying/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic(antimagic_flags))
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		var/atom/throw_target = get_edge_target_turf(L, angle2dir(Angle))
		L.throw_at(throw_target, 200, 4)

/obj/projectile/magic/bounty
	name = "bolt of bounty"
	icon_state = "bounty"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/bounty/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic(antimagic_flags) || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		L.apply_status_effect(STATUS_EFFECT_BOUNTY, firer)

/obj/projectile/magic/antimagic
	name = "bolt of antimagic"
	icon_state = "antimagic"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/antimagic/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic(antimagic_flags))
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		L.apply_status_effect(STATUS_EFFECT_ANTIMAGIC)

/obj/projectile/magic/fetch
	name = "bolt of fetching"
	icon_state = "fetch"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/fetch/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.can_block_magic(antimagic_flags) || !firer)
			L.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		var/atom/throw_target = get_edge_target_turf(L, get_dir(L, firer))
		L.throw_at(throw_target, 200, 4)

/obj/projectile/magic/sapping
	name = "bolt of sapping"
	icon_state = "sapping"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/sapping/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.can_block_magic(antimagic_flags))
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, REF(src), /datum/mood_event/sapped)

/obj/projectile/magic/necropotence
	name = "bolt of necropotence"
	icon_state = "necropotence"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/necropotence/on_hit(target)
	. = ..()
	if(!isliving(target))
		return

	// Performs a soul tap on living targets hit.
	// Takes away max health, but refreshes their spell cooldowns (if any)
	var/datum/action/spell/tap/tap = new(src)
	if(tap.is_valid_spell(target, target))
		tap.on_cast(target, target)

	qdel(tap)

/obj/projectile/magic/wipe
	name = "bolt of possession"
	icon_state = "wipe"
	martial_arts_no_deflect = FALSE

/obj/projectile/magic/wipe/on_hit(target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(M.can_block_magic(antimagic_flags) || istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
		for(var/x in M.get_traumas())//checks to see if the victim is already going through possession
			if(istype(x, /datum/brain_trauma/special/imaginary_friend/trapped_owner))
				M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
				return BULLET_ACT_BLOCK
		to_chat(M, span_warning("Your mind has been opened to possession!"))
		possession_test(M)
		return BULLET_ACT_HIT

/obj/projectile/magic/wipe/proc/possession_test(var/mob/living/carbon/M)
	var/datum/brain_trauma/special/imaginary_friend/trapped_owner/trauma = M.gain_trauma(/datum/brain_trauma/special/imaginary_friend/trapped_owner)
	var/poll_message = "Do you want to play as [M.real_name]?"
	var/ban_key = BAN_ROLE_ALL_ANTAGONISTS
	if(M.mind?.assigned_role)
		poll_message = "[poll_message] Job:[M.mind.assigned_role]."
	if(M.mind?.special_role)
		poll_message = "[poll_message] Status:[M.mind.special_role]."
	else if(M.mind)
		var/datum/antagonist/A = M.mind.has_antag_datum(/datum/antagonist)
		if(A)
			poll_message = "[poll_message] Status:[A.name]."
			ban_key = A.banning_key
	var/list/mob/dead/observer/candidates = poll_candidates_for_mob(poll_message, ban_key, null, 10 SECONDS, M, ignore_category = FALSE)
	if(M.stat == DEAD)//boo.
		return
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(M, "You have been noticed by a ghost, and it has possessed you!")
		var/oldkey = M.key
		M.ghostize(FALSE)
		M.key = C.key
		trauma.friend.key = oldkey
		trauma.friend.reset_perspective(null)
		trauma.friend.Show()
		trauma.friend_initialized = TRUE
	else
		to_chat(M, span_notice("Your mind has managed to go unnoticed in the spirit world."))
		qdel(trauma)

/// Gives magic projectiles an area of effect radius that will bump into any nearby mobs
/obj/projectile/magic/aoe
	damage = 0

	/// The AOE radius that the projectile will trigger on people.
	var/trigger_range = 1
	/// Whether our projectile will only be able to hit the original target / clicked on atom
	var/can_only_hit_target = FALSE

	/// Whether our projectile leaves a trail behind it  as it moves.
	var/trail = FALSE
	/// The duration of the trail before deleting.
	var/trail_lifespan = 0 SECONDS
	/// The icon the trail uses.
	var/trail_icon = 'icons/obj/wizard.dmi'
	/// The icon state the trail uses.
	var/trail_icon_state = "trail"

/obj/projectile/magic/aoe/Range()
	if(trigger_range >= 1)
		for(var/mob/living/nearby_guy in range(trigger_range, get_turf(src)))
			if(nearby_guy.stat == DEAD)
				continue
			if(nearby_guy == firer)
				continue
			// Bump handles anti-magic checks for us, conveniently.
			return Bump(nearby_guy)

	return ..()

/obj/projectile/magic/aoe/can_hit_target(atom/target, list/passthrough, direct_target = FALSE, ignore_loc = FALSE)
	if(can_only_hit_target && target != original)
		return FALSE
	return ..()

/obj/projectile/magic/aoe/Moved(atom/OldLoc, Dir)
	. = ..()
	if(trail)
		create_trail()

/// Creates and handles the trail that follows the projectile.
/obj/projectile/magic/aoe/proc/create_trail()
	if(!trajectory)
		return

	var/datum/point/vector/previous = trajectory.return_vector_after_increments(1, -1)
	var/obj/effect/overlay/trail = new /obj/effect/overlay(previous.return_turf())
	trail.pixel_x = previous.return_px()
	trail.pixel_y = previous.return_py()
	trail.icon = trail_icon
	trail.icon_state = trail_icon_state
	//might be changed to temp overlay
	trail.set_density(FALSE)
	trail.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	QDEL_IN(trail, trail_lifespan)

/obj/projectile/magic/aoe/lightning
	name = "lightning bolt"
	icon_state = "tesla_projectile" //Better sprites are REALLY needed and appreciated!~
	damage = 15
	damage_type = BURN
	nodamage = FALSE
	speed = 0.3

	/// The power of the zap itself when it electrocutes someone
	var/zap_power = 20000
	/// The range of the zap itself when it electrocutes someone
	var/zap_range = 15
	/// The flags of the zap itself when it electrocutes someone
	var/zap_flags = TESLA_MOB_DAMAGE | TESLA_MOB_STUN | TESLA_OBJ_DAMAGE
	/// A reference to the chain beam between the caster and the projectile
	var/datum/beam/chain

/obj/projectile/magic/aoe/lightning/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]")
	return ..()

/obj/projectile/magic/aoe/lightning/on_hit(target)
	. = ..()
	tesla_zap(src, zap_range, zap_power, zap_flags)

/obj/projectile/magic/aoe/lightning/Destroy()
	QDEL_NULL(chain)
	return ..()

/obj/projectile/magic/aoe/lightning/no_zap
	zap_power = 10000
	zap_range = 4
	zap_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE

/obj/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = FALSE

	/// Heavy explosion range of the fireball
	var/exp_heavy = 0
	/// Light explosion range of the fireball
	var/exp_light = 2
	/// Fire radius of the fireball
	var/exp_fire = 2
	/// Flash radius of the fireball
	var/exp_flash = 3

/obj/projectile/magic/fireball/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		// between this 10 burn, the 10 brute, the explosion brute, and the onfire burn,
		// you are at about 65 damage if you stop drop and roll immediately
		mob_target.take_overall_damage(burn = 10)

	var/turf/target_turf = get_turf(target)

	explosion(
		target_turf,
		devastation_range = -1,
		heavy_impact_range = exp_heavy,
		light_impact_range = exp_light,
		flame_range = exp_fire,
		flash_range = exp_flash,
		adminlog = FALSE,
	)

/obj/projectile/magic/aoe/magic_missile
	name = "magic missile"
	icon_state = "magicm"
	range = 20
	speed = 5
	trigger_range = 0
	can_only_hit_target = TRUE
	nodamage = FALSE
	paralyze = 6 SECONDS
	hitsound = 'sound/magic/mm_hit.ogg'

	trail = TRUE
	trail_lifespan = 0.5 SECONDS
	trail_icon_state = "magicmd"

/obj/projectile/magic/aoe/magic_missile/lesser
	color = "red" //Looks more culty this way
	range = 10

/obj/projectile/magic/aoe/juggernaut
	name = "Gauntlet Echo"
	icon_state = "cultfist"
	alpha = 180
	damage = 30
	damage_type = BRUTE
	knockdown = 50
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	ignored_factions = list("cult")
	range = 15
	speed = 7

/obj/projectile/magic/spell/juggernaut/on_hit(atom/target, blocked)
	. = ..()
	var/turf/target_turf = get_turf(src)
	playsound(target_turf, 'sound/weapons/resonator_blast.ogg', 100, FALSE)
	new /obj/effect/temp_visual/cult/sac(target_turf)
	for(var/obj/adjacent_object in range(1, src))
		if(!adjacent_object.density)
			continue
		if(istype(adjacent_object, /obj/structure/destructible/cult))
			continue

		adjacent_object.take_damage(90, BRUTE, MELEE, 0)
		new /obj/effect/temp_visual/cult/turf/floor(get_turf(adjacent_object))

//still magic related, but a different path

/obj/projectile/temp/chill
	name = "bolt of chills"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	armour_penetration = 100
	temperature = -200 // Cools you down greatly per hit
