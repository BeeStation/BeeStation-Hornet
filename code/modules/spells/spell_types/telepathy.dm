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
			to_chat(user, "<span class='warning'>It appears the target's mind is ironclad! No getting a message in there!</span>")
			return
		var/msg = tgui_input_text(usr, "What do you wish to tell [M]?", "Telepathy")
		if(!length(msg))
			revert_cast(user)
			return
		if(CHAT_FILTER_CHECK(msg))
			to_chat(user, "<span class='warning'>Your message contains forbidden words.</span>")
			return
		msg = user.treat_message_min(msg)
		log_directed_talk(user, M, msg, LOG_SAY, "[name]")
		to_chat(user, "<span class='[boldnotice]'>You transmit to [M]:</span> <span class='[notice]'>[msg]</span>")
		if(!M.anti_magic_check(magic_check, holy_check)) //hear no evil
			to_chat(M, "<span class='[boldnotice]'>You hear something behind you talking...</span> <span class='[notice]'>[msg]</span>")
			M.balloon_alert(M, "You hear a voice in your head...")
		for(var/ded in GLOB.dead_mob_list)
			if(!isobserver(ded))
				continue
			var/follow_rev = FOLLOW_LINK(ded, user)
			var/follow_whispee = FOLLOW_LINK(ded, M)
			to_chat(ded, "[follow_rev] <span class='[boldnotice]'>[user] [name]:</span> <span class='[notice]'>\"[msg]\" to</span> [follow_whispee] <span class='name'>[M]</span>")
