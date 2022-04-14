
//The IA Agent's Fax Machine

/obj/machinery/faxmachine
	name = "fax machine"
	desc = "Used to send messages to your corporate overlords (and promptly get fired for writing fanfiction about their mothers)."
	circuit = /obj/item/circuitboard/machine/faxmachine
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	density = TRUE
	idle_power_usage = 30
	active_power_usage = 200
	COOLDOWN_DECLARE(static/important_action_cooldown)

/obj/machinery/faxmachine/attack_hand(mob/living/user)
	. = ..()
	add_fingerprint(user)
	if(!COOLDOWN_FINISHED(src, important_action_cooldown))
		to_chat(user, "<span class='warning'>The subspace communications transmissions system is on cooldown!</span>")
		return
	if(panel_open)
		return

	var/associates = (obj_flags & EMAGGED) ? "the Syndicate" : "Central Command"
	var/msg = capped_multiline_input(user, "Enter a message to be faxed to [associates]", "Fax machine", )

	if(!msg)
		return

	if(!(obj_flags & EMAGGED))
		message_centcom(msg, user)
		to_chat(user, "<span class='notice'>Message transmitted to Central Command.</span>")
	else
		message_syndicate(msg, user)
		to_chat(user, "<span class='danger'>SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND.</span>")

	override_cooldown()
	user.log_talk(msg, LOG_SAY, tag = "message to [associates]")
	deadchat_broadcast("<span class='deadsay'><span class='name'>[user.real_name]</span> has messaged [associates], \"[msg]\" at <span class='name'>[get_area_name(user, TRUE)]</span>.</span>", user)
	COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)

/obj/machinery/faxmachine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)

/obj/machinery/faxmachine/proc/override_cooldown()
	COOLDOWN_RESET(src, important_action_cooldown)

/obj/machinery/faxmachine/attackby(obj/item/G, mob/user, params)
	if(default_unfasten_wrench(user, G))
		return
	if(default_deconstruction_screwdriver(user, "faxopen", "fax", G))
		return
	if(default_deconstruction_crowbar(G))
		return
