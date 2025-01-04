/// A datum storing various mentor functionality on a client.
/// These are created regardless of if said client is signed in, and then assigned on login from the mentor_datums list.
/datum/mentors
	var/name = "someone's mentor datum"
	/// The mentor datum's client
	var/client/owner
	/// The mentor's key (aka client.ckey with ckey() proc called on it)
	var/target
	/// href token for mentor commands, similar to the token used by admins.
	var/href_token
	/// The Mentor Ticket Manager interface
	var/datum/help_ui/mentor/mentor_interface

/datum/mentors/New(ckey)
	if(!ckey)
		QDEL_IN(src, 0)
		stack_trace("Mentor datum created without a ckey: [ckey]")
		return
	target = ckey(ckey)
	if(GLOB.mentor_datums[target])
		QDEL_IN(src, 0)
		stack_trace("A second mentor datum was created for [target]!")
		return
	name = "[ckey]'s mentor datum"
	href_token = GenerateToken()
	GLOB.mentor_datums[target] = src
	// If they're logged in, let's assign their mentor datum now.
	var/client/C = GLOB.directory[ckey]
	assign_to_client(C)

/datum/mentors/proc/assign_to_client(client/C)
	if(!C)
		return
	var/new_client_ckey = ckey(C.ckey)
	if(new_client_ckey != target) // what the fuck
		stack_trace("Invalid client assigned to mentor datum for [target], the new client was [new_client_ckey]")
		return
	owner = C
	owner.mentor_datum = src
	owner.add_mentor_verbs()
	if(!check_rights_for(owner, R_ADMIN)) // add nonadmins to the mentor list.
		GLOB.mentors |= owner

/datum/mentors/proc/CheckMentorHREF(href, href_list)
	var/auth = href_list["mentor_token"]
	. = auth && (auth == href_token || auth == GLOB.mentor_href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/proc/RawMentorHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.mentor_href_token
	if(!forceGlobal && usr)
		var/client/C = usr.client
		to_chat(world, C)
		to_chat(world, usr)
		if(!C)
			CRASH("No client for HrefToken()!")
		var/datum/mentors/holder = C.mentor_datum
		if(holder)
			tok = holder.href_token
	return tok

/proc/MentorHrefToken(forceGlobal = FALSE)
	return "mentor_token=[RawMentorHrefToken(forceGlobal)]"

/datum/mentors/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !GLOB.mentor_datums[usr.ckey])
		log_href_exploit(usr, " Tried to use the mentor panel without having the correct mentor datum.")
		return

	if(!CheckMentorHREF(href, href_list))
		return

	if(href_list["mhelp"])
		var/mhelp_ref = href_list["mhelp"]
		var/datum/help_ticket/mentor/MH = locate(mhelp_ref)
		if(istype(MH))
			MH.Action(href_list["mhelp_action"])
		else
			to_chat(usr, "Ticket [mhelp_ref] has been deleted!")
	else if(href_list["mhelp_tickets"])
		GLOB.mhelp_tickets.BrowseTickets(usr)

