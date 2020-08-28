
/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Qwerty if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	can_atmos_pass = ATMOS_PASS_DENSITY
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/iron
	can_atmos_pass = ATMOS_PASS_DENSITY
	material_modifier = 0.5
	material_flags = MATERIAL_EFFECTS | MATERIAL_AFFECT_STATISTICS
	/// Beauty component mood modifier
	var/impressiveness = 15
	/// Art component subtype added to this statue
	var/art_type = /datum/element/art

/obj/structure/statue/Initialize(mapload)
	. = ..()
	AddElement(art_type, impressiveness)
	//AddElement(/datum/element/beauty, impressiveness * 75)
	AddComponent(/datum/component/simple_rotation)

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(default_unfasten_wrench(user, W))
			return
		if(W.tool_behaviour == TOOL_WELDER)
			if(!W.tool_start_check(user, amount=0))
				return FALSE

			user.visible_message("[user] is slicing apart the [name].", \
								span_notice("You are slicing apart the [name]..."))
			if(W.use_tool(src, user, 40, volume=50))
				user.visible_message("[user] slices apart the [name].", \
									span_notice("You slice apart the [name]!"))
				deconstruct(TRUE)
			return
	return ..()

/obj/structure/statue/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null
	impressiveness = 25 // radiation makes an impression

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "Statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/statue/uranium/Bumped(atom/movable/AM)
	radiate()
	..()

/obj/structure/statue/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	. = ..()

/obj/structure/statue/uranium/attack_paw(mob/user)
	radiate()
	. = ..()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(src, 30)
			last_event = world.time
			active = null
			return
	return

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "This statue is suitably made from plasma."
	impressiveness = 20

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

/obj/structure/statue/plasma/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 300

/obj/structure/statue/plasma/atmos_expose(datum/gas_mixture/air, exposed_temperature)
		plasma_ignition(6)


/obj/structure/statue/plasma/bullet_act(obj/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		plasma_ignition(6, Proj?.firer)
	. = ..()

/obj/structure/statue/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		plasma_ignition(6, user)
	else
		return ..()

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "This is a highly valuable statue made from gold."
	impressiveness = 25

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "This is a valuable statue made from silver."
	impressiveness = 25

/obj/structure/statue/silver/md
	name = "statue of a medical officer"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "This is a very expensive diamond statue."
	impressiveness = 50

/obj/structure/statue/diamond/captain
	name = "statue of THE captain."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core."
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	var/limiting_spam = FALSE
	impressiveness = 50

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/movable/AM)
	honk()
	..()

/obj/structure/statue/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/statue/bananium/attack_hand(mob/user, list/modifiers)
	honk()
	. = ..()

/obj/structure/statue/bananium/attack_paw(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!limiting_spam)
		limiting_spam = TRUE
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
		addtimer(VARSET_CALLBACK(src, limiting_spam, FALSE), 2 SECONDS)

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone
	impressiveness = 15

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"


/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/////////////////////snow/////////////////////////////////////////

/obj/structure/statue/snow
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/snow


/obj/structure/statue/snow/snowman
	name = "snowman"
	desc = "Several lumps of snow put together to form a snowman."
	icon_state = "snowman"

/obj/structure/statue/snow/snowlegion
	name = "snowlegion"
	desc = "Looks like that weird kid with the tiger plushie has been round here again."
	icon_state = "snowlegion"

//////////////////////////copper///////////////////////////////////////

/obj/structure/statue/copper
	max_integrity = 350
	material_drop_type = /obj/item/stack/sheet/mineral/copper
	desc = "This is a statue made from copper."

/obj/structure/statue/copper/dimas
	name = "statue of the quartermaster"
	desc = "This is a statue of the legendary Quartermaster, Lord of Cargonia the land of stolen things."
	max_integrity = 300
	icon_state = "dimas"
	oreAmount = 10 //dimas b dense
	impressiveness = -5 // A testament to one's pride isnt particularly impressive
