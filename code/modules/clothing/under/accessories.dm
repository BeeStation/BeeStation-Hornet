/obj/item/clothing/accessory
	name = "Accessory"
	desc = "Something has gone wrong!"
	// Accessory worn icons found in icons/mob/accessories.dmi
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "plasma"
	inhand_icon_state = ""	//no inhands
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	appearance_flags = TILE_BOUND | RESET_COLOR
	/// If we have multiple accessories, what is the layer of this one?
	var/accessory_layer = ACCESSORY_LAYER_DEFAULT
	/// The accessory slot that is consumed by this item, 2 accessories cannot exist on the same spot.
	var/accessory_slot = ACCESSORY_CHEST
	/// Is this accessory hidden to examiners?
	var/hidden = FALSE
	/// Does it show above the armour slot item
	var/above_suit = FALSE
	/// TRUE if shown as a small icon in corner, FALSE if overlayed
	var/minimize_when_attached = TRUE
	/// The slot that the clothing must cover for the accessory to be valid
	var/attachment_slot = CHEST

/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/under/U, mob/user, silent = TRUE)
	if(attachment_slot && !(U && U.body_parts_covered & attachment_slot))
		if(user && !silent)
			to_chat(user, span_warning("There doesn't seem to be anywhere to put [src]..."))
		return FALSE
	if (accessory_slot in U.attached_accessories)
		if(user && !silent)
			to_chat(user, span_warning("You already have an accessory covering the [LOWER_TEXT(accessory_slot)] of \the [U]."))
		return FALSE
	return TRUE

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/U, user)
	if(atom_storage)
		if(U.atom_storage)
			return FALSE
		U.clone_storage(atom_storage)
		U.atom_storage.set_real_location(src)
	U.attached_accessories[accessory_slot] = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	U.update_appearance(UPDATE_OVERLAYS)

	U.set_armor(U.get_armor().add_other_armor(get_armor()))

	if(isliving(U.loc))
		on_uniform_equip(U, U.loc)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/U, user)
	if(U.atom_storage && U.atom_storage.real_location?.resolve() == src)
		QDEL_NULL(U.atom_storage)

	U.set_armor(U.get_armor().subtract_other_armor(get_armor()))

	if(isliving(user))
		on_uniform_dropped(U, user)

	layer = initial(layer)
	plane = initial(plane)
	U.attached_accessories -= accessory_slot
	U.update_appearance(UPDATE_OVERLAYS)
	U.update_accessory_overlays()

/obj/item/clothing/accessory/proc/on_uniform_equip(obj/item/clothing/under/U, mob/living/wearer)
	return

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/U, mob/living/wearer)
	return

/obj/item/clothing/accessory/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		if(initial(above_suit))
			above_suit = !above_suit
			to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] can be attached to a uniform. Alt-click to remove it once attached.")
	if(initial(above_suit))
		. += span_notice("\The [src] can be worn above or below your suit. Alt-click to toggle.")

/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	inhand_icon_state = "waistcoat"
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/maidapron
	name = "maid apron"
	desc = "The best part of a maid costume."
	icon_state = "maidapron"
	inhand_icon_state = "maidapron"
	minimize_when_attached = FALSE
	attachment_slot = null

//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	custom_materials = list(/datum/material/iron=1000)
	resistance_flags = FIRE_PROOF
	accessory_slot = ACCESSORY_MEDAL
	accessory_layer = ACCESSORY_LAYER_MEDAL
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && !user.combat_mode)

		if(M.wear_suit)
			if((M.wear_suit.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				to_chat(user, span_warning("Medals can only be pinned on jumpsuits."))
				return

		if(M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			var/delay = 20
			if(user == M)
				delay = 0
			else
				user.visible_message("[user] is trying to pin [src] on [M]'s chest.", \
									span_notice("You try to pin [src] on [M]'s chest."))
			var/input
			if(!commended && user != M)
				input = stripped_input(user,"Please input a reason for this commendation, it will be recorded by Nanotrasen.", ,"", 140)
			if(do_after(user, delay, target = M))
				if(U.attach_accessory(src, user, 0)) //Attach it, do not notify the user of the attachment
					if(user == M)
						to_chat(user, span_notice("You attach [src] to [U]."))
					else
						user.visible_message("[user] pins \the [src] on [M]'s chest.", \
											span_notice("You pin \the [src] on [M]'s chest."))
						if(input)
							SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[user.real_name]", "commendee" = "[M.real_name]", "medal" = "[src]", "reason" = input))
							GLOB.commendations += "[user.real_name] awarded <b>[M.real_name]</b> the [span_medaltext("[name]")]! \n- [input]"
							commended = TRUE
							desc += "<br>The inscription reads: [input] - [user.real_name]"
							log_game("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
							message_admins("<b>[key_name_admin(M)]</b> was given the following commendation by <b>[key_name_admin(user)]</b>: [input]")

		else
			to_chat(user, span_warning("Medals can only be pinned on jumpsuits!"))
	else
		..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/ribbon
	name = "ribbon"
	desc = "A ribbon"
	icon_state = "cargo"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "\"cargo tech of the shift\" award"
	desc = "An award bestowed only upon those cargotechs who have exhibited devotion to their duty in keeping with the highest traditions of Cargonia."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	medaltype = "medal-silver"
	custom_materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "the head of personnel award for outstanding achievement in the field of excellence"
	desc = "Nanotrasen's dictionary defines excellence as \"the quality or condition of being excellent\". This is awarded to those rare crewmembers who fit that definition."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	medaltype = "medal-gold"
	custom_materials = list(/datum/material/gold=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentCom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	medaltype = "medal-plasma"
	armor_type = /datum/armor/medal_plasma
	custom_materials = list(/datum/material/plasma=1000)


/datum/armor/medal_plasma
	fire = -10

/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
		visible_message(span_danger(" \The [src] bursts into flame!"),span_userdanger("Your [src] bursts into flame!"))
		qdel(src)

/obj/item/clothing/accessory/medal/plasma/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/item/clothing/accessory/medal/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/item/clothing/accessory/medal/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
	visible_message("<span class='danger'>\The [src] bursts into flame!</span>", "<span class='userdanger'>Your [src] bursts into flame!</span>")
	qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/accessory/medal/med_medal
	name = "exemplary performance medal"
	desc = "A medal awarded to those who have shown distinguished conduct, performance, and initiative within the medical department."
	icon_state = "med_medal"
	above_suit = TRUE

/obj/item/clothing/accessory/medal/med_medal2
	name = "excellence in medicine medal"
	desc = "A medal awarded to those who have shown legendary performance, competence, and initiative beyond all expectations within the medical department."
	icon_state = "med_medal2"
	above_suit = TRUE

////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "red armband"
	desc = "A fancy red armband!"
	icon_state = "redband"
	attachment_slot = null
	accessory_slot = ACCESSORY_ARMBAND
	accessory_layer = ACCESSORY_LAYER_ARMBAND

/obj/item/clothing/accessory/armband/blue
	name = "blue armband"
	desc = "A fancy blue armband!"
	icon_state = "medband"
	color = "#0000ff"

/obj/item/clothing/accessory/armband/green
	name = "green armband"
	desc = "A fancy green armband!"
	icon_state = "medband"
	color = "#00ff00"

/obj/item/clothing/accessory/armband/deputy
	name = "security deputy armband"
	desc = "An armband, worn by personnel authorized to act as a deputy of station security."
	custom_price = 10

/obj/item/clothing/accessory/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is brown."
	icon_state = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "science guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is purple."
	icon_state = "rndband"

/obj/item/clothing/accessory/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is green and blue."
	icon_state = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white."
	icon_state = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white and blue."
	icon_state = "medblueband"

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "attorney's badge")
	user.visible_message("[user] shows [user.p_their()] attorney's badge.", span_notice("You show your attorney's badge."))

/obj/item/clothing/accessory/lawyers_badge/on_uniform_equip(obj/item/clothing/under/U, mob/living/wearer)
	var/mob/living/L = wearer
	if(L)
		L.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_uniform_dropped(obj/item/clothing/under/U, mob/living/wearer)
	var/mob/living/L = wearer
	if(L)
		L.bubble_icon = initial(L.bubble_icon)

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/pocketprotector)

	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	armor_type = /datum/armor/accessory_talisman
	attachment_slot = null


/datum/armor/accessory_talisman
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	acid = 25
	stamina = 10
	bleed = 10

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	above_suit = TRUE
	armor_type = /datum/armor/accessory_skullcodpiece
	attachment_slot = GROIN


/datum/armor/accessory_skullcodpiece
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	acid = 25
	stamina = 10
	bleed = 10

/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	inhand_icon_state = "holster"
	worn_icon_state = "holster"
	slot_flags = ITEM_SLOT_SUITSTORE|ITEM_SLOT_BELT
	var/holstertype = /datum/storage/pockets/holster

/obj/item/clothing/accessory/holster/Initialize(mapload)
	. = ..()
	create_storage(storage_type = holstertype)

/obj/item/clothing/accessory/holster/detective
	name = "detective's shoulder holster"
	holstertype = /datum/storage/pockets/holster/detective

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	new /obj/item/gun/ballistic/revolver/detective(src)

//Poppy Pin
/obj/item/clothing/accessory/poppy_pin
	name = "poppy pin"
	desc = "A pin made from a poppy, worn to remember those who have fallen in war."
	icon_state = "poppy_pin"
	accessory_slot = ACCESSORY_MEDAL
	accessory_layer = ACCESSORY_LAYER_MEDAL

/obj/item/clothing/accessory/poppy_pin/on_uniform_equip(obj/item/clothing/under/U, mob/living/wearer)
	var/mob/living/L = wearer
	if(L && L.mind)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "poppy_pin", /datum/mood_event/poppy_pin)

/obj/item/clothing/accessory/poppy_pin/on_uniform_dropped(obj/item/clothing/under/U, mob/living/wearer)
	var/mob/living/L = wearer
	if(L && L.mind)
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "poppy_pin")

//Security Badges
/obj/item/clothing/accessory/badge
	name = "badge"
	desc = "A badge that symbolises a person's authority as a member of security."
	icon_state = "officerbadge"
	worn_icon_state = "officerbadge"
	w_class = WEIGHT_CLASS_TINY
	accessory_slot = ACCESSORY_MEDAL
	accessory_layer = ACCESSORY_LAYER_MEDAL
	above_suit = TRUE
	var/badge_title = "Security Officer"
	var/officer_name

/obj/item/clothing/accessory/badge/examine(mob/user)
	. = ..()
	if(officer_name)
		to_chat(user, "The [src]'s text reads: [officer_name], [badge_title].")

/obj/item/clothing/accessory/badge/attack_self(mob/user)
	if (!officer_name)
		to_chat(user, "You inspect your [src.name]. Everything seems to be in order and you give it a quick cleaning with your hand.")
		officer_name = user.real_name
		desc = usr
		return
	if (isliving(user))
		if(officer_name)
			user.visible_message(span_notice("[user] displays their [src.name].\nThe [src]'s text reads: [officer_name], [badge_title]."),span_notice("You display your [src.name].\nThe [src]'s text reads: [officer_name], [badge_title]."))
		else
			user.visible_message(span_notice("[user] displays their [src.name].\nIt reads: [badge_title]."),span_notice("You display your [src.name]. It reads: [badge_title]."))
	..()

/obj/item/clothing/accessory/badge/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if (isliving(user) && istype(target))
		user.visible_message(span_danger("[user] invades [target]'s personal space, thrusting \the [src] into their face insistently."), span_danger("You invade [target]'s personal space, thrusting \the [src] into their face insistently."))
		if (officer_name)
			to_chat(target, span_warning("The [src]'s text reads: [officer_name], [badge_title]."))

/obj/item/clothing/accessory/badge/det
	icon_state = "detbadge"
	worn_icon_state = "detbadge"
	badge_title = "Detective"

/obj/item/clothing/accessory/badge/hos
	icon_state = "hosbadge"
	worn_icon_state = "hosbadge"
	badge_title = "Head of Security"
