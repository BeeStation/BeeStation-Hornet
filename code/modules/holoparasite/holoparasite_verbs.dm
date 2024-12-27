/**
 * Set the holoparasite's battlecry.
 */
/mob/living/simple_animal/hostile/holoparasite/verb/set_battlecry_v()
	set name = "Set Battlecry"
	set category = "Holoparasite"
	set desc = "Choose the phrase (or lack thereof) to shout whenever you attack."

	var/new_battlecry = tgui_input_text(src, "What do you want your battlecry to be? Max length of [HOLOPARA_MAX_BATTLECRY_LENGTH] characters. Leave blank if you do not want a battlecry.", default = battlecry, max_length = HOLOPARA_MAX_BATTLECRY_LENGTH, encode = FALSE)
	set_battlecry(new_battlecry)

/**
 * Communicate telepathically with your summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/verb/communicate()
	set name = "Communicate"
	set category = "Holoparasite"
	set desc = "Communicate telepathically with your summoner."

	var/message = tgui_input_text(src, "What do you want to say to your summoner?", "[theme.name] Telepathy")
	if(!message)
		return
	// Trimming, chat filters, treating, etc is handled by the telepathy proc.
	// Note: tgui_input_text sanitizes for us, so we pass sanitize = FALSE
	holoparasite_telepathy(message, sanitize = FALSE)

/**
 * Allows the holoparasite to attempt to reset themselves.
 * This is good for example, if they have to leave OOCly, as this will not touch the usual reset cooldown.
 */
/mob/living/simple_animal/hostile/holoparasite/verb/self_reset()
	set name = "Reset Self"
	set category = "Holoparasite"
	set desc = "Offer control of yourself up to ghosts."

	if(being_reset)
		to_chat(src, span_warning("You are already in the process of attempting a personality reset!"), type = MESSAGE_TYPE_WARNING)
		return
	if(tgui_alert(src, "Are you sure you want to reset yourself? You will be ghosted and a new player will take control of you, if an eligible candidate signs up.", "Reset Confirmation", list("Yes", "No")) != "Yes")
		return
	to_chat(src, span_holoparasitebold("Attempting to reset personality... Please wait."), type = MESSAGE_TYPE_INFO)
	to_chat(summoner.current, span_holoparasitebold("[color_name] is requesting a personality reset, please hold!"), type = MESSAGE_TYPE_INFO)
	reset(cooldown = FALSE, self = TRUE)

/**
 * Toggles whether the holoparasite, when it speaks while recalled, will talk out loud, or privately with its summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/verb/toggle_talk_out_loud()
	set name = "Toggle Recalled Speech"
	set category = "Holoparasite"
	set desc = "Toggles whether, when you speak while recalled, will talk out loud, or privately with your summoner."

	talk_out_loud = !talk_out_loud
	to_chat(src, span_holoparasitebold("You will now talk [talk_out_loud ? "out loud" : "privately with your summoner"] when attempting to speak while recalled."), type = MESSAGE_TYPE_INFO)
