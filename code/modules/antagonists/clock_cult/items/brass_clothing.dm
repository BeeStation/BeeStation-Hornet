/obj/item/clothing/suit/clockwork
	name = "brass armor"
	desc = "A strong, brass suit worn by the soldiers of the Ratvarian armies."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	armor = list("melee" = 25, "bullet" = 20, "laser" = 40, "energy" = 40, "bomb" = 40, "bio" = 70, "rad" = 100, "fire" = 70, "acid" = 70)
	slowdown = 0.6
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/stack/tile/brass)

/obj/item/clothing/suit/clockwork/equipped(mob/living/user, slot)
	. = ..()
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='userdanger'>You feel a shock of energy surge through your body!</span>")
		user.dropItemToGround(src, TRUE)
		var/mob/living/carbon/C = user
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.electrocution_animation(20)
		C.jitteriness += 1000
		C.do_jitter_animation(C.jitteriness)
		C.stuttering += 1
		spawn(20)
		if(C)
			C.jitteriness = max(C.jitteriness - 990, 10)

/obj/item/clothing/suit/clockwork/speed
	name = "robes of divinity"
	desc = "A shiny suit, glowing with a vibrant energy. The wearer will be able to move quickly across battlefields, but will be able to withstand less damage before falling."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass_speed"
	slowdown = -0.3
	armor = list("melee" = -50, "bullet" = -25, "laser" = -25, "energy" = -60, "bomb" = 0, "bio" = 70, "rad" = 100, "fire" = 70, "acid" = 70)

/obj/item/clothing/suit/clockwork/cloak
	name = "shrouding cloak"
	desc = "A faultering cloak that bends light around it, distorting the user making it hard to see with the naked eye, however provides very little protection."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cloak"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 5, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 40)
	slowdown = 0.4
	var/shroud_active = FALSE
	var/i
	var/f
	var/start
	var/previous_alpha

/obj/item/clothing/suit/clockwork/cloak/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_SUIT && !shroud_active)
		shroud_active = TRUE
		previous_alpha = user.alpha
		animate(user, alpha=140, time=30)
		start = user.filters.len
		var/X,Y,rsq
		for(i=1, i<=7, ++i)
			do
				X = 60*rand() - 30
				Y = 60*rand() - 30
				rsq = X*X + Y*Y
			while(rsq<100 || rsq>900)
			user.filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
		for(i=1, i<=7, ++i)
			f = user.filters[start+i]
			animate(f, offset=f:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
			animate(offset=f:offset-1, time=rand()*20+10)

/obj/item/clothing/suit/clockwork/cloak/dropped(mob/user)
	. = ..()
	if(shroud_active)
		shroud_active = FALSE
		for(i=1, i<=min(7, user.filters.len), ++i) // removing filters that are animating does nothing, we gotta stop the animations first
			f = user.filters[start+i]
			animate(f)
		do_sparks(3, FALSE, user)
		user.filters = null
		animate(user, alpha=previous_alpha, time=30)
