/*

	Mailboxes/P.O. Boxes! (idk which one fits more)
	Contains mail, using it with an empty hand opens a menu for you to pull out your own mail.
	Having cargo bay access lets you pull out anyone's mail, so it doesn't get trapped in limbo

	made by candycane/etherware

*/


/obj/machinery/mailbox
	name = "official postbox"
	desc = "A small postbox stationed for easy access, containing station letters."
	icon = 'icons/obj/library.dmi'
	icon_state = "photocopier"
	density = TRUE
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 300
	integrity_failure = 100
	req_access = list(ACCESS_CARGO)
	var/list/active_slots = list()
	var/list/spam_mail = list()

/obj/machinery/mailbox/attack_hand(mob/living/carbon/user)
	var/datum/mail_slot/personal_slot
	if(allowed(user) && active_slots)
		personal_slot = input("Who's mail would you like to access?", "Mail", null) as null|anything in active_slots

	else if(!(user.real_name in active_slots))
		to_chat(user, "<span class='notice'>You look through the tabs, but you have no mail!</span>")
		return

	personal_slot ||= active_slots[user.real_name]
	personal_slot.access_mail(user)

/obj/machinery/mailbox/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/mail))
		var/datum/mail_slot/personal_slot
		var/obj/item/mail/inserting_mail = I
		var/datum/mind/recipient

		if(!inserting_mail.recipient_ref)
			spam_mail += inserting_mail
			inserting_mail.forceMove(src)
			return

		recipient = inserting_mail.recipient_ref.resolve()
		if(!recipient)
			return

		if(!(recipient.real_name in active_slots))
			personal_slot = new(src, user)
			active_slots[recipient.real_name] = personal_slot
		else
			personal_slot = active_slots[recipient.real_name]

		if(!personal_slot)
			to_chat(user, "<span class='warning'>You can't find a box!</span>")
			return

			personal_slot.insert_mail(I)

/datum/mail_slot
	/// the name of the person able to open this
	var/name
	var/list/mail_stack = list()
	var/locked = FALSE

/datum/mail_slot/New(mob/living/carbon/reader)
	name = reader.name

/datum/mail_slot/proc/insert_mail(obj/item/mail/mail)
	mail_stack += mail
	mail.forceMove(src)

/datum/mail_slot/proc/access_mail(mob/living/carbon/reader)
	var/take_out = input("Mail to take out?", "Mail", null) as null|anything in mail_stack
	if(!take_out)
		return
	reader.put_in_hands(take_out)
	to_chat(reader, "You take \the [take_out] out of \the [src].")
	mail_stack -= take_out

	if(length(mail_stack))
		qdel(src)
