class_name WebLifecycle
extends Node
## Runs even while the game tree is paused; no elapsed background combat.
var skip_frame := false
var _suspended := false
var _epoch := -1
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -100
func _process(_delta: float) -> void:
	if not OS.has_feature("web"):
		return
	var epoch := int(JavaScriptBridge.eval("window.gameResumeEpoch || 0"))
	if epoch != _epoch:
		_epoch = epoch
		skip_frame = true
		_release()
	set_suspended(bool(JavaScriptBridge.eval("!!window.gameSuspended")))
func set_suspended(value: bool) -> void:
	if value == _suspended:
		return
	_suspended = value
	_release()
	get_tree().paused = value
	skip_frame = true
func _release() -> void:
	for action in MobileControls.ACTIONS:
		Input.action_release(action)
