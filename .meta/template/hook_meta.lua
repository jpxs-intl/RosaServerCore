---@meta

---@alias HookReturn 1 | 2 | nil
---@alias HookNoOverride 1 | nil

---@class ConsoleAutoCompleteData
---@field response string If data.response is changed, the console's current buffer will be changed to that string.

---@class SendConnectResponseData
---@field message string data.message can be changed to alter the message that is sent.

---@alias hooks.AccountDeathTax fun(account: Account): HookReturn
---@alias hooks.AccountTicketBegin fun(identifier: integer, ticket: integer): HookReturn
---@alias hooks.AccountTicketFound fun(account?: Account): HookReturn
---@alias hooks.AccountsSave fun(): HookReturn
---@alias hooks.AreaCreateBlock fun(blockX: integer, blockY: integer, blockZ: integer, flags: integer): HookReturn
---@alias hooks.AreaDeleteBlock fun(blockX: integer, blockY: integer, blockZ: integer): HookReturn
---@alias hooks.BulletCreate fun(type: integer, position: Vector, velocity: Vector, player: Player): HookReturn
---@alias hooks.BulletHitHuman fun(human: Human, bullet: Bullet): HookReturn
---@alias hooks.BulletMayHit fun(bullet: Bullet): HookNoOverride
---@alias hooks.BulletMayHitHuman fun(bullet: Bullet): HookNoOverride
---@alias hooks.CalculateEarShots fun(connection: Connection, player: Player): HookReturn
---@alias hooks.CollideBodies fun(aBody: RigidBody, bBody: RigidBody, aLocalPos: Vector, bLocalPos: Vector, normal: Vector, a: number, b: number, c: number, d: number): HookReturn
---@alias hooks.ConsoleAutoComplete fun(data: ConsoleAutoCompleteData): HookNoOverride	
---@alias hooks.ConsoleInput fun(input: string): HookNoOverride
---@alias hooks.CreateTraffic fun(amount: HookInteger): HookReturn
---@alias hooks.EconomyCarMarket fun(): HookReturn
---@alias hooks.EventBullet fun(type: integer, position: Vector, velocity: Vector, item: Item): HookReturn
---@alias hooks.EventBulletHit fun(hitType: integer, position: Vector, normal: Vector): HookReturn
---@alias hooks.EventMessage fun(speakerType: integer, message: string, speakerID: integer, volumeLevel: integer): HookReturn
---@alias hooks.EventSound fun(soundType: integer, position: Vector, volume: HookFloat, pitch: HookFloat): HookReturn
---@alias hooks.EventUpdateItemInfo fun(item: Item): HookReturn
---@alias hooks.EventUpdatePlayerFinance fun(player: Player): HookReturn
---@alias hooks.EventUpdatePlayer fun(player: Player): HookReturn
---@alias hooks.EventUpdateVehicle fun(vehicle: Vehicle, updateType: integer, partID: integer, position: Vector, normal: Vector): HookReturn
---@alias hooks.GrenadeExplode fun(grenade: Item): HookReturn
---@alias hooks.HumanCollisionVehicle fun(human: Human, vehicle: Vehicle): HookReturn
---@alias hooks.HumanCreate fun(position: Vector, rotation: RotMatrix, player: Player): HookReturn	
---@alias hooks.HumanDamage fun(human: Human, bone: integer, damage: integer): HookReturn
---@alias hooks.HumanDelete fun(human: Human): HookReturn
---@alias hooks.HumanLimbInverseKinematics fun(human: Human, trunkBoneID: integer, branchBoneID: integer, destination: Vector, destinationAxis: RotMatrix, unk_vecA: Vector, unk_a: HookFloat, rotation: HookFloat, strength: HookFloat, unk_vecB: Vector, unk_vecC: Vector, flags: HookInteger): HookReturn
---@alias hooks.InterruptSignal fun(): HookNoOverride
---@alias hooks.ItemComputerInput fun(computer: Item, character: integer): HookReturn
---@alias hooks.ItemCreate fun(type: ItemType, position: Vector, rotation: RotMatrix): HookReturn
---@alias hooks.ItemDelete fun(item: Item): HookReturn
---@alias hooks.ItemLink fun(item: Item, childItem?: Item, parentHuman?: Human, slot: integer): HookReturn
---@alias hooks.LineIntersectHuman fun(human: Human, posA: Vector, posB: Vector): HookReturn
---@alias hooks.LogicCoop fun(): HookReturn
---@alias hooks.LogicRace fun(): HookReturn
---@alias hooks.LogicRound fun(): HookReturn
---@alias hooks.LogicTerminator fun(): HookReturn
---@alias hooks.LogicVersus fun(): HookReturn
---@alias hooks.LogicWorld fun(): HookReturn
---@alias hooks.Logic fun(): HookReturn
---@alias hooks.PacketBuilding fun(connection: Connection): HookNoOverride
---@alias hooks.PhysicsBullets fun(): HookReturn
---@alias hooks.Physics fun(): HookReturn
---@alias hooks.PhysicsRigidBodies fun(): HookReturn
---@alias hooks.PlayerAI fun(bot: Player): HookReturn
---@alias hooks.PlayerActions fun(player: Player): HookReturn
---@alias hooks.PlayerChat fun(player: Player, message: string): HookReturn
---@alias hooks.PlayerCreate fun(): HookReturn
---@alias hooks.PlayerDeathTax fun(player: Player): HookReturn
---@alias hooks.PlayerDelete fun(player: Player): HookReturn
---@alias hooks.PlayerGiveWantedLevel fun(player: Player, victim: Player, basePoints: HookInteger): HookReturn
---@alias hooks.PostAccountDeathTax fun(account: Account): HookNoOverride
---@alias hooks.PostAccountTicket fun(account?: Account): HookNoOverride
---@alias hooks.PostAccountsSave fun(): HookNoOverride
---@alias hooks.PostAreaCreateBlock fun(blockX: integer, blockY: integer, blockZ: integer, flags: integer): HookNoOverride
---@alias hooks.PostAreaDeleteBlock fun(blockX: integer, blockY: integer, blockZ: integer): HookNoOverride
---@alias hooks.PostBulletCreate fun(bullet: Bullet): HookNoOverride
---@alias hooks.PostCalculateEarShots fun(connection: Connection, player: Player): HookNoOverride
---@alias hooks.PostEconomyCarMarket fun(): HookNoOverride
---@alias hooks.PostEventBullet fun(type: integer, position: Vector, velocity: Vector, item: Item): HookNoOverride
---@alias hooks.PostEventBulletHit fun(hitType: integer, position: Vector, normal: Vector): HookNoOverride
---@alias hooks.PostEventMessage fun(speakerType: integer, message: string, speakerID: integer, volumeLevel: integer): HookNoOverride
---@alias hooks.PostEventSound fun(soundType: integer, position: Vector, volume: number, pitch: number): HookNoOverride
---@alias hooks.PostEventUpdateItemInfo fun(item: Item): HookNoOverride
---@alias hooks.PostEventUpdatePlayerFinance fun(player: Player): HookNoOverride
---@alias hooks.PostEventUpdatePlayer fun(player: Player): HookNoOverride
---@alias hooks.PostEventUpdateVehicle fun(vehicle: Vehicle, updateType: integer, partID: integer, position: Vector, normal: Vector): HookNoOverride
---@alias hooks.PostGrenadeExplode fun(grenade: Item): HookNoOverride
---@alias hooks.PostHumanCollisionVehicle fun(human: Human, vehicle: Vehicle): HookNoOverride
---@alias hooks.PostHumanCreate fun(human: Human): HookNoOverride	
---@alias hooks.PostHumanDamage fun(human: Human, bone: integer, damage: integer): HookNoOverride
---@alias hooks.PostHumanDelete fun(human: Human): HookNoOverride
---@alias hooks.PostHumanLimbInverseKinematics fun(human: Human, trunkBoneID: integer, branchBoneID: integer, destination: Vector, destinationAxis: RotMatrix, unk_vecA: Vector, unk_a: number, rotation: number, strength: number, unk_vecB: Vector, unk_vecC: Vector, flags: integer): HookReturn
---@alias hooks.PostInterruptSignal fun(): HookNoOverride
---@alias hooks.PostItemComputerInput fun(computer: Item, character: integer): HookNoOverride
---@alias hooks.PostItemCreate fun(item: Item): HookNoOverride
---@alias hooks.PostItemDelete fun(item: Item): HookNoOverride
---@alias hooks.PostItemLink fun(item: Item, childItem?: Item, parentHuman?: Human, slot: integer, worked: boolean): HookNoOverride
---@alias hooks.PostLevelCreate fun(): HookNoOverride
---@alias hooks.PostLineIntersectHuman fun(human: Human, posA: Vector, posB: Vector): HookNoOverride
---@alias hooks.PostLogicCoop fun(): HookNoOverride
---@alias hooks.PostLogicRace fun(): HookNoOverride
---@alias hooks.PostLogicRound fun(): HookNoOverride
---@alias hooks.PostLogicTerminator fun(): HookNoOverride
---@alias hooks.PostLogicVersus fun(): HookNoOverride
---@alias hooks.PostLogicWorld fun(): HookNoOverride
---@alias hooks.PostLogic fun(): HookNoOverride
---@alias hooks.PostPacketBuilding fun(connection: Connection): HookNoOverride
---@alias hooks.PostPhysicsBullets fun(): HookNoOverride
---@alias hooks.PostPhysics fun(): HookNoOverride
---@alias hooks.PostPhysicsRigidBodies fun(): HookNoOverride
---@alias hooks.PostPlayerAI fun(bot: Player): HookNoOverride
---@alias hooks.PostPlayerActions fun(player: Player): HookNoOverride
---@alias hooks.PostPlayerChat fun(player: Player, message: string): HookNoOverride
---@alias hooks.PostPlayerCreate fun(player: Player): HookNoOverride
---@alias hooks.PostPlayerDeathTax fun(player: Player): HookNoOverride
---@alias hooks.PostPlayerDelete fun(player: Player): HookNoOverride
---@alias hooks.PostPlayerGiveWantedLevel fun(player: Player, victim: Player, basePoints: integer): HookNoOverride
---@alias hooks.PostResetGame fun(reason: integer): HookNoOverride
---@alias hooks.PostSendConnectResponse fun(address: string, port: integer, data: SendConnectResponseData): HookNoOverride
---@alias hooks.PostSendPacket fun(address: string, port: integer, packetType: integer, packetSize: integer): HookNoOverride
---@alias hooks.PostServerReceive fun(): HookNoOverride
---@alias hooks.PostServerSend fun(): HookNoOverride
---@alias hooks.PostTrafficCarAI fun(): HookNoOverride
---@alias hooks.PostTrafficCarDestination fun(): HookNoOverride
---@alias hooks.PostTrafficSimulation fun(): HookNoOverride
---@alias hooks.PostVehicleCreate fun(vehicle: Vehicle): HookNoOverride
---@alias hooks.PostVehicleDamage fun(vehicle: Vehicle, damage: integer): HookNoOverride
---@alias hooks.PostVehicleDelete fun(vehicle: Vehicle): HookNoOverride
---@alias hooks.ResetGame fun(reason: integer): HookReturn
---@alias hooks.SendConnectResponse fun(address: string, port: integer, data: SendConnectResponseData): HookReturn
---@alias hooks.SendPacket fun(address: string, port: integer, packetType: integer, packetSize: integer): HookReturn
---@alias hooks.ServerReceive fun(): HookReturn
---@alias hooks.ServerSend fun(): HookReturn
---@alias hooks.TrafficCarAI fun(trafficCar: TrafficCar): HookReturn
---@alias hooks.TrafficCarDestination fun(trafficCar: TrafficCar, a: HookInteger, b: HookInteger, c: HookInteger, d: HookInteger): HookReturn
---@alias hooks.TrafficSimulation fun(): HookReturn
---@alias hooks.VehicleCreate fun(type: VehicleType, position: Vector, rotation: RotMatrix, color: integer): HookReturn
---@alias hooks.VehicleDamage fun(vehicle: Vehicle, damage: integer): HookReturn
---@alias hooks.VehicleDelete fun(vehicle: Vehicle): HookReturn