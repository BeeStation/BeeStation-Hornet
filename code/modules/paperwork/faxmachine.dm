
//The IA Agent's Fax Machine

/obj/machinery/faxmachine
	name = "fax machine"
	desc = "Used to send messages to your corporate overlords (and promptly get fired for writing fanfiction about their mother)."
	icon = 'icons/obj/library.dmi'
	icon_state = "fax"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = AREA_USAGE_EQUIP
	COOLDOWN_DECLARE(static/important_action_cooldown)

/obj/machinery/faxmachine/attack_hand(mob/living/user)
	. = ..()
	add_fingerprint(user)
	var/emagged = obj_flags & EMAGGED
	if (!COOLDOWN_FINISHED(src, important_action_cooldown))
		return

	var/associates = emagged ? "the Syndicate": "CentCom"
	var/msg = capped_multiline_input(user, "Enter a message to be faxed to [associates]", "Fax machine", )

	if (!msg)
		return

	if (!emagged)
		message_centcom(msg, user)
		override_cooldown()
		to_chat(user, "<span class='notice'>Message transmitted to Central Command.</span>")
	else
		message_syndicate(msg, user)
		override_cooldown()
		to_chat(user, "<span class='danger'>SYSERR @l(19833)of(transmit.dm): !@$ MESSAGE TRANSMITTED TO SYNDICATE COMMAND.</span>")

	user.log_talk(msg, LOG_SAY, tag = "message to [associates]")
	deadchat_broadcast("<span class='deadsay'><span class='name'>[user.real_name]</span> has messaged [associates], \"[msg]\" at <span class='name'>[get_area_name(user, TRUE)]</span>.</span>", user)
	COOLDOWN_START(src, important_action_cooldown, IMPORTANT_ACTION_COOLDOWN)

/obj/machinery/faxmachine/emag_act(mob/user)
	if (obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='danger'>You scramble the communication routing circuits!</span>")
	playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)

/obj/machinery/faxmachine/proc/override_cooldown()
	COOLDOWN_RESET(src, important_action_cooldown)
