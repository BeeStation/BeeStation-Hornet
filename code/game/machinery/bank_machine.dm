#define SIPHON_MONEY_COUNT 100
#define SIPHON_AMOUNT SIPHON_MONEY_COUNT * delta_time

/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon_screen = "vault"
	icon_keyboard = "ratvar_key1"
	idle_power_usage = 100
	var/next_warning = 0
	var/obj/item/radio/radio
	var/radio_channel = RADIO_CHANNEL_COMMON
	var/minimum_time_between_warnings = 400
	//Variables for siphoning credits
	var/siphoning_credits = 0
	var/list/list_of_budgets = list()
	var/siphoning = FALSE

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
	var/value = 0
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	else if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		value = H.credits
	if(value)
		if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
			var/datum/bank_account/united_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			united_budget.adjust_money(value)
			to_chat(user, "<span class='notice'>You deposit [value] into a station budget account.</span>")
		else
			var/rounded_money_amount = round(value / length(list_of_budgets))
			for(var/datum/bank_account/budget_department_id as anything in list_of_budgets)
				budget_department_id.adjust_money(rounded_money_amount)
			to_chat(user, "<span class='notice'>You deposit [value] into all station budgets.</span>")
		qdel(I)
		return
	return ..()

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
	data["siphoning"] = siphoning
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
	siphoning = TRUE

/obj/machinery/computer/bank_machine/proc/end_siphon()
	if(!siphoning || !siphoning_credits)
		return
	siphoning = FALSE
	new /obj/item/holochip(drop_location(), siphoning_credits) //get the loot
	siphoning_credits = 0


/obj/machinery/computer/bank_machine/process(delta_time)
	var/empty_budgets = 0
	..()
	if(!siphoning)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		say("Insufficient power. Halting siphon.")
		end_siphon()
		return

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNITED_BUDGET))
		var/datum/bank_account/united_budget = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		if(!united_budget.has_money(SIPHON_AMOUNT * 8 )) //8 is the number of stationside budgets
			say("All station budgets depleted. Halting siphon.")
			end_siphon()
			return
		siphoning_credits += SIPHON_AMOUNT * 8
		united_budget.adjust_money(-(SIPHON_AMOUNT * 8))
	else
		for(var/datum/bank_account/target_budget as anything in list_of_budgets)
			if(!target_budget.has_money(SIPHON_AMOUNT))
				empty_budgets += 1
				continue
			if(empty_budgets >= length(list_of_budgets))
				say("All station budgets depleted. Halting siphon.")
				end_siphon()
				return
			siphoning_credits += SIPHON_AMOUNT
			target_budget.adjust_money(-(SIPHON_AMOUNT))

	playsound(src, 'sound/items/poster_being_created.ogg', 100, TRUE)
	if(next_warning < world.time && prob(15))
		var/area/A = get_area(loc)
		var/message = "Unauthorized credit withdrawal underway in [initial(A.name)]!!"
		radio.talk_into(src, message, radio_channel)
		next_warning = world.time + minimum_time_between_warnings

#undef SIPHON_MONEY_COUNT
#undef SIPHON_AMOUNT
