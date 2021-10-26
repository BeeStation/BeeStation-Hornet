/** Do we have any use for this one?
 * # Fake N-spect scanner
 *
 * A clown variant of the N-spect scanner
 *
 * This prints fake reports with garbage in them,
 * can be set to print them instantly with a screwdriver.
 * By default it plays the old "woody" scanning sound, scanning sounds can be cycled by clicking with a multitool.
 * Can be crafted into a bananium HONK-spect scanner
 */
/obj/item/inspector/clown
	///will only cycle through modes with numbers lower than this
	var/max_mode = CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST
	///names of modes, ordered first to last
	var/list/mode_names = list("normal", "classic", "honk", "fafafoggy")
