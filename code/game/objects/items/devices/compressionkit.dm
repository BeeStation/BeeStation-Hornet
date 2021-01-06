/obj/item/compressionkit
	name = "bluespace compression kit"
	desc = "An illegally modified BSRPED, capable of reducing the size of most items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "compression_c"
	item_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 5
	// var/damage_multiplier = 0.2 Not in use yet.

/obj/item/compressionkit/examine(mob/user)
	. = ..()
	. += ("<span class='notice'>It has [charges] charges left. Recharge with bluespace crystals.</span>")

/obj/item/compressionkit/proc/sparks()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()

/obj/item/compressionkit/suicide_act(mob/living/carbon/M)
	M.visible_message("<span class='suicide'>[M] is sticking their head in [src] and turning it on! [M.p_theyre(TRUE)] going to compress their own skull!</span>")
	var/obj/item/bodypart/head = M.get_bodypart("head")
	if(!head)
		return
	var/turf/T = get_turf(M)
	var/list/organs = M.getorganszone("head") + M.getorganszone("eyes") + M.getorganszone("mouth")
	for(var/internal_organ in organs)
		var/obj/item/organ/I = internal_organ
		I.Remove(M)
		I.forceMove(T)
	head.drop_limb()
	qdel(head)
	new M.gib_type(T,1,M.get_static_viruses())
	M.add_splatter_floor(T)
	playsound(M, 'sound/weapons/flash.ogg', 50, 1)
	playsound(M, 'sound/effects/splat.ogg', 50, 1)

	return OXYLOSS

/obj/item/compressionkit/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	else
		if(charges == 0)
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1)
			to_chat(user, "<span class='notice'>The bluespace compression kit is out of charges! Recharge it with bluespace crystals.</span>")
			return
	if(istype(target, /obj/item))
		var/obj/item/O = target
		if(O.w_class == 1)
			playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1)
			to_chat(user, "<span class='notice'>[target] cannot be compressed smaller!.</span>")
			return
		if(O.GetComponent(/datum/component/storage))
			to_chat(user, "<span class='notice'>You can't make this item any smaller without compromising its storage functions!.</span>")
			return
		if(O.w_class > 1)
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user] is compressing [O] with their bluespace compression kit!</span>")
			if(do_mob(user, O, 40) && charges > 0 && O.w_class > 1)
				playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 50, 1)
				sparks()
				flash_lighting_fx(3, 3, LIGHT_COLOR_CYAN)
				O.w_class -= 1
				// O.force_mult -= damage_multiplier
				charges -= 1
				to_chat(user, "<span class='notice'>You successfully compress [target]! The compressor now has [charges] charges.</span>")
		else
			to_chat(user, "<span class='notice'>Anomalous error. Summon a coder.</span>")


/obj/item/compressionkit/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/B = I
		charges += 2
		to_chat(user, "<span class='notice'>You insert [I] into [src]. It now has [charges] charges.</span>")
		if(B.amount > 1)
			B.amount -= 1
		else
			qdel(I)
