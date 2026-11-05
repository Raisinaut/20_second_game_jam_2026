extends Node

@export var smoke_puff: PackedScene

enum ParticleType {
	SMOKE_PUFF,
}
var type_dict = {
	ParticleType.SMOKE_PUFF : "smoke_puff",
}


func spawn_particle(particle_type: ParticleType, parent: Node3D):
	var scene = get(type_dict.get(particle_type))
	if scene == null:
		push_error("Scene is null for ", ParticleType.find_key(particle_type))
		return
	var inst : CPUParticles3D = scene.instantiate()
	inst.emitting = false # Disable emission for now
	inst.ready.connect(_on_particle_ready.bind(inst, parent.global_transform))
	inst.finished.connect(_on_particle_finished.bind(inst))
	get_tree().get_root().call_deferred("add_child", inst)
	print("Particle spawned: ", ParticleType.find_key(particle_type))


# SIGNALS ----------------------------------------------------------------------
func _on_particle_ready(particle: CPUParticles3D, xform: Transform3D) -> void:
	# Set transform before emission
	particle.global_transform = xform
	particle.scale = Vector3.ONE # reset scale for safety
	# Emit
	particle.one_shot = true
	particle.emitting = true

func _on_particle_finished(particle: CPUParticles3D) -> void:
	if particle.one_shot:
		particle.queue_free()
