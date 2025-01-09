/obj/machinery/computer/chef_order
	name = "Produce Orders Console"
	desc = "An interface for ordering fresh produce and other. A far more expensive option than the botanists, but oh well."
	icon_screen = "request"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/computer/chef_order
	light_color = LIGHT_COLOR_ORANGE

	COOLDOWN_DECLARE(order_cooldown)
	var/static/list/order_datums = list()
	var/list/grocery_list = list()

	var/obj/item/radio/headset/headset_cargoradio
	var/radio_channel = RADIO_CHANNEL_SUPPLY

/obj/machinery/computer/chef_order/Initialize()
	. = ..()
	radio = new(src)
	radio.frequency = FREQ_SUPPLY
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

	if(!order_datums.len)
		for(var/path in subtypesof(/datum/orderable_item))
			order_datums += new path

/obj/machinery/computer/chef_order/Destroy()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/computer/chef_order/proc/get_total_cost()
	. = 0
	for(var/datum/orderable_item/item as anything in grocery_list)
		for(var/i in 1 to grocery_list[item]) //for how many times we bought it
			. += item.cost_per_order //add its price

/obj/machinery/computer/chef_order/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProduceConsole", name)
		ui.open()

/obj/machinery/computer/chef_order/ui_data(mob/user)
	. = ..()
	.["off_cooldown"] = COOLDOWN_FINISHED(src, order_cooldown)

/obj/machinery/computer/chef_order/ui_static_data(mob/user)
	. = ..()
	.["total_cost"] = get_total_cost()
	.["order_datums"] = list()
	for(var/datum/orderable_item/item as anything in order_datums)
		.["order_datums"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"cat" = item.category_index,
			"ref" = REF(item),
			"cost" = item.cost_per_order,
			"amt" = grocery_list[item]
			))

/obj/machinery/computer/chef_order/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return
	var/mob/living/chef = usr
	//this is null if the action doesn't need it (purchase, quickpurchase)
	var/datum/orderable_item/wanted_item = locate(params["target"]) in order_datums
	switch(action)
		if("cart_set")
			grocery_list[wanted_item] = params["amt"]
			if(!grocery_list[wanted_item])
				grocery_list -= wanted_item
			update_static_data(chef)
		if("purchase")
			if(!grocery_list.len || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/obj/item/card/id/chef_card = chef.get_idcard(TRUE)
			if(!chef_card || !chef_card.registered_account)
				say("No bank account detected!")
				return
			var/final_cost = get_total_cost()
			if(!chef_card.registered_account.adjust_money(-final_cost))
				say("Sorry, but you do not have enough money.")
				return
			say("Thank you for your purchase! It will arrive on the next cargo shuttle!")
			var/message = "The kitchen has ordered groceries which will arrive on the cargo shuttle! Please make sure it gets to them as soon as possible!"
			radio.talk_into(src, message, radio_channel)
			COOLDOWN_START(src, order_cooldown, 60 SECONDS)
			for(var/datum/orderable_item/ordered_item in grocery_list)
				if(ordered_item in SSsupply.chef_groceries)
					SSsupply.chef_groceries[ordered_item] += grocery_list[ordered_item]
				else
					SSsupply.chef_groceries[ordered_item] = grocery_list[ordered_item]
			grocery_list.Cut()
			update_static_data(chef)
		if("express")
			if(!grocery_list.len || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/obj/item/card/id/chef_card = chef.get_idcard(TRUE)
			if(!chef_card || !chef_card.registered_account)
				say("No bank account detected!")
				return
			var/final_cost = get_total_cost()
			final_cost *= 2
			if(!chef_card.registered_account.adjust_money(-final_cost))
				say("Sorry, but you do not have enough money. Remember, Express upcharges the cost!")
				return
			say("Thank you for your purchase! Please note: The charge of this purchase and machine cooldown has been doubled!")
			COOLDOWN_START(src, order_cooldown, 120 SECONDS)
			var/obj/structure/closet/supplypod/bluespacepod/pod = new()
			pod.explosionSize = list(0,0,0,0)
			for(var/datum/orderable_item/item as anything in grocery_list)//every order
				for(var/amt in 1 to grocery_list[item])//every order amount
					new item.item_instance.type(pod)
			var/turf/landing_location = get_turf(chef)
			new /obj/effect/pod_landingzone(landing_location, pod)
			grocery_list.Cut()
			update_static_data(chef)
	. = TRUE
