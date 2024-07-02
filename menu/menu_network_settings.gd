extends VBoxContainer


func _ready():
	$GridContainer/LocalPredEnabledCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/LocalPredDelayEnabledCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/ServerReconciliationCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/RemotePredCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/EntityInterpolationCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/LagCompCheck.toggled.connect(_on_any_checkbox_changed)
	$GridContainer/LocalPredDelaySpin.value_changed.connect(_on_any_spin_changed)
	
	
func _on_any_checkbox_changed(_pressed):
	Network.local_prediction_enabled = $GridContainer/LocalPredEnabledCheck.button_pressed	
	Network.local_prediction_delay_enabled = $GridContainer/LocalPredDelayEnabledCheck.button_pressed
	Network.server_reconciliation_enabled = $GridContainer/ServerReconciliationCheck.button_pressed
	Network.remote_prediction_enabled = $GridContainer/RemotePredCheck.button_pressed
	Network.remote_entity_interpolation = $GridContainer/EntityInterpolationCheck.button_pressed
	Network.lag_compensation = $GridContainer/LagCompCheck.button_pressed

func _on_any_spin_changed(_value):
	Network.local_prediction_delay = $GridContainer/LocalPredDelaySpin.value
