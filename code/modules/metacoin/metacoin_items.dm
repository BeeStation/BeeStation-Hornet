
/datum/metacoin_shop_item
	var/name = ""
	var/cost = 0
	var/id = ""
	var/enabled = FALSE

	//shat for icons
	var/icon
	var/icon_state
	var/icon_dir = 2

/datum/metacoin_shop_item/proc/buy(client/C)
	if (!SSdbcore.IsConnected())
		to_chat(C, "<span class='rose bold'>Error! Try again later!</span>")
		return
	var/metacoins = C.get_metabalance()
	if (metacoins < cost)
		to_chat(C, "<span class='rose bold'>You do not have enough metacoins to buy the [name]!</span>")
		return
	C.inc_metabalance(-cost, reason="Shop purchase.")
	after_buy(C)
	to_chat(C, "<span class='rose bold'>You bought the [name] for [cost] metacoins!</span>")

/datum/metacoin_shop_item/proc/after_buy(client/C)
	//giving them the item they bought

/datum/metacoin_shop_item/proc/get_icon(client/C) //getting the icon for the shop
	return icon2html(icon, C, icon_state, icon_dir)

/datum/metacoin_shop_item/antag_token //what could go wrong
	name = "antag token"
	cost = 5000 //gl with that one
	id = "antag_token"
	enabled = FALSE

/datum/metacoin_shop_item/antag_token/after_buy(client/C)
	C.inc_antag_token_count(1)


/datum/metacoin_shop_item/only_one //you can only buy this item once
	name = "only one"
	cost = 0 //gl with that one
	enabled = FALSE
	var/class //used for classifying different types of items, like wings, hair, undershirts, etc


/datum/metacoin_shop_item/only_one/buy(client/C)
	C.update_metacoin_items()
	if(id in C.metacoin_items)
		return
	..()

/datum/metacoin_shop_item/only_one/after_buy(client/C)
	var/datum/DBQuery/query_metacoin_item_purchase = SSdbcore.NewQuery("INSERT INTO [format_table_name("metacoin_item_purchases")] (ckey, purchase_date, item_id, item_class) VALUES ('[C.ckey]', Now(), '[id]', '[class]')")
	query_metacoin_item_purchase.warn_execute()
	qdel(query_metacoin_item_purchase)
	C.update_metacoin_items()
