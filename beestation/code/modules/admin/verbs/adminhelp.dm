/datum/admin_help/ClosureLinks(ref_src)
    . = ..()
    . += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mhelp'>MHELP</A>)"

/datum/admin_help/proc/MHelpThis(key_name = key_name_admin(usr))
    if(state != AHELP_ACTIVE)
        return

    if(initiator)
        initiator.giveadminhelpverb()

        SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))

        to_chat(initiator, "<font color='red' size='4'><b>- AdminHelp Rejected! -</b></font>")
        to_chat(initiator, "<font color='red'>This question may regard <b>game mechanics or how-tos</b>. Such questions should be asked with <b>Mentorhelp</b>.</font>")

    SSblackbox.record_feedback("tally", "ahelp_stats", 1, "mhelp this")
    var/msg = "Ticket [TicketHref("#[id]")] told to mentorhelp by [key_name]"
    message_admins(msg)
    log_admin_private(msg)
    AddInteraction("Told to mentorhelp by [key_name].")
    if(!bwoink)
        discordsendmsg("ahelp", "Ticket #[id] told to mentorhelp by [key_name(usr, include_link=0)]")
    Close(silent = TRUE)

/datum/admin_help/Action(action)
    . = ..()
    switch(action)
        if("mhelp")
	        MHelpThis()

/datum/admin_help/var/bwoink // var to tell whether it's a bwoink or not
/datum/admin_help/New(msg, client/C, is_bwoink)
    ..()
    bwoink = is_bwoink
    if(!bwoink)
        discordsendmsg("ahelp", "**ADMINHELP: (#[id]) [C.key]: ** \"[msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]")


/datum/admin_help/Resolve(key_name = key_name_admin(usr), silent = FALSE)
    ..()
    if(!bwoink)
        discordsendmsg("ahelp", "Ticket #[id] resolved by [key_name(usr, include_link=0)]")

/datum/admin_help/Close(key_name = key_name_admin(usr), silent = FALSE)
    ..()
    if(!bwoink && !silent)
        discordsendmsg("ahelp", "Ticket #[id] closed by [key_name(usr, include_link=0)]")

/datum/admin_help/Reject(key_name = key_name_admin(usr))
    ..()
    if(!bwoink)
        discordsendmsg("ahelp", "Ticket #[id] rejected by [key_name(usr, include_link=0)]")

/datum/admin_help/ICIssue(key_name = key_name_admin(usr))
    if(!bwoink)
        discordsendmsg("ahelp", "Ticket #[id] marked as IC by [key_name(usr, include_link=0)]")
