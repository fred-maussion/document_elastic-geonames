# MIMO tablets: demo scripts

One script per demo scenario of the deck. Read this page first, then the scenario you will present.

## Persona and scope

- **Audience:** a workplace or IT operations lead who owns the MIMO room-booking tablets.
- **What they want:** to see where the tablets are, how many, and in which building, and to plan work across offices
  without asking for an export.
- **Data scope: metrics only.** The data is a snapshot of the tablet registry, read from a SQL database every
  15 minutes (`metrics-sql-default`, one document per tablet per snapshot). It holds registry fields and
  configuration flags. There are **no messages, no logs and no events**, so there is no message-level forensics and
  no per-tablet history of what happened on a device.
- **What Elastic adds:** a GeoNames lookup, applied while the data is collected, turns the free-text city and country
  into coordinates, a country code and a time zone. Nothing changes in the MIMO database.

## Prerequisites

- Setup steps 1 to 4 of the [root Readme](../../../Readme.md) and the enrichment in
  [`01-metrics-sql-enrichment.console`](../../01-metrics-sql-enrichment.console) are done, and
  [`02-verify.console`](../../02-verify.console) returns documents with `sql.metrics.location`.
- The multi-layer map of [`03-map-layers.md`](../../03-map-layers.md) exists and is on the dashboard.
- Dashboard time range is **Last 30 minutes** or longer. A shorter range gives an empty map, because the snapshot
  runs every 15 minutes and the map queries use a 30-minute window.
- Deck running: `fslides serve` in `deck/`. Speaker notes show in the player's notes panel only.
- Open only the sections that hold real data: the estate map, room capacity and the Timezone section. Do not open
  the check-in, check-out or environment sections; they hold configuration flags, not live activity.

## Dashboard map

Names are the ones used in the speaker notes and in `03-map-layers.md`. Check them against your dashboard before the
meeting and fix the scripts if a title differs.

| Where | Panel or section | Used in |
| --- | --- | --- |
| Overview | KPIs (tablets, cities, countries) | Scenario 1 |
| Estate map | Map with layers `Tablets per country` (zoom 0 to 4), `Tablets per city`, `Inactive tablets`, `City labels` (zoom 5 and up) | Scenario 1 |
| Filters | Pinned **Country** filter | Scenario 1 |
| Room capacity | **Top 20 buildings by room count** | Scenario 1 |
| Room capacity | **Latest poll per room** table | Scenario 1 |
| Timezone | Section header, distinct time zone count (22 in the sample) | Scenario 2 |
| Timezone | **Tablets by timezone** chart | Scenario 2 |

## Suggested running order

| # | Part | Where | Time |
| --- | --- | --- | --- |
| 1 | Cover, Challenge, How it works | Slides 1 to 3 | 3 min |
| 2 | [Scenario 1: estate map](scenario-1-estate-map.md) | Slide 4, then Kibana | 5 min |
| 3 | [Scenario 2: time zones](scenario-2-timezones.md) | Slide 5, then Kibana | 3 min |
| 4 | Closing and next step | Slide 6 | 2 min |
| | Questions | | 2 min |

Total: about 15 minutes.

## Example figures

Figures in the slides and scripts (689 tablets, 41 cities, 18 countries, 22 time zones, Europe/Berlin 174) come from
the generic sample fleet. **Live values will differ.** Read the real numbers off the dashboard before the meeting and
say them out loud instead of the sample ones.
