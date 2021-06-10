/obj/item/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	block_level = 1
	block_upgrade_walk = 1
	block_power = 50
	max_integrity =  75
	var/transparent = FALSE	// makes beam projectiles pass through the shield
	var/durability = TRUE //the shield uses durability instead of stamina

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(transparent && (hitby.pass_flags & PASSGLASS))
		return FALSE
	return ..()

/obj/item/shield/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	if(durability)
		var/attackforce = 0
		if(isprojectile(hitby))
			var/obj/item/projectile/P = hitby
			if(P.damage_type != STAMINA)// disablers dont do shit to shields
				attackforce = (P.damage / 2)
		else if(isitem(hitby))
			var/obj/item/I = hitby
			attackforce = damage
			if(!I.damtype == BRUTE)
				attackforce = (attackforce / 2)
			attackforce = (attackforce * I.attack_weight)
			if(I.damtype == STAMINA)//pure stamina damage wont affect blocks
				attackforce = 0
		else if(isliving(hitby)) //not putting an anti stamina clause in here. only stamina damage simplemobs i know of are swarmers, and them eating shields makes sense
			var/mob/living/L = hitby
			if(block_flags & BLOCKING_HUNTER)
				attackforce = (damage) //some shields are better at blocking simple mobs
			else
				attackforce = (damage * 2)//simplemobs have an advantage here because of how much these blocking mechanics put them at a disadvantage
			if(block_flags & BLOCKING_NASTY)
				L.attackby(src, owner)
				owner.visible_message("<span class='danger'>[L] injures themselves on [owner]'s [src]!</span>")
		if (obj_integrity <= attackforce)
			var/turf/T = get_turf(owner)
			T.visible_message("<span class='warning'>[hitby] destroys [src]!</span>")
			obj_integrity = 1
			shatter(owner)
			return FALSE
		take_damage(attackforce * ((100-(block_power))/100))
		return TRUE
	else
		return ..()

/obj/item/shield/attackby(obj/item/weldingtool/W, mob/living/user, params)
	if(istype(W))
		if(obj_integrity < max_integrity)
			if(!W.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is welding the [src].", \
									"<span class='notice'>You begin repairing the [src]]...</span>")
			if(W.use_tool(src, user, 40, volume=50))
				obj_integrity += 10
				user.visible_message("[user.name] has repaired some dents on [src].", \
									"<span class='notice'>You finish repairing some of the dents on [src].</span>")
			else
				to_chat(user, "<span class='notice'>The [src] doesn't need repairing.</span>")
	return ..()

/obj/item/shield/examine(mob/user)
	. = ..()
	var/healthpercent = round((obj_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += "<span class='info'>It looks slightly damaged.</span>"
		if(25 to 50)
			. += "<span class='info'>It appears heavily damaged.</span>"
		if(0 to 25)
			. += "<span class='warning'>It's falling apart!</span>"

/obj/item/shield/proc/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/glassbr3.ogg', 100)
	new /obj/item/shard((get_turf(src)))
	qdel(src)

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	block_level = 1
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/glass=7500, /datum/material/iron=1000)
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	transparent = TRUE

/obj/item/shield/riot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else if(istype(W, /obj/item/stack/sheet/mineral/titanium))
		if (obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>[src] is already in perfect condition.</span>")
		else
			var/obj/item/stack/sheet/mineral/titanium/T = W
			T.use(1)
			obj_integrity = max_integrity
			to_chat(user, "<span class='notice'>You repair [src] with [T].</span>")
	else
		return ..()

/obj/item/shield/riot/roman
	name = "\improper Roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	transparent = FALSE
	materials = list(/datum/material/iron=8500)
	max_integrity = 65

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	block_level = 1
	block_upgrade_walk = 1
	block_power = 0
	max_integrity = 30

/obj/item/shield/riot/roman/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/grillehit.ogg', 100)
	new /obj/item/stack/sheet/iron(get_turf(src))
	qdel(src)

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	block_level = 1
	block_upgrade_walk = 1
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	materials = list()
	resistance_flags = FLAMMABLE
	transparent = FALSE
	max_integrity = 55
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/shield/riot/buckler/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/mineral/wood(get_turf(src))
	qdel(src)

/obj/item/shield/riot/goliath
	name = "Goliath shield"
	desc = "A shield made from interwoven plates of goliath hide."
	icon_state = "goliath_shield"
	item_state = "goliath_shield"
	block_level = 1
	block_upgrade_walk = 1
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	materials = list ()
	transparent = FALSE
	block_power = 25
	max_integrity = 70
	block_flags = BLOCKING_HUNTER | BLOCKING_PROJECTILE
	w_class = WEIGHT_CLASS_BULKY

/obj/item/shield/riot/goliath/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/animalhide/goliath_hide(get_turf(src))
	qdel(src)

/obj/item/shield/riot/flash
	name = "strobe shield"
	desc = "A shield with a built in, high intensity light capable of blinding and disorienting suspects. Takes regular handheld flashes as bulbs."
	icon_state = "flashshield"
	item_state = "flashshield"
	var/obj/item/assembly/flash/handheld/embedded_flash

/obj/item/shield/riot/flash/Initialize()
	. = ..()
	embedded_flash = new(src)

/obj/item/shield/riot/flash/attack(mob/living/M, mob/user)
	. =  embedded_flash.attack(M, user)
	update_icon()

/obj/item/shield/riot/flash/attack_self(mob/living/carbon/user)
	. = embedded_flash.attack_self(user)
	update_icon()

/obj/item/shield/riot/flash/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if (. && !embedded_flash.burnt_out)
		embedded_flash.activate()
		update_icon()


/obj/item/shield/riot/flash/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/flash = W
		if(flash.burnt_out)
			to_chat(user, "No sense replacing it with a broken bulb.")
			return
		else
			to_chat(user, "You begin to replace the bulb.")
			if(do_after(user, 20, target = user))
				if(flash.burnt_out || !flash || QDELETED(flash))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				qdel(embedded_flash)
				embedded_flash = flash
				flash.forceMove(src)
				update_icon()
				return
	..()

/obj/item/shield/riot/flash/emp_act(severity)
	. = ..()
	embedded_flash.emp_act(severity)
	update_icon()

/obj/item/shield/riot/flash/update_icon()
	if(!embedded_flash || embedded_flash.burnt_out)
		icon_state = "riot"
		item_state = "riot"
	else
		icon_state = "flashshield"
		item_state = "flashshield"

/obj/item/shield/riot/flash/examine(mob/user)
	. = ..()
	if (embedded_flash?.burnt_out)
		. += "<span class='info'>The mounted bulb has burnt out. You can try replacing it with a new one.</span>"

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "An advanced hard-light shield. It can be retracted, expanded, and stored anywhere, but can't take much punishment before needing a reset"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("shoved", "bashed")
	throw_range = 5
	force = 3
	throwforce = 3
	throw_speed = 3
	max_integrity = 50
	block_sound = 'sound/weapons/egloves.ogg'
	block_flags = BLOCKING_PROJECTILE
	var/base_icon_state = "eshield" // [base_icon_state]1 for expanded, [base_icon_state]0 for contracted
	var/on_force = 10
	var/on_throwforce = 8
	var/on_throw_speed = 2
	var/active = 0
	var/clumsy_check = TRUE
	var/cooldown_duration = 100
	var/cooldown_timer

/obj/item/shield/energy/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/turbolift/turbolift-close.ogg', 200, 1)
	src.attack_self(owner)
	to_chat(owner, "<span class='warning'>The [src] overheats!.</span>")
	cooldown_timer = world.time + cooldown_duration
	addtimer(CALLBACK(src, .proc/recharged, owner), cooldown_duration)

/obj/item/shield/energy/proc/recharged(mob/living/carbon/human/owner)//ree. i hate addtimer. ree.
	playsound(owner, 'sound/effects/beepskyspinsabre.ogg', 35, 1)
	to_chat(owner, "<span class='warning'>The [src] is ready to use!.</span>")

/obj/item/shield/energy/Initialize()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		if(isprojectile(hitby))
			var/obj/item/projectile/P = hitby
			if(P.reflectable)
				P.firer = src
				P.setAngle(get_dir(owner, hitby))
				return 1
		return ..()
	return 0

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	if(cooldown_timer >= world.time)
		return
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_bodypart_damage(5)
	active = !active
	icon_state = "[base_icon_state][active]"
	if(active)
		force = on_force
		throwforce = on_throwforce
		throw_speed = on_throw_speed
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] is now active and back at full power.</span>")
		if(obj_integrity <= 1)
			obj_integrity = max_integrity
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	var/active = 0

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)
