/datum/action/spell/conjure_item/summon_pie
	name = "Summon Creampie"
	desc = "A clown's weapon of choice.  Use this to summon a fresh pie, just waiting to acquaintain itself with someone's face."
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	item_type = /obj/item/food/pie/cream
	cooldown_time = 5 SECONDS
	button_icon = 'icons/obj/food/piecake.dmi'
	button_icon_state = "pie"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/action/spell/pointed/banana_peel
	name = "Conjure Banana Peel"
	desc = "Make a banana peel appear out of thin air right under someone's feet!"
	cooldown_time = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation_type = INVOCATION_NONE

	active_msg = "You focus, your mind reaching to the clown dimension, ready to make a peel matrialize wherever you want!"
	deactive_msg = "You relax, the peel remaining right in the \"thin air\" it would appear out of."
	button_icon = 'icons/obj/hydroponics/harvest.dmi'
	base_icon_state = "banana_peel"
	button_icon_state = "banana"

/datum/action/spell/pointed/banana_peel/on_cast(mob/user, atom/target)
	. = ..()
	if(get_dist(owner,target)>cast_range)
		to_chat(owner, "<span class='notice'>\The [target] is too far away!</span>")
		return
	new /obj/item/grown/bananapeel(get_turf(target))

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/action/spell/touch/megahonk
	name = "Mega HoNk"
	desc = "This spell channels your inner clown powers, concentrating them into one massive HONK."
	hand_path = /obj/item/melee/touch_attack/megahonk

	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	button_icon = 'icons/mecha/mecha_equipment.dmi'
	button_icon_state = "mecha_honker"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/action/spell/touch/bspie
	name = "Bluespace Banana Pie"
	desc = "An entire body would fit in there!"
	hand_path = /obj/item/melee/touch_attack/bspie

	cooldown_time = 60 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	button_icon = 'icons/obj/food/piecake.dmi'
	button_icon_state = "blumpkinpieslice"




/obj/item/melee/touch_attack/megahonk
	name = "\improper honkmother's blessing"
	desc = "You've got a feeling they won't be laughing after this one. Honk honk."
	attack_verb_simple = "HONKDOOOOUKEN!"
	hitsound = 'sound/items/airhorn.ogg'
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_honker"

/datum/action/spell/touch/megahonk/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return TRUE

/obj/item/melee/touch_attack/megahonk/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !iscarbon(target) || !iscarbon(user) || user.handcuffed)
		return
	playsound(get_turf(target), hitsound,100,1)
	for(var/mob/living/carbon/M in (hearers(1, target) - user)) //3x3 around the target, not affecting the user
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		var/mul = (M==target ? 1 : 0.5)
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.adjust_stutter(40 SECONDS*mul)
		M.adjustEarDamage(0, 30*mul)
		M.Knockdown(60*mul)
		if(prob(40))
			M.Knockdown(200*mul)
		else
			M.set_jitter_if_lower(1000 SECONDS*mul)

	. = ..()

/obj/item/melee/touch_attack/megahonk/attack_self(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>\The [src] disappears, to honk another day.</span>")
	qdel(src)

/obj/item/melee/touch_attack/bspie
	name = "\improper bluespace pie"
	desc = "A thing you can barely comprehend as you hold it in your hand. You're fairly sure you could fit an entire body inside."
	hitsound = 'sound/magic/demon_consume.ogg'
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "frostypie"
	color = "#000077"

/obj/item/melee/touch_attack/bspie/attack_self(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>You smear \the [src] on your chest! </span>")
	qdel(src)

/obj/item/melee/touch_attack/bspie/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !iscarbon(target) || !iscarbon(user) || user.handcuffed)
		return
	if(target == user)
		to_chat(user, "<span class='notice'>You smear \the [src] on your chest!</span>")
		qdel(src)
		return
	var/mob/living/carbon/M = target

	user.visible_message("<span class='warning'>[user] is trying to stuff [M]\s body into \the [src]!</span>")
	if(do_after(user, 25 SECONDS, M))
		var/name = M.real_name
		var/obj/item/food/pie/cream/body/pie = new(get_turf(M))
		pie.name = "\improper [name] [pie.name]"

		. = ..()

		M.forceMove(pie)

/datum/action/spell/touch/bspie/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return TRUE


/obj/item/reagent_containers/food/snacks/pie/cream/body

/obj/item/reagent_containers/food/snacks/pie/cream/body/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		A.forceMove(T)
		A.throw_at(T, 1, 1)
	. = ..()

/*
/obj/item/reagent_containers/food/snacks/pie/cream/body/on_consume(mob/living/M) // :shrug:
	if(!reagents.total_volume) //so that it happens on the last bite
		if(iscarbon(M) && contents.len)
			var/turf/T = get_turf(src)
			for(var/atom/movable/A in contents)
				A.forceMove(T)
				A.throw_at(T, 1, 1)
				M.visible_message("[src] bursts out of [M]!</span>")
			M.emote("scream")
			M.Knockdown(40)
			M.adjustBruteLoss(60)
*/
