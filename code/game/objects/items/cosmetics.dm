/obj/item/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/random
	name = "lipstick"
	icon_state = "random_lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	icon_state = "lipstick"
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self(mob/user)
	cut_overlays()
	to_chat(user, span_notice("You twist \the [src] [open ? "closed" : "open"]."))
	open = !open
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		icon_state = "lipstick_uncap"
		add_overlay(colored_overlay)
	else
		icon_state = "lipstick"

/obj/item/lipstick/attack(mob/M, mob/user)
	if(!open)
		return

	if(!ismob(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.is_mouth_covered())
			to_chat(user, span_warning("Remove [ H == user ? "your" : "[H.p_their()]" ] mask!"))
			return
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, span_warning("You need to wipe off the old lipstick first!"))
			return
		if(H == user)
			user.visible_message(span_notice("[user] does [user.p_their()] lips with \the [src]."), \
								span_notice("You take a moment to apply \the [src]. Perfect!"))
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else
			user.visible_message(span_warning("[user] begins to do [H]'s lips with \the [src]."), \
								span_notice("You begin to apply \the [src] on [H]'s lips..."))
			if(do_after(user, 20, target = H))
				user.visible_message("[user] does [H]'s lips with \the [src].", \
									span_notice("You apply \the [src] on [H]'s lips."))
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, span_warning("Where are the lips on that?"))

//you can wipe off lipstick with paper!
/obj/item/paper/attack(mob/M, mob/user)
	if(user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH))
		if(!ismob(M))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, span_notice("You wipe off the lipstick with [src]."))
				H.lip_style = null
				H.update_body()
			else
				user.visible_message(span_warning("[user] begins to wipe [H]'s lipstick off with \the [src]."), \
									span_notice("You begin to wipe off [H]'s lipstick..."))
				if(do_after(user, 10, target = H))
					user.visible_message("[user] wipes [H]'s lipstick off with \the [src].", \
										span_notice("You wipe off [H]'s lipstick."))
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "razor"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	custom_price = 15
	var/extended = 1

/obj/item/razor/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins shaving [user.p_them()]self without the razor guard! It looks like [user.p_theyre()] trying to commit suicide!"))
	shave(user, BODY_ZONE_PRECISE_MOUTH)
	shave(user, BODY_ZONE_HEAD)//doesnt need to be BODY_ZONE_HEAD specifically, but whatever
	return BRUTELOSS

/obj/item/razor/proc/shave(mob/living/carbon/human/H, location = BODY_ZONE_PRECISE_MOUTH)
	if(location == BODY_ZONE_PRECISE_MOUTH)
		H.facial_hair_style = "Shaved"
	else
		H.hair_style = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/welder2.ogg', 20, 1)


/obj/item/razor/attack(mob/M, mob/living/user)
	if(!ishuman(M) || extended != 1 || user.combat_mode)
		return ..()
	var/mob/living/carbon/human/H = M
	// Must be targeting the head
	if (!user.is_zone_selected(BODY_ZONE_HEAD) && !user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH))
		return ..()
	if(!H.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[H] doesn't have a head!"))
		return
	var/mirror = FALSE
	if(HAS_TRAIT(H, TRAIT_SELF_AWARE) || locate(/obj/structure/mirror) in range(1, H))
		mirror = TRUE
	var/datum/task/select_bodyzone = user.select_bodyzone(M, TRUE, BODYZONE_STYLE_DEFAULT, override_zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH))
	select_bodyzone.continue_with(CALLBACK(src, PROC_REF(razor_action), H, user, mirror))

/obj/item/razor/proc/razor_action(mob/living/carbon/human/H, mob/living/user, mirror, location)
	if (!user.can_interact_with(H, TRUE))
		to_chat(user, span_warning("[H] is too far away!"))
		return
	if (!user.can_interact_with(src, TRUE))
		to_chat(user, span_warning("[src] is too far away!"))
		return
	if(location == BODY_ZONE_PRECISE_MOUTH)
		if(!user.combat_mode)
			if(H.gender == MALE)
				INVOKE_ASYNC(src, PROC_REF(new_facial_hairstyle), H, user, mirror)
				return
			else
				return
		else
			if(!(FACEHAIR in H.dna.species.species_traits))
				to_chat(user, span_warning("There is no facial hair to shave!"))
				return
			if(!get_location_accessible(H, location))
				to_chat(user, span_warning("The mask is in the way!"))
				return
			if(H.facial_hair_style == "Shaved")
				to_chat(user, span_warning("Already clean-shaven!"))
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave [user.p_their()] facial hair with [src].", \
										span_notice("You take a moment to shave your facial hair with [src]..."))
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves [user.p_their()] facial hair clean with [src].", \
											span_notice("You finish shaving with [src]. Fast and clean!"))
					shave(H, location)
			else
				user.visible_message(span_warning("[user] tries to shave [H]'s facial hair with [src]."), \
										span_notice("You start shaving [H]'s facial hair..."))
				if(do_after(user, 50, target = H))
					user.visible_message(span_warning("[user] shaves off [H]'s facial hair with [src]."), \
											span_notice("You shave [H]'s facial hair clean off."))
					shave(H, location)

	else if(location == BODY_ZONE_HEAD)
		if(!user.combat_mode)
			INVOKE_ASYNC(src, PROC_REF(new_hairstyle), H, user)
			return
		else
			if(!(HAIR in H.dna.species.species_traits))
				to_chat(user, span_warning("There is no hair to shave!"))
				return
			if(!get_location_accessible(H, location))
				to_chat(user, span_warning("The headgear is in the way!"))
				return
			if(H.hair_style == "Bald" || H.hair_style == "Balding Hair" || H.hair_style == "Skinhead")
				to_chat(user, span_warning("There is not enough hair left to shave!"))
				return

			if(H == user) //shaving yourself
				user.visible_message("[user] starts to shave [user.p_their()] head with [src].", \
										span_notice("You start to shave your head with [src]..."))
				if(do_after(user, 5, target = H))
					user.visible_message("[user] shaves [user.p_their()] head with [src].", \
											span_notice("You finish shaving with [src]."))
					shave(H, location)
			else
				var/turf/H_loc = H.loc
				user.visible_message(span_warning("[user] tries to shave [H]'s head with [src]!"), \
										span_notice("You start shaving [H]'s head..."))
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message(span_warning("[user] shaves [H]'s head bald with [src]!"), \
												span_notice("You shave [H]'s head bald."))
						shave(H, location)

/obj/item/razor/proc/new_hairstyle(mob/living/carbon/human/H, mob/user, mirror)
	if (H == user && !mirror)
		to_chat(user, span_warning("You need a mirror to properly style your own hair!"))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in GLOB.hair_styles_list
	if(!get_location_accessible(H, BODY_ZONE_HEAD))
		to_chat(user, span_warning("The headgear is in the way!"))
		return
	user.visible_message(span_notice("[user] tries to change [H]'s hairstyle using [src]."), span_notice("You try to change [H]'s hairstyle using [src]."))
	if(new_style && do_after(user, 60, target = H))
		user.visible_message(span_notice("[user] successfully changes [H]'s hairstyle using [src]."), span_notice("You successfully change [H]'s hairstyle using [src]."))
		H.hair_style = new_style
		H.update_hair()

/obj/item/razor/proc/new_facial_hairstyle(mob/living/carbon/human/H, mob/user, mirror)
	if(H == user && !mirror)
		to_chat(user, span_warning("You need a mirror to properly style your own facial hair!"))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in GLOB.facial_hair_styles_list
	if(!get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH))
		to_chat(user, span_warning("The mask is in the way!"))
		return
	user.visible_message(span_notice("[user] tries to change [H]'s facial hair style using [src]."), span_notice("You try to change [H]'s facial hair style using [src]."))
	if(new_style && do_after(user, 60, target = H))
		user.visible_message(span_notice("[user] successfully changes [H]'s facial hair style using [src]."), span_notice("You successfully change [H]'s facial hair style using [src]."))
		H.facial_hair_style = new_style
		H.update_hair()

/obj/item/razor/straightrazor
	name = "straight razor"
	icon_state = "straightrazor"
	desc = "An incredibly sharp razor used to shave chins, make surgical incisions, and slit the throats of unpaying customers"
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb_continuous = list("stubs", "pokes")
	attack_verb_simple = list("stub", "poke")
	extended = 0
	var/extended_force = 10
	var/extended_throwforce = 7
	var/extended_icon_state = "straightrazor_open"

/obj/item/razor/straightrazor/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] own throat with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/razor/straightrazor/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	if(extended)
		force = extended_force
		w_class = WEIGHT_CLASS_SMALL //if it becomes normal you can decapitate a guy with a straight razor
		throwforce = extended_throwforce
		icon_state = extended_icon_state
		attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
		attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
		hitsound = 'sound/weapons/bladeslice.ogg'
		sharpness = SHARP
		bleed_force = BLEED_SURFACE
		tool_behaviour = TOOL_SCALPEL
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		throwforce = initial(throwforce)
		icon_state = initial(icon_state)
		attack_verb_continuous = list("stubs", "pokes")
		attack_verb_simple = list("stub", "poke")
		hitsound = 'sound/weapons/genhit.ogg'
		sharpness = BLUNT
		bleed_force = 0
		tool_behaviour = null

/obj/item/handmirror
	name = "hand mirror"
	desc = "A cheap plastic hand mirror. Useful for shaving and self-diagnoses"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handmirror"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throwforce = 2
	throw_speed = 3
	throw_range = 6

/obj/item/handmirror/attack_self(mob/user)
	ADD_TRAIT(user, TRAIT_SELF_AWARE, "mirror_trait")
	to_chat(user, span_notice("You look into the mirror"))
	sleep(150)
	REMOVE_TRAIT(user, TRAIT_SELF_AWARE, "mirror_trait")
