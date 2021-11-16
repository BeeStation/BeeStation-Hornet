#define MODE_STUN "nonlethal"
#define MODE_LETHAL "lethal"
#define WEAK_HIT 1
#define NORMAL_HIT 2
#define STRONG_HIT 3

/obj/item/melee/lawbaton
	name = "\improper L.A.W. Baton"
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
	var/modspace = 100
	var/on = FALSE
	var/overcharged = FALSE
	var/mode = MODE_STUN
	var/smartlethal = TRUE
	var/obj/item/batonmodule/head/head //the baton's head. This determines a baton's main statblock
	var/obj/item/stock_parts/cell/cell //the baton's power cell. This can't be removed
	var/obj/item/stock_parts/capacitor/capacitor //the baton's capacitor. this determines the baton's stun damage
	var/obj/item/stock_parts/micro_laser/laser //the baton's laser. this determines the baton's lethal damage
	var/list/attachments = list() //a list of all attachments a baton has
	var/preloadcapacitor = /obj/item/stock_parts/capacitor //for upgraded batons
	var/preloadlaser = /obj/item/stock_parts/micro_laser
	var/preloadhead = /obj/item/batonmodule/head //all starting attachments, including the head, go here

//attack procs. If you're making balance changes, make them here

/obj/item/melee/lawbaton/proc/overcharge(mob/living/M, mob/living/user)
	playsound(src, 'sound/weapons/kenetic_reload.ogg', 50, TRUE)

/obj/item/melee/lawbaton/attack(mob/living/M, mob/living/user)
	user.changeNext_move(head.attackrate)
	if(on)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.check_shields(src, force, "[user]'s [name]", MELEE_ATTACK))
				if(!SEND_SIGNAL(src, COMSIG_BATON_BLOCKED, M, user) & COMSIG_BATON_UNBLOCKABLE)
					return FALSE
			if(check_martial_counter(M, user))
				if(!SEND_SIGNAL(src, COMSIG_BATON_BLOCKED, M, user) & COMSIG_BATON_UNBLOCKABLE)
					return FALSE 
			if(mode == MODE_LETHAL && HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
				return
		if(!SEND_SIGNAL(src, COMSIG_BATON_ATTACK, M, user) & COMSIG_BATON_NOATTACK)
			handlehit(M, user)
	else if(user.a_intent == INTENT_HARM)
		return ..()
	M.visible_message("<span class='warning'>[user] has prodded [M] with [src]. Luckily it was off.</span>", \
				"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")

/obj/item/melee/lawbaton/proc/handlehit(mob/living/M, mob/living/user)
	var/list/stunsounds = list('sound/weapons/egloves.ogg', 'sound/weapons/ionrifle.ogg', 'sound/weapons/zapbang.ogg')
	var/list/lethalsounds = list('sound/weapons/plasma_cutter.ogg', 'sound/weapons/sear.ogg', 'sound/weapons/marauder.ogg')
	var/list/typesignals = list(COMSIG_BATON_WEAK_ATTACK, COMSIG_BATON_NORMAL_ATTACK, COMSIG_BATON_STRONG_ATTACK)
	var/obj/item/bodypart/affecting = M.get_bodypart(ran_zone(user.zone_selected))
	var/final_mode = head.default_mode
	var/penetrateclothes = FALSE
	if(armour_penetration >= 15)
		penetrateclothes = TRUE
	switch(mode)
		if(MODE_STUN)
			if(iscyborg(M))
				M.Stun((1 + capacitor.rating) * final_mode) //doesn't last very long, but it's *something*
				playsound(src, stunsounds[final_mode], 50, TRUE)
				M.visible_message("<span class='userdanger'>[user] shorts out your circuits with the [src]!</span>", "<span class='warning'>[user] stuns [M] with the [src]!</span>")
				return
			if(!stuncheck(M, user))
				balloon_alert(user, "Target is not susceptible to nonlethal apprehension.")
				to_chat(user, "<span class='notice'>Target is not susceptible to nonlethal apprehension. Aborting attack to preserve battery life.</span>")
				playsound(M, 'sound/machines/buzz-sigh.ogg', 50, 0)
				return
			var/damage = ((6 * final_mode) * (capacitor.rating + 1))
			playsound(src, stunsounds[final_mode], 50, TRUE)
			var/armor_block = M.run_armor_check(affecting, "stamina", armour_penetration = armour_penetration)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!H.can_inject(penetrate_thick = penetrateclothes)) 
					armor_block += 25 //your average security member has about 65 chest stamina armor including this bonus. An assistant in a firesuit carries 35, with slowdown. without security gear or hardsuits, the most a tider can feasibly get is 50ish- still better than lethals
			M.apply_damage(damage, STAMINA, affecting, armor_block)
			user.do_attack_animation(M)
		if(MODE_LETHAL)
			if(stuncheck(M, user) && smartlethal)
				balloon_alert(user, "Target is susceptible to nonlethal apprehension.")
				to_chat(user, "<span class='notice'>Target is susceptible to nonlethal apprehension. You are not authorized to escalate to lethal measures at this time.</span>")
				playsound(M, 'sound/machines/buzz-sigh.ogg', 50, 0)
				SEND_SIGNAL(src, COMSIG_BATON_FAILED_STUNCHECK, M, user)
				return
			var/damage = (8 + (2 * final_mode) * capacitor.rating)
			playsound(src, lethalsounds[final_mode], 50, TRUE)
			var/armor_block = M.run_armor_check(affecting, "melee", armour_penetration = armour_penetration)
			M.apply_damage(damage, BURN, affecting, armor_block)
			add_mob_blood(M)
			user.do_attack_animation(M)
	SEND_SIGNAL(src, typesignals[final_mode], M, user)


//utility procs- these are for the integral baton mechanics

/obj/item/melee/lawbaton/attack_self(mob/user)
	. = ..()
	if(user.IsAdvancedToolUser() && componentcheck(user))
		if(!cell.charge)
			balloon_alert(user, "ERR: Out of power!")
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
		seticon()
	return ..()

/obj/item/melee/lawbaton/examine(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_BATON_EXAMINED, user)
	if(user.IsAdvancedToolUser())
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
	return ..()

/obj/item/melee/lawbaton/Initialize()
	. = ..()
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
		else if(!SEND_SIGNAL(src, COMSIG_BATON_ACTIVATE) & COMSIG_BATON_NOACTIVATE)
			playsound(src, 'sound/effects/contractorbatonhit.ogg', 50, TRUE)
			on = TRUE
	seticon()
			
/obj/item/melee/lawbaton/proc/togglemode()
	if(!on)
		switch(mode)
			if(MODE_STUN)
				mode = MODE_LETHAL
			if(MODE_LETHAL)
				mode = MODE_STUN
		playsound(src, 'sound/items/hypospray.ogg', 50, TRUE)
		seticon()
		SEND_SIGNAL(src, COMSIG_BATON_TOGGLE_MODE)

/obj/item/melee/lawbaton/proc/getmodspace(var/amt)
	var/total = amt
	if(capacitor)
		total += (capacitor.rating-1) * 15
	if(laser)
		total += (laser.rating-1) * 10
	for(var/obj/item/batonmodule/I in attachments)
		total += I.modcost
	return(max(0, modspace - total))

/obj/item/melee/lawbaton/proc/seticon()
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
		if(mode = MODE_STUN)
			to_chat(user, "<span_class = 'warning'>[M] is too heavily armored in this area to feasibly stun.</span>")
		return FALSE
	if(iscarbon(M))
		if(HAS_TRAIT(M, TRAIT_NOSTAMCRIT))
			return FALSE
		else
			return TRUE
	return FALSE

//baton modules

/obj/item/batonmodule
	name = "baton module"
	desc = "A LAW baton module."
	var/modcost = 0
	var/obj/item/melee/lawbaton/lawbaton

/obj/item/batonmodule/proc/attach(var/obj/item/melee/lawbaton/baton)
	lawbaton = baton
	baton.attachments += src
	forceMove(baton)

/obj/item/batonmodule/proc/detach(var/obj/item/melee/lawbaton/baton)
	lawbaton = null
	baton.attachments -= src
	forceMove(baton.drop_location())

/obj/item/batonmodule/Destroy()
	detach(lawbaton)
	return ..()

//baton heads
	
/obj/item/batonmodule/head
	name = "baton emitter"
	desc = "Fresh off the factory lines, this is an unmodified LAW baton emitter."
	icon_state = "sword"
	icon = 'icons/obj/lawbatonmodules.dmi'
	var/attackrate = CLICK_CD_MELEE //normal melee by default. this is essentially how fast the baton attacks
	var/default_mode = NORMAL_HIT 
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

/obj/item/batonmodule/head/attach(var/obj/item/melee/lawbaton/baton)
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

/obj/item/batonmodule/head/detach(var/obj/item/melee/lawbaton/baton)
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

/obj/item/batonmodule/head/katana
	name = "'keeper's katana' baton emitter"
	desc = "A custom baton emitter with a sleek profile and a single-emitter design. A small capacitor bank adjacent to the blade stores an extra kick for a short while after the baton is turned on."
	icon_state = "katana"

/obj/item/batonmodule/head/classic
	name = "classic baton emitter"
	desc = "An old nanotrasen stun baton shell, gutted to function as a LAW baton emitter."
	icon_state = "baton"

/obj/item/batonmodule/head/heavy
	name = "overcharged baton emitter"
	desc = "A prototype model baton emitter. It overcharges on every hit, dealing fifty percent more damage than the stock model. However, it must recharge between hits"
	icon_state = "axe"

/obj/item/batonmodule/head/heavy/greatsword
	name = "'guardian's greatsword' baton emitter"
	desc = "A custom baton emitter made with overcharging capacitors. This artisan-crafted, single-emitter design incorporates a wide guard, making it an excellent defensive tool."
	icon_state = "greatsword"

/obj/item/batonmodule/head/light
	name = "compact baton emitter"
	desc = "A tactical baton emitter. This style of baton fits in the pocket, attacks faster, can exploit chinks in armor, and is weighted for throwing. However, it does significantly less damage."
	icon_state = "dagger"
	attackrate = CLICK_CD_RANGE //attacks twice as fast

/obj/item/batonmodule/head/light/double
	name = "'sentinel's stave' baton emitter"
	desc = "A custom baton emitter. With single-emitter blades  and a lightened design, this special emitter functions similarly to the compact emitter, but it trades the ease of throwing for the ability to easily hit adjacent targets."
	icon_state = "double"



#undef MODE_STUN
#undef MODE_LETHAL
#undef WEAK_HIT
#undef NORMAL_HIT
#undef STRONG_HIT