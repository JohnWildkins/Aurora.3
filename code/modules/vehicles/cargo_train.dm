// See train.dm for most handling and inherited vars
/obj/vehicle/train/engine/cargo
	name = "cargo train tug"
	desc = "A ridable electric car designed for pulling cargo trolleys."

	keytype = /obj/item/key/cargo_train
	cell = /obj/item/cell/high

/obj/vehicle/train/trolley/cargo
	name = "cargo train trolley"

/obj/item/key/cargo_train
	name = "key"
	desc = "A keyring with a small steel key, and a yellow fob reading \"Choo Choo!\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "train_keys"
	w_class = ITEMSIZE_TINY
