
#define FIRING_PIN_REMOVAL_DELAY 50

/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	item_flags = SLOWS_WHILE_IN_HAND | NO_WORN_SLOWDOWN | NEEDS_PERMIT
	custom_materials = list(/datum/material/iron=2000)
	w_class = WEIGHT_CLASS_LARGE
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	attack_verb_continuous = list("strikes", "hits", "bashes")
	attack_verb_simple = list("strike", "hit", "bash")
	max_integrity = 500
	integrity_failure = 0.2

	var/fire_sound = "gunshot"
	var/vary_fire_sound = TRUE
	var/fire_sound_volume = 50
	var/dry_fire_sound = 'sound/weapons/gun_dry_fire.ogg'
	var/suppressed = null	//whether or not a message is displayed when fired
	var/can_suppress = FALSE
	var/suppressed_sound = 'sound/weapons/gunshot_silenced.ogg'
	var/suppressed_volume = 10
	var/can_unsuppress = TRUE
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = TRUE
	var/obj/item/ammo_casing/chambered = null
	trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/can_sawoff = FALSE
	var/sawn_name = null				//used if gun has a special sawn-off rename
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_inhand_icon_state = null			//used if gun has a special sawn-off in-hand sprite
	var/sawn_off = FALSE
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/weapon_weight = WEAPON_LIGHT
	var/dual_wield_spread = 24			//additional spread when dual wielding

	var/spread = 0						//Spread induced by the gun itself.
	var/requires_wielding = TRUE
	var/spread_unwielded				//Spread induced by holding the gun with 1 hand. (40 for light weapons, 60 for medium by default)
	var/wild_spread = FALSE				//Sets a minimum level of bullet spread per shot; meant for difficult to aim / inaccurate guns.
	var/wild_factor = 0.25				//Multiplied by spread to calculate the 'minimum' spread per shot.

	var/full_auto = FALSE //Set this if your gun uses full auto. ONLY guns that go brr should use this. Not pistols!
	var/datum/component/full_auto/autofire_component = null //Repeated calls to getComponent aren't really ideal. So we'll take the memory hit instead.

	var/is_wielded = FALSE

	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

	var/obj/item/firing_pin/pin = /obj/item/firing_pin //standard firing pin for most guns
	var/no_pin_required = FALSE //whether the gun can be fired without a pin

	var/can_bayonet = FALSE //if a bayonet can be added or removed if it already has one.
	var/obj/item/knife/bayonet
	var/knife_x_offset = 0
	var/knife_y_offset = 0

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/zoom_out_amt = 0
	var/datum/action/toggle_scope_zoom/azoom

	var/automatic = 0 //can gun use it, 0 is no, anything above 0 is the delay between clicks in ds

	var/fire_rate = null //how many times per second can a gun fire? default is 2.5
	//Autofire
	var/atom/autofire_target = null //What are we aiming at? This will change if you move your mouse whilst spraying.
	var/next_autofire = 0 //As to stop mag dumps, Whoops!
	var/pb_knockback = 0
	var/ranged_cooldown = 0

	// Equipping
	/// The time it takes for a gun to count as equipped, null to get a precalculated value
	var/equip_time = null
	/// The timer ID of our equipping action
	VAR_PRIVATE/equip_timer_id

	// Weapon slowdown
	var/has_weapon_slowdown = TRUE

	/// Maximum amount of projectile variance for damaged guns
	var/damage_variance = 50

	/// Can we hold someone at gunpoint with this?
	var/can_gunpoint = TRUE

/obj/item/gun/Initialize(mapload)
	. = ..()
	if(pin)
		if(no_pin_required)
			pin = null
		else
			pin = new pin(src)

	add_seclight_point()

	if(!canMouseDown) //Some things like beam rifles override this.
		canMouseDown = automatic //Nsv13 / Bee change.
	build_zooming()
	if (isnull(equip_time))
		// Light guns: 0.5 second equip time
		// Medium guns: 0.8 second equip time
		// Heavy guns: 1.1 second equip time
		equip_time = weapon_weight * 3 + 2
	if (isnull(spread_unwielded))
		spread_unwielded = weapon_weight * 10 + 10
	if (has_weapon_slowdown)
		if (!slowdown)
			slowdown = 0.1 + weapon_weight * 0.3
		item_flags |= SLOWS_WHILE_IN_HAND
	if(requires_wielding)
		RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(wield))
		RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(unwield))

	//Smaller weapons are better when used in a single hand.
	if(requires_wielding)
		AddComponent(/datum/component/two_handed, unwield_on_swap = TRUE, auto_wield = TRUE, ignore_attack_self = TRUE, force_wielded = force, force_unwielded = force, block_power_wielded = block_power, block_power_unwielded = block_power)
	if (can_gunpoint)
		AddComponent(/datum/component/aiming)

/obj/item/gun/proc/wield()
	is_wielded = TRUE

/obj/item/gun/proc/unwield()
	is_wielded = FALSE

/obj/item/gun/Destroy()
	if(isobj(pin)) //Can still be the initial path, then we skip
		QDEL_NULL(pin)
	if(bayonet)
		QDEL_NULL(bayonet)
	if(chambered) //Not all guns are chambered (EMP'ed energy guns etc)
		QDEL_NULL(chambered)
	if(azoom)
		QDEL_NULL(azoom)
	return ..()

/// Handles adding [the seclite mount component][/datum/component/seclite_attachable] to the gun.
/// If the gun shouldn't have a seclight mount, override this with a return.
/// Or, if a child of a gun with a seclite mount has slightly different behavior or icons, extend this.
/obj/item/gun/proc/add_seclight_point()
	return

/obj/item/gun/handle_atom_del(atom/A)
	if(A == pin)
		pin = null
	if(A == chambered)
		chambered = null
		update_appearance(UPDATE_ICON)
	return ..()

/obj/item/gun/Exited(atom/movable/gone, direction)
	if(gone == bayonet)
		bayonet = null
		if(!QDELING(src))
			update_appearance()
	return ..()

/obj/item/gun/examine(mob/user)
	. = ..()

	if(!no_pin_required)
		if(pin)
			. += "It has \a [pin] installed."
			. += span_info("[pin] looks like it could be removed with some <b>tools</b>.")
		else
			. += "It doesn't have a <b>firing pin</b> installed, and won't fire."

	if(bayonet)
		. += "It has \a [bayonet] [can_bayonet ? "" : "permanently "]affixed to it."
		if(can_bayonet) //if it has a bayonet and this is false, the bayonet is permanent.
			. += span_info("[bayonet] looks like it can be <b>unscrewed</b> from [src].")
	if(can_bayonet)
		. += "It has a <b>bayonet</b> lug on it."

	if(weapon_weight == WEAPON_HEAVY)
		. += "This weapon is too heavy to use with just 1 hand!"

	if (atom_integrity < max_integrity * integrity_failure)
		. += "It is irrepairably damaged!"


/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(zoomed && user.get_active_held_item() != src)
		zoom(user, user.dir, FALSE) //we can only stay zoomed in if it's in our hands	//yeah and we only unzoom if we're actually zoomed using the gun!!
	if (slot == ITEM_SLOT_HANDS)
		ranged_cooldown = max(world.time + equip_time, ranged_cooldown)
		user.client?.give_cooldown_cursor(ranged_cooldown - world.time)
	else
		if (equip_timer_id)
			deltimer(equip_timer_id)
			equip_timer_id = null

/obj/item/gun/pickup(mob/user)
	..()
	if(azoom)
		azoom.Grant(user)

/obj/item/gun/dropped(mob/user)
	..()
	if(azoom)
		azoom.Remove(user)
	if(zoomed)
		zoom(user, user.dir)
	update_icon()
	user.client?.clear_cooldown_cursor()
	if (equip_timer_id)
		deltimer(equip_timer_id)
		equip_timer_id = null

//called after the gun has successfully fired its chambered ammo.
/obj/item/gun/proc/on_chamber_fired()
	chambered = null

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot()
	return atom_integrity >= integrity_failure * max_integrity

/obj/item/gun/proc/tk_firing(mob/living/user)
	return loc != user ? TRUE : FALSE

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj)
	balloon_alert_to_viewers("*click*")
	playsound(src, dry_fire_sound, 30, TRUE)

/obj/item/gun/proc/fire_sounds()
	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound)

/obj/item/gun/proc/after_live_shot_fired(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	if(recoil && !tk_firing(user))
		shake_camera(user, recoil + 1, recoil)
	fire_sounds()
	if(!suppressed)
		if(message)
			if(tk_firing(user))
				user.visible_message(
					span_danger("[src] fires itself[pointblank ? " point blank at [pbtarget]!" : "!"]"), \
					null ,\
					span_hear("You hear a gunshot!"), \
					COMBAT_MESSAGE_RANGE
					)

			else if(pointblank)
				user.visible_message(
					span_danger("[user] fires [src] point blank at [pbtarget]!"), \
					span_danger("You fire [src] point blank at [pbtarget]!"), \
					span_hear("You hear a gunshot!"), \
					COMBAT_MESSAGE_RANGE, \
					pbtarget
				)
				to_chat(pbtarget, span_danger("[user] fires [src] point blank at you!"))
				if(pb_knockback > 0 && ismob(pbtarget))
					var/mob/PBT = pbtarget
					var/atom/throw_target = get_edge_target_turf(PBT, user.dir)
					PBT.throw_at(throw_target, pb_knockback, 2)
			else if(!tk_firing(user))
				user.visible_message(
					span_danger("[user] fires [src]!"), \
					span_danger("You fire [src]!"), \
					span_hear("You hear a gunshot!"), \
					COMBAT_MESSAGE_RANGE, \
					user
				)

/obj/item/gun/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in contents)
			//Ignore cells, as we handle them ourselves.
			if(istype(O, /obj/item/stock_parts/cell))
				continue
			O.emp_act(severity)

/obj/item/gun/attack_atom(obj/O, mob/living/user, params)
	if (user.combat_mode || (flags_1 & ISWEAPON))
		..()
		return TRUE
	return FALSE

/obj/item/gun/attack_turf(turf/T, mob/living/user)
	if (user.combat_mode || (flags_1 & ISWEAPON))
		..()
		return TRUE
	return FALSE

/obj/item/gun/attack(mob/M, mob/living/user)
	if (user.combat_mode || (flags_1 & ISWEAPON))
		..()
		return TRUE
	return FALSE

/obj/item/gun/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	// Cancel the attack chain if we fire
	return . || pull_trigger(target, user, click_parameters, GUN_NOT_AIMED)

/obj/item/gun/ranged_attack(atom/target, mob/living/user, params)
	. = ..()
	// Cancel the attack chain if we fire
	return . || pull_trigger(target, user, params, GUN_NOT_AIMED)

/// Represents the user pulling the trigger while aiming at the target
/obj/item/gun/proc/pull_trigger(atom/target, mob/living/user, params = null, aimed = GUN_NOT_AIMED)
	if(QDELETED(target))
		return TRUE
	if(firing_burst)
		return TRUE
	if(target in user.contents) //can't shoot stuff inside us.
		return FALSE
	var/flag = user.Adjacent(target, TRUE)
	if(flag) //It's adjacent, is the user, or is on the user's person
		if (!isturf(target) && (user.combat_mode || (item_flags & ISWEAPON)))
			return FALSE
		if(target == user && !user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH)) //so we can't shoot ourselves (unless mouth selected)
			return FALSE
	add_fingerprint(user)

	// Return true, but act as intercepted so we don't start hitting things
	if (SEND_SIGNAL(src, COMSIG_MOB_PULL_TRIGGER, target, user, params, aimed) & CANCEL_TRIGGER_PULL)
		return TRUE

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return FALSE

	if(flag)
		var/mob/living/living_target = target
		if (!user.client || user.client.prefs.read_player_preference(/datum/preference/choiced/zone_select) == PREFERENCE_BODYZONE_INTENT)
			if(user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH))
				handle_suicide(user, target, params)
				return TRUE
		// On simplified mode, contextually determine if we want to suicide them
		// If the target is ourselves, they are buckled, restrained or lying down then suicide them
		else if(user.is_zone_selected(BODY_ZONE_HEAD) && istype(living_target) && (user == target || HAS_TRAIT(living_target, TRAIT_HANDS_BLOCKED) || living_target.buckled || living_target.IsUnconscious()))
			handle_suicide(user, target, params)
			return TRUE

	// Play the clicking sound if we can't shoot
	if(!can_shoot())
		shoot_with_empty_chamber(user)
		return FALSE

	// Not ready to fire
	if (ranged_cooldown>world.time)
		return FALSE

	//Exclude lasertag guns from the TRAIT_CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
				if(aimed == GUN_AIMED_POINTBLANK)
					to_chat(user, span_userdanger("In a cruel twist of fate you fumble your grip and accidentally shoot yourself in the head!"))
					process_fire(user, user, FALSE, params, BODY_ZONE_HEAD)
					user.dropItemToGround(src, TRUE)
					if(chambered.harmful)
						var/obj/item/organ/brain/target_brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
						target_brain.Remove(user) //Rip you, unlucky
						target_brain.forceMove(get_turf(user))
				else
					to_chat(user, span_userdanger("You shoot yourself in the foot with [src]!"))
					var/shot_leg = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
					process_fire(user, user, FALSE, params, shot_leg)
					user.dropItemToGround(src, TRUE)
				return TRUE

	if(weapon_weight == WEAPON_HEAVY && !is_wielded)
		balloon_alert(user, "You need both hands free to fire [src]!")
		return FALSE

	var/zone_override = null
	if(aimed == GUN_AIMED_POINTBLANK)
		zone_override = BODY_ZONE_HEAD //Shooting while pressed against someone's temple

	process_fire(target, user, TRUE, params, zone_override, aimed)
	return TRUE

/obj/item/gun/can_trigger_gun(mob/living/user)
	. = ..()
	if(!handle_pins(user))
		return FALSE

/obj/item/gun/proc/handle_pins(mob/living/user)
	if(no_pin_required)
		return TRUE
	if(pin)
		if(pin.pin_auth(user) || (pin.obj_flags & EMAGGED))
			return TRUE
		else
			pin.auth_fail(user)
			return FALSE
	else
		balloon_alert(user, "[src] doesn't seem to have a firing pin installed..")
	return FALSE

/obj/item/gun/proc/recharge_newshot()
	return

/// Get the spread that the projectile coming out of the gun will have
/// Multiply by (rand() - 0.5) to determine the angle of the bullet
/obj/item/gun/proc/get_bullet_spread(mob/living/user, atom/target)
	var/min_gun_sprd = 0

	if(wild_spread)
		if (is_wielded)
			//If a gun has WILD SPREAD get the minimum by multiplying spread by its WILD FACTOR
			min_gun_sprd = round(spread * wild_factor, 0.5)
		else
			//Do the same for the gun's unwielded spread
			min_gun_sprd = round(spread_unwielded * wild_factor, 0.5)
	var/bonus_spread = user.get_weapon_inaccuracy_modifier(target, src)
	if(!is_wielded && requires_wielding)
		bonus_spread += spread_unwielded
	var/sprd = 0
	sprd = max(min_gun_sprd, abs(sprd)) * SIGN(sprd)
	sprd += (1 - get_integrity_ratio()) * damage_variance
	return sprd

/obj/item/gun/proc/process_burst(mob/living/user, atom/target, message = TRUE, params=null, zone_override = "", iteration = 0)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!user || !firing_burst)
		firing_burst = FALSE
		return FALSE
	if(!issilicon(user))
		if(iteration > 1 && !(user.is_holding(src))) //for burst firing
			firing_burst = FALSE
			return FALSE
	if (!fire_shot_at(user, target, message, params, zone_override, FALSE) || iteration >= burst_size)
		firing_burst = FALSE
	return TRUE

/obj/item/gun/proc/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", aimed = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
		if(chambered.harmful) // Is the bullet chambered harmful?
			to_chat(user, span_notice(" [src] is lethally chambered! You don't want to risk harming anyone..."))
			return

	if(burst_size > 1)
		firing_burst = TRUE
		for(var/i = 1 to burst_size)
			addtimer(CALLBACK(src, PROC_REF(process_burst), user, target, message, params, zone_override, i), fire_delay * (i - 1))
	else
		fire_shot_at(user, target, message, params, zone_override, aimed)

	if(user)
		user.update_held_items()
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	return TRUE

/obj/item/gun/proc/fire_shot_at(mob/living/user, atom/target, message = TRUE, params=null, zone_override = "", aimed = FALSE)
	// If we have nothing chambered, fire an empty shot
	if(!chambered || !chambered.BB)
		shoot_with_empty_chamber(user)
		firing_burst = FALSE
		return FALSE
	var/taken_damage = chambered.gun_damage
	var/result = before_firing(target, user, aimed)
	if (result & GUN_HIT_SELF)
		target = user
	if(!chambered.fire_casing(target, user, params, get_bullet_spread(user, target), suppressed, zone_override, src))
		shoot_with_empty_chamber(user)
		firing_burst = FALSE
		return FALSE
	// Add the cooldown after firing
	if(fire_rate)
		ranged_cooldown = world.time + 10 / fire_rate
		user.client?.give_cooldown_cursor(10 / fire_rate)
	else
		ranged_cooldown = world.time + CLICK_CD_RANGE
		user.client?.give_cooldown_cursor(CLICK_CD_RANGE)
	// Take damage if necessary
	if (taken_damage)
		take_damage(taken_damage, BRUTE, MELEE, sound_effect = FALSE, armour_penetration = 100)
	after_live_shot_fired(user, get_dist(user, target) <= 1, target, message)
	on_chamber_fired()
	update_appearance()
	return TRUE

/obj/item/gun/update_overlays()
	. = ..()

	if(bayonet)
		var/mutable_appearance/knife_overlay
		var/state = "bayonet" //Generic state.
		if(bayonet.icon_state in icon_states('icons/obj/guns/bayonets.dmi')) //Snowflake state?
			state = bayonet.icon_state
		var/icon/bayonet_icons = 'icons/obj/guns/bayonets.dmi'
		knife_overlay = mutable_appearance(bayonet_icons, state)
		knife_overlay.pixel_x = knife_x_offset
		knife_overlay.pixel_y = knife_y_offset
		. += knife_overlay

	if (atom_integrity < integrity_failure * max_integrity)
		var/mutable_appearance/damage_overlay = mutable_appearance('icons/effects/item_damage.dmi', "itemdamaged")
		damage_overlay.blend_mode = BLEND_MULTIPLY
		. += damage_overlay
		appearance_flags |= KEEP_TOGETHER
	else
		appearance_flags &= ~KEEP_TOGETHER

/obj/item/gun/attack(mob/M, mob/living/user)
	if(user.combat_mode) //Flogging
		if(bayonet)
			M.attackby(bayonet, user)
			return
		else
			return ..()
	return

/obj/item/gun/attack_atom(obj/O, mob/living/user, params)
	if(user.combat_mode)
		if(bayonet)
			O.attackby(bayonet, user)
			return
	return ..()

/obj/item/gun/attackby(obj/item/I, mob/living/user, params)
	if(user.combat_mode)
		return ..()

	else if(istype(I, /obj/item/knife))
		var/obj/item/knife/K = I
		if(!can_bayonet || !K.bayonet || bayonet) //ensure the gun has an attachment point available, and that the knife is compatible with it.
			return ..()
		if(!user.transferItemToLoc(I, src))
			return
		balloon_alert(user, "You attach [K] to [src].")
		bayonet = K
		update_appearance()
		// Become a weapon when we gain a bayonet
		item_flags |= ISWEAPON
	else
		return ..()

/obj/item/gun/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	if(bayonet && can_bayonet) //if it has a bayonet, and the bayonet can be removed
		I.play_tool_sound(src)
		balloon_alert(user, "You unfix [bayonet] from [src].")
		bayonet.forceMove(drop_location())

		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(bayonet)
		return TOOL_ACT_TOOLTYPE_SUCCESS

	else if(pin && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [pin] from [src] with [I]."),
		span_notice("You attempt to remove [pin] from [src]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, volume = 50))
			if(!pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[pin] was pried out of [src] by [user], destroying the pin in the process."),
								span_warning("You pried [pin] out with [I], destroying the pin in the process."), null, 3)
			QDEL_NULL(pin)
			return TOOL_ACT_TOOLTYPE_SUCCESS


/obj/item/gun/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(pin && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [pin] from [src] with [I]."),
		span_notice("You attempt to remove [pin] from [src]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, 5, volume = 50))
			if(!pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[pin] was spliced out of [src] by [user], melting part of the pin in the process."),
								span_warning("You spliced [pin] out of [src] with [I], melting part of the pin in the process."), null, 3)
			QDEL_NULL(pin)
			return TRUE

/obj/item/gun/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(pin && user.is_holding(src))
		user.visible_message(span_warning("[user] attempts to remove [pin] from [src] with [I]."),
		span_notice("You attempt to remove [pin] from [src]. (It will take [DisplayTimeText(FIRING_PIN_REMOVAL_DELAY)].)"), null, 3)
		if(I.use_tool(src, user, FIRING_PIN_REMOVAL_DELAY, volume = 50))
			if(!pin) //check to see if the pin is still there, or we can spam messages by clicking multiple times during the tool delay
				return
			user.visible_message(span_notice("[pin] was ripped out of [src] by [user], mangling the pin in the process."),
								span_warning("You ripped [pin] out of [src] with [I], mangling the pin in the process."), null, 3)
			QDEL_NULL(pin)
			return TRUE

/obj/item/gun/pickup(mob/user)
	..()
	if(azoom)
		azoom.Grant(user)

/obj/item/gun/dropped(mob/user)
	..()
	if(azoom)
		azoom.Remove(user)
	if(zoomed)
		zoom(user, user.dir)

/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params, bypass_timer)
	if(!ishuman(user) || !ishuman(target))
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM)) //This prevents multiplying projectile damage without shooting yourself.
		return

	if (!can_trigger_gun(user))
		return

	if(user == target)
		target.visible_message(span_warning("[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger..."), \
			span_userdanger("You stick [src] in your mouth, ready to pull the trigger..."))
	else
		target.visible_message(span_warning("[user] points [src] at [target]'s head, ready to pull the trigger..."), \
			span_userdanger("[user] points [src] at your head, ready to pull the trigger..."))

	if(!bypass_timer && (!do_after(user, 12 SECONDS, target) || !user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH)))
		if(user)
			if(user == target)
				user.visible_message(span_notice("[user] decided not to shoot."))
			else if(target && target.Adjacent(user))
				target.visible_message(span_notice("[user] has decided to spare [target]."), span_notice("[user] has decided to spare your life!"))
		return

	if (!can_trigger_gun(user))
		return

	target.visible_message(span_warning("[user] pulls the trigger!"), span_userdanger("[(user == target) ? "You pull" : "[user] pulls"] the trigger!"))

	if(chambered?.BB)
		chambered.BB.damage *= 5

	var/fired = process_fire(target, user, TRUE, params, BODY_ZONE_HEAD)
	if(!fired && chambered?.BB)
		chambered.BB.damage /= 5

/obj/item/gun/proc/unlock() //used in summon guns and as a convience for admins
	if(pin)
		qdel(pin)
	pin = new /obj/item/firing_pin

//Happens before the actual projectile creation
/obj/item/gun/proc/before_firing(atom/target, mob/user, aimed)
	if(aimed == GUN_AIMED && chambered?.BB)
		// Faster bullets to account for the fact you've given the target a big warning they're about to be shot
		chambered.BB.speed = initial(chambered.BB.speed) * 0.5
		chambered.BB.damage = initial(chambered.BB.damage) * 2
	if(aimed == GUN_AIMED_POINTBLANK)
		// Execution kill
		chambered.BB.speed = initial(chambered.BB.speed) * 0.25
		chambered.BB.damage = initial(chambered.BB.damage) * 6
	return SEND_SIGNAL(user, COMSIG_MOB_BEFORE_FIRE_GUN, src, target, aimed)

/obj/item/gun/atom_break(damage_flag)
	update_appearance()
	if (ismob(loc))
		loc.balloon_alert(loc, "[src] breaks!")
	return ..()

/obj/item/gun/atom_fix()
	update_appearance()
	return ..()

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	var/obj/item/gun/gun = null

/datum/action/toggle_scope_zoom/on_activate(mob/user, atom/target)
	gun.zoom(owner, owner.dir)

/datum/action/toggle_scope_zoom/is_available()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, owner.dir, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, L.dir, FALSE)
	..()

/obj/item/gun/proc/rotate(atom/thing, old_dir, new_dir)
	SIGNAL_HANDLER

	if(ismob(thing))
		var/mob/lad = thing
		lad.client.view_size.zoomOut(zoom_out_amt, zoom_amt, new_dir)

/obj/item/gun/proc/zoom(mob/living/user, direc, forced_zoom)
	if(!user || !user.client)
		return

	if(isnull(forced_zoom))
		zoomed = !zoomed
	else
		zoomed = forced_zoom

	if(zoomed)
		RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, PROC_REF(rotate))
		user.client.view_size.zoomOut(zoom_out_amt, zoom_amt, direc)
	else
		UnregisterSignal(user, COMSIG_ATOM_DIR_CHANGE)
		user.client.view_size.zoomIn()
	return zoomed

//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src

/obj/item/gun/try_ducttape(mob/living/user, obj/item/stack/sticky_tape/duct/tape)
	balloon_alert(user, "Tape would make it too flimsy to fire!")
	return FALSE

#undef FIRING_PIN_REMOVAL_DELAY
