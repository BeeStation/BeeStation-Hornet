/obj/vehicle/sealed/mecha/combat/honker
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. Used to spread the fun and joy of life. HONK!"
	name = "\improper H.O.N.K"
	icon_state = "honker"
	base_icon_state = "honker"
	movedelay = 3
	max_integrity = 140
	deflect_chance = 60
	internal_damage_threshold = 60
	armor_type = /datum/armor/combat_honker
	max_temperature = 25000
	operation_req_access = list(ACCESS_THEATRE)
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	wreckage = /obj/structure/mecha_wreckage/honker
	mecha_flags = CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS
	max_equip = 3
	var/squeak = 0


/datum/armor/combat_honker
	melee = -20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/combat/honker/get_stats_part(mob/user)
	var/integrity = atom_integrity/max_integrity*100
	var/cell_charge = get_charge()
	var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
	var/tank_pressure = internal_tank ? round(int_tank_air.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? int_tank_air.return_temperature() : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)
	return {"[report_internal_damage()]
						[integrity<30?"<font color='red'><b>DAMAGE LEVEL CRITICAL</b></font><br>":null]
						[internal_damage&MECHA_INT_TEMP_CONTROL?"<font color='red'><b>CLOWN SUPPORT SYSTEM MALFUNCTION</b></font><br>":null]
						[internal_damage&MECHA_INT_TANK_BREACH?"<font color='red'><b>GAS TANK HONK</b></font><br>":null]
						[internal_damage&MECHA_INT_CONTROL_LOST?"<font color='red'><b>HONK-A-DOODLE</b></font> - <a href='byond://?src=[REF(src)];repair_int_control_lost=1'>Recalibrate</a><br>":null]
						<b>IntegriHONK: </b> [integrity]%<br>
						<b>PowerHONK charge: </b>[isnull(cell_charge)?"No power cell installed":"[cell.percent()]%"]<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>AirHONK pressure: </b>[tank_pressure]kPa<br>
						<b>AirHONK temperature: </b>[tank_temperature]&deg;K|[tank_temperature - T0C]&deg;C<br>
						<b>HONK pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? "<font color='red'>[cabin_pressure]</font>": cabin_pressure]kPa<br>
						<b>HONK temperature: </b> [return_temperature()]&deg;K|[return_temperature() - T0C]&deg;C<br>
						<b>Lights: </b>[(mecha_flags & LIGHTS_ON)?"on":"off"]<br>
					"}

/obj/vehicle/sealed/mecha/combat/honker/get_stats_html(mob/user)
	return {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<title>[src.name] data</title>
						<style>
						body {color: #00ff00; background: #32CD32; font-family:"Courier",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #fff; background-color: #000;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function SSticker() {
							setInterval(function(){
								window.location='byond://?src=[REF(src)]&update_content=1';
								document.body.style.color = get_rand_color_string();
								document.body.style.background = get_rand_color_string();
							}, 1000);
						}

						function get_rand_color_string() {
							var color = new Array;
							for(var i=0;i<3;i++){
								color.push(Math.floor(Math.random()*255));
							}
							return "rgb("+color.toString()+")";
						}

						window.onload = function() {
							dropdowns();
							SSticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[src.get_stats_part(user)]
						</div>
						<div id='eq_list'>
						[src.get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[src.get_commands()]
						</div>
						<div id='equipment_menu'>
						[get_equipment_menu()]
						</div>
						</body>
						</html>
					"}

/obj/vehicle/sealed/mecha/combat/honker/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Sounds of HONK:</div>
						<div class='links'>
						<a href='byond://?src=[REF(src)];play_sound=sadtrombone'>Sad Trombone</a>
						<a href='byond://?src=[REF(src)];play_sound=bikehorn'>Bike Horn</a>
						<a href='byond://?src=[REF(src)];play_sound=airhorn2'>Air Horn</a>
						<a href='byond://?src=[REF(src)];play_sound=carhorn'>Car Horn</a>
						<a href='byond://?src=[REF(src)];play_sound=party_horn'>Party Horn</a>
						<a href='byond://?src=[REF(src)];play_sound=reee'>Reee</a>
						<a href='byond://?src=[REF(src)];play_sound=weeoo1'>Siren</a>
						<a href='byond://?src=[REF(src)];play_sound=hiss1'>Hissing Creature</a>
						<a href='byond://?src=[REF(src)];play_sound=armbomb'>Armed Grenade</a>
						<a href='byond://?src=[REF(src)];play_sound=saberon'>Energy Sword</a>
						<a href='byond://?src=[REF(src)];play_sound=airlock_alien_prying'>Airlock Prying</a>
						<a href='byond://?src=[REF(src)];play_sound=lightningbolt'>Lightning Bolt</a>
						<a href='byond://?src=[REF(src)];play_sound=explosionfar'>Distant Explosion</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/vehicle/sealed/mecha/combat/honker/get_equipment_menu() //outputs mecha html equipment menu
	. = {"
	<div class='wr'>
	<div class='header'>EquipHONK</div>
	<div class='links'>"}
	if(equipment.len)
		for(var/X in equipment)
			var/obj/item/mecha_parts/mecha_equipment/W = X
			. += "[W.name] [W.detachable?"<a href='byond://?src=[REF(W)];detach=1'>Detach</a><br>":"\[Non-removable\]<br>"]"
	. += {"<b>Available equipment slots:</b> [max_equip-equipment.len]
	</div>
	</div>"}

/obj/vehicle/sealed/mecha/combat/honker/get_equipment_list()
	if(!LAZYLEN(equipment))
		return
	var/output = "<b>Honk-ON-Systems:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		output += "<div id='[REF(MT)]'>[MT.get_equip_info()]</div>"
	output += "</div>"
	return output

/obj/vehicle/sealed/mecha/combat/honker/play_stepsound()
	if(squeak)
		playsound(src, "clownstep", 70, 1)
	squeak = !squeak

/obj/vehicle/sealed/mecha/combat/honker/Topic(href, href_list)
	..()
	if (href_list["play_sound"])
		switch(href_list["play_sound"])
			if("sadtrombone")
				playsound(src, 'sound/misc/sadtrombone.ogg', 50)
			if("bikehorn")
				playsound(src, 'sound/items/bikehorn.ogg', 50)
			if("airhorn2")
				playsound(src, 'sound/items/airhorn2.ogg', 40) //soundfile has higher than average volume
			if("carhorn")
				playsound(src, 'sound/items/carhorn.ogg', 80) //soundfile has lower than average volume
			if("party_horn")
				playsound(src, 'sound/items/party_horn.ogg', 50)
			if("reee")
				playsound(src, 'sound/effects/reee.ogg', 50)
			if("weeoo1")
				playsound(src, 'sound/items/weeoo1.ogg', 50)
			if("hiss1")
				playsound(src, 'sound/voice/hiss1.ogg', 50)
			if("armbomb")
				playsound(src, 'sound/weapons/armbomb.ogg', 50)
			if("saberon")
				playsound(src, 'sound/weapons/saberon.ogg', 50)
			if("airlock_alien_prying")
				playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50)
			if("lightningbolt")
				playsound(src, 'sound/magic/lightningbolt.ogg', 50)
			if("explosionfar")
				playsound(src, 'sound/effects/explosionfar.ogg', 50)
	return

//DARK H.O.N.K.

/obj/vehicle/sealed/mecha/combat/honker/dark
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. This one has been painted black for maximum fun. HONK!"
	name = "\improper Dark H.O.N.K"
	icon_state = "darkhonker"
	max_integrity = 300
	deflect_chance = 15
	armor_type = /datum/armor/honker_dark
	max_temperature = 35000
	operation_req_access = list(ACCESS_SYNDICATE)
	internals_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/honker/dark
	max_equip = 4


/datum/armor/honker_dark
	melee = 40
	bullet = 40
	laser = 50
	energy = 35
	bomb = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/combat/honker/dark/add_cell(obj/item/stock_parts/cell/C)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/hyper(src)

/obj/vehicle/sealed/mecha/combat/honker/dark/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/thrusters/ion(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker()
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana()//Needed more offensive weapons.
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/tearstache()//The mousetrap mortar was not up-to-snuff.
	ME.attach(src)

/obj/structure/mecha_wreckage/honker/dark
	name = "\improper Dark H.O.N.K wreckage"
	icon_state = "darkhonker-broken"
