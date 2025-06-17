#define DUEL_IDLE 1
#define DUEL_PREPARATION 2
#define DUEL_READY 3
#define DUEL_COUNTDOWN 4
#define DUEL_FIRING 5

//paper rock scissors
#define DUEL_SETTING_A "wide"
#define DUEL_SETTING_B "cone"
#define DUEL_SETTING_C "pinpoint"

/datum/duel
	var/obj/item/gun/energy/dueling/gun_A
	var/obj/item/gun/energy/dueling/gun_B
	var/state = DUEL_IDLE
	var/required_distance = 5
	var/list/confirmations = list()
	var/list/fired = list()
	var/countdown_length = 10
	var/countdown_step = 0

/datum/duel/proc/try_begin()
	//Check if both guns are held and if so begin.
	var/mob/living/A = get_duelist(gun_A)
	var/mob/living/B = get_duelist(gun_B)
	if(!A || !B)
		message_duelists(span_warning("To begin the duel, both participants need to be holding paired dueling pistols."))
		return
	begin()

/datum/duel/proc/begin()
	state = DUEL_PREPARATION
	confirmations.Cut()
	fired.Cut()
	countdown_step = countdown_length

	message_duelists(span_notice("Set your gun setting and move [required_distance] steps away from your opponent."))

	START_PROCESSING(SSobj,src)

/datum/duel/proc/get_duelist(obj/gun)
	var/mob/living/G = gun.loc
	if(!istype(G) || !G.is_holding(gun))
		return null
	return G

/datum/duel/proc/message_duelists(message)
	var/mob/living/LA = get_duelist(gun_A)
	if(LA)
		to_chat(LA,message)
	var/mob/living/LB = get_duelist(gun_B)
	if(LB)
		to_chat(LB,message)

/datum/duel/proc/other_gun(obj/item/gun/energy/dueling/G)
	return G == gun_A ? gun_B : gun_A

/datum/duel/proc/end()
	message_duelists(span_notice("Duel finished. Re-engaging safety."))
	STOP_PROCESSING(SSobj,src)
	state = DUEL_IDLE

/datum/duel/process()
	switch(state)
		if(DUEL_PREPARATION)
			if(check_positioning())
				confirm_positioning()
			else if (!get_duelist(gun_A) && !get_duelist(gun_B))
				end()
		if(DUEL_READY)
			if(!check_positioning())
				back_to_prep()
			else if(confirmations.len == 2)
				confirm_ready()
		if(DUEL_COUNTDOWN)
			if(!check_positioning())
				back_to_prep()
			else
				countdown_step()
		if(DUEL_FIRING)
			if(check_fired())
				end()


/datum/duel/proc/back_to_prep()
	message_duelists(span_notice("Positions invalid. Please move to valid positions [required_distance] steps aways from each other to continue."))
	state = DUEL_PREPARATION
	confirmations.Cut()
	countdown_step = countdown_length

/datum/duel/proc/confirm_positioning()
	message_duelists(span_notice("Position confirmed. Confirm readiness by pulling the trigger once."))
	state = DUEL_READY

/datum/duel/proc/confirm_ready()
	message_duelists(span_notice("Readiness confirmed. Starting countdown. Commence firing at zero mark."))
	state = DUEL_COUNTDOWN

/datum/duel/proc/countdown_step()
	countdown_step--
	if(countdown_step == 0)
		state = DUEL_FIRING
		message_duelists(span_userdanger("Fire!"))
	else
		message_duelists(span_userdanger("[countdown_step]!"))

/datum/duel/proc/check_fired()
	if(fired.len == 2)
		return TRUE
	//Let's say if gun was dropped/stowed the user is finished
	if(!get_duelist(gun_A))
		return TRUE
	if(!get_duelist(gun_B))
		return TRUE
	return FALSE

/datum/duel/proc/check_positioning()
	var/mob/living/A = get_duelist(gun_A)
	var/mob/living/B = get_duelist(gun_B)
	if(!A || !B)
		return FALSE
	if(!isturf(A.loc) || !isturf(B.loc))
		return FALSE
	if(get_dist(A,B) != required_distance)
		return FALSE
	for(var/turf/T in getline(get_turf(A),get_turf(B)))
		if(T.is_blocked_turf(TRUE))
			return FALSE
	return TRUE

/obj/item/gun/energy/dueling
	name = "dueling pistol"
	desc = "High-tech dueling pistol. Launches chaff and projectile according to preset settings."
	icon_state = "dueling_pistol"
	item_state = "gun"
	ammo_x_offset = 2
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = list(/obj/item/ammo_casing/energy/duel)
	automatic_charge_overlays = FALSE
	var/unlocked = FALSE
	var/setting = DUEL_SETTING_A
	var/datum/duel/duel

/obj/item/gun/energy/dueling/proc/setting_iconstate()
	switch(setting)
		if(DUEL_SETTING_A)
			return "duel_red"
		if(DUEL_SETTING_B)
			return "duel_green"
		if(DUEL_SETTING_C)
			return "duel_blue"
	return "duel_red"

/obj/item/gun/energy/dueling/attack_self(mob/living/user)
	. = ..()
	if(duel.state == DUEL_IDLE)
		duel.try_begin()
	else
		toggle_setting(user)

/obj/item/gun/energy/dueling/proc/toggle_setting(mob/living/user)
	switch(setting)
		if(DUEL_SETTING_A)
			setting = DUEL_SETTING_B
		if(DUEL_SETTING_B)
			setting = DUEL_SETTING_C
		if(DUEL_SETTING_C)
			setting = DUEL_SETTING_A
	to_chat(user,span_notice("You switch [src] setting to [setting] mode."))
	update_icon()

/obj/item/gun/energy/dueling/update_overlays()
	. = ..()
	. += setting_iconstate()
	if (emissive_charge)
		. += emissive_appearance(icon, setting_iconstate(), layer, alpha = 80)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/item/gun/energy/dueling/Destroy()
	. = ..()
	if(duel?.gun_A == src)
		duel.gun_A = null
	if(duel?.gun_B == src)
		duel.gun_B = null
	duel = null

/obj/item/gun/energy/dueling/can_trigger_gun(mob/living/user)
	. = ..()
	switch(duel.state)
		if(DUEL_FIRING)
			return . && !duel.fired[src]
		if(DUEL_READY)
			return .
		else
			to_chat(user,span_warning("[src] is locked. Wait for FIRE signal before shooting."))
			return FALSE

/obj/item/gun/energy/dueling/proc/is_duelist(mob/living/L)
	if(!istype(L))
		return FALSE
	if(!L.is_holding(duel.other_gun(src)))
		return FALSE
	return TRUE

/obj/item/gun/energy/dueling/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	if(duel.state == DUEL_READY)
		duel.confirmations[src] = TRUE
		to_chat(user,span_notice("You confirm your readiness."))
		return FALSE
	else if(!is_duelist(target)) //I kinda want to leave this out just to see someone shoot a bystander or missing.
		to_chat(user,span_warning("[src] safety system prevents shooting anyone but your designated opponent."))
		return FALSE
	else
		duel.fired[src] = TRUE
		return ..()

/obj/item/gun/energy/dueling/before_firing(target,user)
	var/obj/item/ammo_casing/energy/duel/D = chambered
	D.setting = setting

/obj/effect/temp_visual/dueling_chaff
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	duration = 30
	var/setting

/obj/effect/temp_visual/dueling_chaff/update_icon()
	. = ..()
	switch(setting)
		if(DUEL_SETTING_A)
			color = "red"
		if(DUEL_SETTING_B)
			color = "green"
		if(DUEL_SETTING_C)
			color = "blue"

//Casing

/obj/item/ammo_casing/energy/duel
	e_cost = 0
	projectile_type = /obj/projectile/energy/duel
	var/setting

/obj/item/ammo_casing/energy/duel/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	. = ..()
	var/obj/projectile/energy/duel/D = BB
	D.setting = setting
	D.update_icon()

/obj/item/ammo_casing/energy/duel/fire_casing(atom/target, mob/living/user, params, spread, quiet, zone_override, atom/fired_from)
	. = ..()
	var/obj/effect/temp_visual/dueling_chaff/C = new(get_turf(user))
	C.setting = setting
	C.update_icon()

//Projectile

/obj/projectile/energy/duel
	name = "dueling beam"
	icon_state = "declone"
	reflectable = FALSE
	homing = TRUE
	var/setting

/obj/projectile/energy/duel/update_icon()
	. = ..()
	switch(setting)
		if(DUEL_SETTING_A)
			color = "red"
		if(DUEL_SETTING_B)
			color = "green"
		if(DUEL_SETTING_C)
			color = "blue"

/obj/projectile/energy/duel/on_hit(atom/target, blocked)
	. = ..()
	var/turf/T = get_turf(target)
	var/obj/effect/temp_visual/dueling_chaff/C = locate() in T
	if(C)
		var/counter_setting
		switch(setting)
			if(DUEL_SETTING_A)
				counter_setting = DUEL_SETTING_B
			if(DUEL_SETTING_B)
				counter_setting = DUEL_SETTING_C
			if(DUEL_SETTING_C)
				counter_setting = DUEL_SETTING_A
		if(C.setting == counter_setting)
			return BULLET_ACT_BLOCK

	var/mob/living/L = target
	if(!istype(target))
		return BULLET_ACT_BLOCK

	var/obj/item/bodypart/B = L.get_bodypart(BODY_ZONE_HEAD)
	B.dismember()
	qdel(B)

//Storage case.
/obj/item/storage/lockbox/dueling
	name = "dueling pistol case"
	desc = "Let's solve this like gentlespacemen."
	icon_state = "medalbox+l"
	item_state = "medalbox+l"
	base_icon_state = "medalbox"
	w_class = WEIGHT_CLASS_LARGE
	req_access = list(ACCESS_CAPTAIN)

/obj/item/storage/lockbox/dueling/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_slots = 2
	atom_storage.set_holdable(list(/obj/item/gun/energy/dueling))

/obj/item/storage/lockbox/dueling/PopulateContents()
	. = ..()
	var/obj/item/gun/energy/dueling/gun_A = new(src)
	var/obj/item/gun/energy/dueling/gun_B = new(src)
	var/datum/duel/D = new
	gun_A.duel = D
	gun_B.duel = D
	D.gun_A = gun_A
	D.gun_B = gun_B

#undef DUEL_IDLE
#undef DUEL_PREPARATION
#undef DUEL_READY
#undef DUEL_COUNTDOWN
#undef DUEL_FIRING
#undef DUEL_SETTING_A
#undef DUEL_SETTING_B
#undef DUEL_SETTING_C
