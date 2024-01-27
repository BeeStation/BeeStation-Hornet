/datum/gang_item
	var/name
	var/desc
	var/item_path
	var/category = "item category"
	var/cost
	var/list/gang_whitelist = list()
	var/list/gang_blacklist = list()
	var/list/gang_items


/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	if(!spawn_item(user, gang, gangtool))
		gang.adjust_influence(-cost)
		to_chat(user, "<span class='notice'>You bought \the [name].</span>")
		return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool) // If this returns anything other than null, something fucked up and influence won't lower.
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	else
		return TRUE

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.influence >= cost)


///////////////////
//Essential Gang Tools
///////////////////

/datum/gang_item/essentials
	category = "Essential Items"

/datum/gang_item/essentials/spraycan
	name = "Territory Spraycan"
	cost = 10
	item_path = /obj/item/toy/crayon/spraycan/gang


/datum/gang_item/essentials/spraycan/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/toy/crayon/spraycan/gang/O = new item_path(user.loc)
	user.put_in_hands(O)
	O.gang = gang
	O.paint_color = gang.color
	O.update_icon()

/datum/gang_item/essentials/gangtool
	name = "Gangtool"
	cost = 50
	item_path = /obj/item/device/gangtool
	desc = "Spare gangtool to keep stashed in case of arrest."


/datum/gang_item/essentials/uniform
	name = "Gang Uniform"
	cost = 5

/datum/gang_item/essentials/uniform/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/uniform_box = new (get_turf(user))

	new gang.outfit(uniform_box)
	new gang.suit(uniform_box)
	new gang.hat(uniform_box)

	user.put_in_hands(uniform_box)
	to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence.")
	return TRUE


///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Weapons"

/datum/gang_item/weapon/emp
	name = "EMP Grenade"
	cost = 50
	item_path = /obj/item/grenade/empgrenade


/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	cost = 100
	item_path = /obj/item/switchblade

/datum/gang_item/weapon/shuriken
	name = "Shuriken box"
	cost = 150
	item_path = /obj/item/storage/box/shuriken_box

/obj/item/storage/box/shuriken_box
	name = "shuriken Box"

/obj/item/storage/box/shuriken_box/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/throwing_star(src)

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	cost = 500
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/pistol_ammo
	name = "10mm Ammo"
	cost = 50
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	cost = 500
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/gang_item/weapon/uzi_ammo
	name = "Uzi Ammo"
	cost = 50
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/gang_item/weapon/laser
	name = "Laser Gun"
	cost = 500
	item_path = /obj/item/gun/energy/laser/retro

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Support Equipment"

/datum/gang_item/equipment/healcigs
	name = "Healing Cigs"
	cost = 20
	item_path = /obj/item/storage/fancy/cigarettes/cigpack_syndicate

/datum/gang_item/equipment/drugs
	name = "Drug Supply"
	cost = 50
	item_path = /obj/item/storage/box

/datum/gang_item/equipment/drugs/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O
	var/turf/T = get_turf(user)
	switch (rand(1,10))
		if (1)
			O = new /obj/item/storage/pill_bottle/lsd(T)
		if (2)
			O = new /obj/item/storage/pill_bottle/happy(T)
		if (3)
			O = new /obj/item/storage/pill_bottle/zoom(T)
		if (4)
			O = new /obj/item/storage/pill_bottle/aranesp(T)
		if (5)
			O = new /obj/item/storage/pill_bottle/happiness(T)
		if (6)
			O = new /obj/item/storage/pill_bottle/psicodine(T)
		if (7)
			O = new /obj/item/storage/pill_bottle/psicodine(T)
		if (8)
			O = new /obj/item/food/grown/cannabis(T)
		if (9)
			O = new /obj/item/food/grown/cannabis/rainbow(T)
		if (10)
			O = new /obj/item/food/grown/cannabis/white(T)
	if (O)
		user.put_in_hands(O)

/datum/gang_item/equipment/aids
	name = "Battlefield Aid Kit"
	cost = 75
	item_path = /obj/item/storage/firstaid/shifty/battle

/datum/gang_item/equipment/hangover
	name = "Bad Trip Kit"
	cost = 75
	item_path = /obj/item/storage/firstaid/shifty/hangover

/obj/item/storage/firstaid/shifty
	name = "shifty medkit"
	desc = "A shady medkit, assembled out of scraps and leftovers."
	icon_state = "bezerk"

/obj/item/storage/firstaid/shifty/battle/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 2,
		/obj/item/reagent_containers/pill/patch/styptic = 2,
		/obj/item/reagent_containers/medspray/synthflesh = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/shifty/hangover/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/reagent_containers/syringe/antitoxin = 1,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)
