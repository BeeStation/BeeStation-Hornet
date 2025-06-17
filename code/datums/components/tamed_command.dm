//Component used for tamed simplemobs, mostly just handles setting AI and generating icons
/datum/component/tamed_command
	///Mobs base icon
	var/icon/base_icon
	///Holder for allies
	var/list/allies = list()

/datum/component/tamed_command/Initialize(...)
	if(isliving(parent))
		var/mob/living/simple_animal/M = parent
		//set ai
		M.ai_controller = new /datum/ai_controller/tamed(M)
		//Add riding component
		M.tame = TRUE
		M.can_buckle = TRUE
		M.buckle_lying = 0
		var/datum/component/riding/D = M.LoadComponent(/datum/component/riding/creature/tamed)
		D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(0, 8), TEXT_WEST = list( 0, 8)))
		D.set_vehicle_dir_layer(NORTH, M.layer)
		D.set_vehicle_dir_layer(EAST, M.layer-0.1)
		D.set_vehicle_dir_layer(WEST, M.layer-0.1)
		D.set_vehicle_dir_layer(SOUTH, M.layer+0.1)
		//Command icons
		generate_icons()

	..()

/datum/component/tamed_command/proc/generate_icons()
	//Setup icons for AI
	var/mob/living/P = parent
	if(istype(P))
		var/datum/ai_controller/tamed/T = P.ai_controller
		var/icon/mob_mask = new(P.icon, P.icon_state)
		var/icon/mob_texture = new(P.icon, P.icon_state)
		var/icon/mob_base = new('icons/obj/carp_lasso.dmi', "cutter") //keeps the icons at 32x32
		mob_texture.Blend("#FFF", ICON_OVERLAY)
		mob_texture.AddAlphaMask(mob_mask)
		mob_base.Blend(mob_texture, ICON_OVERLAY)

		//Some of this is janky, it's just all the icons generating
		var/icon/holder = new('icons/obj/carp_lasso.dmi', "carp_follow") //follow icon
		var/icon/other_holder = new(mob_base)
		holder.Blend(other_holder, ICON_OVERLAY)
		T.follow_icon = new(holder)

		holder = new('icons/obj/carp_lasso.dmi', "carp_stop") //stop icon
		other_holder = new(mob_base)
		other_holder.Blend(holder, ICON_OVERLAY)
		T.stop_icon = new(other_holder)

		holder = new('icons/obj/carp_lasso.dmi', "carp_wander") //stop icon
		other_holder = new(mob_base)
		other_holder.Blend(holder, ICON_OVERLAY)
		T.wander_icon = new(other_holder)

		T.attack_icon = new('icons/obj/carp_lasso.dmi', "carp_attack")

///Add allies
/datum/component/tamed_command/proc/add_ally(var/mob/living/M)
	var/mob/living/P = parent
	if(istype(P))
		var/datum/ai_controller/tamed/T = P.ai_controller
		T.befriend(M)
