
/datum/beecoin_shop_item
	var/name = ""
	var/cost = 0
	var/id = ""
	var/enabled = FALSE

	//shat for icons
	var/icon
	var/icon_state
	var/icon_dir = 2

/datum/beecoin_shop_item/proc/buy(client/C)
	if (!SSdbcore.IsConnected())
		to_chat(C, "<span class='rose bold'>Error! Try again later!</span>")
		return
	var/beecoins = C.get_beecoin_count()
	if (beecoins < cost)
		to_chat(C, "<span class='rose bold'>You do not have enough beecoins to buy the [name]!</span>")
		return
	C.inc_beecoin_count(-cost)
	after_buy(C)
	to_chat(C, "<span class='rose bold'>You bought the [name] for [cost] beecoins!</span>")

/datum/beecoin_shop_item/proc/after_buy(client/C)
	//giving them the item they bought

/datum/beecoin_shop_item/proc/get_icon(client/C) //getting the icon for the shop
	return icon2html(icon, C, icon_state, icon_dir)

/datum/beecoin_shop_item/antag_token //what could go wrong
	name = "antag token"
	cost = 5000 //gl with that one
	id = "antag_token"
	enabled = FALSE

/datum/beecoin_shop_item/antag_token/after_buy(client/C)
	C.inc_antag_token_count(1)


/datum/beecoin_shop_item/only_one //you can only buy this item once
	name = "only one"
	cost = 0 //gl with that one
	enabled = FALSE
	var/class //used for classifying different types of items, like wings, hair, undershirts, etc


/datum/beecoin_shop_item/only_one/buy(client/C)
	C.update_beecoin_items()
	if(id in C.beecoin_items)
		return
	..()

/datum/beecoin_shop_item/only_one/after_buy(client/C)
	var/datum/DBQuery/query_beecoin_item_purchase = SSdbcore.NewQuery("INSERT INTO [format_table_name("beecoin_item_purchases")] (ckey, purchase_date, item_id, item_class) VALUES ('[C.ckey]', Now(), '[id]', '[class]')")
	query_beecoin_item_purchase.warn_execute()
	qdel(query_beecoin_item_purchase)
	C.update_beecoin_items()



/datum/beecoin_shop_item/only_one/moth_wings
	name = "moth wings"
	class = "moth_wings"
	enabled = FALSE

/datum/beecoin_shop_item/only_one/moth_wings/angel
	id = "Angel"
	name = "Angel Moth Wings"
	cost = 1000
	enabled = TRUE

	icon = 'icons/mob/wings.dmi'
	icon_state = "m_wings_angel_FRONT"
	icon_dir = 1
