# Scenario 1: Go from the world to a single room

Slide: `demo-1-estate-map.html`. Time: about 5 minutes.

## 1. Goal and one-sentence message

Show that one live map answers "how many tablets, where, in which building" without an export.

> The registry only knew city and country as text; now you can drill from the world down to one room.

## 2. Setup

- **Time range:** Last 30 minutes or longer.
- **Filters:** none. The Country filter is pinned but unset.
- **Start:** Overview section, map at world view.
- **Before you start:** read the live tablet, city and country counts. The slide shows 689, 41 and 18 as sample
  figures.

## 3. Walkthrough

| Step | Action | Point at | Talk track |
| --- | --- | --- | --- |
| 1 | On slide 4, read the three numbers | 689 / 41 / 18 on the slide | "These are sample figures. On the dashboard you will see yours." |
| 2 | Switch to the dashboard | Overview KPIs | "Tablets, cities, countries, straight from the registry." |
| 3 | Show the map at world view | `Tablets per country` shading | "At world level you see tablets per country." |
| 4 | Zoom into Europe | `Tablets per city` bubbles, then `City labels` from zoom 5 | "Zoom in and the country shading gives way to city bubbles with the count." |
| 5 | Point out the biggest bubbles | Largest bubbles (Munich, Madrid, London in the sample) | "The bigger the bubble, the more tablets." |
| 6 | Set the pinned Country filter, for example Germany | Country filter, then the map | "One filter, and every panel follows." |
| 7 | Scroll to Room capacity | **Top 20 buildings by room count** | "Which buildings have the most rooms." |
| 8 | Pick one room | **Latest poll per room** table | "The last report from each room's tablet." |

## 4. Key takeaway

One view, always current: the map refreshes every 15 minutes from the same database, with no manual geocoding
and no export.

## 5. Questions to expect

- **How precise are the pins?** They are city centroids, not office addresses. Office-level precision needs a
  coordinate list keyed by site, which is not built.
- **How fresh is it?** The agent reads the registry every 15 minutes, so the map is up to about 15 minutes behind.
- **Did you geocode with an outside service?** No. A GeoNames lookup of about 208,000 cities is loaded once into
  Elastic and applied during collection. No external service is called.
- **Does it change our MIMO database?** No. It is read-only.
- **A city is missing from the map.** The lookup did not match it. Those documents carry the tag
  `geonames_no_match` and can be listed and fixed with an alias.
- **Why are many tablets red or INACTIVE?** The status in the registry is almost always INACTIVE, so the red layer
  says little about real activity. Do not draw conclusions from it.
- **Can I see what happened on a tablet?** No. The data is registry snapshots, with no logs or events.

## 6. Fallback

- **Map is empty:** widen the time range to Last 1 hour or more; the map needs data in the last 30 minutes. If it is
  still empty, run `02-verify.console` and check that documents carry `sql.metrics.location`.
- **Panel is empty after a Country filter:** clear the filter and pick another country.
- **No data at all or Kibana unreachable:** stay on slide 4 and describe the click path from the notes, using the
  sample figures and saying they are illustrative. Offer to run it live afterwards.
- **Counts look flat or identical across cities:** say the sample fleet is small and move on to the building list.

## 7. Transition

"We can now see where the tablets are. The next question is when we can touch them." Go to slide 5 and
[Scenario 2](scenario-2-timezones.md).
