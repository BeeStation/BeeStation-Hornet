#define UNFINISHED "unfinished"
#define	SHARPENED_TIP "sharpened"
#define CLOTH_TIP "cloth"
#define CLOTH_TIP_BURNING "cloth_lit"
#define SHARD_TIP "glass"
#define BOTTLE_TIP "bottle"
#define BONE_TIP "bone"
#define BAMBOO_TIP "bamboo"
#define IRON_TIP "iron"
#define PLASTITANIUM_TIP "plastitanium"
COOLDOWN_DECLARE(Burning_arrow)

/obj/item/ammo_casing/caseless/arrow
	name = "arrow of questionable material"
	desc = "You shouldn't be seeing this arrow"
	projectile_type = /obj/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	w_class = WEIGHT_CLASS_NORMAL
	force = 4
	throwforce = 2
	throw_speed = 2
	///What the arrow is tipped with currently
	var/arrow_state = UNFINISHED
	//This is updated when attaching a head
	bleed_force = 0

/obj/item/ammo_casing/caseless/arrow/Initialize(mapload)
	. = ..()
	var/obj/projectile/bullet/reusable/arrow/projectile_arrow = BB
	projectile_arrow.arrow_state = UNFINISHED

/obj/item/ammo_casing/caseless/arrow/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/gun/ballistic/bow))
		var/obj/item/gun/ballistic/bow/Bow = I

		if(Bow.bowstring == null)
			to_chat(user, "<span class='notice'>That bow has no bowstring!</span>")
			return TRUE
		else
			Bow.magazine.attackby(src, user, params, 1)
			to_chat(user, "<span class='notice'>You notch the arrow swiftly.</span>")
			I.update_icon()
			return TRUE
	if(arrow_state == UNFINISHED)
		if(user.do_afters)
			return TRUE
		else
			arrow_craft(I, user, params)
			return TRUE
	if(arrow_state == CLOTH_TIP && I.is_hot() > 900)
		update_arrow_state(CLOTH_TIP_BURNING)

/obj/item/ammo_casing/caseless/arrow/fire_act(exposed_temperature, exposed_volume)
	if(arrow_state == CLOTH_TIP)
		update_arrow_state(CLOTH_TIP_BURNING)
	else
		..()

///Called when originally crafting the arrow
/obj/item/ammo_casing/caseless/arrow/proc/arrow_craft(obj/item/I, mob/user, params)
	//Wrap the object in cloth, making a flammable arrow!
	if(istype(I, /obj/item/stack/sheet/cotton/cloth))
		if(do_after(user, 1 SECONDS, I)) //Short do_after.
			var/obj/item/stack/sheet/cloth = I
			cloth.use(1)
			user.show_message("<span class='notice'>You wrap \the [cloth.name] onto the [src].</span>", MSG_VISUAL)
			update_arrow_state(CLOTH_TIP)
			return TRUE

	//Give the arrow a glass arrowhead. Not the best, but better than nothing!
	else if(istype(I, /obj/item/shard))
		if(do_after(user, 1 SECONDS, I))
			user.show_message("<span class='notice'>You fasten \the [I.name] to the end of the shaft.</span>", MSG_VISUAL)
			update_arrow_state(SHARD_TIP, I)
			return TRUE

	//Give the arrow a bottle to splash reagents on the target hit by the arrow
	else if(istype(I, /obj/item/reagent_containers/cup/glass))
		if(do_after(user, 1 SECONDS, I))
			user.show_message("<span class='notice'>You attach \the [I.name] to the shaft.</span>", MSG_VISUAL)
			update_arrow_state(BOTTLE_TIP, I)
			return TRUE

	//Give the arrow a hollowpoint bone arrowhead. Great for injecting reagents!
	else if(istype(I, /obj/item/stack/sheet/bone))
		if(do_after(user, 1 SECONDS, I))
			var/obj/item/stack/sheet/bone = I
			bone.use(1)
			user.show_message("<span class='notice'>You create a bone hollowpoint arrow.</span>", MSG_VISUAL)
			update_arrow_state(BONE_TIP)
			return TRUE

	//Give the arrow a hollowpoint bamboo arrowhead. Great for injecting reagents, but not quite as powerful!
	else if(istype(I, /obj/item/stack/sheet/bamboo))
		if(do_after(user, 1 SECONDS, I))
			var/obj/item/stack/sheet/bamboo = I
			bamboo.use(1)
			user.show_message("<span class='notice'>You create a bamboo hollowpoint arrow.</span>", MSG_VISUAL)
			update_arrow_state(BAMBOO_TIP)
			return TRUE

	else if(istype(I, /obj/item/stack/sheet/iron))
		if(do_after(user, 2 SECONDS, I))
			var/obj/item/stack/sheet/iron = I
			iron.use(1)
			user.show_message("<span class='notice'>You create an iron tipped arrow.</span>", MSG_VISUAL)
			update_arrow_state(IRON_TIP)
			return TRUE

	else if(istype(I, /obj/item/stack/sheet/mineral/plastitanium))
		if(do_after(user, 2 SECONDS, I))
			var/obj/item/stack/sheet/plastitanium = I
			plastitanium.use(1)
			user.show_message("<span class='notice'>You create a plastitanium tipped arrow.</span>", MSG_VISUAL)
			update_arrow_state(PLASTITANIUM_TIP)
			return TRUE

	//MUST be after glass shards, or the shard will sharpen an arrow
	//Not attaching anything, but we can sharpen the end of whatever we are using to give it a decent embed chance!
	else if(I.is_sharp())
		if(do_after(user, 2 SECONDS, I))
			user.show_message("<span class='notice'>You sharpen \the [name].</span>", MSG_VISUAL)
			playsound(src, 'sound/effects/footstep/hardclaw1.ogg', 50, 1)
			update_arrow_state(SHARPENED_TIP)
			return TRUE

///Updates overlay and appearance, description and stored projectile to match the new state
/obj/item/ammo_casing/caseless/arrow/proc/update_arrow_state(new_state, attachment)

	//First update the stored projectile to reflect the new state
	var/obj/projectile/bullet/reusable/arrow/projectile_arrow = BB
	projectile_arrow.arrow_state = new_state
	arrow_state = new_state

	//skip generic damage/sound update if false
	var/normal_arrow = TRUE

	//And for everything else we need to know exactly what the state is, returning early for special states

	switch(new_state)

//BURNING ARROW (this one returns early, all the variables have already been set by cloth)
		if(CLOTH_TIP_BURNING)
			cut_overlay()
			add_overlay("cloth_lit")
			name = "flaming " + initial(name)
			desc += " that has been set ablaze"
			heat = 1500
			projectile_arrow.burning = TRUE
			light_system = MOVABLE_LIGHT
			projectile_arrow.light_system = MOVABLE_LIGHT
			light_range = 2
			projectile_arrow.light_range = 2
			light_power = 0.6
			projectile_arrow.light_power = 0.6
			light_on = TRUE
			projectile_arrow.light_on = TRUE
			light_color = LIGHT_COLOR_FIRE
			projectile_arrow.light_color = LIGHT_COLOR_FIRE
			return

//SPECIAL ARROWS
		if(UNFINISHED)
			cut_overlay()
			desc = initial(desc)
			name = initial(name)
			projectile_arrow.damage = initial(projectile_arrow.damage)
			projectile_arrow.armour_penetration = initial(projectile_arrow.armour_penetration)
			embedding = null
			normal_arrow = FALSE

		if(CLOTH_TIP)
			add_overlay("cloth")
			name = "padded " + name
			desc += "\nThe end has been wrapped in soft, but flammable cloth"
			projectile_arrow.damage = 1 //it's not totally harmless, but pretty close
			normal_arrow = FALSE

		if(BOTTLE_TIP)
			var/obj/item/reagent_containers/bottle = attachment
			create_reagents(bottle.volume, OPENCONTAINER)
			bottle.reagents.trans_to(src, bottle.volume)
			qdel(bottle)
			add_overlay("bottle")
			name = "bottle " + name
			desc += "\nIt is being used to plug a[reagents?" bottle of something": "n empty bottle"]"
			//Glass breaking sound when bottle breaks, standard blunt arrow hitting sound
			normal_arrow = FALSE

//STANDARD ARROWS
		if(SHARPENED_TIP)
			//No overlay for this one, sprite too small
			name = "sharpened " + name
			desc += "\nThe tip has been sharpened to a dangerous point"
			embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 8, //likely to fall right out due to being easily removed
				"pain_mult" = 0, //damage is dealt by the projectile on impact, not during the embed
				"remove_pain_mult" = 0, //this arrow has no head and will smoothly pull straight out
				"rip_time" = 1 SECONDS,
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 3,
				"jostle_pain_mult" = 1,
				"armour_block" = 40,
				) //arrow has no head, and is missing some of the heft needed to get through proper armor

		if(SHARD_TIP)
			add_overlay("glass")
			name = "glass-tipped " + name
			desc += "\nThere is a nasty glass shard fastened to the end"
			// no embedding for the arrow itself, a shard is broken off during the tryEmbed() proc below for this type of arrow

		if(BAMBOO_TIP)
			create_reagents(7, OPENCONTAINER)
			add_overlay("bamboo")
			name = "bamboo-tipped " + name
			desc += "\nThe bamboo tip can inject up to [reagents.maximum_volume] units"
			embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 6,
				"pain_mult" = 0, //damage is dealt by the projectile on impact, not during the embed
				"remove_pain_mult" = 1,
				"rip_time" = 2 SECONDS,
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 3,
				"jostle_pain_mult" = 1,
				"armour_block" = 40) //Bamboo still doesn't have much heft to it. Bad against properly armored opponents

		if(BONE_TIP)
			create_reagents(5, OPENCONTAINER)
			add_overlay("bone")
			name = "bone-tipped " + name
			desc += "\nThe bone tip can inject up to [reagents.maximum_volume] units"
			embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 6,
				"pain_mult" = 0, //damage is dealt by the projectile on impact, not during the embed
				"remove_pain_mult" = 1,
				"rip_time" = 2 SECONDS,
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 3,
				"jostle_pain_mult" = 1,
				"armour_block" = 80) //Bone is very dense and also good at piercing thick hides of lavaland creatures.

		if(IRON_TIP)
			add_overlay("iron")
			name = "iron-tipped " + name
			desc += "\nThe iron tip is dangerously sharp"
			projectile_arrow.damage += 1 //+2 total
			embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 3,
				"pain_mult" = 0, //damage is dealt by the projectile on impact, not during the embed
				"remove_pain_mult" = 1,
				"rip_time" = 2 SECONDS,
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 4,
				"jostle_pain_mult" = 1,
				"armour_block" = 60) //Good heft, able to get through most standard armor

		if(PLASTITANIUM_TIP)
			add_overlay("plastitanium")
			name = "broadhead " + name
			desc += "\nThe tip of this arrow looks like it would cause especially nasty wounds"
			projectile_arrow.damage += 1 //+2 total
			embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 0, //This nasty arrowhead will not let the arrow fall out on its own and is much worse to rip out as well.
				"pain_mult" = 0,
				"remove_pain_mult" = 3,
				"rip_time" = 3 SECONDS, //Standard embed time removal, where other arrows are faster
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 4,
				"jostle_pain_mult" = 2,
				"armour_block" = 80) //Plastitanium excells at piercing even the best armor
	if(normal_arrow)
		//Most states share the same sound/base damage
		hitsound = 'sound/weapons/pierce.ogg'
		projectile_arrow.damage *= 2
		projectile_arrow.armour_penetration *= 10
		bleed_force = BLEED_DEEP_WOUND

	//Reagents need to be reflected by the stored projectile as well
	if(reagents)
		projectile_arrow.create_reagents(reagents.maximum_volume, OPENCONTAINER)
	//And finally we need to activate those embedding stats we may have added... Or remove them if they were lost.
	updateEmbedding()

///Called after an arrow has hit something solid to see if the arrow should break
/obj/item/ammo_casing/caseless/arrow/proc/check_break(type)
	switch(type)
		if(BOTTLE_TIP)
			new /obj/item/shard(loc)
			playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			return UNFINISHED
		if(CLOTH_TIP_BURNING)
			playsound(loc, 'sound/weapons/fwoosh.ogg', 60, 0)
			return UNFINISHED
	return type

/obj/item/ammo_casing/caseless/arrow/tryEmbed(atom/target, forced=FALSE, silent=FALSE)
	if(arrow_state == SHARD_TIP)
		update_arrow_state(UNFINISHED)
		var/obj/item/shard/broken_tip = new(loc)
		broken_tip.embedding = list(
				"embed_chance" = 100,
				"fall_chance" = 0,
				"pain_mult" = 0,
				"remove_pain_mult" = 5,
				"rip_time" = 3 SECONDS,
				"ignore_throwspeed_threshold" = TRUE,
				"jostle_chance" = 8,
				"jostle_pain_mult" = 2,
				"armour_block" = 60)
		broken_tip.updateEmbedding()
		broken_tip.tryEmbed(target, forced, silent)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 40, TRUE)
	. = ..()

///ARROW SHAFTS///

/obj/item/ammo_casing/caseless/arrow/wood
	name = "wooden arrow"
	desc = "A standard arrow made out of wood."
	icon_state = "arrow_wood"
	projectile_type = /obj/projectile/bullet/reusable/arrow/wood

/obj/item/ammo_casing/caseless/arrow/bamboo
	name = "bamboo arrow"
	desc = "An arrow made out of bamboo, just a bit lighter than normal wood"
	icon_state = "arrow_bamboo"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bamboo

/obj/item/ammo_casing/caseless/arrow/bone
	name = "bone arrow"
	desc = "An arrow carved out of bone, denser than wooden arrows."
	icon_state = "arrow_bone"
	projectile_type = /obj/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/caseless/arrow/plastitanium
	name = "plastitanium arrow"
	desc = "An arrow formed from a very sturdy but lightweight alloy"
	icon_state = "arrow_plastitanium"
	projectile_type = /obj/projectile/bullet/reusable/arrow/plastitanium

/obj/item/ammo_casing/caseless/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow made from wood. tipped with bronze."
	icon_state = "bronzearrow"
	bleed_force = BLEED_DEEP_WOUND
	projectile_type = /obj/projectile/bullet/reusable/arrow/bronze

#undef UNFINISHED
#undef SHARPENED_TIP
#undef CLOTH_TIP
#undef CLOTH_TIP_BURNING
#undef SHARD_TIP
#undef BOTTLE_TIP
#undef BONE_TIP
#undef BAMBOO_TIP
#undef IRON_TIP
#undef PLASTITANIUM_TIP
