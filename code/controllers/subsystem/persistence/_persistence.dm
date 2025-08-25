SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()
	var/list/saved_trophies = list()
	var/list/picture_logging_information = list()
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums

	/// Antag reputation
	var/list/antag_rep = list()
	var/list/antag_rep_change = list()

	/// Used to track SM delamination statistics
	var/rounds_since_engine_exploded = 0
	var/delam_highscore = 0

/datum/controller/subsystem/persistence/Initialize()
	load_poly()
	load_chisel_messages()
	load_trophies()
	load_photo_persistence()
	if(CONFIG_GET(flag/use_antag_rep))
		load_antag_reputation()
	load_custom_outfits()
	load_delamination_counter()
	return SS_INIT_SUCCESS

/**
 * Collects all data that is saved in-between rounds
 **/
/datum/controller/subsystem/persistence/proc/collect_data()
	collect_chisel_messages()
	collect_trophies()
	save_photo_persistence()
	if(CONFIG_GET(flag/use_antag_rep))
		collect_antag_reputation()
	save_custom_outfits()
	save_delamination_counter()

/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/simple_animal/parrot/Poly/stupid_bird in GLOB.alive_mob_list)
		twitterize(stupid_bird.speech_buffer, "polytalk")
		break //Who's been duping the bird?!
