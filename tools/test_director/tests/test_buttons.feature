Feature: Button Interaction
	In order to verify the button click interaction with a device
	a mob should click a button and verify that the device attached
	to it recieved a signal

	Background:
		# Inject code necessary for the test to run
	  Given the following code is injected:
			"""
      /obj/item/assembly/unit_test
        var/pressed = FALSE

      /obj/item/assembly/unit_test/pulsed(mob/pulser)
        . = ..()
        pressed = TRUE
			"""

	Scenario: Button click interaction test
		Given button is defined as new /obj/machinery/button
		And device is defined as new /obj/item/assembly/unit_test
		And the player is next to button
		And the button device is set to device
		When the player clicks the button
		Then device pressed should be 1
