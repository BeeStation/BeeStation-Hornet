/obj/item/clothing/suit/toggle/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat"
	icon = 'icons/obj/clothing/suits/labcoat.dmi'
	worn_icon = 'icons/mob/clothing/suits/labcoat.dmi'
	inhand_icon_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|ARMS
	allowed = list(
		/obj/item/analyzer,
		/obj/item/stack/medical,
		/obj/item/storage/firstaid,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/paper,
		/obj/item/melee/baton/telescopic,
		/obj/item/soap,
		/obj/item/sensor_device,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman
		)
	armor_type = /datum/armor/toggle_labcoat
	species_exception = list(/datum/species/golem)


/datum/armor/toggle_labcoat
	bio = 50
	fire = 50
	acid = 50
	bleed = 5

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model. Issued to Chief Medical Officers, keeping them visible at all times among the sea of the wounded and other doctors."
	icon_state = "labcoat_cmo"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/paramedic
	name = "\improper EMT's jacket"
	desc = "A dark blue jacket with reflective strips for emergency medical technicians."
	icon_state = "labcoat_emt"
	inhand_icon_state = "labcoat_cmo"

/obj/item/clothing/suit/toggle/labcoat/brig_physician
	name = "security medic's labcoat"
	icon_state = "labcoat_sec"
	inhand_icon_state = "labcoat_sec"
	armor_type = /datum/armor/labcoat_brig_physician


/datum/armor/labcoat_brig_physician
	melee = 10
	bio = 10
	fire = 50
	acid = 50
	stamina = 30
	bleed = 10

/obj/item/clothing/suit/toggle/labcoat/mad
	name = "\proper The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen"
	inhand_icon_state = null

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem"

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir"

/obj/item/clothing/suit/toggle/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox"

/obj/item/clothing/suit/toggle/labcoat/research_director
	name = "research director's labcoat"
	desc = "Popped collar, ancient science fair medal, worn out buttons that barely keep the coat closed? Oh yeah, it's research time. Has expensive plasma-imbued fabric, making it resistant to spills."
	icon_state = "labcoat_rd"
	inhand_icon_state = "labcoat_tox"
