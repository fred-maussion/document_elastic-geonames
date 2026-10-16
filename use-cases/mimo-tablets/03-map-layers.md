# Step 3 - Kibana Maps: multi-layer map of MIMO tablets

Data view: `metrics-sql-default` (create it if missing; time field `@timestamp`).
Dashboard / map time range: **Last 30 minutes** or longer. The SQL input snapshots every tablet every 15 min,
and the ES|QL layers also hard-code a 30-minute window, so a shorter picker range shows an empty map.

Prerequisite: the enrichment of step 1 is live, so documents carry `sql.metrics.location` and
`sql.metrics.country_code`.

## Map settings

- **Projection: Mercator.** Open **Map settings > Display** and set the projection to **Mercator**
  (flat map), not Globe. Zoom ranges, bubble sizes and label placement below were chosen for the flat view.

## Layer stack (bottom to top)

| # | Name | Type | Zoom levels | Size | Colour |
| --- | --- | --- | --- | --- | --- |
| 1 | `Tablets per country` | Choropleth (EMS World Countries) | 0 to 4 | n/a | metric `Tablets`, sequential |
| 2 | `Tablets per city` | ES\|QL | 3 to 24 | by value `tablets` | blue, 50 % opacity |
| 3 | `Inactive tablets` | ES\|QL | 3 to 24 | by value `inactive` | red `#F80E00`, 75 % opacity |
| 4 | `City labels` | ES\|QL | **5 to 24** | small dot | label by value `label` |

24 is the maximum zoom, so "to 24" means no upper limit. Layers 1 and 2/3 overlap at zoom 3 to 4 so the
switch from country shading to city bubbles is not abrupt. Layer 3 is drawn inside layer 2: the red share of
each blue bubble is the share of inactive tablets. If the first view is too empty, start layers 2 and 3 at
zoom 2; if the bubbles crowd the starting view, start them at zoom 4.

## Layer 1 - Choropleth

- Add layer > Choropleth > EMS boundaries: **World Countries**.
- Join field: **ISO 3166-1 alpha-2 code**; right source: data view `metrics-sql-default`, term field
  `sql.metrics.country_code` (written by the enrichment pipeline).
- Metric: **Unique count** of `sql.metrics.uuid`, **custom label `Tablets`** (shown in legend and tooltip).
- Apply global time filter: on.
- Style: fill colour by the metric, sequential palette. Layer settings > Zoom levels 0 to 4.

## Layers 2, 3, 4 - ES|QL (same query, different styling)

Returns one row per city with a `geo_point` column.

```esql
FROM metrics-sql-default
| WHERE @timestamp > NOW() - 30 minutes AND sql.metrics.location IS NOT NULL
| STATS tablets  = COUNT_DISTINCT(sql.metrics.uuid),
        active   = COUNT_DISTINCT(CASE(sql.metrics.status == "ACTIVE", sql.metrics.uuid, NULL)),
        location = ST_CENTROID_AGG(sql.metrics.location)
  BY country = sql.metrics.country, city = sql.metrics.city
| EVAL inactive = tablets - active,
       pct_active = ROUND(active * 100.0 / tablets),
       label = CONCAT(city, " · ", TO_STRING(tablets))
| SORT tablets DESC
```

Columns returned: `tablets`, `active`, `location` (geo_point), `country`, `city`, `inactive`,
`pct_active`, `label`. The `label` column is needed by layer 4 only; it is harmless in the others.
`sql.metrics.uuid` is the device identifier of one physical tablet, so `COUNT_DISTINCT` counts tablets, not
snapshots.

Settings common to the three ES|QL layers (defaults are fine): *Dynamically filter for data in the visible map
area* on (filter by `sql.metrics.location`), *Apply global search* on, *Apply global time range* on
(filter by `@timestamp`), *Re-fetch layer data on refresh* on, *Show tooltips* on.

### Layer 2 - `Tablets per city`

- Zoom levels 3 to 24. Opacity 50 %.
- Symbol type marker. Fill blue, border same blue.
- Symbol size: **By value**, field `tablets`, min `6`, max `40`.
- Tooltip fields: `city`, `country`, `tablets`, `active`, `inactive`.

### Layer 3 - `Inactive tablets`

- Duplicate layer 2. Rename it. Zoom levels 3 to 24 (must match layer 2). Opacity 75 %.
- Fill and border red `#F80E00`, border width 1.
- Symbol size: **By value** (not `Fixed`), field `inactive`, min `6`, max `40` (same as layer 2, so the red
  bubble can never exceed the blue one).
- Label: leave `Fixed` and empty; layer 4 handles labels.

### Layer 4 - `City labels`

- Duplicate layer 2. Rename it. Zoom levels **5 to 24** (at lower zoom levels the labels of nearby cities
  overlap).
- Fill and border: keep a small dot (size 6, border width 1) to anchor the label, or set opacity to 0 for
  text only.
- Label: **By value**, field `label` (renders as `Paris · 12`). If it is blank, check that the query of this
  layer contains the `EVAL ... label = CONCAT(...)` line.
- Label position: **Top** or **Bottom**, not `Center`, so the text sits outside the blue/red bubbles.
- Label colour white, label size 14, label border colour black, label border width Small.

## Notes

- The query hard-codes the 30-minute window so the map cannot accidentally aggregate days of snapshots.
  If you change it, change it in all three ES|QL layers (they cannot share one query).
- Layers 2 and 3 only differ when tablets have different `sql.metrics.status` values. If every tablet reports
  the same status, the red bubble fully covers the blue one; that reflects the data, not the layer settings.
- Pins are GeoNames city centroids. When several places share a city name inside a country, the most populated
  one is used; add an alias in the enrichment pipeline to force a different one.
- Office-level precision needs a coordinate list keyed by `site`; it would be a layer between 3 and 4.
- Layers cannot be created through a stable Maps API; if you want the map in the repo, build it once in Kibana
  and export it (Stack Management > Saved Objects > Export) as `map.ndjson`.
