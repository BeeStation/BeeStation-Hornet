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
	icon_state = "frenzy"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/frenzy
	///Boolean on whether they were an AdvancedToolUser, to give the trait back upon exiting.
	var/was_tooluser = FALSE
	/// The stored Vampire antag datum
	var/datum/antagonist/vampire/vampiredatum

/datum/status_effect/frenzy/get_examine_text()
	return "<span class='notice'>They seem... inhumane, and feral!</span>"

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	vampiredatum = IS_VAMPIRE(user)

	// Disable ALL Powers and notify their entry
	vampiredatum.DisableAllPowers(forced = TRUE)
	to_chat(owner, "<span class='userdanger'><FONT size = 10>BLOOD! YOU NEED BLOOD NOW!</span>")
	to_chat(owner, "<span class='announce'>* Vampire Tip: While in Frenzy, you instantly Aggresively grab, have stun resistance, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it).</span>")
	owner.balloon_alert(owner, "you enter a frenzy!")
	SEND_SIGNAL(vampiredatum, VAMPIRE_ENTERS_FRENZY)

	// Give the other Frenzy effects
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_FRENZY)
	ADD_TRAIT(owner, TRAIT_DEAF, TRAIT_FRENZY)
	if(!HAS_TRAIT(owner, TRAIT_DISCOORDINATED))
		was_tooluser = TRUE
		ADD_TRAIT(owner, TRAIT_DISCOORDINATED, TRAIT_FRENZY)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	vampiredatum.frenzygrab.teach(user, TRUE)
	user.Jitter(60 SECONDS)
	user.uncuff()
	vampiredatum.frenzied = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	var/mob/living/carbon/human/user = owner
	owner.balloon_alert(owner, "you come back to your senses.")
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_FRENZY)
	REMOVE_TRAIT(owner, TRAIT_DEAF, TRAIT_FRENZY)
	if(was_tooluser)
		REMOVE_TRAIT(owner, TRAIT_DISCOORDINATED, TRAIT_FRENZY)
		was_tooluser = FALSE
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
	vampiredatum.frenzygrab.remove(user)
	owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)

	SEND_SIGNAL(vampiredatum, VAMPIRE_EXITS_FRENZY)
	vampiredatum.frenzied = FALSE
	return ..()

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	if(!vampiredatum?.frenzied)
		return
	user.adjustFireLoss(1.5 + (vampiredatum.humanity_lost / 10))
