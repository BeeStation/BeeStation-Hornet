### Robust Guide to Turbolifts
#### by ike709
##### Background Knowledge
Turbolifts work much like shuttles. Because they are shuttles. Therefore, it is essential to have a good understanding of [how shuttles work](https://wiki.beestation13.com/view/Guide_to_mapping#Shuttles). Also, an example of a functional turbolift can be found in `_maps\map_files\debug\multi_z.dmm` using the turbolift template found in `_maps\shuttles\turbolifts\debug_primary.dmm`.
##### Creating the turbolift template
The turbolift itself is a regular shuttle template in the shape of a square or rectangle. There are some caveats in order to make it as simple and straightforward as possible:

 - The mobile dock type is `/obj/docking_port/mobile/turbolift`. The `dir` var must be the same side as the side with the airlocks. The only other relevant vars are `id`, `width`, `height`, `dwidth`, and `dheight` (all of which must match the values in the turbolift shaft's stationary dock, more on that later).
 - Turbolifts are, for the moment, indestructible. Use `/obj/machinery/door/airlock/turbolift` for the doors, `/turf/open/indestructible/turbolift` for the floors, and `/turf/closed/indestructible/turbolift` for the walls. No vars need to be edited. Additional, destructible objects such as light fixtures are fine.
 - Turbolifts require unique areas, which must be subtypes of `/area/shuttle/turbolift`. A unique name is recommended, but no other changes are necessary. At the time of writing, three subtypes have been pre-made in `turbolift_areas.dm`.
 - Do not attempt to add APCs, piping, or cables to the turbolift template. Don't worry about power or atmos.
 - The most important part of the turbolift is the turbolift computer (`/obj/machinery/computer/turbolift`). Edit the `pixel_y` and `pixel_x` vars as needed. Set the `shuttle_id` var equal to the mobile dock's `id`. If you want to, you can also set a custom `time_between_stops` (deciseconds) which is the amount of time it will wait on a floor before moving on to the next one. Do not touch the other vars unless you know what you are doing.
 - Remember to add the template to `shuttles.dm`.
##### Creating the turbolift shaft
Unlike the turbolift, the shaft is mostly just a regular part of the station, and can be made out of regular walls or rwalls with the turbolift airlocks as the outer door on the same side as the turbolift template's inner door. However, there are some things to take note of:
 - Use the `/area/shuttle/turbolift/shaft` area within the shaft.
 - Use plating as the floor of the bottom zlevel, and `/turf/open/openspace` as the floor of every zlevel above that.
 - Every zlevel of the shaft needs a turbolift docking port (`/obj/docking_port/stationary/turbolift`). They need to be in the same x/y position as the port below it. HOWEVER, for every docking port **above the bottom level** you only need to edit the `id` var to match the template's mobile dock `id`. For the **bottom dock only** you need to set the `id`, `width`, `height`, `dwidth`, and `dheight` vars to match the template's mobile dock. **Those vars will be automatically copied to the docking ports above the bottom floor.** You also need to set the bottom dock's `roundstart_template` to match the turbolift template.
 - The deck name in the UI is set to the stationary dock's `name` var. Example: `name = "Engineering"` on the bottom floor will be displayed in the UI as `Deck 1: Engineering`.
 - Don't add anything else to the inside of the shaft.
##### Adding turbolift buttons
Turbolift buttons (`/obj/machinery/turbolift_button`) are just call buttons. They can be anywhere on a z-level (though I recommend near the outer doors of the shaft), and they will call the linked turbolift to that z-level. Set the `shuttle_id` var to the turbolift mobile dock `id` / turbolift computer `shuttle_id` and it will handle the rest. You can also set the `pixel_x`/`pixel_y` vars as needed.
##### That's all
The code will take care of everything else, assuming you did everything correctly. Also, rotating the elevators is not supported. Nor can you move them to various points on the same z-level. Many of these restrictions will hopefully be phased out in future updates.
