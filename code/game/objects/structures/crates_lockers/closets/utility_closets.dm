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
	name = "\improper armory locker"
	desc = "A storage unit for weapons, ammo, and similar objects."
	icon = 'icons/obj/storage/guncase.dmi'
	icon_state = "guncase"
	anchored = TRUE
	seethrough_doors = TRUE

	// How many small item thumbnails to draw and their size
	var/max_contents_overlays = 2
	var/static/CONTENTS_OVERLAY_SIZE = 16

/obj/structure/closet/gun_locker/update_overlays()
	. = ..()

	if(!length(contents))
		return .

	// small horizontal shifts for each successive item overlay
	var/static/list/overlay_shifts = list(-4, 2, -10, 6, -14, -1, -7)

	var/count = 0
	var/stack_vertically = FALSE

	for(var/atom/movable/item in contents)
		if(count >= max_contents_overlays)
			break

		// Only allow good shtuff
		if(!istype(item, /obj/item/storage) && !istype(item, /obj/item/gun))
			continue

		// Create overlay image from the item's icon
		var/image/overlay = image(item, src)
		var	icon/item_icon = icon(item.icon, item.icon_state)

		// Scale the overlay to a fixed thumbnail size
		overlay.transform = overlay.transform.Scale(
			CONTENTS_OVERLAY_SIZE / item_icon.Width(),
			CONTENTS_OVERLAY_SIZE / item_icon.Height(),
		)

		// Now we handle each type of item specifically for positioning
		// Rotate guns 90 degrees so they appear horizontally
		if(istype(item, /obj/item/gun))
			overlay.transform = turn(overlay.transform, 90)
			overlay.pixel_y = -2
		else
			overlay.pixel_y = -6

		// If we are a box, shift right. We also want to stack them vertically instead of horizontally
		if(istype(item, /obj/item/storage))
			overlay.pixel_x = 1
			overlay.pixel_y = -3.5
			stack_vertically = TRUE
			overlay.pixel_y = overlay_shifts[(count % overlay_shifts.len) + 1]

		// Position it slightly in front of the locker face, beneath the door overlay
		overlay.layer = FLOAT_LAYER
		overlay.plane = FLOAT_PLANE
		overlay.blend_mode = BLEND_INSET_OVERLAY

		if(!stack_vertically)
			overlay.pixel_x = overlay_shifts[(count % overlay_shifts.len) + 1]

		count += 1

		. += overlay

	return .

/obj/structure/closet/gun_locker/Initialize(mapload)
	. = ..()
	if(mapload)
		RegisterSignal(SSdcs, COMSIG_GLOB_POST_START, PROC_REF(on_roundstart_update_overlays))

/obj/structure/closet/gun_locker/proc/on_roundstart_update_overlays()
	if(!isturf(loc))
		return

	update_appearance(UPDATE_OVERLAYS)

/obj/structure/closet/gun_locker/ballistic
	name = "\improper ballistic armory locker"
	desc = "A red-striped locker that smells faintly of gun oil, meant for top-shelf ballistic ordnance."
	icon_state = "guncase_ballistic"

/obj/structure/closet/gun_locker/energy
	name = "\improper energy armory locker"
	desc = "A yellow-striped locker that hums with leftover capacitor charge and a faint ozone tang. Likely contains energy weapons."
	icon_state = "guncase_energy"

/obj/structure/closet/gun_locker/armor_bulletproof
	name = "\improper ballistic armor locker"
	desc = "A green-striped locker lined with reinforced placards and hooks. Holds bulletproof vests and helmets."
	icon_state = "guncase_bulletarmor"

/obj/structure/closet/gun_locker/armor_riot
	name = "\improper riot armor locker"
	desc = "A dark green-striped locker, dented and battle-scarred. Stocked for crowd control and blunt-force diplomacy."
	icon_state = "guncase_riotarmor"

/obj/structure/closet/gun_locker/techgear
	name = "\improper tech gear locker"
	desc = "A blue-striped locker crammed with gimmicks. Temp-guns, reflector vests, and the like."
	icon_state = "guncase_techgear"

/obj/structure/closet/gun_locker/support
	name = "\improper support locker"
	desc = "A silver-striped locker stocked with all kinds of support gear."
	icon_state = "guncase_support"

/obj/structure/closet/gun_locker/boxes
	name = "\improper storage armory locker"
	desc = "A compact locker that has neat shelves meant for standard NT boxes of most kinds."
	icon_state = "guncase_boxes"

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
