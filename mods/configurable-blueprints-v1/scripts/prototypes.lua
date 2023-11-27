return {
--abstract                   , -- EntityWithOwnerPrototype                
--'accumulator'              , --   AccumulatorPrototype                  (unconfigurable)
--'artillery-turret'         , --   ArtilleryTurretPrototype              (unconfigurable)
--'beacon'                   , --   BeaconPrototype                       (unconfigurable)
--'boiler'                   , --   BoilerPrototype                       (unconfigurable)
--'burner-generator'         , --   BurnerGeneratorPrototype              (unconfigurable)
--'character'                , --   CharacterPrototype                    (not a building)
--abstract                   , --   CombinatorPrototype                   
  'arithmetic-combinator'    , --     ArithmeticCombinatorPrototype       
  'decider-combinator'       , --     DeciderCombinatorPrototype          
  'constant-combinator'      , --   ConstantCombinatorPrototype           
--'container'                , --   ContainerPrototype                    (can hold items)
--'logistic-container'       , --     LogisticContainerPrototype          (can hold items)
--'infinity-container'       , --       InfinityContainerPrototype        (can hold items)
--abstract                   , --   CraftingMachinePrototype              
  'assembling-machine'       , --     AssemblingMachinePrototype          
  'rocket-silo'              , --       RocketSiloPrototype               
--'furnace'                  , --     FurnacePrototype                    (unconfigurable)
  'electric-energy-interface', --   ElectricEnergyInterfacePrototype      
--'electric-pole'            , --   ElectricPolePrototype                 (active ignored)
--'unit-spawner'             , --   EnemySpawnerPrototype                 (unconfigurable)
--abstract                   , --   FlyingRobotPrototype                  
--'combat-robot'             , --     CombatRobotPrototype                (not a building)
--abstract                   , --     RobotWithLogisticInterfacePrototype 
--'construction-robot'       , --       ConstructionRobotPrototype        (not a building)
--'logistic-robot'           , --       LogisticRobotPrototype            (not a building)
--'gate'                     , --   GatePrototype                         (hinders biters)
--'generator'                , --   GeneratorPrototype                    (unconfigurable)
  'heat-interface'           , --   HeatInterfacePrototype                
--'heat-pipe'                , --   HeatPipePrototype                     (unconfigurable)
  'inserter'                 , --   InserterPrototype                     
--'lab'                      , --   LabPrototype                          (unconfigurable)
--'lamp'                     , --   LampPrototype                         (active ignored)
--'land-mine'                , --   LandMinePrototype                     (unconfigurable)
--'linked-container'         , --   LinkedContainerPrototype              (can hold items)
--'market'                   , --   MarketPrototype                       (active ignored)
--'mining-drill'             , --   MiningDrillPrototype                  (unconfigurable)
--'offshore-pump'            , --   OffshorePumpPrototype                 (unconfigurable)
--'pipe'                     , --   PipePrototype                         (unconfigurable)
  'infinity-pipe'            , --     InfinityPipePrototype               
--'pipe-to-ground'           , --   PipeToGroundPrototype                 (unconfigurable)
--'player-port'              , --   PlayerPortPrototype                   (unconfigurable)
--'power-switch'             , --   PowerSwitchPrototype                  (active ignored)
  'programmable-speaker'     , --   ProgrammableSpeakerPrototype          
--'pump'                     , --   PumpPrototype                         (unconfigurable)
--'radar'                    , --   RadarPrototype                        (unconfigurable)
--abstract                   , --   RailPrototype                         
--'curved-rail'              , --     CurvedRailPrototype                 (unconfigurable)
--'straight-rail'            , --     StraightRailPrototype               (unconfigurable)
--abstract                   , --   RailSignalBasePrototype               
--'rail-chain-signal'        , --     RailChainSignalPrototype            (unconfigurable)
--'rail-signal'              , --     RailSignalPrototype                 (unconfigurable)
--'reactor'                  , --   ReactorPrototype                      (unconfigurable)
--'roboport'                 , --   RoboportPrototype                     (unconfigurable)
--'simple-entity-with-owner' , --   SimpleEntityWithOwnerPrototype        (unconfigurable)
--'simple-entity-with-force' , --     SimpleEntityWithForcePrototype      (unconfigurable)
--'solar-panel'              , --   SolarPanelPrototype                   (unconfigurable)
--'storage-tank'             , --   StorageTankPrototype                  (unconfigurable)
  'train-stop'               , --   TrainStopPrototype                    
--abstract                   , --   TransportBeltConnectablePrototype     
--'linked-belt'              , --     LinkedBeltPrototype                 (unconfigurable)
--abstract                   , --     LoaderPrototype                     
  'loader-1x1'               , --       Loader1x1Prototype                
  'loader'                   , --       Loader1x2Prototype                
  'splitter'                 , --     SplitterPrototype                   
--'transport-belt'           , --     TransportBeltPrototype              (unconfigurable)
--'underground-belt'         , --     UndergroundBeltPrototype            (unconfigurable)
--'turret'                   , --   TurretPrototype                       (hinders biters)
--'ammo-turret'              , --     AmmoTurretPrototype                 (hinders biters)
--'electric-turret'          , --     ElectricTurretPrototype             (hinders biters)
--'fluid-turret'             , --     FluidTurretPrototype                (hinders biters)
--'unit'                     , --   UnitPrototype                         (not a building)
--abstract                   , --   VehiclePrototype                      
--'car'                      , --     CarPrototype                        (not a building)
--'abstract                   , --     RollingStockPrototype               
--'artillery-wagon'          , --       ArtilleryWagonPrototype           (not a building)
--'cargo-wagon'              , --       CargoWagonPrototype               (not a building)
--'fluid-wagon'              , --       FluidWagonPrototype               (not a building)
--'locomotive'               , --       LocomotivePrototype               (not a building)
--'spider-vehicle'           , --     SpiderVehiclePrototype              (not a building)
--'wall'                     , --   WallPrototype                         (hinders biters)
--'fish'                     , --   FishPrototype                         (not a building)
--'simple-entity'            , --   SimpleEntityPrototype                 (unconfigurable)
--'spider-leg'               , --   SpiderLegPrototype                    (not a building)
--'tree'                     , --   TreePrototype                         (unconfigurable)
}
