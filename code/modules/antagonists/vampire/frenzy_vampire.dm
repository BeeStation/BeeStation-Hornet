/**
 * # FrenzyGrab
 *
 * The martial art given to Vampires so they can instantly aggressively grab people.
 */
/datum/martial_art/frenzygrab
	name = "Frenzy Grab"
	id = MARTIALART_FRENZYGRAB

/datum/martial_art/frenzygrab/grab_act(mob/living/user, mob/living/target)
	if(user != target)
		target.grabbedby(user)
		target.grippedby(user, instant = TRUE)
		return TRUE
	return ..()

/**
 * # Status effect
 *
 * This is the status effect given to Vampires in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a Frenzy! You are entirely Feral and, depending on your Clan, fighting for your life!"
	icon = 'icons/vampires/actions_vampire.dmi'
	icon_state = "frenzy_alert"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/frenzy

	/// Boolean on whether they were an AdvancedToolUser, to give the trait back upon exiting.
	var/was_tooluser = FALSE
	/// The stored Vampire antag datum
	var/datum/antagonist/vampire/vampiredatum

	var/static/frenzy_traits = list(
		TRAIT_MUTE,
		TRAIT_DEAF,
		TRAIT_STUNIMMUNE
	)

/datum/status_effect/frenzy/get_examine_text()
	return span_notice("They seem... inhumane, and feral!")

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	. = ..()
	var/mob/living/carbon/human/user = owner
	vampiredatum = IS_VAMPIRE(user)

	// Disable ALL Powers and notify their entry
	vampiredatum.DisableAllPowers(forced = TRUE)
	to_chat(owner, span_userdanger("<FONT size = 10>BLOOD! YOU NEED BLOOD NOW!"))
	to_chat(owner, span_announce("* Vampire Tip: While in Frenzy, you instantly Aggresively grab, have stun immunity, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	owner.balloon_alert(owner, "you enter a frenzy!")
	SEND_SIGNAL(vampiredatum, VAMPIRE_ENTERS_FRENZY)

	// Traits
	owner.add_traits(frenzy_traits, TRAIT_VAMPIRE)
	if(!HAS_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER))
		was_tooluser = TRUE
		ADD_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER, TRAIT_FRENZY)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	vampiredatum.frenzygrab.teach(user, TRUE)
	user.uncuff()
	vampiredatum.frenzied = TRUE

/datum/status_effect/frenzy/on_remove()
	. = ..()
	var/mob/living/carbon/human/user = owner
	owner.balloon_alert(owner, "you come back to your senses.")

	// Traits
	owner.remove_traits(frenzy_traits, TRAIT_VAMPIRE)
	if(was_tooluser)
		REMOVE_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER, TRAIT_FRENZY)
		was_tooluser = FALSE

	owner.remove_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	vampiredatum.frenzygrab.remove(user)
	owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)

	SEND_SIGNAL(vampiredatum, VAMPIRE_EXITS_FRENZY)
	vampiredatum.frenzied = FALSE

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	if(!vampiredatum?.frenzied)
		return
	user.adjustFireLoss(0.75)
	user.Jitter(5)

/datum/movespeed_modifier/frenzy_speed
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.5
