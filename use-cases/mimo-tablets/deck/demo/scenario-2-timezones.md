# Scenario 2: Plan support and rollouts across time zones

Slide: `demo-2-timezones.html`. Time: about 3 minutes.

## 1. Goal and one-sentence message

Show that tablets can be grouped by time zone to plan an update in waves.

> Nobody could say which offices are open when an update goes out; now the registry is grouped by time zone.

## 2. Setup

- **Time range:** Last 30 minutes or longer.
- **Filters:** clear the Country filter from Scenario 1.
- **Start:** Timezone section.
- **Before you start:** read the live number of distinct time zones. The slide shows 22 and its bars show 8 of 22 zones
  (Europe/Berlin 174, Madrid 96, Paris 70, down to Australia/Brisbane 3). These are sample figures.

## 3. Walkthrough

| Step | Action | Point at | Talk track |
| --- | --- | --- | --- |
| 1 | On slide 5, show the bars | Tablets per time zone, largest to smallest | "The registry has no time zone, so this was invisible." |
| 2 | Switch to the dashboard, open the Timezone section | Distinct time zone count (22 in the sample) | "This many distinct zones across the estate." |
| 3 | Show the chart | **Tablets by timezone** | "Tablets per zone, largest offices first." |
| 4 | Propose a wave plan | Smallest zones at the bottom, largest at the top | "Pilot on the smallest zones, then roll out to the big offices." |
| 5 | Explain where the zone comes from | None | "It comes from the GeoNames enrichment. It does not exist in the MIMO database." |

## 4. Key takeaway

Grouping tablets by time zone turns a flat list into a rollout plan: pilot small, then go big.

## 5. Questions to expect

- **Can you show local time per office?** Not today. Grouping by zone works; computing local time was not tested, so
  do not promise it.
- **Where does the time zone come from?** From the GeoNames match on city and country. It is the zone of the city,
  not of the building.
- **What about countries with several zones?** The zone follows the matched city, so each city gets its own.
  A city that did not match has no time zone.
- **Can it schedule the update?** No. It shows where the tablets are and in which zone. The scheduling stays in your
  tooling.
- **Does it show which tablets updated?** The registry has an app version field, but this dashboard is not built as a
  rollout tracker. Do not promise it.

## 6. Fallback

- **Tablets by timezone is empty or the Timezone section shows nothing:** widen the time range, then run
  `02-verify.console` and check that `sql.metrics.timezone` is populated. Documents indexed before the enrichment
  went live have no time zone.
- **Only one or two zones:** the sample fleet is small or concentrated. Say so, and use slide 5's bars to
  show the idea.
- **No data at all:** stay on slide 5, walk through the bars as illustrative figures, and offer a live run afterwards.

## 7. Transition

"So we can see the estate and plan by zone. What we cannot see yet is when a whole office goes quiet." Go to slide 6,
the closing slide: value, then the next step (a heartbeat or last-seen signal).
