/obj/item/grenade/chem_grenade/premade
	name = "grenade"
	desc = "A premade made grenade."
	icon_state = "flashbang"
	item_state = "flashbang"

//////////////////////////////
////// PREMADE GRENADES //////
//////////////////////////////

/obj/item/grenade/chem_grenade/premade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of hull breaches."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/metalfoam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/aluminium, 30)
	beaker_two.reagents.add_reagent(/datum/reagent/foaming_agent, 10)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 10)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/premade/smart_metal_foam
	name = "smart metal foam grenade"
	desc = "Used for emergency sealing of hull breaches, while keeping areas accessible."
	stage = GRENADE_READY


/obj/item/grenade/chem_grenade/premade/smart_metal_foam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/aluminium, 75)
	beaker_two.reagents.add_reagent(/datum/reagent/smart_foaming_agent, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/premade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/incendiary/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/stable_plasma, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/premade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/antiweed/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/toxin/plantbgone, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/premade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/cleaner/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/fluorosurfactant, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/water, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/space_cleaner, 10)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/premade/ez_clean
	name = "cleaner grenade"
	desc = "Waffle Co.-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/ez_clean/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/fluorosurfactant, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/water, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/space_cleaner/ez_clean, 60) //ensures a  t h i c c  distribution

	beakers += beaker_one
	beakers += beaker_two



/obj/item/grenade/chem_grenade/premade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/teargas/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 60)
	B1.reagents.add_reagent(/datum/reagent/potassium, 40)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 40)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/premade/facid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/facid/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 290)
	B1.reagents.add_reagent(/datum/reagent/potassium, 10)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 10)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 10)
	B2.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 280)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/premade/colorful
	name = "colorful grenade"
	desc = "Used for wide scale painting projects."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/colorful/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/colorful_reagent, 25)
	B1.reagents.add_reagent(/datum/reagent/potassium, 25)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/glitter
	name = "generic glitter grenade"
	desc = "You shouldn't see this description."
	stage = GRENADE_READY
	var/glitter_type = /datum/reagent/glitter

/obj/item/grenade/chem_grenade/premade/glitter/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/B2 = new(src)

	B1.reagents.add_reagent(glitter_type, 25)
	B1.reagents.add_reagent(/datum/reagent/potassium, 25)
	B2.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/glitter/pink
	name = "pink glitter bomb"
	desc = "For that HOT glittery look."
	glitter_type = /datum/reagent/glitter/pink

/obj/item/grenade/chem_grenade/premade/glitter/blue
	name = "blue glitter bomb"
	desc = "For that COOL glittery look."
	glitter_type = /datum/reagent/glitter/blue

/obj/item/grenade/chem_grenade/premade/glitter/white
	name = "white glitter bomb"
	desc = "For that somnolent glittery look."
	glitter_type = /datum/reagent/glitter/white

/obj/item/grenade/chem_grenade/premade/clf3
	name = "clf3 grenade"
	desc = "BURN!-brand foaming clf3. In a special applicator for rapid purging of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/clf3/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/fluorosurfactant, 250)
	B1.reagents.add_reagent(/datum/reagent/clf3, 50)
	B2.reagents.add_reagent(/datum/reagent/water, 250)
	B2.reagents.add_reagent(/datum/reagent/clf3, 50)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/bioterrorfoam
	name = "Bio terror foam grenade"
	desc = "Tiger Cooperative chemical foam grenade. Causes temporary irration, blindness, confusion, mutism, and mutations to carbon based life forms. Contains additional spore toxin."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/bioterrorfoam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/cryptobiolin, 75)
	B1.reagents.add_reagent(/datum/reagent/water, 50)
	B1.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 50)
	B1.reagents.add_reagent(/datum/reagent/toxin/spore, 75)
	B1.reagents.add_reagent(/datum/reagent/toxin/itching_powder, 50)
	B2.reagents.add_reagent(/datum/reagent/fluorosurfactant, 150)
	B2.reagents.add_reagent(/datum/reagent/toxin/mutagen, 150)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/tuberculosis
	name = "Fungal tuberculosis grenade"
	desc = "WARNING: GRENADE WILL RELEASE DEADLY SPORES CONTAINING ACTIVE AGENTS. SEAL SUIT AND AIRFLOW BEFORE USE."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/tuberculosis/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/potassium, 50)
	B1.reagents.add_reagent(/datum/reagent/phosphorus, 50)
	B1.reagents.add_reagent(/datum/reagent/fungalspores, 200)
	B2.reagents.add_reagent(/datum/reagent/blood, 250)
	B2.reagents.add_reagent(/datum/reagent/consumable/sugar, 50)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/holy
	name = "holy hand grenade"
	desc = "A vessel of concentrated religious might."
	icon_state = "holy_grenade"
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/holy/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/potassium, 100)
	B2.reagents.add_reagent(/datum/reagent/water/holywater, 100)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/premade/ghostbuster
	name = "counterparanormal foam grenade"
	desc = "The note on the side guarantees to ward off most malicious spirits from covered area.\ The grenade itself seems to be old and covered with dust."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/premade/ghostbuster/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/cup/beaker/large/B2 = new(src)

	B1.reagents.add_reagent(/datum/reagent/fluorosurfactant, 50)
	B1.reagents.add_reagent(/datum/reagent/water/holywater, 50)
	B2.reagents.add_reagent(/datum/reagent/water, 50)
	B2.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 50)

	beakers += B1
	beakers += B2
