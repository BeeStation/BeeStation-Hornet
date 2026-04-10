/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *		Action Figure Boxes
 *		Various paper bags.
 *		Encrpytion key boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	w_class = WEIGHT_CLASS_MEDIUM
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	var/foldable = /obj/item/stack/sheet/cardboard
	var/illustration = "writing"
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'
	trade_flags = TRADE_NOT_SELLABLE | TRADE_DELETE_UNSOLD

/obj/item/storage/box/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 8
	atom_storage.max_total_storage = 8
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	update_icon()

/obj/item/storage/box/suicide_act(mob/living/carbon/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src], and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
		myhead.dismember()
		myhead.forceMove(src)//force your enemies to kill themselves with your head collection box!
		playsound(user,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	user.visible_message(span_suicide("[user] beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/box/update_overlays()
	. = ..()
	if(illustration)
		. += illustration

/obj/item/storage/box/attack_self(mob/user)
	..()

	if(!foldable || (flags_1 & HOLOGRAM_1))
		return
	if(contents.len)
		to_chat(user, span_warning("You can't fold this box with items still inside!"))
		return
	if(!ispath(foldable))
		return

	to_chat(user, span_notice("You fold [src] flat."))
	var/obj/item/I = new foldable
	qdel(src)
	user.put_in_hands(I)

/obj/item/storage/box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/package_wrap))
		return 0
	return ..()

//Locker overloading issue solving boxes
/obj/item/storage/box/suitbox
	name = "compression box of invisible outfits"
	desc = "a box with bluespace compression technology that nanotrasen has approved, but this is extremely heavy... If you're glued with this box, pull out of the contents and fold the box."
	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 4
	drag_slowdown = 4 // do not steal by dragging
	/* Note for the compression box:
		Do not put any box (or suit) into this box, or it will allow infinite storage.
		non-storage items are only legit for this box. (suits are storage too, so, no.)
		nor it will allow a glitch when you can access different boxes at the same time.
		examples exist in `closets/secure/security.dm` */

/obj/item/storage/box/suitbox/wardrobe // for `wardrobe.dm`
	name = "compression box of crew outfits"
	var/list/repeated_items = list( // just as a sample
		/obj/item/clothing/under/color/blue,
		/obj/item/clothing/under/color/jumpskirt/blue,
		/obj/item/clothing/shoes/sneakers/brown
	)
	var/max_repetition = 2

/obj/item/storage/box/suitbox/wardrobe/PopulateContents()
	for(var/i in 1 to max_repetition)
		for(var/O in repeated_items)
			new O(src)

//Mime spell boxes

/obj/item/storage/box/mime
	name = "invisible box"
	desc = "Unfortunately not large enough to trap the mime."
	foldable = null
	icon_state = "box"
	inhand_icon_state = null
	alpha = 0

/obj/item/storage/box/mime/attack_hand(mob/user, list/modifiers)
	..()
	if(HAS_MIND_TRAIT(user, TRAIT_MIMING))
		alpha = 255

/obj/item/storage/box/mime/Moved(oldLoc, dir)
	if (iscarbon(oldLoc))
		alpha = 0
	..()

//Disk boxes

/obj/item/storage/box/disks
	name = "diskette box"
	illustration = "disk_kit"

/obj/item/storage/box/disks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/data(src)


/obj/item/storage/box/disks_plantgene
	name = "plant data disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_plantgene/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/plantgene(src)

/obj/item/storage/box/disks_nanite
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/nanite_program(src)

//Parent box to accomodate station trait and apply unique restrictions
/obj/item/storage/box/survival
	name = "survival box"
	illustration = "survival"
	desc = "A compact box that is designed to hold specific emergency supplies"
	w_class = WEIGHT_CLASS_SMALL //So the roundstart box takes up less space.
	var/mask_type = /obj/item/clothing/mask/breath
	var/internal_type = /obj/item/tank/internals/emergency_oxygen
	var/medipen_type = /obj/item/reagent_containers/hypospray/medipen

/obj/item/storage/box/survival/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.max_total_storage = 21
	atom_storage.max_specific_storage = WEIGHT_CLASS_TINY
	var/static/list/exception_hold = typecacheof(list(
		/obj/item/flashlight/flare,
		/obj/item/radio,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/gas,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman/belt,
	))
	atom_storage.exception_hold = exception_hold

/obj/item/storage/box/survival/PopulateContents()
	if(!isplasmaman(loc))
		new mask_type(src)
		new internal_type(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

	if(!isnull(medipen_type))
		new medipen_type(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/flare(src)
		new /obj/item/radio/off(src)

/obj/item/storage/box/survival/proc/wardrobe_removal()
	if(!isplasmaman(loc)) //We need to specially fill the box with plasmaman gear, since it's intended for one
		return
	var/obj/item/mask = locate(mask_type) in src
	var/obj/item/internals = locate(internal_type) in src
	new /obj/item/tank/internals/plasmaman/belt(src)
	qdel(mask) // Get rid of the items that shouldn't be
	qdel(internals)

// Mining survival box
/obj/item/storage/box/survival/mining
	mask_type = /obj/item/clothing/mask/gas/explorer

/obj/item/storage/box/survival/mining/PopulateContents()
	..()
	new /obj/item/stack/medical/gauze(src)

// Engineer survival box
/obj/item/storage/box/survival/engineer
	name = "extended-capacity survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others. This one is labelled to contain an extended-capacity tank."
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/engineer/radio/PopulateContents()
	..() // we want the regular items too.
	new /obj/item/radio/off(src)

// Syndie survival box
/obj/item/storage/box/survival/syndie //why is this its own thing if it's just the engi box with a syndie mask and medipen?
	name = "extended-capacity survival box"
	desc = "A box with the bare essentials of ensuring the survival of you and others. This one is labelled to contain an extended-capacity tank."
	mask_type = /obj/item/clothing/mask/gas/syndicate
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi
	medipen_type = null

// Security survival box
/obj/item/storage/box/survival/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/item/storage/box/survival/security/radio/PopulateContents()
	..() // we want the regular stuff too
	new /obj/item/radio/off(src)

// Clown survival box

/obj/item/storage/box/survival/hug
	icon_state = "hugbox"
	illustration = "heart"

	internal_type = /obj/item/tank/internals/emergency_oxygen/clown

// Medical survival box
/obj/item/storage/box/survival/medical
	mask_type = /obj/item/clothing/mask/breath/medical

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains sterile latex gloves."
	illustration = "latex"

/obj/item/storage/box/gloves/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains sterile medical masks."
	illustration = "sterile"

/obj/item/storage/box/masks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syringes/variety
	name = "syringe variety box"

/obj/item/storage/box/syringes/variety/PopulateContents()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/cryo(src)
	new /obj/item/reagent_containers/syringe/piercing(src)
	new /obj/item/reagent_containers/syringe/bluespace(src)

/obj/item/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "syringe"

/obj/item/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "syringe"

/obj/item/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker( src )

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	illustration = "bbeaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/beaker/bluespace(src)

/obj/item/storage/box/beakers/variety
	name = "beaker variety box"

/obj/item/storage/box/beakers/variety/PopulateContents()
	new /obj/item/reagent_containers/cup/beaker(src)
	new /obj/item/reagent_containers/cup/beaker/large(src)
	new /obj/item/reagent_containers/cup/beaker/plastic(src)
	new /obj/item/reagent_containers/cup/beaker/meta(src)
	new /obj/item/reagent_containers/cup/beaker/noreact(src)
	new /obj/item/reagent_containers/cup/beaker/bluespace(src)

/obj/item/storage/box/medsprays
	name = "box of medical sprayers"
	desc = "A box full of medical sprayers, with unscrewable caps and precision spray heads."

/obj/item/storage/box/medsprays/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/medspray( src )

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."
	illustration = "dna"

/obj/item/storage/box/injectors/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/flashbangs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/flashbang(src)

/obj/item/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/flashes/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/assembly/flash/handheld(src)
	for(var/i in 1 to 6)
		new /obj/item/flashbulb(src)

/obj/item/storage/box/stingbangs
	name = "box of stingbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause severe injuries or death in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/stingbangs/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/stingbang(src)

/obj/item/storage/box/wall_flash
	name = "wall-mounted flash kit"
	desc = "This box contains everything necessary to build a wall-mounted flash. <B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/wall_flash/PopulateContents()
	var/id = rand(1000, 9999)
	// FIXME what if this conflicts with an existing one?

	new /obj/item/wallframe/button(src)
	new /obj/item/electronics/airlock(src)
	var/obj/item/assembly/control/flasher/remote = new(src)
	remote.id = id
	var/obj/item/wallframe/flasher/frame = new(src)
	frame.id = id
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/screwdriver(src)


/obj/item/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "secbox"
	illustration = "grenade"

/obj/item/storage/box/teargas/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/teargas(src)

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	illustration = "emp"

/obj/item/storage/box/emps/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/empgrenade(src)

/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "secbox"
	illustration = "implant"

/obj/item/storage/box/trackimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/minertracker
	name = "boxed tracking implant kit"
	desc = "For finding those who have died on the accursed lavaworld."
	illustration = "implant"

/obj/item/storage/box/minertracker/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 3,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	illustration = "implant"

/obj/item/storage/box/chemimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/chem = 5,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	illustration = "implant"

/obj/item/storage/box/exileimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/exile = 5,
		/obj/item/implanter = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	illustration = "glasses"

/obj/item/storage/box/rxglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	illustration = "drinkglass"

/obj/item/storage/box/drinkingglasses/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/glass/drinkingglass(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	illustration = "condiment"

/obj/item/storage/box/condimentbottles/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/condiment(src)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	illustration = "cup"

/obj/item/storage/box/cups/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/cup/glass/sillycup( src )

/obj/item/storage/box/donkpockets

/obj/item/storage/box/donkpockets/PopulateContents()
	for(var/i in 1 to 6)
		new donktype(src)

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "Instructions: Heat in microwave. Product will stay perpetually warmed with cutting edge Donk Co. technology."
	icon_state = "donkpocketbox"
	illustration=null
	var/donktype = /obj/item/food/donkpocket
	donktype = /obj/item/food/donkpocket

/obj/item/storage/box/donkpockets/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/donkpocket))

/obj/item/storage/box/donkpockets/donkpocketspicy
	name = "box of spicy-flavoured donk-pockets"
	icon_state = "donkpocketboxspicy"
	donktype = /obj/item/food/donkpocket/spicy

/obj/item/storage/box/donkpockets/donkpocketteriyaki
	name = "box of teriyaki-flavoured donk-pockets"
	icon_state = "donkpocketboxteriyaki"
	donktype = /obj/item/food/donkpocket/teriyaki

/obj/item/storage/box/donkpockets/donkpocketpizza
	name = "box of pizza-flavoured donk-pockets"
	icon_state = "donkpocketboxpizza"
	donktype = /obj/item/food/donkpocket/pizza

/obj/item/storage/box/donkpockets/donkpocketgondola
	name = "box of gondola-flavoured donk-pockets"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/food/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketgondolafinlandia
	name = "laatikko gondolin makuisia donk-taskuja"
	desc = "<B>Ohjeet:</B> <I>Lämmitä mikroaaltouunissa. Tuote jäähtyy, jos sitä ei syödä seitsemän minuutin kuluessa.</I>"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/food/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketberry
	name = "box of berry-flavoured donk-pockets"
	icon_state = "donkpocketboxberry"
	donktype = /obj/item/food/donkpocket/berry

/obj/item/storage/box/donkpockets/donkpockethonk
	name = "box of banana-flavoured donk-pockets"
	icon_state = "donkpocketboxbanana"
	donktype = /obj/item/food/donkpocket/honk

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null
	var/cube_type = /obj/item/food/monkeycube

/obj/item/storage/box/monkeycubes/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.set_holdable(list(/obj/item/food/monkeycube))

/obj/item/storage/box/monkeycubes/PopulateContents()
	for(var/i in 1 to 5)
		new cube_type(src)

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Waffle Co. brand monkey cubes. Just add water and a dash of subterfuge!"
	cube_type = /obj/item/food/monkeycube/syndicate

/obj/item/storage/box/gorillacubes
	name = "gorilla cube box"
	desc = "Waffle Co. brand gorilla cubes. Do not taunt."
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/gorillacubes/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.set_holdable(list(/obj/item/food/monkeycube))

/obj/item/storage/box/gorillacubes/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/monkeycube/gorilla(src)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	illustration = "id"

/obj/item/storage/box/ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id(src)

//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	illustration = "pda"

/obj/item/storage/box/PDAs/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/modular_computer/tablet/pda(src)
	new /obj/item/computer_hardware/hard_drive/role/head(src)

	var/newcart = pick(	/obj/item/computer_hardware/hard_drive/role/engineering,
						/obj/item/computer_hardware/hard_drive/role/security,
						/obj/item/computer_hardware/hard_drive/role/medical,
						/obj/item/computer_hardware/hard_drive/role/signal/toxins,
						/obj/item/computer_hardware/hard_drive/role/cargo_technician)
	new newcart(src)

/obj/item/storage/box/silver_ids
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	illustration = "id"

/obj/item/storage/box/silver_ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id/silver(src)

/obj/item/storage/box/prisoner
	name = "box of prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	icon_state = "secbox"
	illustration = "id"

/obj/item/storage/box/prisoner/PopulateContents()
	..()
	new /obj/item/card/id/gulag/one(src)
	new /obj/item/card/id/gulag/two(src)
	new /obj/item/card/id/gulag/three(src)
	new /obj/item/card/id/gulag/four(src)
	new /obj/item/card/id/gulag/five(src)
	new /obj/item/card/id/gulag/six(src)
	new /obj/item/card/id/gulag/seven(src)

/obj/item/storage/box/seccarts
	name = "box of PDA security job disks"
	desc = "A box full of PDA job disks used by Security."
	icon_state = "secbox"
	illustration = "pda"

/obj/item/storage/box/seccarts/PopulateContents()
	new /obj/item/computer_hardware/hard_drive/role/detective(src)
	for(var/i in 1 to 6)
		new /obj/item/computer_hardware/hard_drive/role/security(src)

/obj/item/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	icon_state = "secbox"
	illustration = "firingpin"

/obj/item/storage/box/firingpins/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin(src)

/obj/item/storage/box/firingpins/paywall
	name = "box of paywall firing pins"
	desc = "A box full of paywall firing pins, to allow newly-developed firearms to operate behind a custom-set paywall."
	illustration = "firingpin"

/obj/item/storage/box/firingpins/paywall/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin/paywall(src)

/obj/item/storage/box/lasertagpins
	name = "box of laser tag firing pins"
	desc = "A box full of laser tag firing pins, to allow newly-developed firearms to require wearing brightly coloured plastic armor before being able to be used."
	illustration = "firingpin"

/obj/item/storage/box/lasertagpins/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/firing_pin/tag/red(src)
		new /obj/item/firing_pin/tag/blue(src)

/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/handcuffs/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.max_total_storage = 14
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/box/handcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/handcuffs/compact
	name = "compact box of handcuffs"
	desc = "A compact box full of handcuffs."
	icon_state = "secbox"
	illustration = "handcuff"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/handcuffs/compact/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.max_total_storage = 8
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/box/handcuffs/compact/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/zipties/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 14
	atom_storage.max_total_storage = 28
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/box/zipties/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

/obj/item/storage/box/zipties/compact
	name = "compact box of zipties"
	desc = "A compact box full of zipties."
	icon_state = "secbox"
	illustration = "handcuff"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/zipties/compact/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

/obj/item/storage/box/zipties/compact/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.max_total_storage = 14
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienbox"
	illustration = "handcuff"

/obj/item/storage/box/alienhandcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new	/obj/item/restraints/handcuffs/alien(src)

/obj/item/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "syndiebox"
	illustration = "syndiesuit"

/obj/item/storage/box/fakesyndiesuit/PopulateContents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = span_alert("Keep out of reach of children.")
	illustration = "mousetrap"

/obj/item/storage/box/mousetraps/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/assembly/mousetrap(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"

/obj/item/storage/box/snappops/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/toy/snappop))
	atom_storage.max_slots = 8

/obj/item/storage/box/snappops/PopulateContents()
	for(var/i in 1 to 8)
		new /obj/item/toy/snappop(src)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	inhand_icon_state = "zippo"
	worn_icon_state = "lighter"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound =  'sound/items/handling/matchbox_pickup.ogg'

/obj/item/storage/box/matches/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.set_holdable(list(/obj/item/match))

/obj/item/storage/box/matches/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/match(src)

/obj/item/storage/box/matches/attackby(obj/item/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/match))
		W.matchignite()
		playsound(src.loc, 'sound/items/matchstick_lit.ogg', 100, 1)

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	illustration = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap

/obj/item/storage/box/lights/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 21
	atom_storage.set_holdable(list(/obj/item/light/tube, /obj/item/light/bulb))
	atom_storage.max_total_storage = 21
	atom_storage.allow_quick_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/obj/item/storage/box/lights/bulbs/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/storage/box/lights/tubes/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/tube(src)

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/storage/box/lights/mixed/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches."
	illustration = "grenade"

/obj/item/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/smart_metal_foam
	name = "box of smart metal foam grenades"
	desc = "Used to rapidly seal hull breaches. This variety conforms to the walls of its area."
	illustration = "grenade"

/obj/item/storage/box/smart_metal_foam/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/smart_metal_foam(src)

/obj/item/storage/box/oxycandle
	name = "box of oxygen candles"
	desc = "Used to repressurize areas during power emergencies."
	illustration = "grenade"

/obj/item/storage/box/oxycandle/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/flashlight/oxycandle(src)

/obj/item/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable = null

/obj/item/storage/box/hug/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all.."))
	return BRUTELOSS

/obj/item/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, 1, -5)
	user.visible_message(span_notice("[user] hugs \the [src]."),span_notice("You hug \the [src]."))

/////clown box & honkbot assembly
/obj/item/storage/box/clown
	name = "clown box"
	desc = "A colorful cardboard box for the clown"
	illustration = "clown"

/obj/item/storage/box/clown/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/bodypart/arm/left/robot)) || (istype(I, /obj/item/bodypart/arm/right/robot)))
		if(contents.len) //prevent accidently deleting contents
			to_chat(user, span_warning("You need to empty [src] out first!"))
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		to_chat(user, span_notice("You add some wheels to the [src]! You've got a honkbot assembly now! Honk!"))
		var/obj/item/bot_assembly/honkbot/A = new
		qdel(src)
		user.put_in_hands(A)
	else
		return ..()

//////
/obj/item/storage/box/hug/medical/PopulateContents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/storage/box/rubbershot
	name = "box of rubber shots"
	desc = "A standard box full of rubber shots, designed for riot shotguns."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/rubbershot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/rubbershot(src)

/obj/item/storage/box/lethalshot
	name = "box of lethal shotgun shots"
	desc = "A standard box full of lethal shots, designed for riot shotguns."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/storage/box/lethalshot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/storage/box/beanbag
	name = "box of beanbags"
	desc = "A standard box full of beanbag shells."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/beanbag/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/storage/box/breacherslug
	name = "box of breaching cartridges"
	desc = "A standard box full of breaching slugs."
	icon_state = "breachershot_box"
	illustration = null

/obj/item/storage/box/breacherslug/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/breacher(src)

/obj/item/storage/box/incapacitateshot
	name = "box of incapacitating cartridges"
	desc = "A standard box full of incapacitating shots, made for a shotgun."
	icon_state = "incapacitateshot_box"
	illustration = null

/obj/item/storage/box/incapacitateshot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/incapacitate(src)

/obj/item/storage/box/actionfigure
	name = "box of action figures"
	desc = "The latest set of collectable action figures."
	icon_state = "box"

/obj/item/storage/box/actionfigure/PopulateContents()
	for(var/i in 1 to 4)
		var/randomFigure = pick(subtypesof(/obj/item/toy/figure))
		new randomFigure(src)

/obj/item/storage/box/ingredients //This box is for the randomely chosen version the chef spawns with, it shouldn't actually exist.
	name = "ingredient box"
	illustration = "fruit"
	var/theme_name
	var/list/possible_themes = list("wildcard", "fiesta", "italian", "vegetarian", "american", "fruity", "sweets", "delights", "grains", "carnivore", "exotic")

/obj/item/storage/box/ingredients/Initialize(mapload)
	. = ..()
	if(!theme_name)
		theme_name = pick(possible_themes)
		PopulateContents()
	name = "[name] ([theme_name])"
	desc = "A box containing supplementary ingredients for the aspiring chef. The box's theme is '[theme_name]'."
	inhand_icon_state = "syringe_kit"

/obj/item/storage/box/ingredients/PopulateContents()
	switch(theme_name)
		if("wildcard")
			var/list/randomfood = list(
				/obj/item/food/grown/chili,
				/obj/item/food/grown/tomato,
				/obj/item/food/grown/carrot,
				/obj/item/food/grown/potato,
				/obj/item/food/grown/potato/sweet,
				/obj/item/food/grown/apple,
				/obj/item/food/chocolatebar,
				/obj/item/food/grown/cherries,
				/obj/item/food/grown/banana,
				/obj/item/food/grown/cabbage,
				/obj/item/food/grown/soybeans,
				/obj/item/food/grown/corn,
				/obj/item/food/grown/mushroom/plumphelmet,
				/obj/item/food/grown/mushroom/chanterelle)
			for(var/i in 1 to 7)
				var/food = pick(randomfood)
				new food(src)
		if("fiesta")
			new /obj/item/food/tortilla(src)
			for(var/i in 1 to 2)
				new /obj/item/food/grown/corn(src)
				new /obj/item/food/grown/soybeans(src)
				new /obj/item/food/grown/chili(src)
		if("italian")
			new /obj/item/reagent_containers/cup/glass/bottle/wine(src)
			for(var/i in 1 to 3)
				new /obj/item/food/grown/tomato(src)
				new /obj/item/food/meatball(src)
		if("vegetarian")
			new /obj/item/food/grown/eggplant(src)
			new /obj/item/food/grown/potato(src)
			new /obj/item/food/grown/apple(src)
			new /obj/item/food/grown/corn(src)
			new /obj/item/food/grown/tomato(src)
			for(var/i in 1 to 2)
				new /obj/item/food/grown/carrot(src)
		if("american")
			new /obj/item/food/meatball(src)
			for(var/i in 1 to 2)
				new /obj/item/food/grown/potato(src)
				new /obj/item/food/grown/tomato(src)
				new /obj/item/food/grown/corn(src)
		if("fruity")
			new /obj/item/food/grown/citrus/lemon(src)
			new /obj/item/food/grown/citrus/lime(src)
			new /obj/item/food/grown/watermelon(src)
			for(var/i in 1 to 2)
				new /obj/item/food/grown/apple(src)
				new /obj/item/food/grown/citrus/orange(src)
		if("sweets")
			new /obj/item/food/chocolatebar(src)
			new /obj/item/food/grown/cocoapod(src)
			new /obj/item/food/grown/apple(src)
			for(var/i in 1 to 2)
				new/obj/item/food/grown/cherries(src)
				new /obj/item/food/grown/banana(src)
		if("delights")
			new /obj/item/food/grown/vanillapod(src)
			new /obj/item/food/grown/cocoapod(src)
			new /obj/item/food/grown/berries(src)
			for(var/i in 1 to 2)
				new /obj/item/food/grown/potato/sweet(src)
				new /obj/item/food/grown/bluecherries(src)
		if("grains")
			new /obj/item/food/grown/wheat(src)
			new /obj/item/food/grown/cocoapod(src)
			new /obj/item/food/honeycomb(src)
			new /obj/item/seeds/flower/poppy(src)
			for(var/i in 1 to 3)
				new /obj/item/food/grown/oat(src)
		if("carnivore")
			new /obj/item/food/meat/slab/bear(src)
			new /obj/item/food/meat/slab/spider(src)
			new /obj/item/food/spidereggs(src)
			new /obj/item/food/fishmeat/carp(src)
			new /obj/item/food/meat/slab/xeno(src)
			new /obj/item/food/meat/slab/corgi(src)
			new /obj/item/food/meatball(src)
		if("exotic")
			new /obj/item/food/grown/chili(src)
			for(var/i in 1 to 2)
				new /obj/item/food/fishmeat/carp(src)
				new /obj/item/food/grown/soybeans(src)
				new /obj/item/food/grown/cabbage(src)

/obj/item/storage/box/ingredients/wildcard
	theme_name = "wildcard"

/obj/item/storage/box/ingredients/fiesta
	theme_name = "fiesta"

/obj/item/storage/box/ingredients/italian
	theme_name = "italian"

/obj/item/storage/box/ingredients/vegetarian
	theme_name = "vegetarian"

/obj/item/storage/box/ingredients/american
	theme_name = "american"

/obj/item/storage/box/ingredients/fruity
	theme_name = "fruity"

/obj/item/storage/box/ingredients/sweets
	theme_name = "sweets"

/obj/item/storage/box/ingredients/delights
	theme_name = "delights"

/obj/item/storage/box/ingredients/grains
	theme_name = "grains"

/obj/item/storage/box/ingredients/carnivore
	theme_name = "carnivore"

/obj/item/storage/box/ingredients/exotic
	theme_name = "exotic"

/obj/item/storage/box/emptysandbags
	name = "box of empty sandbags"
	illustration = "sandbag"

/obj/item/storage/box/emptysandbags/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/emptysandbag(src)

/obj/item/storage/box/rndboards
	name = "\proper the liberator's legacy"
	desc = "A box containing a gift for worthy golems."
	illustration = "scicircuit"

/obj/item/storage/box/rndboards/PopulateContents()
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)

/obj/item/storage/box/silver_sulf
	name = "box of silver sulfadiazine patches"
	desc = "Contains patches used to treat burns."
	illustration = "firepatch"

/obj/item/storage/box/silver_sulf/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/patch/silver_sulf(src)

/obj/item/storage/box/fountainpens
	name = "box of fountain pens"
	illustration = "fpen"

/obj/item/storage/box/fountainpens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/pen/fountain(src)

/obj/item/storage/box/holy_grenades
	name = "box of holy hand grenades"
	desc = "Contains several grenades used to rapidly purge heresy."
	illustration = "grenade"

/obj/item/storage/box/holy_grenades/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/holy(src)

/obj/item/storage/box/stockparts/basic //for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
	name = "box of stock parts"
	desc = "Contains a variety of basic stock parts."

/obj/item/storage/box/stockparts/basic/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/matter_bin = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/stockparts/deluxe
	name = "box of deluxe stock parts"
	desc = "Contains a variety of deluxe stock parts."
	icon_state = "syndiebox"

/obj/item/storage/box/stockparts/deluxe/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor/quadratic = 3,
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/manipulator/femto = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 3,
		/obj/item/stock_parts/matter_bin/bluespace = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/dishdrive
	name = "DIY Dish Drive Kit"
	desc = "Contains everything you need to build your own Dish Drive!"
	custom_premium_price = 200

/obj/item/storage/box/dishdrive/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/iron/five = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/screwdriver = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/material
	name = "box of materials"
	illustration = "implant"

/obj/item/storage/box/material/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = 1000
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.max_slots = 1000
	atom_storage.allow_big_nesting = TRUE

/obj/item/storage/box/material/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/rglass = 50,
		/obj/item/stack/sheet/mineral/copper/fifty = 1,
		/obj/item/stack/sheet/plasmaglass = 50,
		/obj/item/stack/sheet/plasmarglass = 50,
		/obj/item/stack/sheet/titaniumglass = 50,
		/obj/item/stack/sheet/plastitaniumglass = 50,
		/obj/item/stack/sheet/plasteel = 50,
		/obj/item/stack/sheet/mineral/plastitanium = 50,
		/obj/item/stack/sheet/mineral/titanium = 50,
		/obj/item/stack/sheet/mineral/gold = 50,
		/obj/item/stack/sheet/mineral/silver = 50,
		/obj/item/stack/sheet/mineral/uranium = 50,
		/obj/item/stack/sheet/mineral/plasma = 50,
		/obj/item/stack/sheet/mineral/diamond = 50,
		/obj/item/stack/ore/bluespace_crystal/refined = 50,
		/obj/item/stack/sheet/mineral/bananium = 50,
		/obj/item/stack/sheet/plastic/fifty = 1,
		/obj/item/stack/sheet/runed_metal/fifty = 1,
		/obj/item/stack/sheet/brass/fifty = 1,
		/obj/item/stack/sheet/mineral/abductor = 50,
		/obj/item/stack/sheet/mineral/adamantine = 50,
		/obj/item/stack/sheet/wood = 50,
		/obj/item/stack/sheet/cotton/cloth = 50,
		/obj/item/stack/sheet/leather = 50,
		/obj/item/stack/sheet/bone = 12,
		/obj/item/stack/sheet/cardboard/fifty = 1,
		/obj/item/stack/sheet/mineral/sandstone = 50,
		/obj/item/stack/sheet/snow = 50,
	)
	for(var/obj/item/stack/stack_type as anything in items_inside)
		var/amt = items_inside[stack_type]
		new stack_type(src, amt, FALSE)

// except iron, glass, copper, plastic, runed metal, brass, and carboard

/obj/item/storage/box/deputy
	name = "box of deputy armbands"
	desc = "To be issued to those authorized to act as deputy of security."
	icon_state = "secbox"
	illustration = "depband"

/obj/item/storage/box/deputy/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/clothing/accessory/armband/deputy(src)
		new /obj/item/card/id/pass/deputy(src)

/obj/item/storage/box/vouchers
	name = "box of security vouchers"
	desc = "To be issued to new recruits only."
	icon_state = "secbox"
	illustration = "writing_syndie"

/obj/item/storage/box/vouchers/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/mining_voucher/security(src)

/obj/item/storage/box/radiokey
	name = "box of generic radio keys"
	desc = "You shouldn't be seeing this. Ahelp."
	icon_state = "radiobox"
	var/radio_key = /obj/item/encryptionkey

/obj/item/storage/box/radiokey/PopulateContents()
	for(var/i in 1 to 7)
		new radio_key(src)

/obj/item/storage/box/radiokey/com
	name = "box of command staff's radio keys"
	desc = "A spare radio key for each command staff, plus an amplification key and a generic command key."
	icon_state = "radiobox_gold"

/obj/item/storage/box/radiokey/com/PopulateContents()
	new /obj/item/encryptionkey/heads/rd(src)
	new /obj/item/encryptionkey/heads/hos(src)
	new /obj/item/encryptionkey/heads/ce(src)
	new /obj/item/encryptionkey/heads/cmo(src)
	new /obj/item/encryptionkey/heads/hop(src)
	new /obj/item/encryptionkey/headset_com(src)
	new /obj/item/encryptionkey/amplification(src)

/obj/item/storage/box/radiokey/sci
	name = "box of science radio keys"
	desc = "For SCIENCE!"
	radio_key = /obj/item/encryptionkey/headset_sci

/obj/item/storage/box/radiokey/sec
	name = "box of security radio keys"
	desc = "Grants access to the station's security radio."
	radio_key = /obj/item/encryptionkey/headset_sec

/obj/item/storage/box/radiokey/eng
	name = "box of engineering radio keys"
	desc = "Dooms you to listen to Poly for all eternity."
	radio_key = /obj/item/encryptionkey/headset_eng

/obj/item/storage/box/radiokey/med
	name = "box of medical radio keys"
	desc = "9 out of 10 doctors reccomend."
	radio_key = /obj/item/encryptionkey/headset_med

/obj/item/storage/box/radiokey/srv
	name = "box of service radio keys"
	desc = "The channel for servants."
	radio_key = /obj/item/encryptionkey/headset_service

/obj/item/storage/box/radiokey/car
	name = "box of cargo tech radio keys"  // qm can always buy mining conscript
	desc = "Slaves you to the quartermaster."
	radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/storage/box/radiokey/cap  // admin spawn
	name = "glorious box of captain's radio keys"
	desc = "All-access radio."
	icon_state = "radiobox_gold"
	radio_key = /obj/item/encryptionkey/heads/captain

/obj/item/storage/box/radiokey/clown  // honk
	name = "\improper H.O.N.K. CO fake encryption keys"
	desc = "Totally prank your friends with these realistic encryption keys!"

/obj/item/storage/box/radiokey/clown/PopulateContents()
	new /obj/item/encryptionkey/heads/rd/fake(src)
	new /obj/item/encryptionkey/heads/hos/fake(src)
	new /obj/item/encryptionkey/heads/ce/fake(src)
	new /obj/item/encryptionkey/heads/cmo/fake(src)
	new /obj/item/encryptionkey/heads/hop/fake(src)

//TABLET COLORIZER BOX
/obj/item/storage/box/tabletcolorizer
	name = "colorizer box"
	desc = "A box full of Tablet Colorizers. Unleash your inner child and play around with a vast array of colors!"
	icon_state = "tabletcbox"
	custom_price = PAYCHECK_MEDIUM * 4

/obj/item/storage/box/tabletcolorizer/PopulateContents()
	new /obj/item/colorizer/tablet(src)
	new /obj/item/colorizer/tablet/pink(src)
	new /obj/item/colorizer/tablet/sand(src)
	new /obj/item/colorizer/tablet/green(src)
	new /obj/item/colorizer/tablet/olive(src)
	new /obj/item/colorizer/tablet/teal(src)
	new /obj/item/colorizer/tablet/purple(src)
	new /obj/item/colorizer/tablet/black(src)
	new /obj/item/colorizer/tablet/white(src)

/obj/item/storage/box/tablet4dummies
	name = "'Tablets For Dummies'"
	desc = "First Edition 'Tablets for Dummies' kit. Complete with body, components, and instructions for assembly."
	icon_state = "radiobox"
	custom_price = 150

/obj/item/storage/box/tablet4dummies/PopulateContents()
	new /obj/item/modular_computer/tablet(src)
	new /obj/item/computer_hardware/battery/tiny(src)
	new /obj/item/computer_hardware/processor_unit/small(src)
	new /obj/item/computer_hardware/hard_drive/micro(src)
	new /obj/item/computer_hardware/identifier(src)
	new /obj/item/computer_hardware/network_card(src)
	new /obj/item/computer_hardware/card_slot(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/tablet_guide(src)

/obj/item/storage/box/hacking4dummies
	name = "'Hacking For Dummies'"
	desc = "Hacking for Dummies kit, made by the HELLRAISER Crack team. Meant to teach you how to stick it to the man! (metaphorically)."
	icon_state = "syndiebox"
	illustration = "disk_kit"
	custom_price = 200 // this SHOULD be calculated by contents... but... that would ruin export, we need to find something else in the future for vendors
	trade_flags = TRADE_CONTRABAND | TRADE_NOT_SELLABLE | TRADE_DELETE_UNSOLD

/obj/item/storage/box/hacking4dummies/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/multitool(src)
	new /obj/item/computer_hardware/hard_drive/portable(src)
	new /obj/item/computer_hardware/hard_drive/portable/advanced(src)
	new /obj/item/computer_hardware/hard_drive/portable/super(src)
	new /obj/item/paper/manualhacking_guide(src)

/obj/item/storage/box/locker
	name = "locker box"
	desc = "A solution to locker clutter. A box. Science's best achievement."
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/locker/security
	name = "security locker box"
	icon_state = "secbox"
/obj/item/storage/box/stabilized //every single stabilized extract from xenobiology
	name = "box of stabilized extracts"
	icon_state = "syndiebox"

/obj/item/storage/box/stabilized/PopulateContents()
	var/static/items_inside = list(
		/obj/item/slimecross/stabilized/grey=1,\
		/obj/item/slimecross/stabilized/orange=1,\
		/obj/item/slimecross/stabilized/purple=1,\
		/obj/item/slimecross/stabilized/blue=1,\
		/obj/item/slimecross/stabilized/metal=1,\
		/obj/item/slimecross/stabilized/yellow=1,\
		/obj/item/slimecross/stabilized/darkpurple=1,\
		/obj/item/slimecross/stabilized/darkblue=1,\
		/obj/item/slimecross/stabilized/silver=1,\
		/obj/item/slimecross/stabilized/bluespace=1,\
		/obj/item/slimecross/stabilized/sepia=1,\
		/obj/item/slimecross/stabilized/cerulean=1,\
		/obj/item/slimecross/stabilized/pyrite=1,\
		/obj/item/slimecross/stabilized/red=1,\
		/obj/item/slimecross/stabilized/green=1,\
		/obj/item/slimecross/stabilized/pink=1,\
		/obj/item/slimecross/stabilized/gold=1,\
		/obj/item/slimecross/stabilized/oil=1,\
		/obj/item/slimecross/stabilized/black=1,\
		/obj/item/slimecross/stabilized/lightpink=1,\
		/obj/item/slimecross/stabilized/adamantine=1,\
		/obj/item/slimecross/stabilized/rainbow=1,\
	)

/obj/item/storage/box/shipping
	name = "box of shipping supplies"
	desc = "Contains several scanners and labelers for shipping things. Wrapping Paper not included."
	illustration = "shipping"
	custom_price = 150

/obj/item/storage/box/shipping/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dest_tagger=1,
		/obj/item/sales_tagger=1,
		/obj/item/export_scanner=1,
		/obj/item/stack/package_wrap/small=2,
		/obj/item/stack/wrapping_paper/small=1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/party_poppers
	name = "box of party_poppers"
	desc = "Turn any event into a celebration and ensure the janitor stays busy."

/obj/item/storage/box/party_poppers/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/spray/chemsprayer/party(src)
