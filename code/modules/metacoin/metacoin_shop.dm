//where you hire metacoin assassins

GLOBAL_LIST_EMPTY(metacoin_shop_items_list)

/proc/init_metacoin_shop_items_list()
	for (var/item_type in subtypesof(/datum/metacoin_shop_item))
		var/datum/metacoin_shop_item/I = new item_type
		GLOB.metacoin_shop_items_list |= I

/* commenting this out until I find a better use for it. - qwerty
/client/verb/metacoin_shop()
	set category = "OOC"
	set name = "Meta Shop"
	set desc="The shop for buying things with [CONFIG_GET(string/metacurrency_name)]s!"

	var/metacoins = src.get_metabalance()
	src.update_metacoin_items()
	var/body = "<body>"
	body += "<div style='font-size: 20px;text-align:center;'><b>[CONFIG_GET(string/metacurrency_name)] Balance</b>: [metacoins]</div><br><br>"
	body += "<div style='display:flex;flex-direction:row;justify-content:flex-start;align-items:baseline;flex-wrap:wrap;width:650px;margin:auto;'>"
	body += "<style>"
	body += ".icon-wrapper {width:114px;height:96px;text-align:center;}"
	body += ".icon {-ms-interpolation-mode:nearest-neighbor;width:96px}"
	body += ".item {width:114px;height:140px;display:inline-block;margin:6px;border:solid 2px;cursor:pointer;transition: margin 0.15s, border 0.15s; user-select: none; -ms-user-select:none;} .item:hover {margin:4px;border:solid 4px;}"
	body += ".disabled {cursor: not-allowed !important; opacity: 0.8; filter: grayscale(100%); -webkit-filter: grayscale(100%); background-color:#666;} .disabled:hover{margin:6px !important;border:solid 2px !important;}"
	body += "</style>"

	if (!GLOB.metacoin_shop_items_list.len)
		init_metacoin_shop_items_list()

	for(var/datum/metacoin_shop_item/I in GLOB.metacoin_shop_items_list)
		if (I.enabled)
			body += "<div class='item [(I.id in src.metacoin_items) ? "disabled" : ""]' onclick='window.location=\"?metacoin_buy=[I.id]\"'><div class='icon-wrapper'>[I.get_icon(src)]</div><div style='text-align:center;user-select:none; -ms-user-select:none;'>[I.name]</div><div style='text-align:center;font-weight:bold;font-size:18px;user-select:none; -ms-user-select:none;'>[I.cost]bc</div></div>"
	body += "</div>"
	body += "<br></body>"

	var/datum/browser/popup = new(usr, "metacoinshop-[REF(src)]", "<div style='font-size: 20px;' align='center'>Welcome to the [CONFIG_GET(string/metacurrency_name)] Shop!</div>", 700, 500)
	popup.set_content(body)
	popup.open(0)


/client/Topic(href, href_list)
	..()
	if(href_list["metacoin_buy"])
		var/datum/metacoin_shop_item/I
		for(var/item_type in subtypesof(/datum/metacoin_shop_item))
			I = new item_type
			if(I.id == href_list["metacoin_buy"] && I.enabled)
				I.buy(src)
				break
		metacoin_shop()

*/
