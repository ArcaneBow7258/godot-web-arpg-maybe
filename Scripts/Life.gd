extends TextureProgressBar
@export var maxLife : int
@export var temp_vis : bool
@export var timeout : float = 2
@export var timer : Timer
signal on_empty
func _ready():
	value = maxLife
	max_value = maxLife
	timer =  $Timer
	if temp_vis:
		visible = false
	else:
		visible = true
		timer.queue_free()

func _on_value_changed(value):
	print(value)
	if temp_vis:
		visible = true
		timer.start(timeout)
	if value <= 0:
		on_empty.emit()


func _on_timer_timeout():
	visible = false


