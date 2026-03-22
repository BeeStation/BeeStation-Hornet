/obj/structure/vampire
	/// Who owns this structure?
	var/mob/living/owner
	/*
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/ghost_desc
	var/vampire_desc
	var/vassal_desc
	var/curator_desc

/obj/structure/vampire/examine(mob/user)
	. = ..()
	if(!user.mind && ghost_desc)
		. += span_cult(ghost_desc)
	if(IS_VAMPIRE(user) && vampire_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential")
			return
		. += span_cult(vampire_desc)
	if(IS_VASSAL(user) && vassal_desc)
		. += span_cult(vassal_desc)
	if(IS_CURATOR(user) && curator_desc)
		. += span_cult(curator_desc)

/// This handles bolting down the structure.
/obj/structure/vampire/proc/bolt(mob/user)
	if(!user)
		return
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Vampire Tip: Examine [src] to understand how it functions!"))
	user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(TRUE)
	owner = user

/// This handles unbolting of the structure.
/obj/structure/vampire/proc/unbolt(mob/user)
	if(user)
		to_chat(user, span_danger("You have unsecured [src]."))
		user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(FALSE)
	owner = null

/obj/structure/vampire/attackby(obj/item/item, mob/living/user, params)
	/// If a Vampire tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_VAMPIRE(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Vampire Tip: Examine Vampire structures to understand how they function!"))
		return
	return ..()

/obj/structure/vampire/attack_hand(mob/user, list/modifiers)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	/// Claiming the Rack instead of using it?
	if(vampiredatum && !owner)
		if(!vampiredatum.vampire_lair_area)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(vampiredatum.vampire_lair_area != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [vampiredatum.vampire_lair_area]."))
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, span_notice("Do you wish to secure [src] here?"))
		var/static/list/secure_options = list(
			"Yes" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_no"))
		var/secure_response = show_radial_menu(user, src, secure_options, radius = 36, require_near = TRUE)
		if(secure_response == "Yes")
			bolt(user)
		return FALSE
	return TRUE

/obj/structure/vampire/AltClick(mob/user)
	. = ..()
	if(user == owner && user.Adjacent(src))
		balloon_alert(user, "unbolt [src]?")
		var/static/list/unsecure_options = list(
			"Yes" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_no"),
		)
		var/unsecure_response = show_radial_menu(user, src, unsecure_options, radius = 36, require_near = TRUE)
		if(unsecure_response == "Yes")
			unbolt(user)

/obj/structure/vampire/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	ghost_desc = "This is a Vassal rack, which allows Vampires to thrall crewmembers into loyal minions."
	vampire_desc = "This is the Vassal rack, which allows you to thrall crewmembers into loyal minions in your service. This costs blood to do.\n\
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Right-click on the persuasion rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack. The time required scales with the tool in your hand.\n\
		Vassals can be turned into special ones by continuing to torture them once converted."
	vassal_desc = "This is the vassal rack, which allows your master to thrall crewmembers into their minions.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassal rack by click dragging the victim onto the rack while it is secured."
	curator_desc = "This is the vassal rack, which monsters use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt it."

	/// How many times a buckled person has to be tortured to be converted.
	var/convert_progress = 3
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/wants_vassilization = FALSE
	/// Prevents popup spam.
	var/vassilization_offered = FALSE
	/// No spamming torture
	var/is_torturing = FALSE

/obj/structure/vampire/vassalrack/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/iron(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/vampire/vassalrack/MouseDrop_T(atom/movable/movable_atom, mob/user)
	var/mob/living/living_target = movable_atom
	if(!anchored && IS_VAMPIRE(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Vampire Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that this machine cannot be vassalized, therefore it is useless to buckle them."))
		return
	if(do_after(user, 5 SECONDS, living_target))
		density = FALSE // Temporarily set density to false so the target is actually on the rack
		attach_victim(living_target, user)
		density = TRUE

/**
 * Attempts to buckle target into the vassalrack
 */
/obj/structure/vampire/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing them."),
		span_boldnotice("You secure [target] tightly in place. They won't escape you now."))

	playsound(loc, 'sound/effects/pop_expl.ogg', 25, 1)
	update_appearance(UPDATE_ICON)

	// Set up Torture stuff now
	convert_progress = 3
	wants_vassilization = FALSE
	vassilization_offered = FALSE

/// Attempt Unbuckle
/obj/structure/vampire/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(IS_VAMPIRE(user) || IS_VASSAL(user))
		return ..()

	if(buckled_mob == user)
		buckled_mob.visible_message(
			span_danger("[user] tries to release themself from the rack!"),
			span_danger("You attempt to release yourself from the rack!"),
			span_hear("You hear a squishy wet noise."),
		)
		if(!do_after(user, 20 SECONDS, buckled_mob))
			return FALSE
	else
		buckled_mob.visible_message(
			span_danger("[user] tries to pull [buckled_mob] from the rack!"),
			span_danger("You attempt to release [buckled_mob] from the rack!"),
			span_hear("You hear a squishy wet noise."),
		)
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return FALSE

	return ..()

/obj/structure/vampire/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE)
	. = ..()
	if(!.)
		return FALSE

	visible_message(span_danger("[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	buckled_mob.Paralyze(2 SECONDS)
	update_appearance(UPDATE_ICON)

/obj/structure/vampire/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!. || !has_buckled_mobs())
		return FALSE

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	var/mob/living/carbon/buckled_person = pick(buckled_mobs)

	// oh no let me free this poor soul
	if(!vampiredatum)
		user_unbuckle_mob(buckled_person, user)
		return TRUE

	// Try to interact with vassal
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_person)
	if(vassaldatum?.master == vampiredatum)
		vampiredatum.my_clan?.interact_with_vassal(vassaldatum)
		return TRUE

	var/obj/item/held_item = user.get_inactive_held_item()
	try_to_torture(user, buckled_person, held_item)

/obj/structure/vampire/vassalrack/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!has_buckled_mobs() || !isliving(user))
		return
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(buckled_carbons)
		if(user == owner)
			unbuckle_mob(buckled_carbons)
		else
			user_unbuckle_mob(buckled_carbons, user)

/obj/structure/vampire/vassalrack/attackby(obj/item/attacking_item, mob/living/user, params)
	if(IS_VAMPIRE(user) && has_buckled_mobs() && !user.combat_mode)
		return try_to_torture(user, pick(buckled_mobs), attacking_item)
	return ..()

/**
 * Torture steps:
 *
 * * When convert_progress reaches 0, the victim is ready to be converted
 * * Using a better tool will reduce the time required to torture
 * * If the victim has a mindshield or is an antagonist, they must accept the conversion. If they don't accept, they aren't converted
 * * Vassalize target
 */
/obj/structure/vampire/vassalrack/proc/try_to_torture(mob/living/living_vampire, mob/living/living_target, obj/item/held_item)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(living_vampire)

	if(!vampiredatum.can_make_vassal(living_target) || is_torturing)
		return

	// These if statements can be simplified but aren't for better code-readability.
	if(convert_progress > 0)
		balloon_alert(living_vampire, "spilling blood...")

		is_torturing = TRUE
		living_target.Paralyze(1 SECONDS)
		vampiredatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)

		if(!do_torture(living_vampire, living_target, held_item))
			is_torturing = FALSE
			return
		is_torturing = FALSE

		vampiredatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		convert_progress--

		if(convert_progress > 0)
			balloon_alert(living_vampire, "needs more persuasion...")
			return

		// If the victim is mindshielded or an antagonist, they choose to accept or refuse vassilization.
		if(!wants_vassilization && (HAS_TRAIT(living_target, TRAIT_MINDSHIELD) || length(living_target.mind.antag_datums)))
			// Check if our target is our brujah clan objective
			if(istype(vampiredatum.my_clan, /datum/vampire_clan/brujah) && vampiredatum.my_clan.clan_objective.target == living_target.mind)
				balloon_alert(living_vampire, "ready for communion!")
				wants_vassilization = TRUE
				return

			balloon_alert(living_vampire, "has external loyalties! more persuasion required!")
			if(!ask_for_vassilization(living_vampire, living_target))
				balloon_alert(living_vampire, "refused persuasion!")
				convert_progress++
				return

		balloon_alert(living_vampire, "ready for communion!")
		return

	if(wants_vassilization || !(HAS_TRAIT(living_target, TRAIT_MINDSHIELD) || length(living_target.mind.antag_datums)))
		living_vampire.balloon_alert_to_viewers("smears blood...", "paints bloody marks...")
		if(!do_after(living_vampire, 5 SECONDS, living_target))
			balloon_alert(living_vampire, "interrupted!")
			return

		// Make our target into a vassal
		vampiredatum.AddBloodVolume(-TORTURE_CONVERSION_COST)
		vampiredatum.make_vassal(living_target)

		// Find Mind Implant & Destroy
		for(var/obj/item/implant/mindshield/mindshield in living_target.implants)
			mindshield.Destroy()

		// We've made a vassal the proper way, do clan stuff
		vampiredatum.my_clan?.on_vassal_made(living_vampire, living_target)

/obj/structure/vampire/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, obj/item/held_item)
	var/torture_time = 15
	torture_time -= held_item?.force / 4
	torture_time -= held_item?.sharpness + 1

	// Minimum 5 seconds
	torture_time = max(5 SECONDS, torture_time SECONDS)
	if(do_after(user, torture_time, target))
		held_item?.play_tool_sound(target)

		var/obj/item/bodypart/selected_bodypart = pick(target.bodyparts)
		target.visible_message(
			span_danger("[user] performs a ritual, spilling some of [target]'s blood from their [selected_bodypart.name]!"),
			span_userdanger("[user] performs a ritual, spilling some blood from your [selected_bodypart.name]!"))

		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
		target.set_jitter_if_lower(10 SECONDS)
		target.apply_damage(held_item ? held_item.force / 4 : 2, held_item ? held_item.damtype : BRUTE, selected_bodypart)
		return TRUE
	else
		balloon_alert(user, "interrupted!")
		return FALSE

/// Offer them the oppertunity to join now.
/obj/structure/vampire/vassalrack/proc/ask_for_vassilization(mob/living/user, mob/living/target)
	if(vassilization_offered)
		balloon_alert(user, "wait a moment!")
		return FALSE
	vassilization_offered = TRUE

	to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await their decision..."))
	var/alert_response = tgui_alert(
		user = target, \
		message = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]? \n\
			You will not lose your current objectives, but they come second to the will of your new master!", \
		title = "THE HORRIBLE PAIN! WHEN WILL IT END?!",
		buttons = list("Accept", "Refuse"),
		timeout = 15 SECONDS, \
		autofocus = TRUE
	)
	if(alert_response == "Accept")
		wants_vassilization = TRUE
	else
		target.balloon_alert_to_viewers("refused vassalization!")

	vassilization_offered = FALSE

	return wants_vassilization

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/vampire/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "candelabrum"
	light_color = "#66FFFF"
	light_power = 3
	density = FALSE
	can_buckle = TRUE
	anchored = FALSE
	ghost_desc = "This is a magical candle which drains at the sanity of non Vampires and Vassals."
	vampire_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active."
	vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master."
	curator_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/vampire/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/vampire/candelabrum/update_icon_state()
	icon_state = "candelabrum[lit ? "_lit" : ""]"
	return ..()

/obj/structure/vampire/candelabrum/bolt()
	density = TRUE
	return ..()

/obj/structure/vampire/candelabrum/unbolt()
	density = FALSE
	return ..()

/obj/structure/vampire/candelabrum/attack_hand(mob/living/user, list/modifiers)
	if(!..())
		return
	if(anchored && (IS_VASSAL(user) || IS_VAMPIRE(user)))
		toggle()
	return ..()

/obj/structure/vampire/candelabrum/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		desc = initial(desc)
		set_light(l_range = 2, l_power = 3, l_color = "#66FFFF")
		START_PROCESSING(SSobj, src)
	else
		desc = "Despite not being lit, it makes your skin crawl."
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/vampire/candelabrum/process()
	if(!lit)
		return
	for(var/mob/living/carbon/nearby_people in viewers(7, src))
		/// We dont want Vampires or Vassals affected by this
		if(IS_VASSAL(nearby_people) || IS_VAMPIRE(nearby_people) || IS_CURATOR(nearby_people))
			continue
		nearby_people.adjust_hallucinations(10 SECONDS)
		SEND_SIGNAL(nearby_people, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)

/// Blood Throne - Allows Vampires to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/vampire/bloodthrone
	name = "blood throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'icons/vampires/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	ghost_desc = "This is a blood throne, any Vampire sitting on it can remotely speak to their Vassals by attempting to speak aloud."
	vampire_desc = "This is a blood throne, sitting on it will allow you to telepathically speak to your vassals by simply speaking."
	vassal_desc = "This is a blood throne, it allows your Master to telepathically speak to you and others like you."
	curator_desc = "This is a chair that hurts those that try to buckle themselves onto it, though the Undead have no problem latching on.\n\
		While buckled, Monsters can use this to telepathically communicate with eachother."
	var/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/vampire/bloodthrone/Initialize(mapload)
	AddComponent(/datum/component/simple_rotation)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/vampire/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

// Armrests
/obj/structure/vampire/bloodthrone/proc/GetArmrest()
	return mutable_appearance('icons/vampires/vamp_obj_64.dmi', "thronearm")

/obj/structure/vampire/bloodthrone/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

// Rotating
/obj/structure/vampire/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/vampire/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	density = FALSE
	. = ..()
	density = TRUE
	user.visible_message(
		span_notice("[user] sits down on \the [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_VAMPIRE(user))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		unbuckle_mob(user)
		user.Paralyze(10 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))

/obj/structure/vampire/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/vampire/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	visible_message(span_danger("[user] unbuckles [user.p_them()]self from \the [src]."))
	if(IS_VAMPIRE(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	. = ..()

/obj/structure/vampire/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 2

// The speech itself
/obj/structure/vampire/bloodthrone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag = ROLE_VAMPIRE)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	for(var/datum/antagonist/vassal/receiver as anything in vampiredatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered, type = MESSAGE_TYPE_RADIO)
	to_chat(user, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]", type = MESSAGE_TYPE_RADIO)

	speech_args[SPEECH_MESSAGE] = ""
