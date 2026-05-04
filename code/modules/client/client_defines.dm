
/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
#ifdef DISABLE_BYOND_AUTH
	authenticate = FALSE
#endif
		////////////////
		//ADMIN THINGS//
		////////////////

	/// If this client has been fully initialized or not
	var/fully_created = FALSE

	/// If this client has been authenticated as actually being authorized to use the attached CKEY
	var/logged_in = FALSE

	/// The admin state of the client. If this is null, the client is not an admin.
	var/datum/admins/holder = null
	var/datum/click_intercept = null // Needs to implement InterceptClickOn(user,params,atom) proc

	/// Acts the same way holder does towards admin: it holds the mentor datum. if set, the client is a mentor.
	var/datum/mentors/mentor_datum = null

	/// Whether the client has ai interacting as a ghost enabled or not
	var/AI_Interact		= 0

	/// Used to cache this client's bans to save on DB queries
	var/ban_cache = null
	///If we are currently building this client's ban cache, this var stores the timeofday we started at
	var/ban_cache_start = 0
	/// Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message	= ""
	/// How many messages sent in the last 10 seconds
	var/total_message_count = 0
	/// Next tick to reset the total message counter
	COOLDOWN_DECLARE(total_count_reset)
	var/externalreplyamount = 0
	var/cryo_warned = -3000//when was the last time we warned them about not cryoing without an ahelp, set to -5 minutes so that rounstart cryo still warns
	var/staff_check_rate = 0 //when was the last time they checked online staff

		/////////
		//OTHER//
		/////////
	/// The client's preferences
	var/datum/preferences/prefs = null
	var/list/keybindings[0]
	var/movement_locked = FALSE

	/// The last world.time that the client's mob turned
	var/last_turn = 0

	///Move delay of controlled mob, any keypresses inside this period will persist until the next proper move
	var/move_delay = 0
	///The visual delay to use for the current client.Move(), mostly used for making a client based move look like it came from some other slower source
	var/visual_delay = 0
	///Current area of the controlled mob
	var/area = null

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

	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE

	var/datum/view_data/view_size

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

	/// rate limiting for the crew manifest
	COOLDOWN_DECLARE(crew_manifest_delay)

	//Tick when ghost roles are useable again
	var/next_ghost_role_tick = 0

	/// If the client is currently under the restrictions of the interview system
	var/interviewee = FALSE

	/// Whether or not this client has standard hotkeys enabled
	var/hotkeys = TRUE

	/// client/eye is immediately changed, and it makes a lot of errors to track eye change
	var/datum/weakref/eye_weakref

///Autoclick list of two elements, first being the clicked thing, second being the parameters.
	var/list/atom/selected_target[2]
	///Used in MouseDrag to preserve the original mouse click parameters
	var/mouseParams = ""
	///Used in MouseDrag to preserve the last mouse-entered location. Weakref
	var/datum/weakref/mouse_location_ref = null
	///Used in MouseDrag to preserve the last mouse-entered object. Weakref
	var/datum/weakref/mouse_object_ref
	//Middle-mouse-button clicked object control for aimbot exploit detection. Weakref
	var/datum/weakref/middle_drag_atom_ref

	///A lazy list of atoms we've examined in the last RECENT_EXAMINE_MAX_WINDOW (default 2) seconds, so that we will call [/atom/proc/examine_more] instead of [/atom/proc/examine] on them when examining
	var/list/recent_examines

	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_up_icon = null
	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_down_icon = null
	///used to override the mouse cursor so it doesnt get reset
	var/mouse_override_icon = null


	/// Whether or not we want to show screentips
	var/show_screentips = TRUE
	/// Should extended screentips be shown?
	var/show_extended_screentips = FALSE

	/// New connection TopicData, cached prior to authentication
	var/temp_topicdata = null

	/// When FORCE_BYOND_EXTERNAL_AUTH is enabled, this is set to the client's hub-authenticated BYOND key if it is valid
	var/byond_authenticated_key = null

	/// True if this client's `key` is a not real BYOND CKEY (the cached result of is_external_auth_key(src.key))
	var/key_is_external = FALSE
	/// The source of external authentication. Can be set even if the CKEY is a real BYOND CKEY.
	var/datum/external_login_method/external_method = null
	/// The UID of this user in the external auth source. Can be set even if the CKEY is a real BYOND CKEY.
	var/external_uid = null
	/// The display name from an external auth source. Used instead of the BYOND key in some UIs. Can be set even if the CKEY is a real BYOND CKEY.
	var/external_display_name = null

	/// Number of attempts this client has made to authenticate with a token
	var/token_attempts = 0
	/// Port currently used by this client's Dream Seeker
	var/seeker_port

