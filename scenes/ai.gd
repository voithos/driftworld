extends Node2D

const colors = preload("res://scripts/colors.gd")

enum STRATEGY {
	DEFENSIVE,
	AGGRESSIVE,
	BALANCED,
}

export (STRATEGY) var strategy = STRATEGY.DEFENSIVE
export (colors.TYPE) var unit_type = colors.TYPE.NEUTRAL

const AI_TICK = 0.2
var delta_since_tick = 0.0

func _ready():
	assert(unit_type != colors.TYPE.PLAYER)
	randomize()

func _physics_process(delta):
	delta_since_tick += delta
	if delta_since_tick >= AI_TICK:
		think(AI_TICK)
		delta_since_tick = 0.0

func think(delta):
	var units = get_tree().get_nodes_in_group("units_" + str(unit_type))
	var bases = get_tree().get_nodes_in_group("bases_" + str(unit_type))
	match strategy:
		STRATEGY.DEFENSIVE:
			defense(delta, units, bases)
		STRATEGY.AGGRESSIVE:
			aggression(delta, units, bases)
		STRATEGY.BALANCED:
			balanced(delta, units, bases)

# TODO: Reduce code duplication

func defense(delta, units, bases):
	var divided = divide_units(units, bases)
	
	for i in range(len(bases)):
		var b = bases[i]
		var base_units = divided[i]

		# Prioritize base defense
		if b.is_under_attack:
			prob_go_to(base_units, b.aggressor_pos, 0.8)
			continue

		var under_attack = false
		for unit in base_units:
			if unit.is_under_attack:
				prob_go_to(base_units, unit.aggressor_pos, 0.5)
				under_attack = true
				break

		# Return to base
		if not under_attack:
			prob_go_to(base_units, b.global_position, 0.5)
			idle_if_close_to_base(base_units, b.global_position, 1)

func aggression(delta, units, bases):
	var divided = divide_units(units, bases)
	var enemy_bases = get_enemy_bases()

	for i in range(len(bases)):
		var b = bases[i]
		var base_units = divided[i]

		# Prioritize base defense
		if b.is_under_attack:
			prob_go_to(base_units, b.aggressor_pos, 0.8)
			continue

		var under_attack = false
		for unit in base_units:
			if unit.is_under_attack:
				prob_go_to(base_units, unit.aggressor_pos, 0.5)
				under_attack = true
				break

		# Go on the offensive
		if not under_attack:
			if b.ai_target_base == null or b.ai_target_base.unit_type == unit_type:
				# No target, or target has been captured
				var close = get_close_bases(enemy_bases, b.global_position)
				var rand_base = pick_random(close)
				if rand_base:
					b.ai_target_base = rand_base
			if b.ai_target_base:
				prob_go_to(base_units, b.ai_target_base.global_position, 0.5)
	
	# If you have no bases, just attack
	if len(bases) == 0:
		for u in units:
			var close = get_close_bases(enemy_bases, u.global_position)
			var rand_base = pick_random(close)
			if rand_base:
				prob_go_to([u], rand_base.global_position, 1.0)

const MIN_BALANCED_UNITS = 15
const STAGING_TIME = 6.0
const STAGING_DIST = 200

func balanced(delta, units, bases):
	var divided = divide_units(units, bases)
	var enemy_bases = get_enemy_bases()

	for i in range(len(bases)):
		var b = bases[i]
		var base_units = divided[i]

		# Prioritize base defense
		if b.is_under_attack:
			prob_go_to(base_units, b.aggressor_pos, 0.8)
			continue

		var under_attack = false
		for unit in base_units:
			if unit.is_under_attack:
				prob_go_to(base_units, unit.aggressor_pos, 0.5)
				under_attack = true
				break

		# Go on the offensive
		if not under_attack:
			# Wait until sufficient units are available.
			if len(base_units) < MIN_BALANCED_UNITS:
				b.ai_target_base = null
				prob_go_to(base_units, b.global_position, 0.5)
				idle_if_close_to_base(base_units, b.global_position, 1)
			# Try to latch onto a target
			elif b.ai_target_base == null or b.ai_target_base.unit_type == unit_type:
				# No target, or target has been captured
				var close = get_close_bases(enemy_bases, b.global_position)
				var rand_base = pick_random(close)
				if rand_base:
					b.ai_target_base = rand_base
					b.ai_staging_time_left = STAGING_TIME

			if b.ai_target_base:
				if b.ai_staging_time_left < 0:
					prob_go_to(base_units, b.ai_target_base.global_position, 0.5)
				else:
					b.ai_staging_time_left -= delta
					var angle = b.global_position.angle_to(b.ai_target_base.global_position)
					var staging_location = b.global_position + Vector2(cos(angle), sin(angle)) * STAGING_DIST
					prob_go_to(base_units, staging_location, 0.9)
	
	# If you have no bases, just attack
	if len(bases) == 0:
		for u in units:
			var close = get_close_bases(enemy_bases, u.global_position)
			var rand_base = pick_random(close)
			if rand_base:
				prob_go_to([u], rand_base.global_position, 1.0)

## Helpers

func pick_random(arr):
	if arr:
		return arr[randi() % arr.size()]
	return null

const CLOSENESS_THRESHOLD = 500*500
func get_close_bases(bases, from_pos):
	var closest = null
	var closest_dist = -1
	for b in bases:
		var dist = from_pos.distance_squared_to(b.global_position)
		if dist < closest_dist or closest == null:
			closest = b
			closest_dist = dist
	
	if closest == null:
		return []
	var res = [closest]
	for b in bases:
		if b != closest:
			if from_pos.distance_squared_to(b.global_position) - closest_dist < CLOSENESS_THRESHOLD:
				res.append(b)
	return res

func get_enemy_bases():
	var bases = []
	for c in colors.TYPE:
		var col = colors.TYPE[c]
		if col == unit_type or col in colors.ALLIES[unit_type]:
			continue
		var bs = get_tree().get_nodes_in_group("bases_" + str(col))
		for b in bs:
			bases.append(b)
	return bases
	
func prob_go_to(units, pos, prob):
	for u in units:
		if randf() < prob:
			u.go_to(pos)

const IDLE_DISTANCE_SQUARED = 200*200

func idle_if_close_to_base(units, pos, prob):
	for u in units:
		if u.global_position.distance_squared_to(pos) <= IDLE_DISTANCE_SQUARED and randf() < prob:
			u.go_idle()

func divide_units(units, bases):
	# Divide units into groups based on the bases they are closest to
	if len(bases) == 0:
		return [units]
	var res = []
	for b in bases:
		res.append([])
	for unit in units:
		var closest_i = -1
		var closest_distsq = -1
		for i in range(len(bases)):
			var distsq = unit.global_position.distance_squared_to(bases[i].global_position)
			if distsq < closest_distsq or closest_i == -1:
				closest_i = i
				closest_distsq = distsq
		res[closest_i].append(unit)
	
	return res
