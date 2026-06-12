
-- =================================================================  
-- Schema Definition (DDL) for Automotive Supply Chain Graph in BigQuery  
-- =================================================================  
  
-- Create Dataset with location as US multi region
-- Change the location as per requirement on the basis of regional availability
-- Refer: https://docs.cloud.google.com/bigquery/docs/locations

CREATE SCHEMA IF NOT EXISTS automotive_graph OPTIONS (location = 'US');

  
-- NODE TABLES

CREATE OR REPLACE TABLE automotive_graph.CarModels(
  ModelID STRING NOT NULL,
  Name STRING NOT NULL,
  CarType STRING,
  TrimLevel STRING,
  BodyStyle STRING,
  LaunchYear INT64,
  BaseMSRP NUMERIC,
  PRIMARY KEY(ModelID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Components(
  ComponentID STRING NOT NULL, Name STRING NOT NULL, Description STRING,
  PRIMARY KEY(ComponentID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Parts(
  PartID STRING NOT NULL,
  Name STRING NOT NULL,
  PartNumber STRING,
  IsRawMaterial BOOL,
  PRIMARY KEY(PartID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Factories(
  FactoryID STRING NOT NULL,
  Name STRING NOT NULL,
  Location STRING,
  DailyProductionCapacity INT64,
  PRIMARY KEY(FactoryID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Warehouses(
  WarehouseID STRING NOT NULL, Name STRING NOT NULL, Location STRING,
  PRIMARY KEY(WarehouseID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Suppliers(
  SupplierID STRING NOT NULL,
  Name STRING NOT NULL,
  Tier INT64,
  Location STRING,
  RiskScore FLOAT64,
  PRIMARY KEY(SupplierID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Ports(
  PortID STRING NOT NULL,
  Name STRING NOT NULL,
  Country STRING,
  AvgCustomsHours INT64,
  PRIMARY KEY(PortID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Vessels(
  VesselID STRING NOT NULL, Name STRING NOT NULL, TEUCapacity INT64,
  PRIMARY KEY(VesselID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.Shipments(
  ShipmentID STRING NOT NULL, Status STRING, ETADate DATE,
  PRIMARY KEY(ShipmentID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.LegalEntities(
  EntityID STRING NOT NULL, Name STRING NOT NULL, Region STRING,
  PRIMARY KEY(EntityID) NOT ENFORCED);  
  
-- EDGE TABLES (with NOT ENFORCED foreign keys to map relationships structurally)
  
CREATE OR REPLACE TABLE automotive_graph.CarModelComponents(
  ModelID STRING NOT NULL, ComponentID STRING NOT NULL,
  PRIMARY KEY(ModelID, ComponentID) NOT ENFORCED,
  FOREIGN KEY(ModelID)
  REFERENCES automotive_graph.CarModels(ModelID)
  NOT ENFORCED,
  FOREIGN KEY(ComponentID)
  REFERENCES automotive_graph.Components(ComponentID)
  NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.ComponentParts(
  ComponentID STRING NOT NULL, PartID STRING NOT NULL, Quantity NUMERIC,
  PRIMARY KEY(ComponentID, PartID) NOT ENFORCED,
  FOREIGN KEY(ComponentID)
  REFERENCES automotive_graph.Components(ComponentID)
  NOT ENFORCED,
  FOREIGN KEY(PartID) REFERENCES automotive_graph.Parts(PartID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.PartComposition(
  FinishedPartID STRING NOT NULL,
  RawMaterialPartID STRING NOT NULL,
  Quantity NUMERIC,
  PRIMARY KEY(FinishedPartID, RawMaterialPartID) NOT ENFORCED,
  FOREIGN KEY(FinishedPartID)
  REFERENCES automotive_graph.Parts(PartID)
  NOT ENFORCED,
  FOREIGN KEY(RawMaterialPartID)
  REFERENCES automotive_graph.Parts(PartID)
  NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.SupplierSupplies(
  SupplierID STRING NOT NULL,
  PartID STRING NOT NULL,
  LeadTimeDays INT64,
  Price NUMERIC,
  PRIMARY KEY(SupplierID, PartID) NOT ENFORCED,
  FOREIGN KEY(SupplierID)
  REFERENCES automotive_graph.Suppliers(SupplierID)
  NOT ENFORCED,
  FOREIGN KEY(PartID) REFERENCES automotive_graph.Parts(PartID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.FactoryAssembly(
  FactoryID STRING NOT NULL, ModelID STRING NOT NULL,
  PRIMARY KEY(FactoryID, ModelID) NOT ENFORCED,
  FOREIGN KEY(FactoryID)
  REFERENCES automotive_graph.Factories(FactoryID)
  NOT ENFORCED,
  FOREIGN KEY(ModelID)
  REFERENCES automotive_graph.CarModels(ModelID)
  NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.WarehouseInventory(
  WarehouseID STRING NOT NULL,
  PartID STRING NOT NULL,
  Quantity NUMERIC,
  LastRestockDate DATE,
  PRIMARY KEY(WarehouseID, PartID) NOT ENFORCED,
  FOREIGN KEY(WarehouseID)
  REFERENCES automotive_graph.Warehouses(WarehouseID)
  NOT ENFORCED,
  FOREIGN KEY(PartID) REFERENCES automotive_graph.Parts(PartID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.ShipmentContents(
  ShipmentID STRING NOT NULL, PartID STRING NOT NULL, Quantity NUMERIC,
  PRIMARY KEY(ShipmentID, PartID) NOT ENFORCED,
  FOREIGN KEY(ShipmentID)
  REFERENCES automotive_graph.Shipments(ShipmentID)
  NOT ENFORCED,
  FOREIGN KEY(PartID) REFERENCES automotive_graph.Parts(PartID) NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.ShipmentLogistics(
  ShipmentID STRING NOT NULL, VesselID STRING NOT NULL,
  PRIMARY KEY(ShipmentID) NOT ENFORCED,
  FOREIGN KEY(ShipmentID)
  REFERENCES automotive_graph.Shipments(ShipmentID)
  NOT ENFORCED,
  FOREIGN KEY(VesselID)
  REFERENCES automotive_graph.Vessels(VesselID)
  NOT ENFORCED);

CREATE OR REPLACE TABLE automotive_graph.ShippingRoutes(
  VesselID STRING NOT NULL,
  PortID STRING NOT NULL,
  Sequence INT64 NOT NULL,
  ETADate DATE,
  CO2KgPerTEU FLOAT64,
  PRIMARY KEY(VesselID, PortID, Sequence) NOT ENFORCED,
  FOREIGN KEY(VesselID)
  REFERENCES automotive_graph.Vessels(VesselID)
  NOT ENFORCED,
  FOREIGN KEY(PortID) REFERENCES automotive_graph.Ports(PortID) NOT ENFORCED);  
  
-- =================================================================  
-- PROPERTY GRAPH COMPILATION  
-- =================================================================
  
CREATE OR REPLACE PROPERTY GRAPH automotive_graph.SupplyChainGraph
NODE TABLES(
  automotive_graph.CarModels,
  automotive_graph.Components,
  automotive_graph.Parts,
  automotive_graph.Factories,
  automotive_graph.Warehouses,
  automotive_graph.Suppliers,
  automotive_graph.Ports,
  automotive_graph.Vessels,
  automotive_graph.Shipments
  )
EDGE TABLES(
  automotive_graph.CarModelComponents
    SOURCE KEY(ModelID) REFERENCES CarModels(ModelID)
    DESTINATION KEY(ComponentID) REFERENCES Components(ComponentID)
    LABEL CarModelComponents,
  automotive_graph.ComponentParts
    SOURCE KEY(ComponentID) REFERENCES Components(ComponentID)
    DESTINATION KEY(PartID) REFERENCES Parts(PartID)
    LABEL ComponentParts,
  automotive_graph.PartComposition
    SOURCE KEY(FinishedPartID) REFERENCES Parts(PartID)
    DESTINATION KEY(RawMaterialPartID) REFERENCES Parts(PartID)
    LABEL PartComposition,
  automotive_graph.SupplierSupplies
    SOURCE KEY(SupplierID) REFERENCES Suppliers(SupplierID)
    DESTINATION KEY(PartID) REFERENCES Parts(PartID)
    LABEL SupplierSupplies,
  automotive_graph.FactoryAssembly
    SOURCE KEY(FactoryID) REFERENCES Factories(FactoryID)
    DESTINATION KEY(ModelID) REFERENCES CarModels(ModelID)
    LABEL FactoryAssembly,
  automotive_graph.WarehouseInventory
    SOURCE KEY(WarehouseID) REFERENCES Warehouses(WarehouseID)
    DESTINATION KEY(PartID) REFERENCES Parts(PartID)
    LABEL WarehouseInventory,
  automotive_graph.ShipmentContents
    SOURCE KEY(ShipmentID) REFERENCES Shipments(ShipmentID)
    DESTINATION KEY(PartID) REFERENCES Parts(PartID)
    LABEL ShipmentContents,
  automotive_graph.ShipmentLogistics
    SOURCE KEY(ShipmentID) REFERENCES Shipments(ShipmentID)
    DESTINATION KEY(VesselID) REFERENCES Vessels(VesselID)
    LABEL ShipmentLogistics,
  automotive_graph.ShippingRoutes
    SOURCE KEY(VesselID) REFERENCES Vessels(VesselID)
    DESTINATION KEY(PortID) REFERENCES Ports(PortID)
    LABEL ShippingRoutes
);
