import Foundation

extension World {
    func setTransform(_ transform: TransformComponent, for entity: EntityID) {
        transforms[entity] = transform
    }

    func setPhysics(_ physics: PhysicsComponent, for entity: EntityID) {
        physicsBodies[entity] = physics
    }

    func setRender(_ render: RenderComponent, for entity: EntityID) {
        renderables[entity] = render
    }

    func setHealth(_ healthComponent: HealthComponent, for entity: EntityID) {
        health[entity] = healthComponent
    }

    func setAI(_ component: AIComponent, for entity: EntityID) {
        ai[entity] = component
    }

    func setCombat(_ component: CombatComponent, for entity: EntityID) {
        combat[entity] = component
    }

    func setCollectible(_ component: CollectibleComponent, for entity: EntityID) {
        collectibles[entity] = component
    }

    func setLight(_ component: LightComponent, for entity: EntityID) {
        lights[entity] = component
    }

    func setHeat(_ component: HeatComponent, for entity: EntityID) {
        heatZones[entity] = component
    }

    func setCrystal(_ component: CrystalComponent, for entity: EntityID) {
        crystals[entity] = component
    }

    func setPlayer(_ component: PlayerComponent, for entity: EntityID) {
        players[entity] = component
    }

    func setEnemy(_ component: EnemyComponent, for entity: EntityID) {
        enemies[entity] = component
    }

    func setParticle(_ component: ParticleEmitterComponent, for entity: EntityID) {
        particleEmitters[entity] = component
    }

    func setBoss(_ component: BossComponent, for entity: EntityID) {
        bosses[entity] = component
    }

    func setMiningTool(_ component: MiningToolComponent, for entity: EntityID) {
        miningTools[entity] = component
    }

    func setDrone(_ component: DroneComponent, for entity: EntityID) {
        drones[entity] = component
    }

    func setHeatLight(_ component: HeatLightComponent, for entity: EntityID) {
        heatLights[entity] = component
    }
}
