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
	/// We give stamina resistance when we have the frenzy status effect. Let's keep track of it
	var/previous_stamina_mod
	/// The stored vampire antag datum
	var/datum/antagonist/vampire/vampiredatum

	var/static/frenzy_traits = list(
		TRAIT_MUTE,
		TRAIT_DEAF,
		TRAIT_STUNIMMUNE,
	)

/datum/status_effect/frenzy/get_examine_text()
	return span_danger("They seem... inhumane, and feral!")

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	vampiredatum = IS_VAMPIRE(carbon_owner)

	ASSERT(isnull(vampiredatum), "Frenzy status effect applied to a non-vampire!")

	// Basic stuff
	carbon_owner.add_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	carbon_owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	carbon_owner.uncuff()
	vampiredatum.frenzygrab.teach(carbon_owner, TRUE)
	vampiredatum.frenzied = TRUE

	// Alert them
	vampiredatum.disable_all_powers(forced = TRUE)
	to_chat(carbon_owner, span_userdanger("<FONT size = 10>BLOOD! YOU NEED BLOOD NOW!"))
	to_chat(carbon_owner, span_announce("* Vampire Tip: While in Frenzy, you instantly Aggresively grab, have stun immunity, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	carbon_owner.balloon_alert(carbon_owner, "you enter a frenzy!")

	// Stamina modifier
	if (ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		previous_stamina_mod = human_owner.physiology.stamina_mod
		human_owner.physiology.stamina_mod *= 0.4

	// Traits
	carbon_owner.add_traits(frenzy_traits, TRAIT_VAMPIRE)
	if(!HAS_TRAIT(carbon_owner, TRAIT_ADVANCEDTOOLUSER))
		was_tooluser = TRUE
		ADD_TRAIT(carbon_owner, TRAIT_ADVANCEDTOOLUSER, TRAIT_FRENZY)

/datum/status_effect/frenzy/on_remove()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner

	// Basic stuff
	carbon_owner.remove_movespeed_modifier(/datum/movespeed_modifier/frenzy_speed)
	carbon_owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)
	vampiredatum.frenzygrab.remove(carbon_owner)
	vampiredatum.frenzied = FALSE

	// Alert them
	carbon_owner.balloon_alert(carbon_owner, "you come back to your senses.")

	// Stamina modifier
	if (ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		human_owner.physiology.stamina_mod = previous_stamina_mod

	// Traits
	carbon_owner.remove_traits(frenzy_traits, TRAIT_VAMPIRE)
	if(was_tooluser)
		REMOVE_TRAIT(carbon_owner, TRAIT_ADVANCEDTOOLUSER, TRAIT_FRENZY)
		was_tooluser = FALSE


/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/carbon_owner = owner
	if(!vampiredatum?.frenzied)
		return
	carbon_owner.adjustFireLoss(0.75)
	carbon_owner.Jitter(5)

/datum/movespeed_modifier/frenzy_speed
	blacklisted_movetypes = FLYING | FLOATING
	multiplicative_slowdown = -0.5

/**
 * # FrenzyGrab
 *
 * The martial art given to Vampires so they can instantly aggressively grab people.
 */
#define MARTIALART_FRENZYGRAB "frenzy grabbing"

/datum/martial_art/frenzygrab
	name = "Frenzy Grab"
	id = MARTIALART_FRENZYGRAB

/datum/martial_art/frenzygrab/grab_act(mob/living/user, mob/living/target)
	if(user == target)
		return ..()

	target.grabbedby(user)
	target.grippedby(user, instant = TRUE)
	return TRUE

#undef MARTIALART_FRENZYGRAB
