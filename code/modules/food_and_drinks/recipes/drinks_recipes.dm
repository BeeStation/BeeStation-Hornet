////////////////////////////////////////// COCKTAILS //////////////////////////////////////


/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	results = list(/datum/reagent/consumable/ethanol/goldschlager = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/gold = 1)

/datum/chemical_reaction/patron
	name = "Patron"
	results = list(/datum/reagent/consumable/ethanol/patron = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 10, /datum/reagent/silver = 1)

/datum/chemical_reaction/bilk
	name = "Bilk"
	results = list(/datum/reagent/consumable/ethanol/bilk = 2)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/ethanol/beer = 1)

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	results = list(/datum/reagent/consumable/icetea = 4)
	required_reagents = list(/datum/reagent/consumable/ice = 1, /datum/reagent/consumable/tea = 3)

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	results = list(/datum/reagent/consumable/icecoffee = 4)
	required_reagents = list(/datum/reagent/consumable/ice = 1, /datum/reagent/consumable/coffee = 3)

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	results = list(/datum/reagent/consumable/nuka_cola = 6)
	required_reagents = list(/datum/reagent/uranium = 1, /datum/reagent/consumable/space_cola = 6)

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	results = list(/datum/reagent/consumable/ethanol/moonshine = 10)
	required_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/wine
	name = "Wine"
	results = list(/datum/reagent/consumable/ethanol/wine = 10)
	required_reagents = list(/datum/reagent/consumable/grapejuice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	results = list(/datum/reagent/consumable/ethanol/beer = 10)
	required_reagents = list(/datum/reagent/consumable/flour = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/vodka
	name = "Vodka"
	results = list(/datum/reagent/consumable/ethanol/vodka = 10)
	required_reagents = list(/datum/reagent/consumable/potato_juice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	results = list(/datum/reagent/consumable/ethanol/kahlua = 5)
	required_reagents = list(/datum/reagent/consumable/coffee = 5, /datum/reagent/consumable/sugar = 5)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	results = list(/datum/reagent/consumable/ethanol/gintonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/tonic = 1)

/datum/chemical_reaction/rum_coke
	name = "Rum and Coke"
	results = list(/datum/reagent/consumable/ethanol/rum_coke = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/space_cola = 1)

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	results = list(/datum/reagent/consumable/ethanol/cuba_libre = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum_coke = 3, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/martini
	name = "Classic Martini"
	results = list(/datum/reagent/consumable/ethanol/martini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	results = list(/datum/reagent/consumable/ethanol/vodkamartini = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/white_russian
	name = "White Russian"
	results = list(/datum/reagent/consumable/ethanol/white_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 3, /datum/reagent/consumable/cream = 2)

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	results = list(/datum/reagent/consumable/ethanol/whiskey_cola = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/space_cola = 1)

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	results = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	results = list(/datum/reagent/consumable/ethanol/bloody_mary = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/tomatojuice = 2, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	results = list(/datum/reagent/consumable/ethanol/gargle_blaster = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	results = list(/datum/reagent/consumable/ethanol/brave_bull = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/ethanol/kahlua = 1)

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	results = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/orangejuice = 2, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	results = list(/datum/reagent/consumable/ethanol/toxins_special = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/toxin/plasma = 2)

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	results = list(/datum/reagent/consumable/ethanol/beepsky_smash = 5)
	required_reagents = list(/datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/ethanol/quadruple_sec = 2, /datum/reagent/iron = 1)

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	results = list(/datum/reagent/consumable/doctor_delight = 5)
	required_reagents = list(/datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/consumable/orangejuice = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/medicine/cryoxadone = 1)

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	results = list(/datum/reagent/consumable/ethanol/irish_cream = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	results = list(/datum/reagent/consumable/ethanol/manly_dorf = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/ale = 2)

/datum/chemical_reaction/greenbeer
	name = "Green Beer"
	results = list(/datum/reagent/consumable/ethanol/beer/green = 10)
	required_reagents = list(/datum/reagent/colorful_reagent/powder/green = 1, /datum/reagent/consumable/ethanol/beer = 10)

/datum/chemical_reaction/greenbeer2 //apparently there's no other way to do this
	name = "Green Beer"
	results = list(/datum/reagent/consumable/ethanol/beer/green = 10)
	required_reagents = list(/datum/reagent/colorful_reagent/powder/green/crayon = 1, /datum/reagent/consumable/ethanol/beer = 10)

/datum/chemical_reaction/hooch
	name = "Hooch"
	results = list(/datum/reagent/consumable/ethanol/hooch = 3)
	required_reagents = list (/datum/reagent/consumable/ethanol = 2, /datum/reagent/fuel = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	results = list(/datum/reagent/consumable/ethanol/irishcoffee = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/coffee = 1)

/datum/chemical_reaction/b52
	name = "B-52"
	results = list(/datum/reagent/consumable/ethanol/b52 = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/cognac = 1)

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	results = list(/datum/reagent/consumable/ethanol/atomicbomb = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/b52 = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/margarita
	name = "Margarita"
	results = list(/datum/reagent/consumable/ethanol/margarita = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila = 2, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	results = list(/datum/reagent/consumable/ethanol/longislandicedtea = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/cuba_libre = 1)

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	results = list(/datum/reagent/consumable/ethanol/threemileisland = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/longislandicedtea = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	results = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/sodawater = 1)

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	results = list(/datum/reagent/consumable/ethanol/black_russian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 3, /datum/reagent/consumable/ethanol/kahlua = 2)

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	results = list(/datum/reagent/consumable/ethanol/manhattan = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	results = list(/datum/reagent/consumable/ethanol/manhattan_proj = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 10, /datum/reagent/uranium = 1)

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	results = list(/datum/reagent/consumable/ethanol/vodkatonic = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/tonic = 1)

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	results = list(/datum/reagent/consumable/ethanol/ginfizz = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/bahama_mama
	name = "Bahama Mama"
	results = list(/datum/reagent/consumable/ethanol/bahama_mama = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/pineapplejuice = 1)

/datum/chemical_reaction/painkiller
	name = "Painkiller"
	results = list(/datum/reagent/consumable/ethanol/painkiller = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 5, /datum/reagent/consumable/pineapplejuice = 4, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/pina_colada
	name = "Pina Colada"
	results = list(/datum/reagent/consumable/ethanol/pina_colada = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_coconut = 1, /datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/singulo
	name = "Singulo"
	results = list(/datum/reagent/consumable/ethanol/singulo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/uranium/radium = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	results = list(/datum/reagent/consumable/ethanol/alliescocktail = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	results = list(/datum/reagent/consumable/ethanol/demonsblood = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/spacemountainwind = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/dr_gibb = 1)

/datum/chemical_reaction/booger
	name = "Booger"
	results = list(/datum/reagent/consumable/ethanol/booger = 4)
	required_reagents = list(/datum/reagent/consumable/cream = 1, /datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/watermelonjuice = 1)

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	results = list(/datum/reagent/consumable/ethanol/antifreeze = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 2, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	results = list(/datum/reagent/consumable/ethanol/barefoot = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/ftliver
	name = "Faster-Than-Liver"
	results = list(/datum/reagent/consumable/ethanol/ftliver = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/consumable/ethanol/screwdrivercocktail = 1)


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	results = list(/datum/reagent/consumable/ethanol/sbiten = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 10, /datum/reagent/consumable/capsaicin = 1)

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	results = list(/datum/reagent/consumable/ethanol/red_mead = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/mead = 1)

/datum/chemical_reaction/mead
	name = "Mead"
	results = list(/datum/reagent/consumable/ethanol/mead = 2)
	required_reagents = list(/datum/reagent/consumable/honey = 2)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	results = list(/datum/reagent/consumable/ethanol/iced_beer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 5, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/grog
	name = "Grog"
	results = list(/datum/reagent/consumable/ethanol/grog = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	results = list(/datum/reagent/consumable/soy_latte = 2)
	required_reagents = list(/datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/soymilk = 1)

/datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	results = list(/datum/reagent/consumable/cafe_latte = 2)
	required_reagents = list(/datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/milk = 1)

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	results = list(/datum/reagent/consumable/ethanol/acid_spit = 6)
	required_reagents = list(/datum/reagent/toxin/acid = 1, /datum/reagent/consumable/ethanol/wine = 5)

/datum/chemical_reaction/amasec
	name = "Amasec"
	results = list(/datum/reagent/consumable/ethanol/amasec = 10)
	required_reagents = list(/datum/reagent/iron = 1, /datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/vodka = 5)

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	results = list(/datum/reagent/consumable/ethanol/changelingsting = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/screwdrivercocktail = 1, /datum/reagent/consumable/lemon_lime = 2)

/datum/chemical_reaction/aloe
	name = "Aloe"
	results = list(/datum/reagent/consumable/ethanol/aloe = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/watermelonjuice = 1)

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	results = list(/datum/reagent/consumable/ethanol/andalusia = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	results = list(/datum/reagent/consumable/ethanol/neurotoxin = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/gargle_blaster = 1, /datum/reagent/medicine/morphine = 1)

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	results = list(/datum/reagent/consumable/ethanol/snowwhite = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/lemon_lime = 1)

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	results = list(/datum/reagent/consumable/ethanol/irishcarbomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/ethanol/irish_cream = 1)

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	results = list(/datum/reagent/consumable/ethanol/syndicatebomb = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/consumable/ethanol/whiskey_cola = 1)

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	results = list(/datum/reagent/consumable/ethanol/erikasurprise = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	results = list(/datum/reagent/consumable/ethanol/devilskiss = 3)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/rum = 1)

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	results = list(/datum/reagent/consumable/ethanol/hippies_delight = 2)
	required_reagents = list(/datum/reagent/drug/mushroomhallucinogen = 1, /datum/reagent/consumable/ethanol/gargle_blaster = 1)

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	results = list(/datum/reagent/consumable/ethanol/bananahonk = 2)
	required_reagents = list(/datum/reagent/consumable/laughter = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/silencer
	name = "Silencer"
	results = list(/datum/reagent/consumable/ethanol/silencer = 3)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	results = list(/datum/reagent/consumable/ethanol/driestmartini = 2)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/ethanol/gin = 1)

/datum/chemical_reaction/thirteenloko
	name = "Thirteen Loko"
	results = list(/datum/reagent/consumable/ethanol/thirteenloko = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/coffee = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/chocolatepudding
	name = "Chocolate Pudding"
	results = list(/datum/reagent/consumable/chocolatepudding = 20)
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 10, /datum/reagent/consumable/eggyolk = 5)

/datum/chemical_reaction/vanillapudding
	name = "Vanilla Pudding"
	results = list(/datum/reagent/consumable/vanillapudding = 20)
	required_reagents = list(/datum/reagent/consumable/vanilla = 5, /datum/reagent/consumable/milk = 5, /datum/reagent/consumable/eggyolk = 5)

/datum/chemical_reaction/cherryshake
	name = "Cherry Shake"
	results = list(/datum/reagent/consumable/cherryshake = 5)
	required_reagents = list(/datum/reagent/consumable/cherryjelly = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/bluecherryshake
	name = "Blue Cherry Shake"
	results = list(/datum/reagent/consumable/bluecherryshake = 5)
	required_reagents = list(/datum/reagent/consumable/bluecherryjelly = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/vanillashake
	name = "Vanilla Milkshake"
	results = list(/datum/reagent/consumable/vanillashake = 5)
	required_reagents = list(/datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/caramelshake
	name = "Caramel Milkshake"
	results = list(/datum/reagent/consumable/caramelshake = 5)
	required_reagents = list(/datum/reagent/consumable/caramel = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1, /datum/reagent/consumable/sodiumchloride = 1)

/datum/chemical_reaction/drink/choccyshake
	name = "Chocolate Milkshake"
	results = list(/datum/reagent/consumable/choccyshake = 5)
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/strawberryshake
	name = "Strawberry Milkshake"
	results = list(/datum/reagent/consumable/strawberryshake = 5)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drink/bananashake
	name = "Banana Milkshake"
	results = list(/datum/reagent/consumable/bananashake = 5)
	required_reagents = list(/datum/reagent/consumable/banana = 1, /datum/reagent/consumable/milk = 3, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/drunkenblumpkin
	name = "Drunken Blumpkin"
	results = list(/datum/reagent/consumable/ethanol/drunkenblumpkin = 4)
	required_reagents = list(/datum/reagent/consumable/blumpkinjuice = 1, /datum/reagent/consumable/ethanol/irish_cream = 2, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/pumpkin_latte
	name = "Pumpkin space latte"
	results = list(/datum/reagent/consumable/pumpkin_latte = 15)
	required_reagents = list(/datum/reagent/consumable/pumpkinjuice = 5, /datum/reagent/consumable/coffee = 5, /datum/reagent/consumable/cream = 5)

/datum/chemical_reaction/gibbfloats
	name = "Gibb Floats"
	results = list(/datum/reagent/consumable/gibbfloats = 15)
	required_reagents = list(/datum/reagent/consumable/dr_gibb = 5, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/cream = 5)

/datum/chemical_reaction/triple_citrus
	name = /datum/reagent/consumable/triple_citrus
	results = list(/datum/reagent/consumable/triple_citrus = 5)
	required_reagents = list(/datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/orangejuice = 1)

/datum/chemical_reaction/grape_soda
	name = "grape soda"
	results = list(/datum/reagent/consumable/grape_soda = 2)
	required_reagents = list(/datum/reagent/consumable/grapejuice = 1, /datum/reagent/consumable/sodawater = 1)

/datum/chemical_reaction/grappa
	name = /datum/reagent/consumable/ethanol/grappa
	results = list(/datum/reagent/consumable/ethanol/grappa = 10)
	required_reagents = list (/datum/reagent/consumable/ethanol/wine = 10)
	required_catalysts = list (/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/whiskey_sour
	name = "Whiskey Sour"
	results = list(/datum/reagent/consumable/ethanol/whiskey_sour = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/sugar = 1)
	mix_message = "The mixture darkens to a rich gold hue."

/datum/chemical_reaction/fetching_fizz
	name = "Fetching Fizz"
	results = list(/datum/reagent/consumable/ethanol/fetching_fizz = 3)
	required_reagents = list(/datum/reagent/consumable/nuka_cola = 1, /datum/reagent/iron = 1) //Manufacturable from only the mining station
	mix_message = "The mixture slightly vibrates before settling."

/datum/chemical_reaction/hearty_punch
	name = "Hearty Punch"
	results = list(/datum/reagent/consumable/ethanol/hearty_punch = 1)  //Very little, for balance reasons
	required_reagents = list(/datum/reagent/consumable/ethanol/brave_bull = 5, /datum/reagent/consumable/ethanol/syndicatebomb = 5, /datum/reagent/consumable/ethanol/absinthe = 5)
	mix_message = "The mixture darkens to a healthy crimson."
	required_temp = 315 //Piping hot!

/datum/chemical_reaction/bacchus_blessing
	name = "Bacchus' Blessing"
	results = list(/datum/reagent/consumable/ethanol/bacchus_blessing = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/hooch = 1, /datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/ethanol/manly_dorf = 1, /datum/reagent/consumable/ethanol/syndicatebomb = 1)
	mix_message = span_warning("The mixture turns to a sickening froth.")

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	results = list(/datum/reagent/consumable/lemonade = 5)
	required_reagents = list(/datum/reagent/consumable/lemonjuice = 2, /datum/reagent/water = 2, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ice = 1)
	mix_message = "You're suddenly reminded of home."

/datum/chemical_reaction/arnold_palmer
	name = "Arnold Palmer"
	results = list(/datum/reagent/consumable/tea/arnold_palmer = 2)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/consumable/lemonade = 1)
	mix_message = "The smells of fresh green grass and sand traps waft through the air as the mixture turns a friendly yellow-orange."

/datum/chemical_reaction/chocolate_milk
	name = "chocolate milk"
	results = list(/datum/reagent/consumable/milk/chocolate_milk = 2)
	required_reagents = list(/datum/reagent/consumable/milk = 1, /datum/reagent/consumable/cocoa = 1)
	mix_message = "The color changes as the mixture blends smoothly."

/datum/chemical_reaction/hot_cocoa
	name = "Hot Coco"
	results = list(/datum/reagent/consumable/hot_cocoa = 6)
	required_reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/cocoa = 1)
	required_temp = 320

/datum/chemical_reaction/coffee
	name = "Coffee"
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/tea
	name = "Tea"
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/eggnog
	name = /datum/reagent/consumable/ethanol/eggnog
	results = list(/datum/reagent/consumable/ethanol/eggnog = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 5, /datum/reagent/consumable/cream = 5, /datum/reagent/consumable/eggyolk = 5)

/datum/chemical_reaction/narsour
	name = "Nar'sour"
	results = list(/datum/reagent/consumable/ethanol/narsour = 1)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/demonsblood = 1)
	mix_message = "The mixture develops a sinister glow."
	mix_sound = 'sound/effects/singlebeat.ogg'

/datum/chemical_reaction/quadruplesec
	name = "Quadruple Sec"
	results = list(/datum/reagent/consumable/ethanol/quadruple_sec = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 5, /datum/reagent/consumable/triple_citrus = 5, /datum/reagent/consumable/ethanol/creme_de_menthe = 5)
	mix_message = "The snap of a taser emanates clearly from the mixture as it settles."
	mix_sound = 'sound/weapons/taser.ogg'

/datum/chemical_reaction/grasshopper
	name = "Grasshopper"
	results = list(/datum/reagent/consumable/ethanol/grasshopper = 15)
	required_reagents = list(/datum/reagent/consumable/cream = 5, /datum/reagent/consumable/ethanol/creme_de_menthe = 5, /datum/reagent/consumable/ethanol/creme_de_cacao = 5)
	mix_message = "A vibrant green bubbles forth as the mixture emulsifies."

/datum/chemical_reaction/stinger
	name = "Stinger"
	results = list(/datum/reagent/consumable/ethanol/stinger = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 10, /datum/reagent/consumable/ethanol/creme_de_menthe = 5 )

/datum/chemical_reaction/quintuplesec
	name = "Quintuple Sec"
	results = list(/datum/reagent/consumable/ethanol/quintuple_sec = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/quadruple_sec = 5, /datum/reagent/consumable/clownstears = 5, /datum/reagent/consumable/ethanol/syndicatebomb = 5)
	mix_message = "Judgment is upon you."
	mix_sound = 'sound/items/airhorn2.ogg'

/datum/chemical_reaction/bastion_bourbon
	name = "Bastion Bourbon"
	results = list(/datum/reagent/consumable/ethanol/bastion_bourbon = 2)
	required_reagents = list(/datum/reagent/consumable/tea = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/berryjuice = 1) //herbal and minty, with a hint of citrus and berry
	mix_message = "You catch an aroma of hot tea and fruits as the mix blends into a blue-green color."

/datum/chemical_reaction/squirt_cider
	name = "Squirt Cider"
	results = list(/datum/reagent/consumable/ethanol/squirt_cider = 1)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/consumable/nutriment = 1)
	mix_message = "The mix swirls and turns a bright red that reminds you of an apple's skin."

/datum/chemical_reaction/fringe_weaver
	name = "Fringe Weaver"
	results = list(/datum/reagent/consumable/ethanol/fringe_weaver = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol = 9, /datum/reagent/consumable/sugar = 1) //9 karmotrine, 1 adelhyde
	mix_message = "The mix turns a pleasant cream color and foams up."

/datum/chemical_reaction/sugar_rush
	name = "Sugar Rush"
	results = list(/datum/reagent/consumable/ethanol/sugar_rush = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/wine = 1) //2 adelhyde (sweet), 1 powdered delta (sour), 1 karmotrine (alcohol)
	mix_message = "The mixture bubbles and brightens into a girly pink."

/datum/chemical_reaction/crevice_spike
	name = "Crevice Spike"
	results = list(/datum/reagent/consumable/ethanol/crevice_spike = 6)
	required_reagents = list(/datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/capsaicin = 4) //2 powdered delta (sour), 4 flanergide (spicy)
	mix_message = "The mixture stings your eyes as it settles."

/datum/chemical_reaction/sake
	name = /datum/reagent/consumable/ethanol/sake
	results = list(/datum/reagent/consumable/ethanol/sake = 10)
	required_reagents = list(/datum/reagent/consumable/rice = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mix_message = "The rice grains ferment into a clear, sweet-smelling liquid."

/datum/chemical_reaction/peppermint_patty
	name = "Peppermint Patty"
	results = list(/datum/reagent/consumable/ethanol/peppermint_patty = 10)
	required_reagents = list(/datum/reagent/consumable/hot_cocoa = 6, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/menthol = 1)
	mix_message = "The cocoa turns mint green just as the strong scent hits your nose."

/datum/chemical_reaction/alexander
	name = "Alexander"
	results = list(/datum/reagent/consumable/ethanol/alexander = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 1, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/sidecar
	name = "Sidecar"
	results = list(/datum/reagent/consumable/ethanol/sidecar = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/cognac = 2, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/between_the_sheets
	name = "Between the Sheets"
	results = list(/datum/reagent/consumable/ethanol/between_the_sheets = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/sidecar = 4)

/datum/chemical_reaction/kamikaze
	name = "Kamikaze"
	results = list(/datum/reagent/consumable/ethanol/kamikaze = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/mojito
	name = "Mojito"
	results = list(/datum/reagent/consumable/ethanol/mojito = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/menthol = 1)

/datum/chemical_reaction/fernet_cola
	name = "Fernet Cola"
	results = list(/datum/reagent/consumable/ethanol/fernet_cola = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/space_cola = 1)


/datum/chemical_reaction/fanciulli
	name = "Fanciulli"
	results = list(/datum/reagent/consumable/ethanol/fanciulli = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 1, /datum/reagent/consumable/ethanol/fernet = 1)

/datum/chemical_reaction/branca_menta
	name = "Branca Menta"
	results = list(/datum/reagent/consumable/ethanol/branca_menta = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/blank_paper
	name = "Blank Paper"
	results = list(/datum/reagent/consumable/ethanol/blank_paper = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/silencer = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nuka_cola = 1, /datum/reagent/consumable/clownstears = 1)


/datum/chemical_reaction/wizz_fizz
	name = "Wizz Fizz"
	results = list(/datum/reagent/consumable/ethanol/wizz_fizz = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/ethanol/champagne = 1)
	mix_message = "The beverage starts to froth with an almost mystical zeal!"
	mix_sound = 'sound/effects/bubbles2.ogg'


/datum/chemical_reaction/bug_spray
	name = "Bug Spray"
	results = list(/datum/reagent/consumable/ethanol/bug_spray = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/triple_sec = 2, /datum/reagent/consumable/lemon_lime = 1, /datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/vodka = 1)
	mix_message = "The faint aroma of summer camping trips wafts through the air; but what's that buzzing noise?"
	mix_sound = 'sound/creatures/bee.ogg'

/datum/chemical_reaction/jack_rose
	name = "Jack Rose"
	results = list(/datum/reagent/consumable/ethanol/jack_rose = 4)
	required_reagents = list(/datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/ethanol/applejack = 2, /datum/reagent/consumable/limejuice = 1)
	mix_message = "As the grenadine incorporates, the beverage takes on a mellow, red-orange glow."

/datum/chemical_reaction/turbo
	name = "Turbo"
	results = list(/datum/reagent/consumable/ethanol/turbo = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/moonshine = 2, /datum/reagent/nitrous_oxide = 1, /datum/reagent/consumable/ethanol/sugar_rush = 1, /datum/reagent/consumable/pwr_game = 1)

/datum/chemical_reaction/old_timer
	name = "Old Timer"
	results = list(/datum/reagent/consumable/ethanol/old_timer = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskeysoda = 3, /datum/reagent/consumable/parsnipjuice = 2, /datum/reagent/consumable/ethanol/alexander = 1)

/datum/chemical_reaction/rubberneck
	name = "Rubberneck"
	results = list(/datum/reagent/consumable/ethanol/rubberneck = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol = 4, /datum/reagent/consumable/grey_bull = 5, /datum/reagent/consumable/astrotame = 1)

/datum/chemical_reaction/duplex
	name = "Duplex"
	results = list(/datum/reagent/consumable/ethanol/duplex = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/hcider = 2, /datum/reagent/consumable/applejuice = 1, /datum/reagent/consumable/berryjuice = 1)

/datum/chemical_reaction/trappist
	name = "Trappist"
	results = list(/datum/reagent/consumable/ethanol/trappist = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/ale = 2, /datum/reagent/water/holywater = 2, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/cream_soda
	name = "Cream Soda"
	results = list(/datum/reagent/consumable/cream_soda = 4)
	required_reagents = list(/datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/sodawater = 2, /datum/reagent/consumable/vanilla = 1)

/datum/chemical_reaction/blazaam
	name = "Blazaam"
	results = list(/datum/reagent/consumable/ethanol/blazaam = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/peachjuice = 1, /datum/reagent/bluespace = 1)

/datum/chemical_reaction/planet_cracker
	name = "Planet Cracker"
	results = list(/datum/reagent/consumable/ethanol/planet_cracker = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 2, /datum/reagent/consumable/ethanol/lizardwine = 2, /datum/reagent/consumable/eggyolk = 1, /datum/reagent/gold = 1)
	mix_message = "The liquid's color starts shifting as the nanogold is alternately corroded and redeposited."

/datum/chemical_reaction/red_queen
	name = "Red Queen"
	results = list(/datum/reagent/consumable/red_queen = 10)
	required_reagents = list(/datum/reagent/consumable/tea = 6, /datum/reagent/mercury = 2, /datum/reagent/consumable/blackpepper = 1, /datum/reagent/growthserum = 1)

/datum/chemical_reaction/mauna_loa
	name = "Mauna Loa"
	results = list(/datum/reagent/consumable/ethanol/mauna_loa = 5)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/ethanol/kahlua = 1, /datum/reagent/consumable/ethanol/bahama_mama = 2)

/datum/chemical_reaction/plasmaflood
	name = "Plasma Flood"
	results = list(/datum/reagent/consumable/ethanol/plasmaflood = 4)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/napalm = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/demonsblood = 1)

/datum/chemical_reaction/fourthwall
	name = "Fourth Wall"
	results = list(/datum/reagent/consumable/ethanol/fourthwall = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/gargle_blaster = 10, /datum/reagent/bluespace = 1)

/datum/chemical_reaction/ratvander
	name = "Rat'vander Cocktail"
	results = list(/datum/reagent/consumable/ethanol/ratvander = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/wine = 5, /datum/reagent/consumable/ethanol/triple_sec = 5, /datum/reagent/consumable/sugar = 1, /datum/reagent/iron = 1, /datum/reagent/copper = 0.6)
	mix_message = "The mixture develops a golden glow."
	mix_sound = 'sound/magic/clockwork/scripture_tier_up.ogg'

/datum/chemical_reaction/icewing
	name = "Icewing"
	results = list(/datum/reagent/consumable/ethanol/icewing = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/antifreeze = 1, /datum/reagent/medicine/mine_salve = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/sarsaparilliansunset
	name = "Sarsaparillian Sunset"
	results = list(/datum/reagent/consumable/ethanol/sarsaparilliansunset = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/tequila_sunrise = 5, /datum/reagent/consumable/nuka_cola = 1, /datum/reagent/napalm = 1)
	required_temp = 320
	mix_message = "The mixture ignites."
	mix_sound = 'sound/items/lighter_on.ogg'

/datum/chemical_reaction/beesknees
	name = "Bee's Knees"
	results = list(/datum/reagent/consumable/ethanol/beesknees = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/mead = 1, /datum/reagent/consumable/honey = 1, /datum/reagent/consumable/ethanol/whiskey = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/beeffizz
	name = "Beef Fizz"
	results = list(/datum/reagent/consumable/beeffizz = 10)
	required_reagents = list(/datum/reagent/consumable/beefbroth = 7, /datum/reagent/consumable/ice = 2, /datum/reagent/consumable/lemonjuice = 1 )
