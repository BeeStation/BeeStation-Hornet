// Flags for [/obj/item/grenade/var/dud_flags]
/// The grenade cannot detonate at all. It is innately nonfunctional.
#define GRENADE_DUD (1<<0)
/// The grenade has been used and as such cannot detonate.
#define GRENADE_USED (1<<1)

/obj/item/grenade
	name = "grenade"
	desc = "It has an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	worn_icon_state = "grenade"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1 | PREVENT_CONTENTS_EXPLOSION_1 // We detonate upon being exploded.
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	/// Bitfields which prevent the grenade from detonating if set. Includes ([GRENADE_DUD]|[GRENADE_USED])
	var/dud_flags = NONE
	var/active = 0
	var/det_time = 50
	var/display_timer = 1
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE
	var/sticky = FALSE
	// I moved the explosion vars and behavior to base grenades because we want all grenades to call [/obj/item/grenade/proc/prime] so we can send COMSIG_GRENADE_PRIME
	///how big of a heavy explosion radius on prime
	var/ex_heavy = 0
	///how big of a light explosion radius on prime
	var/ex_light = 0
	///how big of a flame explosion radius on prime
	var/ex_flame = 0

	// dealing with creating a [/datum/component/pellet_cloud] on prime
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	var/shrapnel_initialized

/obj/item/grenade/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] primes [src], then eats it! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	preprime(user, det_time)
	user.transferItemToLoc(src, user, TRUE)//>eat a grenade set to 5 seconds >rush captain
	sleep(det_time)//so you dont die instantly
	return dud_flags ? SHAME : BRUTELOSS

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/proc/botch_check(mob/living/carbon/human/user)
	var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE))
		if(prob(50))
			to_chat(user, span_warning("Huh? How does this thing work?"))
			preprime(user, 5, FALSE)
			return TRUE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, span_warning("You pull the pin on [src]. Attached to it is a pink ribbon that says, \"[span_clowntext("HONK")]\""))
		preprime(user, 5, FALSE)
		return TRUE
	else if(sticky && prob(50)) // to add risk to sticky tape grenade cheese, no return cause we still prime as normal after
		to_chat(user, span_warning("What the... [src] is stuck to your hand!"))
		ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)


/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 1)
			to_chat(user, "The timer is set to [DisplayTimeText(det_time)].")
		else
			. += "\The [src] is set for instant detonation."
	if (dud_flags & GRENADE_USED)
		. += span_warning("It looks like [p_theyve()] already been used.")


/obj/item/grenade/attack_self(mob/user)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		to_chat(user, span_notice("You try prying [src] off your hand..."))
		if(do_after(user, 70, target=src))
			to_chat(user, span_notice("You manage to remove [src] from your hand."))
			REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)

		return

	if (active)
		return
	if(!botch_check(user)) // if they botch the prime, it'll be handled in botch_check
		preprime(user)

/obj/item/grenade/proc/log_grenade(mob/user, turf/T)
	log_bomber(user, "has primed a", src, "for detonation", message_admins = !dud_flags)
	log_combat(user, src, "primed a", src, "for detonation")

/obj/item/grenade/proc/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/T = get_turf(src)
	log_grenade(user, T) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [DisplayTimeText(det_time)]!"))
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_radius)
	playsound(src, 'sound/weapons/armbomb.ogg', volume, 1)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(prime)), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/proc/prime(mob/living/lanced_by)
	if (dud_flags)
		active = FALSE
		update_icon()
		return FALSE

	dud_flags |= GRENADE_USED // Don't detonate if we have already detonated.
	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized) // add a second check for adding the component in case whatever triggered the grenade went straight to prime (badminnery for example)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_PRIME, lanced_by)
	if(ex_heavy || ex_light || ex_flame)
		explosion(loc, 0, ex_heavy, ex_light, flame_range = ex_flame)
	return TRUE

/obj/item/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/grenade/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		switch(det_time)
			if(1)
				det_time = 30
				to_chat(user, span_notice("You set the [name] for 3 second detonation time."))
			if(30)
				det_time = 50
				to_chat(user, span_notice("You set the [name] for 5 second detonation time."))
			if(50)
				det_time = 1
				to_chat(user, span_notice("You set the [name] for instant detonation."))
		add_fingerprint(user)
	else
		return ..()

/obj/item/grenade/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message(span_danger("[attack_text] hits [owner]'s [src], setting it off! What a shot!"))
		var/turf/T = get_turf(src)
		log_game("A projectile ([hitby]) detonated a grenade held by [key_name(owner)] at [COORD(T)]")
		message_admins("A projectile ([hitby]) detonated a grenade held by [key_name_admin(owner)] at [ADMIN_COORDJMP(T)]")
		INVOKE_ASYNC(src, PROC_REF(prime))
		return TRUE //It hit the grenade, not them

/obj/item/grenade/afterattack(atom/target, mob/user)
	. = ..()
	if(active)
		user.throw_item(target)
