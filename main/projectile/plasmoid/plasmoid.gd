class_name Plasmoid extends Projectile

func _ready() -> void:
	super._ready()
	$BlastProjectile.sender = sender
