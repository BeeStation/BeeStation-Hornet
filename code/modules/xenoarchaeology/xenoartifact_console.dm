/obj/item/circuitboard/computer/xenoartifact_console
	name = "Research and Development Listing Console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoartifact_console

/obj/item/circuitboard/machine/xenoartifact_inbox
    name = "Bluespace Straythread Pad (Machine Board)"
    icon_state = "science"
    build_path = /obj/machinery/xenoartifact_inbox
    req_components = list(
        /obj/item/stack/ore/bluespace_crystal = 1,
        /obj/item/stock_parts/capacitor = 1,
        /obj/item/stock_parts/manipulator = 1,
        /obj/item/stack/cable_coil = 1)
    def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/*
    Current bandaid for shipping artifacts. Don't get too attached.
    This code, and labeler, are probably the most problematic.
*/

/obj/machinery/computer/xenoartifact_console
    name = "Research and Development Listing Console"
    desc = "A science console used to source sellers, and buyers, for various blacklisted research objects."
    icon_screen = "xenoartifact_console"
    icon_keyboard = "rd_key"
    circuit = /obj/item/circuitboard/computer/xenoartifact_console
    
    var/datum/xenoartifactseller/sellers[8]
    var/datum/xenoartifactseller/buyer/buyers[8]
    var/list/tab_index = list("Listings", "Export", "Linking")
    var/current_tab = "Listings"
    var/current_tab_info = "Here you can find listings for various research samples, usually fresh from the field. These samples aren't distrubuted by the Nanotrasen affiliated cargo system, so instead listing data is sourced from stray bluespace-threads."
    var/obj/machinery/xenoartifact_inbox/linked_inbox
    var/list/linked_machines = list()
    var/datum/techweb/linked_techweb
    var/list/sold_artifacts = list() //Actually just a general list of items you've sold, name is a legacy thing
    var/datum/bank_account/budget

/obj/machinery/computer/xenoartifact_console/Initialize()
    . = ..()
    linked_techweb = SSresearch.science_tech
    budget = SSeconomy.get_dep_account(ACCOUNT_SCI)
    for(var/I in 1 to 8)
        sellers[I] = new /datum/xenoartifactseller
        sellers[I].generate()
        buyers[I] = new /datum/xenoartifactseller/buyer
        buyers[I].generate()

/obj/machinery/computer/xenoartifact_console/interact(mob/user)
    ui_interact(user, "XenoartifactConsole")
    ..()

/obj/machinery/computer/xenoartifact_console/ui_interact(mob/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "XenoartifactConsole")
        ui.open()

/obj/machinery/computer/xenoartifact_console/ui_data(mob/user)
    var/list/data = list()
    if(budget)
        data["points"] = budget.account_balance
    data["seller"] = list()
    for(var/datum/xenoartifactseller/S in sellers)
        data["seller"] += list(list(
            "name" = S.name,
            "dialogue" = S.dialogue,
            "price" = S.price,
            "id" = S.unique_id,
        ))
    data["buyer"] = list()
    for(var/datum/xenoartifactseller/buyer/B in buyers)
        data["buyer"] += list(list(
            "name" = B.name,
            "dialogue" = B.dialogue,
            "price" = B.price,
            "id" = B.unique_id,
        ))
    data["tab_index"] = tab_index
    data["current_tab"] = current_tab
    data["tab_info"] = current_tab_info
    data["linked_machines"] = linked_machines
    data["sold_artifacts"] = sold_artifacts
    return data

/obj/machinery/computer/xenoartifact_console/ui_act(action, params) //I should probably use a switch statement for this but, the for statements look painful
    . = TRUE
    if(..())
        return

    if(action == "link_nearby")
        sync_devices()
        return

    for(var/T in tab_index)
        if(action == "set_tab_[T]" && current_tab != T)
            current_tab = T
            switch(T)
                if("Listings")//Not the best way of doing this but I can't be fucked otherwise.
                    current_tab_info = "Here you can find listings for various research samples, usually fresh from the field. These samples aren't distrubuted by the Nanotrasen affiliated cargo system, so instead listing data is sourced from stray bluespace-threads."
                if("Export")
                    current_tab_info = "Sell any export your department produces through open bluespace strings. Anonymously trade and sell ancient alien bombs, explosive slime cores, or just regular bombs."
                if("Linking")
                    current_tab_info = "Link machines to the Listing Console."
            return
        else if(action == "set_tab_[T]" && current_tab == T)
            current_tab = ""
            current_tab_info = ""
            return

    for(var/datum/xenoartifactseller/S in sellers)
        if(action == "purchase_[S.unique_id]" && linked_inbox && budget.account_balance-S.price >= 0)
            var/obj/item/xenoartifact/X = new(get_turf(linked_inbox.loc), S.difficulty)
            X.price = S.price
            sellers -= S
            budget.adjust_money(-1*S.price)
            say("Purchase complete. [budget.account_balance] credits remaining in Research Budget")
            addtimer(CALLBACK(src, .proc/generate_new_seller), (rand(1,5)*60) SECONDS)
            return
        else if(action == "purchase_[S.unique_id]" && !linked_inbox)
            say("Error. No linked hardware.")
            return
        else if(action == "purchase_[S.unique_id]" && budget.account_balance-S.price < 0)
            say("Error. Insufficient funds.")
            return

    if(action == "sell")
        if(!linked_inbox)
            say("Error. No linked hardware.")
            return
        var/info
        var/final_price = 100
        var/obj/nearby = linked_inbox.get_item_prox(1)
        for(var/obj/I in nearby)
            var/avoidtimewaste = TRUE
            for(var/datum/xenoartifactseller/buyer/B in buyers)//Check to avoid wasting time & to see if someone is actually buying that item.
                if(istype(I, B.buying))
                    avoidtimewaste = FALSE
                    buyers -= B
                    break
            if(avoidtimewaste)
                return
            if(istype(I, /obj/item/xenoartifact)) //This and it's brother is pretty iffy
                var/obj/item/xenoartifact/X = I
                final_price = X.modifier*X.price
                if(final_price < 0) //No modulate?
                    final_price = X.price*0.1
                budget.adjust_money(final_price)
                linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, final_price*10)
                info = "[X.name] sold at [station_time_timestamp()] for [final_price] credits, bought for [X.price]"
                sold_artifacts += list(info)
                say(info)
                qdel(I)
                addtimer(CALLBACK(src, .proc/generate_new_buyer), (rand(1,5)*60) SECONDS)
                return
            else if(istype(I, /obj/structure/xenoartifact))
                var/obj/structure/xenoartifact/X = I
                final_price = X.modifier*X.price
                if(final_price < 0)
                    final_price = X.price*0.1
                budget.adjust_money(final_price)
                linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, final_price*10)
                info = "[X.name] sold at [station_time_timestamp()] for [final_price] credits, bought for [X.price]"
                sold_artifacts += list(info)
                say(info)
                qdel(I)
                addtimer(CALLBACK(src, .proc/generate_new_buyer), (rand(1,5)*60) SECONDS)
                return
            else    
                final_price = 125*rand(0.3, 1.8) //This may be a point of conflict/balance
                info = "[I] sold at [station_time_timestamp()] for [final_price]. No further information available."
                sold_artifacts += list(info)
                say(info)
                qdel(I)
                addtimer(CALLBACK(src, .proc/generate_new_buyer), (rand(1,5)*60) SECONDS)
                return

    update_icon()

/obj/machinery/computer/xenoartifact_console/proc/generate_new_seller()
    var/datum/xenoartifactseller/S = new
    S.generate()
    sellers += S

/obj/machinery/computer/xenoartifact_console/proc/generate_new_buyer()
    var/datum/xenoartifactseller/buyer/B = new
    B.generate()
    buyers += B
    addtimer(CALLBACK(src, .proc/qdel, B), (rand(1,5)*60) SECONDS)

/obj/machinery/computer/xenoartifact_console/proc/sync_devices()
    for(var/obj/machinery/xenoartifact_inbox/I in oview(3,src))
        if(I.linked_console != null || I.panel_open)
            return
        if(!(linked_inbox))
            linked_inbox = I
            linked_machines += list(I.name)
            I.linked_console = src
            say("Successfully linked [I].")
            return
    say("Unable to find linkable hadrware.")

/obj/machinery/xenoartifact_inbox
    name = "bluespace straythread pad" //Science words
    desc = "This machine takes advantage of bluespace thread manipulation to highjack in-coming and out-going bluespace signals. Science uses it to deliver their very legal purchases." //All very sciencey
    icon = 'icons/obj/telescience.dmi'
    icon_state = "qpad-idle"
    circuit = /obj/item/circuitboard/machine/xenoartifact_inbox
    var/linked_console

/obj/machinery/xenoartifact_inbox/proc/get_item_prox(var/dist) //Returns a list of items & strucutres, name is funked
    var/obj/items = list()
    for(var/obj/I in oview(dist, src))
        items += list(I)
    return items

/datum/xenoartifactseller //Vendor
    var/name
    var/price
    var/dialogue
    var/unique_id //I don't know what this is used for anymore, I think it has something to do with removing sellers.
    var/difficulty //Xenoartifact shit, not exactly difficulty
    var/list/names = list("Borov", "Ivantsov", "Petrenko", "Voronin", "Kitsenko", "Plichko", "Sergei", "Kruglov", 
                        "Sakharov", "Kalugin", "Semenov", "Vasiliev", "Pavlik", "Tolik", "Kuznetsov", "Sidorovich",
                        "Strelok")
    var/list/dialogues = list("Hello, Commrade. I think I have something that might interest you.",
                            "Hello, Friend. I think I have something you might be interested in.",
                            "Commrade, I can offer you only this.",
                            "For you, my Friend, I offer this.",
                            "Commrade, this thing killed my Babushka, take it.",
                            "друг, you want?",
                            "My buddy thinks I could sell this.",
                            "Це купив би тільки дурень!",
                            "I'm pretty sure this took several years off my life, take it.",
                            "This was hard to find, but you can have it.",
                            "I found this one deep in the zone, it was a risk to get.",
                            "Що ти робиш y моєму домі?")

/datum/xenoartifactseller/proc/generate()
    name = pick(names)
    dialogue = pick(dialogues)
    price = rand(5,80) * 10
    switch(price)
        if(50 to 300)
            difficulty = BLUESPACE
        if(301 to 500)
            difficulty = PLASMA
        if(501 to 700)
            difficulty = URANIUM
        if(701 to 800)
            difficulty = BANANIUM
    price = price * rand(1.0, 1.5) //Measure of error for no particular reason
    unique_id = "[rand(1,100)][rand(1,100)][rand(1,100)]:[world.time]" //I feel like Ive missed an easier way to do this
    addtimer(CALLBACK(src, .proc/change_item), (rand(1,3)*60) SECONDS)

/datum/xenoartifactseller/proc/change_item()
    generate()

/datum/xenoartifactseller/buyer 
    var/obj/buying

/datum/xenoartifactseller/buyer/generate()
    name = pick(names)
    buying = pick(/obj/item/xenoartifact, /obj/structure/xenoartifact)
    if(buying == /obj/item/xenoartifact) //Don't bother trying to use istype here
        dialogue = "[name] is requesting: artifact::item-class"
    else if(buying == /obj/structure/xenoartifact)
        dialogue = "[name] is requesting: artifact::structure-class"
    unique_id = "[rand(1,100)][rand(1,100)][rand(1,100)]:[world.time]"
    addtimer(CALLBACK(src, .proc/change_item), (rand(1,3)*60) SECONDS)
