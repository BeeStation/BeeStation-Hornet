//Chairs, but as an item

/obj/item/chair
	name = "chair"
	desc = "Basic brawl essential."
	icon = 'icons/obj/beds_chairs/chairs.dmi'
	icon_state = "chair_toppled"
	inhand_icon_state = "chair"
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ISWEAPON
	force = 8
	throwforce = 10

	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	custom_materials = list(/datum/material/iron = 2000)
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src,hitsound,50,1)
	return BRUTELOSS

/obj/item/chair/narsie_act()
	var/obj/item/chair/wood/W = new/obj/item/chair/wood(get_turf(src))
	W.setDir(dir)
	qdel(src)

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	for(var/obj/A in get_turf(loc))
		if(istype(A, /obj/structure/chair))
			to_chat(user, span_danger("There is already a chair here."))
			return
		if(A.density && !(A.flags_1 & ON_BORDER_1))
			to_chat(user, span_danger("There is already something here."))
			return

	user.visible_message(span_notice("[user] rights \the [src.name]."), span_notice("You right \the [name]."))
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.set_custom_materials(custom_materials)
	TransferComponents(C)
	C.setDir(dir)
	qdel(src)

/obj/item/chair/proc/smash(mob/living/user)
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically disappears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	else if(custom_materials[SSmaterials.GetMaterialRef(/datum/material/iron)])
		new /obj/item/stack/rods(get_turf(loc), 2)
	qdel(src)

/obj/item/chair/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(prob(break_chance))
		user.visible_message(span_danger("[user] smashes \the [src] to pieces against \the [target]"))
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(C.health < C.maxHealth*0.5)
				C.Paralyze(20)
		smash(user)

/obj/item/chair/fancy
	name = "fancy chair"
	desc = "Meeting brawl essential."
	icon_state = "chair_fancy_toppled"
	inhand_icon_state = "chair_fancy"
	hitsound = 'sound/items/trayhit2.ogg'
	custom_materials = list(/datum/material/iron = 3000)
	origin_type = /obj/structure/chair/fancy

/obj/item/chair/greyscale
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	origin_type = /obj/structure/chair/greyscale

/obj/item/chair/stool
	name = "stool"
	desc = "The last line of defense."
	icon_state = "stool_toppled"
	inhand_icon_state = "stool"
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	desc = "Bar brawl essential."
	icon_state = "bar_toppled"
	inhand_icon_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/bamboo
	name = "bamboo stool"
	desc = "The apex of the bar brawl experience."
	icon_state = "bamboo_stool_toppled"
	inhand_icon_state = "stool_bamboo"
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/stool/bamboo
	custom_materials = null
	break_chance = 50	//Submissive and breakable unlike the chad iron stool

/obj/item/chair/stool/narsie_act()
	return //sturdy enough to ignore a god

/obj/item/chair/wood
	name = "wooden chair"
	desc = "Fancy brawl essential."
	icon_state = "wooden_chair_toppled"
	inhand_icon_state = "woodenchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	custom_materials = null
	break_chance = 50

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	name = "winged wooden chair"
	desc = "First class brawl essential."
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/item/chair/plastic
	name = "plastic chair"
	desc = "Be the reclaimer of your name." //bury the light deep withiiiiiiiiiiiiiiiiin
	icon_state = "plastic_chair_toppled"
	inhand_icon_state = "plastic_chair"
	force = 3//have you ever been hit by a plastic chair? those aren't as bad as a metal or a wood one!
	throwforce = 6

	throw_range = 4
	origin_type = /obj/structure/chair/fancy/plastic
	hitsound = 'sound/weapons/genhit1.ogg'
	custom_materials = list(/datum/material/plastic = 2000)//duh
	break_chance = 15 //Submissive and breakable, but can handle an angry demon

/obj/item/chair/plastic/narsie_act()
	return

/obj/item/chair/foldable
	name = "folding chair"
	desc = "Somehow, you can always find one under the wrestling ring."
	icon_state = "chair_foldable_toppled" //for convenience sake
	lefthand_file = 'icons/mob/inhands/misc/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 7
	break_chance = 25
	origin_type = /obj/structure/chair/foldable

/obj/item/chair/foldable/narsie_act()
	return
