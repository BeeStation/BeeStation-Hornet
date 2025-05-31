/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = FALSE			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie


/obj/structure/toilet/Initialize(mapload)
	. = ..()
	open = round(rand(0, 1))
	update_icon()


/obj/structure/toilet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message(span_danger("[user] slams the toilet seat onto [swirlie]'s head!"), span_userdanger("[user] slams the toilet seat onto your head!"), span_italics("You hear reverberating porcelain."))
		swirlie.adjustBruteLoss(5)

	else if(user.pulling && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				to_chat(user, span_warning("[GM] needs to be on [src]!"))
				return
			if(!swirlie)
				if(open)
					GM.visible_message(span_danger("[user] starts to give [GM] a swirlie!"), span_userdanger("[user] starts to give you a swirlie..."))
					swirlie = GM
					if(do_after(user, 3 SECONDS, target = src, timed_action_flags = IGNORE_HELD_ITEM))
						GM.visible_message(span_danger("[user] gives [GM] a swirlie!"), span_userdanger("[user] gives you a swirlie!"), span_italics("You hear a toilet flushing."))
						if(iscarbon(GM))
							var/mob/living/carbon/C = GM
							if(!C.internal)
								C.adjustOxyLoss(5)
						else
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
					GM.visible_message(span_danger("[user] slams [GM.name] into [src]!"), span_userdanger("[user] slams you into [src]!"))
					GM.adjustBruteLoss(5)
		else
			to_chat(user, span_warning("You need a tighter grip!"))

	else if(cistern && !open && user.CanReach(src))
		if(!contents.len)
			to_chat(user, span_notice("The cistern is empty."))
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(drop_location())
			to_chat(user, span_notice("You find [I] in the cistern."))
			w_items -= I.w_class
	else
		open = !open
		update_icon()


/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"


/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, span_notice("You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]..."))
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 30))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", span_notice("You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!"), span_italics("You hear grinding porcelain."))
			cistern = !cistern
			update_icon()

	else if(cistern && !user.combat_mode)
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, "<span class='warning'>[I] does not fit!</span>")
			return
		if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
			to_chat(user, "<span class='warning'>The cistern is full!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the cistern!</span>")
			return
		w_items += I.w_class
		to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")

	else if(istype(I, /obj/item/reagent_containers) && !user.combat_mode)
		if (!open)
			return
		var/obj/item/reagent_containers/RG = I
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, span_notice("You fill [RG] from [src]. Gross."))
	else
		return ..()

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if (secret_type)
		new secret_type(src)

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal. Comes complete with experimental urinal cake."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE
	var/exposed = 0 // can you currently put an item inside
	var/obj/item/hiddenitem = null // what's in the urinal

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/urinal, 32)

/obj/structure/urinal/Initialize(mapload)
	. = ..()
	hiddenitem = new /obj/item/food/urinalcake

/obj/structure/urinal/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.pulling && isliving(user.pulling))
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				to_chat(user, span_notice("[GM.name] needs to be on [src]."))
				return
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message(span_danger("[user] slams [GM] into [src]!"), span_danger("You slam [GM] into [src]!"))
			GM.adjustBruteLoss(8)
		else
			to_chat(user, span_warning("You need a tighter grip!"))

	else if(exposed)
		if(!hiddenitem)
			to_chat(user, span_notice("There is nothing in the drain holder."))
		else
			if(ishuman(user))
				user.put_in_hands(hiddenitem)
			else
				hiddenitem.forceMove(get_turf(src))
			to_chat(user, span_notice("You fish [hiddenitem] out of the drain enclosure."))
			hiddenitem = null
	else
		..()

/obj/structure/urinal/attackby(obj/item/I, mob/living/user, params)
	if(exposed)
		if (hiddenitem)
			to_chat(user, span_warning("There is already something in the drain enclosure."))
			return
		if(I.w_class > 1)
			to_chat(user, span_warning("[I] is too large for the drain enclosure."))
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("\[I] is stuck to your hand, you cannot put it in the drain enclosure!"))
			return
		hiddenitem = I
		to_chat(user, span_notice("You place [I] into the drain enclosure."))
	else
		return ..()

/obj/structure/urinal/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	to_chat(user, span_notice("You start to [exposed ? "screw the cap back into place" : "unscrew the cap to the drain protector"]..."))
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
	if(I.use_tool(src, user, 20))
		user.visible_message("[user] [exposed ? "screws the cap back into place" : "unscrew the cap to the drain protector"]!",
			span_notice("You [exposed ? "screw the cap back into place" : "unscrew the cap on the drain"]!"),
			span_italics("You hear metal and squishing noises."))
		exposed = !exposed
	return TRUE


/obj/item/food/urinalcake
	name = "urinal cake"
	desc = "The noble urinal cake, protecting the station's pipes from the station's pee. Do not eat."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "urinalcake"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/chlorine = 3, /datum/reagent/ammonia = 1)
	foodtypes = TOXIC | GROSS

/obj/item/food/urinalcake/attack_self(mob/living/user)
	user.visible_message(span_notice("[user] squishes [src]!"), span_notice("You squish [src]."), "<i>You hear a squish.</i>")
	icon_state = "urinalcake_squish"
	addtimer(VARSET_CALLBACK(src, icon_state, "urinalcake"), 8)

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	worn_icon_state = "duck"


/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment
	var/dispensedreagent = /datum/reagent/water // for whenever plumbing happens


/obj/structure/sinkframe
	name = "sink frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink_frame"
	desc = "A sink frame, that needs 2 plastic sheets to finish construction."
	anchored = FALSE

/obj/structure/sinkframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/sinkframe/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/plastic))
		balloon_alert(user, "You start constructing a sink...")
		if(do_after(user, 4 SECONDS, target = src))
			I.use(1)
			balloon_alert(user, "You create a sink.")
			var/obj/structure/sink/new_sink = new /obj/structure/sink(loc)
			new_sink.setDir(dir)
			qdel(src)
			return
	return ..()

/obj/structure/sinkframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/sink/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, span_notice("Someone's already washing here."))
		return
	var/washing_face = user.is_zone_selected(BODY_ZONE_HEAD)
	user.visible_message(span_notice("[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]..."), \
						span_notice("You start washing your [washing_face ? "face" : "hands"]..."))
	busy = TRUE

	if(!do_after(user, 40, target = src))
		busy = FALSE
		return

	busy = FALSE

	if(washing_face)
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_FACE_ACT, CLEAN_WASH)
		user.drowsyness = max(user.drowsyness - rand(2,3), 0) //Washing your face wakes you up if you're falling asleep
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(!human_user.wash_hands(CLEAN_WASH))
			to_chat(user, span_warning("Your hands are covered by something!"))
			return
	else
		user.wash(CLEAN_WASH)

	user.visible_message(span_notice("[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src]."), \
						span_notice("You wash your [washing_face ? "face" : "hands"] using [src]."))

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return

	if(istype(O, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = O
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				RG.reagents.add_reagent(dispensedreagent, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, span_notice("You fill [RG] from [src]."))
				return TRUE
			to_chat(user, span_notice("\The [RG] is full."))
			return FALSE

	if(istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.cell && B.cell.charge && B.turned_on)
			flick("baton_active", src)
			user.Paralyze(B.stun_time)
			user.stuttering = B.stun_time/20
			B.deductcharge(B.cell_hit_cost)
			user.visible_message(span_warning("[user] shocks [user.p_them()]self while attempting to wash the active [B.name]!"), \
								span_userdanger("You unwisely attempt to wash [B] while it's still on."))
			playsound(src, B.stun_sound, 50, TRUE)
			return

	if(istype(O, /obj/item/mop))
		O.reagents.add_reagent(dispensedreagent, 5)
		to_chat(user, span_notice("You wet [O] in [src]."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		new /obj/item/reagent_containers/cup/rag(src.loc)
		to_chat(user, span_notice("You tear off a strip of gauze and make a rag."))
		G.use(1)
		return

	if(!istype(O))
		return
	if(O.item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(!user.combat_mode)
		to_chat(user, "<span class='notice'>You start washing [O]...</span>")
		busy = TRUE
		if(!do_after(user, 40, target = src))
			busy = FALSE
			return 1
		busy = FALSE
		O.wash(CLEAN_WASH)
		reagents.expose(O, TOUCH, 5 / max(reagents.total_volume, 5))
		user.visible_message(span_notice("[user] washes [O] using [src]."), \
							span_notice("You wash [O] using [src]."))
		return 1
	else
		return ..()

/obj/structure/sink/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron (loc, 3)
	qdel(src)


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	desc = "A puddle used for washing one's hands and face."
	icon_state = "puddle"
	resistance_flags = UNACIDABLE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/deconstruct(disassembled = TRUE)
	qdel(src)


//Shower Curtains//
//Defines used are pre-existing in layers.dm//


/obj/structure/curtain
	name = "plastic curtain"
	desc = "Contains less than 1% mercury."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "bathroom-open"
	var/icon_type = "bathroom"//used in making the icon state
	color = "#ACD1E9" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	var/open = TRUE

/obj/structure/curtain/update_icon()
	if(!open)
		icon_state = "[icon_type]-closed"
		layer = WALL_OBJ_LAYER
		set_density(TRUE)
		set_opacity(TRUE)
		open = FALSE

	else
		icon_state = "[icon_type]-open"
		layer = SIGN_LAYER
		set_density(FALSE)
		set_opacity(FALSE)
		open = TRUE

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		color = tgui_color_picker(user,"","Choose Color",color)
	else
		return ..()

/obj/structure/curtain/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 50)
	return TRUE

/obj/structure/curtain/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return TRUE

	user.visible_message(span_warning("[user] cuts apart [src]."),
		span_notice("You start to cut apart [src]."), "You hear cutting.")
	if(I.use_tool(src, user, 50, volume=100) && !anchored)
		to_chat(user, span_notice("You cut apart [src]."))
		deconstruct()

	return TRUE


/obj/structure/curtain/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	toggle(user)

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cotton/cloth (loc, 2)
	new /obj/item/stack/sheet/plastic (loc, 2)
	new /obj/item/stack/rods (loc, 1)
	qdel(src)

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, 1)

/obj/structure/curtain/bounty
	icon_type = "bounty"
	icon_state = "bounty-open"
	color = null
	alpha = 255

/obj/structure/curtain/proc/toggle(mob/M)
	if (check(M))
		open = !open
		playsound(loc, 'sound/effects/curtain.ogg', 50, 1)
		update_appearance()

/obj/structure/curtain/proc/check(mob/M)
	return TRUE

/obj/structure/curtain/directional
	icon_type = "bounty"
	icon_state = "bounty-open"
	color = null
	alpha = 255
	name = "window curtain"

/obj/structure/curtain/directional/check(mob/M)
	if (get_dir(src, M) & dir)
		return TRUE
	else
		return FALSE
