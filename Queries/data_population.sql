
-- =================================================================  
-- Data Population (DML)  
-- =================================================================  

-- Factories & Warehouses

INSERT INTO automotive_graph.Factories (FactoryID, Name, Location, DailyProductionCapacity) VALUES  
('F-AETHEL', 'Aethelgard Assembly', 'Aethelgard, Veritas', 900),   
('F-KORVAX', 'Korvax Prime Engine Works', 'Korvax, Franconia', 700),  
('F-SOLARA', 'Solara Gigafactory', 'Solara, Orientas', 1500),   
('F-CINDER', 'Cinderfall EV Powertrain', 'Cinderfall, Veritas', 1000),   
('F-NIMBUS', 'Nimbusia Motors', 'Nimbusia, Kaidia', 800);  
  
INSERT INTO automotive_graph.Warehouses (WarehouseID, Name, Location) VALUES  
('W-STARLIGHT', 'Starlight Central Depot', 'Starlight, Veritas'),   
('W-VESPERA', 'Vespera Hub', 'Vespera, Franconia'),  
('W-DRIFTWOOD', 'Driftwood Logistics', 'Driftwood, Orientas'),   
('W-SILKEN', 'Silken Bay Distribution', 'Silken Bay, Kaidia');  
  
INSERT INTO automotive_graph.Ports (PortID, Name, Country, AvgCustomsHours) VALUES   
('PORT-KAEL', 'Port of Kael', 'Orientas', 12),   
('PORT-ELYSIUM', 'Port of Elysium', 'Veritas', 60),   
('PORT-VALEN', 'Port of Valen', 'Franconia', 30),   
('PORT-SERAPH', 'Port of Seraphina', 'Sinope', 40);  
  
INSERT INTO automotive_graph.Vessels (VesselID, Name, TEUCapacity) VALUES   
('V-JUMPER', 'The Void Jumper', 18000),   
('V-CHASER', 'The Sun Chaser', 22000);  
  
-- Car Models & Components

INSERT INTO automotive_graph.CarModels (ModelID, Name, CarType, TrimLevel, BodyStyle, LaunchYear, BaseMSRP) VALUES  
('CM-EQUINOX-LX', 'Equinox EV', 'EV', 'Luxury', 'Sedan', 2024, 75000),   
('CM-EQUINOX-ST', 'Equinox EV', 'EV', 'Standard', 'Sedan', 2024, 65000),  
('CM-GOLIATH-SP', 'Goliath V8', 'Gas', 'Sport', 'Coupe', 2023, 82000),   
('CM-VAGABOND-LX', 'Vagabond', 'Hybrid', 'Luxury', 'SUV', 2024, 78000),  
('CM-VAGABOND-ST', 'Vagabond', 'Hybrid', 'Standard', 'SUV', 2024, 68000),   
('CM-SPARK-ST', 'Spark', 'Gas', 'Standard', 'Hatchback', 2025, 35000);  
  
INSERT INTO automotive_graph.Components (ComponentID, Name) VALUES  
('C-BAT-ARC', 'ArcLight 150kWh Battery'),   
('C-ENG-GOL', 'Goliath V8 Engine'),   
('C-INFO-NEX', 'Nexus Infotainment'),  
('C-HYBRID-SYN', 'Synergy Hybrid Powertrain'),   
('C-MOTOR-EMO', 'E-Motion Dual Drive'),   
('C-ROOF-SKY', 'SkyView Panoramic Roof'),  
('C-ENG-SPK', 'Spark 1.5T Engine');  
  
-- Parts (Finished & Raw)

INSERT INTO automotive_graph.Parts (PartID, Name, PartNumber, IsRawMaterial) VALUES  
('P-008', 'ArcCell Battery Unit', 'BAT-ARC-2', false),   
('P-021', 'Nexus Core Chip', 'INF-NEX-2', false),  
('P-035', 'Vortex Turbocharger', 'TURBO-VTX-2', false),   
('P-042', 'E-Motion Stator', 'EM-STAT-2', false),  
('P-101', 'Raw Solarium', 'RAW-SOL-2', true),   
('P-102', 'Raw Crylithium', 'RAW-CRY-1', true),   
('P-105', 'Raw Neodymian', 'RAW-NEO-4', true);  
  
-- Suppliers

INSERT INTO automotive_graph.Suppliers (SupplierID, Name, Tier, Location, RiskScore) VALUES  
('SUP-007', 'Nexus Semiconductors', 1, 'Sylva, Taipia', 0.75),   
('SUP-008', 'Arcane Chips', 1, 'Nova, Cascadia', 0.25),  
('SUP-016', 'Vortex Turbines', 1, 'Stuttgart, Franconia', 0.1),   
('SUP-201', 'Apex Power Systems', 2, 'Ceres, Sinope', 0.45),  
('SUP-302', 'GeoCore Mining', 3, 'Kivu, Congolia', 0.85),   
('SUP-015', 'Heliospan Magnetics', 2, 'Oasis, Cascadia', 0.2),  
('SUP-305', 'Dynamo Materials', 3, 'Perth, Westralia', 0.3);  
  
-- Bill of Materials (Relationships)

INSERT INTO automotive_graph.CarModelComponents VALUES   
('CM-EQUINOX-LX', 'C-BAT-ARC'),   
('CM-EQUINOX-LX', 'C-MOTOR-EMO'),   
('CM-EQUINOX-LX', 'C-ROOF-SKY'),  
('CM-VAGABOND-LX', 'C-HYBRID-SYN'),   
('CM-VAGABOND-LX', 'C-ROOF-SKY'),   
('CM-GOLIATH-SP', 'C-ENG-GOL'),   
('CM-SPARK-ST', 'C-ENG-SPK');  
  
INSERT INTO automotive_graph.ComponentParts VALUES   
('C-BAT-ARC', 'P-008', 9000),   
('C-HYBRID-SYN', 'P-042', 1),   
('C-HYBRID-SYN', 'P-035', 1),  
('C-MOTOR-EMO', 'P-042', 2),   
('C-ENG-GOL', 'P-035', 2),   
('C-ENG-SPK', 'P-035', 1);  
  
INSERT INTO automotive_graph.PartComposition VALUES   
('P-008', 'P-102', 0.5),   
('P-042', 'P-105', 2.1);  
  
INSERT INTO automotive_graph.SupplierSupplies VALUES   
('SUP-201', 'P-008', 40, 12.50),   
('SUP-302', 'P-102', 80, 5.50),   
('SUP-015', 'P-042', 30, 800),  
('SUP-305', 'P-105', 60, 45),   
('SUP-016', 'P-035', 14, 1200);  
  
-- Factory Assembly

INSERT INTO automotive_graph.FactoryAssembly VALUES   
('F-SOLARA', 'CM-EQUINOX-LX'),   
('F-SOLARA', 'CM-EQUINOX-ST'),  
('F-NIMBUS', 'CM-VAGABOND-LX'),   
('F-NIMBUS', 'CM-VAGABOND-ST'),   
('F-KORVAX', 'CM-GOLIATH-SP'),   
('F-AETHEL', 'CM-SPARK-ST');  
  
-- Initial Inventory and Shipments

INSERT INTO automotive_graph.WarehouseInventory (WarehouseID, PartID, Quantity, LastRestockDate) VALUES  
('W-STARLIGHT', 'P-035', 800, '2025-06-05'),   
('W-SILKEN', 'P-035', 450, '2025-05-10'),  
('W-DRIFTWOOD', 'P-042', 2000, '2025-05-20'),   
('W-STARLIGHT', 'P-021', 5000, '2025-06-01');  
  
INSERT INTO automotive_graph.Shipments (ShipmentID, Status, ETADate) VALUES  
('SH-004', 'In Transit', '2025-06-20'),   
('SH-005', 'At Port', '2025-06-15'),  
('SH-006', 'In Transit', '2025-07-05'),   
('SH-007', 'In Transit', '2025-07-10');  
  
INSERT INTO automotive_graph.ShipmentLogistics (ShipmentID, VesselID) VALUES   
('SH-004', 'V-JUMPER'),   
('SH-005', 'V-CHASER'),   
('SH-006', 'V-JUMPER'),   
('SH-007', 'V-CHASER');  
  
INSERT INTO automotive_graph.ShipmentContents (ShipmentID, PartID, Quantity) VALUES  
('SH-004', 'P-035', 500),   
('SH-005', 'P-035', 700),   
('SH-006', 'P-042', 1500),   
('SH-007', 'P-035', 1200);

INSERT INTO automotive_graph.ShippingRoutes (VesselID, PortID, Sequence, ETADate, CO2KgPerTEU) VALUES 
('V-CHASER', 'PORT-SERAPH', 1, '2025-06-15', 120.5),
('V-CHASER', 'PORT-ELYSIUM', 2, '2025-06-25', 95.2),
('V-JUMPER', 'PORT-KAEL', 1, '2025-06-18', 110.0),
('V-JUMPER', 'PORT-VALEN', 2, '2025-06-28', 85.0);
