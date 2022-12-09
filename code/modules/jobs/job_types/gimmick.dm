/datum/job/gimmick //gimmick var must be set to true for all gimmick jobs BUT the parent
	title = JOB_NAME_GIMMICK
	flag = GIMMICK
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "no one"
	selection_color = "#dddddd"
	exp_type_department = EXP_TYPE_GIMMICK

	access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_CIV
	bank_account_department = ACCOUNT_CIV_BITFLAG
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_ASSISTANT)

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Peasant"
	allow_bureaucratic_error = FALSE
	outfit = /datum/outfit/job/gimmick
/datum/outfit/job/gimmick
	can_be_admin_equipped = FALSE // we want just the parent outfit to be unequippable since this leads to problems
// --------------------------------
// --- barber
/datum/job/gimmick/barber
	title = JOB_NAME_BARBER
	flag = BARBER
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/barber

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)

	rpg_title = "Scissorhands"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/outfit/job/gimmick/barber
	name = JOB_NAME_BARBER
	jobtype = /datum/job/gimmick/barber
	id = /obj/item/card/id/job/barber
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE
// --------------------------------
// --- stage magician
/datum/job/gimmick/stage_magician
	title = JOB_NAME_STAGEMAGICIAN
	flag = MAGICIAN
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/stage_magician

	access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)

	rpg_title = "Master Illusionist"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/magic
	)
/datum/outfit/job/gimmick/stage_magician
	name = JOB_NAME_STAGEMAGICIAN
	jobtype = /datum/job/gimmick/stage_magician
	id = /obj/item/card/id/job/stage_magician
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	head = /obj/item/clothing/head/that
	ears = /obj/item/radio/headset
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/magic=1)
	can_be_admin_equipped = TRUE
// --------------------------------
// --- psychiatrist
/datum/job/gimmick/psychiatrist
	title = JOB_NAME_PSYCHIATRIST
	flag = PSYCHIATRIST
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/psychiatrist

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_EASY)
	mind_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MEDICAL_METABOLISM)

	rpg_title = "Enchanter"


	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/outfit/job/gimmick/psychiatrist //psychiatrist doesnt get much shit, but he has more access and a cushier paycheck
	name = JOB_NAME_PSYCHIATRIST
	jobtype = /datum/job/gimmick/psychiatrist
	id = /obj/item/card/id/job/psychiatrist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	backpack_contents = list(/obj/item/choice_beacon/pet/ems=1)
	can_be_admin_equipped = TRUE
// --------------------------------
// --- vip
/datum/job/gimmick/vip
	title = JOB_NAME_VIP
	flag = CELEBRITY
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/vip

	access = list(ACCESS_MAINT_TUNNELS) //Assistants with shitloads of money, what could go wrong?
	minimal_access = list(ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_VIP
	bank_account_department = ACCOUNT_VIP_BITFLAG
	payment_per_department = list(ACCOUNT_VIP_ID = PAYCHECK_VIP)  //our power is being fucking rich

	rpg_title = "Master of Patronage"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/vip
	)
/datum/outfit/job/gimmick/vip
	name = JOB_NAME_VIP
	jobtype = /datum/job/gimmick/vip
	id = /obj/item/card/id/gold/vip
	belt = /obj/item/modular_computer/tablet/pda/vip
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads //VIP can talk loud for no reason
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	can_be_admin_equipped = TRUE
// --------------------------------
// --- mailman
/datum/job/gimmick/mailman
	title = JOB_NAME_MAILMAN
	//flag = MAILMAN // do we really need this?
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/mailman

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_CAR | DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_CAR_BITFLAG
	payment_per_department = list(ACCOUNT_CAR_ID = PAYCHECK_EASY)

	rpg_title = "Questdeliver"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/mailman
	)
/datum/outfit/job/gimmick/mailman
	name = JOB_NAME_MAILMAN
	jobtype = /datum/job/gimmick/mailman
	id = /obj/item/card/id/job/mailman
	belt = /obj/item/modular_computer/tablet/pda/mailman
	ears = /obj/item/radio/headset/headset_cargo

	backpack_contents = list(/obj/item/book/granter/spell/mailman=1, /obj/item/storage/bag/mail=1)
	// these are important; these sets are actually a set of robe for mailman special spell
	head = /obj/item/clothing/head/mailman
	uniform = /obj/item/clothing/under/misc/mailman
	shoes = /obj/item/clothing/shoes/laceup

	can_be_admin_equipped = TRUE
// mailman's special spell
/obj/item/book/granter/spell/mailman
	name =  "Oath of Mailman"
	spell = /obj/effect/proc_holder/spell/targeted/mail_track
	spellname = "Mailman's sense"
	icon_state = "scroll2"
	icon = 'icons/obj/wizard.dmi'
	desc = "Oath of mailman for the duty to deliver mails."
	remarks = list("What's the duty of a mailman?",
		"What should we do as a mailman?", "What's the goal as a mailman?",
		"Where should we go for our duty?", "How can we make our goal?","Who should we become for our duty?",
		"Whom should we deliver mails to?","When would our duty end?")

/obj/item/book/granter/spell/mailman/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		name = "empty scroll"
		desc = "Mailman's used scroll. Not worth anymore."
		icon_state = "blankscroll"

/obj/effect/proc_holder/spell/targeted/mail_track
	name = "Mailman's sense"
	desc = "Your supernatural sense to assume where the recipent of your mail is. Using this will glue your mail, and you need to find its recipient to unglue it."
	charge_max = 150
	clothes_req = CLOTH_REQ_MAILMAN
	range = -1
	include_user = TRUE
	action_icon = 'icons/obj/bureaucracy.dmi'
	action_icon_state = "mail_small"

	message_robeless_suit = "I am not prepared for this without my suit."
	message_robeless_hat = "I am not prepared for this without my hat."
	message_robeless_shoes = "I am not prepared for this without my laceup shoes."
	still_recharging_msg

/obj/effect/proc_holder/spell/targeted/mail_track/Initialize(mapload)
	. = ..()
	var/static/casting_clothes_special
	if(!length(casting_clothes_special))
		casting_clothes_special = typecacheof(list(
			/obj/item/clothing/head/mailman,
			/obj/item/clothing/head/helmet/space/plasmaman/mailman,
			/obj/item/clothing/under/plasmaman/mailman,
			/obj/item/clothing/under/misc/mailman,
			/obj/item/clothing/shoes/laceup))

	casting_clothes = casting_clothes_special

/obj/effect/proc_holder/spell/targeted/mail_track/cast(list/targets, mob/living/user = usr)
	var/obj/item/mail/mail = user.get_active_held_item()
	if(!istype(mail, /obj/item/mail))
		to_chat(user,"<span class='notice'>You need to hold a mail on your hand.</span>")
		charge_counter = charge_max // that activation must be mistake. fully recharges.
		return
	unglue_mail(mail) //failsafe when this mail becomes undelivable
	var/datum/mind/recipient = mail.recipient_ref?.resolve()
	if(!recipient)
		to_chat(user,"<span class='notice'>It looks this mail goes nowhere.</span>")
		return
	var/mob/living/recipient_body = recipient?.current
	if(!recipient_body)
		to_chat(user,"<span class='notice'>You think this mail can't be delivered.</span>")
		return
	if(!recipient_body.stat == DEAD)
		to_chat(user,"<span class='notice'>You sense of a danger... Better put this alone.</span>")
		return
	if(recipient_body == user)
		to_chat(user,"<span class='notice'>A funny idea...</span>")
		return
	if(user.get_virtual_z_level() != recipient_body.get_virtual_z_level())
		to_chat(user,"<span class='notice'>Its recipient seems to be far away.</span>")
		return

	glue_mail(mail)
	switch(get_dist(user, recipient_body))
		if(0 to 7)
			unglue_mail(mail)
			to_chat(user,"<span class='notice'>You feel your duty ends here.</span>")
		if(8 to 15)
			to_chat(user,"<span class='notice'>They must be somewhere here...</span>")
		else // if you're too far away from them, your supernatural sense of direction isn't reliable
			var/location = "nowhere"
			if(prob(3)) // 3% chance to find a specific area.
				location = lowertext(get_area_name(recipient_body, TRUE))
			else
				var/static/fake_locations = list(
					"turn around", "go back", "behind the wall", "inside of a locker",
					"arrival pod", "brig", "bridge", "medbay central", "cargo bay",
					"research division", "somewhere hallway", "centcom", "lavaland mining office",
					"spirit realm", "bearspace", "nullspace", "hyperspace", "voidspace",
					"laghter demon's belly", "lizardpeople reptilian conspiracy association"
				)
				location = prob(90) ? "[dir2text(get_dir(usr, prob(90) ? pick(GLOB.player_list - user) : recipient_body))]" : pick(fake_locations)
				// 81% (90% * 90%): tracks a proper person
				// 9% (90% * 10%): tracks a wrong person
				// 10%: shows improper location
			to_chat(user,"<span class='notice'>Hmm... [lowertext(location)]?</span>")

/obj/effect/proc_holder/spell/targeted/mail_track/proc/glue_mail(obj/item/mail)
	ADD_TRAIT(mail, TRAIT_NODROP, MAGICALLY_GLUED_ITEM_TRAIT)

/obj/effect/proc_holder/spell/targeted/mail_track/proc/unglue_mail(obj/item/mail)
	REMOVE_TRAIT(mail, TRAIT_NODROP, MAGICALLY_GLUED_ITEM_TRAIT)
