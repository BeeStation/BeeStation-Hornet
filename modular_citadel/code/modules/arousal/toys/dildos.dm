//////////
//DILDOS//
//////////
/obj/item/dildo
	name 				= "dildo"
	desc 				= "Floppy!"
	icon 				= 'modular_citadel/icons/obj/genitals/dildo.dmi'
	force 				= 0
	hitsound			= 'sound/weapons/tap.ogg'
	throwforce			= 0
	icon_state 			= "dildo_knotted_2"
	alpha 				= 192//transparent
	var/can_customize	= FALSE
	var/dildo_shape 	= "human"
	var/dildo_size		= 2
	var/dildo_type		= "dildo"//pretty much just used for the icon state
	var/random_color 	= TRUE
	var/random_size 	= FALSE
	var/random_shape 	= FALSE
	var/is_knotted		= FALSE
	//Lists moved to _cit_helpers.dm as globals so they're not instanced individually

/obj/item/dildo/proc/update_appearance()
	icon_state = "[dildo_type]_[dildo_shape]_[dildo_size]"
	var/sizeword = ""
	switch(dildo_size)
		if(1)
			sizeword = "small "
		if(3)
			sizeword = "big "
		if(4)
			sizeword = "huge "
		if(5)
			sizeword = "gigantic "

	name = "[sizeword][dildo_shape] [can_customize ? "custom " : ""][dildo_type]"

/obj/item/dildo/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	customize(user)
	return TRUE

/obj/item/dildo/proc/customize(mob/living/user)
	if(!can_customize)
		return FALSE
	if(src && !user.incapacitated() && in_range(user,src))
		var/color_choice = input(user,"Choose a color for your dildo.","Dildo Color") as null|anything in GLOB.dildo_colors
		if(src && color_choice && !user.incapacitated() && in_range(user,src))
			sanitize_inlist(color_choice, GLOB.dildo_colors, "Red")
			color = GLOB.dildo_colors[color_choice]
	update_appearance()
	if(src && !user.incapacitated() && in_range(user,src))
		var/shape_choice = input(user,"Choose a shape for your dildo.","Dildo Shape") as null|anything in GLOB.dildo_shapes
		if(src && shape_choice && !user.incapacitated() && in_range(user,src))
			sanitize_inlist(shape_choice, GLOB.dildo_colors, "Knotted")
			dildo_shape = GLOB.dildo_shapes[shape_choice]
	update_appearance()
	if(src && !user.incapacitated() && in_range(user,src))
		var/size_choice = input(user,"Choose the size for your dildo.","Dildo Size") as null|anything in GLOB.dildo_sizes
		if(src && size_choice && !user.incapacitated() && in_range(user,src))
			sanitize_inlist(size_choice, GLOB.dildo_colors, "Medium")
			dildo_size = GLOB.dildo_sizes[size_choice]
	update_appearance()
	if(src && !user.incapacitated() && in_range(user,src))
		var/transparency_choice = input(user,"Choose the transparency of your dildo. Lower is more transparent!(192-255)","Dildo Transparency") as null|num
		if(src && transparency_choice && !user.incapacitated() && in_range(user,src))
			sanitize_integer(transparency_choice, 192, 255, 192)
			alpha = transparency_choice
	update_appearance()
	return TRUE

/obj/item/dildo/Initialize()
	. = ..()
	if(random_color == TRUE)
		var/randcolor = pick(GLOB.dildo_colors)
		color = GLOB.dildo_colors[randcolor]
	if(random_shape == TRUE)
		var/randshape = pick(GLOB.dildo_shapes)
		dildo_shape = GLOB.dildo_shapes[randshape]
	if(random_size == TRUE)
		var/randsize = pick(GLOB.dildo_sizes)
		dildo_size = GLOB.dildo_sizes[randsize]
	update_appearance()
	alpha		= rand(192, 255)
	pixel_y 	= rand(-7,7)
	pixel_x 	= rand(-7,7)

/obj/item/dildo/examine(mob/user)
	. = ..()
	if(can_customize)
		. += "<span class='notice'>Alt-Click \the [src.name] to customize it.</span>"

/obj/item/dildo/random//totally random
	name 				= "random dildo"//this name will show up in vendors and shit so you know what you're vending(or don't, i guess :^))
	random_color 		= TRUE
	random_shape 		= TRUE
	random_size 		= TRUE

/obj/item/dildo/knotted
	dildo_shape 		= "knotted"
	name 				= "knotted dildo"
	attack_verb 		= list("penetrated", "knotted", "slapped", "inseminated")

obj/item/dildo/human
	dildo_shape 		= "human"
	name 				= "human dildo"
	attack_verb = list("penetrated", "slapped", "inseminated")

obj/item/dildo/plain
	dildo_shape 		= "plain"
	name 				= "plain dildo"
	attack_verb 		= list("penetrated", "slapped", "inseminated")

obj/item/dildo/flared
	dildo_shape 		= "flared"
	name 				= "flared dildo"
	attack_verb 		= list("penetrated", "slapped", "neighed", "gaped", "prolapsed", "inseminated")

obj/item/dildo/flared/huge
	name 				= "literal horse cock"
	desc 				= "THIS THING IS HUGE!"
	dildo_size 			= 4

obj/item/dildo/custom
	name 				= "customizable dildo"
	desc 				= "Thanks to significant advances in synthetic nanomaterials, this dildo is capable of taking on many different forms to fit the user's preferences! Pricy!"
	can_customize		= TRUE
	random_color 		= TRUE
	random_shape 		= TRUE
	random_size 		= TRUE

// Suicide acts, by request

/obj/item/dildo/proc/manual_suicide(mob/living/user)
		user.visible_message("<span class='suicide'>[user] finally finishes deepthroating the [src], and their life.</span>")
		user.adjustOxyLoss(200)
		user.death(0)

/obj/item/dildo/suicide_act(mob/living/user)
//	is_knotted = ((src.dildo_shape == "knotted")?"They swallowed the knot":"Their face is turning blue")
	if(do_after(user,17,target=src))
		user.visible_message("<span class='suicide'>[user] tears-up and gags as they shove [src] down their throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(loc, 'sound/weapons/gagging.ogg', 50, 1, -1)
		user.Stun(150)
		user.adjust_blurriness(8)
		var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
		eyes?.applyOrganDamage(10)
	return MANUAL_SUICIDE

/obj/item/dildo/flared/huge/suicide_act(mob/living/user)
	if(do_after(user,35,target=src))
		user.visible_message("<span class='suicide'>[user] tears-up and gags as they try to deepthroat the [src]! WHY WOULD THEY DO THAT? It looks like [user.p_theyre()] trying to commit suicide!!</span>")
		playsound(loc, 'sound/weapons/gagging.ogg', 50, 2, -1)
		user.Stun(300)
		user.adjust_blurriness(8)
	return MANUAL_SUICIDE

