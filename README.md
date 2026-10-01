# Supply Chain Analytics with Google BigQuery Graph: From Reactive to Predictive

[![Release](https://img.shields.io/badge/Release-v1.0.0-blue.svg)](https://github.com/Rajdipc/Supply-Chain-Analytics-with-Google-BigQuery/releases)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?logo=googlecloud&logoColor=white)](https://cloud.google.com/)
[![BigQuery](https://img.shields.io/badge/Google_BigQuery-669DF6?logo=googlebigquery&logoColor=white)](https://cloud.google.com/bigquery)
[![BigQuery Graph](https://img.shields.io/badge/BigQuery_Graph-ISO_GQL-0F9D58)](https://cloud.google.com/bigquery/docs/graph-overview)
[![BigQuery ML](https://img.shields.io/badge/BigQuery_ML-Boosted_Trees-FBBC04)](https://cloud.google.com/bigquery/docs/bqml-introduction)
[![Vertex AI](https://img.shields.io/badge/Vertex_AI-Vector_Embeddings-EA4335?logo=googlecloud&logoColor=white)](https://cloud.google.com/vertex-ai)
[![Medium](https://img.shields.io/badge/Medium-Article-black?logo=medium&logoColor=white)](https://medium.com/google-cloud/supply-chain-analytics-with-bigquery-graph-from-reactive-to-predictive-3324239edfa3)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

`#BigQueryGraph` &nbsp;•&nbsp; `#BigQuery` &nbsp;•&nbsp; `#GoogleCloud` &nbsp;•&nbsp; `#GQL` &nbsp;•&nbsp; `#SupplyChain` &nbsp;•&nbsp; `#GraphAnalytics` &nbsp;•&nbsp; `#PropertyGraph` &nbsp;•&nbsp; `#BigQueryML` &nbsp;•&nbsp; `#VertexAI` &nbsp;•&nbsp; `#VectorSearch` &nbsp;•&nbsp; `#DigitalTwin` &nbsp;•&nbsp; `#MLOps`

---

## 📌 Overview

This repository accompanies the Google Cloud technical publication:  
👉 **[Supply Chain Analytics with BigQuery Graph: From Reactive to Predictive](https://medium.com/google-cloud/supply-chain-analytics-with-bigquery-graph-from-reactive-to-predictive-3324239edfa3)**  
*By Rajdip Chaudhuri (Outcome Customer Engineer at Google)*

Modern global supply chains are multi-tiered, non-linear property graphs comprising parts, suppliers, bill-of-materials (BOM), shipping lanes, ports, factories, and finished products. Traditional relational databases force these relationship networks into flat tables, requiring complex, fragile, and computationally prohibitive multi-table `JOIN` statements (often 10–15 deep).

**BigQuery Graph** integrates native property graphs and the international **ISO GQL (Graph Query Language)** standard directly into Google BigQuery. This repository provides complete DDL, data population scripts, graph queries, ACID transaction patterns, and hybrid AI workflows that turn an automotive supply chain digital twin into a predictive resilience engine.

---

## 🌐 The Automotive Supply Chain Property Graph Model

The digital twin models a multi-tier automotive manufacturing and shipping network:

```mermaid
graph LR
    Suppliers["Suppliers (Tier 1..N)"] -->|SupplierSupplies| Parts["Parts (Raw & Finished)"]
    Parts -->|PartComposition (BOM)| Parts
    Parts -->|ComponentParts| Components["Components (Assemblies)"]
    Components -->|CarModelComponents| CarModels["Car Models (Vehicles)"]
    Factories["Factories"] -->|FactoryAssembly| CarModels
    Warehouses["Warehouses"] -->|WarehouseInventory| Parts
    Shipments["Shipments"] -->|ShipmentContents| Parts
    Shipments -->|ShipmentLogistics| Vessels["Vessels (Container Ships)"]
    Vessels -->|ShippingRoutes| Ports["Ports (Maritime Hubs)"]
```

### Nodes & Relationships
| Entity Type | Tables | Description |
|---|---|---|
| **Nodes** | `CarModels`, `Components`, `Parts`, `Factories`, `Warehouses`, `Suppliers`, `Ports`, `Vessels`, `Shipments`, `LegalEntities` | Core physical and logical participants across the supply network. |
| **Edges** | `CarModelComponents`, `ComponentParts`, `PartComposition`, `SupplierSupplies`, `FactoryAssembly`, `WarehouseInventory`, `ShipmentContents`, `ShipmentLogistics`, `ShippingRoutes` | Structural connections tracking assembly dependencies, inventory storage, shipping lanes, and supplier contracts. |

---

## 📂 Repository Structure

```text
├── Queries/
│   ├── schema_definition.sql  # DDL for node tables, edge tables, foreign keys, and PROPERTY GRAPH compilation
│   ├── data_population.sql    # Synthetic dataset populating factories, vessels, parts, BOM, and shipments
│   ├── graph_queries.sql      # Native ISO GQL queries: Blast radius, defect traceability, and prescriptive ranking
│   ├── transactions.sql       # ACID transactional updates ensuring graph integrity without orphaned edges
│   └── ai_part.sql            # Hybrid AI: Autonomous Vertex AI embeddings, Vector Search, and BigQuery ML
└── README.md                  # Architecture overview, pipeline documentation, and quickstart guide
```

---

## 🚀 Key Use Cases & Technical Highlights

### 1. Disruptive Blast Radius Analysis (`graph_queries.sql`)
When a maritime bottleneck or strike hits a hub (such as *Port of Seraphina*), standard SQL requires over a dozen recursive joins to discover which assembly lines will stall. Using native ISO GQL in BigQuery:

```sql
GRAPH automotive_graph.SupplyChainGraph  
MATCH  (factory:Factories)-[:FactoryAssembly]->(car_model:CarModels)-[:CarModelComponents]->(component:Components)-[:ComponentParts]->(part:Parts),
       (part)<-[:ShipmentContents]-(shipment:Shipments)-[:ShipmentLogistics]->(vessel:Vessels)-[:ShippingRoutes]->(port:Ports)  
WHERE port.Name = 'Port of Seraphina' 
  AND shipment.Status IN ('In Transit', 'At Port')  
RETURN DISTINCT
  factory.Name AS ImpactedFactory,  
  car_model.Name AS HaltedCarModel,  
  car_model.BodyStyle AS BodyStyle,  
  (factory.DailyProductionCapacity * car_model.BaseMSRP) AS DailyRevenueAtRisk  
ORDER BY DailyRevenueAtRisk DESC;
```
*Outcome:* Instantly reveals affected factories and calculates **Daily Revenue at Risk** in a concise, readable traversal.

---

### 2. Multi-Tier Defect Traceability (`graph_queries.sql`)
Trace defective raw materials (e.g. tainted alloys or contaminated battery minerals) up through multi-tier suppliers, sub-assemblies, and finished parts to identify every exposed vehicle model before delivery.

```sql
GRAPH automotive_graph.SupplyChainGraph  
MATCH (supplier:Suppliers)-[:SupplierSupplies]->(raw_material:Parts),
      (raw_material)<-[:PartComposition]-(finished_part:Parts)<-[:ComponentParts]-(component:Components)<-[:CarModelComponents]-(car_model:CarModels)  
WHERE supplier.Name = 'Dynamo Materials' 
  AND raw_material.Name = 'Raw Neodymian'  
RETURN DISTINCT  
  car_model.Name AS CarModelName, component.Name AS ComponentName, finished_part.Name AS FinishedPartName;
```

---

### 3. Prescriptive Mitigation Ranking with `GRAPH_TABLE` (`graph_queries.sql`)
Blend graph pattern matching inside standard SQL relational operators (`UNION ALL`, analytical aggregations) to find and rank mitigation strategies across:
- **Warehouse Transfers:** Diverting stock from non-impacted hubs.
- **In-Transit Reroutes:** Intercepting sea cargo before final port discharge.
- **Expedited Supplier Orders:** Engaging alternative qualified vendors.

Results are consolidated and ordered by `TimeToDeliverDays` for immediate operations execution.

---

### 4. ACID Graph Transactions (`transactions.sql`)
Maintain graph consistency when decommissioning vehicle models or updating logistics routes. Demonstrates BigQuery multi-statement transactions (`BEGIN TRANSACTION ... COMMIT TRANSACTION`) to purge dependent edge tables (`FactoryAssembly`, `CarModelComponents`) before deleting target nodes, preventing orphaned edges.

---

### 5. Hybrid AI: Semantic Vector Search + Graph + BQML (`ai_part.sql`)
Combines unstructured text understanding, graph topology, and supervised ML:

1. **Autonomous Vector Embeddings (`AI.EMBED`):**  
   Part engineering specifications are automatically vectorized via a generated column connected to Vertex AI's `text-embedding-005` model.
2. **Hybrid Semantic Search + GQL:**  
   Find parts matching fuzzy, unstructured queries (e.g., *"high-temperature forced-induction systems"*) using `AI.SEARCH`, and pipe the matched `PartID`s directly into a `GRAPH_TABLE` match to calculate financial blast radius.
3. **Graph Feature Engineering:**  
   Derive graph metrics (supplier redundancy count, average supplier risk, BOM dependency depth) directly from graph topology.
4. **Predictive Production Halt Classifier:**  
   Train a BigQuery ML `boosted_tree_classifier` (XGBoost) to predict component halt probabilities:
   ```sql
   CREATE OR REPLACE MODEL automotive_graph.halt_prediction_model
   OPTIONS(
     model_type = 'boosted_tree_classifier',
     input_label_cols = ['production_halt_label'],
     booster_type = 'GBTREE',
     data_split_method = 'AUTO_SPLIT'
   ) AS
   SELECT supplier_redundancy_count, avg_supplier_risk, raw_material_dependency_depth, production_halt_label
   FROM automotive_graph.ComponentMLFeatures;
   ```

---

## 🛠️ Getting Started & Execution Guide

### Prerequisites
1. A Google Cloud project with billing enabled.
2. BigQuery API enabled.
3. For the AI section (`ai_part.sql`):
   - A BigQuery Cloud Resource connection created in your region (e.g., `us.vertex_ai_connection`).
   - The connection's service account granted the **Vertex AI User** (`roles/aiplatform.user`) role.

### Step-by-Step Execution Sequence

1. **Create Dataset & Property Graph:**
   Execute [`Queries/schema_definition.sql`](Queries/schema_definition.sql) in the BigQuery console. This creates dataset `automotive_graph`, sets up 10 node tables and 9 edge tables, and compiles `SupplyChainGraph`.

2. **Load Graph Data:**
   Run [`Queries/data_population.sql`](Queries/data_population.sql) to populate nodes and edges with synthetic automotive data.

3. **Execute Graph Queries:**
   Run [`Queries/graph_queries.sql`](Queries/graph_queries.sql) to run blast radius, multi-tier defect tracing, and mitigation ranking queries.

4. **Verify ACID Transactions:**
   Run [`Queries/transactions.sql`](Queries/transactions.sql) to test safe multi-table node and edge deletions.

5. **Run Hybrid AI & Machine Learning:**
   Execute [`Queries/ai_part.sql`](Queries/ai_part.sql) to generate embeddings, perform hybrid vector + graph queries, build topological features, and train the BQML halt prediction model.

---

## 📖 Further Reading & Reference

- **Medium Article:** [Supply Chain Analytics with BigQuery Graph: From Reactive to Predictive](https://medium.com/google-cloud/supply-chain-analytics-with-bigquery-graph-from-reactive-to-predictive-3324239edfa3)
- **Documentation:** [Google Cloud BigQuery Graph Documentation](https://cloud.google.com/bigquery/docs/graph-overview)
- **ISO GQL Standard:** [Graph Query Language Standards Overview](https://www.iso.org/standard/76582.html)
