//Gun crafting parts til they can be moved elsewhere

// PARTS //
/obj/item/weaponcrafting
	name = "weapon part"
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 6)
	icon_state = "riflestock"

// ATTACHMENTS //

/obj/item/weaponcrafting/attachment
	//The following are buffs given to the weapon this is attached to
	force = 0
	sharpness = 0
	bleed_force = 0
	//if this changes the fire sound of the weapon, put it here
	var/fire_sound = null
	//If we can attach this to a bow
	var/bow_suitable = TRUE
	//If we can attach this to a standard gun, currently a useless var but will be important later
	var/gun_suitable = TRUE
	var/spread = 0
	var/damage_multiplier = 0
	var/speed_multiplier = 0
	var/added_description = "<span class='info'>The item attached to this does absolutely nothing.</span>"

// PRIMARY //
// Primary attachments are meant to affect the mechanical aspect of a weapon, for now, since im working on bows, im using this to separate bow string from other attachments
// knowing this can be usefull for the future when its expanded into other weapons

/obj/item/weaponcrafting/attachment/primary/cablestring
	name = "cable coil string"
	desc = "A cable coil string to be used in weapon crafting."
	icon_state = "cablestring"
	damage_multiplier = 0.7
	speed_multiplier = 1.35
	gun_suitable = FALSE
	//Debuff to damage and speed
	added_description = "<span class='info'>The bowstring is improvised out of cable. It looks rather weak.</span>"

/obj/item/weaponcrafting/attachment/primary/bamboostring
	name = "bamboo fiber string"
	desc = "A string made out of bamboo fiber to be used in weapon crafting."
	icon_state = "bamboostring"
	damage_multiplier = 0.9
	speed_multiplier = 0.8
	gun_suitable = FALSE
	//A bit weak and a bit fast
	added_description = "<span class='info'>The bowstring is made of bamboo fiber. Close to standard strength.</span>"

/obj/item/weaponcrafting/attachment/primary/silkstring
	name = "silkstring"
	desc = "A string made out of silk to be used in weapon crafting."
	icon_state = "silkstring"
	damage_multiplier = 1
	speed_multiplier = 1
	gun_suitable = FALSE
	//Standard stuff, no debuffs
	added_description = "<span class='info'>The bowstring is made of silkstring. Standard strength.</span>"

/obj/item/weaponcrafting/attachment/primary/leatherstring
	name = "leather string"
	desc = "A string made out of leather to be used in weapon crafting."
	icon_state = "leatherstring"
	damage_multiplier = 1
	speed_multiplier = 1.2
	gun_suitable = FALSE
	//Slight debuff to speed
	added_description = "<span class='info'>The bowstring is made of leather. Standard strength.</span>"

/obj/item/weaponcrafting/attachment/primary/sinewstring
	name = "sinew string"
	desc = "A bow string made out of sinew to be used in weapon crafting."
	icon_state = "sinewstring"
	damage_multiplier = 1.2
	speed_multiplier = 1
	gun_suitable = FALSE
	//Buff to damage
	added_description = "<span class='info'>The bowstring is made of sinew. It looks pretty strong.</span>"

/obj/item/weaponcrafting/attachment/primary/energy_crystal //Not aviable ingame yet
	name = "energy crystal"
	desc = "An energy crystal made out of uranium used in the construction of energy weaponry. A warning lable reads 'Warning: Do Not Ingest'."
	custom_materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT * 1)
	material_flags = MATERIAL_EFFECTS
	icon_state = "crystal"
	damage_multiplier = 1.5
	speed_multiplier = 0.6
	fire_sound = 'sound/weapons/edagger.ogg'
	//Stronger, faster
	added_description = "<span class='info'>The bowstring is made of pure energy. As robust as it gets.</span>"

/obj/item/weaponcrafting/attachment/primary/energy_crystal/clockwork //Made specially for clockcult, unretreaveable for now
	name = "clockwork magic crystal"
	desc = "An energy crystal made out of magic!"
	custom_materials = null
	icon_state = "clock_crystal"
	damage_multiplier = 1
	speed_multiplier = 1
	added_description = "<span class='info'>The bowstring is made of pure energy. Able to create its own arrows.</span>"
	//Ideally this stupid thing would create the arrows on its own, but for now thats tied to the bow itself

// SECONDARY //
// Secondary attachments, think of attachments as having slots they fit in, these fit into the "second" slot

/obj/item/weaponcrafting/attachment/secondary/bowfangs
	name = "bow fangs"
	desc = "Fangs that can be attached to a bow to make it more suitable for hand to hand combat. It decreases accuracy, however."
	icon_state = "fangs"
	force = 5
	spread = 2
	sharpness = SHARP
	bleed_force = BLEED_CUT
	gun_suitable = FALSE
	added_description = "<span class='info'>Iron Fangs have been attached to it, making it dangerous in melee combat.</span>"

/obj/item/weaponcrafting/attachment/secondary/bowfangs/bone
	name = "bone bow fangs"
	desc = "Fangs made out of bone that can be attached to a bow to make it more suitable for hand to hand combat. It decreases accuracy, however."
	icon_state = "fangs_bone"
	force = 7
	spread = 3
	sharpness = BLUNT
	bleed_force = BLEED_SCRATCH
	gun_suitable = FALSE
	added_description = "<span class='info'>Bone fangs have been attached to it, making it dangerous in melee combat.</span>"

/obj/item/weaponcrafting/attachment/secondary/scope
	name = "scope"
	desc = "A scope that can be added to a weapon or bow to improve accuracy."
	icon_state = "scope" //These need a more talented spriter than me
	spread = -5 //Its a good thing when these and multipliers are negative, this represents how much spread it reduces
	added_description = "<span class='info'>A scope has been attached, improving accuracy.</span>"

/obj/item/weaponcrafting/attachment/secondary/scope/glassless
	name = "scope frame"
	desc = "A scope frame lacking a glass lens."
	icon_state = "scopeless"
	spread = 0 //This does fuckall
	added_description = "<span class='info'>Whoever attached this likes to have useless baubles on their weapons.</span>"

/obj/item/weaponcrafting/attachment/secondary/scope/glassless/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.use(1))
			new /obj/item/weaponcrafting/attachment/secondary/scope(get_turf(src),1)
			return TRUE
	. = ..()

/obj/item/weaponcrafting/attachment/secondary/accelerators
	name = "accelerators"
	desc = "Cogs meant to accelerate the velocity of a weapons projectiles."
	icon_state = "accelerators"
	speed_multiplier = -0.2 //this represents a decrease in slowdown since its negative
	added_description = "<span class='info'>Couple of accelerators have been added to this weapon, increasing its projectile speeds.</span>"
