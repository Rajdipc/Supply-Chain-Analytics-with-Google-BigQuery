
-- Insert a new Part node row

INSERT INTO automotive_graph.Parts (PartID, Name, PartNumber, IsRawMaterial)  
VALUES ('P-050', 'Warp Core', 'WRP-CORE-1', false);  
  
-- Insert a new Supplier node row

INSERT INTO automotive_graph.Suppliers (SupplierID, Name, Tier, Location, RiskScore)  
VALUES ('SUP-025', 'Continuum Drives', 1, 'Geneva, Helvetia', 0.05);  
  
-- Insert the edge row connecting them

INSERT INTO automotive_graph.SupplierSupplies (SupplierID, PartID, LeadTimeDays, Price)  
VALUES ('SUP-025', 'P-050', 25, 50000);


-- Update the RiskScore for a specific supplier

UPDATE automotive_graph.Suppliers  
SET RiskScore = 0.9  
WHERE SupplierID = 'SUP-007';


BEGIN TRANSACTION;

  -- Step 1: Delete edges connecting factories to the discontinued model

  DELETE FROM automotive_graph.FactoryAssembly  
  WHERE ModelID = 'CM-GOLIATH-SP';  
  
  -- Step 2: Delete edges connecting components to the discontinued model

  DELETE FROM automotive_graph.CarModelComponents  
  WHERE ModelID = 'CM-GOLIATH-SP';  
  
  -- Step 3: Delete the car model node itself

  DELETE FROM automotive_graph.CarModels  
  WHERE ModelID = 'CM-GOLIATH-SP';  
COMMIT TRANSACTION;
