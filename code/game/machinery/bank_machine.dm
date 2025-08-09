#define SIPHON_AMOUNT 500

/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon_screen = "vault"
	icon_keyboard = "ratvar_key1"
	idle_power_usage = 100
	processing_flags = START_PROCESSING_MANUALLY
	var/next_warning = 0
	var/obj/item/radio/radio
	var/radio_channel = RADIO_CHANNEL_COMMON
	var/minimum_time_between_warnings = 400
	//Variables for siphoning credits
	var/siphoning_credits = 0
	var/list/list_of_budgets = list()

/obj/machinery/computer/bank_machine/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.recalculateChannels()

	for(var/datum/bank_account/department/each_account in SSeconomy.budget_accounts)
		if(!each_account.nonstation_account)
			list_of_budgets += each_account


/obj/machinery/computer/bank_machine/Destroy()
	end_siphon()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/computer/bank_machine/attackby(obj/item/I, mob/user)
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		united_budget_money_insertion(I, user)
		return ..()
	money_insertion(I, user)
	return ..()

/obj/machinery/computer/bank_machine/proc/united_budget_money_insertion(obj/item/I, mob/user)
	var/value
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	else if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		value = H.credits
	if(!value)
		return
	var/datum/bank_account/united_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	united_budget.adjust_money(value)
	to_chat(user, span_notice("You deposit [value] into a station budget account.</span>"))
	qdel(I)

/obj/machinery/computer/bank_machine/proc/money_insertion(obj/item/I, mob/user)
	var/list/budget_choice = list()
	for(var/datum/bank_account/department/budget as anything in list_of_budgets)
		budget_choice += budget.department_id
	budget_choice += "All"
	var/targeted_budget = tgui_input_list(user, "Into which budget would you like to deposit the money?", "Money deposit", budget_choice)
	if(!targeted_budget)
		return

	var/value
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	else if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		value = H.credits
	if(!value)
		return

	if(!(targeted_budget == "All"))
		var/datum/bank_account/selected_budget = SSeconomy.get_budget_account(targeted_budget)
		selected_budget.adjust_money(value)
		to_chat(user, span_notice("You deposit [value] into the [selected_budget.account_holder]."))
	else
		var/money_amount_modulo = (value % length(list_of_budgets))
		var/rounded_money_amount = ((value - money_amount_modulo) / length(list_of_budgets))
		if(money_amount_modulo)
			var/datum/bank_account/first_budget_card = list_of_budgets[1]
			first_budget_card.adjust_money(money_amount_modulo) //If we have an indivisible amount of money, dump it in the first budget.
		for(var/datum/bank_account/budget_department_id as anything in list_of_budgets)
			budget_department_id.adjust_money(rounded_money_amount)
		to_chat(user, span_notice("You deposit [value] into all station budgets."))
	qdel(I)

/obj/machinery/computer/bank_machine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/bank_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BankMachine")
		ui.set_autoupdate(TRUE) //Automatic money amount updating.
		ui.open()

/obj/machinery/computer/bank_machine/ui_data(mob/user)
	var/list/data = list()
	var/total_balance = 0

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		var/datum/bank_account/united_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		total_balance = united_budget.account_balance
	else
		for(var/datum/bank_account/each as anything in list_of_budgets)
			total_balance += each.account_balance

	data["current_balance"] = total_balance
	data["siphoning"] = (datum_flags & DF_ISPROCESSING)
	data["station_name"] = station_name()

	return data

/obj/machinery/computer/bank_machine/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("siphon")
			say("Siphon of station credits has begun!")
			start_siphon()
			. = TRUE
		if("halt")
			say("Station credit withdrawal halted.")
			end_siphon()
			. = TRUE

/obj/machinery/computer/bank_machine/proc/start_siphon()
	START_PROCESSING(SSmachines, src)

/obj/machinery/computer/bank_machine/proc/end_siphon()
	if(!siphoning_credits)
		return FALSE
	new /obj/item/holochip(drop_location(), siphoning_credits) //get the loot
	siphoning_credits = 0
	STOP_PROCESSING(SSmachines, src)
	return TRUE

/obj/machinery/computer/bank_machine/process(delta_time)
	..()
	if(machine_stat & (BROKEN|NOPOWER))
		say("Insufficient power. Halting siphon.")
		return end_siphon()

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		var/amount_to_siphon = SIPHON_AMOUNT * delta_time
		var/datum/bank_account/united_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		if(!united_budget.has_money(amount_to_siphon))
			say("All station budgets depleted. Halting siphon.")
			return end_siphon()
		siphoning_credits += amount_to_siphon
		united_budget.adjust_money(-amount_to_siphon)
	else
		var/empty_budgets = 0
		var/amount_to_siphon = round((SIPHON_AMOUNT * delta_time) / length(list_of_budgets))
		for(var/datum/bank_account/target_budget as anything in list_of_budgets)
			if(!target_budget.has_money(amount_to_siphon))
				empty_budgets += 1
				continue
			if(empty_budgets >= length(list_of_budgets))
				say("All station budgets depleted. Halting siphon.")
				return end_siphon()
			siphoning_credits += amount_to_siphon
			target_budget.adjust_money(-amount_to_siphon)

	playsound(src, 'sound/items/poster_being_created.ogg', 100, TRUE)
	if(next_warning < world.time && prob(15))
		var/area/A = get_area(loc)
		var/message = "Unauthorized credit withdrawal underway in [initial(A.name)]!!"
		radio.talk_into(src, message, radio_channel)
		next_warning = world.time + minimum_time_between_warnings

#undef SIPHON_AMOUNT
