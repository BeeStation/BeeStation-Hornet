/mob/living/simple_animal/hostile/holoparasite
	/**
	 * The cooldown for resetting this holoparasite.
	 * This cooldown can be bypassed if the holoparasite's client has been afk or disconnected for longer than [HOLOPARA_AFK_RESET_TIME],
	 * or if they have no ckey.
	 */
	COOLDOWN_DECLARE(reset_cooldown)
	/**
	 * When the holoparasite's client last logged out.
	 * Set to 0 if the player is currently logged in.
	 */
	var/logout_time = 0
	/// Whether the holoparasite is currently in the process of being reset or not.
	var/being_reset = FALSE


/**
 * Is this holoparasite eligible for a free reset by its master due to AFK timeout/disconnection/etc?
 */
/mob/living/simple_animal/hostile/holoparasite/proc/eligible_for_reset()
	. = FALSE
	if(!ckey)
		return TRUE
	if(logout_time > 0 && ((world.time - logout_time) > HOLOPARA_AFK_RESET_TIME))
		return TRUE
	if(client?.is_afk(HOLOPARA_AFK_RESET_TIME))
		return TRUE

/**
 * Mark the holoparasite as logged in.
 */
/mob/living/simple_animal/hostile/holoparasite/Login()
	. = ..()
	logout_time = 0

/**
 * Mark the holoparasite as logged out, setting the logout time.
 */
/mob/living/simple_animal/hostile/holoparasite/Logout()
	. = ..()
	logout_time = world.time

/**
 * Attempts to pull a new player for the holoparasite from
 */
/mob/living/simple_animal/hostile/holoparasite/proc/reset(cooldown = TRUE, automatic = FALSE, self = FALSE)
	set waitfor = FALSE
	if(being_reset)
		return
	being_reset = TRUE
	var/list/mob/dead/observer/candidates = poll_ghost_candidates(
		"Do you want to play as [summoner.name]'s [real_name], a [theme.name]?",
		jobban_type = ROLE_HOLOPARASITE,
		poll_time = 30 SECONDS
	)
	being_reset = FALSE
	if(!length(candidates))
		to_chat(summoner.current, "<span class='holoparasite bold'>[color_name] could not be reset, as there were no eligible candidate personalities willing to take over!</span>")
		if(self)
			to_chat(src, "<span class='holoparasite bold'>Personality reset <span class='danger'>failed</span>: no eligible candidate personalities.</span>")
		return
	var/mob/dead/observer/new_player = pick(candidates)
	if(!new_player)
		to_chat(summoner.current, "<span class='holoparasite bold'>[color_name] could not be reset due to an error!</span>")
		if(self)
			to_chat(summoner.current, "<span class='holoparasite bold'>Personality reset <span class='danger'>failed</span>: unknown error!</span>")
		return
	to_chat(src, "<span class='holoparasite bold big'>[self ? "A ghost took control of you, at your request." : "Your summoner reset you! Better luck next time!"]</span>")
	ghostize(can_reenter_corpse = FALSE)
	key = new_player.key
	to_chat(summoner.current, "<span class='holoparasite bold big'>Personality reset for [color_name] succeeded!</span>")
	SSblackbox.record_feedback("tally", "holoparasite_reset", 1, automatic ? "automatic" : (self ? "self" : (cooldown ? "summoner" : "summoner (free)")))
	if(cooldown)
		COOLDOWN_START(src, reset_cooldown, HOLOPARA_MANUAL_RESET_COOLDOWN)
