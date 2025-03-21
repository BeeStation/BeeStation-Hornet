/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	target.heal_overall_damage(50, 50, 50)
	target.adjustToxLoss(-50, forced = TRUE)

/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/afterattack(atom/target, mob/user, prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/H = target
	if(H.stat == DEAD)
		to_chat(user, span_warning("[src] will not work on the dead!"))
		return
	if(!do_after(user, 5 SECONDS, H))
		to_chat(user, span_notice("You need to hold still to apply [src]!"))
		return
	if(H != user)
		user.visible_message(span_notice("[user] crushes the [src] over [H], the milky goo quickly regenerating all of [H.p_their()] injuries!"),
			span_notice("You squeeze the [src], and it bursts over [H], the milky goo regenerating [H.p_their()] injuries."))
	else
		user.visible_message(span_notice("[user] crushes the [src] over [user.p_them()]self, the milky goo quickly regenerating all of [user.p_their()] injuries!"),
			span_notice("You squeeze the [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!"))
	core_effect_before(H, user)
	core_effect(H, user)
	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	qdel(src)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.
	effect_desc = "Heals the target and does nothing else."

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message(span_warning("The [src] boils over!"))
	for(var/turf/open/turf in RANGE_TURFS(1,target))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

/obj/item/slimecross/regenerative/purple
	colour = "purple"
	effect_desc = "Fully heals the target and injects them with some regen jelly."

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	..()
	target.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)

/obj/item/slimecross/regenerative/blue
	colour = "blue"
	effect_desc = "Heals the target and makes the floor wet."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	..()
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message(span_warning("The milky goo in the extract gets all over the floor!"))

/obj/item/slimecross/regenerative/metal
	colour = "metal"
	effect_desc = "Heals the target and encases the target in a locker."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	..()
	target.visible_message(span_warning("The milky goo hardens and reshapes itself, encasing [target]!"))
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"
	effect_desc = "Heals the target and fully recharges a single item on the target."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	..()
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, span_notice("You feel a strange electrical pulse, and one of your electrical items was recharged."))

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"
	effect_desc = "Heals the target and gives them purple clothing if they are naked."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	..()
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message(span_notice("The milky goo congeals into clothing!"))

/obj/item/slimecross/regenerative/darkblue
	colour = "dark blue"
	effect_desc = "Heals the target and fireproofs their clothes."

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		fireproof(C)
	if(H.get_item_by_slot(ITEM_SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message(span_notice("Some of [target]'s clothing gets coated in the goo, and turns blue!"))

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = "silver"
	effect_desc = "Heals the target and makes their belly feel round and full."

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	..()
	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	to_chat(target, span_notice("You feel satiated."))

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	effect_desc = "Heals the target and teleports them to where this core was created."
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	..()
	target.visible_message(span_warning("[src] disappears in a shower of sparks!"),span_danger("The milky goo teleports you somewhere it remembers!"))
	do_teleport(target, T, effectin = new /datum/effect_system/spark_spread, effectout = new /datum/effect_system/spark_spread, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = "sepia"
	effect_desc = "Heals the target and stops time."

/obj/item/slimecross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, span_notice("You try to forget how you feel."))
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"
	effect_desc = "Heals the target and makes a second regenerative core with no special effects."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	..()
	forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, span_notice("Some of the milky goo congeals in your hand!"))

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"
	effect_desc = "Heals and randomly colors the target."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	..()
	target.visible_message(span_warning("The milky goo coating [target] leaves [target.p_them()] a different color!"))
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"
	effect_desc = "Heals the target and injects them with some ephedrine."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	..()
	to_chat(target, span_notice("You feel... <i>faster.</i>"))
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = "green"
	effect_desc = "Heals the target and changes the species or color of a slime or jellyperson."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	..()
	if(isslime(target))
		target.visible_message(span_warning("The [target] suddenly changes color!"))
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()
	if(isoozeling(target))
		target.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly,5)


/obj/item/slimecross/regenerative/pink
	colour = "pink"
	effect_desc = "Heals the target and injects them with some krokodil."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	..()
	to_chat(target, span_notice("You feel more calm."))
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"
	effect_desc = "Heals the target and produces a random coin."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	..()
	var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, 1)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = "oil"
	effect_desc = "Heals the target and flashes everyone in sight."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	..()
	playsound(src, 'sound/weapons/flash.ogg', 100, 1)
	for(var/mob/living/L in viewers(7, user))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = "black"
	effect_desc = "Heals the target and creates a duplicate of them, that drops dead soon after."

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, span_notice("The milky goo flows from your skin, forming an imperfect copy of you."))
	if(iscarbon(target))
		var/mob/living/carbon/T = target
		var/mob/living/carbon/D = dummy
		T.dna.transfer_identity(D)
		D.updateappearance(mutcolor_update=1)
		D.real_name = T.real_name
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.adjustOxyLoss(200)
	//Force death just in case
	dummy.death()

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"
	effect_desc = "Heals the target and also heals the user."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	..()
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.heal_overall_damage(50, 50, 50)
	U.adjustToxLoss(-50, forced = TRUE)
	to_chat(U, span_notice("Some of the milky goo sprays onto you, as well!"))

/obj/item/slimecross/regenerative/adamantine
	colour = "adamantine"
	effect_desc = "Heals the target and boosts their armor."

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	..()
	target.apply_status_effect(/datum/status_effect/slimeskin)

/obj/item/slimecross/regenerative/rainbow
	colour = "rainbow"
	effect_desc = "Heals the target and temporarily makes them immortal, but pacifistic."

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	..()
	target.apply_status_effect(/datum/status_effect/rainbow_protection)
