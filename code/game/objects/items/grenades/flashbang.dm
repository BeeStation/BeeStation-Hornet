/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	custom_price = 25
	var/flashbang_range = 7 //how many tiles away the mob will be stunned.

/obj/item/grenade/flashbang/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, COLOR_WHITE, 2)
	for(var/mob/living/M in viewers(flashbang_range, flashbang_turf))
		flash(get_turf(M), M)
	for(var/mob/living/M in hearers(flashbang_range, flashbang_turf))
		bang(get_turf(M), M)
	qdel(src)

//Flash
/obj/item/grenade/flashbang/proc/flash(turf/T, mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	//When distance is 0, will be 1
	//When distance is 7, will be 0
	//Can be less than 0 due to hearers being a circular radius.
	var/distance_proportion = max(1 - (distance / flashbang_range), 0)

	if(M.flash_act(intensity = 1, affect_silicon = 1))
		if(distance_proportion)
			M.Paralyze(20 * distance_proportion)
			M.Knockdown(200 * distance_proportion)
	else
		M.flash_act(intensity = 2)

//Bang
/obj/item/grenade/flashbang/proc/bang(turf/T, mob/living/M)
	if(M.stat == DEAD)
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	M.show_message(span_warning("BANG"), MSG_AUDIBLE)
	if(!distance || loc == M || loc == M.loc)	//Stop allahu akbarring rooms with this.
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
	else
		if(distance <= 1)
			M.Paralyze(5)
			M.Knockdown(30)

		var/distance_proportion = max(1 - (distance / flashbang_range), 0)
		if(distance_proportion)
			M.soundbang_act(1, 200 * distance_proportion, rand(0, 5))

/obj/item/grenade/stingbang
	name = "stingbang"
	icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 1 //how many tiles away the mob will be stunned.
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
	shrapnel_radius = 5
	max_demand = 5
	custom_premium_price = 200


/obj/item/grenade/stingbang/mega
	name = "mega stingbang"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball/mega
	shrapnel_radius = 12

/obj/item/grenade/stingbang/prime(mob/living/lanced_by)
	if(dud_flags)
		active = FALSE
		update_icon()
		return FALSE
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		var/obj/item/bodypart/B = C.get_holding_bodypart_of_item(src)
		if(B)
			forceMove(get_turf(C))
			C.visible_message("<b>[span_danger("[src] goes off in [C]'s hand, blowing [C.p_their()] [B.name] to bloody shreds!")]</b>", span_userdanger("[src] goes off in your hand, blowing your [B.name] to bloody shreds!"))
			B.dismember()

	. = ..()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/weapons/flashbang.ogg', 50, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, COLOR_WHITE, (flashbang_range + 2), 2, 1)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		pop(get_turf(M), M)
	qdel(src)

//Flash
/obj/item/grenade/stingbang/proc/flash(turf/T, mob/living/M)
	if(M.stat == DEAD)
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	if(M.flash_act(affect_silicon = 1))
		M.Paralyze(max(10/max(1,distance), 5))
		M.Knockdown(max(100/max(1,distance), 60))

//Pop
/obj/item/grenade/stingbang/proc/pop(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.show_message(span_warning("POP"))
	var/distance = max(0,get_dist(get_turf(src),T))
	if(!distance || loc == M || loc == M.loc)	//Stop allahu akbarring rooms with this.
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
		if(M.apply_damages(brute = 10, burn = 10))
			to_chat(M, span_userdanger("The blast from \the [src] bruises and burns you!"))

	// only checking if they're on top of the tile, cause being one tile over will be its own punishment

// Grenade that releases more shrapnel the more times you use it in hand between priming and detonation (sorta like the 9bang from MW3), for admin goofs
/obj/item/grenade/primer
	name = "rotfrag grenade"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases shrapnel shards."
	icon_state = "timeg"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/rots_per_mag = 3 /// how many times we need to "rotate" the charge in hand per extra tile of magnitude
	shrapnel_type = /obj/projectile/bullet/shrapnel
	var/rots = 1 /// how many times we've "rotated" the charge

/obj/item/grenade/primer/attack_self(mob/user)
	. = ..()
	if(active)
		user.playsound_local(user, 'sound/misc/box_deploy.ogg', 50, TRUE)
		rots++
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/grenade/primer/prime(mob/living/lanced_by)
	shrapnel_radius = round(rots / rots_per_mag)
	. = ..()
	if(!.)
		return
	qdel(src)

/obj/item/grenade/primer/stingbang
	name = "rotsting"
	desc = "A grenade that generates more shrapnel the more you rotate it in your hand after pulling the pin. This one releases stingballs."
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	rots_per_mag = 2
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
