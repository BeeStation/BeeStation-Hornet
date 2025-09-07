SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	/// Soapstone messages
	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()

	/// Library trophies
	var/list/saved_trophies = list()

	/// Pictures and photo albums
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums

	/// Antag reputation
	var/list/antag_rep = list()
	var/list/antag_rep_change = list()

/datum/controller/subsystem/persistence/Initialize()
	if(CONFIG_GET(flag/use_antag_rep))
		load_antag_reputation()
	load_poly()
	load_chisel_messages()
	load_trophies()
	load_photo_persistence()
	load_custom_outfits()
	return SS_INIT_SUCCESS

/**
 * Collects all data that is saved in-between rounds
 **/
/datum/controller/subsystem/persistence/proc/collect_data()
	if(CONFIG_GET(flag/use_antag_rep))
		collect_antag_reputation()
	collect_chisel_messages()
	collect_trophies()
	save_photo_persistence()
	save_custom_outfits()

/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/simple_animal/parrot/Poly/stupid_bird in GLOB.alive_mob_list)
		twitterize(stupid_bird.speech_buffer, "polytalk")
		break //Who's been duping the bird?!
