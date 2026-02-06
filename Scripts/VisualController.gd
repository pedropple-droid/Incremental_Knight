extends Node
class_name VisualController

@onready var action_controller: ActionController = ActionController.new()
@onready var upgrade_controller: UpgradeController = UpgradeController.new()
@onready var qte: QTEController = QTEController.new()
@onready var data_handler: DataHandler = DataHandler.new()
