/datum/action/vampire/shapeshift/batform
	name = "Bat Transformation"
	desc = "Take on the shape of a space bat.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions on use."
	power_explanation = "You take on the form of a bat and lose nearly all Vampire benefits, including your brutish strength.\n\
		When you transform back into your standard vampiric form, you will gain an equal amount of damage to that which you sustained when a bat.\n\
		You will drop all of your posessions when using this power."
	button_icon_state = "power_batform"
	bloodcost = 200
	constant_bloodcost = 1.5
	sol_multiplier = 2
	cooldown_time = 10 SECONDS
	obvious = TRUE
	shapeshifted_mob = /mob/living/simple_animal/hostile/retaliate/bat/vampire

/datum/action/vampire/shapeshift/batform/activate_power()
	for(var/obj/item/item in owner)
		owner.dropItemToGround(item, TRUE)
	. = ..()
