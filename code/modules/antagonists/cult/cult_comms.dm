// Contains cult communion, guide, and cult master abilities

/datum/action/innate/cult
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	button_icon_state = null
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

/datum/action/innate/cult/is_available()
	if(!IS_CULTIST(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/comm/on_activate()
	var/input = tgui_input_text(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !is_available())
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, span_warning("You cannot send a message that contains a word prohibited in IC chat!"))
		return
	cultist_commune(usr, input)

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common)
	user.whisper(html_decode(message))
	var/title = "Acolyte"
	var/span = "srt_radio cult italic"
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/cult/master))
		span = "cultlarge"
		title = "Master"
	else if(!ishuman(user))
		title = "Construct"
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = user.treat_message_min(message)
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_CULTIST(M))
			to_chat(M, my_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = M == user)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]", type = MESSAGE_TYPE_RADIO)

	user.log_talk(message, LOG_SAY, tag="blood cult")

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/is_available()
	if(IS_CULTIST(owner.mind.current))
		return TRUE

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = "[span_srtradiocultboldtalic("The [user.name]: [message]")]"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(IS_CULTIST(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

/datum/action/innate/cult/mastervote
	name = "Assert Leadership"
	button_icon_state = "cultvote"

/datum/action/innate/cult/mastervote/is_available()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C || C.cult_team.cult_vote_called || !ishuman(owner))
		return FALSE
	return ..()

/datum/action/innate/cult/mastervote/on_activate()
	var/choice = tgui_alert(owner, "The mantle of leadership is heavy. Success in this role requires an expert level of communication and experience. Are you sure?",, list("Yes", "No"))
	if(choice == "Yes" && is_available())
		var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
		pollCultists(owner,C.cult_team)

/proc/pollCultists(mob/living/nominee, datum/team/cult/team) //Cult Master Poll
	if(world.time < CULT_POLL_WAIT)
		to_chat(nominee, "It would be premature to select a leader while everyone is still settling in, try again in [DisplayTimeText(CULT_POLL_WAIT-world.time)].")
		return
	team.cult_vote_called = TRUE //somebody's trying to be a master, make sure we don't let anyone else try
	for(var/datum/mind/B in team.members)
		if(B.current)
			B.current.update_action_buttons_icon()
			if(!B.current.incapacitated())
				SEND_SOUND(B.current, 'sound/hallucinations/im_here1.ogg')
				to_chat(B.current, span_cultlarge("Acolyte [nominee] has asserted that [nominee.p_theyre()] worthy of leading the cult. A vote will be called shortly."))
	sleep(100)
	var/list/asked_cultists = list()
	for(var/datum/mind/B in team.members)
		if(B.current && B.current != nominee && !B.current.incapacitated())
			SEND_SOUND(B.current, 'sound/magic/exit_blood.ogg')
			asked_cultists += B.current
	var/datum/poll_config/config = new()
	config.question = "[span_notice(nominee.name)] seeks to lead your cult, do you support [nominee.p_them()]?"
	config.poll_time = 30 SECONDS
	config.role_name_text = "cult master nomination"
	config.custom_response_messages = list(
		POLL_RESPONSE_SIGNUP = "You have pledged your allegience to [nominee].",
		POLL_RESPONSE_ALREADY_SIGNED = "You have already pledged your allegience!",
		POLL_RESPONSE_NOT_SIGNED = "You aren't nominated for this.",
		POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to unregister yourself, voting has already begun!",
		POLL_RESPONSE_UNREGISTERED = "You have been removed your pledge to [nominee]."
	)
	config.alert_pic = nominee
	config.chat_text_border_icon = mutable_appearance('icons/effects/effects.dmi', "cult_master_logo")
	var/list/yes_voters = SSpolling.poll_candidates(config, asked_cultists)
	if(QDELETED(nominee) || nominee.incapacitated())
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[nominee] has died in the process of attempting to win the cult's support!"))
		return FALSE
	if(!nominee.mind)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current,span_cultlarge("[nominee] has gone catatonic in the process of attempting to win the cult's support!"))
		return FALSE
	if(LAZYLEN(yes_voters) <= LAZYLEN(asked_cultists) * 0.5)
		team.cult_vote_called = FALSE
		for(var/datum/mind/B in team.members)
			if(B.current)
				B.current.update_action_buttons_icon()
				if(!B.current.incapacitated())
					to_chat(B.current, span_cultlarge("[nominee] could not win the cult's support and shall continue to serve as an acolyte."))
		return FALSE
	team.cult_master = nominee
	nominee.mind.remove_antag_datum(/datum/antagonist/cult)
	nominee.mind.add_antag_datum(/datum/antagonist/cult/master)
	for(var/datum/mind/B in team.members)
		if(B.current)
			for(var/datum/action/innate/cult/mastervote/vote in B.current.actions)
				qdel(vote)
			if(!B.current.incapacitated())
				to_chat(B.current,span_cultlarge("[nominee] has won the cult's support and is now their master. Follow [nominee.p_their()] orders to the best of your ability!"))
	return TRUE

/datum/action/innate/cult/master/is_available()
	if(!owner.mind || !owner.mind.has_antag_datum(/datum/antagonist/cult/master) || GLOB.narsie)
		return 0
	return ..()

/datum/action/innate/cult/master/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/cult/master/finalreck/on_activate()
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!antag)
		return
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T as() in (RANGE_TURFS(1, owner) - get_turf(owner)))
			if(!T.is_blocked_turf(TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, span_warning("You need more space to summon your cult!"))
			return
		if(do_after(owner, 30, target = owner))
			for(var/datum/mind/B in antag.cult_team.members)
				if(B.current && B.current.stat != DEAD)
					var/turf/mobloc = get_turf(B.current)
					switch(i)
						if(1)
							new /obj/effect/temp_visual/cult/sparks(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 50, 1)
						if(2)
							new /obj/effect/temp_visual/dir_setting/cult/phase/out(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 75, 1)
						if(3)
							new /obj/effect/temp_visual/dir_setting/cult/phase(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 100, 1)
						if(4)
							playsound(mobloc, 'sound/magic/exit_blood.ogg', 100, 1)
							if(B.current != owner)
								var/turf/final = pick(destinations)
								if(istype(B.current.loc, /obj/item/soulstone))
									var/obj/item/soulstone/S = B.current.loc
									S.release_shades(owner)
								B.current.setDir(SOUTH)
								new /obj/effect/temp_visual/cult/blood(final)
								addtimer(CALLBACK(B.current, TYPE_PROC_REF(/mob, reckon), final), 10)
		else
			return
	antag.cult_team.reckoning_complete = TRUE
	Remove(owner)

/mob/proc/reckon(turf/final)
	new /obj/effect/temp_visual/cult/blood/out(get_turf(src))
	forceMove(final)

/datum/action/innate/cult/master/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common, forced = "cult invocation")
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 50, 1)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 75, 1)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common, forced = "cult invocation")
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 100, 1)

/datum/action/innate/cult/master/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	requires_target = TRUE
	cooldown_time = 2 MINUTES
	enable_text = "<span class='cult'>You prepare to mark a target for your cult. <b>Click a target to mark them!</b></span>"
	disable_text = "<span class='cult'>You cease the marking ritual.</span>"
	/// The duration of the mark itself
	var/cult_mark_duration = 90 SECONDS

/datum/action/innate/cult/master/cultmark/InterceptClickOn(mob/clicker, params, atom/clicked_on)
	var/turf/clicker_turf = get_turf(clicker)
	if(!isturf(clicker_turf))
		return FALSE

	if(!(clicked_on in view(7, clicker_turf)))
		return FALSE
	return ..()

/datum/action/innate/cult/master/cultmark/on_activate(mob/user, atom/target)
	var/datum/antagonist/cult/cultist = user.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")
	if(cult_team.blood_target)
		to_chat(user, ("<span class='cult'>The cult has already designated a target!</span>"))
		return FALSE

	if(cult_team.set_blood_target(target, user, cult_mark_duration))
		disable_text = "<span class='cult'>The marking rite is complete! It will last for [DisplayTimeText(cult_mark_duration)] seconds.</span>"
		unset_click_ability(user)
		disable_text = initial(disable_text)
		start_cooldown()
		update_buttons()
		return TRUE
	unset_click_ability(user)
	return TRUE

/datum/action/innate/cult/ghostmark //Ghost version
	name = "Mark a Blood Target for the Cult"
	desc = "Marks whatever you are orbiting for the entire cult to track."
	button_icon_state = "cult_mark"
	/// The duration of the mark on the target
	var/cult_mark_duration = 60 SECONDS
	/// The cooldown between marks - the ability can be used in between cooldowns, but can't mark (only clear)
	var/cult_mark_cooldown_duration = 60 SECONDS
	/// The actual cooldown tracked of the action
	COOLDOWN_DECLARE(cult_mark_cooldown)

/datum/action/innate/cult/ghostmark/is_available()
	return ..() && istype(owner, /mob/dead/observer)

/datum/action/innate/cult/ghostmark/on_activate()
	var/datum/antagonist/cult/cultist = owner.mind?.has_antag_datum(/datum/antagonist/cult, TRUE)
	if(!cultist)
		CRASH("[type] was casted by someone without a cult antag datum.")

	var/datum/team/cult/cult_team = cultist.get_team()
	if(!cult_team)
		CRASH("[type] was casted by a cultist without a cult team datum.")

	if(cult_team.blood_target)
		if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
			cult_team.unset_blood_target_and_timer()
			to_chat(owner, ("<span class='cultbold'>You have cleared the cult's blood target!</span>"))
			return TRUE

		to_chat(owner, ("<span class='cultbold'>The cult has already designated a target!</span>"))
		return FALSE

	if(!COOLDOWN_FINISHED(src, cult_mark_cooldown))
		to_chat(owner, ("<span class='cultbold'>You aren't ready to place another blood mark yet!</span>"))
		return FALSE

	var/atom/mark_target = owner.orbiting?.parent || get_turf(owner)
	if(!mark_target)
		return FALSE

	if(cult_team.set_blood_target(mark_target, owner, 60 SECONDS))
		to_chat(owner, span_cultbold(">You have marked [mark_target] for the cult! It will last for [DisplayTimeText(cult_mark_duration)]."))
		COOLDOWN_START(src, cult_mark_cooldown, cult_mark_cooldown_duration)
		update_button_status()
		addtimer(CALLBACK(src, PROC_REF(reset_button)), cult_mark_cooldown_duration + 1)
		return TRUE

	to_chat(owner, ("<span class='cult'>The marking failed!</span>"))
	return FALSE

/datum/action/innate/cult/ghostmark/proc/update_button_status()
	if(!owner)
		return
	if(COOLDOWN_FINISHED(src, cult_mark_duration))
		name = initial(name)
		desc = initial(desc)
		button_icon_state = initial(button_icon_state)
	else
		name = "Clear the Blood Mark"
		desc = "Remove the Blood Mark you previously set."
		button_icon_state = "emp"

	update_buttons()

/datum/action/innate/cult/ghostmark/proc/reset_button()
	if(QDELETED(owner) || QDELETED(src))
		return

	SEND_SOUND(owner, 'sound/magic/enter_blood.ogg')
	to_chat(owner, ("<span class='cultbold'>Your previous mark is gone - you are now ready to create a new blood mark.</span>"))
	update_button_status()

//////// ELDRITCH PULSE /////////



/datum/action/innate/cult/master/pulse
	name = "Eldritch Pulse"
	desc = "Seize upon a fellow cultist or cult structure and teleport it to a nearby location."
	button_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "arcane_barrage"
	requires_target = TRUE
	enable_text = "<span class='cult'>You prepare to tear through the fabric of reality... <b>Click a target to sieze them!</b></span>"
	disable_text = "<span class='cult'>You cease your preparations.</span>"
	cooldown_time = 15 SECONDS
	/// Weakref to whoever we're currently about to toss
	var/datum/weakref/throwee_ref

/datum/action/innate/cult/master/pulse/InterceptClickOn(mob/living/clicker, params, atom/clicked_on)
	var/turf/clicker_turf = get_turf(clicker)
	if(!isturf(clicker_turf))
		return FALSE

	if(!(clicked_on in view(7, clicker_turf)))
		return FALSE

	if(clicked_on == clicker)
		return FALSE
	return ..()

/datum/action/innate/cult/master/pulse/on_activate(mob/user, atom/target)
	var/atom/throwee = throwee_ref?.resolve()

	if(QDELETED(throwee))
		to_chat(user, span_cult("You lost your target!"))
		throwee = null
		throwee_ref = null
		return FALSE

	if(throwee)
		if(get_dist(throwee, target) >= 16)
			to_chat(user, span_cult("You can't teleport [target.p_them()] that far!"))
			return FALSE

		var/turf/throwee_turf = get_turf(throwee)

		playsound(throwee_turf, 'sound/magic/exit_blood.ogg')
		new /obj/effect/temp_visual/cult/sparks(throwee_turf, user.dir)
		throwee.visible_message(
			span_warning("A pulse of magic whisks [throwee] away!"),
			span_cult("A pulse of blood magic whisks you away..."),
		)

		if(!do_teleport(throwee, target, channel = TELEPORT_CHANNEL_CULT))
			to_chat(user, span_cult("The teleport fails!"))
			throwee.visible_message(
				span_warning("...Except they don't go very far"),
				span_warning("...Except you don't appear to have moved very far."),
			)
			return FALSE

		throwee_turf.Beam(target, icon_state = "sendbeam", time = 0.4 SECONDS)
		new /obj/effect/temp_visual/cult/sparks(get_turf(target), user.dir)
		throwee.visible_message(
			span_warning("[throwee] appears suddenly in a pulse of magic!"),
			span_cult("...And you appear elsewhere."),
		)

		start_cooldown()
		to_chat(user, span_cult("A pulse of blood magic surges through you as you shift [throwee] through time and space."))
		user.click_intercept = null
		throwee_ref = null
		update_buttons()

		return TRUE
	else
		if(isliving(target))
			var/mob/living/living_clicked = target
			if(!IS_CULTIST(living_clicked))
				return FALSE
			SEND_SOUND(user, sound('sound/weapons/thudswoosh.ogg'))
			to_chat(user, span_cultbold("You reach through the veil with your mind's eye and seize [target]! <b>Click anywhere nearby to teleport [living_clicked.p_them()]!</b>"))
			throwee_ref = WEAKREF(target)
			return TRUE

		if(istype(target, /obj/structure/destructible/cult))
			to_chat(user, span_cultbold("You reach through the veil with your mind's eye and lift [target]! <b>Click anywhere nearby to teleport it!</b>"))
			throwee_ref = WEAKREF(target)
			return TRUE

	return FALSE
