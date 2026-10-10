/// Temporary access on an ID card
/datum/access_grant
	var/obj/item/card/id/card
	var/list/accesses
	var/source
	/// Timer id for auto-expiry, then for the grace period once revoking. Null if the grant is indefinite
	var/timer_id
	var/grace_period = 0
	var/revoking = FALSE

/datum/access_grant/New(obj/item/card/id/card, list/accesses, source, duration, grace_period = 0)
	. = ..()
	src.card = card
	src.accesses = accesses.Copy()
	src.source = source
	src.grace_period = grace_period
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
	revoke("expired")

/datum/access_grant/proc/revoke(reason = "revoked", grace = null, mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(src))
		return
	if(isnull(grace))
		grace = grace_period
	if(grace <= 0 || revoking)
		finish_revoke(reason, user)
		return
	revoking = TRUE
	deltimer(timer_id)
	timer_id = addtimer(CALLBACK(src, PROC_REF(finish_revoke), reason), grace, TIMER_STOPPABLE)
	announce_revocation("[reason], ends in [DisplayTimeText(grace)]", "ends in [DisplayTimeText(grace)]", user)

/datum/access_grant/proc/finish_revoke(reason = "revoked", mob/user)
	announce_revocation(reason, reason == "expired" ? "expired" : "withdrawn", user)
	qdel(src)

/**
 * Arguments:
 * * note - what happened, for the log
 * * phrase - what happened, as the card says it
 */
/datum/access_grant/proc/announce_revocation(note, phrase, mob/user)
	if(!card)
		return
	card.log_access_change(get_unique_access(), "[source] (temporary access [note])", user, granting = FALSE)
	card.card_talk("Temporary [access_names()] access [phrase].", warning = TRUE)

/datum/access_grant/proc/get_unique_access()
	. = accesses - card.access - card.get_skeleton_access()
	for(var/datum/access_grant/other as anything in card.access_grants)
		if(other != src)
			. -= other.accesses

/datum/access_grant/proc/access_names()
	return english_list(get_access_descs(accesses))

/datum/access_grant/proc/get_examine_reason()
	return "Authorized at an ID console"

/datum/access_grant/proc/timing_text()
	if(revoking)
		return "ending in [DisplayTimeText(timeleft(timer_id))]"
	if(timer_id)
		return "expires in [DisplayTimeText(timeleft(timer_id))]"
	return "active until revoked"

/// A head job's access, title, HUD and command pay layered over the card's own job
/datum/access_grant/acting_head
	var/datum/job/job
	/// Grace period before access is cut when a "real"(lmao) head of this job latejoins
	var/arrival_grace = 5 MINUTES
	VAR_PRIVATE/previous_assignment
	VAR_PRIVATE/previous_hud_state
	VAR_PRIVATE/acting_hud_state
	VAR_PRIVATE/datum/bank_account/paid_account
	VAR_PRIVATE/previous_command_pay
	VAR_PRIVATE/acting_command_pay
	var/cause

/datum/access_grant/acting_head/New(obj/item/card/id/card, datum/job/job, source)
	src.job = job
	..(card, job.get_access(), source)
	previous_assignment = card.assignment
	previous_hud_state = card.hud_state
	card.assignment = "Acting [job.title]"
	card.hud_state = get_hud_by_jobname(card.assignment, returns_unknown = FALSE) || get_hud_by_jobname(job.title)
	acting_hud_state = card.hud_state
	card.update_label()
	card.refresh_holder_hud()
	var/command_pay = job.payment_per_department[ACCOUNT_COM_ID]
	if(card.registered_account && command_pay)
		paid_account = card.registered_account
		previous_command_pay = paid_account.payment_per_department[ACCOUNT_COM_ID]
		acting_command_pay = max(previous_command_pay, command_pay)
		paid_account.payment_per_department[ACCOUNT_COM_ID] = acting_command_pay
	LAZYADD(card.access_grants, src)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN, PROC_REF(on_latejoin))
	SSjob.acting_heads += src
	SSjob.refresh_skeleton_access()

/datum/access_grant/acting_head/Destroy()
	restore_card()
	SSjob.acting_heads -= src
	SSjob.refresh_skeleton_access()
	return ..()

/datum/access_grant/acting_head/proc/restore_card()
	PRIVATE_PROC(TRUE)
	if(paid_account)
		if(paid_account.payment_per_department[ACCOUNT_COM_ID] == acting_command_pay)
			paid_account.payment_per_department[ACCOUNT_COM_ID] = previous_command_pay
		paid_account = null
	if(!card)
		return
	if(card.acting_head == src)
		card.acting_head = null
	if(card.assignment == "Acting [job.title]")
		card.assignment = previous_assignment
	if(card.hud_state == acting_hud_state)
		card.hud_state = previous_hud_state
	card.update_label()
	card.refresh_holder_hud()
	card.sync_manifest()

/datum/access_grant/acting_head/announce_revocation(note, phrase, mob/user)
	if(!card)
		return
	if(user)
		log_id("[key_name(user)] ended acting [job.title] status on [card.get_log_name()] ([note]).")
	else
		log_id("Acting [job.title] status on [card.get_log_name()] [note][cause ? ", [cause]" : ""].")
	card.log_access_change(get_unique_access(), "[source] (acting [job.title] [note])", user, granting = FALSE)
	card.card_talk("[cause ? "[cause]. " : ""]Acting [job.title] appointment [phrase].", warning = TRUE)

/datum/access_grant/acting_head/proc/on_latejoin(datum/source, datum/job/joined_job, mob/living/spawned)
	SIGNAL_HANDLER
	if(revoking || joined_job.type != job.type)
		return
	cause = "[joined_job.title] reported for duty"
	revoke("revoked", arrival_grace)
