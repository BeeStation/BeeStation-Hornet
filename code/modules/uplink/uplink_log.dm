GLOBAL_LIST(uplink_logs_by_key)	//assoc key = /datum/uplink_log

/datum/uplink_log
	var/owner
	var/list/uplink_log				//assoc path-of-item = /datum/uplink_purchase_entry
	/// List of directives that we have completed
	var/list/completed_directive_names = list()
	var/total_spent = 0
	var/effective_amount = 0

/datum/uplink_log/New(_owner, datum/component/uplink/_parent)
	owner = _owner
	LAZYINITLIST(GLOB.uplink_logs_by_key)
	if(owner)
		if(GLOB.uplink_logs_by_key[owner])
			stack_trace("WARNING: DUPLICATE PURCHASE LOGS DETECTED. [_owner] [_parent] [_parent.type]")
			MergeWithAndDel(GLOB.uplink_logs_by_key[owner])
		GLOB.uplink_logs_by_key[owner] = src
	uplink_log = list()

/datum/uplink_log/Destroy()
	uplink_log = null
	if(GLOB.uplink_logs_by_key[owner] == src)
		GLOB.uplink_logs_by_key -= owner
	return ..()

/datum/uplink_log/proc/MergeWithAndDel(datum/uplink_log/other)
	if(!istype(other))
		return
	. = owner == other.owner
	if(!.)
		return
	for(var/hash in other.uplink_log)
		if(!uplink_log[hash])
			uplink_log[hash] = other.uplink_log[hash]
		else
			var/datum/uplink_purchase_entry/UPE = uplink_log[hash]
			var/datum/uplink_purchase_entry/UPE_O = other.uplink_log[hash]
			UPE.amount_purchased += UPE_O.amount_purchased
	qdel(other)

/datum/uplink_log/proc/TotalTelecrystalsSpent()
	. = total_spent

/datum/uplink_log/proc/generate_render(show_key = TRUE)
	. = ""
	for(var/hash in uplink_log)
		var/datum/uplink_purchase_entry/UPE = uplink_log[hash]
		. += "<span class='tooltip_container'>\[[UPE.icon_b64][show_key?"([owner])":""]<span class='tooltip_hover'><b>[UPE.name]</b><br>[UPE.spent_cost ? "[UPE.spent_cost] TC" : "[UPE.base_cost] TC<br>(Surplus)"]<br>[UPE.desc]</span>[(UPE.amount_purchased > 1) ? "x[UPE.amount_purchased]" : ""]\]</span>"

/datum/uplink_log/proc/render_directives()
	. = ""
	if (length(completed_directive_names))
		. += "<b>Completed Directives:</b><br>"
		. += "<ul>"
		for (var/completed_directive in completed_directive_names)
			. += "<li>[html_encode(completed_directive)]</li>"
		. += "</ul>"

/datum/uplink_log/proc/LogPurchase(atom/A, datum/uplink_item/uplink_item, spent_cost, is_bonus = FALSE)
	var/datum/uplink_purchase_entry/UPE
	var/hash = hash_purchase(uplink_item, spent_cost)
	if(uplink_log[hash])
		UPE = uplink_log[hash]
	else
		UPE = new
		uplink_log[hash] = UPE
		UPE.path = A.type
		UPE.icon_b64 = "[icon2base64html(A)]"
		UPE.desc = uplink_item.desc
		UPE.name = uplink_item.name
		UPE.base_cost = initial(uplink_item.cost)
		UPE.spent_cost = spent_cost
		UPE.allow_refund = uplink_item.refundable

	UPE.amount_purchased++
	if(!is_bonus)
		total_spent += spent_cost
	effective_amount += spent_cost

/datum/uplink_log/proc/hash_purchase(datum/uplink_item/uplink_item, spent_cost)
	return "[uplink_item.type]|[uplink_item.name]|[uplink_item.cost]|[spent_cost]"

/datum/uplink_purchase_entry
	var/amount_purchased = 0
	var/path
	var/icon_b64
	var/desc
	var/base_cost
	var/spent_cost
	var/name
	var/allow_refund
