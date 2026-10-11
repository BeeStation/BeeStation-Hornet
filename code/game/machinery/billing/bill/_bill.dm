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
	/// List of tags for this bill, what kind of stuff we're billing
	var/bill_tags = BILL_TAG_UNPAID

/datum/bill/New(_title, _body, _from, _to, _amount, _draft = FALSE, _can_delete = TRUE, _tags)
	. = ..()
	title = _title
	body = _body
	from = _from
	to_whom = _to
	amount = _amount
	draft = _draft
	can_delete = _can_delete
	bill_tags |= _tags
	if(!draft)
		sent_when = station_time_timestamp("YYYY-MM-DD hh:mm:ss")

/datum/bill/proc/pay()
	if(paid)
		return
	var/datum/bank_account/account_to = SSeconomy.get_budget_account(to_whom)
	var/datum/bank_account/account_from = SSeconomy.get_budget_account(from)
	if(!account_to || !account_from)
		return
	// Can we afford this?
	if(amount > account_to.account_balance)
		return
	account_to.adjust_money(-amount)
	paid = TRUE
	bill_tags &= BILL_TAG_UNPAID
	bill_tags |= BILL_TAG_PAID
	account_from.adjust_money(amount)
	SEND_SIGNAL(src, COMSIG_BILLING_BILL_PAID, amount)

	return TRUE

// undraft / send bill
/datum/bill/proc/undraft()
	draft = FALSE
	sent_when = station_time_timestamp("YYYY-MM-DD hh:mm:ss")
	SEND_SIGNAL(src, COMSIG_BILLING_BILL_UNDRAFT)
