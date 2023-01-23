/* Cloth */

GLOBAL_LIST_INIT(cloth_recipes, list ( \
	new/datum/stack_recipe("white jumpsuit",						/obj/item/clothing/under/color/white, 3), \
	new/datum/stack_recipe("white shoes",							/obj/item/clothing/shoes/sneakers/white, 2), \
	new/datum/stack_recipe("white scarf",							/obj/item/clothing/neck/scarf, 1), \
	new/datum/stack_recipe("white hoodie",							/obj/item/clothing/suit/hooded/hoodie, 5), \
	null, \
	new/datum/stack_recipe("backpack",								/obj/item/storage/backpack, 4), \
	new/datum/stack_recipe("duffel bag",							/obj/item/storage/backpack/duffelbag, 6), \
	null, \
	new/datum/stack_recipe("plant bag",								/obj/item/storage/bag/plants, 4), \
	new/datum/stack_recipe("book bag",								/obj/item/storage/bag/books, 4), \
	new/datum/stack_recipe("mining satchel",						/obj/item/storage/bag/ore, 4), \
	new/datum/stack_recipe("chemistry bag",							/obj/item/storage/bag/chemistry, 4), \
	new/datum/stack_recipe("bio bag",								/obj/item/storage/bag/bio, 4), \
	new/datum/stack_recipe("construction bag",						/obj/item/storage/bag/construction, 4), \
	new/datum/stack_recipe("sheet snatcher",						/obj/item/storage/bag/sheetsnatcher, 6), \
	null, \
	new/datum/stack_recipe("improvised gauze",						/obj/item/stack/medical/gauze/improvised, 1, 2, 6), \
	new/datum/stack_recipe("rag",									/obj/item/reagent_containers/glass/rag, 1), \
	new/datum/stack_recipe("bedsheet",								/obj/item/bedsheet, 3), \
	new/datum/stack_recipe("double bedsheet",						/obj/item/bedsheet, 6), \
	new/datum/stack_recipe("empty sandbag",							/obj/item/emptysandbag, 4), \
	null, \
	new/datum/stack_recipe("fingerless gloves",						/obj/item/clothing/gloves/fingerless, 1), \
	new/datum/stack_recipe("white gloves",							/obj/item/clothing/gloves/color/white, 3), \
	new/datum/stack_recipe("white softcap",							/obj/item/clothing/head/soft, 2), \
	new/datum/stack_recipe("white beanie",							/obj/item/clothing/head/beanie, 2), \
	null, \
	new/datum/stack_recipe("blindfold",								/obj/item/clothing/glasses/blindfold, 2), \
	null, \
	new/datum/stack_recipe("19x19 canvas",							/obj/item/canvas/nineteen_nineteen, 3), \
	new/datum/stack_recipe("23x19 canvas",							/obj/item/canvas/twentythree_nineteen, 4), \
	new/datum/stack_recipe("23x23 canvas",							/obj/item/canvas/twentythree_twentythree, 5), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cotton/cloth)

/* Durathread cloth*/

GLOBAL_LIST_INIT(durathread_recipes, list ( \
	new/datum/stack_recipe("durathread jumpsuit",					/obj/item/clothing/under/color/durathread, 4, time = 4 SECONDS), \
	new/datum/stack_recipe("durathread beret",						/obj/item/clothing/head/beret/durathread, 2, time = 4 SECONDS), \
	new/datum/stack_recipe("durathread beanie",						/obj/item/clothing/head/beanie/durathread, 2, time = 4 SECONDS), \
	new/datum/stack_recipe("durathread bandana",					/obj/item/clothing/mask/bandana/durathread, 1, time = 2.5 SECONDS), \
	new/datum/stack_recipe("durathread hoodie",						/obj/item/clothing/suit/hooded/hoodie/durathread, 5, time = 5 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cotton/cloth/durathread)

/* Silk */

GLOBAL_LIST_INIT(silk_recipes, list ( \
	new/datum/stack_recipe("silk string",							/obj/item/weaponcrafting/silkstring, 2, time = 4 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/silk)
