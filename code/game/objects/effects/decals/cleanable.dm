/obj/effect/decal/cleanable
	gender = PLURAL
	layer = ABOVE_NORMAL_TURF_LAYER
	var/list/random_icon_states = null
	var/blood_state = "" //I'm sorry but cleanable/blood code is ass, and so is blood_DNA
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if (random_icon_states && (icon_state == initial(icon_state)) && length(random_icon_states) > 0)
		icon_state = pick(random_icon_states)
	create_reagents(300)
	if(loc && isturf(loc))
		for(var/obj/effect/decal/cleanable/C in loc)
			if(C != src && C.type == type && !QDELETED(C))
				if (replace_decal(C))
					return INITIALIZE_HINT_QDEL

	if(LAZYLEN(diseases))
		var/list/datum/disease/diseases_to_add = list()
		for(var/datum/disease/D in diseases)
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
				diseases_to_add += D
		if(LAZYLEN(diseases_to_add))
			AddComponent(/datum/component/infective, diseases_to_add)

/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C) // Returns true if we should give up in favor of the pre-existing decal
	if(mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/attackby(obj/item/W, mob/user, params)
	if((istype(W, /obj/item/reagent_containers/glass) && !istype(W, /obj/item/reagent_containers/glass/rag)) || istype(W, /obj/item/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!src.reagents.total_volume)
				to_chat(user, span_notice("[src] isn't thick enough to scoop up!"))
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, span_notice("[W] is full!"))
				return
			to_chat(user, span_notice("You start scooping up [src] into [W]..."))
			var/scoop_time
			scoop_time = min((W.reagents.maximum_volume - W.reagents.total_volume), src.reagents.total_volume) //1 second per 10 units scooped
			if(do_mob(user, user, scoop_time))
				if(src)
					to_chat(user, span_notice("You scoop up [src] into [W]!"))
					reagents.trans_to(W, reagents.total_volume, transfered_by = user)
					if(!reagents.total_volume) //scooped up all of it
						qdel(src)
						return

	if(W.is_hot()) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/clothing/mask/cigarette))
			return
		else
			var/hotness = W.is_hot()
			reagents.expose_temperature(hotness)
			to_chat(user, span_notice("You heat [name] with [W]!"))
	else
		return ..()

/obj/effect/decal/cleanable/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/effect/decal/cleanable/fire_act(exposed_temperature, exposed_volume)
	if(reagents)
		reagents.expose_temperature(exposed_temperature)
	..()


//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/Crossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		if(H.shoes && blood_state && bloodiness && !HAS_TRAIT(H, TRAIT_LIGHT_STEP))
			var/obj/item/clothing/shoes/S = H.shoes
			if(!istype(S) || !S.can_be_bloody)
				return
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS,S.bloody_shoes[blood_state]+add_blood)
			S.add_blood_DNA(return_blood_DNA())
			S.blood_state = blood_state
			update_icon()
			H.update_inv_shoes()


/**
 * Checks if this decal is a valid decal that can be blood crawled in.
 */
/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return bloodiness

	return FALSE

/**
 * Gets the color associated with the any blood present on this decal. If there is no blood, returns null.
 */
/obj/effect/decal/cleanable/proc/get_blood_color()
	switch(blood_state)
		if(BLOOD_STATE_HUMAN)
			return rgb(149, 10, 10)
		if(BLOOD_STATE_XENO)
			return rgb(43, 186, 0)
		if(BLOOD_STATE_OIL)
			return rgb(22, 22, 22)

	return null

/obj/effect/decal/cleanable/wash(clean_types)
	..()
	qdel(src)
	return TRUE
