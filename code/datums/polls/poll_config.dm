/datum/poll_config
	/// Optional, The question to ask the candidates. If null, a default question will be used. ("Do you want to play as role?")
	var/question = null
	/// Optional, A role preference (/datum/role_preference/roundstart/traitor) to pass, it won't show to any candidates who don't have it in their preferences.
	var/role = null
	/// Optional, What jobban role / flag to check, it won't show to any candidates who have this jobban.
	var/check_jobban = null
	/// How long the poll will last.
	var/poll_time = 30 SECONDS
	/// If true, then we will not be announced or play a sound
	var/silent = FALSE
	/// Optional, A poll category. If a candidate has this category in their ignore list, they won't be polled.
	var/ignore_category = null
	/// If TRUE, the candidate's window will flash when they're polled.
	var/flash_window = TRUE
	/// Optional, An /atom or an /image to display on the poll alert.
	var/alert_pic = null
	/// An /atom to teleport/jump to, if alert_pic is an /atom defaults to that.
	var/atom/jump_target = null
	/// Optional, A string to display in logging / the (default) question. If null, the role name will be used.
	var/role_name_text = null
	/// Optional, A list of strings to use as responses to the poll. If null, the default responses will be used. see __DEFINES/polls.dm for valid keys to use.
	var/list/custom_response_messages = null
	/// If TRUE, all candidates will start signed up for the poll, making it opt-out rather than opt-in.
	var/start_signed_up = FALSE
	/// Lets you pick candidates and return a single mob or list of mobs that were chosen. If set to a non-zero value, then the poll proc will return a random selection of this many candidates, otherwise all candidates will be returned so that you can handle selection yourself.
	var/amount_to_pick = 0
	/// Object or path to make an icon of to decorate the chat announcement.
	var/chat_text_border_icon
	/// Whether we should announce the chosen candidates in chat. This is ignored unless amount_to_pick is greater than 0.
	var/announce_chosen = TRUE
	/// A function that goes from /mob -> boolean that determines whether the provided mob should be included in the poll.
	var/datum/callback/check_candidate = null
	/// Who we auto add to the poll
	var/auto_add_type = POLL_AUTO_ADD_NONE
	/// If true, we require confirmation before we are added to the poll
	var/requires_confirmation = FALSE
	/// If true, the poll will be included in the spawners menu
	var/include_in_spawners = FALSE
	/// Can we right click to dismiss this poll?
	var/can_hide = FALSE
