/*
	Seller personality for the RND listing console
*/

#define SELLER_PERSONALITY_GENEROUS "SELLER_PERSONALITY_GENEROUS"
#define SELLER_PERSONALITY_NORMAL "SELLER_PERSONALITY_NORMAL"
#define SELLER_PERSONALITY_STINGY "SELLER_PERSONALITY_STINGY"

//Move this to its own datum file if you implement it for other sub departments of science
/datum/rnd_lister
	///What is this slimeball's name
	var/name = "Petrikov"
	///What nonsense flavor dialogue do they spout
	var/dialogue = ""
	///What kind of selling personality do they have
	var/personality = SELLER_PERSONALITY_GENEROUS
	///How often do they restock their... stock
	var/restock_time = 1 MINUTES
	///What science thingy are they selling
	var/atom/stock_type
	var/list/current_stock = list()
	var/max_stock = 1

/datum/rnd_lister/New()
	. = ..()
	//Generate initial stock
	replenish_stock(max_stock)

//Generic random seller
/datum/rnd_lister/random/New()
	. = ..()
	///Randomized stats
	name = pick(SSxenoarchaeology.xenoa_seller_names)
	dialogue = pick(SSxenoarchaeology.xenoa_seller_dialogue)
	personality = pick(list(SELLER_PERSONALITY_GENEROUS, SELLER_PERSONALITY_NORMAL, SELLER_PERSONALITY_STINGY))

/datum/rnd_lister/proc/get_new_stock()
	return new stock_type()

///Get the price of an atom, persumably our stock, based on our selling personality
/datum/rnd_lister/proc/get_price(atom/listing)
	switch(personality)
		if(SELLER_PERSONALITY_GENEROUS)
			return round(listing.item_price * 0.8, 1)
		if(SELLER_PERSONALITY_NORMAL)
			return listing.item_price
		if(SELLER_PERSONALITY_STINGY)
			return round(listing.item_price * 1.5, 1)
		else
			return 0 //FOR FREE!

/datum/rnd_lister/proc/buy_stock(atom/listing)
	//Remove stock and prepare to replace it
	current_stock -= listing
	addtimer(CALLBACK(src, PROC_REF(replenish_stock)), restock_time)
	return listing

/datum/rnd_lister/proc/replenish_stock(amount = 1)
	for(var/listing_index in 1 to amount)
		var/atom/listing = get_new_stock()
		current_stock += listing

/*
	Artifact sellers
*/

/datum/rnd_lister/artifact_seller
	///What kind of artifacts do we sell - Weighted list
	var/list/artifact_types = list(XENOA_BLUESPACE = 1, XENOA_PLASMA = 1, XENOA_URANIUM = 1, XENOA_BANANIUM = 1)

/datum/rnd_lister/artifact_seller/get_new_stock()
	var/datum/xenoartifact_material/material = pick_weight(artifact_types)
	var/obj/item/xenoartifact/artifact = new(null, material)
	return artifact

/*
	Actual types of artifact sellers
*/

//Will sell random artifacts equally
/datum/rnd_lister/artifact_seller/bastard
	name = "Sidorovich"
	dialogue = "What are you standing there for? come closer."
	personality = SELLER_PERSONALITY_NORMAL
	max_stock = 2

//Sells uranium, and rarely, banaium artifacts
/datum/rnd_lister/artifact_seller/uranium_bananium
	name = "Deepthroat"
	dialogue = "..."
	personality = SELLER_PERSONALITY_STINGY
	artifact_types = list(XENOA_URANIUM = 3, XENOA_BANANIUM = 1)

//Sells bluespace
/datum/rnd_lister/artifact_seller/bluespace
	name = "Raichovich"
	dialogue = "These things make my head hurt, take the from me!"
	personality = SELLER_PERSONALITY_NORMAL
	artifact_types = list(XENOA_BLUESPACE = 1)
	max_stock = 3

//Sells plasma & bluespace
/datum/rnd_lister/artifact_seller/plasma_bluespace
	name = "Shalashaska"
	dialogue = "Maybe I'm colorblind, but some of these don't look blue..."
	personality = SELLER_PERSONALITY_STINGY
	artifact_types = list(XENOA_BLUESPACE = 1, XENOA_PLASMA = 1)
	max_stock = 2

/*
	Supply pack for this system
	Whenever a listing is purchased, a supply pack with the purchased items is returned
*/
/datum/supply_pack/science_listing
	name = "Research Material Listing"
	desc = "Contains potentially hazardous materials, or ridiculous ties."
	hidden = TRUE
	crate_name = "research material container"
	crate_type = /obj/structure/closet/crate/science
	max_supply = 1
	current_supply = 1
	cost = 0
	can_secure = FALSE

#undef SELLER_PERSONALITY_GENEROUS
#undef SELLER_PERSONALITY_NORMAL
#undef SELLER_PERSONALITY_STINGY
