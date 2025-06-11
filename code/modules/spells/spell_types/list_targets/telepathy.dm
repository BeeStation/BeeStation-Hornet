/datum/action/spell/telepathy
	name = "Telepathy"
	desc = "Telepathically transmits a message to the target."
	icon_icon = 'icons/hud/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"
	requires_target = TRUE

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = NONE

	/// The message we send to the next person via telepathy.
	var/message
	/// The span surrounding the telepathy message
	var/telepathy_span = "notice"
	/// The bolded span surrounding the telepathy message
	var/bold_telepathy_span = "boldnotice"
	/// Only dedicated for revenants
	var/use_runechat_telepathy = FALSE

/datum/action/spell/telepathy/pre_cast(mob/user, atom/target)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	message = tgui_input_text(owner, "What do you wish to whisper to [target]?", "[src]")
	if(QDELETED(src) || QDELETED(owner) || QDELETED(target) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST

	if(!message)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/spell/telepathy/is_valid_spell(mob/user, atom/target)
	return ..() && isliving(target)

/datum/action/spell/telepathy/on_cast(mob/living/user, mob/living/target)
	. = ..()
	message = user.treat_message_min(message)
	log_directed_talk(owner, target, message, LOG_SAY, name)

	var/formatted_message = "<span class='[telepathy_span]'>[message]</span>"

	to_chat(owner, "<span class='[bold_telepathy_span]'>You transmit to [target]:</span> [formatted_message]")
	to_chat(target, "<span class='[bold_telepathy_span]'>You hear something behind you talking...</span> [formatted_message]")
	if(use_runechat_telepathy)
		owner.create_private_chat_message(message="...[message]",
									message_language = /datum/language/metalanguage,
									hearers=list(owner, target))
	else
		target.balloon_alert(target, "You hear a voice in your head...")
	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = "<span class='[bold_telepathy_span]'>[owner] [src]:</span>"
		var/to_link = FOLLOW_LINK(ghost, target)
		var/to_mob_name = "<span class='name'>[target]</span>"

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
