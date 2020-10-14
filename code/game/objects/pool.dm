//Simple pool behaviour. Sprites by Cdey!

/**
How to pool!
Place pool turfs on the inside of your pool. This is where you swim. Pool end caps to cap it off on the north face
Place pool border decals around the pool so it doesn't look weird
Place a pool ladder at the top of the pool so that it leads to a normal tile (or else it'll be hard to get out of the pool.)
Place a pool filter somewhere in the pool if you want people to be able to modify the pool's settings (Temperature) or dump reagents into the pool (which'll change the pool's colour)
*/
//So you don't get to run at /tg/ movespeed in a pool and SPAM SPLOSH!
#define MOVESPEED_ID_SWIMMING "SWIMMING_SPEED_MOD"

//Component used to show that a mob is swimming, and force them to swim a lil' bit slower. Components are actually really based!

/datum/component/swimming
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/lengths = 0 //How far have we swum?
	var/lengths_for_bonus = 25 //If you swim this much, you'll count as having "excercised" and thus gain a buff.

/datum/component/swimming/Initialize()
	. = ..()
	if(!isliving(parent))
		message_admins("Swimming component erroneously added to a non-living mob ([parent]).")
		return INITIALIZE_HINT_QDEL //Only mobs can swim, like Ian...
	var/mob/M = parent
	M.visible_message("<span class='notice'>[parent] starts splashing around in the water!</span>")
	M.add_movespeed_modifier(MOVESPEED_ID_SWIMMING, update=TRUE, priority=50, multiplicative_slowdown=4, movetypes=GROUND)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/onMove)

/datum/component/swimming/proc/onMove()
	lengths ++
	if(lengths > lengths_for_bonus)
		var/mob/living/L = parent
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		L.apply_status_effect(STATUS_EFFECT_EXERCISED) //Swimming is really good excercise!
		lengths = 0

/datum/component/swimming/UnregisterFromParent()
	var/mob/M = parent
	M.remove_movespeed_modifier(MOVESPEED_ID_SWIMMING)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/effect/overlay/poolwater
	name = "Pool water"
	icon = 'icons/obj/pool.dmi'
	icon_state = "water"
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/turf/open/indestructible/sound/pool
	name = "Swimming pool"
	desc = "A fun place where you go to swim! <b>Drag and drop yourself onto it to climb in...</b>"
	icon = 'icons/obj/pool.dmi'
	icon_state = "pool"
	sound = 'sound/effects/splash.ogg'
	var/id = null //Set me if you don't want the pool and the pump to be in the same area, or you have multiple pools per area.
	var/obj/effect/water_overlay = null

/turf/open/indestructible/sound/pool/end
	icon_state = "poolwall"

/turf/open/indestructible/sound/pool/Initialize(mapload)
	. = ..()
	water_overlay = new /obj/effect/overlay/poolwater(src)
	add_overlay(water_overlay)

/turf/open/indestructible/sound/pool/proc/set_colour(colour)
	cut_overlay(water_overlay)
	water_overlay.color = colour
	add_overlay(water_overlay)

/turf/open/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //If you're swimming around, you don't really want to stop swimming just like that do you?
	if(S)
		return FALSE //If you're swimming, you can't swim into a regular turf, y'dig?
	. = ..()

/turf/open/indestructible/sound/pool/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
	return (isliving(mover)) ? S : ..() //So you can do stuff like throw beach balls around the pool!

/turf/open/indestructible/sound/pool/Entered(atom/movable/AM)
	. = ..()
	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	if(isliving(AM))
		var/datum/component/swimming/S = AM.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
		if(!S)
			AM.AddComponent(/datum/component/swimming)

/turf/open/indestructible/sound/pool/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(!istype(newloc, /turf/open/indestructible/sound/pool))
		var/datum/component/swimming/S = Obj.GetComponent(/datum/component/swimming) //Handling admin TPs here.
		S?.RemoveComponent()

/turf/open/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/atom/movable/AM = dropping
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming)
	if(S)
		if(do_after(user, 1 SECONDS, target=src))
			S.RemoveComponent()
			visible_message("<span class='notice'>[dropping] climbs out of the pool.</span>")
			AM.forceMove(src)
	else
		. = ..()

/turf/open/indestructible/sound/pool/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming) //If they're already swimming, don't let them start swimming again.
	if(S)
		return FALSE
	. = ..()
	if(user != dropping)
		dropping.visible_message("<span class='notice'>[user] starts to lower [dropping] down into [src].</span>", \
		 "<span class='notice'>You start to lower [dropping] down into [src].</span>")
	else
		to_chat(user, "<span class='notice'>You start climbing down into [src]...")
	if(do_after(user, 4 SECONDS, target=src))
		splash(dropping)

/datum/mood_event/poolparty
	description = "<span class='nicegreen'>I love swimming!.</span>\n"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/robotpool
	description = "<span class='warning'>I really wasn't built with water resistance in mind...</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/poolwet
	description = "<span class='warning'>Eugh! my clothes are soaking wet from that swim.</span>\n"
	mood_change = -4
	timeout = 4 MINUTES

/turf/open/indestructible/sound/pool/proc/splash(mob/user)
	user.forceMove(src)
	playsound(src, 'sound/effects/splosh.ogg', 100, 1) //Credit to hippiestation for this sound file!
	user.visible_message("<span class='boldwarning'>SPLASH!</span>")
	var/zap = FALSE
	if(issilicon(user)) //Do not throw brick in a pool. Brick begs.
		zap = TRUE //Sorry borgs! Swimming will come at a cost.
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		var/datum/species/SS = F.dna.species
		if(MOB_ROBOTIC in SS.inherent_biotypes)  //ZAP goes the IPC!
			zap = 2 //You can protect yourself from water damage with thick clothing.
		if(F.head && istype(F.head, /obj/item/clothing))
			var/obj/item/clothing/CH = F.head
			if (CH.clothing_flags & THICKMATERIAL) //Skinsuit should suffice! But IPCs are robots and probably not water-sealed.
				zap --
		if(F.wear_suit && istype(F.wear_suit, /obj/item/clothing))
			var/obj/item/clothing/CS = F.wear_suit
			if (CS.clothing_flags & THICKMATERIAL)
				zap --
	if(zap > 0)
		user.emp_act(zap)
		user.emote("scream") //Chad coders use M.say("*scream")
		do_sparks(zap, TRUE, user)
		to_chat(user, "<span class='userdanger'>WARNING: WATER DAMAGE DETECTED!</span>")
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "robotpool", /datum/mood_event/robotpool)
	else
		if(!check_clothes(user))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolparty)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolwet)

//Largely a copypaste from shower.dm. Checks if the mob was stupid enough to enter a pool fully clothed. We allow masks as to not discriminate against clown and mime players.
/turf/open/indestructible/sound/pool/proc/check_clothes(mob/living/carbon/human/H)
	if(!istype(H)) //Don't care about non humans.
		return FALSE
	if(H.wear_suit && (H.wear_suit.clothing_flags & SHOWEROKAY))
		// Do not check underclothing if the over-suit is suitable.
		// This stops people feeling dumb if they're showering
		// with a radiation suit on.
		return FALSE

	. = FALSE
	if(H.wear_suit && !(H.wear_suit.clothing_flags & SHOWEROKAY))
		. = TRUE
	else if(H.w_uniform && !(H.w_uniform.clothing_flags & SHOWEROKAY))
		. = TRUE
	else if(H.head && !(H.head.clothing_flags & SHOWEROKAY))
		. = TRUE

/obj/effect/turf_decal/pool
	name = "Pool siding"
	icon = 'icons/obj/pool.dmi'
	icon_state = "poolborder"

/obj/effect/turf_decal/pool/corner
	icon_state = "bordercorner"

/obj/effect/turf_decal/pool/innercorner
	icon_state = "innercorner"

//Pool machinery

/obj/structure/pool_ladder
	name = "Pool ladder"
	desc = "Click this to get out of a pool quickly."
	icon = 'icons/obj/pool.dmi'
	icon_state = "ladder"
	pixel_y = 12

/obj/machinery/pool_filter
	name = "Pool filter"
	desc = "A device which can help you regulate conditions in a pool. Use a <b>wrench</b> to change its operating temperature, or hit it with a reagent container to load in new liquid to add to the pool."
	icon = 'icons/obj/pool.dmi'
	icon_state = "poolfilter"
	pixel_y = 12 //So it sits above the water
	idle_power_usage = IDLE_POWER_USE
	var/id = null //change this if youre an annoying mapper who wants multiple pools per area.
	var/list/pool = list()
	var/desired_temperature = 300 //Room temperature
	var/current_temperature = 300 //current temp
	var/preset_reagent_type = null //Set this if you want your pump to start filled with a given reagent. SKEWIUM POOL SKEWIUM POOL!

/obj/machinery/pool_filter/examine(mob/user)
	. = ..()
	. += "<span class='boldnotice'>The thermostat on it reads [current_temperature].</span>"

/obj/machinery/pool_filter/Initialize()
	. = ..()
	create_reagents(100, OPENCONTAINER) //If you're a terrible terrible clown and want to dump reagents into the pool.
	if(preset_reagent_type)
		reagents.add_reagent(preset_reagent_type, 100)
	var/area/AR = get_area(src)
	for(var/turf/open/indestructible/sound/pool/water in get_area_turfs(AR))
		if(!istype(water))
			continue //Only affect pool turfs.
		if(id && water.id != id)
			continue //Not the same id. Fine. Ignore that one then!
		pool += water

//Brick can set the pool to low temperatures remotely. This will probably be hell on malf!

/obj/machinery/pool_filter/attack_robot(mob/user)
	. = ..()
	wrench_act(user, null)

/obj/machinery/pool_filter/attack_ai(mob/user)
	. = ..()
	wrench_act(user, null)

/obj/machinery/pool_filter/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	var/newTemp = input(user, "Set a new temperature for [src] (Kelvin).", "[src]", null) as num
	if(!newTemp)
		return
	newTemp = CLAMP(newTemp, T0C, 320)
	desired_temperature = newTemp
	return FALSE

/obj/machinery/pool_filter/process()
	if(!pool?.len)
		return //No use having one of these processing for no reason is there?
	if(!is_operational())
		return
	use_power(idle_power_usage)
	var/delta = (current_temperature > desired_temperature) ? -0.5 : 0.5
	current_temperature += delta
	current_temperature = CLAMP(current_temperature, T0C, desired_temperature)
	var/trans_amount = reagents.total_volume / pool.len //Split up the reagents equally.
	for(var/turf/open/indestructible/sound/pool/water in pool)
		if(reagents.reagent_list.len)
			water.set_colour(mix_color_from_reagents(reagents.reagent_list))
		else
			water.set_colour("#009999")
		if(water.contents.len && reagents.total_volume > 0)
			for(var/mob/living/M in water)
				if(!istype(M))
					continue
				var/datum/reagents/splash_holder = new/datum/reagents(trans_amount) //Take some of our reagents out, react them with the pool denizens.
				splash_holder.my_atom = water
				reagents.trans_to(splash_holder, trans_amount, transfered_by = src)
				splash_holder.chem_temp = current_temperature
				if(prob(80))
					splash_holder.reaction(M, TOUCH)
				else //Sometimes the water penetrates a lil deeper than just a splosh.
					splash_holder.reaction(M, INGEST)
				qdel(splash_holder)
				var/mob/living/carbon/C = M
				if(current_temperature <= 283.5) //Colder than 10 degrees is going to make you very cold
					if(iscarbon(M))
						C.adjust_bodytemperature(-80, 80)
					to_chat(M, "<span class='warning'>The water is freezing cold!</span>")
				else if(current_temperature >= 308.5) //Hotter than 35 celsius is going to make you burn up
					if(iscarbon(M))
						C.adjust_bodytemperature(35, 0, 500)
					M.adjustFireLoss(5)
					to_chat(M, "<span class='danger'>The water is searing hot!</span>")

/obj/structure/pool_ladder/attack_hand(mob/user)
	var/datum/component/swimming/S = user.GetComponent(/datum/component/swimming)
	if(S)
		to_chat(user, "<span class='notice'>You start to climb out of the pool...</span>")
		if(do_after(user, 1 SECONDS, target=src))
			S.RemoveComponent()
			visible_message("<span class='notice'>[user] climbs out of the pool.</span>")
			user.forceMove(get_turf(get_step(src, NORTH))) //Ladders shouldn't adjoin another pool section. Ever.
	else
		to_chat(user, "<span class='notice'>You start to climb into the pool...</span>")
		var/turf/T = get_turf(src)
		if(do_after(user, 1 SECONDS, target=src))
			if(!istype(T, /turf/open/indestructible/sound/pool)) //Ugh, fine. Whatever.
				user.forceMove(get_turf(src))
			else
				var/turf/open/indestructible/sound/pool/P = T
				P.splash(user)

/obj/structure/pool_ladder/attack_robot(mob/user)
	. = ..()
	attack_hand(user)