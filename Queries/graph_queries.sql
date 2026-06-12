
-- Use Case 1: Find the blast radius using native GQL

GRAPH automotive_graph.SupplyChainGraph  
MATCH  (factory:Factories)-[:FactoryAssembly]->(car_model:CarModels)-[:CarModelComponents]->(component:Components)-[:ComponentParts]->(part:Parts),  (part)<-[:ShipmentContents]-(shipment:Shipments)-[:ShipmentLogistics]->(vessel:Vessels)-[:ShippingRoutes]->(port:Ports)  
WHERE port.Name = 'Port of Seraphina' AND shipment.Status IN ('In Transit', 'At Port')  
RETURN DISTINCT
  factory.Name AS ImpactedFactory,  
  car_model.Name AS HaltedCarModel,  
  car_model.BodyStyle AS BodyStyle,  
  car_model.TrimLevel AS TrimLevel,  
  (factory.DailyProductionCapacity * car_model.BaseMSRP) AS DailyRevenueAtRisk  
ORDER BY DailyRevenueAtRisk DESC;


-- Use Case 2: Trace a defective raw material using native GQL

GRAPH automotive_graph.SupplyChainGraph  
MATCH   
  (supplier:Suppliers)-[:SupplierSupplies]->(raw_material:Parts),  (raw_material)<-[:PartComposition]-(finished_part:Parts)<-[:ComponentParts]-(component:Components)<-[:CarModelComponents]-(car_model:CarModels)  
WHERE supplier.Name = 'Dynamo Materials' AND raw_material.Name = 'Raw Neodymian'  
RETURN DISTINCT  
  car_model.Name AS CarModelName,  
  car_model.BodyStyle AS BodyStyle,  
  car_model.TrimLevel AS TrimLevel,  
  component.Name AS ComponentName,  
  finished_part.Name AS FinishedPartName,  
  raw_material.Name AS RawMaterialName;


-- Use Case 3: Find and rank solutions to a parts shortfall using GQL inside SQL
  
-- Option 1: Find available inventory in other warehouses

SELECT  
  'Warehouse Transfer' AS MitigationType,  
  SourceName,  
  Quantity,  
  TimeToDeliverDays  
FROM GRAPH_TABLE(  
  automotive_graph.SupplyChainGraph  
  MATCH (w:Warehouses)-[wi:WarehouseInventory]->(p:Parts {Name: 'Vortex Turbocharger'})  
  WHERE w.Name != 'Vespera Hub'  
  RETURN  
    w.Name AS SourceName,  
    wi.Quantity AS Quantity,  
    CASE w.Location  
      WHEN 'Starlight, Veritas' THEN 3  
      WHEN 'Silken Bay, Kaidia' THEN 5  
      ELSE 7  
    END AS TimeToDeliverDays  
)  
  
UNION ALL  
  
-- Option 2: Find in-transit shipments that can be rerouted

SELECT  
  'Reroute Shipment' AS MitigationType,  
  SourceName,  
  Quantity,  
  TimeToDeliverDays  
FROM GRAPH_TABLE(  
  automotive_graph.SupplyChainGraph  
  MATCH (s:Shipments)-[sc:ShipmentContents]->(p:Parts {Name: 'Vortex Turbocharger'})  
  WHERE s.Status = 'In Transit'  
  RETURN  
    s.ShipmentID AS SourceName,  
    sc.Quantity AS Quantity,  
    DATE_DIFF(s.ETADate, CURRENT_DATE(), DAY) + 2 AS TimeToDeliverDays  
)  
  
UNION ALL  
  
-- Option 3: Find alternative suppliers for a rush order

SELECT  
  'Expedited Purchase' AS MitigationType,  
  SourceName,  
  Quantity,  
  TimeToDeliverDays  
FROM GRAPH_TABLE(  
  automotive_graph.SupplyChainGraph  
  MATCH (s:Suppliers)-[ss:SupplierSupplies]->(p:Parts {Name: 'Vortex Turbocharger'})  
  RETURN  
    s.Name AS SourceName,  
    10000 AS Quantity,  
    ss.LeadTimeDays AS TimeToDeliverDays  
)  
ORDER BY TimeToDeliverDays ASC;
