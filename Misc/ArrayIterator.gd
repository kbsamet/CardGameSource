extends Node

class Iterator:
	var _array: Array
	var _index: int

	func _init(arr: Array):
		_array = arr
		_index = 0

	func has_next() -> bool:
		return _index < _array.size()

	func next():
		if has_next():
			var element = _array[_index]
			_index += 1
			return element
		else:
			return null  # or any other value indicating the end of the array
