/// All clients with mentor datums (excluding admins) - use is_mentor() instead of checking this
GLOBAL_LIST_EMPTY(mentors)
GLOBAL_PROTECT(mentors)

/// All mentor datums - these are created for every entry in the database / mentors.txt and may not correspond to logged in clients
GLOBAL_LIST_EMPTY(mentor_datums)
GLOBAL_PROTECT(mentor_datums)

/// The global mentor HREF token. Use the MentorHrefToken() proc.
GLOBAL_VAR_INIT(mentor_href_token, GenerateToken())
GLOBAL_PROTECT(mentor_href_token)

/// Log of all mentor actions
GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)

/// Returns if the client has access to mentor stuff and can use the mentor system.
/// This is true for mentors and admins with R_ADMIN.
/// If you want to check if someone is a "true mentor", check mentor_datum
/// If you want a list of "true mentors", check GLOB.mentors
/client/proc/is_mentor()
	return mentor_datum || check_rights_for(src, R_ADMIN)
