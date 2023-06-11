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

	var/static/list/generic_goodies = list(
		/obj/item/stack/spacecash/c10										= 22, //the lamest chance to get item, what do you expect really?
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game			= 10,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy	= 10,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers 			= 10,
		/obj/item/reagent_containers/food/snacks/candy						= 10,
		/obj/item/reagent_containers/food/snacks/chips						= 10,
		/obj/item/stack/spacecash/c50 										= 10,
		/obj/item/stack/spacecash/c100 										= 25,
		/obj/item/stack/spacecash/c200 										= 15,
		/obj/item/stack/spacecash/c500 										= 5,
		/obj/item/stack/spacecash/c1000 									= 1
	)

	//if the goodie is dangerous for the station, in this list it goes
	var/static/list/hazard_goodies = list(
			/obj/item/gun/ballistic/rifle/boltaction,
			/obj/item/construction/rcd/arcd,
			/obj/item/reagent_containers/spray/waterflower/superlube,
			/mob/living/simple_animal/hostile/retaliate/clown,
			/obj/item/clothing/accessory/holster/detective,
			/obj/item/reagent_containers/hypospray/medipen/pumpup,
			/obj/item/firing_pin,
			/obj/item/storage/lockbox/loyalty,
			/obj/item/grenade/clusterbuster/cleaner,
			/obj/item/book/granter/spell/mimery_blockade,
			/obj/item/gun/ballistic/rifle/boltaction/enchanted,
			/obj/item/melee/classic_baton/police/telescopic,
			/obj/item/reagent_containers/glass/bottle/random_virus/minor,
			/obj/item/reagent_containers/glass/bottle/random_virus,
			/obj/item/gun/ballistic/revolver/nagant
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
	var/msg = "<span class='notice'><i>You notice the postmarking on the front of the mail...</i></span>"
	if(recipient)
		msg += "\n<span class='info'>Certified NT mail for [recipient].</span>"
	else
		msg += "\n<span class='info'>Certified mail for [GLOB.station_name].</span>"
	. += "\n[msg]"


/obj/item/mail/Initialize()
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
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sort_tag = destination_tag.currTag
			playsound(loc, 'sound/machines/twobeep_high.ogg', 100, 1)

/obj/item/mail/attack_self(mob/user)
	if(recipient_ref)
		var/datum/mind/recipient = recipient_ref.resolve()
		// If the recipient's mind has gone, then anyone can open their mail
		// whether a mind can actually be qdel'd is an exercise for the reader
		if(recipient && recipient != user?.mind)
			if(!is_changeling(user))
				to_chat(user, "<span class='notice'>You can't open somebody else's mail! That's <em>immoral</em>!</span>")
				return
			if(user.real_name != recipient.name)
				to_chat(user, "<span class='warning'>We must keep our disguise intact.</span>")  // cuz your disguise cant open the mail so you shouldnt either
				return

	user.visible_message("[user] start to unwrap a package...", \
			"<span class='notice'>You start to unwrap the package...</span>", \
			"<span class='italics'>You hear paper ripping.</span>")
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	if(contents.len)
		user.put_in_hands(contents[1])
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

// Accepts a mind to initialize goodies for a piece of mail.
/obj/item/mail/proc/initialize_for_recipient(datum/mind/recipient)
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
	//Load the List of Dangerous goodies
	var/list/danger_goodies = hazard_goodies

	//Load the job the player have
	var/datum/job/this_job = SSjob.name_occupations[recipient.assigned_role] // only station crews have 'assigned role'
	if(this_job)
		goodies += this_job.mail_goodies
		var/datum/data/record/R = find_record("name", recipient.name, GLOB.data_core.general)
		if(R) // datacore is primary
			color = get_chatcolor_by_hud(R.fields["hud"])
		else if(this_job.title) // when they have no datacore, roundstart job will be base
			color = get_chatcolor_by_hud(this_job.title)
		if(!color)
			color = COLOR_WHITE


	for(var/i in 1 to goodie_count)
		var/target_good = pick_weight(goodies)
		var/atom/movable/target_atom = new target_good(src)
		body.log_message("[key_name(body)] received [target_atom.name] in the mail ([target_good])", LOG_GAME)
		if(target_atom.type in danger_goodies)
			message_admins("<span class='adminnotice'><b><font color=orange>DANGEROUS ITEM RECEIVED:</font></b>[ADMIN_LOOKUPFLW(body)] received [target_atom.name] in the mail ([target_good]) as a [recipient.assigned_role]</span>")

	return TRUE

// Alternate setup, just complete garbage inside and anyone can open
/obj/item/mail/proc/junk_mail()

	var/obj/junk = /obj/item/paper/fluff/junkmail_generic
	var/special_name = FALSE
	add_overlay("[initial(icon_state)]-spam")

	if(prob(25))
		special_name = TRUE
		junk = pick(list(/obj/item/paper/pamphlet/gateway,
						/obj/item/paper/pamphlet/violent_video_games,
						/obj/item/paper/fluff/junkmail_redpill,
						/obj/item/paper/fluff/nice_argument
						))

	var/static/list/junk_names = list(
		/obj/item/paper/pamphlet/gateway = "[initial(name)] for [pick(GLOB.adjectives)] adventurers",
		/obj/item/paper/pamphlet/violent_video_games = "[initial(name)] for the truth about the arcade centcom doesn't want to hear",
		/obj/item/paper/fluff/junkmail_redpill = "[initial(name)] for those feeling [pick(GLOB.adjectives)] working at Nanotrasen",
		/obj/item/paper/fluff/nice_argument = "[initial(name)] with INCREDIBLY IMPORTANT ARTIFACT- DELIVER TO SCIENCE DIVISION. HANDLE WITH CARE.",
	)

	//better spam mail names instead of being "IMPORTANT MAIL", courtesy of Monkestation
	color = "#[pick(random_short_color())]"
	switch(rand(1,10))

		if(1,2)
			name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.alive_mob_list)]" //LETTER FOR IAN / BUBBLEGUM / MONKEY(420)
		if(3,4)
			name = special_name ? junk_names[junk] : "[initial(name)] for [pick(GLOB.player_list)]" //Letter for ANYONE, even that wizard rampaging through the station.
		if(5)
			name = special_name ? junk_names[junk] : "DO NOT OPEN"
		else
			name = special_name ? junk_names[junk] : "[pick("important","critical","crucial","serious","vital")] [initial(name)]"

	junk = new junk(src)
	return TRUE

/obj/item/mail/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER
	if(!hasmob)
		disposal_holder.destinationTag = sort_tag

// Subtype that's always junkmail
/obj/item/mail/junkmail/Initialize()
	. = ..()
	junk_mail()

/obj/structure/closet/crate/mail
	name = "mail crate"
	desc = "A certified post crate from CentCom."
	icon_state = "mail_crate"
	door_anim_time = 0

/* Fills this mail crate with N pieces of mail, where N is the lower of the amount var passed,
** and the maximum capacity of this crate. If N is larger than the number of alive human players, the excess will be junkmail.*/
/obj/structure/closet/crate/mail/proc/populate(amount)
	var/mail_count = min(amount, storage_capacity)
	if(mail_count == null)
		mail_count = 1
	//fills the crate for the recipients
	var/list/mail_recipients = list()

	for(var/mob/living/carbon/human/human in GLOB.player_list)
		// Skip wizards, nuke ops, cyborgs and dead people; Centcom does not send them mail
		if(human.stat == DEAD || !human.mind || !SSjob.GetJob(human.mind.assigned_role) || human.mind.special_role)
			continue

		mail_recipients += human.mind

	if(mail_count < 15)
		for(var/i in 1 to rand(3,8))
			var/obj/item/mail/new_mail
			if(prob(FULL_CRATE_LETTER_ODDS))
				new_mail = new /obj/item/mail(src)
			else
				new_mail = new /obj/item/mail/envelope(src)
			new_mail.junk_mail()

	for(var/i in 1 to mail_count)
		var/datum/mind/recipient = pick_n_take(mail_recipients)
		var/obj/item/mail/new_mail
		if(prob(FULL_CRATE_LETTER_ODDS))
			new_mail = new /obj/item/mail(src)
		else
			new_mail = new /obj/item/mail/envelope(src)
		if(recipient)
			new_mail.initialize_for_recipient(recipient)
		else
			new_mail.junk_mail()

	update_icon()

/// Crate for mail that automatically depletes the economy subsystem's pending mail counter.
/obj/structure/closet/crate/mail/economy/Initialize()
	. = ..()
	populate(SSeconomy.mail_waiting)
	SSeconomy.mail_waiting = 0

/// Crate for mail that automatically generates a lot of mail. Usually only normal mail, but on lowpop it may end up just being junk.
/obj/structure/closet/crate/mail/full
	name = "brimming mail crate"
	desc = "A certified post crate from CentCom. Looks stuffed to the gills."

/obj/structure/closet/crate/mail/full/Initialize()
	. = ..()
	populate(null)

/obj/item/paper/fluff/junkmail_redpill
	name = "smudged paper"
	icon_state = "scrap"
	var/nuclear_option_odds = 0.1

/obj/item/paper/fluff/nice_argument
	name = "RE: Nice Argument..."
	icon_state = "paper"

/obj/item/paper/fluff/nice_argument/Initialize()
	. = ..()
	var/station_name = station_name()
	add_raw_text("Nice argument, however there's a <i>small detail</i>...<br>IP: '[rand(0,10)].[rand(0,255)].[rand(0,255)].[rand(0,255)]'<br> Station name: '[station_name]'<br>")

/obj/item/paper/fluff/junkmail_redpill/Initialize()
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

/obj/item/paper/fluff/junkmail_generic
	name = "important document"
	desc = "I wonder what's so important here..."
	icon_state = "paper_spam"
	color = "#FFCCFF"

/obj/item/paper/fluff/junkmail_generic/Initialize()
	default_raw_text = pick(GLOB.junkmail_messages)
	return ..()
