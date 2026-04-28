/* Cloth */

GLOBAL_LIST_INIT(cloth_recipes, list ( \
	new/datum/stack_recipe("white jumpskirt", /obj/item/clothing/under/color/jumpskirt/white, 3, category = CAT_CLOTHING), /*Ladies first*/ \
	new/datum/stack_recipe("white jumpsuit", /obj/item/clothing/under/color/white, 3, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white shoes", /obj/item/clothing/shoes/sneakers/white, 2, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white scarf", /obj/item/clothing/neck/scarf, 1, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white bandana", /obj/item/clothing/mask/bandana/white, 2, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white hoodie", /obj/item/clothing/suit/hooded/hoodie, 5, time = 4 SECONDS, category = CAT_CLOTHING), \
	null, \
	new/datum/stack_recipe("backpack", /obj/item/storage/backpack, 4, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("duffel bag", /obj/item/storage/backpack/duffelbag, 6, category = CAT_CONTAINERS), \
	null, \
	new/datum/stack_recipe("plant bag", /obj/item/storage/bag/plants, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("book bag", /obj/item/storage/bag/books, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("mail bag", /obj/item/storage/backpack/satchel/mail, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("mining satchel", /obj/item/storage/bag/ore, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("chemistry bag", /obj/item/storage/bag/chemistry, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("bio bag", /obj/item/storage/bag/bio, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("construction bag", /obj/item/storage/bag/construction, 4, time = 4 SECONDS, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("sheet snatcher", /obj/item/storage/bag/sheetsnatcher, 6, time = 4 SECONDS, category = CAT_CONTAINERS), \
	null, \
	new/datum/stack_recipe("improvised gauze", /obj/item/stack/medical/gauze/improvised, 1, 2, 6, category = CAT_TOOLS), \
	new/datum/stack_recipe("rag", /obj/item/reagent_containers/cup/rag, 1, time = 1 SECONDS, category = CAT_CHEMISTRY), \
	new/datum/stack_recipe("bedsheet", /obj/item/bedsheet, 3, time = 4 SECONDS, category = CAT_FURNITURE), \
	new/datum/stack_recipe("double bedsheet", /obj/item/bedsheet/double, 6, time = 8 SECONDS, category = CAT_FURNITURE), \
	new/datum/stack_recipe("empty sandbag", /obj/item/emptysandbag, 4, time = 2 SECONDS, category = CAT_CONTAINERS), \
	null, \
	new/datum/stack_recipe("fingerless gloves", /obj/item/clothing/gloves/fingerless, 1, time = 3 SECONDS, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white gloves", /obj/item/clothing/gloves/color/white, 3, time = 4 SECONDS, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white softcap", /obj/item/clothing/head/soft, 2, time = 4 SECONDS, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white beanie", /obj/item/clothing/head/beanie, 2, time = 4 SECONDS, category = CAT_CLOTHING), \
	new/datum/stack_recipe("white bandana", /obj/item/clothing/mask/bandana, 1, time = 2.5 SECONDS, category = CAT_CLOTHING), \
	null, \
	new/datum/stack_recipe("blindfold", /obj/item/clothing/glasses/blindfold, 2, time = 4 SECONDS, category = CAT_CLOTHING), \
	null, \
	new/datum/stack_recipe("19x19 canvas", /obj/item/canvas/nineteen_nineteen, 3, time = 3 SECONDS, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("23x19 canvas", /obj/item/canvas/twentythree_nineteen, 4, time = 4 SECONDS, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("23x23 canvas", /obj/item/canvas/twentythree_twentythree, 5, time = 5 SECONDS, category = CAT_ENTERTAINMENT), \
	null, \
	new/datum/stack_recipe("plush fabric", /obj/item/toy/empty_plush, 5, time = 4 SECONDS, category = CAT_ENTERTAINMENT), \
	null, \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cotton/cloth)

/* Durathread cloth*/

GLOBAL_LIST_INIT(durathread_recipes, list ( \
	new/datum/stack_recipe("durathread jumpsuit", /obj/item/clothing/under/color/durathread, 4, time = 4 SECONDS, category = CAT_CLOTHING),
	new/datum/stack_recipe("durathread jumpskirt", /obj/item/clothing/under/color/jumpskirt/durathread, 4, time = 4 SECONDS, category = CAT_CLOTHING),
	new/datum/stack_recipe("durathread beret", /obj/item/clothing/head/beret/durathread, 2, time = 4 SECONDS, category = CAT_CLOTHING),
	new/datum/stack_recipe("durathread beanie", /obj/item/clothing/head/beanie/durathread, 2, time = 4 SECONDS, category = CAT_CLOTHING),
	new/datum/stack_recipe("durathread bandana", /obj/item/clothing/mask/bandana/durathread, 1, time = 25, category = CAT_CLOTHING),
	new/datum/stack_recipe("durathread hoodie", /obj/item/clothing/suit/hooded/hoodie/durathread, 5, time = 5 SECONDS, category = CAT_CLOTHING),
))

STACKSIZE_MACRO(/obj/item/stack/sheet/cotton/cloth/durathread)

/* Silk */

GLOBAL_LIST_INIT(silk_recipes, list ( \
	new/datum/stack_recipe("silk string", /obj/item/weaponcrafting/silkstring, 2, time = 4 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/silk)
