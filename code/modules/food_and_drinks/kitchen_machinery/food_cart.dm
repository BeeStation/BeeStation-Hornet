#define STORAGE_CAPACITY 30
#define LIQUID_CAPACIY 200
#define MIXER_CAPACITY 100

/obj/machinery/food_cart
	name = "food cart"
	desc = "New generation hot dog stand."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "foodcart"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	var/food_stored = 0
	var/glasses = 0
	var/portion = 10
	var/selected_drink
	var/list/stored_food = list()
	var/obj/item/reagent_containers/mixer

/obj/machinery/food_cart/Initialize()
	. = ..()
	create_reagents(LIQUID_CAPACIY, OPENCONTAINER | NO_REACT)
	mixer = new /obj/item/reagent_containers(src, MIXER_CAPACITY)
	mixer.name = "Mixer"

/obj/machinery/food_cart/Destroy()
	QDEL_NULL(mixer)
	return ..()

/obj/machinery/food_cart/proc/isFull()
	return food_stored >= STORAGE_CAPACITY

/obj/machinery/food_cart/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, O, 0)
		return TRUE
	if(istype(O, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/DG = O
		if(!DG.reagents.total_volume) //glass is empty
			qdel(DG)
			glasses++
			to_chat(user, "<span class='notice'>[src] accepts the drinking glass, sterilizing it.</span>")
	else if(istype(O, /obj/item/reagent_containers/food/snacks))
		if(isFull())
			to_chat(user, "<span class='warning'>[src] is at full capacity.</span>")
		else
			var/obj/item/reagent_containers/food/snacks/S = O
			if(!user.transferItemToLoc(S, src))
				return
			if(stored_food[sanitize(S.name)])
				stored_food[sanitize(S.name)]++
			else
				stored_food[sanitize(S.name)] = 1
	else if(istype(O, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = O
		if(G.get_amount() >= 1)
			G.use(1)
			glasses += 4
			to_chat(user, "<span class='notice'>[src] accepts a sheet of glass.</span>")
	else if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = O
		for(var/obj/item/reagent_containers/food/snacks/S in T.contents)
			if(isFull())
				to_chat(user, "<span class='warning'>[src] is at full capacity.</span>")
				break
			else
				if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
					if(stored_food[sanitize(S.name)])
						stored_food[sanitize(S.name)]++
					else
						stored_food[sanitize(S.name)] = 1
	else if(O.is_drainable())
		return
	else
		. = ..()
	updateDialog()

/obj/machinery/food_cart/ui_interact(mob/user)
	. = ..()
	var/dat
	dat += "<br><b>STORED INGREDIENTS AND DRINKS</b><br><div class='statusDisplay'>"
	dat += "Remaining glasses: [glasses]<br>"
	dat += "Portion: <a href='?src=[REF(src)];portion=1'>[portion]</a><br>"
	for(var/i in 1 to LAZYLEN(reagents.reagent_list))
		var/datum/reagent/R = reagents.reagent_list[i]
		dat += "[R.name]: [R.volume] "
		dat += "<a href='?src=[REF(src)];disposeI=[i]'>Purge</a>"
		if (glasses > 0)
			dat += "<a href='?src=[REF(src)];pour=[i]'>Pour in a glass</a>"
		dat += "<a href='?src=[REF(src)];mix=[i]'>Add to the mixer</a><br>"
	dat += "</div><br><b>MIXER CONTENTS</b><br><div class='statusDisplay'>"
	for(var/i in 1 to LAZYLEN(mixer.reagents.reagent_list))
		var/datum/reagent/R = mixer.reagents.reagent_list[i]
		dat += "[R.name]: [R.volume] "
		dat += "<a href='?src=[REF(src)];transfer=[i]'>Transfer back</a>"
		if (glasses > 0)
			dat += "<a href='?src=[REF(src)];m_pour=[i]'>Pour in a glass</a>"
		dat += "<br>"
	dat += "</div><br><b>STORED FOOD</b><br><div class='statusDisplay'>"
	for(var/V in stored_food)
		if(stored_food[V] > 0)
			dat += "<b>[V]: [stored_food[V]]</b> <a href='?src=[REF(src)];dispense=[V]'>Dispense</a><br>"
	dat += "</div><br><a href='?src=[REF(src)];refresh=1'>Refresh</a> <a href='?src=[REF(src)];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "foodcart","Food Cart", 500, 350, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/food_cart/Topic(href, href_list)
	if(..())
		return

	if(href_list["disposeI"])
		reagents.del_reagent(reagents.reagent_list[text2num(href_list["disposeI"])]?.type)

	if(href_list["dispense"])
		if(stored_food[href_list["dispense"]]-- <= 0)
			stored_food[href_list["dispense"]] = 0
		else
			for(var/obj/O in contents)
				if(sanitize(O.name) == href_list["dispense"])
					O.forceMove(drop_location())
					break

	if(href_list["portion"])
		portion = CLAMP(input("How much drink do you want to dispense per glass?") as num, 0, 50)

	if(href_list["pour"] || href_list["m_pour"])
		if(glasses-- <= 0)
			to_chat(usr, "<span class='warning'>There are no glasses left!</span>")
			glasses = 0
		else
			var/obj/item/reagent_containers/food/drinks/drinkingglass/DG = new(loc)
			if(href_list["pour"])
				reagents.trans_id_to(DG, reagents.reagent_list[text2num(href_list["pour"])]?.type, portion)
			if(href_list["m_pour"])
				mixer.reagents.trans_id_to(DG, mixer.reagents.reagent_list[text2num(href_list["m_pour"])]?.type, portion)

	if(href_list["mix"])
		if(!reagents.trans_id_to(mixer, reagents.reagent_list[text2num(href_list["mix"])]?.type, portion))
			to_chat(usr, "<span class='warning'>[mixer] is full!</span>")

	if(href_list["transfer"])
		if(!mixer.reagents.trans_id_to(src, mixer.reagents.reagent_list[text2num(href_list["transfer"])]?.type, portion))
			to_chat(usr, "<span class='warning'>[src] is full!</span>")

	updateDialog()

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null,"window=foodcart")
	return

/obj/machinery/food_cart/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 4)
	qdel(src)

/obj/machinery/food_cart/coffee
	name = "coffee cart"
	desc = "Ah! The bitter drink of the Gods."
	icon_state = "icecream_vat"
	glasses = 10
	portion = 20

/obj/machinery/food_cart/coffee/Initialize()
	..()
	var/A = rand(0,3)
	var/B = rand(0,3)
	var/C = rand(0,3)
	var/D = rand(0,1)
	reagents.add_reagent(/datum/reagent/consumable/cafe_latte, A*20)
	reagents.add_reagent(/datum/reagent/consumable/icecoffee, B*20)
	reagents.add_reagent(/datum/reagent/consumable/soy_latte, C*20)
	reagents.add_reagent(/datum/reagent/consumable/pumpkin_latte, D*20)
	reagents.add_reagent(/datum/reagent/consumable/coffee, (10-A-B-C-D)*20)

#undef STORAGE_CAPACITY
#undef LIQUID_CAPACIY
#undef MIXER_CAPACITY
