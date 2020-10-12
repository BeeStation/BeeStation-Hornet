/obj/item/integrated_circuit/reagent/storage/synthesizer
	name = "integrated reagent synthesizer"
	desc = "this circuit is capable of creating basic reagents"
	icon_state = "synthesizer"
	extended_desc = "circuit synthesizes 1u of any of these reagents, aliminum, bromine, carbon, chlorine, copper, ethanol, fluorine, hydrogen, iodine, iron, lithium, mercury, nitrogen, oxygen, phosphorus, potassium, radium, silicon, silver, sodium, stable_plasma, sugar, sulfur, acid, water, welding fuel. it has an internal storage of 30u"

	complexity = 25
	volume = 30
	cooldown_per_use = 1 SECONDS
	power_draw_per_use = 20000

	inputs = list("reagentname" = IC_PINTYPE_STRING,
		"synthesize" = IC_PINTYPE_BOOLEAN
		)
	outputs = list(
		"ammount used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)

	var/valid_reagents = list(
		"aluminium"		=	/datum/reagent/aluminium,
		"bromine"		=	/datum/reagent/bromine,
		"carbon"		=	/datum/reagent/carbon,
		"chlorine"		=	/datum/reagent/chlorine,
		"copper"		=	/datum/reagent/copper,
		"ethanol"		=	/datum/reagent/consumable/ethanol,
		"fluorine"		=	/datum/reagent/fluorine,
		"hydrogen"		=	/datum/reagent/hydrogen,
		"iodine"		=	/datum/reagent/iodine,
		"iron"			=	/datum/reagent/iron,
		"lithium"		=	/datum/reagent/lithium,
		"mercury"		=	/datum/reagent/mercury,
		"nitrogen"		=	/datum/reagent/nitrogen,
		"oxygen"		=	/datum/reagent/oxygen,
		"phosphorus"	=	/datum/reagent/phosphorus,
		"potassium"		=	/datum/reagent/potassium,
		"radium"		=	/datum/reagent/uranium/radium,
		"silicon"		=	/datum/reagent/silicon,
		"silver"		=	/datum/reagent/silver,
		"sodium"		=	/datum/reagent/sodium,
		"stable_plasma"	=	/datum/reagent/stable_plasma,
		"sugar"			=	/datum/reagent/consumable/sugar,
		"sulfure"		=	/datum/reagent/sulfur,
		"acid"			=	/datum/reagent/toxin/acid,
		"water"			=	/datum/reagent/water,
		"fuel"			=	/datum/reagent/fuel
	)

/obj/item/integrated_circuit/reagent/storage/synthesizer/do_work()
	. = ..()
	if(get_pin_data(IC_INPUT,2))
		reagents.add_reagent(valid_reagents[get_pin_data(IC_INPUT,1)],1)
	push_vol()
	push_data()
