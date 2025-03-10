
/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slices_num = 6
	volume = 80
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES
	burns_in_oven = TRUE

/obj/item/reagent_containers/food/snacks/pizza/raw
	foodtype =  GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/pizza/margherita
	name = "margherita pizza"
	desc = "The most cheesy pizza in the galaxy."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/margherita
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/pizza/margherita/raw
	name = "raw pizza margherita"
	icon_state = "pizzamargherita_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/margherita/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/margherita, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizza/margherita/robo/Initialize(mapload)
	bonus_reagents += list(/datum/reagent/nanomachines = 70)
	return ..()

/obj/item/reagent_containers/food/snacks/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheesy pizza in the galaxy."
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/pizza/meat
	name = "meat pizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/meat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 8)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES| DAIRY | MEAT

/obj/item/reagent_containers/food/snacks/pizza/meat/raw
	name = "raw meatpizza"
	icon_state = "meatpizza_raw"
	foodtype =  GRAIN | VEGETABLES| DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/meat/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/meat, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meat pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/mushroom
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/mushroom/raw
	name = "raw mushroom pizza"
	icon_state = "mushroompizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/mushroom/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/mushroom, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#FFE4C4"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/vegetable
	name = "vegetable pizza"
	desc = "No Tomatos Sapiens were harmed during the making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/vegetable
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/oculine = 12, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/vegetable/raw
	name = "raw vegetable pizza"
	icon_state = "vegetablepizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/vegetable/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/vegetable, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all the pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/omnizine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD

/obj/item/reagent_containers/food/snacks/pizza/donkpocket/raw
	name = "raw donkpocket pizza"
	icon_state = "donkpocketpizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/donkpocket/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/donkpocket, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD

/obj/item/reagent_containers/food/snacks/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/dank
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/doctor_delight = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | FRUIT | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/dank/raw
	name = "raw dank pizza"
	icon_state = "dankpizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/dank/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/dank, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	filling_color = "#2E8B57"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | FRUIT | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can really smell the sassiness."
	icon_state = "sassysagepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/sassysage
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/sassysage/raw
	name = "raw sassysage pizza"
	icon_state = "sassysagepizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | MEAT | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/sassysage/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/sassysage, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	filling_color = "#FF4500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/pineapple
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE

/obj/item/reagent_containers/food/snacks/pizza/pineapple/raw
	name = "raw Hawaiian pizza"
	icon_state = "pineapplepizza_raw"
	foodtype =  GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/pineapple/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/pineapple, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/pineapple
	name = "\improper Hawaiian pizza slice"
	desc = "A slice of delicious controversy."
	icon_state = "pineapplepizzaslice"
	filling_color = "#FF4500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE

/obj/item/reagent_containers/food/snacks/pizza/seafood
	name = "\improper Tuna pizza"
	desc = "Steak of the sea, now topping of the sea."
	icon_state = "tunapizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/seafood
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 8) //got that omega 3 fatty acid
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "tuna" = 2)
	foodtype = GRAIN | VEGETABLES | SEAFOOD | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/seafood/raw
	name = "raw Tuna pizza"
	icon_state = "tunapizza_raw"
	foodtype =  GRAIN | VEGETABLES |  SEAFOOD | DAIRY | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/seafood/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/seafood, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/pizzaslice/seafood
	name = "\improper Tuna pizza slice"
	desc = "A slice of delicious tuna pizza."
	icon_state = "tunapizzaslice"
	filling_color = "#ffdebf"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "tuna" = 2)
	foodtype = GRAIN | VEGETABLES | SEAFOOD | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/arnold
	name = "\improper Arnold pizza"
	desc = "Hello, you've reached Arnold's pizza shop. I'm not here now, I'm out killing pepperoni."
	icon_state = "arnoldpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/arnold
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/iron = 10, /datum/reagent/medicine/omnizine = 30)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)

/obj/item/reagent_containers/food/snacks/pizza/arnold/raw
	name = "raw Arnold pizza"
	icon_state = "arnoldpizza_raw"
	foodtype =  GRAIN | DAIRY | VEGETABLES | RAW
	burns_in_oven = FALSE
	slice_path = null

/obj/item/reagent_containers/food/snacks/pizza/arnold/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/pizza/arnold, rand(70 SECONDS, 80 SECONDS), TRUE, TRUE)

/obj/item/reagent_containers/food/snacks/proc/try_break_off(mob/living/M, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	if(prob(50) && iscarbon(user) && M == user && (r_arm || l_arm))
		user.visible_message(span_warning("\The [src] breaks off [user]'s arm!!"), span_warning("\The [src] breaks off your arm!"))
		if(l_arm)
			l_arm.dismember()
		else
			r_arm.dismember()
		playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, TRUE, -1)

/obj/item/reagent_containers/food/snacks/proc/i_kill_you(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/pineappleslice))
		to_chat(user, "<font color='red' size='7'>If you want something crazy like pineapple, I kill you.</font>")
		user.gib() //if you want something crazy like pineapple, i kill you

/obj/item/reagent_containers/food/snacks/pizza/arnold/attack(mob/living/M, mob/living/user)
	. = ..()
	try_break_off(M, user)

/obj/item/reagent_containers/food/snacks/pizza/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/reagent_containers/food/snacks/pizzaslice/arnold
	name = "\improper Arnold pizza slice"
	desc = "I come over, maybe I give you a pizza, maybe I break off your arm."
	icon_state = "arnoldpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/reagent_containers/food/snacks/pizzaslice/arnold/attack(mob/living/M, mob/living/user)
	. =..()
	try_break_off(M, user)

/obj/item/reagent_containers/food/snacks/pizzaslice/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()

/obj/item/reagent_containers/food/snacks/pizzaslice/custom
	name = "pizza slice"
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFFFFF"
	foodtype = GRAIN | VEGETABLES

