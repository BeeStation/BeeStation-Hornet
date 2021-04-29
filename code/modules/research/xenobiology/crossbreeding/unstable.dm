/obj/item/slimecross/unstable
	name = "unstable extract"
	desc = "You can feel rumblin inside..."
	icon_state = "unstable"
	effect = "unstable"
	var/mob/living/carbon/human/human_thrower

/obj/item/slimecross/unstable/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	if(ishuman(thrower))
		human_thrower = thrower
	return ..()


/obj/item/slimecross/unstable/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(human_thrower)
		on_effect(hit_atom)
	qdel(src)

/obj/item/slimecross/unstable/proc/on_effect(atom/hit_atom)
	return

/obj/item/slimecross/unstable/grey
	colour = "grey"
	effect_desc = "When thrown creates a rabid slime that is loyal to you."

/obj/item/slimecross/unstable/grey/on_effect(atom/hit_atom)
	var/mob/living/simple_animal/slime/agrro/slimey =  new /mob/living/simple_animal/slime/agrro(get_turf(hit_atom))
	slimey.Friends[human_thrower] = SLIME_FRIENDSHIP_ATTACK
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/humie = hit_atom
		humie.buckle_mob(slimey)

/obj/item/slimecross/unstable/orange
	colour = "orange"
	effect_desc = "When thrown creates a spot of immense heat"

/obj/item/slimecross/unstable/orange/on_effect(atom/hit_atom)
	new /obj/effect/hotspot(hit_atom.drop_location(),200,10000)

/obj/item/slimecross/unstable/purple
	colour = "purple"
	effect_desc = "When thrown creates a smoke cloud of healing reagents."

/obj/item/slimecross/unstable/purple/on_effect(atom/hit_atom)
	var/datum/effect_system/smoke_spread/chem/S = new()
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(20)
	reagents.add_reagent(/datum/reagent/medicine/regen_jelly,20)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, 3, location, silent = TRUE)
	S.start()

/obj/item/slimecross/unstable/blue
	colour = "blue"
	effect_desc = "When thrown extinguishes mobs and cools them down."

/obj/item/slimecross/unstable/blue/on_effect(atom/hit_atom)
	for(var/i in 0 to 5)
		var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src))
		W.Move(get_step(W,pick(GLOB.alldirs)))

	for(var/mob/living/carbon/carbie in range(1,src))
		carbie.fire_stacks = -2
		carbie.ExtinguishMob()
		carbie.set_bodytemperature(BODYTEMP_NORMAL)

/obj/item/slimecross/unstable/metal
	colour = "metal"

/obj/item/slimecross/unstable/metal/on_effect(atom/hit_atom)
	if(!iscarbon(hit_atom))
		new /obj/structure/wage_cage(get_turf(hit_atom))
		return

	var/mob/living/carbon/carbie = hit_atom
	var/obj/item/restraints/handcuffs/metal_cage/wagie_cagie = new /obj/item/restraints/handcuffs/metal_cage(hit_atom)
	wagie_cagie.apply_cuffs(carbie,human_thrower)

/obj/item/slimecross/unstable/yellow
	colour = "yellow"
	effect_desc = "When thrown causes a tesla zap and a small emp."

/obj/item/slimecross/unstable/yellow/on_effect(atom/hit_atom)
	tesla_zap(get_turf(hit_atom),1,2000)
	empulse(get_turf(hit_atom), 0,2,TRUE)

/obj/item/slimecross/unstable/darkpurple
	colour = "dark purple"
	effect_desc = "When thrown spawns extremely hot plasma."

/obj/item/slimecross/unstable/darkpurple/on_effect(atom/hit_atom)
	atmos_spawn_air("plasma=[50];TEMP=[10000]")

	if(!iscarbon(hit_atom))
		return
	var/mob/living/carbon/carbie = hit_atom
	carbie.reagents.add_reagent(/datum/reagent/toxin/plasma,25,reagtemp = 1000)

/obj/item/slimecross/unstable/darkblue
	colour = "dark blue"
	effect_desc = "When thrown stuns and ices the first thing it hits."

/obj/item/slimecross/unstable/darkblue/on_effect(atom/hit_atom)
	if(!iscarbon(hit_atom))
		return
	var/mob/living/carbon/carbie = hit_atom
	carbie.Paralyze(10)
	carbie.adjust_bodytemperature(-300)
	carbie.apply_status_effect(/datum/status_effect/freon)

/obj/item/slimecross/unstable/silver
	colour = "silver"
	effect_desc = "When thrown feeds whatever was hit with a lot of nutrition."

/obj/item/slimecross/unstable/silver/on_effect(atom/hit_atom)
	if(isliving(hit_atom))
		var/mob/living/livies = hit_atom
		livies.adjust_nutrition(100)

/obj/item/slimecross/unstable/bluespace
	colour = "bluespace"
	effect_desc = "When thrown teleports everything on hit turf to the thrower."

/obj/item/slimecross/unstable/bluespace/on_effect(atom/hit_atom)
	var/turf/turfie = get_turf(hit_atom)
	var/turf/thrower_turf = get_turf(human_thrower)
	var/list/ref_list = turfie.contents
	for(var/something in ref_list)
		if(!isatom(something))
			continue
		do_teleport(something,thrower_turf)

/obj/item/slimecross/unstable/sepia
	colour = "sepia"
	effect_desc = "When thrown creates a temporary 1 tile size timestop field."

/obj/item/slimecross/unstable/sepia/on_effect(atom/hit_atom)
	. = ..()
	new /obj/effect/timestop(get_turf(hit_atom), 0, 5 SECONDS,null)

/obj/item/slimecross/unstable/cerulean
	colour = "cerulean"
	effect_desc = "When thrown creates a weaker copy of the first human it hits or when it misses it creates a copy of it's thrower."

/obj/item/slimecross/unstable/cerulean/on_effect(atom/hit_atom)
	var/mob/living/carbon/human/H

	if(ishuman(hit_atom))
		H = hit_atom
	else
		H = human_thrower

	H.notransform = TRUE

	CHECK_DNA_AND_SPECIES(H)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(get_turf(hit_atom))

	spare.underwear = "Nude"
	H.dna.transfer_identity(spare, transfer_SE=1)
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance()
	spare.domutcheck()
	spare.Move(get_step(get_turf(hit_atom), pick(NORTH,SOUTH,EAST,WEST)))

	var/datum/component/nanites/owner_nanites = H.GetComponent(/datum/component/nanites)
	if(owner_nanites)
		//copying over nanite programs/cloud sync with 50% saturation in host and spare
		owner_nanites.nanite_volume *= 0.5
		spare.AddComponent(/datum/component/nanites, owner_nanites.nanite_volume)
		SEND_SIGNAL(spare, COMSIG_NANITE_SYNC, owner_nanites, TRUE, TRUE) //The trues are to copy activation as well

	spare.setMaxHealth(H.maxHealth/5)

	H.notransform = FALSE

/obj/item/slimecross/unstable/pyrite
	colour = "pyrite"
	effect_desc = "When thrown randomly colors nearby tiles"
	var/static/list/color_list = list("#FFA500","#B19CD9", "#ADD8E6","#7E7E7E","#FFFF00","#551A8B","#0000FF","#D3D3D3", "#32CD32","#704214","#2956B2","#FAFAD2", "#FF0000",
					"#00FF00", "#FF69B4","#FFD700", "#505050", "#FFB6C1","#008B8B")

/obj/item/slimecross/unstable/pyrite/on_effect(atom/hit_atom)
	for(var/atom/some_atom in range(get_turf(hit_atom),1))
		some_atom.add_atom_colour(pick(color_list), FIXED_COLOUR_PRIORITY)

/obj/item/slimecross/unstable/red
	colour = "red"
	effect_desc = "When thrown causes extreme bleeding to the first person hit."

/obj/item/slimecross/unstable/red/on_effect(atom/hit_atom)
	if(!ishuman(hit_atom))
		new /obj/effect/decal/cleanable/blood(get_turf(hit_atom))
		return
	var/mob/living/carbon/human/H = hit_atom
	H.bleed_rate += 15


/obj/item/slimecross/unstable/green
	colour = "green"
	effect_desc = "When thrown causes 25 brute damage, you heal for the amount of damage it deals after armor mitigation."

/obj/item/slimecross/unstable/green/on_effect(atom/hit_atom)
	if(!isliving(hit_atom))
		return
	var/mob/living/L = hit_atom
	var/health_amt_now = L.getBruteLoss()
	L.apply_damage(25,BRUTE)
	var/health_to_heal = health_amt_now - L.getBruteLoss()
	human_thrower.adjustBruteLoss(health_to_heal)

/obj/item/slimecross/unstable/pink
	colour = "pink"
	effect_desc = "When thrown it hugs the first thing it hits."

/obj/item/slimecross/unstable/pink/on_effect(atom/hit_atom)
	if(!iscarbon(hit_atom))
		return
	var/mob/living/carbon/carbie = hit_atom
	human_thrower.help_shake_act(carbie)

/obj/item/slimecross/unstable/gold
	colour = "gold"
	effect_desc = "When thrown spawns goliath tentacles."

/obj/item/slimecross/unstable/gold/on_effect(atom/hit_atom)
	if(isliving(hit_atom))
		var/mob/living/livies = hit_atom
		livies.Stun(40)
	new /obj/effect/temp_visual/goliath_tentacle/original(get_turf(hit_atom),human_thrower)

/obj/item/slimecross/unstable/oil
	colour = "oil"
	effect_desc = "When thrown it explodes."

/obj/item/slimecross/unstable/oil/on_effect(atom/hit_atom)
	dyn_explosion(get_turf(hit_atom),0.5)

/obj/item/slimecross/unstable/black
	colour = "black"
	effect_desc = "When thrown it stains all visor in a 3x3 radius of the impact, additionally it also produces a small smoke cloud, both effects dont interact with eachother."

/obj/item/slimecross/unstable/black/on_effect(atom/hit_atom)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, get_turf(hit_atom))
	smoke.start()
	for(var/mob/living/carbon/human/humie in range(get_turf(hit_atom),2))
		var/obj/item/clothing/glasses/big_g = humie.glasses
		if(!big_g)
			return
		big_g.AddElement(/datum/element/dirty_glasses)

/obj/item/slimecross/unstable/adamantine
	colour = "adamantine"
	effect_desc = "When thrown craetes deadly adamantine shards on the floor that rip apart shoes."

/obj/item/slimecross/unstable/adamantine/on_effect(atom/hit_atom)
	new /obj/item/slimecross/unstable/adamantine(get_turf(hit_atom))
	for(var/i in 1 to 4)
		new /obj/item/shard/adamantine(get_step(hit_atom,pick(GLOB.alldirs)))

/obj/item/slimecross/unstable/rainbow
	colour = "rainbow"
	effect_desc = "When thrown the first human it hits will begin flaring in millions of colors and slowly melting."

/obj/item/slimecross/unstable/rainbow/on_effect(atom/hit_atom)
	if(!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/H = hit_atom
	H.apply_status_effect(/datum/status_effect/rainbow_death)
