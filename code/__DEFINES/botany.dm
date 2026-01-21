///plant feature catagories
#define PLANT_FEATURE_FRUIT (1<<0)
#define PLANT_FEATURE_BODY (1<<1)
#define PLANT_FEATURE_ROOTS (1<<2)

///Plant data format
#define PLANT_DATA(title, data) list("data_title" = title, "data_field" = data)

/*
	Plant stat values
*/
//Body stat values
	//How many fruits this plant produces per yield
#define PLANT_BODY_HARVEST_MICRO 1
#define PLANT_BODY_HARVEST_SMALL 3
#define PLANT_BODY_HARVEST_MEDIUM 6
#define PLANT_BODY_HARVEST_LARGE 10
	//How many times can this plant be harvested
#define PLANT_BODY_YIELD_MICRO 1
#define PLANT_BODY_YIELD_SMALL 3
#define PLANT_BODY_YIELD_MEDIUM 5
#define PLANT_BODY_YIELD_LARGE 8
#define PLANT_BODY_YIELD_FOREVER INFINITY
	//How long between yields
#define PLANT_BODY_YIELD_TIME_SLOW 0//30 SECONDS
#define PLANT_BODY_YIELD_TIME_MEDIUM 0//15 SECONDS
#define PLANT_BODY_YIELD_TIME_FAST 0//5 SECONDS
	//How many planter slots does this body take up
#define PLANT_BODY_SLOT_SIZE_MICRO 0.5 //Use this for mushrooms, weeds, and other support plants
#define PLANT_BODY_SLOT_SIZE_SMALL 1
#define PLANT_BODY_SLOT_SIZE_MEDIUM 2
#define PLANT_BODY_SLOT_SIZE_LARGE 3.5
#define PLANT_BODY_SLOT_SIZE_LARGEST 4 //Probably don't use this, unless you know what you're doing
	//Health array
#define PLANT_BODY_HEALTH_SMALL 50
#define PLANT_BODY_HEALTH_MEDIUM 100
#define PLANT_BODY_HEALTH_LARGE 200
	//Plant body growth times
#define PLANT_BODY_GROWTH_SLOW 2 SECONDS//129 SECONDS
#define PLANT_BODY_GROWTH_MEDIUM 2 SECONDS//60 SECONDS
#define PLANT_BODY_GROWTH_FAST 2 SECONDS//40 SECONDS
#define PLANT_BODY_GROWTH_VERY_FAST 2 SECONDS//10 SECONDS

//Fruit stat values
	//How many reagents can the fruit hold
#define PLANT_FRUIT_VOLUME_MICRO 8
#define PLANT_FRUIT_VOLUME_SMALL 15
#define PLANT_FRUIT_VOLUME_MEDIUM 28
#define PLANT_FRUIT_VOLUME_LARGE 50
#define PLANT_FRUIT_VOLUME_VERY_LARGE 100
	//How long it takes the fruit to grow to maturity
#define PLANT_FRUIT_GROWTH_SLOW 2 SECONDS//60 SECONDS
#define PLANT_FRUIT_GROWTH_MEDIUM 2 SECONDS//30 SECONDS
#define PLANT_FRUIT_GROWTH_FAST 2 SECONDS//20 SECONDS
#define PLANT_FRUIT_GROWTH_VERY_FAST 2 SECONDS//5 SECONDS

//Reagent values as a %
#define PLANT_REAGENT_MICRO 0.05
#define PLANT_REAGENT_SMALL 0.15
#define PLANT_REAGENT_MEDIUM 0.25
#define PLANT_REAGENT_LARGE 0.45
#define PLANT_REAGENT_VERY_LARGE 0.75

///Substrate flags
#define PLANT_SUBSTRATE_DIRT (1<<0)
#define PLANT_SUBSTRATE_SAND (1<<1)
#define PLANT_SUBSTRATE_CLAY (1<<2)
#define PLANT_SUBSTRATE_DEBRIS (1<<3)

///Fruit sizes
#define PLANT_FRUIT_SIZE_SMALL 1
#define PLANT_FRUIT_SIZE_MEDIUM 2
#define PLANT_FRUIT_SIZE_LARGE 3

//plant genes
#define PLANT_GENE_INDEX_FEATURES "PLANT_GENE_INDEX_FEATURES"
#define PLANT_GENE_INDEX_ID "PLANT_GENE_INDEX_ID"
