/* Utility Closets
 * Contains:
 *		Emergency Closet
 *		Fire Closet
 *		Tool Closet
 *		Radiation Closet
 *		Bombsuit Closet
 *		Hydrant
 *		First Aid
 */

/*
 * Emergency Closet
 */
/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency vacuum exposure."
	icon_state = "emergency"

/obj/structure/closet/emcloset/empty
	name = "emergency closet"
	desc = "It's a storage unit for emergency vacuum exposure."
	icon_state = "emergency"

/obj/structure/closet/emcloset/empty/PopulateContents()
	return

/obj/structure/closet/emcloset/anchored
	anchored = TRUE

/obj/structure/closet/emcloset/Initialize(mapload)
	if (prob(1))
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/structure/closet/emcloset/PopulateContents()
	..()
	// Guaranteed, 2 Suits:
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/suit/space/hardsuit/skinsuit(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/clothing/suit/space/hardsuit/skinsuit(src)

	// Guaranteed but number varies
	switch(rand(30))
		if(0 to 10) //  1
			new /obj/item/flashlight/oxycandle(src)
		if(11 to 20) // 2
			new /obj/item/flashlight/oxycandle(src)
			new /obj/item/flashlight/oxycandle(src)
		if(21 to 30) // 3
			new /obj/item/flashlight/oxycandle(src)
			new /obj/item/flashlight/oxycandle(src)
			new /obj/item/flashlight/oxycandle(src)

	// Roll for 2 supplementary items
	for(var/i in 1 to 2)
		switch(rand(30))
			if(0 to 10) //  1
				new /obj/item/storage/toolbox/emergency(src)
			if(11 to 20) // 2
				new /obj/item/grenade/chem_grenade/smart_metal_foam(src)
			if(21 to 30) // 3
				new /obj/item/reagent_containers/hypospray/medipen/vactreat(src)

/*
 * Fire Closet
 */
/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "fire"

/obj/structure/closet/firecloset/empty
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "fire"

/obj/structure/closet/firecloset/empty/PopulateContents()
	return

/obj/structure/closet/firecloset/PopulateContents()
	..()
	//Guaranteed, 1 Suit
	new /obj/item/clothing/suit/utility/fire/firefighter(src)
	new /obj/item/clothing/head/utility/hardhat/red(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)

	// Number varies
	switch(rand(100))
		if(0 to 50) // Boohoo you lost the lottery
			new /obj/item/reagent_containers/hypospray/medipen(src)
		if(51 to 90) // 2
			new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
		if(91 to 100) // 3
			new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
			new /obj/item/reagent_containers/pill/patch/silver_sulf(src)


	// Roll for 2 supplementary items
	for(var/i in 1 to 2)
		switch(rand(30))
			if(0 to 10) //  1
				new /obj/item/storage/toolbox/emergency(src)
			if(11 to 20) // 2
				new /obj/item/extinguisher(src)
			if(21 to 30) // 3
				new /obj/item/reagent_containers/hypospray/medipen(src)

/*
 * Tool Closet
 */
/obj/structure/closet/toolcloset
	name = "tool closet"
	desc = "It's a storage unit for tools."
	icon_state = "eng"
	icon_door = "eng_tool"

/obj/structure/closet/toolcloset/empty
	name = "tool closet"
	desc = "It's a storage unit for tools."
	icon_state = "eng"
	icon_door = "eng_tool"

/obj/structure/closet/toolcloset/empty/PopulateContents()
	return

/obj/structure/closet/toolcloset/PopulateContents()
	..()
	if(prob(40))
		new /obj/item/clothing/suit/hazardvest(src)
	if(prob(70))
		new /obj/item/flashlight(src)
	if(prob(70))
		new /obj/item/screwdriver(src)
	if(prob(70))
		new /obj/item/wrench(src)
	if(prob(70))
		new /obj/item/weldingtool(src)
	if(prob(70))
		new /obj/item/crowbar(src)
	if(prob(70))
		new /obj/item/wirecutters(src)
	if(prob(70))
		new /obj/item/t_scanner(src)
	if(prob(20))
		new /obj/item/storage/belt/utility(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(20))
		new /obj/item/multitool(src)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	if(prob(40))
		new /obj/item/clothing/head/utility/hardhat(src)


/*
 * Radiation Closet
 */
/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "eng"
	icon_door = "eng_rad"

/obj/structure/closet/radiation/empty
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "eng"
	icon_door = "eng_rad"

/obj/structure/closet/radiation/empty/PopulateContents()
	return

/obj/structure/closet/radiation/PopulateContents()
	..()
	new /obj/item/geiger_counter(src)
	new /obj/item/clothing/suit/utility/radiation(src)
	new /obj/item/clothing/head/utility/radiation(src)
	if(prob(50))
		new /obj/item/storage/firstaid/radbgone(src)
	else
		new /obj/item/storage/pill_bottle/antirad(src)

/*
 *Gun-Lockers except they are actually lockers
 */
/obj/structure/closet/gun_locker
	name = "\improper weapon closet"
	desc = "It's a storage unit for weapons and similar objects."
	icon_state = "shotguncase"

/*
 * Bombsuit closet
 */
/obj/structure/closet/bombcloset
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bomb"

/obj/structure/closet/bombcloset/empty
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bomb"

/obj/structure/closet/bombcloset/empty/PopulateContents()
	return

/obj/structure/closet/bombcloset/PopulateContents()
	..()
	new /obj/item/clothing/suit/utility/bomb_suit(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/utility/bomb_hood(src)

/obj/structure/closet/bombcloset/security/PopulateContents()
	new /obj/item/clothing/suit/utility/bomb_suit/security(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/head/utility/bomb_hood/security(src)

/obj/structure/closet/bombcloset/white/PopulateContents()
	new /obj/item/clothing/suit/utility/bomb_suit/white(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/utility/bomb_hood/white(src)

/*
 * Ammunition
 */
/obj/structure/closet/ammunitionlocker
	name = "ammunition locker"

/obj/structure/closet/ammunitionlocker/PopulateContents()
	..()
	for(var/i in 1 to 8)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
