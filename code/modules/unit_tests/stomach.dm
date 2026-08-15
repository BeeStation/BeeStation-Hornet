/datum/unit_test/stomach/Run()

	// Pause natural mob life so it can be handled entirely by the test
	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/food/hotdog/debug/fooditem = allocate(/obj/item/food/hotdog/debug)
	var/obj/item/organ/stomach/belly = human.get_organ_slot(ORGAN_SLOT_STOMACH)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/reagent/drug/methamphetamine/meth = /datum/reagent/drug/methamphetamine

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")

	fooditem.attack(human, human)

	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "Stomach doesn't have ketchup after eating")
	TEST_ASSERT_EQUAL(human.reagents.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human body has ketchup after eating it should only be in the stomach")

	//Give them meth and let it kick in
	pill.reagents.add_reagent(meth, 1.9 * initial(meth.metabolization_rate) * SSMOBS_DT)
	pill.attack(human, human)
	human.Life(SSMOBS_DT)

	TEST_ASSERT(human.reagents.has_reagent(meth), "Human body does not have meth after life tick")
	TEST_ASSERT(human.has_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine), "Human consumed meth, but did not gain movespeed modifier")

	belly.Remove(human)
	human.reagents.remove_all(human.reagents.total_volume)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has reagents after clearing")

	fooditem.attack(human, human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has ketchup without a stomach")



/datum/unit_test/stomach/Destroy()
	SSmobs.ignite()
	return ..()


/// Hunger scales natural stamina regeneration
/datum/unit_test/hunger_stamina/Run()

	SSmobs.pause()

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.satiety = 0

	human.set_nutrition(NUTRITION_LEVEL_FED)
	var/fed_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(fed_coeff - 1) < 0.001, "Stamina coefficient should be 1 at NUTRITION_LEVEL_FED, got [fed_coeff]")

	human.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	var/well_fed_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(well_fed_coeff - 1) < 0.001, "Stamina coefficient should clamp to 1 above NUTRITION_LEVEL_FED, got [well_fed_coeff]")

	human.set_nutrition(0)
	var/empty_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(empty_coeff - STAMINA_HUNGER_FLOOR) < 0.001, "Stamina coefficient should bottom out at STAMINA_HUNGER_FLOOR, got [empty_coeff]")

	// ramp between either, dont step at a threshold
	human.set_nutrition(NUTRITION_LEVEL_HUNGRY)
	var/hungry_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(hungry_coeff > STAMINA_HUNGER_FLOOR && hungry_coeff < 1, "Stamina coefficient should sit between the floor and 1 while hungry, got [hungry_coeff]")

	// Eating well pays a bonus
	human.set_nutrition(NUTRITION_LEVEL_FED)
	human.satiety = 100
	var/satiated_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(satiated_coeff - STAMINA_SATIETY_BONUS) < 0.001, "High satiety should apply STAMINA_SATIETY_BONUS, got [satiated_coeff]")

	// dont penalize NOHUNGER source on a stat they have no way to refill
	human.satiety = 0
	human.set_nutrition(0)
	ADD_TRAIT(human, TRAIT_NOHUNGER, TRAIT_SOURCE_UNIT_TESTS)
	var/nohunger_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(nohunger_coeff - 1) < 0.001, "TRAIT_NOHUNGER mobs should take no hunger stamina penalty, got [nohunger_coeff]")
	REMOVE_TRAIT(human, TRAIT_NOHUNGER, TRAIT_SOURCE_UNIT_TESTS)

	// no stomach, no care
	var/obj/item/organ/stomach/belly = human.get_organ_slot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT_NOTNULL(belly, "Test human somehow has no stomach to begin with")
	belly.Remove(human)
	var/stomachless_coeff = human.get_stamina_nutrition_coeff()
	TEST_ASSERT(abs(stomachless_coeff - 1) < 0.001, "Mobs with no stomach should take no hunger stamina penalty, got [stomachless_coeff]")

/datum/unit_test/hunger_stamina/Destroy()
	SSmobs.ignite()
	return ..()
