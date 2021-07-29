
/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////

	/// The admin state of the client. If this is null, the client is not an admin.
	var/datum/admins/holder = null
	var/datum/click_intercept = null // Needs to implement InterceptClickOn(user,params,atom) proc

	/// Whether the client has ai interacting as a ghost enabled or not
	var/AI_Interact		= 0

	/// Used to cache this client's bans to save on DB queries
	var/ban_cache = null
	/// Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message	= ""
	/// Contains a number of how many times a message identical to last_message was sent.
	var/last_message_count = 0
	/// How many messages sent in the last 10 seconds
	var/total_message_count = 0
	/// Next tick to reset the total message counter
	var/total_count_reset = 0
	var/ircreplyamount = 0
	var/cryo_warned = -3000//when was the last time we warned them about not cryoing without an ahelp, set to -5 minutes so that rounstart cryo still warns

		/////////
		//OTHER//
		/////////
	/// The client's preferences
	var/datum/preferences/prefs = null
	var/list/keybindings[0]

	/// The last world.time that the client's mob turned
	var/last_turn = 0

	/// The next world.time this client is allowed to move
	var/move_delay = 0
	var/area			= null

	var/buzz_playing = null
		////////////
		//SECURITY//
		////////////
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////

	/// Used to determine how old the account is - in days.
	var/player_age = -1
	/// Date that this account was first seen in the server
	var/player_join_date = null
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	/// Date of byond account creation in ISO 8601 format
	var/account_join_date = null
	/// Age of byond account in days
	var/account_age = -1

	preload_rsc = PRELOAD_RSC

	var/atom/movable/screen/click_catcher/void

	//These two vars are used to make a special mouse cursor, with a unique icon for clicking
	/// Mouse icon while not clicking
	var/mouse_up_icon = null
	/// Mouse icon while clicking
	var/mouse_down_icon = null

	var/ip_intel = "Disabled"

	/// Datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	var/lastping = 0
	var/avgping = 0
	/// world.time they connected
	var/connection_time
	/// world.realtime they connected
	var/connection_realtime
	/// world.timeofday they connected
	var/connection_timeofday

	var/inprefs = FALSE
	var/list/topiclimiter
	var/list/clicklimiter

	/// These persist between logins/logouts during the same round.
	var/datum/player_details/player_details

	var/list/char_render_holders			//Should only be a key-value list of north/south/east/west = atom/movable/screen.

	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE

	var/datum/viewData/view_size

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

	/// rate limiting for the crew manifest
	var/crew_manifest_delay

	//Tick when ghost roles are useable again
	var/next_ghost_role_tick = 0

	/// Messages currently seen by this client
	var/list/seen_messages
