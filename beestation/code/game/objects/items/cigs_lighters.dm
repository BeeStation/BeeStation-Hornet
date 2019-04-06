//In order to try and stay atomic with TG's shit, I have copied and pasted their stuff here, with my very unatomic changes. 
//If they update their lighter stuff we'll probably have to update this too but better to do that than to have to deal with conflicts. 

/obj/item/clothing/mask/cigarette/light(flavor_text = null)
	..()
	playsound(src, 'sound/items/cig_light.ogg', 75, 1, -1)


/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
	var/mob/living/M = loc
	if(isliving(loc))
		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		new type_butt(location)
		if(ismob(loc))
			to_chat(M, "<span class='notice'>Your [name] goes out.</span>")
			playsound(src, 'sound/items/cig_snuff.ogg', 25, 1)
		qdel(src)
		return
	open_flame()
	if((reagents && reagents.total_volume) && (nextdragtime <= world.time))
		nextdragtime = world.time + dragtime
		handle_reagents()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on \the [src], putting it out instantly.</span>")
		new type_butt(user.loc)
		new /obj/effect/decal/cleanable/ash(user.loc)
		playsound(src, 'sound/items/cig_snuff.ogg', 25, 1)
		qdel(src)
	. = ..()

/obj/item/lighter/attack_self(mob/living/user)
	if(user.is_holding(src))
		if(!lit)
			set_lit(TRUE)
			if(fancy)
				user.visible_message("Without even breaking stride, [user] flips open and lights [src] in one smooth movement.", "<span class='notice'>Without even breaking stride, you flip open and light [src] in one smooth movement.</span>")
				playsound(src.loc, 'sound/items/zippo_on.ogg', 100, 1)
			else
				var/prot = FALSE
				var/mob/living/carbon/human/H = user

				if(istype(H) && H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(G.max_heat_protection_temperature)
						prot = (G.max_heat_protection_temperature > 360)
				else
					prot = TRUE

				if(prot || prob(75))
					user.visible_message("After a few attempts, [user] manages to light [src].", "<span class='notice'>After a few attempts, you manage to light [src].</span>")
				else
					var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
					user.apply_damage(5, BURN, hitzone)
					user.visible_message("<span class='warning'>After a few attempts, [user] manages to light [src] - however, [user.p_they()] burn [user.p_their()] finger in the process.</span>", "<span class='warning'>You burn yourself while lighting the lighter!</span>")
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "burnt_thumb", /datum/mood_event/burnt_thumb)
				playsound(src.loc, 'sound/items/lighter_on.ogg', 100, 1)

		else
			set_lit(FALSE)
			if(fancy)
				user.visible_message("You hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.", "<span class='notice'>You quietly shut off [src] without even looking at what you're doing. Wow.</span>")
				playsound(src.loc, 'sound/items/zippo_off.ogg', 100, 1)
			else
				user.visible_message("[user] quietly shuts off [src].", "<span class='notice'>You quietly shut off [src].</span>")
				playsound(src.loc, 'sound/items/lighter_off.ogg', 100, 1)
	else
		. = ..()

//Throwing matches down here too because there isn't anything else to do with them.
/obj/item/storage/box/matches/attackby(obj/item/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/match))
		W.matchignite()
		playsound(src.loc, 'sound/items/matchstick_lit.ogg', 100, 1)