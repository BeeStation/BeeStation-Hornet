/// The darkness threshold for space dragon when choosing a color
#define REJECT_DARK_COLOUR_THRESHOLD 20

/**
 * # Space Dragon
 *
 * A space-faring leviathan-esque monster which breathes fire and summons carp.  Spawned during its respective midround antagonist event.
 *
 * A space-faring monstrosity who has the ability to breathe dangerous fire breath and uses its powerful wings to knock foes away.
 * Normally spawned as an antagonist during the Space Dragon event, Space Dragon's main goal is to open three rifts from which to pull a great tide of carp onto the station.
 * Space Dragon can summon only one rift at a time, and can do so anywhere a blob is allowed to spawn.  In order to trigger his victory condition, Space Dragon must summon and defend three rifts while they charge.
 * Space Dragon, when spawned, has five minutes to summon the first rift.  Failing to do so will cause Space Dragon to return from whence he came.
 * When the rift spawns, ghosts can interact with it to spawn in as space carp to help complete the mission.  One carp is granted when the rift is first summoned, with an extra one every 30 seconds.
 * Once the victory condition is met, all current rifts become invulnerable to damage, are allowed to spawn infinite sentient space carp, and Space Dragon gets unlimited rage.
 * Alternatively, if the shuttle arrives while Space Dragon is still active, their victory condition will automatically be met and all the rifts will immediately become fully charged.
 * If a charging rift is destroyed, Space Dragon will be incredibly slowed, and the endlag on his gust attack is greatly increased on each use.
 * Space Dragon has the following abilities to assist him with his objective:
 * - Can shoot fire in straight line, dealing 30 burn damage and setting those suseptible on fire.
 * - Can use his wings to temporarily stun and knock back any nearby mobs.  This attack has no cooldown, but instead has endlag after the attack where Space Dragon cannot act.  This endlag's time decreases over time, but is added to every time he uses the move.
 * - Can swallow mob corpses to heal for half their max health.  Any corpses swallowed are stored within him, and will be regurgitated on death.
 * - Can tear through any type of wall.  This takes 4 seconds for most walls, and 12 seconds for reinforced walls.
 */
/mob/living/simple_animal/hostile/space_dragon
	name = "Space Dragon"
	desc = "A vile, leviathan-esque creature that flies in the most unnatural way. Looks slightly similar to a space carp."
	maxHealth = 350
	health = 350
	combat_mode = TRUE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	speed = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	death_sound = 'sound/creatures/space_dragon_roar.ogg'
	icon = 'icons/mob/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	bubble_icon = "spacedragon"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	melee_damage = 35
	mob_size = MOB_SIZE_LARGE
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	armour_penetration = 30
	pixel_x = -16
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	death_message = "screeches as its wings turn to dust and it collapses on the floor, its life estinguished."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list(FACTION_CARP)
	pressure_resistance = 200
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	/// How much endlag using Wing Gust should apply.  Each use of wing gust increments this, and it decreases over time.
	var/tiredness = 0
	/// A multiplier to how much each use of wing gust should add to the tiredness variable.  Set to 5 if the current rift is destroyed.
	var/tiredness_mult = 1
	/// The distance Space Dragon's gust reaches
	var/gust_distance = 3
	/// The amount of tiredness to add to Space Dragon per use of gust
	var/gust_tiredness = 30
	/// Determines whether or not Space Dragon is in the middle of using wing gust.  If set to true, prevents him from moving and doing certain actions.
	var/using_special = FALSE
	/// Determines whether or not Space Dragon is currently tearing through a wall.
	var/tearing_wall = FALSE
	/// Whether space dragon is swallowing a body currently
	var/is_swallowing = FALSE
	/// The cooldown ability to use wing gust
	var/datum/action/gust_attack/gust
	/// The ability to make your sprite smaller
	var/datum/action/small_sprite/space_dragon/small_sprite
	/// The color of the space dragon.
	var/chosen_color
	/// If the dragon is allowed to summon rifts or not
	var/can_summon_rifts = TRUE


/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	gust = new
	gust.Grant(src)
	small_sprite = new
	small_sprite.Grant(src)
	add_traits(list(TRAIT_FREE_HYPERSPACE_MOVEMENT, TRAIT_SPACEWALK), INNATE_TRAIT)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/mob/living/simple_animal/hostile/space_dragon/proc/living_revive(source)
	SIGNAL_HANDLER
	if(!isliving(source))
		return
	var/mob/living/mob = source
	//TODO Componentize this
	if(mob in src)
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		visible_message(span_danger("[src] vomits up [mob]!"))
		mob.forceMove(loc)
		mob.Paralyze(50)
		UnregisterSignal(mob, COMSIG_LIVING_REVIVE)

/mob/living/simple_animal/hostile/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		// Not for use on BeeStation
		//dragon_name()
		color_selection()

/mob/living/simple_animal/hostile/space_dragon/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	tiredness = max(tiredness - (0.5 * delta_time), 0)

/mob/living/simple_animal/hostile/space_dragon/AttackingTarget()
	if(using_special)
		return
	if(target == src)
		to_chat(src, span_warning("You almost bite yourself, but then decide against it."))
		return
	if(istype(target, /turf/closed/wall))
		if(tearing_wall)
			return
		var/turf/closed/wall/thewall = target
		to_chat(src, span_warning("You begin tearing through the wall..."))
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		var/timetotear = 4 SECONDS
		if(istype(target, /turf/closed/wall/r_wall))
			timetotear = 12 SECONDS
		tearing_wall = TRUE
		if(do_after(src, timetotear, target = thewall))
			if(istype(thewall, /turf/open))
				tearing_wall = FALSE
				return
			thewall.dismantle_wall(1)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
		tearing_wall = FALSE
		return
	if(isliving(target)) //Swallows corpses like a snake to regain health.
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(is_swallowing)
				return
			to_chat(src, span_warning("You begin to swallow [L] whole..."))
			is_swallowing = TRUE
			if(do_after(src, 3 SECONDS, target = L))
				RegisterSignal(L, COMSIG_LIVING_REVIVE, PROC_REF(living_revive))
				if(eat(L))
					adjustHealth(-L.maxHealth * 0.5)
			is_swallowing = FALSE
			return
	. = ..()
	if(istype(target, /obj/vehicle/sealed/mecha))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(50, BRUTE, MELEE, 1)

/mob/living/simple_animal/hostile/space_dragon/Move()
	if(!using_special)
		..()

/mob/living/simple_animal/hostile/space_dragon/OpenFire()
	if(using_special)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	fire_stream()

/mob/living/simple_animal/hostile/space_dragon/death(gibbed)
	empty_contents()
	..()
	update_dragon_overlay()

/mob/living/simple_animal/hostile/space_dragon/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	update_dragon_overlay()

/mob/living/simple_animal/hostile/space_dragon/ex_act(severity, target, origin)
	set waitfor = FALSE
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	// Deal with parent operations
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)
	// Run bomb armour
	var/bomb_armor = (100 - getarmor(null, BOMB)) / 100
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(180 * bomb_armor)
		if (EXPLODE_HEAVY)
			adjustBruteLoss(80 * bomb_armor)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30 * bomb_armor)

/**
  * Allows space dragon to choose its own name.
  *
  * Prompts the space dragon to choose a name, which it will then apply to itself.
  * If the name is invalid, will re-prompt the dragon until a proper name is chosen.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_name()
	var/chosen_name = sanitize_name(reject_bad_text(stripped_input(src, "What would you like your name to be?", "Choose Your Name", real_name, MAX_NAME_LEN)))
	if(!chosen_name)
		to_chat(src, span_warning("Not a valid name, please try again."))
		dragon_name()
		return
	to_chat(src, span_notice("Your name is now [span_name("[chosen_name]")], the feared Space Dragon."))
	fully_replace_character_name(null, chosen_name)

/**
  * Allows space dragon to choose a color for itself.
  *
  * Prompts the space dragon to choose a color, from which it will then apply to itself.
  * If an invalid color is given, will re-prompt the dragon until a proper color is chosen.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/color_selection()
	chosen_color = tgui_color_picker(src,"What would you like your color to be?","Choose Your Color", COLOR_WHITE)
	if(!chosen_color) //redo proc until we get a color
		to_chat(src, span_warning("Not a valid color, please try again."))
		color_selection()
		return
	var/list/skin_hsv = rgb2hsv(chosen_color)
	if(skin_hsv[3] < REJECT_DARK_COLOUR_THRESHOLD)
		to_chat(src, span_danger("Invalid color. Your color is not bright enough."))
		color_selection()
		return
	add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)
	update_dragon_overlay()

/**
  * Adds the proper overlay to the space dragon.
  *
  * Clears the current overlay on space dragon and adds a proper one for whatever animation he's in.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/update_dragon_overlay()
	cut_overlays()
	if(small_sprite.small)
		return
	if(stat == DEAD)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_dead")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
	else
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_base")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)

/**
  * Determines a line of turfs from sources's position to the target with length range.
  *
  * Determines a line of turfs from the source's position to the target with length range.
  * The line will extend on past the target if the range is large enough, and not reach the target if range is small enough.
  * Arguments:
  * * offset - whether or not to aim slightly to the left or right of the target
  * * range - how many turfs should we go out for
  * * atom/at - The target
  */
/mob/living/simple_animal/hostile/space_dragon/proc/line_target(offset, range, atom/at = target)
	if(!at)
		return
	var/angle = ATAN2(at.x - src.x, at.y - src.y) + offset
	var/turf/T = get_turf(src)
	for(var/i in 1 to range)
		var/turf/check = locate(src.x + cos(angle) * i, src.y + sin(angle) * i, src.z)
		if(!check)
			break
		T = check
	return (get_line(src, T) - get_turf(src))

/**
  * Spawns fire at each position in a line from the source to the target.
  *
  * Spawns fire at each position in a line from the source to the target.
  * Stops if it comes into contact with a solid wall, a window, or a door.
  * Delays the spawning of each fire by 1.5 deciseconds.
  * Arguments:
  * * atom/at - The target
  */
/mob/living/simple_animal/hostile/space_dragon/proc/fire_stream(atom/at = target)
	playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
	var/range = 20
	var/list/turfs = list()
	turfs = line_target(0, range, at)
	var/delayFire = -1.0
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			return
		for(var/obj/structure/window/W in T.contents)
			return
		for(var/obj/machinery/door/D in T.contents)
			if(D.density)
				return
		delayFire += 1.0
		addtimer(CALLBACK(src, PROC_REF(dragon_fire_line), T), delayFire)

/**
  * What occurs on each tile to actually create the fire.
  *
  * Creates a fire on the given turf.
  * It creates a hotspot on the given turf, damages any living mob with 30 burn damage, and damages mechs by 50.
  * It can only hit any given target once.
  * Arguments:
  * * turf/T - The turf to trigger the effects on.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_fire_line(turf/T)
	var/list/hit_list = list()
	hit_list += src
	new /obj/effect/hotspot/bright(T)
	T.hotspot_expose(700, 50, 1)
	for(var/mob/living/L in T.contents)
		if(L.faction_check_mob(src) && L != src)
			hit_list += L
			start_carp_speedboost(L)
		if(L in hit_list)
			continue
		hit_list += L
		L.adjustFireLoss(30)
		to_chat(L, span_userdanger("You're hit by [src]'s fire breath!"))
	// deals damage to mechs
	for(var/obj/vehicle/sealed/mecha/M in T.contents)
		if(M in hit_list)
			continue
		hit_list += M
		M.take_damage(50, BRUTE, MELEE, 1)

/**
  * Handles consuming and storing consumed things inside Space Dragon
  *
  * Plays a sound and then stores the consumed thing inside Space Dragon.
  * Used in AttackingTarget(), paired with a heal should it succeed.
  * Arguments:
  * * atom/movable/A - The thing being consumed
  */
/mob/living/simple_animal/hostile/space_dragon/proc/eat(atom/movable/A)
	if(A?.loc != src)
		playsound(src, 'sound/magic/demon_attack1.ogg', 100, TRUE)
		visible_message(span_warning("[src] swallows [A] whole!"))
		A.forceMove(src)
		return TRUE
	return FALSE

/**
  * Disperses the contents of the mob on the surrounding tiles.
  *
  * Randomly places the contents of the mob onto surrounding tiles.
  * Has a 10% chance to place on the same tile as the mob.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/empty_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/**
  * Resets Space Dragon's status after using wing gust.
  *
  * Resets Space Dragon's status after using wing gust.
  * If it isn't dead by the time it calls this method, reset the sprite back to the normal living sprite.
  * Also sets the using_special variable to FALSE, allowing Space Dragon to move and attack freely again.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/reset_status()
	if(stat != DEAD)
		icon_state = "spacedragon"
	using_special = FALSE
	update_dragon_overlay()

/**
 * Applies the speed boost to carps when hit by space dragon's flame breath
 *
 * Applies the dragon rage effect to carps temporarily, giving them a glow and a speed boost.
 * This lasts for 8 seconds.
 * Arguments:
 * * mob/living/target - The carp being affected.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/start_carp_speedboost(mob/living/target)
	target.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 2))
	target.add_movespeed_modifier(/datum/movespeed_modifier/rift_empowerment)
	addtimer(CALLBACK(src, PROC_REF(end_carp_speedboost), target), 8 SECONDS)
/**
 * Remove the speed boost from carps when hit by space dragon's flame breath
 *
 * Removes the dragon rage effect from carps, removing their glow and speed boost.
 * Arguments:
 * * mob/living/target - The carp being affected.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/end_carp_speedboost(mob/living/target)
	target.remove_filter("anger_glow")
	target.remove_movespeed_modifier(/datum/movespeed_modifier/rift_empowerment)

/**
 * Handles wing gust from the windup all the way to the endlag at the end.
 *
 * Handles the wing gust attack from start to finish, based on the timer.
 * After animate, trigger the attack.  Change Space Dragon's sprite and push all living creatures back in a 3 tile radius and stun them for 5 seconds.
 * Stay in the ending state for how much our tiredness dictates and add to our tiredness.
 * Arguments:
 * * animate - If this is the animation cycle or not.
 */
/mob/living/simple_animal/hostile/space_dragon/proc/useGust(animate = TRUE)
	if(animate)
		animate(src, pixel_y = 20, time = 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(useGust), FALSE), 1.2 SECONDS)
		return
	pixel_y = 0
	if(!small_sprite.small)
		icon_state = "spacedragon_gust_2"
		cut_overlays()
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust_2")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/list/candidates_flung = list()
	for (var/turf/epicenter in view(1, usr.loc))
		if(istype(epicenter, /turf/closed)) //Gusts dont go through walls.
			continue
		for (var/mob/living/mob in view(gust_distance, epicenter))
			if(mob == src || mob.faction_check_mob(src))
				continue
			candidates_flung |= mob

	for(var/mob/living/candidate in candidates_flung)
		visible_message(span_boldwarning("[candidate] is knocked back by the gust!"))
		to_chat(candidate, span_userdanger("You're knocked back by the gust!"))
		var/dir_to_target = get_dir(get_turf(src), get_turf(candidate))
		var/throwtarget = get_edge_target_turf(candidate, dir_to_target)
		candidate.safe_throw_at(throwtarget, 10, 1, src)
		candidate.Paralyze(50)
	addtimer(CALLBACK(src, PROC_REF(reset_status)), 4 + ((tiredness * tiredness_mult) / 10))
	tiredness = tiredness + (gust_tiredness * tiredness_mult)

/mob/living/proc/carp_talk(message, shown_name = real_name)
	message = trim(message)
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = treat_message_min(message)
	log_talk(message, LOG_SAY)
	var/message_a = say_quote(message)
	var/valid_span_class = "srt_radio carpspeak"
	if(istype(src, /mob/living/simple_animal/hostile/space_dragon))
		valid_span_class += " big"
	var/rendered = "<span class='[valid_span_class]'>Carp Wavespeak [span_name(shown_name)] [span_message(message_a)]</span>"
	for(var/mob/S in GLOB.player_list)
		if(!S.stat && ("carp" in S.faction))
			to_chat(S, rendered)
		if(S in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(S, src)
			to_chat(S, "[link] [rendered]")

/datum/action/gust_attack
	name = "Gust Attack"
	desc = "Use your wings to knock back foes with gusts of air, pushing them away and stunning them. Using this too often will leave you vulnerable for longer periods of time."
	background_icon_state = "bg_default"
	button_icon = 'icons/hud/actions/actions_space_dragon.dmi'
	button_icon_state = "gust_attack"
	cooldown_time = 5 SECONDS // the ability takes up around 2-3 seconds

/datum/action/gust_attack/is_available()
	return ..() && istype(owner, /mob/living/simple_animal/hostile/space_dragon)

/datum/action/gust_attack/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return FALSE
	S.using_special = TRUE
	S.icon_state = "spacedragon_gust"
	S.update_dragon_overlay()
	S.useGust(TRUE)
	start_cooldown()
	return TRUE

#undef REJECT_DARK_COLOUR_THRESHOLD
