class_name Parabolic

var coefficients = []

func _init(input: Array[Vector2]):
	if input[0].x < input[1].x:
		coefficients = Parabolic.solve_parabola_coefficients(input[0], input[1], input[2])
	else:
		coefficients = Parabolic.solve_parabola_coefficients(input[1], input[0], input[2])

func is_valid() -> bool:
	return !coefficients.is_empty()

func calc_y(x: float) -> float:
	if coefficients.is_empty():
		return NAN
	return coefficients[0]*x*x + coefficients[1]*x + coefficients[2]

# alias for constructor
static func calculate(input: Array[Vector2]) -> Parabolic:
	return Parabolic.new(input)

# Returns an array with coefficients [a, b, c] for the given 3 points.
# Returns empty array if determinant is zero.
static func solve_parabola_coefficients(p1: Vector2, p2: Vector2, p3: Vector2) -> Array[float]:
	# Set up the system of equations
	var a_matrix: Array[Array] = [
		[p1.x*p1.x, p1.x, 1],
		[p2.x*p2.x, p2.x, 1],
		[p3.x*p3.x, p3.x, 1]
	]
	var y_matrix: Array[float] = [p1.y, p2.y, p3.y]

	# Solve for the coefficients using Cramer's Rule
	# computing the determinant of a_matrix and then solving for 'a', 'b', and 'c'
	return solve_system(a_matrix, y_matrix)


# Function to solve a system of linear equations using Cramer's Rule
static func solve_system(matrix: Array[Array], y_matrix: Array) -> Array[float]:
	var det: float = determinant(matrix)
	if det == 0:
		print_debug("zero determinant for %s" % str(matrix))
		return []

	var solution: Array[float] = [0, 0, 0]
	for i in range(3):
		var mod_matrix = matrix.duplicate(true)
		for j in range(3):
			mod_matrix[j][i] = y_matrix[j] # Replace the column with the results
		var det_i = determinant(mod_matrix)
		if det_i ==0:
			print_debug("zero determinant for %s" % str(matrix))
			return []
		solution[i] = det_i / det
	return solution


# Function to calculate the determinant of a 3x3 matrix
static func determinant(matrix: Array[Array]) -> float:
	return matrix[0][0] * (matrix[1][1] * matrix[2][2] - matrix[2][1] * matrix[1][2]) - \
		   matrix[0][1] * (matrix[1][0] * matrix[2][2] - matrix[1][2] * matrix[2][0]) + \
		   matrix[0][2] * (matrix[1][0] * matrix[2][1] - matrix[1][1] * matrix[2][0])

func _to_string():
	if !is_valid():
		return "invalid"
	return "(y = %s*x^2 + %s*x + %s)" % coefficients
