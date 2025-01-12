/obj/structure/vampire
	///Who owns this structure?
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
		. += "<span class='cult'>[ghost_desc]</span>"
	if(IS_VAMPIRE(user) && vampire_desc)
		if(!owner)
			. += "<span class='cult'>It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential</span>"
			return
		. += "<span class='cult'>[vampire_desc]</span>"
	if(IS_VASSAL(user) && vassal_desc)
		. += "<span class='cult'>[vassal_desc]</span>"
	if(IS_CURATOR(user) && curator_desc)
		. += "<span class='cult'>[curator_desc]</span>"

/// This handles bolting down the structure.
/obj/structure/vampire/proc/bolt(mob/user)
	to_chat(user, "<span class='danger'>You have secured [src] in place.</span>")
	to_chat(user, "<span class='announce'>* Vampire Tip: Examine [src] to understand how it functions!</span>")
	user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(TRUE)
	owner = user

/// This handles unbolting of the structure.
/obj/structure/vampire/proc/unbolt(mob/user)
	to_chat(user, "<span class='danger'>You have unsecured [src].</span>")
	user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(FALSE)
	owner = null

/obj/structure/vampire/attackby(obj/item/item, mob/living/user, params)
	/// If a Vampire tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_VAMPIRE(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, "<span class='announce'>* Vampire Tip: Examine Vampire structures to understand how they function!</span>")
		return
	return ..()

/obj/structure/vampire/attack_hand(mob/user, list/modifiers)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	/// Claiming the Rack instead of using it?
	if(vampiredatum && !owner)
		if(!vampiredatum.vampire_lair_area)
			to_chat(user, "<span class='danger'>You don't have a lair. Claim a coffin to make that location your lair.</span>")
			return FALSE
		if(vampiredatum.vampire_lair_area != get_area(src))
			to_chat(user, "<span class='danger'>You may only activate this structure in your lair: [vampiredatum.vampire_lair_area].</span>")
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, "<span class='notice'>Do you wish to secure [src] here?</span>")
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
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Click on the persuasion rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack while not on help intent.\n\
		The conversion time is decreased depending on how sharp the tool in you offhand is, if you have one.\n\
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
		to_chat(user, "<span class='danger'>Until this rack is secured in place, it cannot serve its purpose.</span>")
		to_chat(user, "<span class='announce'>* Vampire Tip: Examine the Persuasion Rack to understand how it functions!</span>")
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, "<span class='danger'>You realize that this machine cannot be vassalized, therefore it is useless to buckle them.</span>")
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
		"<span class='notice'>[user] straps [target] into the rack, immobilizing them.</span>",
		"<span class='boldnotice'>You secure [target] tightly in place. They won't escape you now.</span>",
	)

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
			"<span class='danger'>[user] tries to release themself from the rack!</span>",
			"<span class='danger'>You attempt to release yourself from the rack!</span>",
			"<span class='hear'>You hear a squishy wet noise.</span>",
		)
		if(!do_after(user, 20 SECONDS, buckled_mob))
			return
	else
		buckled_mob.visible_message(
			"<span class='danger'>[user] tries to pull [buckled_mob] from the rack!</span>",
			"<span class='danger'>You attempt to release [buckled_mob] from the rack!</span>",
			"<span class='hear'>You hear a squishy wet noise.</span>",
		)
		if(!do_after(user, 10 SECONDS, buckled_mob))
			return

	return ..()

/obj/structure/vampire/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(!..())
		return FALSE
	visible_message("<span class='danger'>[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack.</span>")
	buckled_mob.Paralyze(2 SECONDS)
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/vampire/vassalrack/attack_hand(mob/user, list/modifiers)
	..()
	if(!has_buckled_mobs())
		return FALSE

	var/datum/antagonist/vassal/vampiredatum = IS_VAMPIRE(user)
	// Try Unbuckle
	var/mob/living/carbon/buckled_person = pick(buckled_mobs)
	if(user.a_intent == INTENT_HELP)
		if(vampiredatum)
			unbuckle_mob(buckled_person)
			return FALSE
		else
			user_unbuckle_mob(buckled_person, user)
			return

	// Try to interact with vassal
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_person)
	if(vassaldatum?.master == vampiredatum)
		SEND_SIGNAL(vampiredatum, VAMPIRE_INTERACT_WITH_VASSAL, vassaldatum)
		return

	torture_victim(user, buckled_person)

/**
 * Torture steps:
 *
 * * When convert_progress reaches 0, the victim is ready to be converted
 * * Using a better tool will reduce the time required to torture
 * * If the victim has a mindshield or is an antagonist, they must accept the conversion. If they don't accept, they aren't converted
 * * Vassalize target
 */
/obj/structure/vampire/vassalrack/proc/torture_victim(mob/living/user, mob/living/target)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)

	if(!vampiredatum.can_make_vassal(target) || is_torturing)
		return

	// These if statements can be simplified but aren't for better code-readability.
	if(convert_progress > 0)
		balloon_alert(user, "spilling blood...")

		is_torturing = TRUE
		target.Paralyze(1 SECONDS)
		vampiredatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		if(!do_torture(user, target))
			is_torturing = FALSE
			return
		is_torturing = FALSE

		vampiredatum.AddBloodVolume(-TORTURE_BLOOD_HALF_COST)
		convert_progress--

		if(convert_progress > 0)
			balloon_alert(user, "needs more persuasion...")
			return

		// If the victim is mindshielded or an antagonist, they choose to accept or refuse vassilization.
		if(!wants_vassilization && (HAS_TRAIT(target, TRAIT_MINDSHIELD) || length(target.mind.antag_datums)))
			balloon_alert(user, "has external loyalties! more persuasion required!")
			if(!ask_for_vassilization(user, target))
				balloon_alert(user, "refused persuasion!")
				convert_progress++
				return

		balloon_alert(user, "ready for communion!")
	if(wants_vassilization || !(HAS_TRAIT(target, TRAIT_MINDSHIELD) || length(target.mind.antag_datums)))
		user.balloon_alert_to_viewers("smears blood...", "paints bloody marks...")
		if(!do_after(user, 5 SECONDS, target))
			balloon_alert(user, "interrupted!")
			return
		vampiredatum.AddBloodVolume(-TORTURE_CONVERSION_COST)

		vampiredatum.make_vassal(target)
		// Find Mind Implant & Destroy
		for(var/obj/item/implant/implant as anything in target.implants)
			if(istype(implant, /obj/item/implant/mindshield))
				implant.Destroy()
		SEND_SIGNAL(vampiredatum, VAMPIRE_MADE_VASSAL, user, target)

/obj/structure/vampire/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target)
	var/obj/item/held_item = user.get_inactive_held_item()
	var/torture_time = 15
	torture_time -= held_item?.force / 4
	torture_time -= held_item?.sharpness + 1

	// Minimum 5 seconds
	torture_time = max(5 SECONDS, torture_time SECONDS)
	if(do_after(user, torture_time, target))
		held_item?.play_tool_sound(target)

		var/obj/item/bodypart/selected_bodypart = pick(target.bodyparts)
		target.visible_message(
			"<span class='danger'>[user] performs a ritual, spilling some of [target]'s blood from their [selected_bodypart.name]!</span>",
			"<span class='userdanger'>[user] performs a ritual, spilling some blood from your [selected_bodypart.name]!</span>")

		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
		target.Jitter(5 SECONDS)
		target.apply_damage(held_item ? held_item.force / 4 : 2, held_item ? held_item.damtype : BRUTE, selected_bodypart)
		return TRUE
	else
		balloon_alert(user, "interrupted!")
		return FALSE

/// Offer them the oppertunity to join now.
/obj/structure/vampire/vassalrack/proc/ask_for_vassilization(mob/living/user, mob/living/target)
	if(vassilization_offered)
		return FALSE
	vassilization_offered = TRUE

	to_chat(user, "<span class='notice'>[target] has been given the opportunity for servitude. You await their decision...</span>")
	var/alert_response = tgui_alert(
		user = target, \
		message = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]? \n\
			You will not lose your current objectives, but they come second to the will of your new master!", \
		title = "THE HORRIBLE PAIN! WHEN WILL IT END?!",
		buttons = list("Accept", "Refuse"),
		timeout = 10 SECONDS, \
		autofocus = TRUE
	)
	if(alert_response == "Accept")
		wants_vassilization = TRUE
	else
		target.balloon_alert_to_viewers("stares defiantly", "refused vassalization!")
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
	ghost_desc = "This is a magical candle which drains at the sanity of non Vampires and Vassals.\n\
		Vassals can turn the candle on manually, while Vampires can do it from a distance."
	vampire_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.\n\
		You can right-click on it from any range to turn it on remotely, or simply be next to it and click on it to turn it on and off normally."
	vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n\
		You can turn it on and off by clicking on it while you are next to it."
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
		nearby_people.hallucination += 5 SECONDS
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
		to_chat(user, "<span class='announce'>[src] is not bolted to the ground!</span>")
		return
	density = FALSE
	. = ..()
	density = TRUE
	user.visible_message(
		"<span class='notice'>[user] sits down on [src].</span>",
		"<span class='boldnotice'>You sit down onto [src].</span>",
	)
	if(IS_VAMPIRE(user))
		RegisterSignal(user, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		unbuckle_mob(user)
		user.Paralyze(10 SECONDS)
		to_chat(user, "<span class='cult'>The power of the blood throne overwhelms you!</span>")

/obj/structure/vampire/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/vampire/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	src.visible_message("<span class='danger'>[user] unbuckles themselves from [src].</span>")
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
	var/rendered = "<span class='cultlarge'><b>[user.real_name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag = ROLE_VAMPIRE)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	for(var/datum/antagonist/vassal/receiver as anything in vampiredatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered)
	to_chat(user, rendered)

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""
