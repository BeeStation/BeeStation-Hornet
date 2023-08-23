//NEVER USE THIS IT SUX	-PETETHEGOAT
//IT SUCKS A BIT LESS -GIACOM

/obj/item/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can be removed by the janitor."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "paint_neutral"
	var/paint_color = "FFFFFF"
	item_state = "paintcan"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/paintleft = 10

/obj/item/paint/red
	name = "red paint"
	paint_color = "C73232" //"FF0000"
	icon_state = "paint_red"

/obj/item/paint/green
	name = "green paint"
	paint_color = "2A9C3B" //"00FF00"
	icon_state = "paint_green"

/obj/item/paint/blue
	name = "blue paint"
	paint_color = "5998FF" //"0000FF"
	icon_state = "paint_blue"

/obj/item/paint/yellow
	name = "yellow paint"
	paint_color = "CFB52B" //"FFFF00"
	icon_state = "paint_yellow"

/obj/item/paint/violet
	name = "violet paint"
	paint_color = "AE4CCD" //"FF00FF"
	icon_state = "paint_violet"

/obj/item/paint/black
	name = "black paint"
	paint_color = "333333"
	icon_state = "paint_black"

/obj/item/paint/white
	name = "white paint"
	paint_color = "FFFFFF"
	icon_state = "paint_white"


/obj/item/paint/anycolor
	gender = PLURAL
	name = "adaptive paint"
	icon_state = "paint_neutral"

/obj/item/paint/anycolor/attack_self(mob/user)
	var/t1 = input(user, "Please select a color:", "[src]", null) in sort_list(list( "red", "blue", "green", "yellow", "violet", "black", "white"))
	if ((user.get_active_held_item() != src || user.stat || user.restrained()))
		return
	switch(t1)
		if("red")
			paint_color = "C73232"
		if("blue")
			paint_color = "5998FF"
		if("green")
			paint_color = "2A9C3B"
		if("yellow")
			paint_color = "CFB52B"
		if("violet")
			paint_color = "AE4CCD"
		if("white")
			paint_color = "FFFFFF"
		if("black")
			paint_color = "333333"
	icon_state = "paint_[t1]"
	add_fingerprint(user)


/obj/item/paint/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(paintleft <= 0)
		icon_state = "paint_empty"
		return
	if(!isturf(target) || isspaceturf(target))
		return
	var/newcolor = "#" + paint_color
	target.add_atom_colour(newcolor, WASHABLE_COLOUR_PRIORITY)

/obj/item/paint/paint_remover
	gender =  PLURAL
	name = "paint remover"
	desc = "Used to remove color from anything."
	icon_state = "paint_neutral"

/obj/item/paint/paint_remover/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isclothing(target) && HAS_TRAIT(target, TRAIT_SPRAYPAINTED) || target.color != initial(target.color))
		user.visible_message("[user] begins to clean \the [target.name] with [src]...", "<span class='notice'>You begin to clean \the [target.name] with [src]...</span>")
		if(!do_after(user, 10, target = target))
			to_chat(user, "<span class='notice'>You fail to clean \the [target.name]!.</span>")
			return
		to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
		if(isclothing(target) && HAS_TRAIT(target, TRAIT_SPRAYPAINTED))
			var/obj/item/clothing/C = target
			var/mob/living/carbon/human/H = user
			C.flash_protect -= 1
			C.tint -= 2
			H.update_tint()
			REMOVE_TRAIT(target, TRAIT_SPRAYPAINTED, CRAYON_TRAIT)
		if(istype(target, /obj/structure/window))
			target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			target.set_opacity(initial(target.opacity))
		if(target.color != initial(target.color))
			to_chat(user, "<span class='notice'>You clean \the [target.name].</span>")
			target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
