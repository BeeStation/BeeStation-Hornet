/// An associative list of sound effect paths to instances
GLOBAL_LIST_INIT(sfx_datums_by_paths, init_subtypes_w_path_keys(/datum/sound_effect))

/**
 * The sound effect datum is a helper datum to easily get a sound effect from a group.
 * Simply create a new sub-type, and specify your file_paths list.
 */
/datum/sound_effect
	abstract_type = /datum/sound_effect
	/// list of paths to our files, use the /assoc subtype if your paths are weighted
	var/list/file_paths

/datum/sound_effect/proc/return_sfx()
	return pick(file_paths)

/datum/sound_effect/shatter
	file_paths = list(
		'sound/effects/glass/glassbr1.ogg',
		'sound/effects/glass/glassbr2.ogg',
		'sound/effects/glass/glassbr3.ogg',
	)

/datum/sound_effect/explosion
	file_paths = list(
		'sound/effects/explosion/explosion1.ogg',
		'sound/effects/explosion/explosion2.ogg',
	)

/datum/sound_effect/explosion_creaking
	file_paths = list(
		'sound/effects/explosion/explosioncreak1.ogg',
		'sound/effects/explosion/explosioncreak2.ogg',
	)

/datum/sound_effect/hull_creaking
	file_paths = list(
		'sound/effects/creak/creak1.ogg',
		'sound/effects/creak/creak2.ogg',
		'sound/effects/creak/creak3.ogg',
	)

/datum/sound_effect/sparks
	file_paths = list(
		'sound/effects/sparks/sparks1.ogg',
		'sound/effects/sparks/sparks2.ogg',
		'sound/effects/sparks/sparks3.ogg',
		'sound/effects/sparks/sparks4.ogg',
	)

/datum/sound_effect/rustle
	file_paths = list(
		'sound/effects/rustle/rustle1.ogg',
		'sound/effects/rustle/rustle2.ogg',
		'sound/effects/rustle/rustle3.ogg',
		'sound/effects/rustle/rustle4.ogg',
		'sound/effects/rustle/rustle5.ogg',
	)

/datum/sound_effect/bodyfall
	file_paths = list(
		'sound/effects/bodyfall/bodyfall1.ogg',
		'sound/effects/bodyfall/bodyfall2.ogg',
		'sound/effects/bodyfall/bodyfall3.ogg',
		'sound/effects/bodyfall/bodyfall4.ogg',
	)

/datum/sound_effect/punch
	file_paths = list(
		'sound/weapons/punch/punch1.ogg',
		'sound/weapons/punch/punch2.ogg',
		'sound/weapons/punch/punch3.ogg',
		'sound/weapons/punch/punch4.ogg',
	)

/datum/sound_effect/clown_step
	file_paths = list(
		'sound/effects/footstep/clownstep1.ogg',
		'sound/effects/footstep/clownstep2.ogg',
	)

/datum/sound_effect/swing_hit
	file_paths = list(
		'sound/weapons/genhit1.ogg',
		'sound/weapons/genhit2.ogg',
		'sound/weapons/genhit3.ogg',
	)

/datum/sound_effect/hiss
	file_paths = list(
		'sound/mobs/non-humanoids/hiss/hiss1.ogg',
		'sound/mobs/non-humanoids/hiss/hiss2.ogg',
		'sound/mobs/non-humanoids/hiss/hiss3.ogg',
		'sound/mobs/non-humanoids/hiss/hiss4.ogg',
	)

/datum/sound_effect/page_turn
	file_paths = list(
		'sound/effects/page_turn/pageturn1.ogg',
		'sound/effects/page_turn/pageturn2.ogg',
		'sound/effects/page_turn/pageturn3.ogg',
	)

/datum/sound_effect/ricochet
	file_paths = list(
		'sound/weapons/effects/ric1.ogg',
		'sound/weapons/effects/ric2.ogg',
		'sound/weapons/effects/ric3.ogg',
		'sound/weapons/effects/ric4.ogg',
		'sound/weapons/effects/ric5.ogg',
	)

/datum/sound_effect/terminal_type
	file_paths = list(
		'sound/machines/terminal/terminal_button01.ogg',
		'sound/machines/terminal/terminal_button02.ogg',
		'sound/machines/terminal/terminal_button03.ogg',
		'sound/machines/terminal/terminal_button04.ogg',
		'sound/machines/terminal/terminal_button05.ogg',
		'sound/machines/terminal/terminal_button06.ogg',
		'sound/machines/terminal/terminal_button07.ogg',
		'sound/machines/terminal/terminal_button08.ogg',
	)

/datum/sound_effect/desecration
	file_paths = list(
		'sound/effects/desecration/desecration-01.ogg',
		'sound/effects/desecration/desecration-02.ogg',
		'sound/effects/desecration/desecration-03.ogg',
	)

/datum/sound_effect/can_open
	file_paths = list(
		'sound/items/can/can_open1.ogg',
		'sound/items/can/can_open2.ogg',
		'sound/items/can/can_open3.ogg',
	)

/datum/sound_effect/bullet_miss
	file_paths = list(
		'sound/weapons/bulletflyby.ogg',
		'sound/weapons/bulletflyby2.ogg',
		'sound/weapons/bulletflyby3.ogg',
	)

/datum/sound_effect/revolver_spin
	file_paths = list(
		'sound/weapons/gun/revolver/spin1.ogg',
		'sound/weapons/gun/revolver/spin2.ogg',
		'sound/weapons/gun/revolver/spin3.ogg',
	)

/datum/sound_effect/law
	file_paths = list(
		'sound/mobs/non-humanoids/beepsky/creep.ogg',
		'sound/mobs/non-humanoids/beepsky/god.ogg',
		'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
		'sound/mobs/non-humanoids/beepsky/insult.ogg',
		'sound/mobs/non-humanoids/beepsky/radio.ogg',
		'sound/mobs/non-humanoids/beepsky/secureday.ogg',
	)

/datum/sound_effect/honkbot_e
	file_paths = list(
		'sound/items/bikehorn.ogg',
		'sound/items/AirHorn2.ogg',
		'sound/misc/sadtrombone.ogg',
		'sound/items/AirHorn.ogg',
		'sound/effects/reee.ogg',
		'sound/items/WEEOO1.ogg',
		'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
		'sound/mobs/non-humanoids/beepsky/creep.ogg',
		'sound/magic/Fireball.ogg',
		'sound/effects/pray.ogg',
		'sound/mobs/non-humanoids/hiss/hiss1.ogg',
		'sound/machines/buzz-sigh.ogg',
		'sound/machines/ping.ogg',
		'sound/weapons/flashbang.ogg',
		'sound/weapons/bladeslice.ogg',
	)

/datum/sound_effect/goose
	file_paths = list(
		'sound/mobs/non-humanoids/goose/goose1.ogg',
		'sound/mobs/non-humanoids/goose/goose2.ogg',
		'sound/mobs/non-humanoids/goose/goose3.ogg',
		'sound/mobs/non-humanoids/goose/goose4.ogg',
	)

/datum/sound_effect/sm_calm
	file_paths = list(
		'sound/machines/sm/accent/normal/1.ogg',
		'sound/machines/sm/accent/normal/2.ogg',
		'sound/machines/sm/accent/normal/3.ogg',
		'sound/machines/sm/accent/normal/4.ogg',
		'sound/machines/sm/accent/normal/5.ogg',
		'sound/machines/sm/accent/normal/6.ogg',
		'sound/machines/sm/accent/normal/7.ogg',
		'sound/machines/sm/accent/normal/8.ogg',
		'sound/machines/sm/accent/normal/9.ogg',
		'sound/machines/sm/accent/normal/10.ogg',
		'sound/machines/sm/accent/normal/11.ogg',
		'sound/machines/sm/accent/normal/12.ogg',
		'sound/machines/sm/accent/normal/13.ogg',
		'sound/machines/sm/accent/normal/14.ogg',
		'sound/machines/sm/accent/normal/15.ogg',
		'sound/machines/sm/accent/normal/16.ogg',
		'sound/machines/sm/accent/normal/17.ogg',
		'sound/machines/sm/accent/normal/18.ogg',
		'sound/machines/sm/accent/normal/19.ogg',
		'sound/machines/sm/accent/normal/20.ogg',
		'sound/machines/sm/accent/normal/21.ogg',
		'sound/machines/sm/accent/normal/22.ogg',
		'sound/machines/sm/accent/normal/23.ogg',
		'sound/machines/sm/accent/normal/24.ogg',
		'sound/machines/sm/accent/normal/25.ogg',
		'sound/machines/sm/accent/normal/26.ogg',
		'sound/machines/sm/accent/normal/27.ogg',
		'sound/machines/sm/accent/normal/28.ogg',
		'sound/machines/sm/accent/normal/29.ogg',
		'sound/machines/sm/accent/normal/30.ogg',
		'sound/machines/sm/accent/normal/31.ogg',
		'sound/machines/sm/accent/normal/32.ogg',
		'sound/machines/sm/accent/normal/33.ogg',
	)

/datum/sound_effect/sm_delam
	file_paths = list(
		'sound/machines/sm/accent/delam/1.ogg',
		'sound/machines/sm/accent/delam/2.ogg',
		'sound/machines/sm/accent/delam/3.ogg',
		'sound/machines/sm/accent/delam/4.ogg',
		'sound/machines/sm/accent/delam/5.ogg',
		'sound/machines/sm/accent/delam/6.ogg',
		'sound/machines/sm/accent/delam/7.ogg',
		'sound/machines/sm/accent/delam/8.ogg',
		'sound/machines/sm/accent/delam/9.ogg',
		'sound/machines/sm/accent/delam/10.ogg',
		'sound/machines/sm/accent/delam/11.ogg',
		'sound/machines/sm/accent/delam/12.ogg',
		'sound/machines/sm/accent/delam/13.ogg',
		'sound/machines/sm/accent/delam/14.ogg',
		'sound/machines/sm/accent/delam/15.ogg',
		'sound/machines/sm/accent/delam/16.ogg',
		'sound/machines/sm/accent/delam/17.ogg',
		'sound/machines/sm/accent/delam/18.ogg',
		'sound/machines/sm/accent/delam/19.ogg',
		'sound/machines/sm/accent/delam/20.ogg',
		'sound/machines/sm/accent/delam/21.ogg',
		'sound/machines/sm/accent/delam/22.ogg',
		'sound/machines/sm/accent/delam/23.ogg',
		'sound/machines/sm/accent/delam/24.ogg',
		'sound/machines/sm/accent/delam/25.ogg',
		'sound/machines/sm/accent/delam/26.ogg',
		'sound/machines/sm/accent/delam/27.ogg',
		'sound/machines/sm/accent/delam/28.ogg',
		'sound/machines/sm/accent/delam/29.ogg',
		'sound/machines/sm/accent/delam/30.ogg',
		'sound/machines/sm/accent/delam/31.ogg',
		'sound/machines/sm/accent/delam/32.ogg',
		'sound/machines/sm/accent/delam/33.ogg',
	)

/datum/sound_effect/keyboard_clicks
	file_paths = list(
		'sound/machines/computer/keyboard_clicks_1.ogg',
		'sound/machines/computer/keyboard_clicks_2.ogg',
		'sound/machines/computer/keyboard_clicks_3.ogg',
		'sound/machines/computer/keyboard_clicks_4.ogg',
		'sound/machines/computer/keyboard_clicks_5.ogg',
		'sound/machines/computer/keyboard_clicks_6.ogg',
		'sound/machines/computer/keyboard_clicks_7.ogg',
	)

/datum/sound_effect/button
	file_paths = list(
		'sound/machines/button/button1.ogg',
		'sound/machines/button/button2.ogg',
		'sound/machines/button/button3.ogg',
		'sound/machines/button/button4.ogg',
	)

/datum/sound_effect/lever_switch
	file_paths = list(
		'sound/machines/button/button1.ogg',
		'sound/machines/button/button2.ogg',
		'sound/machines/button/button3.ogg',
		'sound/machines/button/button4.ogg',
	)

/datum/sound_effect/portal_created
	file_paths = list(
		'sound/effects/portal/portal_open_1.ogg',
		'sound/effects/portal/portal_open_2.ogg',
		'sound/effects/portal/portal_open_3.ogg',
	)

/datum/sound_effect/stone_drop
	file_paths = list(
		'sound/items/stones/stone_drop1.ogg',
		'sound/items/stones/stone_drop2.ogg',
		'sound/items/stones/stone_drop3.ogg',
	)

/datum/sound_effect/stone_pickup
	file_paths = list(
		'sound/items/stones/stone_pick_up1.ogg',
		'sound/items/stones/stone_pick_up2.ogg',
	)

/datum/sound_effect/liquid_pour
	file_paths = list(
		'sound/effects/liquid_pour/liquid_pour1.ogg',
		'sound/effects/liquid_pour/liquid_pour2.ogg',
		'sound/effects/liquid_pour/liquid_pour3.ogg',
	)

/datum/sound_effect/default_liquid_slosh
	file_paths = list(
		'sound/items/handling/reagent_containers/default/default_liquid_slosh1.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh2.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh3.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh4.ogg',
		'sound/items/handling/reagent_containers/default/default_liquid_slosh5.ogg',
	)

/datum/sound_effect/plastic_bottle_liquid_slosh
	file_paths = list(
		'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh1.ogg',
		'sound/items/handling/reagent_containers/plastic_bottle/plastic_bottle_liquid_slosh2.ogg',
	)

/datum/sound_effect/writing_pen
	file_paths = list(
		'sound/effects/writing_pen/writing_pen1.ogg',
		'sound/effects/writing_pen/writing_pen2.ogg',
		'sound/effects/writing_pen/writing_pen3.ogg',
		'sound/effects/writing_pen/writing_pen4.ogg',
		'sound/effects/writing_pen/writing_pen5.ogg',
		'sound/effects/writing_pen/writing_pen6.ogg',
		'sound/effects/writing_pen/writing_pen7.ogg',
	)

/datum/sound_effect/seatbelt_buckle
	file_paths = list(
		'sound/machines/buckle/buckle1.ogg',
		'sound/machines/buckle/buckle2.ogg',
		'sound/machines/buckle/buckle3.ogg',
	)

/datum/sound_effect/seatbelt_unbuckle
	file_paths = list(
		'sound/machines/buckle/unbuckle1.ogg',
		'sound/machines/buckle/unbuckle2.ogg',
		'sound/machines/buckle/unbuckle3.ogg',
	)

/datum/sound_effect/headset_equip
	file_paths = list(
		'sound/items/equip/headset_equip1.ogg',
		'sound/items/equip/headset_equip2.ogg',
	)

/datum/sound_effect/headset_pickup
	file_paths = list(
		'sound/items/handling/headset/headset_pickup1.ogg',
		'sound/items/handling/headset/headset_pickup2.ogg',
		'sound/items/handling/headset/headset_pickup3.ogg',
	)

/datum/sound_effect/goggles_pickup
	file_paths = list(
		'sound/items/goggles/goggles_pickup1.ogg',
		'sound/items/goggles/goggles_pickup2.ogg',
		'sound/items/goggles/goggles_pickup3.ogg',
	)

/datum/sound_effect/goggles_drop
	file_paths = list(
		'sound/items/goggles/goggles_drop1.ogg',
		'sound/items/goggles/goggles_drop2.ogg',
		'sound/items/goggles/goggles_drop3.ogg',
	)

/datum/sound_effect/goggles_equip
	file_paths = list(
		'sound/items/goggles/goggles_equip1.ogg',
		'sound/items/goggles/goggles_equip2.ogg',
		'sound/items/goggles/goggles_equip3.ogg',
		'sound/items/goggles/goggles_equip4.ogg',
	)

/datum/sound_effect/glasses_pickup
	file_paths = list(
		'sound/items/glasses/glasses_pickup1.ogg',
		'sound/items/glasses/glasses_pickup2.ogg',
		'sound/items/glasses/glasses_pickup3.ogg',
	)

/datum/sound_effect/glasses_drop
	file_paths = list(
		'sound/items/glasses/glasses_drop1.ogg',
		'sound/items/glasses/glasses_drop2.ogg',
		'sound/items/glasses/glasses_drop3.ogg',
	)

/datum/sound_effect/glasses_equip
	file_paths = list(
		'sound/items/glasses/glasses_equip1.ogg',
		'sound/items/glasses/glasses_equip2.ogg',
	)

/datum/sound_effect/food_plate_pickup
	file_paths = list(
		'sound/items/food_plate/food_plate_pickup1.ogg',
		'sound/items/food_plate/food_plate_pickup2.ogg',
		'sound/items/food_plate/food_plate_pickup3.ogg',
	)

/datum/sound_effect/food_plate_drop
	file_paths = list(
		'sound/items/food_plate/food_plate_drop1.ogg',
		'sound/items/food_plate/food_plate_drop2.ogg',
		'sound/items/food_plate/food_plate_drop3.ogg',
	)

/datum/sound_effect/cutlery_pickup
	file_paths = list(
		'sound/items/cutlery/cutlery_pickup1.ogg',
		'sound/items/cutlery/cutlery_pickup2.ogg',
		'sound/items/cutlery/cutlery_pickup3.ogg',
	)

/datum/sound_effect/cutlery_drop
	file_paths = list(
		'sound/items/cutlery/cutlery_drop1.ogg',
		'sound/items/cutlery/cutlery_drop2.ogg',
		'sound/items/cutlery/cutlery_drop3.ogg',
	)

/datum/sound_effect/knife_pickup
	file_paths = list(
		'sound/items/knife/knife_pickup1.ogg',
		'sound/items/knife/knife_pickup2.ogg',
		'sound/items/knife/knife_pickup3.ogg',
	)

/datum/sound_effect/knife_drop
	file_paths = list(
		'sound/items/knife/knife_drop1.ogg',
		'sound/items/knife/knife_drop2.ogg',
		'sound/items/knife/knife_drop3.ogg',
	)

/datum/sound_effect/knife_slice
	file_paths = list(
		'sound/items/knife/knife_slice1.ogg',
		'sound/items/knife/knife_slice2.ogg',
		'sound/items/knife/knife_slice3.ogg',
		'sound/items/knife/knife_slice4.ogg',
		'sound/items/knife/knife_slice5.ogg',
		'sound/items/knife/knife_slice6.ogg',
	)

/datum/sound_effect/tray_pickup
	file_paths = list(
		'sound/items/tray/tray_pickup1.ogg',
		'sound/items/tray/tray_pickup2.ogg',
		'sound/items/tray/tray_pickup3.ogg',
	)

/datum/sound_effect/tray_drop
	file_paths = list(
		'sound/items/tray/tray_drop1.ogg',
		'sound/items/tray/tray_drop2.ogg',
		'sound/items/tray/tray_drop3.ogg',
	)

/datum/sound_effect/tray_insert
	file_paths = list(
		'sound/items/tray/tray_insert1.ogg',
		'sound/items/tray/tray_insert2.ogg',
		'sound/items/tray/tray_insert3.ogg',
	)

/datum/sound_effect/rolling_pin_pickup
	file_paths = list(
		'sound/items/rolling_pin/rolling_pin_pickup1.ogg',
		'sound/items/rolling_pin/rolling_pin_pickup2.ogg',
		'sound/items/rolling_pin/rolling_pin_pickup3.ogg',
	)

/datum/sound_effect/rolling_pin_drop
	file_paths = list(
		'sound/items/rolling_pin/rolling_pin_drop1.ogg',
		'sound/items/rolling_pin/rolling_pin_drop2.ogg',
		'sound/items/rolling_pin/rolling_pin_drop3.ogg',
	)

/datum/sound_effect/rolling_pin_rolling
	file_paths = list(
		'sound/items/rolling_pin/rolling_pin_rolling1.ogg',
		'sound/items/rolling_pin/rolling_pin_rolling2.ogg',
		'sound/items/rolling_pin/rolling_pin_rolling3.ogg',
		'sound/items/rolling_pin/rolling_pin_rolling4.ogg',
		'sound/items/rolling_pin/rolling_pin_rolling5.ogg',
		'sound/items/rolling_pin/rolling_pin_rolling6.ogg',
	)

/datum/sound_effect/griddle_on
	file_paths = list(
		'sound/machines/griddle/griddle_turn_on1.ogg',
		'sound/machines/griddle/griddle_turn_on2.ogg',
	)

/datum/sound_effect/griddle_off
	file_paths = list(
		'sound/machines/griddle/griddle_turn_off1.ogg',
		'sound/machines/griddle/griddle_turn_off2.ogg',
	)

/datum/sound_effect/seasoning_shaker_pickup
	file_paths = list(
		'sound/items/seasoning_shaker/seasoning_shaker_pickup1.ogg',
		'sound/items/seasoning_shaker/seasoning_shaker_pickup2.ogg',
		'sound/items/seasoning_shaker/seasoning_shaker_pickup3.ogg',
	)

/datum/sound_effect/seasoning_shaker_drop
	file_paths = list(
		'sound/items/seasoning_shaker/seasoning_shaker_drop1.ogg',
		'sound/items/seasoning_shaker/seasoning_shaker_drop2.ogg',
	)

/datum/sound_effect/towel_pickup
	file_paths = list(
		'sound/items/towel/towel_pickup1.ogg',
		'sound/items/towel/towel_pickup2.ogg',
	)

/datum/sound_effect/towel_drop
	file_paths = list(
		'sound/items/towel/towel_drop1.ogg',
		'sound/items/towel/towel_drop2.ogg',
	)

/datum/sound_effect/cucumba_pickup
	file_paths = list(
		'sound/items/cucumba/cucumba_pickup1.ogg',
		'sound/items/cucumba/cucumba_pickup2.ogg',
		'sound/items/cucumba/cucumba_pickup3.ogg',
	)

/datum/sound_effect/cucumba_drop
	file_paths = list(
		'sound/items/cucumba/cucumba_drop1.ogg',
		'sound/items/cucumba/cucumba_drop2.ogg',
		'sound/items/cucumba/cucumba_drop3.ogg',
	)
