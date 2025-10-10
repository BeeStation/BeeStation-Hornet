/*****************************Coin********************************/

// The coin's value is a value of it's materials.
// Yes, the gold standard makes a come-back!
// This is the only way to make coins that are possible to produce on station actually worth anything.

//YOU WISH the comment above was right!

/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin"
	flags_1 = CONDUCT_1
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = 400)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cooldown = 0
	var/value
	var/coinflip

/obj/item/coin/Initialize(mapload)
	. = ..()
	coinflip = pick(sideslist)
	icon_state = "coin_[coinflip]"
	pixel_x = base_pixel_x + rand(0, 16) - 8
	pixel_y = base_pixel_y + rand(0, 8) - 8

/obj/item/coin/set_custom_materials(list/materials, multiplier = 1)
	. = ..()
	value = 0
	for(var/i in custom_materials)
		var/datum/material/M = i
		value += M.value_per_unit * custom_materials[M]

/obj/item/coin/get_item_credit_value()
	return value

/obj/item/coin/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] contemplates suicide with \the [src]!"))
	if (!attack_self(user))
		user.visible_message(span_suicide("[user] couldn't flip \the [src]!"))
		return SHAME
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 10)//10 = time takes for flip animation
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index == 2)//tails
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] promptly falls over, dead!"))
		user.adjustOxyLoss(200)
		user.death(FALSE)
		user.set_suicide(TRUE)
		user.suicide_log()
	else
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] keeps on living!"))

/obj/item/coin/examine(mob/user)
	. = ..()
	. += span_info("It's worth [value] credit\s.")

/obj/item/coin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, span_warning("There already is a string attached to this coin!"))
			return

		if (CC.use(1))
			add_overlay("coin_string_overlay")
			string_attached = 1
			to_chat(user, span_notice("You attach a string to the coin."))
		else
			to_chat(user, span_warning("You need one length of cable to attach a string to the coin!"))
			return
	else
		..()

/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	if(!string_attached)
		return TRUE

	new /obj/item/stack/cable_coil(drop_location(), 1)
	overlays = list()
	string_attached = null
	to_chat(user, span_notice("You detach the string from the coin."))
	return TRUE

/obj/item/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, span_warning("The coin won't flip very well with something attached!") )
			return FALSE//do not flip the coin
		cooldown = world.time + 15
		flick("coin_[coinflip]_flip", src)
		coinflip = pick(sideslist)
		icon_state = "coin_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
							span_notice("You flip [src]. It lands on [coinflip]."), \
							span_italics("You hear the clattering of loose change."))
	return TRUE//did the coin flip? useful for suicide_act

/obj/item/coin/gold
	custom_materials = list(/datum/material/gold = 400)

/obj/item/coin/silver
	custom_materials = list(/datum/material/silver = 400)

/obj/item/coin/diamond
	custom_materials = list(/datum/material/diamond = 400)

/obj/item/coin/plasma
	custom_materials = list(/datum/material/plasma = 400)

/obj/item/coin/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/item/coin/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
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
	custom_materials = list(/datum/material/uranium = 400)

/obj/item/coin/titanium
	custom_materials = list(/datum/material/titanium = 400)

/obj/item/coin/bananium
	custom_materials = list(/datum/material/bananium = 400)

/obj/item/coin/adamantine
	custom_materials = list(/datum/material/adamantine = 400)

/obj/item/coin/mythril
	custom_materials = list(/datum/material/plastic = 400)// cause we dont have mythril as a material, yet for some reason mappers like using this coin
//	custom_materials = list(/datum/material/mythril = 400)

/obj/item/coin/plastic
	custom_materials = list(/datum/material/plastic = 400)

///obj/item/coin/runite
//	custom_materials = list(/datum/material/runite = 400)

/obj/item/coin/twoheaded
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")

/obj/item/coin/antagtoken
	name = "antag token"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	icon_state = "coin_valid"
	custom_materials = list(/datum/material/plastic = 400)
	sideslist = list("valid", "salad")
	material_flags = NONE
	max_demand = 10
	custom_premium_price = 150

/obj/item/coin/arcade_token
	name = "arcade token"
	custom_materials = list(/datum/material/bananium = 400)
	desc = "A coin that allows you to redeem a prize from an arcade machine."
	value = 0

/obj/item/coin/iron
