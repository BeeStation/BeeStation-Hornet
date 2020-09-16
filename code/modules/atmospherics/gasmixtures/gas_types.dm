GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/stimulum, /datum/gas/nitryl))) //unable to react amongst themselves
GLOBAL_LIST_INIT(standard_gasses, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma, /datum/gas/water_vapor, /datum/gas/hypernoblium, /datum/gas/tritium, /datum/gas/nitrous_oxide, /datum/gas/pluoxium, /datum/gas/bz, /datum/gas/miasma, /datum/gas/stimulum, /datum/gas/nitryl)) //unable to react amongst themselves

/proc/meta_gas_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/list/gas_info = new(7)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_SPECIFIC_HEAT] = initial(gas.specific_heat)
		gas_info[META_GAS_NAME] = initial(gas.name)

		gas_info[META_GAS_MOLES_VISIBLE] = initial(gas.moles_visible)
		if(initial(gas.moles_visible) != null)
			gas_info[META_GAS_OVERLAY] = new /list(FACTOR_GAS_VISIBLE_MAX)
			for(var/i in 1 to FACTOR_GAS_VISIBLE_MAX)
				gas_info[META_GAS_OVERLAY][i] = new /obj/effect/overlay/gas(initial(gas.gas_overlay), i * 255 / FACTOR_GAS_VISIBLE_MAX)

				gas_info[META_GAS_OVERLAY][i].color = initial(gas.color)
		gas_info[META_GAS_FUSION_POWER] = initial(gas.fusion_power)
		gas_info[META_GAS_DANGER] = initial(gas.dangerous)
		gas_info[META_GAS_ID] = initial(gas.id)
		.[gas_path] = gas_info

/proc/gas_id2path(id)
	var/list/meta_gas = GLOB.meta_gas_info
	if(id in meta_gas)
		return id
	for(var/path in meta_gas)
		if(meta_gas[path][META_GAS_ID] == id)
			return path
	return ""

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/atmospherics.dmi
	var/moles_visible = null
	var/dangerous = FALSE //currently used by canisters
	var/fusion_power = 0 //How much the gas accelerates a fusion reaction
	var/rarity = 0 // relative rarity compared to other gases, used when setting up the reactions list.
	var/color = null
	var/chemgas = 0
// If you add or remove gases, update TOTAL_NUM_GASES in the extools code to match! Extools currently expects 14 gas types to exist.

/datum/gas/oxygen
	id = "o2"
	specific_heat = 20
	name = "Oxygen"
	rarity = 900

/datum/gas/nitrogen
	id = "n2"
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000

/datum/gas/carbon_dioxide //what the fuck is this?
	id = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"
	rarity = 700

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 800

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500

/datum/gas/hypernoblium
	id = "nob"
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 50

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	dangerous = TRUE
	rarity = 600

/datum/gas/nitryl
	id = "no2"
	specific_heat = 20
	name = "Nitryl"
	gas_overlay = "nitryl"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 16
	rarity = 100

/datum/gas/tritium
	id = "tritium"
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 1
	rarity = 300

/datum/gas/bz
	id = "bz"
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8
	rarity = 400

/datum/gas/stimulum
	id = "stim"
	specific_heat = 5
	name = "Stimulum"
	fusion_power = 7
	rarity = 1

/datum/gas/pluoxium
	id = "pluox"
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	rarity = 200

/datum/gas/miasma
	id = "miasma"
	specific_heat = 20
	name = "Miasma"
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250

// BEGIN


/datum/gas/ethanol
	id = "ethanol"
	specific_heat = 20
	name = "ethanol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#404030"

/datum/gas/beer
	id = "beer"
	specific_heat = 20
	name = "beer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/ftliver
	id = "ftliver"
	specific_heat = 20
	name = "ftliver"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0D0D0D"

/datum/gas/light
	id = "light"
	specific_heat = 20
	name = "light"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/green
	id = "green"
	specific_heat = 20
	name = "green"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A8E61D"

/datum/gas/kahlua
	id = "kahlua"
	specific_heat = 20
	name = "kahlua"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/whiskey
	id = "whiskey"
	specific_heat = 20
	name = "whiskey"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/thirteenloko
	id = "thirteenloko"
	specific_heat = 20
	name = "thirteenloko"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#102000"

/datum/gas/vodka
	id = "vodka"
	specific_heat = 20
	name = "vodka"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0064C8"

/datum/gas/bilk
	id = "bilk"
	specific_heat = 20
	name = "bilk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#895C4C"

/datum/gas/threemileisland
	id = "threemileisland"
	specific_heat = 20
	name = "threemileisland"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#666340"

/datum/gas/gin
	id = "gin"
	specific_heat = 20
	name = "gin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/rum
	id = "rum"
	specific_heat = 20
	name = "rum"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/tequila
	id = "tequila"
	specific_heat = 20
	name = "tequila"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFF91"

/datum/gas/vermouth
	id = "vermouth"
	specific_heat = 20
	name = "vermouth"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#91FF91"

/datum/gas/wine
	id = "wine"
	specific_heat = 20
	name = "wine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7E4043"

/datum/gas/lizardwine
	id = "lizardwine"
	specific_heat = 20
	name = "lizardwine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7E4043"

/datum/gas/grappa
	id = "grappa"
	specific_heat = 20
	name = "grappa"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F8EBF1"

/datum/gas/cognac
	id = "cognac"
	specific_heat = 20
	name = "cognac"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AB3C05"

/datum/gas/absinthe
	id = "absinthe"
	specific_heat = 20
	name = "absinthe"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(10, 206, 0)

/datum/gas/hooch
	id = "hooch"
	specific_heat = 20
	name = "hooch"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/ale
	id = "ale"
	specific_heat = 20
	name = "ale"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/goldschlager
	id = "goldschlager"
	specific_heat = 20
	name = "goldschlager"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFF91"

/datum/gas/patron
	id = "patron"
	specific_heat = 20
	name = "patron"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#585840"

/datum/gas/gintonic
	id = "gintonic"
	specific_heat = 20
	name = "gintonic"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/rum_coke
	id = "rum_coke"
	specific_heat = 20
	name = "rum_coke"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#3E1B00"

/datum/gas/cuba_libre
	id = "cuba_libre"
	specific_heat = 20
	name = "cuba_libre"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#3E1B00"

/datum/gas/whiskey_cola
	id = "whiskey_cola"
	specific_heat = 20
	name = "whiskey_cola"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#3E1B00"

/datum/gas/martini
	id = "martini"
	specific_heat = 20
	name = "martini"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/vodkamartini
	id = "vodkamartini"
	specific_heat = 20
	name = "vodkamartini"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/white_russian
	id = "white_russian"
	specific_heat = 20
	name = "white_russian"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A68340"

/datum/gas/vodka_cola
	id = "vodka_cola"
	specific_heat = 20
	name = "vodka_cola"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#3f2410" // rgb: 62, 27, 0

/datum/gas/black_roulette
	id = "black_roulette"
	specific_heat = 20
	name = "black_roulette"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7c550bbe" // rgb: 102, 67, 0

/datum/gas/triple_coke
	id = "triple_coke"
	specific_heat = 20
	name = "triple_coke"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7c550bbe" // rgb: 102, 67, 0

/datum/gas/salty_water
	id = "salty_water"
	specific_heat = 20
	name = "salty_water"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffe65b"

/datum/gas/screwdrivercocktail
	id = "screwdrivercocktail"
	specific_heat = 20
	name = "screwdrivercocktail"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A68310"

/datum/gas/booger
	id = "booger"
	specific_heat = 20
	name = "booger"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#8CFF8C"

/datum/gas/bloody_mary
	id = "bloody_mary"
	specific_heat = 20
	name = "bloody_mary"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/brave_bull
	id = "brave_bull"
	specific_heat = 20
	name = "brave_bull"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/tequila_sunrise
	id = "tequila_sunrise"
	specific_heat = 20
	name = "tequila_sunrise"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFE48C"

/datum/gas/toxins_special
	id = "toxins_special"
	specific_heat = 20
	name = "toxins_special"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/beepsky_smash
	id = "beepsky_smash"
	specific_heat = 20
	name = "beepsky_smash"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/irish_cream
	id = "irish_cream"
	specific_heat = 20
	name = "irish_cream"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/manly_dorf
	id = "manly_dorf"
	specific_heat = 20
	name = "manly_dorf"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/longislandicedtea
	id = "longislandicedtea"
	specific_heat = 20
	name = "longislandicedtea"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/moonshine
	id = "moonshine"
	specific_heat = 20
	name = "moonshine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AAAAAA77"

/datum/gas/b52
	id = "b52"
	specific_heat = 20
	name = "b52"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/irishcoffee
	id = "irishcoffee"
	specific_heat = 20
	name = "irishcoffee"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/margarita
	id = "margarita"
	specific_heat = 20
	name = "margarita"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#8CFF8C"

/datum/gas/black_russian
	id = "black_russian"
	specific_heat = 20
	name = "black_russian"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#360000"

/datum/gas/manhattan
	id = "manhattan"
	specific_heat = 20
	name = "manhattan"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/manhattan_proj
	id = "manhattan_proj"
	specific_heat = 20
	name = "manhattan_proj"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/whiskeysoda
	id = "whiskeysoda"
	specific_heat = 20
	name = "whiskeysoda"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/antifreeze
	id = "antifreeze"
	specific_heat = 20
	name = "antifreeze"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/barefoot
	id = "barefoot"
	specific_heat = 20
	name = "barefoot"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/snowwhite
	id = "snowwhite"
	specific_heat = 20
	name = "snowwhite"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/demonsblood
	id = "demonsblood"
	specific_heat = 20
	name = "demonsblood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#820000"

/datum/gas/devilskiss
	id = "devilskiss"
	specific_heat = 20
	name = "devilskiss"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A68310"

/datum/gas/vodkatonic
	id = "vodkatonic"
	specific_heat = 20
	name = "vodkatonic"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0064C8"

/datum/gas/ginfizz
	id = "ginfizz"
	specific_heat = 20
	name = "ginfizz"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/bahama_mama
	id = "bahama_mama"
	specific_heat = 20
	name = "bahama_mama"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF7F3B"

/datum/gas/singulo
	id = "singulo"
	specific_heat = 20
	name = "singulo"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/sbiten
	id = "sbiten"
	specific_heat = 20
	name = "sbiten"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/red_mead
	id = "red_mead"
	specific_heat = 20
	name = "red_mead"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C73C00"

/datum/gas/mead
	id = "mead"
	specific_heat = 20
	name = "mead"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/iced_beer
	id = "iced_beer"
	specific_heat = 20
	name = "iced_beer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/grog
	id = "grog"
	specific_heat = 20
	name = "grog"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/aloe
	id = "aloe"
	specific_heat = 20
	name = "aloe"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/andalusia
	id = "andalusia"
	specific_heat = 20
	name = "andalusia"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/alliescocktail
	id = "alliescocktail"
	specific_heat = 20
	name = "alliescocktail"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/acid_spit
	id = "acid_spit"
	specific_heat = 20
	name = "acid_spit"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#365000"

/datum/gas/amasec
	id = "amasec"
	specific_heat = 20
	name = "amasec"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/changelingsting
	id = "changelingsting"
	specific_heat = 20
	name = "changelingsting"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/irishcarbomb
	id = "irishcarbomb"
	specific_heat = 20
	name = "irishcarbomb"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/syndicatebomb
	id = "syndicatebomb"
	specific_heat = 20
	name = "syndicatebomb"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/erikasurprise
	id = "erikasurprise"
	specific_heat = 20
	name = "erikasurprise"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/driestmartini
	id = "driestmartini"
	specific_heat = 20
	name = "driestmartini"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E6671"

/datum/gas/bananahonk
	id = "bananahonk"
	specific_heat = 20
	name = "bananahonk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFF91"

/datum/gas/silencer
	id = "silencer"
	specific_heat = 20
	name = "silencer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/drunkenblumpkin
	id = "drunkenblumpkin"
	specific_heat = 20
	name = "drunkenblumpkin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1EA0FF"

/datum/gas/whiskey_sour
	id = "whiskey_sour"
	specific_heat = 20
	name = "whiskey_sour"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(255, 201, 49)

/datum/gas/hcider
	id = "hcider"
	specific_heat = 20
	name = "hcider"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#CD6839"

/datum/gas/fetching_fizz
	id = "fetching_fizz"
	specific_heat = 20
	name = "fetching_fizz"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(255, 91, 15)

/datum/gas/hearty_punch
	id = "hearty_punch"
	specific_heat = 20
	name = "hearty_punch"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(140, 0, 0)

/datum/gas/bacchus_blessing
	id = "bacchus_blessing"
	specific_heat = 20
	name = "bacchus_blessing"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(51, 19, 3)

/datum/gas/atomicbomb
	id = "atomicbomb"
	specific_heat = 20
	name = "atomicbomb"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#666300"

/datum/gas/gargle_blaster
	id = "gargle_blaster"
	specific_heat = 20
	name = "gargle_blaster"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/neurotoxin
	id = "neurotoxin"
	specific_heat = 20
	name = "neurotoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2E2E61"

/datum/gas/hippies_delight
	id = "hippies_delight"
	specific_heat = 20
	name = "hippies_delight"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/eggnog
	id = "eggnog"
	specific_heat = 20
	name = "eggnog"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#fcfdc6"

/datum/gas/narsour
	id = "narsour"
	specific_heat = 20
	name = "narsour"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = RUNE_COLOR_DARKRED

/datum/gas/triple_sec
	id = "triple_sec"
	specific_heat = 20
	name = "triple_sec"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffcc66"

/datum/gas/creme_de_menthe
	id = "creme_de_menthe"
	specific_heat = 20
	name = "creme_de_menthe"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00cc00"

/datum/gas/creme_de_cacao
	id = "creme_de_cacao"
	specific_heat = 20
	name = "creme_de_cacao"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#996633"

/datum/gas/quadruple_sec
	id = "quadruple_sec"
	specific_heat = 20
	name = "quadruple_sec"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#cc0000"

/datum/gas/quintuple_sec
	id = "quintuple_sec"
	specific_heat = 20
	name = "quintuple_sec"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ff3300"

/datum/gas/grasshopper
	id = "grasshopper"
	specific_heat = 20
	name = "grasshopper"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "00ff00"

/datum/gas/stinger
	id = "stinger"
	specific_heat = 20
	name = "stinger"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "ccff99"

/datum/gas/bastion_bourbon
	id = "bastion_bourbon"
	specific_heat = 20
	name = "bastion_bourbon"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00FFFF"

/datum/gas/squirt_cider
	id = "squirt_cider"
	specific_heat = 20
	name = "squirt_cider"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF0000"

/datum/gas/fringe_weaver
	id = "fringe_weaver"
	specific_heat = 20
	name = "fringe_weaver"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFEAC4"

/datum/gas/sugar_rush
	id = "sugar_rush"
	specific_heat = 20
	name = "sugar_rush"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF226C"

/datum/gas/crevice_spike
	id = "crevice_spike"
	specific_heat = 20
	name = "crevice_spike"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5BD231"

/datum/gas/sake
	id = "sake"
	specific_heat = 20
	name = "sake"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DDDDDD"

/datum/gas/peppermint_patty
	id = "peppermint_patty"
	specific_heat = 20
	name = "peppermint_patty"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#45ca7a"

/datum/gas/alexander
	id = "alexander"
	specific_heat = 20
	name = "alexander"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F5E9D3"

/datum/gas/sidecar
	id = "sidecar"
	specific_heat = 20
	name = "sidecar"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFC55B"

/datum/gas/between_the_sheets
	id = "between_the_sheets"
	specific_heat = 20
	name = "between_the_sheets"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F4C35A"

/datum/gas/kamikaze
	id = "kamikaze"
	specific_heat = 20
	name = "kamikaze"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EEF191"

/datum/gas/mojito
	id = "mojito"
	specific_heat = 20
	name = "mojito"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DFFAD9"

/datum/gas/fernet
	id = "fernet"
	specific_heat = 20
	name = "fernet"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1B2E24"

/datum/gas/fernet_cola
	id = "fernet_cola"
	specific_heat = 20
	name = "fernet_cola"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#390600"

/datum/gas/fanciulli
	id = "fanciulli"
	specific_heat = 20
	name = "fanciulli"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/branca_menta
	id = "branca_menta"
	specific_heat = 20
	name = "branca_menta"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#4B5746"

/datum/gas/blank_paper
	id = "blank_paper"
	specific_heat = 20
	name = "blank_paper"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DCDCDC"

/datum/gas/fruit_wine
	id = "fruit_wine"
	specific_heat = 20
	name = "fruit_wine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/champagne
	id = "champagne"
	specific_heat = 20
	name = "champagne"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffffc1"

/datum/gas/wizz_fizz
	id = "wizz_fizz"
	specific_heat = 20
	name = "wizz_fizz"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#4235d0"

/datum/gas/bug_spray
	id = "bug_spray"
	specific_heat = 20
	name = "bug_spray"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#33ff33"

/datum/gas/applejack
	id = "applejack"
	specific_heat = 20
	name = "applejack"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ff6633"

/datum/gas/jack_rose
	id = "jack_rose"
	specific_heat = 20
	name = "jack_rose"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ff6633"

/datum/gas/turbo
	id = "turbo"
	specific_heat = 20
	name = "turbo"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#e94c3a"

/datum/gas/old_timer
	id = "old_timer"
	specific_heat = 20
	name = "old_timer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#996835"

/datum/gas/rubberneck
	id = "rubberneck"
	specific_heat = 20
	name = "rubberneck"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffe65b"

/datum/gas/duplex
	id = "duplex"
	specific_heat = 20
	name = "duplex"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#50e5cf"

/datum/gas/trappist
	id = "trappist"
	specific_heat = 20
	name = "trappist"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#390c00"

/datum/gas/blazaam
	id = "blazaam"
	specific_heat = 20
	name = "blazaam"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/planet_cracker
	id = "planet_cracker"
	specific_heat = 20
	name = "planet_cracker"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/mauna_loa
	id = "mauna_loa"
	specific_heat = 20
	name = "mauna_loa"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#fe8308"

/datum/gas/plasmaflood
	id = "plasmaflood"
	specific_heat = 20
	name = "plasmaflood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#630480"

/datum/gas/fourthwall
	id = "fourthwall"
	specific_heat = 20
	name = "fourthwall"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0b43a3"

/datum/gas/ratvander
	id = "ratvander"
	specific_heat = 20
	name = "ratvander"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/icewing
	id = "icewing"
	specific_heat = 20
	name = "icewing"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/sarsaparilliansunset
	id = "sarsaparilliansunset"
	specific_heat = 20
	name = "sarsaparilliansunset"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/beesknees
	id = "beesknees"
	specific_heat = 20
	name = "beesknees"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/orangejuice
	id = "orangejuice"
	specific_heat = 20
	name = "orangejuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E78108"

/datum/gas/tomatojuice
	id = "tomatojuice"
	specific_heat = 20
	name = "tomatojuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#731008"

/datum/gas/limejuice
	id = "limejuice"
	specific_heat = 20
	name = "limejuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#365E30"

/datum/gas/carrotjuice
	id = "carrotjuice"
	specific_heat = 20
	name = "carrotjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#973800"

/datum/gas/berryjuice
	id = "berryjuice"
	specific_heat = 20
	name = "berryjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#863333"

/datum/gas/applejuice
	id = "applejuice"
	specific_heat = 20
	name = "applejuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ECFF56"

/datum/gas/poisonberryjuice
	id = "poisonberryjuice"
	specific_heat = 20
	name = "poisonberryjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#863353"

/datum/gas/watermelonjuice
	id = "watermelonjuice"
	specific_heat = 20
	name = "watermelonjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#863333"

/datum/gas/lemonjuice
	id = "lemonjuice"
	specific_heat = 20
	name = "lemonjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#863333"

/datum/gas/banana
	id = "banana"
	specific_heat = 20
	name = "banana"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#863333"

/datum/gas/nothing
	id = "nothing"
	specific_heat = 20
	name = "nothing"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/laughter
	id = "laughter"
	specific_heat = 20
	name = "laughter"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF4DD2"

/datum/gas/superlaughter
	id = "superlaughter"
	specific_heat = 20
	name = "superlaughter"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF4DD2"

/datum/gas/potato_juice
	id = "potato_juice"
	specific_heat = 20
	name = "potato_juice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/grapejuice
	id = "grapejuice"
	specific_heat = 20
	name = "grapejuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#290029"

/datum/gas/milk
	id = "milk"
	specific_heat = 20
	name = "milk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DFDFDF"

/datum/gas/soymilk
	id = "soymilk"
	specific_heat = 20
	name = "soymilk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DFDFC7"

/datum/gas/cream
	id = "cream"
	specific_heat = 20
	name = "cream"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DFD7AF"

/datum/gas/coffee
	id = "coffee"
	specific_heat = 20
	name = "coffee"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#482000"

/datum/gas/tea
	id = "tea"
	specific_heat = 20
	name = "tea"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#101000"

/datum/gas/lemonade
	id = "lemonade"
	specific_heat = 20
	name = "lemonade"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/arnold_palmer
	id = "arnold_palmer"
	specific_heat = 20
	name = "arnold_palmer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFB766"

/datum/gas/icecoffee
	id = "icecoffee"
	specific_heat = 20
	name = "icecoffee"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#102838"

/datum/gas/icetea
	id = "icetea"
	specific_heat = 20
	name = "icetea"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#104038"

/datum/gas/space_cola
	id = "space_cola"
	specific_heat = 20
	name = "space_cola"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#100800"

/datum/gas/nuka_cola
	id = "nuka_cola"
	specific_heat = 20
	name = "nuka_cola"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#100800"

/datum/gas/grey_bull
	id = "grey_bull"
	specific_heat = 20
	name = "grey_bull"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EEFF00"

/datum/gas/spacemountainwind
	id = "spacemountainwind"
	specific_heat = 20
	name = "spacemountainwind"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#102000"

/datum/gas/dr_gibb
	id = "dr_gibb"
	specific_heat = 20
	name = "dr_gibb"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#102000"

/datum/gas/space_up
	id = "space_up"
	specific_heat = 20
	name = "space_up"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00FF00"

/datum/gas/lemon_lime
	id = "lemon_lime"
	specific_heat = 20
	name = "lemon_lime"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#8CFF00"

/datum/gas/pwr_game
	id = "pwr_game"
	specific_heat = 20
	name = "pwr_game"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9385bf"

/datum/gas/shamblers
	id = "shamblers"
	specific_heat = 20
	name = "shamblers"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#f00060"

/datum/gas/sodawater
	id = "sodawater"
	specific_heat = 20
	name = "sodawater"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#619494"

/datum/gas/tonic
	id = "tonic"
	specific_heat = 20
	name = "tonic"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0064C8"

/datum/gas/monkey_energy
	id = "monkey_energy"
	specific_heat = 20
	name = "monkey_energy"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#f39b03"

/datum/gas/ice
	id = "ice"
	specific_heat = 20
	name = "ice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#619494"

/datum/gas/soy_latte
	id = "soy_latte"
	specific_heat = 20
	name = "soy_latte"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/cafe_latte
	id = "cafe_latte"
	specific_heat = 20
	name = "cafe_latte"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/doctor_delight
	id = "doctor_delight"
	specific_heat = 20
	name = "doctor_delight"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF8CFF"

/datum/gas/chocolatepudding
	id = "chocolatepudding"
	specific_heat = 20
	name = "chocolatepudding"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#800000"

/datum/gas/vanillapudding
	id = "vanillapudding"
	specific_heat = 20
	name = "vanillapudding"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFAD2"

/datum/gas/cherryshake
	id = "cherryshake"
	specific_heat = 20
	name = "cherryshake"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFB6C1"

/datum/gas/bluecherryshake
	id = "bluecherryshake"
	specific_heat = 20
	name = "bluecherryshake"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00F1FF"

/datum/gas/pumpkin_latte
	id = "pumpkin_latte"
	specific_heat = 20
	name = "pumpkin_latte"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F4A460"

/datum/gas/gibbfloats
	id = "gibbfloats"
	specific_heat = 20
	name = "gibbfloats"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B22222"

/datum/gas/pumpkinjuice
	id = "pumpkinjuice"
	specific_heat = 20
	name = "pumpkinjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFA500"

/datum/gas/blumpkinjuice
	id = "blumpkinjuice"
	specific_heat = 20
	name = "blumpkinjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00BFFF"

/datum/gas/triple_citrus
	id = "triple_citrus"
	specific_heat = 20
	name = "triple_citrus"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/grape_soda
	id = "grape_soda"
	specific_heat = 20
	name = "grape_soda"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E6CDFF"

/datum/gas/chocolate_milk
	id = "chocolate_milk"
	specific_heat = 20
	name = "chocolate_milk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7D4E29"

/datum/gas/menthol
	id = "menthol"
	specific_heat = 20
	name = "menthol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#80AF9C"

/datum/gas/grenadine
	id = "grenadine"
	specific_heat = 20
	name = "grenadine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EA1D26"

/datum/gas/parsnipjuice
	id = "parsnipjuice"
	specific_heat = 20
	name = "parsnipjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFA500"

/datum/gas/peachjuice
	id = "peachjuice"
	specific_heat = 20
	name = "peachjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E78108"

/datum/gas/cream_soda
	id = "cream_soda"
	specific_heat = 20
	name = "cream_soda"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#dcb137"

/datum/gas/red_queen
	id = "red_queen"
	specific_heat = 20
	name = "red_queen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#e6ddc3"

/datum/gas/bungojuice
	id = "bungojuice"
	specific_heat = 20
	name = "bungojuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F9E43D"

/datum/gas/drug
	id = "drug"
	specific_heat = 20
	name = "drug"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/space_drugs
	id = "space_drugs"
	specific_heat = 20
	name = "space_drugs"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#60A584"

/datum/gas/nicotine
	id = "nicotine"
	specific_heat = 20
	name = "nicotine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#60A584"

/datum/gas/crank
	id = "crank"
	specific_heat = 20
	name = "crank"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FA00C8"

/datum/gas/krokodil
	id = "krokodil"
	specific_heat = 20
	name = "krokodil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0064B4"

/datum/gas/methamphetamine
	id = "methamphetamine"
	specific_heat = 20
	name = "methamphetamine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFAFA"

/datum/gas/bath_salts
	id = "bath_salts"
	specific_heat = 20
	name = "bath_salts"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFAFA"

/datum/gas/aranesp
	id = "aranesp"
	specific_heat = 20
	name = "aranesp"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#78FFF0"

/datum/gas/happiness
	id = "happiness"
	specific_heat = 20
	name = "happiness"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFF378"

/datum/gas/nutriment
	id = "nutriment"
	specific_heat = 20
	name = "nutriment"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664330"

/datum/gas/vitamin
	id = "vitamin"
	specific_heat = 20
	name = "vitamin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/cooking_oil
	id = "cooking_oil"
	specific_heat = 20
	name = "cooking_oil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EADD6B"

/datum/gas/sugar
	id = "sugar"
	specific_heat = 20
	name = "sugar"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/virus_food
	id = "virus_food"
	specific_heat = 20
	name = "virus_food"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#899613"

/datum/gas/soysauce
	id = "soysauce"
	specific_heat = 20
	name = "soysauce"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#792300"

/datum/gas/ketchup
	id = "ketchup"
	specific_heat = 20
	name = "ketchup"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#731008"

/datum/gas/capsaicin
	id = "capsaicin"
	specific_heat = 20
	name = "capsaicin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B31008"

/datum/gas/frostoil
	id = "frostoil"
	specific_heat = 20
	name = "frostoil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#8BA6E9"

/datum/gas/condensedcapsaicin
	id = "condensedcapsaicin"
	specific_heat = 20
	name = "condensedcapsaicin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B31008"

/datum/gas/sodiumchloride
	id = "sodiumchloride"
	specific_heat = 20
	name = "sodiumchloride"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/blackpepper
	id = "blackpepper"
	specific_heat = 20
	name = "blackpepper"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/coco
	id = "coco"
	specific_heat = 20
	name = "coco"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/hot_coco
	id = "hot_coco"
	specific_heat = 20
	name = "hot_coco"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#403010"

/datum/gas/mushroomhallucinogen
	id = "mushroomhallucinogen"
	specific_heat = 20
	name = "mushroomhallucinogen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E700E7"

/datum/gas/garlic
	id = "garlic"
	specific_heat = 20
	name = "garlic"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FEFEFE"

/datum/gas/sprinkles
	id = "sprinkles"
	specific_heat = 20
	name = "sprinkles"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF00FF"

/datum/gas/cornoil
	id = "cornoil"
	specific_heat = 20
	name = "cornoil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/enzyme
	id = "enzyme"
	specific_heat = 20
	name = "enzyme"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#365E30"

/datum/gas/dry_ramen
	id = "dry_ramen"
	specific_heat = 20
	name = "dry_ramen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/hot_ramen
	id = "hot_ramen"
	specific_heat = 20
	name = "hot_ramen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/hell_ramen
	id = "hell_ramen"
	specific_heat = 20
	name = "hell_ramen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#302000"

/datum/gas/flour
	id = "flour"
	specific_heat = 20
	name = "flour"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/cherryjelly
	id = "cherryjelly"
	specific_heat = 20
	name = "cherryjelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#801E28"

/datum/gas/bluecherryjelly
	id = "bluecherryjelly"
	specific_heat = 20
	name = "bluecherryjelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00F0FF"

/datum/gas/rice
	id = "rice"
	specific_heat = 20
	name = "rice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/vanilla
	id = "vanilla"
	specific_heat = 20
	name = "vanilla"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFACD"

/datum/gas/eggyolk
	id = "eggyolk"
	specific_heat = 20
	name = "eggyolk"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFB500"

/datum/gas/corn_starch
	id = "corn_starch"
	specific_heat = 20
	name = "corn_starch"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/corn_syrup
	id = "corn_syrup"
	specific_heat = 20
	name = "corn_syrup"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/honey
	id = "honey"
	specific_heat = 20
	name = "honey"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#d3a308"

/datum/gas/special
	id = "special"
	specific_heat = 20
	name = "special"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/mayonnaise
	id = "mayonnaise"
	specific_heat = 20
	name = "mayonnaise"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DFDFDF"

/datum/gas/tearjuice
	id = "tearjuice"
	specific_heat = 20
	name = "tearjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#c0c9a0"

/datum/gas/stabilized
	id = "stabilized"
	specific_heat = 20
	name = "stabilized"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664330"

/datum/gas/entpoly
	id = "entpoly"
	specific_heat = 20
	name = "entpoly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1d043d"

/datum/gas/tinlux
	id = "tinlux"
	specific_heat = 20
	name = "tinlux"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#b5a213"

/datum/gas/vitfro
	id = "vitfro"
	specific_heat = 20
	name = "vitfro"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#d3a308"

/datum/gas/clownstears
	id = "clownstears"
	specific_heat = 20
	name = "clownstears"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#eef442"

/datum/gas/liquidelectricity
	id = "liquidelectricity"
	specific_heat = 20
	name = "liquidelectricity"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#97ee63"

/datum/gas/astrotame
	id = "astrotame"
	specific_heat = 20
	name = "astrotame"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/caramel
	id = "caramel"
	specific_heat = 20
	name = "caramel"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C65A00"

/datum/gas/bbqsauce
	id = "bbqsauce"
	specific_heat = 20
	name = "bbqsauce"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#78280A"

/datum/gas/char
	id = "char"
	specific_heat = 20
	name = "char"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/medicine
	id = "medicine"
	specific_heat = 20
	name = "medicine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/leporazine
	id = "leporazine"
	specific_heat = 20
	name = "leporazine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/adminordrazine
	id = "adminordrazine"
	specific_heat = 20
	name = "adminordrazine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/quantum_heal
	id = "quantum_heal"
	specific_heat = 20
	name = "quantum_heal"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/synaptizine
	id = "synaptizine"
	specific_heat = 20
	name = "synaptizine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF00FF"

/datum/gas/synaphydramine
	id = "synaphydramine"
	specific_heat = 20
	name = "synaphydramine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EC536D"

/datum/gas/inacusiate
	id = "inacusiate"
	specific_heat = 20
	name = "inacusiate"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#6600FF"

/datum/gas/cryoxadone
	id = "cryoxadone"
	specific_heat = 20
	name = "cryoxadone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0000C8"

/datum/gas/clonexadone
	id = "clonexadone"
	specific_heat = 20
	name = "clonexadone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0000C8"

/datum/gas/pyroxadone
	id = "pyroxadone"
	specific_heat = 20
	name = "pyroxadone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#f7832a"

/datum/gas/rezadone
	id = "rezadone"
	specific_heat = 20
	name = "rezadone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#669900"

/datum/gas/spaceacillin
	id = "spaceacillin"
	specific_heat = 20
	name = "spaceacillin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/silver_sulfadiazine
	id = "silver_sulfadiazine"
	specific_heat = 20
	name = "silver_sulfadiazine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/oxandrolone
	id = "oxandrolone"
	specific_heat = 20
	name = "oxandrolone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#f7ffa5"

/datum/gas/styptic_powder
	id = "styptic_powder"
	specific_heat = 20
	name = "styptic_powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF9696"

/datum/gas/salglu_solution
	id = "salglu_solution"
	specific_heat = 20
	name = "salglu_solution"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DCDCDC"

/datum/gas/mine_salve
	id = "mine_salve"
	specific_heat = 20
	name = "mine_salve"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#6D6374"

/datum/gas/synthflesh
	id = "synthflesh"
	specific_heat = 20
	name = "synthflesh"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFEBEB"

/datum/gas/charcoal
	id = "charcoal"
	specific_heat = 20
	name = "charcoal"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#000000"

/datum/gas/system_cleaner
	id = "system_cleaner"
	specific_heat = 20
	name = "system_cleaner"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F1C40F"

/datum/gas/liquid_solder
	id = "liquid_solder"
	specific_heat = 20
	name = "liquid_solder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#727272"

/datum/gas/omnizine
	id = "omnizine"
	specific_heat = 20
	name = "omnizine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DCDCDC"

/datum/gas/calomel
	id = "calomel"
	specific_heat = 20
	name = "calomel"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#19C832"

/datum/gas/potass_iodide
	id = "potass_iodide"
	specific_heat = 20
	name = "potass_iodide"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#14FF3C"

/datum/gas/pen_acid
	id = "pen_acid"
	specific_heat = 20
	name = "pen_acid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E6FFF0"

/datum/gas/sal_acid
	id = "sal_acid"
	specific_heat = 20
	name = "sal_acid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D2D2D2"

/datum/gas/salbutamol
	id = "salbutamol"
	specific_heat = 20
	name = "salbutamol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00FFFF"

/datum/gas/perfluorodecalin
	id = "perfluorodecalin"
	specific_heat = 20
	name = "perfluorodecalin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF6464"

/datum/gas/ephedrine
	id = "ephedrine"
	specific_heat = 20
	name = "ephedrine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D2FFFA"

/datum/gas/diphenhydramine
	id = "diphenhydramine"
	specific_heat = 20
	name = "diphenhydramine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#64FFE6"

/datum/gas/morphine
	id = "morphine"
	specific_heat = 20
	name = "morphine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A9FBFB"

/datum/gas/oculine
	id = "oculine"
	specific_heat = 20
	name = "oculine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/atropine
	id = "atropine"
	specific_heat = 20
	name = "atropine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#000000"

/datum/gas/epinephrine
	id = "epinephrine"
	specific_heat = 20
	name = "epinephrine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D2FFFA"

/datum/gas/strange_reagent
	id = "strange_reagent"
	specific_heat = 20
	name = "strange_reagent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A0E85E"

/datum/gas/mannitol
	id = "mannitol"
	specific_heat = 20
	name = "mannitol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DCDCFF"

/datum/gas/neurine
	id = "neurine"
	specific_heat = 20
	name = "neurine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EEFF8F"

/datum/gas/mutadone
	id = "mutadone"
	specific_heat = 20
	name = "mutadone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5096C8"

/datum/gas/antihol
	id = "antihol"
	specific_heat = 20
	name = "antihol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00B4C8"

/datum/gas/stimulants
	id = "stimulants"
	specific_heat = 20
	name = "stimulants"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#78008C"

/datum/gas/pumpup
	id = "pumpup"
	specific_heat = 20
	name = "pumpup"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#78008C"

/datum/gas/insulin
	id = "insulin"
	specific_heat = 20
	name = "insulin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFF0"

/datum/gas/bicaridine
	id = "bicaridine"
	specific_heat = 20
	name = "bicaridine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/kelotane
	id = "kelotane"
	specific_heat = 20
	name = "kelotane"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/antitoxin
	id = "antitoxin"
	specific_heat = 20
	name = "antitoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/carthatoline
	id = "carthatoline"
	specific_heat = 20
	name = "carthatoline"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#225722"

/datum/gas/hepanephrodaxon
	id = "hepanephrodaxon"
	specific_heat = 20
	name = "hepanephrodaxon"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D2691E"

/datum/gas/inaprovaline
	id = "inaprovaline"
	specific_heat = 20
	name = "inaprovaline"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/tricordrazine
	id = "tricordrazine"
	specific_heat = 20
	name = "tricordrazine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/regen_jelly
	id = "regen_jelly"
	specific_heat = 20
	name = "regen_jelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#91D865"

/datum/gas/syndicate_nanites
	id = "syndicate_nanites"
	specific_heat = 20
	name = "syndicate_nanites"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#555555"

/datum/gas/earthsblood
	id = "earthsblood"
	specific_heat = 20
	name = "earthsblood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = rgb(255, 175, 0)

/datum/gas/haloperidol
	id = "haloperidol"
	specific_heat = 20
	name = "haloperidol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#27870a"

/datum/gas/lavaland_extract
	id = "lavaland_extract"
	specific_heat = 20
	name = "lavaland_extract"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/changelingadrenaline
	id = "changelingadrenaline"
	specific_heat = 20
	name = "changelingadrenaline"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/changelinghaste
	id = "changelinghaste"
	specific_heat = 20
	name = "changelinghaste"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/corazone
	id = "corazone"
	specific_heat = 20
	name = "corazone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F5F5F5"

/datum/gas/muscle_stimulant
	id = "muscle_stimulant"
	specific_heat = 20
	name = "muscle_stimulant"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/modafinil
	id = "modafinil"
	specific_heat = 20
	name = "modafinil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#BEF7D8"

/datum/gas/psicodine
	id = "psicodine"
	specific_heat = 20
	name = "psicodine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#07E79E"

/datum/gas/silibinin
	id = "silibinin"
	specific_heat = 20
	name = "silibinin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFD0"

/datum/gas/polypyr
	id = "polypyr"
	specific_heat = 20
	name = "polypyr"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9423FF"

/datum/gas/blood
	id = "blood"
	specific_heat = 20
	name = "blood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C80000"

/datum/gas/liquidgibs
	id = "liquidgibs"
	specific_heat = 20
	name = "liquidgibs"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF9966"

/datum/gas/vaccine
	id = "vaccine"
	specific_heat = 20
	name = "vaccine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C81040"

/datum/gas/water
	id = "water"
	specific_heat = 20
	name = "water"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AAAAAA77"

/datum/gas/holywater
	id = "holywater"
	specific_heat = 20
	name = "holywater"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#E0E8EF"

/datum/gas/unholywater
	id = "unholywater"
	specific_heat = 20
	name = "unholywater"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/hellwater
	id = "hellwater"
	specific_heat = 20
	name = "hellwater"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/godblood
	id = "godblood"
	specific_heat = 20
	name = "godblood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/lube
	id = "lube"
	specific_heat = 20
	name = "lube"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#009CA8"

/datum/gas/spraytan
	id = "spraytan"
	specific_heat = 20
	name = "spraytan"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFC080"

/datum/gas/mutationtoxin
	id = "mutationtoxin"
	specific_heat = 20
	name = "mutationtoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/classic
	id = "classic"
	specific_heat = 20
	name = "classic"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#13BC5E"

/datum/gas/unstable
	id = "unstable"
	specific_heat = 20
	name = "unstable"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#13BC5E"

/datum/gas/felinid
	id = "felinid"
	specific_heat = 20
	name = "felinid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/lizard
	id = "lizard"
	specific_heat = 20
	name = "lizard"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/fly
	id = "fly"
	specific_heat = 20
	name = "fly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/moth
	id = "moth"
	specific_heat = 20
	name = "moth"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/pod
	id = "pod"
	specific_heat = 20
	name = "pod"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/jelly
	id = "jelly"
	specific_heat = 20
	name = "jelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/golem
	id = "golem"
	specific_heat = 20
	name = "golem"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/abductor
	id = "abductor"
	specific_heat = 20
	name = "abductor"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/android
	id = "android"
	specific_heat = 20
	name = "android"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/ipc
	id = "ipc"
	specific_heat = 20
	name = "ipc"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/squid
	id = "squid"
	specific_heat = 20
	name = "squid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/skeleton
	id = "skeleton"
	specific_heat = 20
	name = "skeleton"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/zombie
	id = "zombie"
	specific_heat = 20
	name = "zombie"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/goofzombie
	id = "goofzombie"
	specific_heat = 20
	name = "goofzombie"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/ash
	id = "ash"
	specific_heat = 20
	name = "ash"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/supersoldier
	id = "supersoldier"
	specific_heat = 20
	name = "supersoldier"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/shadow
	id = "shadow"
	specific_heat = 20
	name = "shadow"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/slime_toxin
	id = "slime_toxin"
	specific_heat = 20
	name = "slime_toxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/mulligan
	id = "mulligan"
	specific_heat = 20
	name = "mulligan"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/aslimetoxin
	id = "aslimetoxin"
	specific_heat = 20
	name = "aslimetoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#13BC5E"

/datum/gas/gluttonytoxin
	id = "gluttonytoxin"
	specific_heat = 20
	name = "gluttonytoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5EFF3B"

/datum/gas/serotrotium
	id = "serotrotium"
	specific_heat = 20
	name = "serotrotium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#202040"

/datum/gas/copper
	id = "copper"
	specific_heat = 20
	name = "copper"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#6E3B08"

/datum/gas/hydrogen
	id = "hydrogen"
	specific_heat = 20
	name = "hydrogen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/potassium
	id = "potassium"
	specific_heat = 20
	name = "potassium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A0A0A0"

/datum/gas/mercury
	id = "mercury"
	specific_heat = 20
	name = "mercury"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#484848"

/datum/gas/sulfur
	id = "sulfur"
	specific_heat = 20
	name = "sulfur"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#BF8C00"

/datum/gas/carbon
	id = "carbon"
	specific_heat = 20
	name = "carbon"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1C1300"

/datum/gas/chlorine
	id = "chlorine"
	specific_heat = 20
	name = "chlorine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/fluorine
	id = "fluorine"
	specific_heat = 20
	name = "fluorine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/sodium
	id = "sodium"
	specific_heat = 20
	name = "sodium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/phosphorus
	id = "phosphorus"
	specific_heat = 20
	name = "phosphorus"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#832828"

/datum/gas/lithium
	id = "lithium"
	specific_heat = 20
	name = "lithium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/glycerol
	id = "glycerol"
	specific_heat = 20
	name = "glycerol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/sterilizine
	id = "sterilizine"
	specific_heat = 20
	name = "sterilizine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/iron
	id = "iron"
	specific_heat = 20
	name = "iron"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/gold
	id = "gold"
	specific_heat = 20
	name = "gold"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F7C430"

/datum/gas/silver
	id = "silver"
	specific_heat = 20
	name = "silver"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D0D0D0"

/datum/gas/uranium
	id = "uranium"
	specific_heat = 20
	name = "uranium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B8B8C0"

/datum/gas/radium
	id = "radium"
	specific_heat = 20
	name = "radium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C7C7C7"

/datum/gas/bluespace
	id = "bluespace"
	specific_heat = 20
	name = "bluespace"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0000CC"

/datum/gas/aluminium
	id = "aluminium"
	specific_heat = 20
	name = "aluminium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A8A8A8"

/datum/gas/silicon
	id = "silicon"
	specific_heat = 20
	name = "silicon"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A8A8A8"

/datum/gas/fuel
	id = "fuel"
	specific_heat = 20
	name = "fuel"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#660000"

/datum/gas/space_cleaner
	id = "space_cleaner"
	specific_heat = 20
	name = "space_cleaner"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A5F0EE"

/datum/gas/ez_clean
	id = "ez_clean"
	specific_heat = 20
	name = "ez_clean"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/cryptobiolin
	id = "cryptobiolin"
	specific_heat = 20
	name = "cryptobiolin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/impedrezene
	id = "impedrezene"
	specific_heat = 20
	name = "impedrezene"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/nanomachines
	id = "nanomachines"
	specific_heat = 20
	name = "nanomachines"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#535E66"

/datum/gas/xenomicrobes
	id = "xenomicrobes"
	specific_heat = 20
	name = "xenomicrobes"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#535E66"

/datum/gas/fungalspores
	id = "fungalspores"
	specific_heat = 20
	name = "fungalspores"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#92D17D"

/datum/gas/snail
	id = "snail"
	specific_heat = 20
	name = "snail"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#003300"

/datum/gas/fluorosurfactant
	id = "fluorosurfactant"
	specific_heat = 20
	name = "fluorosurfactant"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9E6B38"

/datum/gas/foaming_agent
	id = "foaming_agent"
	specific_heat = 20
	name = "foaming_agent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664B63"

/datum/gas/smart_foaming_agent
	id = "smart_foaming_agent"
	specific_heat = 20
	name = "smart_foaming_agent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664B63"

/datum/gas/ammonia
	id = "ammonia"
	specific_heat = 20
	name = "ammonia"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#404030"

/datum/gas/diethylamine
	id = "diethylamine"
	specific_heat = 20
	name = "diethylamine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#604030"

/datum/gas/carbondioxide
	id = "carbondioxide"
	specific_heat = 20
	name = "carbondioxide"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B0B0B0"

/datum/gas/powder
	id = "powder"
	specific_heat = 20
	name = "powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/red
	id = "red"
	specific_heat = 20
	name = "red"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DA0000"

/datum/gas/orange
	id = "orange"
	specific_heat = 20
	name = "orange"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FF9300"

/datum/gas/yellow
	id = "yellow"
	specific_heat = 20
	name = "yellow"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFF200"

/datum/gas/blue
	id = "blue"
	specific_heat = 20
	name = "blue"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00B7EF"

/datum/gas/purple
	id = "purple"
	specific_heat = 20
	name = "purple"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#DA00FF"

/datum/gas/invisible
	id = "invisible"
	specific_heat = 20
	name = "invisible"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF00"

/datum/gas/black
	id = "black"
	specific_heat = 20
	name = "black"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1C1C1C"

/datum/gas/white
	id = "white"
	specific_heat = 20
	name = "white"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/plantnutriment
	id = "plantnutriment"
	specific_heat = 20
	name = "plantnutriment"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#000000"

/datum/gas/eznutriment
	id = "eznutriment"
	specific_heat = 20
	name = "eznutriment"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#376400"

/datum/gas/left4zednutriment
	id = "left4zednutriment"
	specific_heat = 20
	name = "left4zednutriment"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#1A1E4D"

/datum/gas/robustharvestnutriment
	id = "robustharvestnutriment"
	specific_heat = 20
	name = "robustharvestnutriment"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9D9D00"

/datum/gas/oil
	id = "oil"
	specific_heat = 20
	name = "oil"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/stable_plasma
	id = "stable_plasma"
	specific_heat = 20
	name = "stable_plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/iodine
	id = "iodine"
	specific_heat = 20
	name = "iodine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/carpet
	id = "carpet"
	specific_heat = 20
	name = "carpet"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/bromine
	id = "bromine"
	specific_heat = 20
	name = "bromine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/phenol
	id = "phenol"
	specific_heat = 20
	name = "phenol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/acetone
	id = "acetone"
	specific_heat = 20
	name = "acetone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/colorful_reagent
	id = "colorful_reagent"
	specific_heat = 20
	name = "colorful_reagent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/hair_dye
	id = "hair_dye"
	specific_heat = 20
	name = "hair_dye"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/barbers_aid
	id = "barbers_aid"
	specific_heat = 20
	name = "barbers_aid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/concentrated_barbers_aid
	id = "concentrated_barbers_aid"
	specific_heat = 20
	name = "concentrated_barbers_aid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8A5DC"

/datum/gas/saltpetre
	id = "saltpetre"
	specific_heat = 20
	name = "saltpetre"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#60A584"

/datum/gas/lye
	id = "lye"
	specific_heat = 20
	name = "lye"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFD6"

/datum/gas/drying_agent
	id = "drying_agent"
	specific_heat = 20
	name = "drying_agent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A70FFF"

/datum/gas/mutagenvirusfood
	id = "mutagenvirusfood"
	specific_heat = 20
	name = "mutagenvirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A3C00F"

/datum/gas/synaptizinevirusfood
	id = "synaptizinevirusfood"
	specific_heat = 20
	name = "synaptizinevirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#D18AA5"

/datum/gas/plasmavirusfood
	id = "plasmavirusfood"
	specific_heat = 20
	name = "plasmavirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A69DA9"

/datum/gas/weak
	id = "weak"
	specific_heat = 20
	name = "weak"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#CEC3C6"

/datum/gas/uraniumvirusfood
	id = "uraniumvirusfood"
	specific_heat = 20
	name = "uraniumvirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#67ADBA"

/datum/gas/stable
	id = "stable"
	specific_heat = 20
	name = "stable"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#04506C"

/datum/gas/laughtervirusfood
	id = "laughtervirusfood"
	specific_heat = 20
	name = "laughtervirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffa6ff"

/datum/gas/advvirusfood
	id = "advvirusfood"
	specific_heat = 20
	name = "advvirusfood"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ffffff"

/datum/gas/viralbase
	id = "viralbase"
	specific_heat = 20
	name = "viralbase"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#fff0da"

/datum/gas/royal_bee_jelly
	id = "royal_bee_jelly"
	specific_heat = 20
	name = "royal_bee_jelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00ff80"

/datum/gas/romerol
	id = "romerol"
	specific_heat = 20
	name = "romerol"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#123524"

/datum/gas/magillitis
	id = "magillitis"
	specific_heat = 20
	name = "magillitis"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00f041"

/datum/gas/growthserum
	id = "growthserum"
	specific_heat = 20
	name = "growthserum"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ff0000"

/datum/gas/plastic_polymers
	id = "plastic_polymers"
	specific_heat = 20
	name = "plastic_polymers"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#f7eded"

/datum/gas/glitter
	id = "glitter"
	specific_heat = 20
	name = "glitter"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/pink
	id = "pink"
	specific_heat = 20
	name = "pink"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ff8080"

/datum/gas/pax
	id = "pax"
	specific_heat = 20
	name = "pax"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AAAAAA55"

/datum/gas/bz_metabolites
	id = "bz_metabolites"
	specific_heat = 20
	name = "bz_metabolites"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFF00"

/datum/gas/concentrated_bz
	id = "concentrated_bz"
	specific_heat = 20
	name = "concentrated_bz"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFF00"

/datum/gas/fake_cbz
	id = "fake_cbz"
	specific_heat = 20
	name = "fake_cbz"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FAFF00"

/datum/gas/peaceborg
	id = "peaceborg"
	specific_heat = 20
	name = "peaceborg"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/confuse
	id = "confuse"
	specific_heat = 20
	name = "confuse"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/inabizine
	id = "inabizine"
	specific_heat = 20
	name = "inabizine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/tire
	id = "tire"
	specific_heat = 20
	name = "tire"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/tranquility
	id = "tranquility"
	specific_heat = 20
	name = "tranquility"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9A6750"

/datum/gas/liquidadamantine
	id = "liquidadamantine"
	specific_heat = 20
	name = "liquidadamantine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#10cca6"

/datum/gas/spider_extract
	id = "spider_extract"
	specific_heat = 20
	name = "spider_extract"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ED2939"

/datum/gas/ratlight
	id = "ratlight"
	specific_heat = 20
	name = "ratlight"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B5A642"

/datum/gas/invisium
	id = "invisium"
	specific_heat = 20
	name = "invisium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#85E3E9"

/datum/gas/thermite
	id = "thermite"
	specific_heat = 20
	name = "thermite"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#550000"

/datum/gas/nitroglycerin
	id = "nitroglycerin"
	specific_heat = 20
	name = "nitroglycerin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#808080"

/datum/gas/stabilizing_agent
	id = "stabilizing_agent"
	specific_heat = 20
	name = "stabilizing_agent"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFF00"

/datum/gas/clf3
	id = "clf3"
	specific_heat = 20
	name = "clf3"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFC8C8"

/datum/gas/sorium
	id = "sorium"
	specific_heat = 20
	name = "sorium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5A64C8"

/datum/gas/liquid_dark_matter
	id = "liquid_dark_matter"
	specific_heat = 20
	name = "liquid_dark_matter"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#210021"

/datum/gas/blackpowder
	id = "blackpowder"
	specific_heat = 20
	name = "blackpowder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#000000"

/datum/gas/flash_powder
	id = "flash_powder"
	specific_heat = 20
	name = "flash_powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/smoke_powder
	id = "smoke_powder"
	specific_heat = 20
	name = "smoke_powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/sonic_powder
	id = "sonic_powder"
	specific_heat = 20
	name = "sonic_powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/phlogiston
	id = "phlogiston"
	specific_heat = 20
	name = "phlogiston"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FA00AF"

/datum/gas/napalm
	id = "napalm"
	specific_heat = 20
	name = "napalm"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FA00AF"

/datum/gas/cryostylane
	id = "cryostylane"
	specific_heat = 20
	name = "cryostylane"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#0000DC"

/datum/gas/pyrosium
	id = "pyrosium"
	specific_heat = 20
	name = "pyrosium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#64FAC8"

/datum/gas/teslium
	id = "teslium"
	specific_heat = 20
	name = "teslium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#20324D"

/datum/gas/energized_jelly
	id = "energized_jelly"
	specific_heat = 20
	name = "energized_jelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#CAFF43"

/datum/gas/firefighting_foam
	id = "firefighting_foam"
	specific_heat = 20
	name = "firefighting_foam"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#A6FAFF55"

/datum/gas/toxin
	id = "toxin"
	specific_heat = 20
	name = "toxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#CF3600"

/datum/gas/amatoxin
	id = "amatoxin"
	specific_heat = 20
	name = "amatoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#792300"

/datum/gas/mutagen
	id = "mutagen"
	specific_heat = 20
	name = "mutagen"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00FF00"

/datum/gas/lexorin
	id = "lexorin"
	specific_heat = 20
	name = "lexorin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7DC3A0"

/datum/gas/slimejelly
	id = "slimejelly"
	specific_heat = 20
	name = "slimejelly"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#801E28"

/datum/gas/minttoxin
	id = "minttoxin"
	specific_heat = 20
	name = "minttoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#CF3600"

/datum/gas/carpotoxin
	id = "carpotoxin"
	specific_heat = 20
	name = "carpotoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#003333"

/datum/gas/zombiepowder
	id = "zombiepowder"
	specific_heat = 20
	name = "zombiepowder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#669900"

/datum/gas/ghoulpowder
	id = "ghoulpowder"
	specific_heat = 20
	name = "ghoulpowder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664700"

/datum/gas/mindbreaker
	id = "mindbreaker"
	specific_heat = 20
	name = "mindbreaker"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B31008"

/datum/gas/plantbgone
	id = "plantbgone"
	specific_heat = 20
	name = "plantbgone"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#49002E"

/datum/gas/weedkiller
	id = "weedkiller"
	specific_heat = 20
	name = "weedkiller"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#4B004B"

/datum/gas/pestkiller
	id = "pestkiller"
	specific_heat = 20
	name = "pestkiller"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#4B004B"

/datum/gas/spore
	id = "spore"
	specific_heat = 20
	name = "spore"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9ACD32"

/datum/gas/spore_burning
	id = "spore_burning"
	specific_heat = 20
	name = "spore_burning"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#9ACD32"

/datum/gas/chloralhydrate
	id = "chloralhydrate"
	specific_heat = 20
	name = "chloralhydrate"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#000067"

/datum/gas/fakebeer
	id = "fakebeer"
	specific_heat = 20
	name = "fakebeer"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#664300"

/datum/gas/coffeepowder
	id = "coffeepowder"
	specific_heat = 20
	name = "coffeepowder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5B2E0D"

/datum/gas/teapowder
	id = "teapowder"
	specific_heat = 20
	name = "teapowder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7F8400"

/datum/gas/mutetoxin
	id = "mutetoxin"
	specific_heat = 20
	name = "mutetoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F0F8FF"

/datum/gas/staminatoxin
	id = "staminatoxin"
	specific_heat = 20
	name = "staminatoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#6E2828"

/datum/gas/polonium
	id = "polonium"
	specific_heat = 20
	name = "polonium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#787878"

/datum/gas/histamine
	id = "histamine"
	specific_heat = 20
	name = "histamine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FA6464"

/datum/gas/formaldehyde
	id = "formaldehyde"
	specific_heat = 20
	name = "formaldehyde"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#B4004B"

/datum/gas/venom
	id = "venom"
	specific_heat = 20
	name = "venom"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F0FFF0"

/datum/gas/fentanyl
	id = "fentanyl"
	specific_heat = 20
	name = "fentanyl"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#64916E"

/datum/gas/cyanide
	id = "cyanide"
	specific_heat = 20
	name = "cyanide"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00B4FF"

/datum/gas/bad_food
	id = "bad_food"
	specific_heat = 20
	name = "bad_food"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#d6d6d8"

/datum/gas/itching_powder
	id = "itching_powder"
	specific_heat = 20
	name = "itching_powder"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/initropidril
	id = "initropidril"
	specific_heat = 20
	name = "initropidril"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7F10C0"

/datum/gas/pancuronium
	id = "pancuronium"
	specific_heat = 20
	name = "pancuronium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#195096"

/datum/gas/sodium_thiopental
	id = "sodium_thiopental"
	specific_heat = 20
	name = "sodium_thiopental"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#6496FA"

/datum/gas/sulfonal
	id = "sulfonal"
	specific_heat = 20
	name = "sulfonal"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7DC3A0"

/datum/gas/amanitin
	id = "amanitin"
	specific_heat = 20
	name = "amanitin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#FFFFFF"

/datum/gas/lipolicide
	id = "lipolicide"
	specific_heat = 20
	name = "lipolicide"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F0FFF0"

/datum/gas/coniine
	id = "coniine"
	specific_heat = 20
	name = "coniine"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#7DC3A0"

/datum/gas/spewium
	id = "spewium"
	specific_heat = 20
	name = "spewium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#2f6617"

/datum/gas/curare
	id = "curare"
	specific_heat = 20
	name = "curare"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#191919"

/datum/gas/heparin
	id = "heparin"
	specific_heat = 20
	name = "heparin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#C8C8C8"

/datum/gas/rotatium
	id = "rotatium"
	specific_heat = 20
	name = "rotatium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AC88CA"

/datum/gas/skewium
	id = "skewium"
	specific_heat = 20
	name = "skewium"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#ADBDCD"

/datum/gas/anacea
	id = "anacea"
	specific_heat = 20
	name = "anacea"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#3C5133"

/datum/gas/acid
	id = "acid"
	specific_heat = 20
	name = "acid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#00FF32"

/datum/gas/fluacid
	id = "fluacid"
	specific_heat = 20
	name = "fluacid"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#5050FF"

/datum/gas/delayed
	id = "delayed"
	specific_heat = 20
	name = "delayed"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1


/datum/gas/mimesbane
	id = "mimesbane"
	specific_heat = 20
	name = "mimesbane"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#F0F8FF"

/datum/gas/bonehurtingjuice
	id = "bonehurtingjuice"
	specific_heat = 20
	name = "bonehurtingjuice"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#AAAAAA77"

/datum/gas/bungotoxin
	id = "bungotoxin"
	specific_heat = 20
	name = "bungotoxin"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250
	chemgas = 1
	color = "#EBFF8E"

// END

/datum/gas/unobtanium //C++ monstermos expects 14 gas types to exist, we only had 13
	id = "unobtanium"
	specific_heat = 20
	name = "Unobtanium"
	rarity = 2500

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state, alph)
	. = ..()
	icon_state = state
	alpha = alph
