extends Node

class Iterator:
	var _array: Array
	var _index: int

	func _init(arr: Array) -> void:
		_array = arr
		_index = 0

	func has_next() -> bool:
		return _index < _array.size()

	func next() -> Variant:
		if has_next():
			var element : Variant = _array[_index]
			_index += 1
			return element
		else:
			return null  # or any other value indicating the end of the array
