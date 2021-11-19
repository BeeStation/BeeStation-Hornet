#define MODE_STUN "nonlethal"
#define MODE_LETHAL "lethal"
#define WEAK_HIT 1
#define NORMAL_HIT 2
#define STRONG_HIT 3
GLOBAL_LIST_EMPTY(baton_list)

/obj/item/melee/lawbaton
	name = "L.A.W. Baton"
	desc = "The Thinktronic Systems LTD smart Law enforcement And Wildlife control baton, or LAW baton for short. A laser-based weapon designed to both nonlethally bring down criminals and cut down wildlife pests with ease."
	icon_state = "empty"
	item_state = "empty"
	icon = 'icons/obj/lawbaton.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/lawbaton_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/lawbaton_righthand.dmi'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	force = 2 //when unpowered and without a head, it's little more than a plastic stick
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/modspace = 100
	var/on = FALSE
	var/overcharged = FALSE
	var/mode = MODE_STUN
	var/smartlethal = TRUE
	var/authenticated = FALSE
	var/username //used to store used IDs
	var/mob/living/registered //used to store user ids as well
	var/list/stunsounds = list('sound/weapons/egloves.ogg', 'sound/weapons/ionrifle.ogg', 'sound/weapons/zapbang.ogg')
	var/list/lethalsounds = list('sound/weapons/plasma_cutter.ogg', 'sound/weapons/sear.ogg', 'sound/weapons/resonator_blast.ogg')
	var/obj/item/batonmodule/head/head //the baton's head. This determines a baton's main statblock
	var/obj/item/stock_parts/cell/cell //the baton's power cell. This can't be removed
	var/obj/item/stock_parts/capacitor/capacitor //the baton's capacitor. this determines the baton's stun damage
	var/obj/item/stock_parts/micro_laser/laser //the baton's laser. this determines the baton's lethal damage
	var/list/attachments = list() //a list of all attachments a baton has
	var/preloadcapacitor = /obj/item/stock_parts/capacitor //for upgraded batons
	var/preloadlaser = /obj/item/stock_parts/micro_laser
	var/preloadhead = /obj/item/batonmodule/head //all starting attachments, including the head, go here

//attack and combat procs. If you're making balance changes, make them here

/obj/item/melee/lawbaton/proc/overcharge(mob/living/user, var/noisy = TRUE, var/time) //set time to 0 to overcharge next attack. if you set a time, it will overcharge the next attack in that amount of deciseconds
	if(overcharged)
		if(SEND_SIGNAL(src, COMSIG_BATON_OVERCHARGE_PLUS, user) & COMSIG_BATON_NOOVERCHARGEMESSAGE)
			return 
		else 
			balloon_alert(user, "Overcharge failed.")
			to_chat(user, "<span class='notice'>Capacitors are running over full capacity. Aborting overcharge.</span>")
	if(noisy)
		playsound(src, 'sound/mecha/mech_shield_raise.ogg', 50, TRUE)
	balloon_alert(user, "Capacitors overclocked.")
	to_chat(user, "<span class='notice'>Capacitors have been overclocked. Thinktronics Systems LTD is not liable for any damages caused by this function.</span>")
	overcharged = TRUE
	SEND_SIGNAL(src, COMSIG_BATON_OVERCHARGING, user)
	if(time)
		addtimer(CALLBACK(src, .proc/discharge, user), time, TIMER_UNIQUE|TIMER_OVERRIDE)//used by attachments to give the baton a temporary buff. This timer is unique so your overcharge isnt turned off by your last overcharge decaying

/obj/item/melee/lawbaton/proc/discharge(mob/living/user)
	if(!overcharged)
		return
	else
		balloon_alert(user, "Capacitors discharged.")
		to_chat(user, "<span class='notice'>Capacitors have been discharged to avoid overheating.</span>")
		overcharged = FALSE
		playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE)

/obj/item/melee/lawbaton/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	if(on && .) 	
		SEND_SIGNAL(src, COMSIG_BATON_BLOCK, owner, hitby, attack_text, damage, attack_type)
		return TRUE
	return FALSE

/obj/item/melee/lawbaton/attack(mob/living/M, mob/living/user)
	if(on)
		if(!authenticated)
			to_chat(user, "<span class='notice'>Please register your Thinktronics Systems LTD account to make use of this baton. Thank you.</span>")
			playsound(M, 'sound/machines/buzz-sigh.ogg', 50, 0)
			togglepower()
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.check_shields(src, force, "[user]'s [name]", MELEE_ATTACK))
				if(!(SEND_SIGNAL(src, COMSIG_BATON_BLOCKED, M, user) & COMSIG_BATON_UNBLOCKABLE))
					return FALSE
			if(check_martial_counter(H, user))
				if(!(SEND_SIGNAL(src, COMSIG_BATON_BLOCKED, M, user) & COMSIG_BATON_UNBLOCKABLE))
					return FALSE 
		if(mode == MODE_LETHAL && HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		if(!(SEND_SIGNAL(src, COMSIG_BATON_ATTACK, M, user) & COMSIG_BATON_NOATTACK))
			handlehit(M, user)
			return
	else if(user.a_intent == INTENT_HARM)
		return ..()
	M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
				"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
				

/obj/item/melee/lawbaton/proc/handlehit(mob/living/M, mob/living/user, var/hitmode, var/bodypart = BODY_ZONE_CHEST)
	var/obj/item/bodypart/affecting =  M.get_bodypart(bodypart)
	if(!isliving(M) || !isliving(user))
		return
	if(user)
		affecting = M.get_bodypart(ran_zone(user.zone_selected))
	var/penetrateclothes = FALSE
	if(armour_penetration >= 15)
		penetrateclothes = TRUE
	var/final_mode = head.default_mode
	if(hitmode)
		final_mode = hitmode 
	if(!on || !authenticated)
		return //sanity check
	if(!cell.charge)
		balloon_alert(user, "ERR: Out of power!")
		togglepower()
		return
	if(!componentcheck())
		togglepower()
		return
	switch(mode)
		if(MODE_STUN)
			if(!stuncheck(M, user))
				balloon_alert(user, "Target is not susceptible to nonlethal apprehension.")
				to_chat(user, "<span class='notice'>Target is not susceptible to nonlethal apprehension. Aborting attack to preserve battery life.</span>")
				playsound(M, 'sound/machines/buzz-sigh.ogg', 50, 0)
				SEND_SIGNAL(src, COMSIG_BATON_FAILED_STUNCHECK, M, user)
				return
		if(MODE_LETHAL)
			if(stuncheck(M, user) && smartlethal)
				balloon_alert(user, "Target is susceptible to nonlethal apprehension.")
				to_chat(user, "<span class='notice'>Target is susceptible to nonlethal apprehension. You are not authorized to escalate to lethal measures at this time.</span>")
				playsound(M, 'sound/machines/buzz-sigh.ogg', 50, 0)
				SEND_SIGNAL(src, COMSIG_BATON_FAILED_STUNCHECK, M, user)
				return
	if(overcharged)
		final_mode = min(final_mode + 1, STRONG_HIT)
		SEND_SIGNAL(src, COMSIG_BATON_OVERCHARGE, M, user)
		overcharged = FALSE
	if(cell.charge < 25 * final_mode)
		final_mode = min(WEAK_HIT, final_mode - round((25 * final_mode) - cell.charge)/25)
		balloon_alert(user, "Insufficient charge. Efficacy reduced.")
	switch(mode)
		if(MODE_STUN)
			if(iscyborg(M))
				M.Stun((1 + capacitor.rating) * final_mode) //doesn't last very long, but it's *something*
				playsound(src, stunsounds[final_mode], 50, TRUE)
				if(user)
					M.visible_message("<span class='userdanger'>[user] shorts out your circuits with the [src]!</span>", "<span class='warning'>[user] stuns [M] with the [src]!</span>")
					user.do_attack_animation(M)
					M.lastattacker = user.real_name
					M.lastattackerckey = user.ckey
					log_combat(user, M, "stunned")
				else 
					M.visible_message("<span class='userdanger'>[src] shorts out your circuits!</span>", "<span class='warning'>The [src] stuns [M]!</span>")
				return
			var/damage = ((6 * final_mode) * (capacitor.rating + 1))
			playsound(src, stunsounds[final_mode], 50, TRUE)
			var/armor_block = M.run_armor_check(affecting, "stamina", armour_penetration = armour_penetration)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!H.can_inject(penetrate_thick = penetrateclothes)) 
					armor_block += 25 //your average security member has about 65 chest stamina armor including this bonus. An assistant in a firesuit carries 35, with slowdown. without security gear or hardsuits, the most a tider can feasibly get is 50ish- still better than lethals
			M.apply_damage(damage, STAMINA, affecting, armor_block)
		if(MODE_LETHAL)
			var/damage = (8 + (2 * final_mode) * capacitor.rating)
			playsound(src, lethalsounds[final_mode], 50, TRUE)
			var/armor_block = M.run_armor_check(affecting, "melee", armour_penetration = armour_penetration)
			M.apply_damage(damage, BURN, affecting, armor_block)
			add_mob_blood(M)
	if(user)
		var/attack_message = "electrocuted"
		if(mode == MODE_LETHAL)
			attack_message = "burnt"
		user.do_attack_animation(M)
		M.lastattacker = user.real_name
		M.lastattackerckey = user.ckey
		M.visible_message("<span class='danger'>[user] has [attack_message] [M] with [src]!</span>", \
								"<span class='userdanger'>[user] has [attack_message] you with [src]!</span>")
		log_combat(user, M, "attacked [mode]ly")
		if(final_mode == STRONG_HIT)
			user.changeNext_move(16)
			to_chat(user, "<span class='warning'>The baton bucks in your grip!</span>")
	switch(final_mode)
		if(WEAK_HIT)
			SEND_SIGNAL(src, COMSIG_BATON_WEAK_ATTACK, M, user)
		if(NORMAL_HIT)
			SEND_SIGNAL(src, COMSIG_BATON_NORMAL_ATTACK, M, user)
		if(STRONG_HIT)
			SEND_SIGNAL(src, COMSIG_BATON_STRONG_ATTACK, M, user)
	var/chargemult = 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M 
		if(C.stam_paralyzed)//punish keeping people floored without cuffing, but dont punish using paralysis for cheap hits
			chargemult += 1
	if(M.stat) //punish using the baton to husk people, or kill mobs that can be crit
		chargemult += 1
	deductcharge((25 * final_mode) * chargemult)

/obj/item/melee/lawbaton/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	SEND_SIGNAL(src, COMSIG_BATON_THROWN, target, range, speed, thrower)
	return ..()

/obj/item/melee/lawbaton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(hit_atom && !QDELETED(hit_atom))
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
		SEND_SIGNAL(src, COMSIG_BATON_THROW_IMPACT, hit_atom, throwingdatum)
		hit_atom.hitby(src, 0, throwingdatum=throwingdatum)
		if(isliving(hit_atom))
			var/mob/living/M = hit_atom
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.check_shields(src, force, "thrown [name]", MELEE_ATTACK))
					if(!(SEND_SIGNAL(src, COMSIG_BATON_BLOCKED, M) & COMSIG_BATON_UNBLOCKABLE))
						return
				if(!(SEND_SIGNAL(src, COMSIG_BATON_ATTACK, M) & COMSIG_BATON_NOATTACK))
					handlehit(M, hitmode = head.default_mode_thrown)


//utility procs- these are for the integral baton mechanics

/obj/item/melee/lawbaton/attack_self(mob/user)
	. = ..()
	if(user.IsAdvancedToolUser() && componentcheck(user))
		if(!cell.charge)
			balloon_alert(user, "ERR: Out of power!")
			return 
		if(!authenticated)
			to_chat(user, "<span class='notice'>This baton has not yet been registered to a valid Thinktronics Systems LTD account. Please swipe an ID with valid weapons authorization to register this baton.</span>")
			return
		togglepower()

/obj/item/melee/lawbaton/AltClick(mob/user)
	. = ..()
	if(user.IsAdvancedToolUser() && cell.charge)
		if(on)
			balloon_alert(user, "Mode cannot be switched while baton is active")
			return 
		balloon_alert(user, "Mode switched")
		togglemode()
		to_chat(user, "<span class='notice'>You switch the [src]'s mode to [mode]</span>")

/obj/item/melee/lawbaton/attackby(obj/item/W, mob/living/user, params)
	if(!on && user.IsAdvancedToolUser())
		switch(W.tool_behaviour)
			if(TOOL_MULTITOOL)
				if(authenticated)
					to_chat(user, "<span class='notice'>You start resetting [src].</span>")
					if(W.use_tool(src, user, 50, volume=50))
						reset(user)
			if(TOOL_SCREWDRIVER)
				if(capacitor)
					to_chat(user, "<span class='notice'>You start removing the [capacitor] from the [src].</span>")
					if(W.use_tool(src, user, 20, volume=50))
						user.put_in_hands(capacitor)
						to_chat(user, "<span class='notice'>You remove the [capacitor] from the [src].</span>")
						capacitor = null
					return
			if(TOOL_WIRECUTTER)
				if(laser)
					to_chat(user, "<span class='notice'>You start removing the [laser] from the [src].</span>")
					if(W.use_tool(src, user, 20, volume=50))
						user.put_in_hands(laser)
						to_chat(user, "<span class='notice'>You remove the [laser] from the [src].</span>")
						laser = null
					return
			if(TOOL_WRENCH)
				if(head)
					to_chat(user, "<span class='notice'>You start removing the [head] from the [src].</span>")
					if(W.use_tool(src, user, 50, volume=50))
						head.detach(src)
						user.put_in_hands(head)
						to_chat(user, "<span class='notice'>You remove the [head] from the [src].</span>")
					return
			if(TOOL_CROWBAR)
				if(LAZYLEN(attachments))
					to_chat(user, "<span class='notice'>You start removing the attachments from the [src]</span>")
					if(W.use_tool(src, user, 50, volume=50))
						for(var/obj/item/batonmodule/A in attachments)
							if(istype(A, /obj/item/batonmodule/head))
								continue
							A.detach(src)
					return
		if(istype(W, /obj/item/stock_parts/capacitor)) //i would use switch(W.type), but i gotta check for subtypes :/
			if(!capacitor)
				var/obj/item/stock_parts/capacitor/S = W
				if(getmodspace((S.rating-1) * 15))
					to_chat(user, "<span class='notice'>You install the [S] into the [src].</span>")
					capacitor = S
					S.forceMove(src)
				else
					to_chat(user, "<span class='notice'>The [src] has no room for the [S].</span>")
			return
		if(istype(W, /obj/item/stock_parts/micro_laser))
			if(!laser)
				var/obj/item/stock_parts/micro_laser/S = W
				if(getmodspace((S.rating-1) * 10))
					to_chat(user, "<span class='notice'>You install the [S] into the [src].</span>")
					laser = S
					S.forceMove(src)
				else
					to_chat(user, "<span class='notice'>The [src] has no room for the [S].</span>")
			return
		if(istype(W, /obj/item/batonmodule/head))
			if(!head)
				var/obj/item/batonmodule/head/S = W
				if(getmodspace(S.modcost))
					to_chat(user, "<span class='notice'>You install the [S] into the [src].</span>")
					S.attach(src)
				else
					to_chat(user, "<span class='notice'>The [src] has no room for the [S].</span>")
			return
		if(istype(W, /obj/item/batonmodule))
			var/obj/item/batonmodule/S = W
			if(getmodspace(S.modcost))
				to_chat(user, "<span class='notice'>You install the [S] into the [src].</span>")
				S.attach(src)
			else
				to_chat(user, "<span class='notice'>The [src] has no room for the [S].</span>")
			return
		if(istype(W, /obj/item/card/id))
			var/obj/item/card/id/S = W
			if(authenticated)
				if(ACCESS_ARMORY in S.access)
					if(!smartlethal)
						to_chat(user, "<span class='notice'>You reactivate [src]'s lethality restrictions.</span>")
						smartlethal = TRUE
						playsound(src, 'sound/machines/ping.ogg', 50, 0)
						return
					else 
						to_chat(user, "<span class='notice'>You begin to fill out the form to disable [src]'s smart lethality restrictions.</span>")
						if(do_mob(user, src, 200))
							smartlethal = FALSE
							playsound(src, 'sound/machines/ping.ogg', 50, 0)
							to_chat(user, "<span class='notice'>Danger! Safety sensors turned off.</span>")
						return
			else
				to_chat(user, "<span class='notice'>You begin to register [src] to the [S].</span>")
				if(do_mob(user, src, 50))//just long enough that you can't feasibly walk around with a baton that's not registered and register it in combat
					login(user, S)
					return
		update_icon()
	return ..()

/obj/item/melee/lawbaton/proc/login(mob/user, var/obj/item/card/id/S)
	if(!(ACCESS_WEAPONS in S.access))
		balloon_alert(user, "ERR: Weapons permit not found.")
		to_chat(user, "<span class='notice'>You cannot register an account, because you do not have a registered weapons permit!</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return
	var/name = "My"
	if(S.registered_name)
		name = "[S.registered_name]'s"
		for(var/obj/item/melee/lawbaton/baton in GLOB.baton_list)
			if(baton.registered == user || baton.username == S.registered_name)
				balloon_alert(user, "ERR: Account logged in elsewhere.")
				to_chat(user, "<span class='notice'>You or the holder of this ID are already logged in on another device!</span>")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
				return FALSE
	else for(var/obj/item/melee/lawbaton/baton in GLOB.baton_list)
		if(baton.registered == user)
			balloon_alert(user, "ERR: Account logged in elsewhere.")
			to_chat(user, "<span class='notice'>You or the holder of this ID are already logged in on another device!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			return FALSE
	if(!GetComponent(/datum/component/gps/tracking))
		AddComponent(/datum/component/gps/tracking, "[name] L.A.W. Baton")
	authenticated = TRUE
	smartlethal = TRUE 
	username = S.registered_name
	registered = user
	to_chat(user, "<span class='notice'>Congratulations on your purchase of a Thinktronics Systems LTD Law enforcement And Wildlife control baton!</span>")
	playsound(src, 'sound/machines/ping.ogg', 50, 0)
	return TRUE


/obj/item/melee/lawbaton/proc/reset(mob/user)
	var/datum/component/gps/tracking/GPS = GetComponent(/datum/component/gps/tracking)
	if(GPS)
		GPS.RemoveComponent()
	authenticated = initial(authenticated)
	smartlethal = initial(smartlethal)
	username = null
	registered = null
	to_chat(user, "<span class='notice'>Baton reset to factory settings.</span>")
	playsound(src, 'sound/machines/ping.ogg', 50, 0)

/obj/item/melee/lawbaton/examine(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_BATON_EXAMINED, user)
	if(user.IsAdvancedToolUser())
		if(!authenticated)
			. += "<span class='warning'>Its ID card scanner is open, and its screen is prompting you to register a Thinktronics Systems account by swiping an <b>ID card</b> that has an encoded <b>weapons permit</b>.</span>"
			return
		else if(username)
			. += "<span class='notice'>It's registered to <b>[username]</b>. It can be reset to factory settings with a <b>multitool</b>.</span>"
		else 
			. += "<span class='notice'>It's registered to a guest account. It can be reset to factory settings with a <b>multitool</b>.</span>"
		. +=  "<span class='notice'>Its screen says it has <b>[(cell.charge/10)]%</b> power remaining.</span>"
		if(!head)
			. += "<span class='notice'>It has no emitter installed</span>"
		else
			. += "<span class='notice'>This baton has a [head] installed. It can be <i>wrenched</i> out.</span>"
		if(!laser)
			. += "<span class='notice'>The laser is missing.</span>"
		else
			. += "<span class='notice'>A class <b>[laser.rating]</b> micro laser is installed. It is <i>wired</i> in place.</span>"
		if(!capacitor)
			. += "<span class='notice'>The capacitor is missing.</span>"
		else
			. += "<span class='notice'>A class <b>[capacitor.rating]</b> capacitor bank is installed. It is <i>screwed</i> in place.</span>"
		if(LAZYLEN(attachments))
			. += "<span class='notice'>It has <b>[LAZYLEN(attachments)]</b> attachments installed. Its attachment port can be <i>pried</i> open.</span>"
		. +=  "<span class='notice'>It has <b>[getmodspace()]</b> points of modification space remaining.</span>"
		if(on)
			. += "<span class='warning'>It's turned on, and cant be modified!</span>"
		. += "<span class='warning'>It's set to attack [mode]ly. You can change this by alt-clicking the baton.</span>"
	else
		. += "<span class='notice'>You can't make sense of this device.</span>"

/obj/item/melee/lawbaton/proc/componentcheck(mob/user)
	if(!head)
		balloon_alert(user, "ERR: emitter not found")
		to_chat(user, "<span class='notice'>Baton emitter missing. If you think this error was a false positive, contact thinktronic support.</span>")
		return FALSE
	if(!capacitor && mode == MODE_STUN)
		balloon_alert(user, "ERR: capacitor not found. Nonlethal mode disabled.")
		to_chat(user, "<span class='notice'>Capacitor bank missing. If you think this error was a false positive, contact thinktronic support.</span>")
		return FALSE
	if(!laser && mode == MODE_LETHAL)
		balloon_alert(user, "ERR: laser not found. Lethal mode disabled")
		to_chat(user, "<span class='notice'>Laser cutter missing. If you think this error was a false positive, contact thinktronic support.</span>")
		return FALSE
	if(!cell)
		balloon_alert(user, "FATAL ERROR: Power cell missing!")
		to_chat(user, "<span class='notice'>Power cell missing! Please purchase a new Thinktronic Systems LTD Law enforcement And Wildlife control baton. Thank you for your continued patronage.</span>")
		return FALSE 
	return TRUE 

//backend procs

/obj/item/melee/lawbaton/proc/deductcharge(amt)
	if(cell)
		. = cell.use(min(amt, cell.charge))
		if(on && !cell.charge)
			togglepower()
			SEND_SIGNAL(src, COMSIG_BATON_NO_CHARGE)
			return FALSE
		return . 
	else 
		return FALSE

/obj/item/melee/lawbaton/get_cell()
	return cell

/obj/item/melee/lawbaton/Destroy()
	if(head)
		QDEL_NULL(head)
	if(cell)
		QDEL_NULL(cell)
	if(capacitor)
		QDEL_NULL(capacitor)
	if(laser)
		QDEL_NULL(laser)
	for(var/obj/item/batonmodule/I in attachments)
		QDEL_NULL(I)
	GLOB.baton_list -= src
	return ..()

/obj/item/melee/lawbaton/Initialize()
	. = ..()
	GLOB.baton_list += src
	cell = new(src)
	capacitor = new preloadcapacitor(src)
	laser = new preloadlaser(src)
	var/obj/item/batonmodule/head/newhead = new preloadhead(src)
	newhead.attach(src)

/obj/item/melee/lawbaton/proc/togglepower()
	if(head)
		if(on)
			SEND_SIGNAL(src, COMSIG_BATON_DEACTIVATE)
			playsound(src, 'sound/effects/stealthoff.ogg', 50, TRUE)
			on = FALSE
		else if(!(SEND_SIGNAL(src, COMSIG_BATON_ACTIVATE) & COMSIG_BATON_NOACTIVATE))
			playsound(src, 'sound/effects/contractorbatonhit.ogg', 50, TRUE)
			on = TRUE
	else if(on)
		on = FALSE
	update_icon()
			
/obj/item/melee/lawbaton/proc/togglemode()
	if(!on)
		switch(mode)
			if(MODE_STUN)
				mode = MODE_LETHAL
			if(MODE_LETHAL)
				mode = MODE_STUN
		playsound(src, 'sound/items/hypospray.ogg', 50, TRUE)
		update_icon()
		SEND_SIGNAL(src, COMSIG_BATON_TOGGLE_MODE)

/obj/item/melee/lawbaton/proc/getmodspace(var/amt)
	var/total = amt
	if(capacitor)
		total += (capacitor.rating-1) * 15
	if(laser)
		total += (laser.rating-1) * 10
	for(var/obj/item/batonmodule/I in attachments)
		total += I.modcost
	return(max(0, modspace - total)) //a fully upgraded vanilla baton is 75% full

/obj/item/melee/lawbaton/update_icon()
	. = ..()
	cut_overlays()
	item_state = icon_state
	if(on)
		item_state = "[icon_state]_[mode]"
		add_overlay("[icon_state]_[mode]")

/obj/item/melee/lawbaton/proc/stuncheck(mob/living/M, mob/living/user) //can we stun the target?
	var/obj/item/bodypart/affecting = M.get_bodypart(ran_zone(user.zone_selected))
	var/armor_block = M.run_armor_check(affecting, "stamina", armour_penetration = armour_penetration)
	var/penetrateclothes = FALSE 
	if(armour_penetration >= 15)
		penetrateclothes = TRUE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.can_inject(penetrate_thick = penetrateclothes))
			armor_block += 25
	if(armor_block  >= 80) //if the target isn't feasible to take down nonlethally, dont bother. This is about how protected nukies and other such threats are
		if(mode == MODE_STUN)
			to_chat(user, "<span_class = 'warning'>[M] is too heavily armored in this area to feasibly stun.</span>")
		return FALSE
	if(iscarbon(M))
		if(HAS_TRAIT(M, TRAIT_NOSTAMCRIT))
			return FALSE
		else
			return TRUE
	return FALSE

//baton subtypes

/obj/item/melee/lawbaton/jailbroken 
	name = "\improper Jailbroken L.A.W. Baton"
	desc = "The Thinktronic Systems LTD smart Law enforcement And Wildlife control baton, or LAW baton for short. This one has been jailbroken, and does not require account registration or a lethal weapons permit, though its warranty is void."
	authenticated = TRUE 
	smartlethal = FALSE 

//baton modules

/obj/item/batonmodule
	name = "baton module"
	desc = "A LAW baton module."
	w_class = WEIGHT_CLASS_SMALL
	icon_state = "module"
	icon = 'icons/obj/lawbatonmodules.dmi'
	var/modcost = 0
	var/cooldowntime = 300 //30 seconds by default
	var/exclusive = FALSE //if true, this is unstackable with others of its type
	var/list/incompatibleattachments = list()//populate this list with exact types of modules you dont want this stacking with
	var/cooldownholder
	var/obj/item/melee/lawbaton/lawbaton

/obj/item/batonmodule/proc/attach(obj/item/melee/lawbaton/baton)
	lawbaton = baton
	for(var/obj/item/batonmodule/S in baton.attachments)
		if(exclusive && S.exclusive && istype(S, type))
			return 
		if(src.type in S.incompatibleattachments)
			return
		if(S.type in incompatibleattachments)
			return
	baton.attachments += src
	forceMove(baton)
	RegisterSignal(baton, COMSIG_BATON_ACTIVATE, .proc/on_activation, TRUE)
	RegisterSignal(baton, COMSIG_BATON_DEACTIVATE, .proc/on_deactivation, TRUE)
	RegisterSignal(baton, COMSIG_BATON_TOGGLE_MODE, .proc/on_toggle, TRUE)
	RegisterSignal(baton, COMSIG_BATON_NO_CHARGE, .proc/on_power_loss, TRUE)
	RegisterSignal(baton, COMSIG_BATON_ATTACK, .proc/on_any_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_STRONG_ATTACK, .proc/on_strong_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_NORMAL_ATTACK, .proc/on_normal_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_WEAK_ATTACK, .proc/on_weak_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_OVERCHARGE, .proc/on_overcharge_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_OVERCHARGE_PLUS, .proc/on_capacitor_overload, TRUE)
	RegisterSignal(baton, COMSIG_BATON_BLOCK, .proc/on_baton_block, TRUE)
	RegisterSignal(baton, COMSIG_BATON_BLOCKED, .proc/on_blocked_attack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_FAILED_STUNCHECK, .proc/on_failed_stuncheck, TRUE)
	RegisterSignal(baton, COMSIG_BATON_THROWN, .proc/on_baton_thrown, TRUE)
	RegisterSignal(baton, COMSIG_BATON_THROW_IMPACT, .proc/on_baton_throw_impact, TRUE)
	RegisterSignal(baton, COMSIG_BATON_EXAMINED, .proc/on_examine, TRUE)
	RegisterSignal(baton, COMSIG_ATOM_EMP_ACT, .proc/on_emp_act, TRUE)
	RegisterSignal(baton, COMSIG_ITEM_AFTERATTACK, .proc/on_afterattack, TRUE)
	RegisterSignal(baton, COMSIG_BATON_OVERCHARGING, .proc/on_overcharge, TRUE)

/obj/item/batonmodule/proc/detach(obj/item/melee/lawbaton/baton)
	lawbaton = null
	baton.attachments -= src
	forceMove(baton.drop_location())
	UnregisterSignal(baton, list(COMSIG_BATON_ACTIVATE, 
	COMSIG_BATON_DEACTIVATE, 
	COMSIG_BATON_TOGGLE_MODE, 
	COMSIG_BATON_NO_CHARGE, 
	COMSIG_BATON_ATTACK, 
	COMSIG_BATON_STRONG_ATTACK, 
	COMSIG_BATON_NORMAL_ATTACK,
	COMSIG_BATON_WEAK_ATTACK, 
	COMSIG_BATON_OVERCHARGE, 
	COMSIG_BATON_OVERCHARGE_PLUS, 
	COMSIG_BATON_BLOCK, 
	COMSIG_BATON_BLOCKED, 
	COMSIG_BATON_FAILED_STUNCHECK, 
	COMSIG_BATON_THROWN, 
	COMSIG_BATON_THROW_IMPACT, 
	COMSIG_BATON_EXAMINED))

/obj/item/batonmodule/Destroy()
	detach(lawbaton)
	return ..()

/obj/item/batonmodule/proc/cooldown()//this proc starts a cooldown if none are on and returns true. otherwise, it returns false
	if(cooldownholder <= world.time)
		cooldownholder = world.time + cooldowntime 
		return TRUE 
	else 
		return FALSE

/obj/item/batonmodule/proc/on_activation()//called when a baton is turned on
	SIGNAL_HANDLER//return COMSIG_BATON_NOACTIVATE to prevent the baton from being turned off

/obj/item/batonmodule/proc/on_deactivation()//called when a baton is turned off
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_toggle()//called when a baton changes modes
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_power_loss()//called when a baton runs out of power
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_capacitor_overload(mob/living/user)//called when a baton would overcharge while already overcharged
	SIGNAL_HANDLER//return COMSIG_BATON_NOOVERCHARGEMESSAGE to stop a message from happening when overloading twice

/obj/item/batonmodule/proc/on_examine(mob/living/user)//called when a baton is examined
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_overcharge(mob/living/user)//called when a baton gains overcharge
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_failed_stuncheck(mob/living/M, mob/living/user) //called when a baton cannot use a mode due to a failed check
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_baton_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)//called when a baton succesfully blocks an attack
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_baton_thrown(atom/target, range, speed, mob/thrower)//called when a baton is thrown at a target
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_baton_throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)//called when a baton hits a target with a thrown attack
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_emp_act(severity)//called when a baton is hit with an EMP
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_blocked_attack(mob/living/M, mob/living/user)//called after a baton's attack is blocked
	SIGNAL_HANDLER//return  COMSIG_BATON_UNBLOCKABLE to cause the attack to bypass the block

/obj/item/batonmodule/proc/on_any_attack(mob/living/M, mob/living/user)//called when a baton attacks or hits with a throw. called before baton damage category is calculated. not called on *hits*, just *attacks*
	SIGNAL_HANDLER//return COMSIG_BATON_NOATTACK to cause the attack to fail

/obj/item/batonmodule/proc/on_overcharge_attack(mob/living/M, mob/living/user) //called when a baton hits with an overcharged strike, just before damage is dealt
	SIGNAL_HANDLER

//the following three are called after a baton deals damage, and for their respective attacks
/obj/item/batonmodule/proc/on_weak_attack(mob/living/M, mob/living/user) 
	SIGNAL_HANDLER
/obj/item/batonmodule/proc/on_normal_attack(mob/living/M, mob/living/user) 
	SIGNAL_HANDLER
/obj/item/batonmodule/proc/on_strong_attack(mob/living/M, mob/living/user) 
	SIGNAL_HANDLER

/obj/item/batonmodule/proc/on_afterattack(atom/target, mob/user, proximity_flag, click_parameters)//called with afterattack. use for afterattack stuff (IE things that need an atom)
	SIGNAL_HANDLER

//baton heads
/obj/item/batonmodule/head
	name = "baton emitter"
	desc = "Fresh off the factory lines, this is an unmodified LAW baton emitter."
	icon_state = "sword"
	var/default_mode = NORMAL_HIT 
	var/default_mode_thrown = WEAK_HIT 
	var/chargemod = 1 //modifies how much charge each hit takes
	var/batonblockflags = BLOCKING_ACTIVE | BLOCKING_NASTY
	var/batonblockupgradewalk = 1
	var/batonblocklevel = 0
	var/batonblockpower = 0
	var/batonattackweight = 1
	var/batonforce = 4
	var/batonthrowforce = 4
	var/batonweightclass = WEIGHT_CLASS_NORMAL
	var/batonarmorpen = 0
	var/batonsharpness = IS_BLUNT

/obj/item/batonmodule/head/attach(obj/item/melee/lawbaton/baton)
	if(baton.head)
		return
	. = ..()
	if(baton)
		baton.block_upgrade_walk = batonblockupgradewalk
		baton.block_level = batonblocklevel
		baton.block_power = batonblockpower
		baton.block_flags = batonblockflags
		baton.attack_weight = batonattackweight
		baton.force = batonforce
		baton.throwforce = batonthrowforce
		baton.w_class = batonweightclass
		baton.sharpness = batonsharpness
		baton.armour_penetration = batonarmorpen
		baton.icon_state = icon_state
		baton.item_state = icon_state
		baton.head = src
		baton.update_icon()

/obj/item/batonmodule/head/detach(obj/item/melee/lawbaton/baton)
	. = ..()
	if(baton)
		baton.block_upgrade_walk = initial(baton.block_upgrade_walk)
		baton.block_level = initial(baton.block_level)
		baton.block_power = initial(baton.block_power)
		baton.block_flags = initial(baton.block_flags)
		baton.attack_weight = initial(baton.attack_weight)
		baton.force = initial(baton.force)
		baton.throwforce = initial(baton.throwforce)
		baton.w_class = initial(baton.w_class)
		baton.armour_penetration = initial(baton.armour_penetration)
		baton.icon_state = initial(baton.icon_state)
		baton.sharpness = initial(baton.sharpness)
		baton.item_state = initial(baton.item_state)
		baton.head = null
		baton.update_icon()

/obj/item/batonmodule/head/katana
	name = "'keeper's katana' baton emitter"
	desc = "A custom baton emitter with a sleek profile and a single-emitter design. A small capacitor bank adjacent to the blade stores an extra kick for a short while after the baton is turned on."
	modcost = 10
	icon_state = "katana"
	batonblockflags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE //Its blocks are too weak for this to matter much, but it IS a katana

/obj/item/batonmodule/head/katana/on_activation()
	. = ..()
	var/mob/living/user
	if(isliving(lawbaton.loc))
		user = lawbaton.loc
	if(cooldown())
		lawbaton.overcharge(user, FALSE, 30)

/obj/item/batonmodule/head/classic
	name = "classic baton emitter"
	desc = "An old nanotrasen stun baton shell, gutted to function as a LAW baton emitter."
	icon_state = "baton"

/obj/item/batonmodule/head/heavy
	name = "overcharged baton emitter"
	desc = "A prototype model baton emitter. It overcharges on every hit, dealing fifty percent more damage than the stock model. However, it must recharge between hits"
	icon_state = "axe"
	cooldowntime = 20
	batonforce = 8
	batonweightclass = WEIGHT_CLASS_BULKY 

/obj/item/batonmodule/head/heavy/attach(obj/item/melee/lawbaton/baton)
	. = ..()
	baton.AddComponent(/datum/component/two_handed, require_twohands=TRUE, block_power_unwielded=block_power, block_power_wielded=block_power)

/obj/item/batonmodule/head/heavy/detach(obj/item/melee/lawbaton/baton)
	. = ..()
	var/datum/component/two_handed/wielding = baton.GetComponent(/datum/component/two_handed)
	if(wielding)
		wielding.RemoveComponent()

/obj/item/batonmodule/head/heavy/on_activation()
	. = ..()
	if(!lawbaton.overcharged)
		if(cooldownholder <= world.time)
			lawbaton.overcharge(noisy = FALSE)
		else return COMSIG_BATON_NOACTIVATE

/obj/item/batonmodule/head/heavy/on_any_attack(mob/living/M, mob/living/user)
	. = ..()
	if(!lawbaton.overcharged)
		if(lawbaton.on)
			lawbaton.togglepower()
		return COMSIG_BATON_NOATTACK

/obj/item/batonmodule/head/heavy/on_overcharge_attack(mob/living/M, mob/living/user)
	. = ..()
	if(lawbaton.on)
		lawbaton.togglepower()
	cooldownholder = world.time + cooldowntime 
	addtimer(CALLBACK(src, .proc/overchargebaton, user), cooldowntime, TIMER_UNIQUE|TIMER_OVERRIDE)
	
/obj/item/batonmodule/head/heavy/proc/overchargebaton(user)
	if(!lawbaton.on)
		lawbaton.togglepower()
	lawbaton.overcharge(user)

/obj/item/batonmodule/head/heavy/on_blocked_attack(mob/living/M, mob/living/user)
	. = ..()
	if(!lawbaton.overcharged || !lawbaton.on)
		return
	var/limbtohit 
	if(iscarbon(M))
		if(M.get_inactive_held_item())
			var/obj/item/I = M.get_inactive_held_item()
			if(I.block_flags & BLOCKING_ACTIVE)
				if(M.active_hand_index == 1)
					limbtohit = BODY_ZONE_L_ARM
				else
					limbtohit = BODY_ZONE_R_ARM
			else
				if(M.active_hand_index == 1)
					limbtohit = BODY_ZONE_R_ARM
				else
					limbtohit = BODY_ZONE_L_ARM
		if(get_dist(M, user) <= 1)
			lawbaton.handlehit(M, user, WEAK_HIT, limbtohit) //hit the blocking limb. this will be a normal hit, due to overcharge
		
/obj/item/batonmodule/head/heavy/greatsword
	name = "'guardian's greatsword' baton emitter"
	desc = "A custom baton emitter made with overcharging capacitors. This artisan-crafted, single-emitter design incorporates a wide guard, making it an excellent defensive tool."
	icon_state = "greatsword"
	block_level = 1
	block_power = 40

/obj/item/batonmodule/head/heavy/greatsword/on_baton_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	. = ..()
	if(!lawbaton.overcharged || !lawbaton.on)
		return
	if(iscarbon(hitby))
		var/mob/living/carbon/C = hitby
		if(owner.active_hand_index == 1)
			lawbaton.handlehit(C, owner, WEAK_HIT, BODY_ZONE_L_ARM)
		else
			lawbaton.handlehit(C, owner, WEAK_HIT, BODY_ZONE_R_ARM)
	else if(isliving(hitby))
		var/mob/living/L = hitby
		lawbaton.handlehit(L, owner, WEAK_HIT)

/obj/item/batonmodule/head/light
	name = "compact baton emitter"
	desc = "A tactical baton emitter. This style of baton fits in the pocket, attacks faster, can exploit chinks in armor, and is weighted for throwing. However, it does significantly less damage."
	icon_state = "dagger"
	default_mode = WEAK_HIT
	default_mode_thrown = NORMAL_HIT
	batonarmorpen = 15
	batonweightclass = WEIGHT_CLASS_SMALL
	batonthrowforce = 8

/obj/item/batonmodule/head/light/on_weak_attack(mob/living/M, mob/living/user)
	. = ..()
	user.changeNext_move(4)

/obj/item/batonmodule/head/light/double
	name = "'sentinel's stave' baton emitter"
	desc = "A custom baton emitter. With single-emitter blades  and a lightened design, this special emitter functions similarly to the compact emitter, but it trades the ease of throwing and armor penetration for the ability to easily hit adjacent targets, though it may cause unintentional collateral."
	icon_state = "double"
	default_mode_thrown = WEAK_HIT
	modcost = 20 
	batonarmorpen = 10
	batonthrowforce = 4
	cooldowntime = 30// about 3 seconds between each aim-corrected hit. given the low damage, this is acceptable
	var/mob/living/lasttarget

	


#undef MODE_STUN
#undef MODE_LETHAL
#undef WEAK_HIT
#undef NORMAL_HIT
#undef STRONG_HIT