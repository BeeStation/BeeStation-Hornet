/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The view of the client, similar to /client/var/view
	var/view = "17x15"

	/// View data of the client, similar to /client/var/view_size.
	var/datum/view_data/view_size

	/// Objects on the screen of the client
	var/list/screen = list()

	/// The mob the client controls
	var/mob/mob

	/// The ckey for this mock interface
	var/ckey = "mockclient"

	/// The key for this mock interface
	var/key = "mockclient"

/datum/client_interface/New()
	..()
	var/static/mock_client_uid = 0
	mock_client_uid++

	src.key = "[key]_[mock_client_uid]"
	ckey = ckey(key)

	GLOB.directory[ckey] = src

/datum/client_interface/Destroy(force, ...)
	GLOB.directory -= ckey
	return ..()

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/proc/set_macros()
	return

/datum/client_interface/proc/should_include_for_role(banning_key = BAN_ROLE_ALL_ANTAGONISTS, role_preference_key = null, poll_ignore_key = null, req_hours = 0, feedback = FALSE)
	return TRUE
