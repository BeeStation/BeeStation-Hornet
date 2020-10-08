////////////////////////////////////////// COCKTAILS //////////////////////////////////////

/*      EXAMPLE of drink recipes ~ Kryyto ~

/datum/chemical_reaction/sarsaparilliansunset
	name = "Sarsaparillian Sunset"
	id = /datum/reagent/consumable/ethanol/sarsaparilliansunset
	results = list(/datum/reagent/consumable/ethanol/sarsaparilliansunset = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 5, /datum/reagent/consumable/nuka_cola = 1, /datum/reagent/napalm = 1)         Will be use
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)                                                                                             Will NOT be use
	required_temp = 320
	mix_message = "The mixture ignites."   
	mix_sound = 'sound/items/lighter_on.ogg'                                                                                                                    .ogg or .wav only       (ogg being like an mp3 on Groove)
*/

/datum/chemical_reaction/vodka_cola
    name = "Vodka Cola"
	id = /datum/reagent/consumable/ethanol/vodka_cola
	results = list(/datum/reagent/consumable/ethanol/vodka_cola = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/consumable/space_cola = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/consumable/soda_water = 1)                                                             
	mix_message = "Nothing special."   

/datum/chemical_reaction/salty_water
    name = "Salty water"
	id = /datum/reagent/consumable/salty_water
	results = list(/datum/reagent/consumable/salty_water = 5)
	required_reagents = list(/datum/reagent/consumable/water = 5, /datum/reagent/consumable/sodiumchloride = 1)
	required_reagents = list(/datum/reagent/consumable/water = 5, /datum/reagent/medicine/salglu_solution = 1)                                                             
	mix_message = "Nothing special."   

/datum/chemical_reaction/death_afternoon
    name = "Death in the afternoon"
	id = /datum/reagent/consumable/ethanol/death_afternoon
	results = list(/datum/reagent/consumable/ethanol/death_afternoon = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 3, /datum/reagent/consumable/ethanol/absinthe = 1)                                                       
	mix_message = "You felt a pain in your chest, you can't describe it."   

/datum/chemical_reaction/pina_colada
    name = "Piña colada"
	id = /datum/reagent/consumable/ethanol/pina_colada
	results = list(/datum/reagent/consumable/ethanol/pina_colada = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 5, /datum/reagent/consumable/coco = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/pineapplejuice = 5)                                                          
	mix_message = "Nothing that special."   

/datum/chemical_reaction/triple_coke
    name = "Triple coke"
	id = /datum/reagent/consumable/ethanol/triple_coke
	results = list(/datum/reagent/consumable/ethanol/triple_coke = 15)
	required_reagents = list(/datum/chemical_reaction/vodka_cola = 5, /datum/reagent/consumable/ethanol/whiskey_cola = 5, /datum/reagent/consumable/ethanol/rum_coke = 5)
	mix_message = "The reaction scream for a moment, then settle down."   

/datum/chemical_reaction/black_roulette
    name = "Black roulette"
	id = /datum/reagent/consumable/ethanol/black_roulette
	results = list(/datum/reagent/consumable/ethanol/black_roulette = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 5, /datum/reagent/medicine/strange_reagent = 1)                                                            
	mix_message = "You hear a mechanical sound coming from the drink."   