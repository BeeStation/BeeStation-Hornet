/obj/item/book/codex_gigas
	name = "\improper Codex Gigas"
	desc = "A book documenting the nature of devils."
	icon_state ="demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "the Codex Gigas"

/obj/item/book/codex_gigas/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	new /obj/item/book/kindred(current_turf)

/**
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators.
 *	When used on a player, after a short timer, will reveal if the player is a Bloodsucker, including their real name and Clan.
 *	This book should not work on Bloodsuckers using the Masquerade ability.
 *	If it reveals a Bloodsucker, the Curator will then be able to tell they are a Bloodsucker on examine (Like a Vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 *
 *	Regular Bloodsuckers won't have any negative effects from the book, while everyone else will get burns/eye damage.
 */
/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	title = "the Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'icons/bloodsuckers/vamp_obj.dmi'
	lefthand_file = 'icons/bloodsuckers/bs_leftinhand.dmi'
	righthand_file = 'icons/bloodsuckers/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	author = "dozens of generations of Curators"
	unique = TRUE
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	///Boolean on whether the book is currently being used, so you can only use it on one person at a time.
	var/in_use = FALSE

/obj/item/book/kindred/Initialize()
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

///Attacking someone with the book.
/obj/item/book/kindred/afterattack(mob/living/target, mob/living/user, flag, params)
	. = ..()
	if(!user.can_read(src) || in_use || (target == user) || !ismob(target))
		return
	if(!IS_CURATOR(user))
		if(IS_BLOODSUCKER(user))
			to_chat(user, "<span class='notice'>[src] seems to be too complicated for you. It would be best to leave this for someone else to take.</span>")
			return
		to_chat(user, "<span class='warning'>[src] burns your hands as you try to use it!</span>")
		user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return

	in_use = TRUE
	user.balloon_alert_to_viewers(user, "reading book...", "looks at [target] and [src]")
	if(!do_after(user, 3 SECONDS, target, timed_action_flags = NONE, progress = TRUE))
		to_chat(user, "<span class='notice'>You quickly close [src].</span>")
		in_use = FALSE
		return
	in_use = FALSE

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(target)
	// Are we a Bloodsucker | Are we on Masquerade. If one is true, they will fail.
	if(IS_BLOODSUCKER(target) && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(bloodsuckerdatum.broke_masquerade)
			to_chat(user, "<span class='warning'>[target], also known as '[bloodsuckerdatum.return_full_name()]', is indeed a Bloodsucker, but you already knew this.</span>")
			return
		to_chat(user, "<span class='warning'>[target], also known as '[bloodsuckerdatum.return_full_name()]', [bloodsuckerdatum.my_clan ? "is part of the [bloodsuckerdatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it.</span>")
		bloodsuckerdatum.break_masquerade()
	else
		to_chat(user, "<span class='notice'>You fail to draw any conclusions to [target] being a Bloodsucker.</span>")

/obj/item/book/kindred/attack_self(mob/living/user)
	if(!IS_CURATOR(user))
		if(IS_BLOODSUCKER(user))
			to_chat(user, "<span class='notice'>[src] seems to be too complicated for you. It would be best to leave this for someone else to take.</span>")
		else
			to_chat(user, "<span class='warning'>You feel your eyes unable to read the boring texts...</span>")
		return
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()

	for(var/datum/bloodsucker_clan/clans as anything in subtypesof(/datum/bloodsucker_clan))
		var/clan_data = list()
		clan_data["clan_name"] = initial(clans.name)
		clan_data["clan_desc"] = initial(clans.description)
		data["clans"] += list(clan_data)

	return data
