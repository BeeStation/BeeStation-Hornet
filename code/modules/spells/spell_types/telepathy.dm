/obj/effect/proc_holder/spell/targeted/telepathy
	name = "Telepathy"
	desc = "Telepathically transmits a message to the target."
	charge_max = 0
	clothes_req = 0
	range = 7
	include_user = 0
	action_icon = 'icons/hud/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_spell"
	var/notice = "notice"
	var/boldnotice = "boldnotice"
	var/magic_check = FALSE
	var/holy_check = FALSE

/obj/effect/proc_holder/spell/targeted/telepathy/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/M in targets)
		if(istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			to_chat(user, span_warning("It appears the target's mind is ironclad! No getting a message in there!"))
			return
		var/msg = tgui_input_text(usr, "What do you wish to tell [M]?", "Telepathy")
		if(!length(msg))
			revert_cast(user)
			return
		if(CHAT_FILTER_CHECK(msg))
			to_chat(user, span_warning("Your message contains forbidden words."))
			return
		msg = user.treat_message_min(msg)
		log_directed_talk(user, M, msg, LOG_SAY, "[name]")
		to_chat(user, "[span_boldnotice("You transmit to [M]:")] [span_notice(msg)]")
		if(!M.anti_magic_check(magic_check, holy_check)) //hear no evil
			to_chat(M, "[span_boldnotice("You hear something behind you talking...")] [span_notice(msg)]")
			M.balloon_alert(M, "You hear a voice in your head...")
		for(var/ded in GLOB.dead_mob_list)
			if(!isobserver(ded))
				continue
			var/follow_rev = FOLLOW_LINK(ded, user)
			var/follow_whispee = FOLLOW_LINK(ded, M)
			to_chat(ded, "[follow_rev] [span_boldnotice("[user] [name]:")] [span_notice(""\[msg]\" to")] [follow_whispee] [span_name(M)]")
