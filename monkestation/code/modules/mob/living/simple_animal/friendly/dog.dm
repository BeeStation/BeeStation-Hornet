/mob/living/simple_animal/pet/dog/australianshepherd
	name = "\improper australian shepherd"
	real_name = "australian shepherd"
	desc = "It's an australian shepherd."
	icon = 'monkestation/icons/mob/pets.dmi'
	icon_state = "australianshepherd"
	icon_living = "australianshepherd"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/corgi = 1) //theres no generic dog meat type
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'monkestation/icons/mob/pets_held.dmi'
	held_state = "australianshepherd"

/mob/living/simple_animal/pet/dog/australianshepherd/captain
	name = "Captain"
	real_name = "Captain"
	gender = MALE
	desc = "Captain Butthole Nugget on deck!"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	speak = list("barks!", "woofs!", "borks!", "yips!", "burks!")
