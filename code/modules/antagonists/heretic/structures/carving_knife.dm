// The rune carver, a heretic knife that can draw rune traps.
/obj/item/melee/rune_carver
	name = "carving knife"
	desc = "A small knife made of cold steel, pure and perfect. Its sharpness can carve into plastitanium itself - \
		but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/heretic.dmi'
	icon_state = "rune_carver"
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	throwforce = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	actions_types = list(/datum/action/item_action/rune_shatter)
	embedding = list(
		ignore_throwspeed_threshold = TRUE,
		embed_chance = 75,
		jostle_chance = 2,
		jostle_pain_mult = 5,
		pain_stam_pct = 0.4,
		pain_mult = 3,
		rip_time = 15,
	)

	/// Whether we're currently drawing a rune
	var/drawing = FALSE
	/// Max amount of runes that can be drawn
	var/max_rune_amt = 10
	/// A list of weakrefs to all of ourc urrent runes
	var/list/datum/weakref/current_runes = list()
	/// Turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava))

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += "<span class='notice'><b>[length(current_runes)] / [max_rune_amt]</b> total carvings have been drawn.</span>"
	. += "<span class='info'>The following runes can be carved:</span>"
	for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
		var/potion_string = "<span class='info'>\tThe " + initial(trap.name) + " - " + initial(trap.carver_tip) + "</span>"
		. += potion_string

/obj/item/melee/rune_carver/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(!IS_HERETIC_OR_MONSTER(user))
		return

	if(!isopenturf(target))
		return

	if(is_type_in_typecache(target, blacklisted_turfs))
		return

	INVOKE_ASYNC(src, PROC_REF(try_carve_rune), target, user)

/*
 * Begin trying to carve a rune. Go through a few checks, then call do_carve_rune if successful.
 */
/obj/item/melee/rune_carver/proc/try_carve_rune(turf/open/target_turf, mob/user)
	if(drawing)
		target_turf.balloon_alert(user, "Already carving")
		return

	if(locate(/obj/structure/trap/eldritch) in range(1, target_turf))
		target_turf.balloon_alert(user, "Too close to another carving")
		return

	for(var/datum/weakref/rune_ref as anything in current_runes)
		if(!rune_ref?.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		target_turf.balloon_alert(user, "Too many carvings")
		return

	drawing = TRUE
	do_carve_rune(target_turf, user)
	drawing = FALSE

/*
 * The actual proc that handles selecting the rune to draw and creating it.
 */
/obj/item/melee/rune_carver/proc/do_carve_rune(turf/open/target_turf, mob/user)
	// Assoc list of [name] to [image] for the radial (to show tooltips)
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
			names_to_path[initial(trap.name)] = trap
			choices[initial(trap.name)] = image(icon = initial(trap.icon), icon_state = initial(trap.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		target_turf,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/to_make = names_to_path[picked_choice]
	if(!ispath(to_make, /obj/structure/trap/eldritch))
		CRASH("[type] attempted to create a rune of incorrect type! (got: [to_make])")

	target_turf.balloon_alert(user, "You begin carving the [picked_choice]")
	user.playsound_local(target_turf, 'sound/items/sheath.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, target = target_turf))
		target_turf.balloon_alert(user, "Interrupted")
		return

	target_turf.balloon_alert(user, "[picked_choice] carved")
	var/obj/structure/trap/eldritch/new_rune = new to_make(target_turf, user)
	current_runes += WEAKREF(new_rune)

/datum/action/item_action/rune_shatter
	name = "Rune Break"
	desc = "Destroys all runes carved by this blade."
	background_icon_state = "bg_ecult"
	button_icon_state = "rune_break"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'

/datum/action/item_action/rune_shatter/New(Target)
	. = ..()
	if(!istype(Target, /obj/item/melee/rune_carver))
		qdel(src)
		return

/datum/action/item_action/rune_shatter/Grant(mob/granted)
	if(!IS_HERETIC_OR_MONSTER(granted))
		return

	return ..()

/datum/action/item_action/rune_shatter/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	var/obj/item/melee/rune_carver/target_sword = target
	if(!length(target_sword.current_runes))
		return FALSE

/datum/action/item_action/rune_shatter/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.playsound_local(get_turf(owner), 'sound/magic/blind.ogg', 50, TRUE)
	var/obj/item/melee/rune_carver/target_sword = target
	QDEL_LIST(target_sword.current_runes)
	target_sword.SpinAnimation(5, 1)
	return TRUE

// The actual rune traps the knife draws.
/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "A collection of unknown symbols, they remind you of days long gone..."
	icon = 'icons/obj/heretic.dmi'
	/// A tip displayed to heretics who examine the rune carver. Explains what the rune does.
	var/carver_tip
	/// Reference to trap owner mob
	var/datum/weakref/owner

/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(new_owner)
		owner = WEAKREF(new_owner)

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return ..()
	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/weapon, mob/living/user)
	if(istype(weapon, /obj/item/melee/rune_carver) || istype(weapon, /obj/item/nullrod))
		loc.balloon_alert(user, "Carving dispelled")
		playsound(src, 'sound/items/sheath.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
		qdel(src)

	return ..()

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10
	time_between_triggers = 5 SECONDS
	sparks = FALSE
	carver_tip = "A nearly invisible rune that, when stepped on, alerts the carver as to who triggered it and where."

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(real_owner)
		to_chat(real_owner, "<span class='userdanger'>[victim.real_name] has stepped on the alert rune in [get_area(src)]!</span>")
		real_owner.playsound_local(get_turf(real_owner), 'sound/magic/curse.ogg', 50, TRUE)

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"
	time_between_triggers = 45 SECONDS
	charges = 1
	carver_tip = "When stepped on, causes heavy leg damage and stuns the victim for 5 seconds. Has 1 charge."

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"
	time_between_triggers = 20 SECONDS
	charges = 2
	carver_tip = "When stepped on, adds heavy stamina damage, blindness, and a variety of ailments to the victim. Has 2 charges."

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.adjustStaminaLoss(80)
	carbon_victim.silent += 10
	carbon_victim.stuttering += 30
	carbon_victim.Jitter(10)
	carbon_victim.Dizzy(20)
	carbon_victim.adjust_blindness(2)
	SEND_SIGNAL(carbon_victim, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	playsound(src, 'sound/magic/blind.ogg', 75, TRUE)
