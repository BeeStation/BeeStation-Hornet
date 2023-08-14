/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The view of the client, similar to /client/var/view
	var/view = "17x15"

/datum/client_interface/proc/should_include_for_role(banning_key = BAN_ROLE_ALL_ANTAGONISTS, role_preference_key = null, poll_ignore_key = null, req_hours = 0, feedback = FALSE)
	return TRUE
