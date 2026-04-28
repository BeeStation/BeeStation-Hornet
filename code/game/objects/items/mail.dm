/// Mail is tamper-evident and unresealable, postmarked by CentCom for an individual recepient.
/obj/item/mail
	name = "mail"
	gender = NEUTER
	desc = "An officially postmarked, tamper-evident parcel powered by bluespace technology and regulated by CentCom, it's made of rather high-quality materials."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mail_small"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/paper_pickup.ogg'
	throwforce = 0
	throw_range = 1
	throw_speed = 1
	/// Destination tagging for the mail sorter.
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	/// Weak reference to who this mail is for and who can open it.
	var/sort_tag = 0
	/// How many goodies this mail contains.
	var/datum/weakref/recipient_ref
	/// Goodies which can be given to anyone. The base weight for cash is 56. For there to be a 50/50 chance of getting a department item, they need 56 weight as well.
	var/goodie_count = 1

	// List of weird things and contraband that can come in the mail
	var/static/list/generic_goodies = list(
		/obj/item/stack/spacecash/c500 = 2,
		/obj/item/stack/spacecash/c1000 = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/stack/sheet/telecrystal = 1,
		/obj/item/knife = 3,
		/obj/item/knife/ritual = 1,
		/obj/item/clothing/neck/heretic_focus = 1,
		/obj/item/clothing/suit/costume/vapeshirt = 1,
		/obj/item/clothing/suit/costume/nerdshirt = 1,
		/obj/item/clothing/under/syndicate/combat = 1,
		/obj/item/gun/ballistic/automatic/pistol/service = 1,
		/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag = 1,
		/obj/item/ammo_box/magazine/m45 = 1,
		/obj/item/gun/energy/floragun = 1,
		/obj/item/gun/energy/ionrifle = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/storage/belt = 1,
		/obj/item/clothing/gloves/color/yellow = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/clothing/accessory/holster = 1,
		/obj/item/clothing/head/cone = 1,
		/obj/item/clothing/head/beanie/green = 1,
		/obj/item/clothing/head/beanie/orange = 1,
		/obj/item/clothing/head/beanie/red = 1,
		/obj/item/clothing/head/beanie/purple = 1,
		/obj/item/clothing/shoes/laceup = 1,
		/obj/item/storage/belt/military/army = 1,
		/obj/item/tank/jetpack/carbondioxide = 1,
		/obj/item/tank/jetpack/suit = 1,
		/obj/item/clothing/ears/headphones = 1,
		/obj/item/camera = 1,
		/obj/item/gps = 1,
		/obj/item/soap = 1,
		/obj/item/clothing/glasses/sunglasses/advanced = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool = 1,
		/obj/item/wrench = 1,
		/obj/item/multitool = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/gun/ballistic/automatic/pistol/service = 1,
		/obj/item/ammo_box/magazine/recharge/service = 1,
		/obj/item/powertool/hand_drill = 1,
		/obj/item/powertool/jaws_of_life = 1,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/scalpel/advanced = 1,
		/obj/item/switchblade/plastitanium = 1
	)

	/// Overlays (pure fluff), Does the letter have the postmark overlay?
	/// Does the letter have postmarks?
	var/postmarked = TRUE
	/// Does the letter have a stamp overlay?
	var/stamped = TRUE
	/// List of all stamp overlays on the letter.
	var/list/stamps = list()
	/// Maximum number of stamps on the letter.
	var/stamp_max = 1
	/// Physical offset of stamps on the object. X direction.
	var/stamp_offset_x = 0
	/// Physical offset of stamps on the object. Y direction.
	var/stamp_offset_y = 2

/obj/item/mail/envelope
	name = "envelope"
	icon_state = "mail_large"
	goodie_count = 2
	stamp_max = 2
	stamp_offset_y = 5

/obj/item/mail/examine(mob/user)
	. = ..()

	var/datum/mind/recipient
	if(recipient_ref)
		recipient = recipient_ref.resolve()
	var/msg = span_notice("<i>You notice the postmarking on the front of the mail...</i>")
	if(recipient)
		msg += "\n[span_info("Certified NT mail for [recipient].")]"
	else
		msg += "\n[span_info("Certified mail for [GLOB.station_name].")]"
	. += "\n[msg]"


/obj/item/mail/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))
	AddElement(/datum/element/item_scaling, 0.75, 1)

	// Icons
	// Add some random stamps.
	if(stamped)
		var/stamp_count = rand(1, stamp_max)
		for(var/i in 1 to stamp_count)
			stamps += list("stamp_[rand(2, 10)]")
	update_icon()

/obj/item/mail/update_overlays()
	. = ..()
	var/bonus_stamp_offset = 0
	for(var/stamp in stamps)
		var/image/stamp_image = image(
			icon = icon,
			icon_state = stamp,
			pixel_x = stamp_offset_x,
			pixel_y = stamp_offset_y + bonus_stamp_offset
		)
		stamp_image.appearance_flags |= RESET_COLOR
		add_overlay(stamp_image)
		bonus_stamp_offset -= 5

	if(postmarked)
		var/image/postmark_image = image(
			icon = icon,
			icon_state = "postmark",
			pixel_x = stamp_offset_x + rand(-3, 1),
			pixel_y = stamp_offset_y + rand(bonus_stamp_offset + 3, 1)
		)
		postmark_image.appearance_flags |= RESET_COLOR
		add_overlay(postmark_image)

/obj/item/mail/attackby(obj/item/W, mob/user, params)
	// Destination tagging
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/destination_tag = W

		if(sort_tag != destination_tag.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[destination_tag.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, 1)

/obj/item/mail/attack_self(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			if(!IS_CHANGELING(user) && !(user?.mind?.has_antag_datum(/datum/antagonist/obsessed)))
				to_chat(user, span_notice("You can't open somebody else's mail! That's <em>immoral</em>!"))
				return
			var/can_open = FALSE
			var/datum/antagonist/obsessed/obs_datum = locate() in user?.mind?.antag_datums
			if(obs_datum)
				if(obs_datum.trauma.obsession.name != recipient.name)
					to_chat(user, span_notice("This <em>worthless</em> piece of parchment isn't adressed to your beloved!"))
					return
				can_open = TRUE
			if(user.real_name != recipient.name && !can_open)
				to_chat(user, span_warning("We must keep our disguise intact."))  // cuz your disguise cant open the mail so you shouldnt either
				return

	user.visible_message("[user] start to unwrap a package...", \
			span_notice("You start to unwrap the package..."), \
			span_italics("You hear paper ripping."))
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	for (var/obj/item/item in contents)
		if (!user.put_in_hands(item))
			item.forceMove(get_turf(user))
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient, list/received_report)
	switch(rand(1,5))
		if(5)
			name = "[initial(name)] critical to [recipient.name] ([recipient.assigned_role])"
		else
			name = "[initial(name)] for [recipient.name] ([recipient.assigned_role])"
	recipient_ref = WEAKREF(recipient)

	//Recipients
	var/mob/living/body = recipient.current
	//Load the generic list of goodies
	var/list/goodies = generic_goodies.Copy()

	//Load the job the player have
	var/datum/job/this_job = SSjob.name_occupations[recipient.assigned_role] // only station crews have 'assigned role'
	if(this_job)
		goodies += this_job.mail_goodies
		var/datum/record/crew/R = find_record(recipient.name, GLOB.manifest.general)
		if(R) // manifest is primary
			color = get_chatcolor_by_hud(R.hud)
		else if(this_job.title) // when they have no manifest, roundstart job will be base
			color = get_chatcolor_by_hud(this_job.title)
		if(!color)
			color = COLOR_WHITE

	for(var/i in 1 to goodie_count)
		var/target_good = pick_weight(goodies)
		var/atom/movable/target_atom = new target_good(src)
		body.log_message("[key_name(body)] received [target_atom.name] in the mail ([target_good])", LOG_GAME)
		received_report += "[key_name(body)] received [target_atom.name]"

	return TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail_crate"
	door_anim_time = 0
	custom_price = 0

/* Fills this mail crate with N pieces of mail, where N is the lower of the amount var passed,
** and the maximum capacity of this crate. If N is larger than the number of alive human players, the excess will be junkmail.*/
/obj/structure/closet/crate/mail/proc/populate(amount)
	var/mail_count = min(amount, storage_capacity)
	if(mail_count == null)
		mail_count = 1
	//fills the crate for the recipients
	var/list/mail_recipients = list()

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		// Mail is not routed to anyone who isn't present on the manifest, since how would we know
		// to send their mail here?
		if(!human.mind || !find_record(human.mind.name, GLOB.manifest.general))
			continue

		mail_recipients += human.mind

	var/list/received_report = list()

	for(var/i in 1 to mail_count)
		var/datum/mind/recipient = pick_n_take(mail_recipients)
		if (!recipient)
			break
		var/obj/item/mail/new_mail
		if(prob(FULL_CRATE_LETTER_ODDS))
			new_mail = new /obj/item/mail(src)
		else
			new_mail = new /obj/item/mail/envelope(src)
		new_mail.initialize_for_recipient(recipient, received_report)

	to_chat(GLOB.admins, "<span class='adminhelp_conclusion'><span class='bold big'>Mail Report</span><br>[span_adminnotice(jointext(received_report, "\n"))]</span>")

	update_icon()

/// Crate for mail that automatically depletes the economy subsystem's pending mail counter.
/obj/structure/closet/crate/mail/economy/Initialize(mapload)
	. = ..()
	populate(SSeconomy.mail_waiting)
	SSeconomy.mail_waiting = 0

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "brimming mail crate"
	desc = "A certified post crate from CentCom. Looks stuffed to the gills."

/obj/structure/closet/crate/mail/full/Initialize(mapload)
	. = ..()
	populate(null)

/obj/item/paper/fluff/junkmail_redpill
	name = "smudged paper"
	icon_state = "scrap"
	show_written_words = FALSE
	var/nuclear_option_odds = 0.1

/obj/item/paper/fluff/nice_argument
	name = "RE: Nice Argument..."
	icon_state = "paper"
	show_written_words = FALSE

/obj/item/paper/fluff/nice_argument/Initialize(mapload)
	. = ..()
	var/station_name = station_name()
	add_raw_text("Nice argument, however there's a <i>small detail</i>...<br>IP: '[rand(0,10)].[rand(0,255)].[rand(0,255)].[rand(0,255)]'<br> Station name: '[station_name]'<br>")

/obj/item/paper/fluff/junkmail_redpill/Initialize(mapload)
	// 1 in 1000 chance of getting 2 random nuke code characters.
	if(!prob(nuclear_option_odds))
		add_raw_text("<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[random_code(4)]...'")
		return ..()
	var/code = random_code(5)
	for(var/obj/machinery/nuclearbomb/selfdestruct/nuke in GLOB.nuke_list)
		if(nuke)
			if(nuke.r_code == "ADMIN")
				nuke.r_code = code
				message_admins("Through junkmail, the self-destruct code was set to \"[code]\".")
			else //Already set by admins/something else?
				code = nuke.r_code
		else
			stack_trace("Station self-destruct not found during lone op team creation.")
			code = null
	add_raw_text("<i>You need to escape the simulation. Don't forget the numbers, they help you remember:</i> '[code[rand(1,5)]][code[rand(1,5)]][code[rand(1,5)]][code[rand(1,5)]]...'")
	return ..()

//admin letter enabling players to brute force their way through the nuke code if they're so inclined.
/obj/item/paper/fluff/junkmail_redpill/true
	nuclear_option_odds = 100
