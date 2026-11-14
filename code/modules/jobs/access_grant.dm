/// Temporary access on an ID card
/datum/access_grant
	var/obj/item/card/id/card
	var/list/access
	var/source
	/// Timer id for auto-expiry, then for the grace period once revoking. Null if the grant is indefinite
	var/timer_id
	var/revoking = FALSE

/datum/access_grant/New(obj/item/card/id/card, list/access, source, duration)
	. = ..()
	src.card = card
	src.access = access.Copy()
	src.source = source
	LAZYADD(card.access_grants, src)
	if(duration)
		timer_id = addtimer(CALLBACK(src, PROC_REF(expire)), duration, TIMER_STOPPABLE)

/datum/access_grant/Destroy()
	deltimer(timer_id)
	timer_id = null
	if(card)
		LAZYREMOVE(card.access_grants, src)
		card = null
	return ..()

/datum/access_grant/proc/expire()
	timer_id = null
	announce_revocation("expired", "expired")
	qdel(src)

/datum/access_grant/proc/revoke(reason = "revoked", mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(src))
		return
	announce_revocation(reason, "withdrawn", user)
	qdel(src)

/// Calling revoke() during the grace period ends it early
/datum/access_grant/proc/revoke_after(grace, reason = "revoked", mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(src) || revoking)
		return
	revoking = TRUE
	deltimer(timer_id)
	timer_id = addtimer(CALLBACK(src, PROC_REF(revoke), reason), grace, TIMER_STOPPABLE)
	announce_revocation("[reason], ends in [DisplayTimeText(grace)]", "ends in [DisplayTimeText(grace)]", user)

/**
 * Arguments:
 * * note - what happened, for the log
 * * phrase - what happened, as the card says it
 */
/datum/access_grant/proc/announce_revocation(note, phrase, mob/user)
	if(!card)
		return
	var/list/lost = access - card.get_non_skeleton_access(except = src) - card.get_skeleton_access()
	if(length(lost))
		var/access_desc = get_access_desc(lost)
		if(user)
			card.log_card("removed temporary [access_desc] access from [card] ([note], granted using [source])", user)
		else
			card.log_card("temporary [access_desc] access [note] (granted using [source])")
	card.card_talk("Temporary [get_access_desc(access)] access [phrase].", warning = TRUE)

/datum/access_grant/proc/get_examine_reason()
	return "Authorized at an ID console"

/datum/access_grant/proc/timing_text()
	if(revoking)
		return "handing over in [DisplayTimeText(timeleft(timer_id))]"
	if(timer_id)
		return "expires in [DisplayTimeText(timeleft(timer_id))]"
	return "active until revoked"

/// A head job's access, title, HUD and command pay layered over the card's own job
/datum/access_grant/acting_head
	var/datum/job/job
	var/cause

/datum/access_grant/acting_head/New(obj/item/card/id/card, datum/job/job, source)
	src.job = job
	..(card, job.get_access(), source)
	var/old_assignment = card.get_assignment()
	card.acting_head = src
	card.assignment_changed(old_assignment)
	SSjob.acting_heads += src
	card.registered_account?.refresh_acting_pay()
	SSjob.refresh_skeleton_access()

/datum/access_grant/acting_head/Destroy()
	SSjob.acting_heads -= src
	_restore_card()
	// Off the card first, so skeleton crew announcements count this access as gone
	if(card)
		LAZYREMOVE(card.access_grants, src)
	SSjob.refresh_skeleton_access()
	// After the refresh, since skeleton crew rules can give some of it straight back
	if(!QDESTROYING(card))
		card.log_access_change(access - card.GetAccess(), "end of acting [job.title] appointment", granting = FALSE)
	return ..()

/datum/access_grant/acting_head/proc/on_account_changed(datum/bank_account/old_account)
	old_account?.refresh_acting_pay()
	card.registered_account?.refresh_acting_pay()

/datum/access_grant/acting_head/proc/_restore_card()
	PRIVATE_PROC(TRUE)
	if(!card)
		return
	var/acting_assignment = card.get_assignment()
	if(card.acting_head == src)
		card.acting_head = null
	card.assignment_changed(acting_assignment)
	card.registered_account?.refresh_acting_pay()

/datum/access_grant/acting_head/announce_revocation(note, phrase, mob/user)
	if(!card)
		return
	var/detail = note
	if(cause)
		detail = "[note], [cause]"
	if(user)
		card.log_card("ended acting [job.title] status on [card] ([detail])", user)
	else
		card.log_card("acting [job.title] status [detail]")
	if(cause)
		card.card_talk("[capitalize(cause)]. Acting [job.title] appointment [phrase].", warning = TRUE)
	else
		card.card_talk("Acting [job.title] appointment [phrase].", warning = TRUE)

/datum/access_grant/acting_head/proc/on_head_arrival(datum/job/joined_job)
	if(revoking || joined_job.type != job.type)
		return
	cause = "[joined_job.title] reported for duty"
	revoke_after(HANDOVER_GRACE_PERIOD)

/datum/access_grant/acting_head/proc/on_head_departure(datum/job/left_job)
	if(!revoking || left_job.type != job.type || !SSjob.is_job_empty(job.title))
		return
	revoking = FALSE
	deltimer(timer_id)
	timer_id = null
	cause = null
	card.log_card("acting [job.title] status kept, [left_job.title] left")
	card.card_talk("[left_job.title] left. Acting [job.title] appointment continues.")
