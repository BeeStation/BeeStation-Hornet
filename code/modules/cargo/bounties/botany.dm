/datum/bounty/item/botany
	reward = 5000
	var/datum/bounty/item/botany/multiplier = 0 //adds bonus reward money; increased for higher tier or rare mutations
	var/datum/bounty/item/botany/bonus_desc //for adding extra flavor text to bounty descriptions
	var/datum/bounty/item/botany/foodtype = "meal" //same here
	var/datum/bounty/item/botany/format_exception = FALSE //Set to true if the bounty uses a custom format from the one below

/datum/bounty/item/botany/New()
	..()

	if (format_exception == FALSE)
		description = "Central Command's head chef is looking to prepare a fine [foodtype] with [name]. [bonus_desc]"
		reward += multiplier * 1000
		required_count = rand(5, 10)

/datum/bounty/item/botany/ambrosia_vulgaris
	name = "Ambrosia Vulgaris Leaves"
	wanted_types = list(
		/obj/item/food/grown/ambrosia/vulgaris = TRUE,
	)
	foodtype = "stew"

/datum/bounty/item/botany/ambrosia_gaia
	name = "Ambrosia Gaia Leaves"
	wanted_types = list(
		/obj/item/food/grown/ambrosia/gaia = TRUE,
	)
	multiplier = 4
	foodtype = "stew"

/datum/bounty/item/botany/apple_golden
	name = "Golden Apples"
	wanted_types = list(
		/obj/item/food/grown/apple/gold = TRUE,
	)
	multiplier = 4
	foodtype = "dessert"

/datum/bounty/item/botany/banana
	name = "Bananas"
	wanted_types = list(
		/obj/item/food/grown/banana = TRUE,
		/obj/item/food/grown/banana/bluespace = FALSE,
	)
	foodtype = "banana split"

/datum/bounty/item/botany/banana_bluespace
	name = "Bluespace Bananas"
	wanted_types = list(
		/obj/item/food/grown/banana/bluespace = TRUE,
	)
	multiplier = 2
	foodtype = "banana split"

/datum/bounty/item/botany/beans_koi
	name = "Koi Beans"
	wanted_types = list(
		/obj/item/food/grown/koibeans = TRUE,
	)
	multiplier = 2

/datum/bounty/item/botany/berries_death
	name = "Death Berries"
	wanted_types = list(
		/obj/item/food/grown/berries/death = TRUE,
	)
	multiplier = 2
	bonus_desc = "He insists that \"he knows what he's doing\"."
	foodtype = "sorbet"

/datum/bounty/item/botany/berries_glow
	name = "Glow-Berries"
	wanted_types = list(
		/obj/item/food/grown/berries/glow = TRUE,
	)
	multiplier = 2
	foodtype = "sorbet"

/datum/bounty/item/botany/cannabis
	name = "Cannabis Leaves"
	wanted_types = list(
		/obj/item/food/grown/cannabis = TRUE,
		/obj/item/food/grown/cannabis/white = FALSE,
		/obj/item/food/grown/cannabis/death = FALSE,
		/obj/item/food/grown/cannabis/ultimate = FALSE,
	)
	multiplier = 4 //hush money
	bonus_desc = "Do not mention this shipment to security."
	foodtype = "batch of \"muffins\""

/datum/bounty/item/botany/cannabis_white
	name = "Lifeweed Leaves"
	wanted_types = list(
		/obj/item/food/grown/cannabis/white = TRUE,
	)
	multiplier = 6
	bonus_desc = "Do not mention this shipment to security."
	foodtype = "\"meal\""

/datum/bounty/item/botany/cannabis_death
	name = "Deathweed Leaves"
	wanted_types = list(
		/obj/item/food/grown/cannabis/death = TRUE,
	)
	multiplier = 6
	bonus_desc = "Do not mention this shipment to security."
	foodtype = "\"meal\""

/datum/bounty/item/botany/cannabis_ultimate
	name = "Omega Weed Leaves"
	wanted_types = list(
		/obj/item/food/grown/cannabis/ultimate = TRUE,
	)
	multiplier = 6
	bonus_desc = "Under no circumstances mention this shipment to security."
	foodtype = "batch of \"brownies\""

/datum/bounty/item/botany/wheat
	name = "Wheat Grains"
	wanted_types = list(
		/obj/item/food/grown/wheat = TRUE,
	)

/datum/bounty/item/botany/rice
	name = "Rice Grains"
	wanted_types = list(
		/obj/item/food/grown/rice = TRUE,
	)

/datum/bounty/item/botany/chili
	name = "Chili Peppers"
	wanted_types = list(
		/obj/item/food/grown/chili = TRUE,
	)

/datum/bounty/item/botany/chili
	name = "Ice Chili Peppers"
	wanted_types = list(
		/obj/item/food/grown/icepepper = TRUE,
	)
	multiplier = 2

/datum/bounty/item/botany/chili
	name = "Ghost Chili Peppers"
	wanted_types = list(
		/obj/item/food/grown/ghost_chili = TRUE,
	)
	multiplier = 2

/datum/bounty/item/botany/citrus_lime
	name = "Limes"
	wanted_types = list(
		/obj/item/food/grown/citrus/lime = TRUE,
	)
	foodtype = "sorbet"

/datum/bounty/item/botany/citrus_lemon
	name = "Lemons"
	wanted_types = list(
		/obj/item/food/grown/citrus/lemon = TRUE,
	)
	foodtype = "sorbet"

/datum/bounty/item/botany/citrus_oranges
	name = "Oranges"
	wanted_types = list(
		/obj/item/food/grown/citrus/orange = TRUE,
	)
	bonus_desc = "Do not ship lemons or limes." //I vanted orahnge!
	foodtype = "sorbet"

/datum/bounty/item/botany/eggplant
	name = "Eggplants"
	wanted_types = list(
		/obj/item/food/grown/eggplant = TRUE,
	)
	bonus_desc = "Not to be confused with egg-plants."

/datum/bounty/item/botany/eggplant_eggy
	name = "Egg-plants"
	wanted_types = list(
		/obj/item/food/grown/shell/eggy = TRUE,
	)
	bonus_desc = "Not to be confused with eggplants."
	multiplier = 2

/datum/bounty/item/botany/kudzu
	name = "Kudzu Pods"
	wanted_types = list(
		/obj/item/food/grown/kudzupod = TRUE,
	)
	bonus_desc = "Store in a dry, dark place."
	multiplier = 4

/datum/bounty/item/botany/watermelon
	name = "Watermelons"
	wanted_types = list(
		/obj/item/food/grown/watermelon = TRUE,
	)
	foodtype = "dessert"

/datum/bounty/item/botany/watermelon_holy
	name = "Holy Melons"
	wanted_types = list(
		/obj/item/food/grown/holymelon = TRUE,
	)
	multiplier = 2
	foodtype = "dessert"

/datum/bounty/item/botany/glowshroom
	name = "Glowshrooms"
	wanted_types = list(
		/obj/item/food/grown/mushroom/glowshroom = TRUE,
		/obj/item/food/grown/mushroom/glowshroom/glowcap = FALSE,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom = FALSE,
	)
	foodtype = "omelet"

/datum/bounty/item/botany/glowshroom_cap
	name = "Glowcaps"
	wanted_types = list(
		/obj/item/food/grown/mushroom/glowshroom/glowcap = TRUE,
	)
	multiplier = 2
	foodtype = "omelet"

/datum/bounty/item/botany/glowshroom_shadow
	name = "Shadowshrooms"
	wanted_types = list(
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom = TRUE,
	)
	multiplier = 2
	foodtype = "omelet"

/datum/bounty/item/botany/nettles_death
	name = "Death Nettles"
	wanted_types = list(
		/obj/item/food/grown/nettle/death = TRUE,
	)
	multiplier = 2
	bonus_desc = "Wear protection when handling them."
	foodtype = "cheese"

/datum/bounty/item/botany/pineapples
	name = "Pineapples"
	wanted_types = list(
		/obj/item/food/grown/pineapple = TRUE,
	)
	bonus_desc = "Not for human consumption."
	foodtype = "ashtray"

/datum/bounty/item/botany/tomato
	name = "Tomatoes"
	wanted_types = list(
		/obj/item/food/grown/tomato = TRUE,
		/obj/item/food/grown/tomato/blue = FALSE,
	)

/datum/bounty/item/botany/tomato_bluespace
	name = "Bluespace Tomatoes"
	wanted_types = list(
		/obj/item/food/grown/tomato/blue/bluespace = TRUE,
	)
	multiplier = 4

/datum/bounty/item/botany/oatz
	name = "Oats"
	wanted_types = list(
		/obj/item/food/grown/oat = TRUE,
	)
	multiplier = 2
	foodtype = "batch of oatmeal"
	bonus_desc = "Squats and oats. We're all out of oats."

/datum/bounty/item/botany/forgetmenot
	name = "Forget-Me-Nots"
	description = "Commander Zot has his eyes on Quartermaster Maya. Send a shipment of forget-me-nots - her favorite flower - and he'll happily reward you."
	reward = 7000
	required_count = 3
	wanted_types = list(
		/obj/item/food/grown/flower/forgetmenot = TRUE,
	)
	format_exception = TRUE

/datum/bounty/item/botany/geranium
	name = "Geraniums"
	description = "Commander Zot has the hots for Commander Zena. Send a shipment of geraniums - her favorite flower - and he'll happily reward you."
	reward = 6000
	required_count = 3
	wanted_types = list(
		/obj/item/food/grown/flower/geranium = TRUE,
	)
	format_exception = TRUE

/datum/bounty/item/botany/rainbowflowercrown
	name = "Rainbow Flower Crowns"
	description = "Central Command is concerned about their intern suicide rate. A shipment of rainbow flower crowns should do nicely to improve morale."
	reward = 10000
	required_count = 3
	wanted_types = list(
		/obj/item/clothing/head/flowercrown/rainbowbunch = TRUE,
	)
	format_exception = TRUE
