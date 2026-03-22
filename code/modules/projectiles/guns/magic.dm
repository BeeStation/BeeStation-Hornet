/obj/item/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofnothing"
	inhand_icon_state = "staff"
	//WE ALREADY HAVE LEFTHAND AND RIGHTHAND FILES HERE
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	fire_sound = 'sound/weapons/emitter.ogg'
	flags_1 =  CONDUCT_1
	w_class = WEIGHT_CLASS_BULKY
	var/antimagic_flags = MAGIC_RESISTANCE
	var/max_charges = 6
	var/charges = 0
	var/recharge_rate = 8
	var/charge_timer = 0
	var/can_charge = TRUE
	var/ammo_type
	var/no_den_usage
	clumsy_check = 0
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses magic instead
	pin = /obj/item/firing_pin/magic
	no_pin_required = TRUE
	requires_wielding = FALSE	//Magic has no recoil, just hold with 1 hand
	equip_time = 0
	has_weapon_slowdown = FALSE

/obj/item/gun/magic/fire_sounds()
	var/frequency_to_use = sin((90/max_charges) * charges)
	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound, frequency = frequency_to_use)

/obj/item/gun/magic/can_trigger_gun(mob/living/user)
	if(no_den_usage)
		var/area/A = get_area(user)
		if(istype(A, /area/wizard_station))
			add_fingerprint(user)
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to use [src]."))
			return FALSE
		else
			no_den_usage = 0
	if(!user.can_cast_magic(antimagic_flags))
		add_fingerprint(user)
		to_chat(user, span_warning("Something is interfering with [src]."))
		return FALSE
	return ..()

/obj/item/gun/magic/can_shoot()
	return charges && ..()

/obj/item/gun/magic/recharge_newshot()
	if (charges && chambered && !chambered.BB)
		chambered.newshot()

/obj/item/gun/magic/on_chamber_fired()
	// Drain the charge and recharge
	charges--
	recharge_newshot()

/obj/item/gun/magic/Initialize(mapload)
	. = ..()
	charges = max_charges
	if(ammo_type)
		chambered = new ammo_type(src)
	if(can_charge)
		START_PROCESSING(SSobj, src)


/obj/item/gun/magic/Destroy()
	if(can_charge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/magic/process(delta_time)
	if(!can_charge)
		STOP_PROCESSING(SSobj, src)
	if (charges >= max_charges)
		charge_timer = 0
		return
	charge_timer += delta_time
	if(charge_timer < recharge_rate)
		return 0
	charge_timer = 0
	charges++
	if(charges == 1)
		recharge_newshot()
		update_icon()
	return 1

/obj/item/gun/magic/update_icon()
	return

/obj/item/gun/magic/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("The [name] whizzles quietly."))

/obj/item/gun/magic/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is twisting [src] above [user.p_their()] head, releasing a magical blast! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, fire_sound, 50, 1, -1)
	return FIRELOSS

/obj/item/gun/magic/vv_edit_var(var_name, var_value)
	. = ..()
	switch (var_name)
		if(NAMEOF(src, charges))
			recharge_newshot()
