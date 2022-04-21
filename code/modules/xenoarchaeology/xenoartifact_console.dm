/obj/item/circuitboard/computer/xenoartifact_console
	name = "research and development listing console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/xenoartifact_console

/obj/item/circuitboard/machine/xenoartifact_inbox
    name = "bluespace straythread pad (Machine Board)"
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
    name = "research and development listing console"
    desc = "A science console used to source sellers, and buyers, for various blacklisted research objects."
    icon_screen = "xenoartifact_console"
    icon_keyboard = "rd_key"
    circuit = /obj/item/circuitboard/computer/xenoartifact_console
    
    var/list/sellers[8]
    var/list/buyers[8]
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
    var/datum/xenoartifactseller/S
    var/datum/xenoartifactseller/buyer/B
    for(var/I in 1 to 8)
        sellers[I] = new /datum/xenoartifactseller
        S = sellers[I]
        S.generate()
        buyers[I] = new /datum/xenoartifactseller/buyer
        B = buyers[I]
        B.generate()

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
    for(var/datum/xenoartifactseller/S as() in sellers)
        data["seller"] += list(list(
            "name" = S.name,
            "dialogue" = S.dialogue,
            "price" = S.price,
            "id" = S.unique_id,
        ))
    data["buyer"] = list()
    for(var/datum/xenoartifactseller/buyer/B as() in buyers)
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
        if(action == "set_tab_[T]")
            if(current_tab != T)
                current_tab = T
                switch(T)
                    if("Listings")//Not the best way of doing this but I can't be fucked otherwise.
                        current_tab_info = "Here you can find listings for various research samples, usually fresh from the field. These samples aren't distrubuted by the Nanotrasen affiliated cargo system, so instead listing data is sourced from stray bluespace-threads."
                    if("Export")
                        current_tab_info = "Sell any export your department produces through open bluespace strings. Anonymously trade and sell ancient alien bombs, explosive slime cores, or just regular bombs."
                    if("Linking")
                        current_tab_info = "Link machines to the Listing Console."
                return
            else if(current_tab == T)
        