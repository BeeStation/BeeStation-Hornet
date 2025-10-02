/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */

//First Aid kit
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon = 'icons/obj/storage/medkit.dmi'
	icon_state = "firstaid"
	inhand_icon_state = "firstaid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_LARGE
	var/skin_type = MEDBOT_SKIN_DEFAULT

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/regular/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/firstaid/regular/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/medipen = 2)
	generate_items_inside(items_inside,src)

//Compact First Aid kit
/obj/item/storage/firstaid/compact
	name = "compact first-aid kit"
	desc = "A compact first aid kit designed for treating common injuries found in the field."
	w_class = WEIGHT_CLASS_NORMAL //Intended to be used by ERTs or other uncommon roles

/obj/item/storage/firstaid/compact/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/medipen = 2)
	generate_items_inside(items_inside,src)

//First MD kit
/obj/item/storage/firstaid/medical
	name = "doctor's bag"
	icon_state = "firstaid-surgeryalt"
	inhand_icon_state = "firstaid-surgeryalt"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "firstaid_surgeryalt"
	desc = "A fancy high capacity aid kit for doctors, full of medical supplies and basic surgical equipment"
	skin_type = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/firstaid/medical/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY //holds the same equipment as a medibelt
	atom_storage.max_slots = 12
	atom_storage.max_total_storage = 24
	atom_storage.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical
		))

/obj/item/storage/firstaid/medical/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/medical/paramedic
	name = "paramedics medical bag"
	icon_state = "firstaid-surgeryalt"
	inhand_icon_state = "firstaid-surgeryalt"
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "firstaid_surgeryalt"
	desc = "A not-so fancy high capacity aid kit for paramedics, filled with 'top of the line' medical supplies."
	skin_type = null
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT

/obj/item/storage/firstaid/medical/paramedic/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY //holds the same equipment as a medibelt
	atom_storage.max_slots = 12
	atom_storage.max_total_storage = 24
	atom_storage.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/lighter,
		/obj/item/weldingtool/mini,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/rollerbed
		))


/obj/item/storage/firstaid/medical/paramedic/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/reagent_containers/cup/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/rollerbed = 1,
		/obj/item/weldingtool/mini = 1, // stopping IPC bleeding while delivering them to robotics (STOP DELIVERING IPCS TO MEDBAY I SWEAR TO GOD) -doc
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 2,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/medical/physician
	name = "brig physicians bag"
	desc = "A specialized doctors bag, specifically meant for healing security when they get beaten to death by a unarmed prisoner."

/obj/item/storage/firstaid/medical/physician/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 2,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/hypospray/medipen/ = 2,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/healthanalyzer = 1,)
	generate_items_inside(items_inside,src)

//First Aid kit (ancient)
/obj/item/storage/firstaid/ancient
	icon_state = "firstaid-old"
	desc = "A first aid kit with the ability to heal common types of injuries."
	skin_type = null

/obj/item/storage/firstaid/ancient/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 2,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment= 3)
	generate_items_inside(items_inside,src)


//First burn kit
/obj/item/storage/firstaid/fire
	name = "burn treatment kit"
	desc = "A specialized medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "firstaid-burn"
	inhand_icon_state = "firstaid-burn"
	skin_type = MEDBOT_SKIN_BURN

/obj/item/storage/firstaid/fire/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins rubbing \the [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to start a fire!"))
	return FIRELOSS

/obj/item/storage/firstaid/fire/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-burn","firstaid-burnalt")

/obj/item/storage/firstaid/fire/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 4,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/stack/medical/ointment = 2)
	generate_items_inside(items_inside,src)


//First toxin kit
/obj/item/storage/firstaid/toxin
	name = "toxin treatment kit"
	desc = "Used to treat toxic blood content and radiation poisoning."
	icon_state = "firstaid-toxin"
	inhand_icon_state = "firstaid-toxin"
	skin_type = MEDBOT_SKIN_TOXIN

/obj/item/storage/firstaid/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-toxin","firstaid-toxinalt")

/obj/item/storage/firstaid/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/antitoxin = 4,
		/obj/item/reagent_containers/syringe/calomel = 1,
		/obj/item/reagent_containers/syringe/diphenhydramine = 1,
		/obj/item/storage/pill_bottle/charcoal = 1)
	generate_items_inside(items_inside,src)


//First radiation kit
/obj/item/storage/firstaid/radbgone
	name = "radiation treatment kit"
	desc = "Used to treat minor toxic blood content and major radiation poisoning."
	icon_state = "firstaid-rad"
	inhand_icon_state = "firstaid-rad"
	skin_type = MEDBOT_SKIN_RADIATION

/obj/item/storage/firstaid/radbgone/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/firstaid/radbgone/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/antirad_plus = 2,
		/obj/item/reagent_containers/pill/antirad = 2,
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/storage/pill_bottle/penacid = 1,
		/obj/item/reagent_containers/pill/mutarad = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/radbgone/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-rad","firstaid-radalt")

//First airloss kit
/obj/item/storage/firstaid/o2
	name = "oxygen deprivation treatment kit"
	desc = "A box full of oxygen goodies."
	icon_state = "firstaid-o2"
	inhand_icon_state = "firstaid-o2"

/obj/item/storage/firstaid/o2/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/firstaid/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/salbutamol = 1,
		/obj/item/reagent_containers/hypospray/medipen = 3,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/o2/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-o2","firstaid-o2alt")


//First brute kit
/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A first aid kit for when you get toolboxed."
	icon_state = "firstaid-brute"
	inhand_icon_state = "firstaid-brute"
	skin_type = MEDBOT_SKIN_BRUTE

/obj/item/storage/firstaid/brute/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins beating [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/firstaid/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/styptic = 4,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/gauze = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/brute/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-brute","firstaid-brutealt")


//First Advanced kit
/obj/item/storage/firstaid/advanced
	name = "advanced first aid kit"
	desc = "An advanced kit to help deal with advanced wounds."
	icon_state = "firstaid-advanced"
	inhand_icon_state = "firstaid-advanced"
	custom_premium_price = 600
	skin_type = MEDBOT_SKIN_ADVANCED

/obj/item/storage/firstaid/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 3,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/penacid = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/advanced/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-advanced","firstaid-advancedalt")

//Compact First Advanced kit
/obj/item/storage/firstaid/advanced/compact
	name = "compact advanced first aid kit"
	desc = "A compact advanced first aid kit designed for treating severe injuries found in the field."
	w_class = WEIGHT_CLASS_NORMAL //Intended to be used by ERTs or other uncommon roles

//First Random kit
/obj/item/storage/firstaid/random
	name = "mystery medical kit"
	desc = "Are you feeling lucky today?"
	icon_state = "firstaid-mystery"
	inhand_icon_state = "firstaid-mystery"
	skin_type = NONE

/obj/item/storage/firstaid/random/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/random/PopulateContents()
	if(empty)
		return
	var/supplies = list(
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/reagent_containers/pill/patch/synthflesh,
		/obj/item/reagent_containers/hypospray/medipen/atropine,
		/obj/item/storage/pill_bottle/penacid,
		/obj/item/reagent_containers/pill/patch/styptic,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/reagent_containers/pill/salbutamol,
		/obj/item/reagent_containers/hypospray/medipen/dexalin,
		/obj/item/reagent_containers/pill/mutadone,
		/obj/item/reagent_containers/pill/antirad,
		/obj/item/reagent_containers/syringe/antitoxin,
		/obj/item/reagent_containers/syringe/calomel,
		/obj/item/reagent_containers/syringe/diphenhydramine,
		/obj/item/storage/pill_bottle/charcoal,
		/obj/item/reagent_containers/pill/patch/silver_sulf,
		/obj/item/storage/pill_bottle/kelotane)
	for(var/i in 1 to 6)
		var/selected_type = pick(supplies)
		new selected_type(src)

//First Tactical kit
/obj/item/storage/firstaid/tactical
	name = "combat medical kit"
	desc = "I hope you've got insurance."
	icon_state = "firstaid-combat"
	inhand_icon_state = "firstaid-combat"
	skin_type = MEDBOT_SKIN_SYNDI
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/tactical/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-combat","firstaid-combatalt")

/obj/item/storage/firstaid/tactical/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_LARGE
	atom_storage.max_slots = 7
	atom_storage.max_total_storage = 56 //any combination of allowed items

	//Surgical tools, medkit supplies, compact defibrillator and a few odds and ends but not as much as medbelt
	atom_storage.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/hypospray,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/defibrillator/compact
		))


/obj/item/storage/firstaid/tactical/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/defibrillator/compact/combat/loaded = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/reagent_containers/pill/patch/styptic = 2,
		/obj/item/reagent_containers/pill/patch/silver_sulf = 2,
		/obj/item/clothing/glasses/hud/health/night = 1)
	generate_items_inside(items_inside,src)

//infiltrator kit, buyable by traitors
/obj/item/storage/firstaid/infiltrator
	name = "infiltrator medical kit"
	desc = "(Un)fortunately for you, the Syndicate has a good medical plan."
	icon_state = "firstaid-combat"
	inhand_icon_state = "firstaid-combat"
	skin_type = MEDBOT_SKIN_SYNDI
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/infiltrator/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 2,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

//medibot assembly
/obj/item/storage/firstaid/attackby(obj/item/bodypart/S, mob/user, params)
	if((!istype(S, /obj/item/bodypart/arm/left/robot)) && (!istype(S, /obj/item/bodypart/arm/right/robot)))
		return ..()

	//Making a medibot!
	if(contents.len >= 1)
		to_chat(user, span_warning("You need to empty [src] out first!"))
		return

	if(!src.skin_type)
		to_chat(user, span_warning("[src] cannot be used to make a medibot!"))
		return

	var/obj/item/bot_assembly/medbot/A = new
	A.skin = src.skin_type


	user.put_in_hands(A)
	to_chat(user, span_notice("You add [S] to [src]."))
	A.robot_arm = S.type
	A.firstaid = type
	qdel(S)
	qdel(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister_0"
	icon = 'icons/obj/medicine_containers.dmi'
	inhand_icon_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = UNIQUE_RENAME
	var/pill_variance = 100 //probability pill_bottle has a different icon state. Put at 0 for no variance
	var/pill_type = "pill_canister_"

/obj/item/storage/pill_bottle/Initialize(mapload)
	. = ..()
	if(prob(pill_variance))
		icon_state = "[pill_type][rand(0,6)]"

/obj/item/storage/pill_bottle/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/reagent_containers/pill))

/obj/item/storage/pill_bottle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/pill_bottle/charcoal
	name = "bottle of charcoal pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/charcoal/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/bicaridine
	name = "bottle of bicaridine pills"
	desc = "Contains pills used to treat moderate to small brute injuries."

/obj/item/storage/pill_bottle/bicaridine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/bicaridine(src)

/obj/item/storage/pill_bottle/kelotane
	name = "bottle of kelotane pills"
	desc = "Contains pills used to treat moderate to small burns."

/obj/item/storage/pill_bottle/kelotane/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/kelotane(src)

/obj/item/storage/pill_bottle/antirad
	name = "bottle of anti-radiation pills"
	desc = "Contains pills used to treat the effects of minor radiation."

/obj/item/storage/pill_bottle/antirad/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/antirad(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/epinephrine(src)

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mutadone(src)

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mannitol(src)

/obj/item/storage/pill_bottle/mannitol/braintumor //For the brain tumor quirk
	desc = "Generously supplied by your Nanotrasen health insurance to treat that pesky tumor in your brain."

/obj/item/storage/pill_bottle/mannitol/braintumor/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/mannitol/braintumor(src)

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/stimulant(src)

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/patch/styptic(src)

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aranesp(src)

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psicodine(src)

/obj/item/storage/pill_bottle/happiness
	name = "happiness pill bottle"
	desc = "The label is long gone, in its place an 'H' written with a marker."

/obj/item/storage/pill_bottle/happiness/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happiness(src)

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid pills"
	desc = "Contains pills to expunge radiation and toxins."

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/penacid(src)


/obj/item/storage/pill_bottle/neurine
	name = "bottle of neurine pills"
	desc = "Contains pills to treat non-severe mental traumas."

/obj/item/storage/pill_bottle/neurine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/neurine(src)

/obj/item/storage/pill_bottle/floorpill
	name = "bottle of floorpills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/floorpill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/floorpill/PopulateContents()
	for(var/i in 1 to rand(1,7))
		new /obj/item/reagent_containers/pill/floorpill(src)

/obj/item/storage/pill_bottle/floorpill/full/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/floorpill(src)

/obj/item/storage/pill_bottle/salbutamol
	name = "bottle of salbutamol pills"
	desc = "Contains pills to heal suffocation damage."

/obj/item/storage/pill_bottle/salbutamol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/salbutamol(src)
