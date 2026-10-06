/datum/bill
	/// Bill title, billmcbillface
	var/title = ""
	/// Bill body, description and information
	var/body = ""
	/// Who made the bill - Department ID
	var/from
	/// Who the bill is addressed to - Department ID
	var/to_whom // Can't use 'to' lol
	/// How deep in the hole - in credits
	var/amount = 0
	/// Status
	var/paid = FALSE
	/// When was this bill SENT
	var/sent_when
	/// Is this bill a draft
	var/draft = FALSE
	/// Can this bill de deleted? use this for system/s bills
	var/can_delete = TRUE

/datum/bill/New(_title, _body, _from, _to, _amount, _draft = FALSE, _can_delete = TRUE)
	. = ..()
	title = _title
	body = _body
	from = _from
	to_whom = _to
	amount = _amount
	draft = _draft
	can_delete = _can_delete
	if(!draft)
		sent_when = station_time_timestamp("YYYY-MM-DD hh:mm:ss")

// undraft / send bill
/datum/bill/proc/undraft()
	draft = FALSE
	sent_when = station_time_timestamp("YYYY-MM-DD hh:mm:ss")
	SEND_SIGNAL(src, COMSIG_BILLING_BILL_UNDRAFT)
