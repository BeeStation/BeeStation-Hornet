The enclosed /images folder holds the image files used as the title screen for the game. All common formats such as PNG, JPG, and GIF are supported.
Byond's DMI format is also supported, but if you use a DMI only include one image per file and do not give it an icon_state (the text label below the image).

Keep in mind that the area a title screen fills is a 480px square so you should scale/crop source images to these dimensions first.
The game won't scale these images for you, so smaller images will not fill the screen and larger ones will be cut off.

Using unnecessarily huge images can cause client side lag and should be avoided. Extremely large GIFs should preferentially be converted to DMIs.
Placing non-image files in the images folder can cause errors.

You may add as many title screens as you like, if there is more than one a random screen is chosen (see name conventions for specifics).

---

Naming Conventions:

Every title screen you add must have a unique name. It is allowed to name two things the same if they have different file types, but this should be discouraged.
