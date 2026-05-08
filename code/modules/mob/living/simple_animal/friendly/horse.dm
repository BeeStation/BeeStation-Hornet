// code/modules/mob/living/simple_animal/friendly/horse.dm

/mob/living/simple_animal/horse
	name = "Horse"
	desc = "A Majestic creature with a notoriously strong heart."
	icon = 'icons/mob/horsey.dmi'
	icon_state = "Horse-White"
	icon_living = "Horse-White"
	icon_dead = "Horse-White-Dead"
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("neighs", "winnies")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	melee_damage = 8
	health = 150
	maxHealth = 150
	gold_core_spawnable = FRIENDLY_SPAWN
	can_buckle = FALSE
	buckle_lying = 0
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	move_force = MOVE_FORCE_NORMAL
	unsuitable_atmos_damage = 1
	minbodytemp = 250
	maxbodytemp = 350
	/// Do we register a unique rider?
	var/unique_tamer = FALSE
	/// The person we've been tamed by
	var/datum/weakref/my_owner
	/// Sound for galloping while being ridden
	var/gallop_sound = 'sound/creatures/gallup.ogg'
	var/snort_sound = 'sound/creatures/snort.ogg'
	var/list/whinny_sounds = list(
		'sound/creatures/whinny01.ogg',
		'sound/creatures/whinny02.ogg',
		'sound/creatures/whinny03.ogg',
	)
	/// Can this horse be ridden?
	var/can_ride = TRUE
	/// Damage dealt when trampling someone lying down
	var/trample_damage = 15
	/// Damage dealt when crashing into walls
	var/crash_damage = 10
	/// Chance to dismount the rider when crashing (0-100)
	var/crash_dismount_chance = 60
	/// List of food types that can tame the horse
	var/static/list/taming_food = list(
		/obj/item/food/grown/apple,
		/obj/item/food/grown/wheat,
		/obj/item/food/grown/oat,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/apple/gold,
	)
	/// Is the horse currently jumping?
	var/jumping = FALSE
	/// How many tiles can the horse jump?
	var/jump_distance = 3
	/// Cooldown between jumps
	var/jump_cooldown_time = 3 SECONDS
	/// The randomly chosen base icon (without direction/dead/jump suffix)
	var/base_icon = "Horse-White"
	/// Has the horse been named by a player?
	var/has_been_named = FALSE
	/// Timer for whistle movement timeout
	var/whistle_timer
	/// Auto‑buckle check timer
	var/auto_buckle_timer
	/// Owner who whistled, used for auto‑buckle
	var/mob/living/whistle_owner
	/// Stored normal speed, so we can restore it after whistle boost
	var/normal_speed = 1
	/// Stores riders' original pass flags during a jump, so they can be restored
	var/list/rider_pass_backup = list()
	COOLDOWN_DECLARE(jump_cooldown)
	COOLDOWN_DECLARE(trample_cooldown)
	COOLDOWN_DECLARE(whistle_cooldown)
	COOLDOWN_DECLARE(crash_cooldown)

/mob/living/simple_animal/horse/Initialize(mapload)
	. = ..()
	// Randomize appearance among the four variants
	var/static/list/horse_variants = list("Horse-White", "Horse-Spotted", "Horse-Grey", "Horse-Brown")
	var/chosen = pick(horse_variants)
	base_icon = chosen
	icon_state = chosen
	icon_living = chosen
	icon_dead = "[chosen]-Dead"
	normal_speed = speed

	AddElement(/datum/element/pet_bonus, "whickers happily")
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddComponent(/datum/component/tameable, food_types = taming_food, tame_chance = 25, bonus_tame_chance = 15, unique = unique_tamer)

/mob/living/simple_animal/horse/tamed(mob/living/tamer, atom/food)
	playsound(src, snort_sound, 50)

	if(can_ride)
		AddElement(/datum/element/ridable, /datum/component/riding/creature/horse)
		can_buckle = TRUE
		buckle_lying = 0

	visible_message(span_notice("[src] snorts happily."))
	new /obj/effect/temp_visual/heart(loc)
	playsound(src, pick(whinny_sounds), 50)

	// Set the owner (even if not unique) so whistle works
	if(my_owner)
		var/mob/living/old_owner = my_owner.resolve()
		if(old_owner)
			UnregisterSignal(old_owner, COMSIG_MOB_EMOTE)
	my_owner = WEAKREF(tamer)
	RegisterSignal(tamer, COMSIG_MOB_EMOTE, PROC_REF(on_owner_emote))

	if(unique_tamer)
		RegisterSignal(src, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle))

	// Name the horse the first time it's tamed
	if(!has_been_named)
		var/chosen_name = reject_bad_name(tgui_input_text(tamer, "Choose a name for your new horse!", "Name your horse", name, MAX_NAME_LEN))
		if(chosen_name)
			name = chosen_name
			has_been_named = TRUE

	return ..()

/mob/living/simple_animal/horse/post_buckle_mob(mob/living/M)
	. = ..()
	if(M)
		var/datum/action/horse_jump/jump_action = new()
		jump_action.Grant(M)

/mob/living/simple_animal/horse/post_unbuckle_mob(mob/living/M)
	. = ..()
	if(M)
		var/datum/action/horse_jump/jump_action = locate() in M.actions
		if(jump_action)
			jump_action.Remove(M)
	// In case we have leftover pass flag backups, restore them
	restore_rider_pass_flags()

/mob/living/simple_animal/horse/Destroy()
	var/mob/living/old_owner = my_owner?.resolve()
	if(old_owner)
		UnregisterSignal(old_owner, COMSIG_MOB_EMOTE)
	UnregisterSignal(src, COMSIG_MOVABLE_PREBUCKLE)
	if(whistle_timer)
		deltimer(whistle_timer)
	if(auto_buckle_timer)
		deltimer(auto_buckle_timer)
	restore_rider_pass_flags()
	my_owner = null
	return ..()

/mob/living/simple_animal/horse/proc/on_prebuckle(mob/source, mob/living/buckler, force, buckle_mob_flags)
	SIGNAL_HANDLER
	var/mob/living/tamer = my_owner?.resolve()
	if(!unique_tamer)
		return
	if(buckler != tamer)
		visible_message(span_danger("[src] whinnies angrily at [buckler]!"))
		playsound(src, pick(whinny_sounds), 50)
		return COMPONENT_BLOCK_BUCKLE

/mob/living/simple_animal/horse/death(gibbed)
	// Restore any modified pass flags before unbuckling
	restore_rider_pass_flags()
	playsound(src, snort_sound, 70)
	playsound(src, pick(whinny_sounds), 70)
	for(var/mob/living/rider in buckled_mobs)
		rider.apply_damage(15, BRUTE)
		unbuckle_mob(rider)
		rider.Paralyze(2 SECONDS)
		rider.Knockdown(4 SECONDS)
		rider.visible_message(
			span_danger("[rider] is thrown from [src] as it collapses!"),
			span_userdanger("You're thrown from [src] as it collapses beneath you!")
		)
	return ..()

/mob/living/simple_animal/horse/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		playsound(src, pick(whinny_sounds), 50)

/mob/living/simple_animal/horse/Move(atom/newloc, direct)
	. = ..()
	if(.)
		// Trample prone people
		for(var/mob/living/victim in get_turf(src))
			if(victim == src || (victim in buckled_mobs))
				continue
			if(victim.body_position != LYING_DOWN)
				continue
			if(!COOLDOWN_FINISHED(src, trample_cooldown))
				continue
			COOLDOWN_START(src, trample_cooldown, 1 SECONDS)
			victim.apply_damage(trample_damage, BRUTE, BODY_ZONE_CHEST)
			victim.visible_message(
				span_danger("[victim] is trampled by [src]!"),
				span_userdanger("You're trampled by [src]!")
			)
			playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

		// Drop dead or critical riders
		check_rider_status()

/mob/living/simple_animal/horse/proc/check_rider_status()
	for(var/mob/living/rider in buckled_mobs)
		if(rider.stat == DEAD)
			rider.visible_message(
				span_danger("[rider] slumps off [src]!"),
				span_userdanger("You fall off [src] as your life fades...")
			)
			unbuckle_mob(rider)
			rider.Knockdown(2 SECONDS)
		else if(rider.stat == UNCONSCIOUS) // critical condition
			rider.visible_message(
				span_danger("[rider] goes limp and slides off [src]!"),
				span_userdanger("You lose consciousness and fall from [src]!")
			)
			unbuckle_mob(rider)
			rider.Knockdown(2 SECONDS)

/mob/living/simple_animal/horse/proc/do_jump()
	jumping = TRUE
	COOLDOWN_START(src, jump_cooldown, jump_cooldown_time)

	icon_state = "[base_icon]-Jump"
	update_icon()

	playsound(src, pick(whinny_sounds), 50)

	animate(src, pixel_y = 16, time = 1)
	animate(pixel_y = 0, time = 2)

	pass_flags |= PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE

	var/list/rider_original_flags = list()
	for(var/mob/living/rider in buckled_mobs)
		rider_original_flags[rider] = rider.pass_flags
		rider.pass_flags |= PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE

	var/crashed = FALSE
	for(var/i in 1 to jump_distance)
		var/turf/next = get_step(src, dir)
		if(!next)
			break
		if(next.density)
			crash_into_wall(next)
			crashed = TRUE
			break
		var/blocked = FALSE
		for(var/atom/movable/AM in next)
			if(AM.density && !isliving(AM) && \
				!istype(AM, /obj/structure/table) && \
				!istype(AM, /obj/structure/rack) && \
				!istype(AM, /obj/machinery) && \
				!istype(AM, /obj/structure/railing))
				crash_into_wall(AM)
				crashed = TRUE
				blocked = TRUE
				break
		if(blocked)
			break
		var/success = step(src, dir)
		if(!success)
			var/atom/blocker = locate(/atom/movable) in next
			if(!blocker)
				blocker = next
			crash_into_wall(blocker)
			crashed = TRUE
			break

	pass_flags &= ~(PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE)
	for(var/mob/living/rider in buckled_mobs)
		rider.pass_flags = rider_original_flags[rider]

	if(!crashed)
		addtimer(CALLBACK(src, PROC_REF(end_jump)), 3)
	else
		end_jump()

/mob/living/simple_animal/horse/proc/backup_rider_pass_flags()
	rider_pass_backup = list()
	for(var/mob/living/rider in buckled_mobs)
		rider_pass_backup[rider] = rider.pass_flags

/mob/living/simple_animal/horse/proc/restore_rider_pass_flags()
	for(var/mob/living/rider in rider_pass_backup)
		if(!QDELETED(rider))
			rider.pass_flags = rider_pass_backup[rider]
	rider_pass_backup.Cut()

/mob/living/simple_animal/horse/proc/end_jump()
	restore_rider_pass_flags()
	jumping = FALSE
	icon_state = base_icon
	update_icon()

/// crash handler – damage, chance to stun and unbuckle the rider.
/mob/living/simple_animal/horse/proc/crash_into_wall(atom/wall)
	if(!COOLDOWN_FINISHED(src, crash_cooldown))
		return
	COOLDOWN_START(src, crash_cooldown, 2 SECONDS)

	restore_rider_pass_flags()
	visible_message(span_danger("[src] crashes into [wall]!"))
	playsound(src, pick(whinny_sounds), 50)
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	adjustBruteLoss(crash_damage * 0.5)

	for(var/mob/living/rider in buckled_mobs)
		rider.apply_damage(crash_damage, BRUTE)
		if(prob(crash_dismount_chance))
			rider.Paralyze(2 SECONDS)
			rider.Knockdown(4 SECONDS)
			unbuckle_mob(rider)
			rider.visible_message(
				span_danger("[rider] is thrown from [src]!"),
				span_userdanger("You're thrown from [src]!")
			)
		else
			rider.visible_message(
				span_danger("[rider] is jolted violently on [src]!"),
				span_userdanger("You're jolted violently on [src]!")
			)

/// Called when the horse's owner uses a whistle emote.
/mob/living/simple_animal/horse/proc/on_owner_emote(mob/living/user, datum/emote/emote)
	SIGNAL_HANDLER
	if(!istype(emote, /datum/emote/living/whistle))
		return
	if(stat == DEAD || !(mobility_flags & MOBILITY_MOVE))
		return
	// If the owner is already riding, do nothing
	if(length(buckled_mobs) && buckled_mobs[1] == user)
		return
	// If someone else is riding, buck them off
	if(length(buckled_mobs))
		var/mob/living/rider = buckled_mobs[1]
		if(rider != user)
			rider.visible_message(
				span_danger("[src] bucks [rider] off and dashes toward [user]!"),
				span_userdanger("You're thrown off [src] as it races toward [user]!")
			)
			rider.apply_damage(10, BRUTE)
			unbuckle_mob(rider)
			rider.Paralyze(2 SECONDS)
			rider.Knockdown(4 SECONDS)

	if(get_dist(src, user) > 15)
		return
	if(!COOLDOWN_FINISHED(src, whistle_cooldown))
		return
	COOLDOWN_START(src, whistle_cooldown, 5 SECONDS)

	visible_message(span_notice("[src] perks up and trots towards [user]!"))
	playsound(src, pick(whinny_sounds), 50)

	// Speed boost, minimum distance 1 so it stops right next to the owner
	set_varspeed(-2)
	Goto(user, 3, 1)

	whistle_owner = user
	if(whistle_timer)
		deltimer(whistle_timer)
	whistle_timer = addtimer(CALLBACK(src, PROC_REF(stop_whistle_movement)), 8 SECONDS, TIMER_STOPPABLE)

	auto_buckle_check()

/mob/living/simple_animal/horse/proc/auto_buckle_check()
	if(auto_buckle_timer)
		deltimer(auto_buckle_timer)
	if(!whistle_owner || QDELETED(whistle_owner))
		return
	if(get_dist(src, whistle_owner) <= 1 && can_buckle && whistle_owner.Adjacent(src))
		if(!length(buckled_mobs) || buckled_mobs[1] != whistle_owner)
			if(istype(src, /mob/living/simple_animal/horse/syndicate))
				visible_message(
					span_notice("[src] skids to a halt beside [whistle_owner] and, with a powerful whinny, nudges [whistle_owner.p_them()] onto its back!"),
					span_userdanger("[src] throws you onto its back in one swift motion!")
				)
			else
				visible_message(
					span_notice("[src] trots up to [whistle_owner] and patiently waits for [whistle_owner.p_them()] to mount."),
					span_notice("[src] bows its head, inviting you to climb on.")
				)
			buckle_mob(whistle_owner, force = TRUE)
			stop_whistle_movement()
			return
	auto_buckle_timer = addtimer(CALLBACK(src, PROC_REF(auto_buckle_check)), 0.5 SECONDS, TIMER_STOPPABLE)

/mob/living/simple_animal/horse/proc/stop_whistle_movement()
	SSmove_manager.stop_looping(src)
	set_varspeed(normal_speed)
	if(whistle_timer)
		deltimer(whistle_timer)
		whistle_timer = null
	if(auto_buckle_timer)
		deltimer(auto_buckle_timer)
		auto_buckle_timer = null
	whistle_owner = null

/datum/action/horse_jump
	name = "Jump"
	desc = "Leap over obstacles!"
	button_icon_state = "barn"

/datum/action/horse_jump/on_activate(mob/user, atom/target)
	if(!user.buckled || !istype(user.buckled, /mob/living/simple_animal/horse))
		return
	var/mob/living/simple_animal/horse/H = user.buckled
	if(H.jumping)
		return
	if(!COOLDOWN_FINISHED(H, jump_cooldown))
		return
	H.do_jump()

// Syndicate space horse - tougher, spaceproof and worthy
/mob/living/simple_animal/horse/syndicate
	name = "syndicate space horse"
	desc = "A special breed of horse engineered by the syndicate to gallop through the depths of space. A modern outlaw's best friend."
	icon_state = "Horse-Black"
	icon_living = "Horse-Black"
	icon_dead = "Horse-Black-Dead"
	health = 300
	maxHealth = 300
	faction = list("Syndicate")
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0
	unique_tamer = TRUE
	gold_core_spawnable = NO_SPAWN
	trample_damage = 25
	var/charge_trample_threshold = 0.7
	jump_distance = 4
	jump_cooldown_time = 2 SECONDS
	base_icon = "Horse-Black"
	crash_dismount_chance = 30

/mob/living/simple_animal/horse/syndicate/Initialize(mapload)
	. = ..()
	base_icon = "Horse-Black"
	icon_state = "Horse-Black"
	icon_living = "Horse-Black"
	icon_dead = "Horse-Black-Dead"
	name = pick("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
	var/static/list/syndicate_taming_food = list(/obj/item/food/grown/apple)
	AddComponent(/datum/component/tameable, food_types = syndicate_taming_food, tame_chance = 100, bonus_tame_chance = 15, unique = unique_tamer)
	normal_speed = speed

/mob/living/simple_animal/horse/syndicate/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/horse/syndicate/Bump(atom/A)
	if(isliving(A))
		var/mob/living/victim = A
		if(victim in buckled_mobs)
			return ..()
		if(victim.buckled)
			return ..()
		if(!ishuman(victim))
			return ..()
		if(!COOLDOWN_FINISHED(src, trample_cooldown))
			return ..()
		var/is_charging = FALSE
		var/current_speed = 1.0
		var/datum/component/riding/creature/horse/riding_comp = GetComponent(/datum/component/riding/creature/horse)
		if(riding_comp)
			current_speed = riding_comp.current_move_delay
			is_charging = (current_speed <= charge_trample_threshold)
		if(is_charging)
			COOLDOWN_START(src, trample_cooldown, 1 SECONDS)
			victim.apply_damage(trample_damage, BRUTE, BODY_ZONE_CHEST)
			victim.Knockdown(3 SECONDS)
			var/throw_dist = round(4 + (0.7 - current_speed) * 20)
			throw_dist = clamp(throw_dist, 4, 12)
			victim.visible_message(
				span_danger("[victim] is run over by [src] as it charges through, sending [victim.p_them()] flying!"),
				span_userdanger("You're run over by [src] as it charges through you!")
			)
			playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
			var/list/valid_dirs = list(turn(dir, 90), turn(dir, -90))
			var/throw_dir = pick(valid_dirs)
			var/turf/throw_target = get_edge_target_turf(src, throw_dir)
			victim.throw_at(throw_target, throw_dist, 4)
			return
	return ..()

/mob/living/simple_animal/horse/syndicate/Move(atom/newloc, direct)
	. = ..()
	if(.)
		for(var/mob/living/victim in get_turf(src))
			if(victim == src || (victim in buckled_mobs))
				continue
			if(victim.body_position == LYING_DOWN)
				if(!COOLDOWN_FINISHED(src, trample_cooldown))
					continue
				COOLDOWN_START(src, trample_cooldown, 1 SECONDS)
				victim.apply_damage(trample_damage, BRUTE, BODY_ZONE_CHEST)
				victim.visible_message(
					span_danger("[victim] is trampled by [src]!"),
					span_userdanger("You're trampled by [src]!")
				)
				playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

		// Drop dead or critical riders
		check_rider_status()

// ===================== WEAPON JOUSTING INIT =====================

/obj/item/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/pitchfork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/mop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

/obj/item/pushbroom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)
