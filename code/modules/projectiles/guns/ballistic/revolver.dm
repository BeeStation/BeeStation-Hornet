/obj/item/gun/ballistic/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo." //usually used by syndicates
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	fire_sound = 'sound/weapons/revolver357shot.ogg'
	load_sound = 'sound/weapons/revolverload.ogg'
	eject_sound = 'sound/weapons/revolverempty.ogg'
	vary_fire_sound = FALSE
	fire_sound_volume = 90
	dry_fire_sound = 'sound/weapons/revolverdry.ogg'
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	tac_reloads = FALSE
	fire_rate = 1.5 //slower than normal guns due to the damage factor
	var/spin_delay = 10
	var/recent_spin = 0

/obj/item/gun/ballistic/revolver/chamber_round(spin_cylinder = TRUE)
	if(spin_cylinder)
		chambered = magazine.get_round(TRUE)
	else
		chambered = magazine.stored_ammo[1]

/obj/item/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	chamber_round(TRUE)

/obj/item/gun/ballistic/revolver/AltClick(mob/user)
	..()
	spin()


/obj/item/gun/ballistic/revolver/fire_sounds()
	var/frequency_to_use = sin((90/magazine?.max_ammo) * get_ammo(TRUE, FALSE)) // fucking REVOLVERS
	var/click_frequency_to_use = 1 - frequency_to_use * 0.75
	var/play_click = sqrt(magazine?.max_ammo) > get_ammo(TRUE, FALSE)
	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		if(play_click)
			playsound(src, 'sound/weapons/effects/ballistic_click.ogg', suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = click_frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound)
		if(play_click)
			playsound(src, 'sound/weapons/effects/ballistic_click.ogg', fire_sound_volume, vary_fire_sound, frequency = click_frequency_to_use)

/obj/item/gun/ballistic/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if (recent_spin > world.time)
		return
	recent_spin = world.time + spin_delay

	if(do_spin())
		playsound(usr, "revolver_spin", 30, FALSE)
		usr.visible_message("[usr] spins [src]'s chamber.", span_notice("You spin [src]'s chamber."))
	else
		remove_verb(/obj/item/gun/ballistic/revolver/verb/spin)

/obj/item/gun/ballistic/revolver/proc/do_spin()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	. = istype(C)
	if(.)
		C.spin()
		chamber_round(FALSE)

/obj/item/gun/ballistic/revolver/get_ammo(countchambered = FALSE, countempties = TRUE)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/ballistic/revolver/examine(mob/user)
	. = ..()
	var/live_ammo = get_ammo(FALSE, FALSE)
	. += "[live_ammo ? live_ammo : "None"] of those are live rounds."
	if (current_skin)
		. += "It can be spun with <b>alt+click</b>"

/obj/item/gun/ballistic/revolver/detective
	name = "\improper Colt Detective Special"
	desc = "A classic, if not outdated, law enforcement firearm. Uses .38-special rounds."
	fire_sound = 'sound/weapons/revolver38shot.ogg'
	icon_state = "detective"
	fire_rate = 2
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/rubber
	obj_flags = UNIQUE_RENAME
	unique_reskin_icon = list(
		"Default" = "detective",
		"Fitz Special" = "detective_fitz",
		"Police Positive Special" = "detective_police",
		"Blued Steel" = "detective_blued",
		"Stainless Steel" = "detective_stainless",
		"Gold Trim" = "detective_gold",
		"Leopard Spots" = "detective_leopard",
		"The Peacemaker" = "detective_peacemaker",
		"Black Panther" = "detective_panther"
	)

/obj/item/gun/ballistic/revolver/detective/cowboy
	name = "sheriff's revolver"
	desc = "Reach for the skies."
	icon_state = "detective_peacemaker"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	unique_reskin_icon = null

/obj/item/gun/ballistic/revolver/detective/random
	name = "\improper Colt .38 revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/random

/obj/item/gun/ballistic/revolver/detective/reskin_obj(mob/M)
	if(isnull(unique_reskin))
		unique_reskin = list(
			"Default" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective"),
			"Fitz Special" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_fitz"),
			"Police Positive Special" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_police"),
			"Blued Steel" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_blued"),
			"Stainless Steel" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_stainless"),
			"Gold Trim" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_gold"),
			"Leopard Spots" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_leopard"),
			"The Peacemaker" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_peacemaker"),
			"Black Panther" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "detective_panther")
		)
	. = ..()

/obj/item/gun/ballistic/revolver/detective/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	if(magazine.caliber != initial(magazine.caliber))
		if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
			playsound(user, fire_sound, fire_sound_volume, vary_fire_sound)
			to_chat(user, span_userdanger("[src] blows up in your face!"))
			user.take_bodypart_damage(0,20)
			explosion(src, 0, 0, 1, 1)
			user.dropItemToGround(src)
			return 0
	return ..()

/obj/item/gun/ballistic/revolver/detective/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(magazine.caliber == "38")
		to_chat(user, span_notice("You begin to reinforce the barrel of [src]..."))
		if(magazine.ammo_count())
			afterattack(user, user)	//you know the drill
			user.visible_message(span_danger("[src] goes off!"), span_userdanger("[src] goes off in your face!"))
			return TRUE
		if(I.use_tool(src, user, 30))
			if(magazine.ammo_count())
				to_chat(user, span_warning("You can't modify it!"))
				return TRUE
			magazine.caliber = "357"
			src.caliber = magazine.caliber
			fire_rate = 1 //worse than a nromal .357
			fire_sound = 'sound/weapons/revolver357shot.ogg'
			desc = "The barrel and chamber assembly seems to have been modified."
			to_chat(user, span_notice("You reinforce the barrel of [src]. Now it will fire .357 rounds."))
	else
		to_chat(user, span_notice("You begin to revert the modifications to [src]..."))
		if(magazine.ammo_count())
			afterattack(user, user)	//and again
			user.visible_message(span_danger("[src] goes off!"), span_userdanger("[src] goes off in your face!"))
			return TRUE
		if(I.use_tool(src, user, 30))
			if(magazine.ammo_count())
				to_chat(user, span_warning("You can't modify it!"))
				return
			magazine.caliber = "38"
			src.caliber = magazine.caliber
			fire_rate = initial(fire_rate)
			fire_sound = 'sound/weapons/revolver38shot.ogg'
			desc = initial(desc)
			to_chat(user, span_notice("You remove the modifications on [src]. Now it will fire .38 rounds."))
	return TRUE


/obj/item/gun/ballistic/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."
	icon_state = "mateba"

/obj/item/gun/ballistic/revolver/golden
	name = "\improper Golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8
	fire_rate = 2 //keeping with the description's reference, this fires slightly faster than the normal gun
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/nagant
	name = "\improper Nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	can_suppress = TRUE

	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762


// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/gun/ballistic/revolver/russian
	name = "\improper Russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism requiring you to spin the chamber before each trigger pull."
	icon_state = "russianrevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = FALSE

/obj/item/gun/ballistic/revolver/russian/do_spin()
	. = ..()
	spun = TRUE

/obj/item/gun/ballistic/revolver/russian/attackby(obj/item/A, mob/user, params)
	..()
	if(get_ammo() > 0)
		spin()
	update_icon()
	A.update_icon()
	return

/obj/item/gun/ballistic/revolver/russian/attack_self(mob/user)
	if(!spun)
		spin()
		spun = TRUE
		return
	..()

/obj/item/gun/ballistic/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	. = ..(null, user, flag, params)

	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.combat_mode) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			to_chat(user, span_warning("A mechanism prevents you from shooting anyone but yourself!"))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!spun)
			to_chat(user, span_warning("You need to spin \the [src]'s chamber first!"))
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire_casing(user, user))
				playsound(user, fire_sound, fire_sound_volume, vary_fire_sound)
				var/zone = check_zone(user.get_combat_bodyzone(target))
				var/obj/item/bodypart/affecting = H.get_bodypart(zone)
				if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH)
					shoot_self(user, affecting)
				else
					user.visible_message(span_danger("[user.name] cowardly fires [src] at [user.p_their()] [affecting.name]!"), span_userdanger("You cowardly fire [src] at your [affecting.name]!"), span_italics("You hear a gunshot!"))
				chambered = null
				return

		user.visible_message(span_danger("*click*"))
		playsound(src, dry_fire_sound, 30, TRUE)

/obj/item/gun/ballistic/revolver/russian/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	add_fingerprint(user)
	playsound(src, dry_fire_sound, 30, TRUE)
	user.visible_message(span_danger("[user.name] tries to fire \the [src] at the same time, but only succeeds at looking like an idiot."), span_danger("\The [src]'s anti-combat mechanism prevents you from firing it at the same time!"))

/obj/item/gun/ballistic/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(span_danger("[user.name] fires [src] at [user.p_their()] head!"), span_userdanger("You fire [src] at your head!"), span_italics("You hear a gunshot!"))

/obj/item/gun/ballistic/revolver/russian/soul
	name = "cursed Russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/gun/ballistic/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/soulstone/anybody/revolver/SS = new /obj/item/soulstone/anybody/revolver(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message(span_danger("[user.name]'s soul is captured by \the [src]!"), span_userdanger("You've lost the gamble! Your soul is forfeit!"))

/obj/item/gun/ballistic/revolver/reverse //Fires directly at its user... unless the user is a clown, of course.
	clumsy_check = 0

/obj/item/gun/ballistic/revolver/reverse/can_trigger_gun(mob/living/user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) || (user.mind && user.mind.assigned_role == JOB_NAME_CLOWN))
		return ..()
	if(process_fire(user, user, FALSE, null, BODY_ZONE_HEAD))
		user.visible_message(span_warning("[user] somehow manages to shoot [user.p_them()]self in the face!"), span_userdanger("You somehow shoot yourself in the face! How the hell?!"))
		user.emote("scream")
		user.drop_all_held_items()
		user.Paralyze(80)
	return FALSE

/obj/item/gun/ballistic/revolver/mime
	name = "finger gun"
	desc = "Your hand, pointed into the shape of a gun."
	fire_sound = null
	dry_fire_sound = 'sound/misc/fingersnap1.ogg'
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/mime
	lefthand_file = null
	righthand_file = null
	item_flags = DROPDEL | ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/gun/ballistic/revolver/mime/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("Your fingergun is out of ammo!"))
	qdel(src)

/obj/item/gun/ballistic/revolver/mime/attack_self(mob/user)
	qdel(src)

//The Lethal Version from Advanced Mimery
/obj/item/gun/ballistic/revolver/mime/magic
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/mime/lethal
