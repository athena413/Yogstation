#define MILK_TO_BUTTER_COEFF 15
#define LIQUID_TO_SOLID_COEFF 25

/obj/machinery/reagentgrinder
	name = "\improper All-In-One Grinder"
	desc = "From BlenderTech. Will It Blend? Let's test it out!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer"
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/reagentgrinder
	pass_flags = PASSTABLE
	resistance_flags = ACID_PROOF
	var/operating = FALSE
	var/obj/item/reagent_containers/container = /obj/item/reagent_containers/glass/beaker/large
	var/limit = 10
	var/speed = 1
	var/list/holdingitems

	var/static/radial_examine = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_eject")
	var/static/radial_grind = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_grind")
	var/static/radial_juice = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_juice")
	var/static/radial_mix = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_mix")

/obj/machinery/reagentgrinder/kitchen //starts with a mixing bowl inside instead
	container = /obj/item/reagent_containers/glass/mixbowl

/obj/machinery/reagentgrinder/Initialize(mapload)
	. = ..()
	holdingitems = list()
	container = new container(src)

/obj/machinery/reagentgrinder/constructed/Initialize(mapload)
	. = ..()
	holdingitems = list()
	QDEL_NULL(container)
	update_icon()

/obj/machinery/reagentgrinder/Destroy()
	if(container)
		container.forceMove(drop_location())
	drop_all_items()
	return ..()

/obj/machinery/reagentgrinder/contents_explosion(severity, target)
	if(container)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += container
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += container
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += container

/obj/machinery/reagentgrinder/RefreshParts()
	speed = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		speed = M.rating

/obj/machinery/reagentgrinder/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(operating)
		. += span_warning("\The [src] is operating.")
		return

	if(container || length(holdingitems))
		. += span_notice("\The [src] contains:")
		if(container)
			. += span_notice("- \A [container].")
		for(var/i in holdingitems)
			var/obj/item/O = i
			. += span_notice("- \A [O.name].")

	if(!(stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		span_notice("- Grinding reagents at <b>[speed*100]%</b>.")
		if(container)
			for(var/datum/reagent/R in container.reagents.reagent_list)
				. += span_notice("- [R.volume] units of [R.name].")

/obj/machinery/reagentgrinder/handle_atom_del(atom/A)
	. = ..()
	if(A == container)
		container = null
		update_icon()
	if(holdingitems[A])
		holdingitems -= A

/obj/machinery/reagentgrinder/proc/drop_all_items()
	for(var/i in holdingitems)
		var/atom/movable/AM = i
		AM.forceMove(drop_location())
	holdingitems = list()

/obj/machinery/reagentgrinder/update_icon()
	if(!container)
		icon_state = "juicer"
		return

	if(istype(container, /obj/item/reagent_containers/glass/mixbowl))
		icon_state = "juicer_bowl"
	else
		icon_state = "juicer_beaker"

/obj/machinery/reagentgrinder/proc/replace_container(mob/living/user, obj/item/reagent_containers/new_container)
	if(container)
		container.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(container)
	if(new_container)
		container = new_container
	else
		container = null
	update_icon()
	return TRUE

/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	//You can only screw open empty grinder
	if(!container && !length(holdingitems) && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(panel_open) //Can't insert objects when its screwed open
		return TRUE

	if (istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_container(user, B)
		to_chat(user, span_notice("You add [B] to [src]."))
		update_icon()
		return TRUE //no afterattack

	if(holdingitems.len >= limit)
		to_chat(user, span_warning("[src] is filled to capacity!"))
		return TRUE

	//Fill machine with a bag!
	if(istype(I, /obj/item/storage/bag))
		var/list/inserted = list()
		if(SEND_SIGNAL(I, COMSIG_TRY_STORAGE_TAKE_TYPE, /obj/item/reagent_containers/food/snacks/grown, src, limit - length(holdingitems), null, null, user, inserted))
			for(var/i in inserted)
				holdingitems[i] = TRUE
			if(!I.contents.len)
				to_chat(user, span_notice("You empty [I] into [src]."))
			else
				to_chat(user, span_notice("You fill [src] to the brim."))
		return TRUE

	if(!I.grind_results && !I.juice_results)
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, span_warning("You cannot grind [I] into reagents!"))
			return TRUE

	if(!I.grind_requirements(src)) //Error messages should be in the objects' definitions
		return

	if(user.transferItemToLoc(I, src))
		to_chat(user, span_notice("You add [I] to [src]."))
		holdingitems[I] = TRUE
		return FALSE

/obj/machinery/reagentgrinder/ui_interact(mob/user) // The microwave Menu //I am reasonably certain that this is not a microwave
	. = ..()

	if(operating || !user.canUseTopic(src, !issilicon(user)))
		return

	var/list/options = list()

	if(container || length(holdingitems))
		options["eject"] = radial_eject

	if(isAI(user))
		if(stat & NOPOWER)
			return
		options["examine"] = radial_examine

	// if there is no power or it's broken, the procs will fail but the buttons will still show
	if(length(holdingitems))
		options["grind"] = radial_grind
		options["juice"] = radial_juice
	else if(container?.reagents.total_volume)
		options["mix"] = radial_mix

	var/choice

	if(length(options) < 1)
		return
	if(length(options) == 1)
		for(var/key in options)
			choice = key
	else
		choice = show_radial_menu(user, src, options, require_near = !issilicon(user))

	// post choice verification
	if(operating || (isAI(user) && stat & NOPOWER) || !user.canUseTopic(src, !issilicon(user)))
		return

	switch(choice)
		if("eject")
			eject(user)
		if("grind")
			grind(user)
		if("juice")
			juice(user)
		if("mix")
			mix(user)
		if("examine")
			examine(user)

/obj/machinery/reagentgrinder/proc/eject(mob/user)
	for(var/i in holdingitems)
		var/obj/item/O = i
		O.forceMove(drop_location())
		holdingitems -= O
	if(container)
		replace_container(user)

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/shake_for(duration)
	add_overlay("juicer_blend")
	var/offset = prob(50) ? -2 : 2
	var/old_pixel_x = pixel_x
	animate(src, pixel_x = pixel_x + offset, time = 0.02 SECONDS, loop = -1) //start shaking
	addtimer(CALLBACK(src, PROC_REF(stop_shaking), old_pixel_x), duration)

/obj/machinery/reagentgrinder/proc/stop_shaking(old_px)
	cut_overlays()
	animate(src)
	pixel_x = old_px

/obj/machinery/reagentgrinder/proc/operate_for(time, silent = FALSE, juicing = FALSE)
	shake_for(time / speed)
	operating = TRUE
	if(!silent)
		if(!juicing)
			playsound(src, 'sound/machines/blender.ogg', 50, 1)
		else
			playsound(src, 'sound/machines/juicer.ogg', 20, 1)
	addtimer(CALLBACK(src, PROC_REF(stop_operating)), time / speed)

/obj/machinery/reagentgrinder/proc/stop_operating()
	operating = FALSE

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(!container || stat & (NOPOWER|BROKEN) || container.reagents.total_volume >= container.reagents.maximum_volume)
		return
	operate_for(5 SECONDS, juicing = TRUE)
	for(var/obj/item/i in holdingitems)
		if(container.reagents.total_volume >= container.reagents.maximum_volume)
			break
		var/obj/item/I = i
		check_trash(I)
		if(I.juice_results)
			juice_item(I)

/obj/machinery/reagentgrinder/proc/juice_item(obj/item/I) //Juicing results can be found in respective object definitions
	if(I.on_juice(src) == -1)
		to_chat(usr, span_danger("[src] shorts out as it tries to juice up [I], and transfers it back to storage."))
		return
	container.reagents.add_reagent_list(I.juice_results)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/grind(mob/user)
	power_change()
	if(!container || stat & (NOPOWER|BROKEN) || container.reagents.total_volume >= container.reagents.maximum_volume)
		return
	operate_for(6 SECONDS)
	for(var/i in holdingitems)
		if(container.reagents.total_volume >= container.reagents.maximum_volume)
			break
		var/obj/item/I = i
		check_trash(I)
		if(I.grind_results)
			grind_item(i, user)

/obj/machinery/reagentgrinder/proc/grind_item(obj/item/I, mob/user) //Grind results can be found in respective object definitions
	if(I.on_grind(src) == -1) //Call on_grind() to change amount as needed, and stop grinding the item if it returns -1
		to_chat(usr, span_danger("[src] shorts out as it tries to grind up [I], and transfers it back to storage."))
		return
	container.reagents.add_reagent_list(I.grind_results)
	if(I.reagents)
		I.reagents.trans_to(container, I.reagents.total_volume, transfered_by = user)
	remove_object(I)

/obj/machinery/reagentgrinder/proc/check_trash(obj/item/I)
	if (istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/R = I
		if (R.trash)
			R.generate_trash(get_turf(src))

/obj/machinery/reagentgrinder/proc/mix(mob/user)
	//For butter and other things that would change upon shaking or mixing
	power_change()
	if(!container || stat & (NOPOWER|BROKEN))
		return
	operate_for(5 SECONDS, juicing = TRUE)
	addtimer(CALLBACK(src, /obj/machinery/reagentgrinder/proc/mix_complete), 5 SECONDS)

/obj/machinery/reagentgrinder/proc/mix_complete()
	if(container?.reagents.total_volume)
		//Recipe to make Butter
		var/butter_amt = FLOOR(container.reagents.get_reagent_amount(/datum/reagent/consumable/milk) / MILK_TO_BUTTER_COEFF, 1)
		container.reagents.remove_reagent(/datum/reagent/consumable/milk, MILK_TO_BUTTER_COEFF * butter_amt)
		for(var/i in 1 to butter_amt)
			new /obj/item/reagent_containers/food/snacks/butter(drop_location())
		//Recipe to make Mayonnaise
		if (container.reagents.has_reagent(/datum/reagent/consumable/eggyolk))
			var/amount = container.reagents.get_reagent_amount(/datum/reagent/consumable/eggyolk)
			container.reagents.remove_reagent(/datum/reagent/consumable/eggyolk, amount)
			container.reagents.add_reagent(/datum/reagent/consumable/mayonnaise, amount)
		//Recipe to make Soap
		var/soap_amt = FLOOR(container.reagents.get_reagent_amount(/datum/reagent/liquidsoap) / LIQUID_TO_SOLID_COEFF, 1)
		container.reagents.remove_reagent(/datum/reagent/liquidsoap, LIQUID_TO_SOLID_COEFF * soap_amt)
		for(var/i in 1 to soap_amt)
			new /obj/item/soap/homemade(drop_location())

/obj/machinery/reagentgrinder/MouseDrop_T(atom/dropping, mob/user)
	if(istype(dropping, /obj/item/reagent_containers/glass))
		attackby(dropping, user)
	else
		..()

#undef MILK_TO_BUTTER_COEFF
#undef LIQUID_TO_SOLID_COEFF
