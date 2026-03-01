/obj/item/soulstone
	name = "soulstone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	layer = HIGH_OBJ_LAYER
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	var/old_shard = FALSE
	var/spent = FALSE
	var/original_name = "" // The original name of the person whose soul is in the soulstone, kept for constructs droping the soulstone again
	///This controls the color of the soulstone as well as restrictions for who can use it. THEME_CULT is red and is the default of cultist THEME_WIZARD is purple and is the default of wizard and THEME_HOLY is for purified soul stone
	var/theme = THEME_CULT
	/// Role check, if any needed
	var/required_role = /datum/antagonist/cult
	var/mob/living/simple_animal/shade/contained_shade = null

/obj/item/soulstone/proc/role_check(mob/who)
	return required_role ? (who.mind && who.mind.has_antag_datum(required_role, TRUE)) : TRUE

/obj/item/soulstone/proc/was_used()
	if(old_shard)
		spent = TRUE
		name = "dull [name]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/soulstone/anybody
	required_role = null

/obj/item/soulstone/mystic
	icon_state = "mystic_soulstone"
	theme = THEME_WIZARD
	required_role = /datum/antagonist/wizard

/obj/item/soulstone/anybody/revolver
	old_shard = TRUE

/obj/item/soulstone/anybody/purified
	icon_state = "purified_soulstone"
	theme = THEME_HOLY

/obj/item/soulstone/anybody/chaplain
	name = "mysterious old shard"
	old_shard = TRUE

/obj/item/soulstone/vampire
	theme = THEME_WIZARD
	required_role = /datum/antagonist/vassal

/obj/item/soulstone/pickup(mob/living/user)
	..()
	if(!role_check(user))
		to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you pick up the soulstone. It would be wise to be rid of this quickly."))

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(role_check(user) || isobserver(user))
		if (old_shard)
			. += span_cult("A soulstone, used to capture a soul, either from dead humans or from freed shades.")
		else
			. += span_cult("A soulstone, used to capture souls, either from unconscious or sleeping humans or from freed shades.")
		. += span_cult("The captured soul can be placed into a construct shell to produce a construct, placed into a runic golem to produce a cultist golem, placed into a soulless dead body to transfer them into it or released from the stone as a shade.")
		if(spent)
			. += span_cult("This shard is spent; it is now just a creepy rock.")

/obj/item/soulstone/Destroy()
	if(contained_shade)
		contained_shade.death()
		contained_shade = null
	return ..()

/obj/item/soulstone/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == contained_shade)
		contained_shade = null

	if(isshade(gone))
		var/mob/living/simple_animal/shade/S = gone
		S.remove_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
		S.cancel_camera()
		if(theme == THEME_HOLY)
			S.icon_state = "shade_angelic"
			S.name = "Purified [S.real_name]"

/obj/item/soulstone/proc/hot_potato(mob/living/user)
	to_chat(user, span_userdanger("Holy magics residing in \the [src] burn your hand!"))
	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	affecting.receive_damage( 0, 10 )	// 10 burn damage
	user.emote("scream")
	user.update_damage_overlays()
	user.dropItemToGround(src)

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(!role_check(user))
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		user.Unconscious(3 SECONDS)
		return
	if(spent)
		to_chat(user, span_warning("There is no power left in the shard."))
		return
	if(!ishuman(M))
		return ..()
	if(contained_shade && M.stat == DEAD)
		reanimate_corpse(M, user)
		return
	if(IS_CULTIST(M) && IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"Come now, do not capture your brethren's soul.\""))
		return
	if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return
	if(HAS_TRAIT(M, TRAIT_NO_SOUL))
		to_chat(user, span_warning("This body does not possess a soul to capture."))
		return
	log_combat(user, M, "captured [M.name]'s soul", src)
	transfer_soul("VICTIM", M, user)

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/soulstone/proc/reanimate_corpse(mob/living/carbon/human/host, mob/user)
	if(!contained_shade)
		return FALSE
	if(host.stat != DEAD) // Self explanatory, they must be dead
		to_chat(user, span_warning("The vessel must be dead to accept a new soul."))
		return FALSE
	if(host.get_ghost(FALSE, TRUE)) // We don't want to overwrite the original soul if it still exists
		to_chat(user, span_warning("This vessel's original soul still lingers within inside."))
		return FALSE
	if(!host.get_organ_slot(ORGAN_SLOT_BRAIN)) // No brain and having a soul, shouldn't happen, we cant let it pass
		to_chat(user, span_warning("This vessel lacks a brain and cannot house a soul."))
		return FALSE
	user.visible_message(span_notice("[user] presses [src] against [host]'s chest, the gem glowing with eerie light!"),
						span_notice("You jam the [src] into [host]'s chest. The soul inside leaps into the vacant vessel."))
	if(!contained_shade.mind)
		return FALSE
	contained_shade.mind.transfer_to(host)
	host.revive() //This does not heal a mangled corpse
	host.emote("gasp")
	log_combat(user, src, "revived with soulstone")
	var/message = ""
	playsound(host, 'sound/effects/glassbr2.ogg', 50, TRUE)
	switch(theme)
		if(THEME_HOLY)
			message = "You have been brought back into this world by holy energies."
		if(THEME_CULT)
			message = "Your soul is bound to this flesh by Nar'Sie! Serve the cult."
			if(IS_CULTIST(user))
				host.mind.add_antag_datum(/datum/antagonist/cult) // Make them a cultist, just making sure they didn't lose it
		else
			message = "You have been forced back into a mortal shell"
	to_chat(host, span_boldannounce(message))
	contained_shade = null
	qdel(src)
	return TRUE

/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return
	if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return
	if(!role_check(user))
		user.Unconscious(3 SECONDS)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return
	release_shades(user)

/obj/item/soulstone/proc/release_shades(mob/user)
	if(!contained_shade)
		return
	contained_shade.forceMove(get_turf(user))
	contained_shade.cancel_camera()
	contained_shade.remove_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
	switch(theme)
		if(THEME_HOLY)
			icon_state = "purified_soulstone"
			contained_shade.icon_state = "shade_holy"
			contained_shade.name = "Purified [contained_shade.real_name]"
			contained_shade.loot = list(/obj/item/ectoplasm/angelic)
		if(THEME_WIZARD)
			icon_state = "mystic_soulstone"
			contained_shade.icon_state = "shade_wizard"
			contained_shade.loot = list(/obj/item/ectoplasm/mystic)
		if(THEME_CULT)
			icon_state = "soulstone"
	name = initial(name)
	if(IS_CULTIST(user))
		to_chat(contained_shade, span_bold("You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs."))
	else if(role_check(user))
		to_chat(contained_shade, span_bold("You have been released from your prison, but you are still bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs."))
	contained_shade = null
	was_used()
///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct_cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || IS_WIZARD(user) || user.stat == DEAD)
		. += span_cult("A construct shell, used to house bound souls from a soulstone.\n"+\
		"Placing a soulstone with a soul into this shell allows you to produce your choice of the following:\n"+\
		"An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.\n"+\
		"A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.\n"+\
		"A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.")

/obj/structure/constructshell/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!IS_CULTIST(user) && !IS_WIZARD(user) && !SS.theme == THEME_HOLY)
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place [SS] into the shell. It would be wise to be rid of this quickly."))
			if(isliving(user))
				var/mob/living/living_user = user
				living_user.set_dizzy_if_lower(1 MINUTES)
			return
		if(SS.theme == THEME_HOLY && IS_CULTIST(user))
			SS.hot_potato(user)
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/soulstone/proc/transfer_soul(choice as text, target, mob/user)
	switch(choice)
		if("FORCE")
			if(!iscarbon(target) && !isconstruct(target))
				return FALSE
			if(contents.len)
				return FALSE
			if(iscarbon(target))
				var/mob/living/carbon/victim = target
				if(victim.client)
					for(var/obj/item/W in victim)
						victim.dropItemToGround(W)
					steal_soul(victim, user)
					return TRUE
				else
					to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its mortal frame. You attempt to bring it back...")
					return getCultGhost(victim, user)
			else if(isconstruct(target))
				var/mob/living/simple_animal/hostile/construct/creation = target
				if(creation.client)
					steal_soul(creation, user)
					return TRUE
				to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its construct shell.")
				return FALSE
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/datum/antagonist/cult/C = user.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
			if(C && C.cult_team.is_sacrifice_target(T.mind))
				if(IS_CULTIST(user))
					to_chat(user, "[span_cult("<b>\"This soul is mine.</b>")] [span_cultlarge("SACRIFICE THEM!\"")]")
				else
					to_chat(user, span_danger("The soulstone seems to reject this soul."))
				return FALSE
			if(contents.len)
				to_chat(user, "[span_userdanger("Capture failed!")]: The soulstone is full! Free an existing soul to make room.")
			else
				if((!old_shard && T.stat != CONSCIOUS) || (old_shard && T.stat == DEAD))
					if(T.client == null)
						to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its mortal frame. You attempt to bring it back...")
						getCultGhost(T,user)
					else
						if(old_shard) //no insta cremating on the spot
							to_chat(user, "[span_userdanger("Capture failed!")]: The old shard is not powerful enough to absorb the soul of this being.")
							return FALSE
						for(var/obj/item/W in T)
							T.dropItemToGround(W)
						steal_soul(T, user, TRUE)
				else
					to_chat(user, "[span_userdanger("Capture failed!")]: Kill or maim the victim first!")

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(contained_shade)
				to_chat(user, "[span_userdanger("Capture failed!")]: The soulstone is full! Free an existing soul to make room.")
			else
				T.forceMove(src)
				contained_shade = T
				T.add_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
				T.health = T.maxHealth
				if(theme == THEME_HOLY)
					icon_state = "purified_soulstone2"
					if(IS_CULTIST(T))
						T.mind.remove_antag_datum(/datum/antagonist/cult)
				if(theme == THEME_WIZARD)
					icon_state = "mystic_soulstone2"
				if(theme == THEME_CULT)
					icon_state = "soulstone2"
				name = "soulstone: Shade of [T.real_name]"
				to_chat(T, span_notice("Your soul has been captured by the soulstone. Its arcane energies are reknitting your ethereal form."))
				if(user != T)
					to_chat(user, "[span_info("<b>Capture successful!</b>:")] [T.real_name]'s soul has been captured and stored within the soulstone.")

		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			if(contained_shade)
				var/construct_class = show_radial_menu(user, src, GLOB.construct_radial_images, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!T || !T.loc || !construct_class)
					return

				make_new_construct_from_class(construct_class, theme, contained_shade, user, FALSE, T.loc)

				for(var/datum/antagonist/cult/cultist in GLOB.antagonists)
					if(cultist.owner == contained_shade.mind)
						cultist.remove_antag_hud(ANTAG_HUD_CULT, cultist.owner.current)
				qdel(T)
				contained_shade = null
				qdel(src)
			else
				to_chat(user, "[span_userdanger("Creation failed!")]: [src] is empty! Go kill someone!")

/obj/item/soulstone/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/proc/make_new_construct_from_class(construct_class, theme, mob/target, mob/creator, cultoverride, loc_override)
	switch(construct_class)
		if(CONSTRUCT_JUGGERNAUT)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/juggernaut/noncult, target, creator, cultoverride, loc_override)
		if(CONSTRUCT_WRAITH)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/noncult, target, creator, cultoverride, loc_override)
		if(CONSTRUCT_ARTIFICER)
			if(IS_CULTIST(creator))
				makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer, target, creator, cultoverride, loc_override) // ignore themes, the actual giving of cult info is in the makeNewConstruct proc
				return
			switch(theme)
				if(THEME_WIZARD)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/mystic, target, creator, cultoverride, loc_override)
				if(THEME_HOLY)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/angelic, target, creator, cultoverride, loc_override)
				if(THEME_CULT)
					makeNewConstruct(/mob/living/simple_animal/hostile/construct/artificer/noncult, target, creator, cultoverride, loc_override)

/proc/makeNewConstruct(mob/living/simple_animal/hostile/construct/ctype, mob/target, mob/stoner = null, cultoverride = FALSE, loc_override = null)
	if(QDELETED(target))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype((loc_override) ? (loc_override) : (get_turf(target)))
	var/makeicon = newstruct.icon_state
	var/theme = newstruct.theme
	flick("make_[makeicon][theme]", newstruct)
	playsound(newstruct, 'sound/effects/constructform.ogg', 50)
	if(stoner)
		newstruct.faction |= "[REF(stoner)]"
		newstruct.master = stoner
		var/datum/action/innate/seek_master/SM = new()
		SM.Grant(newstruct)
	if(target)
		newstruct.original_name = target.name
		newstruct.original_real_name = target.real_name
	newstruct.key = target.key
	var/atom/movable/screen/alert/bloodsense/BS
	if(newstruct.mind && ((stoner && IS_CULTIST(stoner)) || cultoverride))
		newstruct.mind.add_antag_datum(/datum/antagonist/cult)
	if(IS_CULTIST(stoner) || cultoverride)
		to_chat(newstruct, "<b>You are still bound to serve the cult[stoner ? " and [stoner]":""], follow [stoner ? stoner.p_their() : "their"] orders and help [stoner ? stoner.p_them() : "them"] complete [stoner ? stoner.p_their() : "their"] goals at all costs.</b>")
	else if(stoner)
		to_chat(newstruct, "<b>You are still bound to serve your creator, [stoner], follow [stoner.p_their()] orders and help [stoner.p_them()] complete [stoner.p_their()] goals at all costs.</b>")
	newstruct.clear_alert("bloodsense")
	BS = newstruct.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(BS)
		BS.Cviewer = newstruct
	newstruct.cancel_camera()

/obj/item/soulstone/proc/steal_soul(mob/living/victim, mob/user, message_user = FALSE)
	init_shade(victim, user, message_user)
	victim.dust()

/obj/item/soulstone/proc/init_shade(mob/target, mob/user, message_user = FALSE, mob/shade_controller)
	if(!shade_controller)
		shade_controller = target
	contained_shade = new /mob/living/simple_animal/shade(src)
	contained_shade.add_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
	contained_shade.name = "Shade of [target.name]"
	contained_shade.real_name = target.real_name
	contained_shade.cancel_camera()
	if(user)
		contained_shade.faction |= "[REF(user)]"
	shade_controller.mind.transfer_to(contained_shade)
	name = "soulstone: Shade of [target.real_name]"
	switch(theme)
		if(THEME_HOLY)
			icon_state = "purified_soulstone2"
		if(THEME_WIZARD)
			icon_state = "mystic_soulstone2"
		if(THEME_CULT)
			icon_state = "soulstone2"
	if(!user)
		return
	if(IS_CULTIST(user))
		contained_shade.mind.add_antag_datum(/datum/antagonist/cult)
		to_chat(contained_shade, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
	else if(role_check(user))
		to_chat(contained_shade, "Your soul has been captured! You are now bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.")
	if(message_user)
		to_chat(user, span_info("<b>Capture successful!</b>: [target.real_name]'s soul has been ripped from [target.p_their()] body and stored within [src]."))

/obj/item/soulstone/proc/getCultGhost(mob/living/carbon/human/T, mob/user)
	var/mob/dead/observer/chosen_ghost

	chosen_ghost = T.get_ghost(TRUE,TRUE) //Try to grab original owner's ghost first

	if(!chosen_ghost || !chosen_ghost.client) //Failing that, we grab a ghosts
		var/datum/poll_config/config = new()
		config.check_jobban = ROLE_CULTIST
		config.poll_time = 10 SECONDS
		config.ignore_category = POLL_IGNORE_CULT_SHADE
		config.jump_target = T
		config.role_name_text = "shade"
		config.alert_pic = /mob/living/simple_animal/shade
		var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, T)

		if(candidate)
			chosen_ghost = candidate
	if(!T)
		return FALSE
	if(!chosen_ghost)
		to_chat(user, span_danger("There were no spirits willing to become a shade."))
		return FALSE
	if(contained_shade)//If they used the soulstone on someone else in the meantime
		return FALSE
	for(var/obj/item/W in T)
		T.dropItemToGround(W)
	init_shade(T, user , shade_controller = chosen_ghost)
	qdel(T)
	return TRUE
