/*****************************Coin********************************/

// The coin's value is a value of it's materials.
// Yes, the gold standard makes a come-back!
// This is the only way to make coins that are possible to produce on station actually worth anything.

//YOU WISH the comment above was right!

/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags_1 = CONDUCT_1
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/value = 1
	var/coinflip

/obj/item/coin/get_item_credit_value()
	return value

/obj/item/coin/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] contemplates suicide with \the [src]!</span>")
	if (!attack_self(user))
		user.visible_message("<span class='suicide'>[user] couldn't flip \the [src]!</span>")
		return SHAME
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 10)//10 = time takes for flip animation
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index==2)//tails
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] promptly falls over, dead!</span>")
		user.adjustOxyLoss(200)
		user.death(0)
		user.set_suicide(TRUE)
		user.suicide_log()
	else
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] keeps on living!</span>")

/obj/item/coin/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x +  rand(0,16) - 8
	pixel_y = base_pixel_y + rand(0,8) - 8

/obj/item/coin/examine(mob/user)
	. = ..()
	if(value)
		. += "<span class='info'>It's worth [value] credit\s.</span>"

/obj/item/coin/gold
	name = "gold coin"
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	value = 25
	materials = list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/gold = 4)

/obj/item/coin/silver
	name = "silver coin"
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	value = 10
	materials = list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/silver = 4)

/obj/item/coin/diamond
	name = "diamond coin"
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	value = 100
	materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/carbon = 4)

/obj/item/coin/iron
	name = "iron coin"
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	value = 1
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/iron = 4)

/obj/item/coin/plasma
	name = "plasma coin"
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	value = 40
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/toxin/plasma = 4)

/obj/item/coin/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		plasma_ignition(0)


/obj/item/coin/plasma/bullet_act(obj/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		plasma_ignition(0, Proj?.firer)
	. = ..()

/obj/item/coin/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		plasma_ignition(0, user)
	else
		return ..()

/obj/item/coin/uranium
	name = "uranium coin"
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	value = 25
	materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/uranium = 4)

/obj/item/coin/bananium
	name = "bananium coin"
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	value = 200 //makes the clown cry
	materials = list(/datum/material/bananium = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/consumable/banana = 4)

/obj/item/coin/adamantine
	name = "adamantine coin"
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	value = 100

/obj/item/coin/mythril
	name = "mythril coin"
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	value = 300

/obj/item/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.2)
	value = 1
	grind_results = list(/datum/reagent/iron = 4)

/obj/item/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	value = 0
	grind_results = list(/datum/reagent/consumable/sodiumchloride = 4)

/obj/item/coin/arcade_token
	name = "arcade token"
	icon_state = "coin_bananium_heads"
	cmineral = "bananium"
	desc = "A coin that allows you to redeem a prize from an arcade machine."
	value = 0

/obj/item/coin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='warning'>There already is a string attached to this coin!</span>")
			return

		if (CC.use(1))
			add_overlay("coin_string_overlay")
			string_attached = 1
			to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of cable to attach a string to the coin!</span>")
			return
	else
		..()

/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	if(!string_attached)
		return TRUE

	new /obj/item/stack/cable_coil(drop_location(), 1)
	overlays = list()
	string_attached = null
	to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	return TRUE

/obj/item/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, "<span class='warning'>The coin won't flip very well with something attached!</span>" )
			return FALSE//do not flip the coin
		coinflip = pick(sideslist)
		cooldown = world.time + 15
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
							 "<span class='italics'>You hear the clattering of loose change.</span>")
	return TRUE//did the coin flip? useful for suicide_act


