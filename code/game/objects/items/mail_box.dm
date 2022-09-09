/*

	Mailboxes/P.O. Boxes! (idk which one fits more)
	Contains mail, using it with an empty hand opens a menu for you to pull out your own mail.
	Having cargo bay access lets you pull out anyone's mail, so it doesn't get trapped in limbo

	made by candycane/etherware

*/


/obj/structure/mailbox
	name = "official postbox"
	desc = "A small postbox stationed for easy access, containing station letters."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mailbox"
	density = TRUE
	max_integrity = 1000
	req_access = list(ACCESS_CARGO)  // can look thru anyones mail
	var/list/active_slots = list()
	var/list/spam_mail = list()

/obj/machinery/mailbox/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A small ticker on the side reads\nUSR - [length(active_slots)]\nSPM - [length(spam_mail)]"
	if(active_slots[user.real_name])
		. += "<span class='notice'>You spot a green light above your tray!</span>"

/obj/machinery/mailbox/attack_hand(mob/living/carbon/user)
	. = ..()
	if(!length(active_slots))
		to_chat(user, "<span class='notice'>All of the trays are empty!</span>")
		return
	var/datum/mail_slot/personal_slot
	if(allowed(user) && active_slots)
		var/manual_name = input("Who's mail would you like to access?", "Mail", null) as null|anything in active_slots
		if(!manual_name)
			return
		personal_slot = active_slots[manual_name]

	else if(!(user.real_name in active_slots))
		to_chat(user, "<span class='notice'>You look through the tabs, but you have no mail!</span>")
		return

	personal_slot ||= active_slots[user.real_name]
	if(personal_slot.access_mail(user))
		active_slots -= user.real_name

/obj/machinery/mailbox/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/mail))
		var/datum/mail_slot/personal_slot
		var/obj/item/mail/inserting_mail = I

		if(!inserting_mail.recipient_ref)
			spam_mail += inserting_mail
			inserting_mail.forceMove(src)
			to_chat(user, "<span class='notice'>You slip the mail into the spam box.</span>")
			return

		var/datum/mind/recipient = inserting_mail.recipient_ref.resolve()
		if(!recipient)
			return

		var/mail_to = recipient.name

		if(!(mail_to in active_slots))
			personal_slot = new()
			active_slots[mail_to] = personal_slot
		else
			personal_slot = active_slots[mail_to]

		if(!personal_slot)
			to_chat(user, "<span class='warning'>You can't find a box!</span>")
			return

		to_chat(user, "<span class='notice'>You slip the mail into the proper box.</span>")
		personal_slot.insert_mail(I)

/obj/strucutre/mailbox/AltClick(mob/user)
	. = ..()
	var/picked_mail = input("What spam mail would you like to access?", "Mail", null) as null|anything in spam_mail
	user.put_in_hands(picked_mail)
	to_chat(user, "<span class='notice'>You take the mail out from the spam folder.</spam>")

/datum/mail_slot
	/// the name of the person able to open this
	var/list/mail_stack = list()
	var/locked = FALSE

/datum/mail_slot/proc/insert_mail(obj/item/mail/mail)
	mail_stack += mail
	mail.forceMove(src)

/datum/mail_slot/proc/access_mail(mob/living/carbon/reader)
	var/take_out = input("Mail to take out?", "Mail", null) as null|anything in mail_stack
	if(!take_out)
		return
	reader.put_in_hands(take_out)
	to_chat(reader, "You take \the [take_out] out of the slot.")
	mail_stack -= take_out

	if(!length(mail_stack))
		return TRUE // time to clear entry
