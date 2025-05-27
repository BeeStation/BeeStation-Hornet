/obj/item/gun/ballistic
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_LARGE

	//sound info vars
	var/load_sound = "gun_insert_full_magazine"
	var/load_empty_sound = "gun_insert_empty_magazine"
	var/load_sound_volume = 40
	var/load_sound_vary = TRUE
	var/rack_sound = "gun_slide_lock"
	var/half_rack_sound = "gun_slide_lock" //Only needs to be used on BOLT_TYPE_PUMP guns, for Ctrl-Click functionality
	var/rack_sound_volume = 60
	var/rack_sound_vary = TRUE
	var/lock_back_sound = "sound/weapons/pistollock.ogg"
	var/lock_back_sound_volume = 60
	var/lock_back_sound_vary = TRUE
	var/eject_sound = "gun_remove_empty_magazine"
	var/eject_empty_sound = "gun_remove_full_magazine"
	var/eject_sound_volume = 40
	var/eject_sound_vary = TRUE
	var/bolt_drop_sound = 'sound/weapons/gun_chamber_round.ogg'
	var/bolt_drop_sound_volume = 60
	var/empty_alarm_sound = 'sound/weapons/smg_empty_alarm.ogg'
	var/empty_alarm_volume = 70
	var/empty_alarm_vary = TRUE

	//Info below has to deal with guns with internal magazines or actual removable magazines.
	var/spawnwithmagazine = TRUE
	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info //Shame I had to add caliber back anyway :^)
	var/mag_display = FALSE //Whether the sprite has a visible magazine or not
	var/mag_display_ammo = FALSE //Whether the sprite has a visible ammo display or not
	var/empty_indicator = FALSE //Whether the sprite has an indicator for being empty or not.
	var/empty_alarm = FALSE //Whether the gun alarms when empty or not.
	var/special_mags = FALSE //Whether the gun supports multiple special mag types
	var/alarmed = FALSE
	//Additional info related to the actual chambering, and to allow loading bullets directly into battery / into var/chambered
	//Copies the caliber of the magazine in the gun during Initialize() | Must be explicitly set on the gun if it spawns without a magazine ;)
	var/caliber = null
	var/direct_loading = FALSE //A gun with this allows the internal magazine to be loaded without removing, ontop of directly chambering rounds
	//Six bolt types:
	//BOLT_TYPE_STANDARD: Gun has a bolt, it stays closed while not cycling. The gun must be racked to have a bullet chambered when a mag is inserted.
	//Example: c20, m90
	//BOLT_TYPE_OPEN: Gun has a bolt, it is open when ready to fire. The gun can never have a chambered bullet with no magazine, but the bolt stays ready when a mag is removed.
	//Example: Some SMGs, the L6
	//BOLT_TYPE_NO_BOLT: Gun has no moving bolt mechanism, it cannot be racked. Also dumps the entire contents when emptied instead of a magazine.
	//Example: Rocket launchers, Break-action shotguns, revolvers, derringer
	//BOLT_TYPE_LOCKING: Gun has a bolt, it locks back when empty. It can be released to chamber a round if a magazine is in.
	//Example: Pistols with a slide lock, some SMGs
	//BOLT_TYPE_PUMP: Functions identically to BOLT_TYPE_STANDARD, but requires two hands to rack the bolt.
	//Examples: Pump-action shotguns
	//BOLT_TYPE_TWO_STEP: Functions identically to BOLT_TYPE_PUMP (and thus, STANDARD), but each interaction with the bolt toggles between locked (open) & unlocked (closed).
	//Examples: Mosin nagant, pipe guns
	var/bolt_type = BOLT_TYPE_STANDARD
	var/bolt_locked = FALSE //Used for locking bolt and open bolt guns. Set a bit differently for the two but prevents firing when true for both.
	var/bolt_wording = "bolt" //bolt, slide, etc.
	var/semi_auto = TRUE //Whether the gun has to be racked each shot or not.
	var/obj/item/ammo_box/magazine/magazine
	var/casing_ejector = TRUE //whether the gun ejects the chambered casing
	var/internal_magazine = FALSE //Whether the gun has an internal magazine or a detatchable one. Overridden by BOLT_TYPE_NO_BOLT.
	var/magazine_wording = "magazine"
	var/cartridge_wording = "bullet"
	var/rack_delay = 5
	var/recent_rack = 0
	var/tac_reloads = TRUE //Snowflake mechanic no more.

/obj/item/gun/ballistic/Initialize(mapload)
	. = ..()
	if (!spawnwithmagazine)
		bolt_locked = TRUE
		update_icon()
		return
	if (!magazine)
		magazine = new mag_type(src)
	if (!caliber)
		caliber = magazine.caliber
	chamber_round()
	update_icon()

/obj/item/gun/ballistic/fire_sounds()
	var/frequency_to_use
	var/play_click
	if(magazine)
		frequency_to_use = sin((90/magazine?.max_ammo) * get_ammo())
		play_click = round(sqrt(magazine?.max_ammo * 2)) > get_ammo()
	else
		frequency_to_use = sin((90) * get_ammo())
		play_click = round(sqrt(2)) > get_ammo()
	var/click_frequency_to_use = 1 - frequency_to_use * 0.75

	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		if(play_click)
			playsound(src, 'sound/weapons/effects/ballistic_click.ogg', suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = click_frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound)
		if(play_click)
			playsound(src, 'sound/weapons/effects/ballistic_click.ogg', fire_sound_volume, vary_fire_sound, frequency = click_frequency_to_use)

/obj/item/gun/ballistic/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_ballistic))

/**
 *
 * Outputs type-specific weapon stats for ballistic weaponry based on its magazine and its caliber.
 * It contains extra breaks for the sake of presentation
 *
 */
/obj/item/gun/ballistic/proc/add_notes_ballistic()
	if(magazine) // Make sure you have a magazine, to get the notes from
		return "\n[magazine.add_notes_box()]"
	else if(chambered) // if you don't have a magazine, is there something chambered?
		return "\n[chambered.add_notes_ammo()]"
	else // we have a very expensive mechanical paperweight.
		return "\nThe lack of magazine and usable cartridge in chamber makes its usefulness questionable, at best."

/obj/item/gun/ballistic/vv_edit_var(vname, vval)
	. = ..()
	if(vname in list(NAMEOF(src, internal_magazine), NAMEOF(src, magazine), NAMEOF(src, chambered), NAMEOF(src, empty_indicator), NAMEOF(src, sawn_off), NAMEOF(src, bolt_locked), NAMEOF(src, bolt_type)))
		update_appearance()

/obj/item/gun/ballistic/update_icon()
	if (QDELETED(src))
		return
	..()
	if(current_skin)
		icon_state = "[unique_reskin_icon[current_skin]][sawn_off ? "_sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][sawn_off ? "_sawn" : ""]"

/obj/item/gun/ballistic/update_overlays()
	. = ..()
	switch(bolt_type)
		if(BOLT_TYPE_LOCKING, BOLT_TYPE_PUMP, BOLT_TYPE_TWO_STEP)
			. += "[icon_state]_bolt[bolt_locked ? "_locked" : ""]"
	if (bolt_type == BOLT_TYPE_OPEN && bolt_locked)
		. += "[icon_state]_bolt"
	if (suppressed)
		. += "[icon_state]_suppressor"
	if(!chambered && empty_indicator)
		. += "[icon_state]_empty"
	if (magazine)
		if (special_mags)
			if(magazine.multiple_sprites)
				. += "[icon_state]_mag_[initial(magazine.icon_state)]"
			else
				. += "[icon_state]_mag_[magazine.icon_state]"
			if (!magazine.ammo_count())
				. += "[icon_state]_mag_empty"
		else
			. += "[icon_state]_mag"
			var/capacity_number = 0
			switch(get_ammo() / magazine.max_ammo)
				if(0.2 to 0.39)
					capacity_number = 20
				if(0.4 to 0.59)
					capacity_number = 40
				if(0.6 to 0.79)
					capacity_number = 60
				if(0.8 to 0.99)
					capacity_number = 80
				if(1.0)
					capacity_number = 100
			if (capacity_number)
				. += "[icon_state]_mag_[capacity_number]"

/obj/item/gun/ballistic/update_icon_state()
	. = ..()
	if(current_skin)
		icon_state = "[unique_reskin_icon[current_skin]][sawn_off ? "_sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][sawn_off ? "_sawn" : ""]"

/obj/item/gun/ballistic/on_chamber_fired()
	if (casing_ejector)
		eject_chamber()
	else
		chambered = null
	if (!semi_auto)
		return
	chamber_round()

/obj/item/gun/ballistic/proc/eject_chamber()
	if (!chambered)
		return
	chambered.forceMove(drop_location())
	chambered.bounce_away(TRUE)
	chambered = null

/obj/item/gun/ballistic/proc/chamber_round(keep_bullet = FALSE)
	if (chambered || !magazine)
		return
	if (magazine.ammo_count())
		chambered = magazine.get_round(keep_bullet || bolt_type == BOLT_TYPE_NO_BOLT)
		if (bolt_type != BOLT_TYPE_OPEN)
			chambered.forceMove(src)

/obj/item/gun/ballistic/proc/rack(mob/user = null)
	switch(bolt_type)
		if(BOLT_TYPE_NO_BOLT)
			return
		if(BOLT_TYPE_OPEN)
			if(!bolt_locked)	//If it's an open bolt, racking again would do nothing
				if(user)
					to_chat(user, span_notice("\The [src]'s [bolt_wording] is already cocked!"))
				return
			bolt_locked = FALSE
		if(BOLT_TYPE_TWO_STEP)
			if(!is_wielded && !HAS_TRAIT(user, TRAIT_NICE_SHOT))
				to_chat(user, span_warning("You require your other hand to be free to rack the [bolt_wording] of \the [src]!"))
				return
				//If it's locked (open), drop the bolt to close and unlock it
			if(bolt_locked == TRUE)
				drop_bolt(user)
				return
			//Otherwise, we open the bolt and eject the current casing
			if(!is_wielded && prob(20))
				user.visible_message(span_notice("[user] racks \the [src]'s [bolt_wording] with a single hand!"))
			to_chat(user, span_notice("You open the [bolt_wording] of \the [src]."))
			playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
			if (chambered)
				eject_chamber()
			else
				chamber_round()
			bolt_locked = TRUE
			update_icon()
			return
		if(BOLT_TYPE_PUMP)
			if(!is_wielded && !HAS_TRAIT(user, TRAIT_NICE_SHOT))
				to_chat(user, span_warning("You require your other hand to be free to rack the [bolt_wording] of \the [src]!"))
				return
			if(!is_wielded && prob(20))
				user.visible_message(span_notice("[user] racks \the [src]'s [bolt_wording] with a single hand!"))
			if(bolt_locked == TRUE) //If it's locked (open), drop the bolt to close and unlock it
				drop_bolt(user)
				return
			//Otherwise, we open the bolt and eject the current casing
	if(user)
		to_chat(user, span_notice("You rack the [bolt_wording] of \the [src]."))
	if (chambered)
		eject_chamber()
	else
		chamber_round()
	if (bolt_type == BOLT_TYPE_LOCKING && !chambered)
		bolt_locked = TRUE
		playsound(src, lock_back_sound, lock_back_sound_volume, lock_back_sound_vary)
	else
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	update_icon()

/obj/item/gun/ballistic/proc/drop_bolt(mob/user = null)
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	if (user)
		to_chat(user, span_notice("You drop the [bolt_wording] of \the [src]."))
	chamber_round()
	bolt_locked = FALSE
	update_icon()

/obj/item/gun/ballistic/proc/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	if(!istype(AM, mag_type))
		to_chat(user, span_warning("\The [AM] doesn't seem to fit into \the [src]..."))
		return FALSE
	if(user.transferItemToLoc(AM, src))
		magazine = AM
		if (display_message)
			to_chat(user, span_notice("You load a new [magazine_wording] into \the [src]."))
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			chamber_round()
		update_icon()
		return TRUE
	else
		to_chat(user, span_warning("You cannot seem to get \the [src] out of your hands!"))
		return FALSE

/obj/item/gun/ballistic/proc/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(bolt_type == BOLT_TYPE_OPEN)
		//Put the chambered bullet back into the magazine, because it was never really taken out in the first place.
		if(chambered)
			magazine.attackby(chambered, user, null, TRUE, FALSE)
		chambered = null
	if (magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine.forceMove(drop_location())
	var/obj/item/ammo_box/magazine/old_mag = magazine
	if (tac_load)
		if (insert_magazine(user, tac_load, FALSE))
			to_chat(user, span_notice("You perform a tactical reload on \the [src]."))
		else
			to_chat(user, span_warning("You dropped the old [magazine_wording], but the new one doesn't fit. How embarrassing."))
			magazine = null
	else
		magazine = null
	user.put_in_hands(old_mag)
	old_mag.update_icon()
	if (display_message)
		to_chat(user, span_notice("You pull the [magazine_wording] out of \the [src]."))
	update_icon()

/obj/item/gun/ballistic/can_shoot()
	//If it's locked open (TWO_STEP and PUMP), it can't fire.
	if((bolt_type == BOLT_TYPE_TWO_STEP || bolt_type == BOLT_TYPE_PUMP) && bolt_locked)
		return FALSE
	return chambered && ..()

/obj/item/gun/ballistic/attackby(obj/item/A, mob/user, params)
	..()
	if (.)
		return
	if (!internal_magazine && istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine)
			insert_magazine(user, AM)
		else
			if (tac_reloads)
				eject_magazine(user, FALSE, AM)
			else
				to_chat(user, span_notice("There's already a [magazine_wording] in \the [src]."))
		return
	if (istype(A, /obj/item/ammo_casing) || istype(A, /obj/item/ammo_box))
		//If it has a removable magazine, and does not support direct loading, return.
		if(!internal_magazine && !direct_loading)
			if(magazine)
				to_chat(user, span_notice("Remove \the [src]'s magazine to load it!"))
			return
		//Most guns with internal magazines (or the ability to load a removable one) are loaded through the bolt that gets locked open. PUMP are the exception here.
		if(!bolt_locked && (bolt_type == BOLT_TYPE_LOCKING || bolt_type == BOLT_TYPE_OPEN || bolt_type == BOLT_TYPE_TWO_STEP))
			to_chat(user, span_notice("The [bolt_wording] is closed!"))
			return
		//For chambering cartridges directly, only possible with a single cartridge in hand on guns with either internal magazines or direct_loading set to true
		//The additional check for bolt_locked only applies to PUMP bolt types, as they're the only ones that can load on a closed bolt.
		if(!chambered && istype(A, /obj/item/ammo_casing) && bolt_locked && bolt_type != BOLT_TYPE_OPEN)
			var/obj/item/ammo_casing/AC = A
			//If the gun isn't chambered in the same caliber as the cartridge, don't load it.
			if(src.caliber != AC.caliber)
				to_chat(user, span_warning("\The [src] isn't chambered in this caliber!"))
				return
			chambered = AC
			chambered.forceMove(src)
			to_chat(user, span_notice("You chamber a [cartridge_wording] directly into \the [src]."))
			playsound(src, load_sound, load_sound_volume, load_sound_vary)
			return
		//If we don't have a magazine at all, and didn't load into battery, abort loading
		if(!magazine)
			to_chat(user, span_warning("There's nowhere to load a [cartridge_wording] into!"))
			return
		//Otherwise, try loading into the internal magazine next.
		var/num_loaded = magazine.attackby(A, user, params, TRUE)
		if (num_loaded)
			to_chat(user, span_notice("You load [num_loaded] [cartridge_wording]\s into \the [src]."))
			playsound(src, load_sound, load_sound_volume, load_sound_vary)
			if (chambered == null && bolt_type == BOLT_TYPE_NO_BOLT)
				chamber_round()
			A.update_icon()
			update_icon()
		else
			to_chat(user, span_notice("\The [src] doesn't have room for another [cartridge_wording]!"))
		return
	if(istype(A, /obj/item/suppressor))
		var/obj/item/suppressor/S = A
		if(!can_suppress)
			to_chat(user, span_warning("You can't seem to figure out how to fit [S] on [src]!"))
			return
		if(!user.is_holding(src))
			to_chat(user, span_notice("You need be holding [src] to fit [S] to it!"))
			return
		if(suppressed)
			to_chat(user, span_warning("[src] already has a suppressor!"))
			return
		if(user.transferItemToLoc(A, src))
			to_chat(user, span_notice("You screw \the [S] onto \the [src]."))
			install_suppressor(A)
			return
	if((A.tool_behaviour == TOOL_SAW || istype(A, /obj/item/gun/energy/plasmacutter)) && can_sawoff == TRUE)
		sawoff(user)
		return
	return FALSE

/obj/item/gun/ballistic/get_bullet_spread(mob/living/user, atom/target)
	. = ..()
	if (sawn_off)
		. += SAWN_OFF_ACC_PENALTY

/obj/item/gun/ballistic/proc/install_suppressor(obj/item/suppressor/S)
	// this proc assumes that the suppressor is already inside src
	suppressed = S
	weight_class_up() //so pistols do not fit in pockets when suppressed
	update_icon()

/obj/item/gun/ballistic/AltClick(mob/user)
	if (unique_reskin_icon && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		reskin_obj(user)
		return
	if(loc == user)
		if(suppressed && can_unsuppress)
			if(!user.is_holding(src))
				return
			to_chat(user, span_notice("You unscrew \the [suppressed] from \the [src]."))
			user.put_in_hands(suppressed)
			weight_class_down()
			suppressed = null
			update_icon()
			return

/obj/item/gun/ballistic/CtrlClick(mob/user)
	if(bolt_type == BOLT_TYPE_PUMP && is_wielded && loc == user && !bolt_locked)
		to_chat(user, span_notice("You lock open the [bolt_wording] of \the [src]."))
		playsound(src, half_rack_sound, rack_sound_volume, rack_sound_vary)
		if (chambered)
			eject_chamber()
		else
			chamber_round()
		bolt_locked = TRUE
		update_icon()
		return
	..()

/obj/item/gun/ballistic/proc/prefire_empty_checks()
	if (!chambered && !get_ammo())
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			bolt_locked = TRUE
			playsound(src, bolt_drop_sound, bolt_drop_sound_volume)
			update_icon()


/obj/item/gun/ballistic/proc/postfire_empty_checks()
	if (!chambered && !get_ammo())
		if (!alarmed && empty_alarm)
			playsound(src, empty_alarm_sound, empty_alarm_volume, empty_alarm_vary)
			alarmed = TRUE
			update_icon()
		if (bolt_type == BOLT_TYPE_LOCKING && semi_auto)
			bolt_locked = TRUE
			update_icon()

/obj/item/gun/ballistic/pull_trigger(atom/target, mob/living/user, flag, params, aimed)
	prefire_empty_checks()
	return ..()

/obj/item/gun/ballistic/on_chamber_fired()
	. = ..()
	postfire_empty_checks()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/attack_hand(mob/user, list/modifiers)
	if(!internal_magazine && loc == user && user.is_holding(src) && magazine)
		eject_magazine(user)
		return
	return ..()

/obj/item/gun/ballistic/attack_self(mob/living/user)
	if(!internal_magazine && magazine)
		if(!magazine.ammo_count())
			eject_magazine(user)
			return

	if(bolt_type == BOLT_TYPE_NO_BOLT)
		chambered = null
		var/num_unloaded = 0
		for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
			CB.forceMove(drop_location())
			CB.bounce_away(FALSE, NONE)
			num_unloaded++
		if (num_unloaded)
			to_chat(user, span_notice("You unload [num_unloaded] [cartridge_wording]\s from [src]."))
			playsound(user, eject_sound, eject_sound_volume, eject_sound_vary)
			update_icon()
			return

	if(bolt_type == BOLT_TYPE_LOCKING && bolt_locked)
		drop_bolt(user)
		return
	if (recent_rack > world.time)
		return
	recent_rack = world.time + rack_delay
	rack(user)
	return

/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	var/count_chambered = !(bolt_type == BOLT_TYPE_NO_BOLT)
	. += "It has [get_ammo(count_chambered)] round\s remaining."
	if (!chambered)
		. += "It does not seem to have a round chambered."
	if (bolt_locked)
		. += "The [bolt_wording] is locked back and needs to be released before firing."
	if (suppressed)
		. += "It has a suppressor attached that can be removed with <b>alt+click</b>."
	if (bolt_type == BOLT_TYPE_PUMP)
		. += "You can <b>ctrl+click</b> to half-pump \the [src] to directly chamber a [cartridge_wording]."

/obj/item/gun/ballistic/proc/get_ammo(countchambered = TRUE)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/gun/ballistic/proc/get_ammo_list(countchambered = TRUE, drop_all = FALSE)
	var/list/rounds = list()
	if(chambered && countchambered)
		rounds.Add(chambered)
		if(drop_all)
			chambered = null
	rounds.Add(magazine.ammo_list(drop_all))
	return rounds

#define BRAINS_BLOWN_THROW_RANGE 3
#define BRAINS_BLOWN_THROW_SPEED 1

/obj/item/gun/ballistic/suicide_act(mob/living/user)
	var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
	if (B && chambered && chambered.BB && can_trigger_gun(user) && !chambered.BB.nodamage)
		user.visible_message(span_suicide("[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!"))
		sleep(25)
		if(user.is_holding(src))
			var/turf/T = get_turf(user)
			process_fire(user, user, FALSE, null, BODY_ZONE_HEAD)
			user.visible_message(span_suicide("[user] blows [user.p_their()] brain[user.p_s()] out with [src]!"))
			var/turf/target = get_ranged_target_turf(user, turn(user.dir, 180), BRAINS_BLOWN_THROW_RANGE)
			B.Remove(user)
			B.forceMove(T)
			var/datum/callback/gibspawner = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_atom_to_turf), /obj/effect/gibspawner/generic, B, 1, FALSE, user)
			B.throw_at(target, BRAINS_BLOWN_THROW_RANGE, BRAINS_BLOWN_THROW_SPEED, callback=gibspawner)
			return BRUTELOSS
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(span_suicide("[user] is pretending to blow [user.p_their()] brain[user.p_s()] out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b>"))
		playsound(src, dry_fire_sound, 30, TRUE)
		return OXYLOSS
#undef BRAINS_BLOWN_THROW_SPEED
#undef BRAINS_BLOWN_THROW_RANGE


/obj/item/gun/ballistic/proc/sawoff(mob/user)
	if(sawn_off)
		to_chat(user, span_warning("\The [src] is already shortened!"))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", span_notice("You begin to shorten \the [src]..."))

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message(span_danger("\The [src] goes off!"), span_danger("\The [src] goes off in your face!"))
		return

	if(do_after(user, 30, target = src))
		if(sawn_off)
			return
		user.visible_message("[user] shortens \the [src]!", span_notice("You shorten \the [src]."))
		if (bayonet)
			bayonet.forceMove(drop_location())
			bayonet = null
			update_appearance()
		if (suppressed)
			if (istype(suppressed, /obj/item/suppressor))
				//weight class is set later, don't need to worry about removing extra weight from the suppressor
				var/obj/S = suppressed
				S.forceMove(drop_location())
			//If it's integrally suppressed, you're messing that up by chopping off most of it from the tip
			suppressed = null
		if (sawn_name)
			name = sawn_name
		else
			name = "sawn-off [src.name]"
		desc = sawn_desc
			//The file might not have a "gun" icon, let's prepare for this
		lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
		inhand_x_dimension = 32
		inhand_y_dimension = 32
		w_class = WEIGHT_CLASS_LARGE
		if (sawn_item_state)
			item_state = sawn_item_state
		else
			item_state = "gun"
		worn_icon_state = "gun"
		slot_flags &= ~ITEM_SLOT_BACK	//you can't sling it on your back
		slot_flags |= ITEM_SLOT_BELT	//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		recoil += SAWN_OFF_RECOIL		//Add the additional 1 recoil, instead of setting recoil to one (looking at you improv shotgun)
		can_bayonet = FALSE				//you got rid of the mounting lug with the rest of the barrel, dumbass
		can_suppress = FALSE			//ditto for the threaded barrel
		sawn_off = TRUE
		update_icon()
		return TRUE

// Sawing guns related proc
/obj/item/gun/ballistic/proc/blow_up(mob/user)
	. = FALSE
	if(!chambered)
		return
	if(chambered.BB)
		process_fire(user, user, FALSE)
		. = TRUE

/obj/item/suppressor
	name = "suppressor"
	desc = "A syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
	w_class = WEIGHT_CLASS_TINY


/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits most weapons."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
