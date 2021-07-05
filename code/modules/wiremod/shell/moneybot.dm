/**
 * # Money Bot
 *
 * Immobile (but not dense) shell that can receive and dispense money.
 */
/obj/structure/money_bot
	name = "money bot"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_large"

	density = FALSE
	light_range = FALSE

	var/stored_money = 0

/obj/structure/money_bot/deconstruct(disassembled)
	new /obj/item/holochip(drop_location(), stored_money)
	return ..()

/obj/structure/money_bot/proc/add_money(to_add)
	stored_money += to_add
	SEND_SIGNAL(src, COMSIG_MONEYBOT_ADD_MONEY, to_add)

/obj/structure/money_bot/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/money_bot(),
		new /obj/item/circuit_component/money_dispenser()
	), SHELL_CAPACITY_LARGE)

/obj/structure/money_bot/wrench_act(mob/living/user, obj/item/tool)
	anchored = !anchored
	tool.play_tool_sound(src)
	balloon_alert(user, "You [anchored?"secure":"unsecure"] [src].")
	return TRUE


/obj/item/circuit_component/money_dispenser
	display_name = "Money Dispenser"
	display_desc = "Used to dispense money from the money bot. Money is taken from the internal storage of money."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The amount of money to dispense
	var/datum/port/input/dispense_amount

	/// Outputs a signal when it fails to output any money.
	var/datum/port/output/on_fail

	var/obj/structure/money_bot/attached_bot

/obj/item/circuit_component/money_dispenser/Initialize()
	. = ..()
	dispense_amount = add_input_port("Amount", PORT_TYPE_NUMBER)
	on_fail = add_output_port("On Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/money_dispenser/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/money_bot))
		attached_bot = shell

/obj/item/circuit_component/money_dispenser/unregister_shell(atom/movable/shell)
	attached_bot = null
	return ..()

/obj/item/circuit_component/money_dispenser/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!attached_bot)
		return

	var/to_dispense = clamp(dispense_amount.input_value, 0, attached_bot.stored_money)
	if(!to_dispense)
		on_fail.set_output(COMPONENT_SIGNAL)
		return
	attached_bot.add_money(-to_dispense)
	new /obj/item/holochip(drop_location(), to_dispense)

/obj/item/circuit_component/money_dispenser/Destroy()
	dispense_amount = null
	attached_bot = null
	return ..()

/obj/item/circuit_component/money_bot
	display_name = "Money Bot"
	display_desc = "Used to receive input signals when money is inserted into the money bot shell and also keep track of the total money in the shell."
	var/obj/structure/money_bot/attached_bot

	/// Total money in the shell
	var/datum/port/output/total_money
	/// Amount of the last money inputted into the shell
	var/datum/port/output/money_input
	/// Trigger for when money is inputted into the shell
	var/datum/port/output/money_trigger

/obj/item/circuit_component/money_bot/Initialize()
	. = ..()
	total_money = add_output_port("Total Money", PORT_TYPE_NUMBER)
	money_input = add_output_port("Last Input Money", PORT_TYPE_NUMBER)
	money_trigger = add_output_port("Money Input", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/money_bot/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/money_bot))
		attached_bot = shell
		total_money.set_output(attached_bot.stored_money)
		RegisterSignal(shell, COMSIG_PARENT_ATTACKBY, .proc/handle_money_insert)
		RegisterSignal(shell, COMSIG_MONEYBOT_ADD_MONEY, .proc/handle_money_update)

/obj/item/circuit_component/money_bot/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_MONEYBOT_ADD_MONEY,
	))
	total_money.set_output(null)
	attached_bot = null
	return ..()

/obj/item/circuit_component/money_bot/Destroy()
	attached_bot = null
	total_money = null
	money_input = null
	money_trigger = null
	return ..()

/obj/item/circuit_component/money_bot/proc/handle_money_insert(atom/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER
	if(!attached_bot || !iscash(item))
		return

	var/amount_to_insert = item.get_item_credit_value()
	if(!amount_to_insert)
		balloon_alert(attacker, "this has no value!")
		return

	attached_bot.add_money(amount_to_insert)
	balloon_alert(attacker, "inserted [amount_to_insert] credits.")
	money_input.set_output(amount_to_insert)
	money_trigger.set_output(COMPONENT_SIGNAL)
	qdel(item)

/obj/item/circuit_component/money_bot/proc/handle_money_update(atom/source)
	SIGNAL_HANDLER
	if(attached_bot)
		total_money.set_output(attached_bot.stored_money)
