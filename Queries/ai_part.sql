
-- Step 1: Add a Description column to the Parts table to store unstructured engineering text

ALTER TABLE automotive_graph.Parts ADD COLUMN Description STRING;

-- Step 2: Populate unstructured specifications for our parts

UPDATE automotive_graph.Parts  
SET Description = 'High-temperature, heavy-duty alloy forced-induction exhaust-driven turbine assembly.'  
WHERE PartID = 'P-035'; -- Vortex Turbocharger  
  
UPDATE automotive_graph.Parts  
SET Description = 'High-capacity cobalt-free rechargeable lithium battery cell for traction storage.'  
WHERE PartID = 'P-008'; -- ArcCell Battery Unit  
  
UPDATE automotive_graph.Parts  
SET Description = 'High-torque permanent magnet copper stator and rotor core for dual-drive powertrains.'  
WHERE PartID = 'P-042'; -- E-Motion Stator

-- Step 3: Add an autonomous embedding column. BigQuery will automatically 
-- call Vertex AI and keep the embeddings in sync with any incoming DML updates.
-- Note: 'us.vertex_ai_connection' represents an external cloud resource (remote connection) 
-- that must be created in BigQuery prior to running this script. The connection's 
-- corresponding service account must be granted the 'Vertex AI User' role (roles/aiplatform.user) 
-- in the Google Cloud Console to authorize calls to the embedding endpoint.

ALTER TABLE automotive_graph.Parts
ADD COLUMN description_embedding STRUCT<result ARRAY<FLOAT64>, status STRING>
GENERATED ALWAYS AS (
  AI.EMBED(
    Description,
    connection_id => 'us.vertex_ai_connection',
    endpoint => 'text-embedding-005'
  )
) STORED OPTIONS (asynchronous = TRUE);

-- Step 4: Create an IVF Vector Index to enable fast, sub-second Approximate Nearest Neighbor (ANN) search
-- This step will give error because BigQuery requires a minimum of 5,000 rows to create an IVF vector index and the table currently has 8 rows as per the data generated in earlier sections. Hence, skip the next step for this post

CREATE OR REPLACE VECTOR INDEX automotive_graph.parts_vector_index
ON automotive_graph.Parts(description_embedding)
OPTIONS(distance_type = 'COSINE', index_type = 'IVF');


-- Hybrid Semantic Vector Search + GQL Blast Radius

WITH semantically_matched_parts AS (
  SELECT 
    base.PartID AS TargetPartID,
    base.Name AS PartName,
    distance
  FROM AI.SEARCH(
    TABLE automotive_graph.Parts,
    'Description',
    'high-temperature forced-induction systems',
    top_k => 2
  )
)
SELECT 
  smp.PartName,
  smp.distance AS SemanticDistance,
  gt.ImpactedFactory,
  gt.HaltedCarModel,
  gt.DailyRevenueAtRisk
FROM semantically_matched_parts smp
JOIN GRAPH_TABLE(
  automotive_graph.SupplyChainGraph
  MATCH (factory:Factories)-[:FactoryAssembly]->(car_model:CarModels)-[:CarModelComponents]->(component:Components)-[:ComponentParts]->(part:Parts)
  RETURN 
    part.PartID AS PartID,
    factory.Name AS ImpactedFactory,
    car_model.Name AS HaltedCarModel,
    (factory.DailyProductionCapacity * car_model.BaseMSRP) AS DailyRevenueAtRisk
) gt ON smp.TargetPartID = gt.PartID
ORDER BY smp.distance ASC, gt.DailyRevenueAtRisk DESC;


-- Step 1: Create a view that extracts graph-structured metrics as training features

CREATE OR REPLACE VIEW automotive_graph.ComponentMLFeatures AS (
  SELECT 
    ComponentID,
    ComponentName,
    -- Feature 1: Supplier redundancy count derived from the graph topology
    COUNT(DISTINCT supplier_id) AS supplier_redundancy_count,
    -- Feature 2: Mean risk score of the component's immediate suppliers
    COALESCE(AVG(supplier_risk), 0.5) AS avg_supplier_risk,
    -- Feature 3: Number of raw materials required at the bottom of the BOM
    COUNT(DISTINCT raw_material_id) AS raw_material_dependency_depth,
    -- Label: Simulate production halt occurrence (1 = High Risk, 0 = Safe)
    IF(COALESCE(AVG(supplier_risk), 0.5) > 0.6 OR COUNT(DISTINCT supplier_id) = 1, 1, 0) AS production_halt_label
  FROM GRAPH_TABLE(
    automotive_graph.SupplyChainGraph
    MATCH 
      (c:Components)-[:ComponentParts]->(p:Parts)
      OPTIONAL MATCH (s:Suppliers)-[:SupplierSupplies]->(p)
      OPTIONAL MATCH (p)-[:PartComposition]->(raw:Parts)
    RETURN 
      c.ComponentID AS ComponentID,
      c.Name AS ComponentName,
      s.SupplierID AS supplier_id,
      s.RiskScore AS supplier_risk,
      raw.PartID AS raw_material_id
  )
  GROUP BY ComponentID, ComponentName
);

-- Step 2: Train a Boosted Tree Classifier inside BigQuery ML using our graph features

CREATE OR REPLACE MODEL automotive_graph.halt_prediction_model
OPTIONS(
  model_type = 'boosted_tree_classifier',
  input_label_cols = ['production_halt_label'],
  booster_type = 'GBTREE',
  num_parallel_tree = 5,
  max_iterations = 20,
  -- Enable automatic data splitting for model validation and to prevent overfitting
  data_split_method = 'AUTO_SPLIT',
  data_split_eval_fraction = 0.2
) AS
SELECT 
  supplier_redundancy_count,
  avg_supplier_risk,
  raw_material_dependency_depth,
  production_halt_label
FROM automotive_graph.ComponentMLFeatures;


SELECT 
  ComponentID,
  ComponentName,
  predicted_production_halt_label AS Predicted_Halt_Risk,
  -- Safely extract the exact probability of a halt (label 1) from the predictions struct
  ROUND((SELECT prob FROM UNNEST(predicted_production_halt_label_probs) WHERE label = 1), 4) AS Halt_Risk_Probability,
  supplier_redundancy_count AS Supplier_Redundancy,
  ROUND(avg_supplier_risk, 2) AS Avg_Supplier_Risk,
  raw_material_dependency_depth AS Raw_Material_Depth
FROM ML.PREDICT(
  MODEL automotive_graph.halt_prediction_model,
  (SELECT * FROM automotive_graph.ComponentMLFeatures)
)
ORDER BY Halt_Risk_Probability DESC;


