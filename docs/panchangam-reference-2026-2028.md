# Panchangam Reference Data: Sashti & Krithigai, 2026–2028

**Status:** 🟡 On hold (2026-09-27) — user flagged a data mismatch and will supply dates from a verified source of their own; treat everything below as provisional research, not confirmed, until that happens.
**Date compiled:** 2026-09-27
**Purpose:** Seed data for a planned calendar feature to help devotees track Valarpirai Sashti, Theipirai Sashti, Maha (Skanda) Sashti, and Krithigai/Karthigai Deepam dates. See the conversation this was compiled from for the design discussion (a Drive-backup-style pre-computed, bundled-data approach was recommended over live astronomical calculation — same philosophy as `thiruppugazh.db`).

## Methodology

- **Source:** [drikpanchang.com](https://www.drikpanchang.com/) — the most widely trusted online Panchangam, using the modern "Drik Ganita" (observational/computed, not the older Vakya) method with **Lahiri ayanamsa** (India's official government standard). Location used: **Chennai, Tamil Nadu** (`geoname-id=1264527`), since tithi/nakshatra day-boundaries are location-sensitive (sunrise-based) and this app is Tamil Nadu-focused.
- **Cross-checks performed:**
  - Chennai vs. Hyderabad coordinates gave *identical* Skanda Sashti dates for all 12 months of 2026 — confirms location sensitivity isn't an issue for these specific dates at this precision.
  - The 2026 Soorasamharam (main annual Skanda Sashti) date was independently confirmed against **[tiruchendur.org](https://tiruchendur.org/kanda-sasti/kanda-sasti-2026-dates/)**, the official website of the Tiruchendur temple — the single most authoritative source for this specific festival. It agrees exactly with drikpanchang: **November 15, 2026**.
  - 2026 Krithigai dates were independently cross-checked against **calendar.tamildot.com** (a dedicated Tamil calendar site) — all 13 dates matched exactly.
  - **Caveat:** 2027 and 2028 Krithigai lists, and all Theipirai Sashti lists, come from drikpanchang only — not independently cross-checked against a second source the way 2026 was. Recommend a spot-check against a printed/published Tamil panchangam (e.g. a temple's own annual calendar) before shipping this as in-app data, especially for the marquee dates (Maha Sashti, Karthigai Deepam).
  - One real discrepancy was caught and resolved during research: a search-engine-generated summary claimed the 2026 Soorasamharam was Nov 16 — this was wrong; both drikpanchang and the temple's own site independently confirm **Nov 15**. This is a caution against trusting AI-generated search summaries at face value for dates like these — always fetch the primary source page directly.
- **Karthigai Deepam** uses a different day-assignment rule than the plain daily Krittika Nakshatra list: it's assigned by *Ratrimana* (nakshatra prevailing during the night), not the sunrise-to-sunrise convention used for the routine monthly list — so its date can differ by a day from what the plain monthly Krithigai list below would suggest (see 2028: monthly list says Nov 30, dedicated Karthigai Deepam page says Dec 1, because the star was still active into the night of Dec 1).

---

## 1. Maha (Skanda) Sashti — the main annual festival (Soorasamharam)

The Valarpirai Sashti falling in Tamil month Aippasi/Karthikai (the 6-day festival, famous at Tiruchendur, Palani, etc.):

| Year | Festival starts | **Soorasamharam (main day)** | Thirukalyanam |
|---|---|---|---|
| 2026 | Nov 10 (Tue) | **Nov 15, 2026 (Sunday)** ✅ temple-confirmed | Nov 16 (Mon) |
| 2027 | ~Oct 30 | **Nov 4, 2027 (Thursday)** | ~Nov 5 |
| 2028 | ~Oct 18 | **Oct 23, 2028 (Monday)** | ~Oct 24 |

## 2. Valarpirai Sashti (Shukla Paksha Shashthi — waxing moon 6th day), monthly

All 12–13 occurrences per year; the one bolded above is the annual Maha Sashti.

**2026:** Jan 24, Feb 22, Mar 24, Apr 22, May 21 *(Adhika month)*, Jun 19, Jul 19, Aug 17, Sep 16, Oct 16, **Nov 15**, Dec 15

**2027:** Jan 13, Feb 12, Mar 13, Apr 12, May 11, Jun 9, Jul 8, Aug 7, Sep 5, Oct 5, **Nov 4**, Dec 3

**2028:** Jan 2, Feb 1, Mar 2, Mar 31, Apr 30, May 29, Jun 27, Jul 26, Aug 25, Sep 23, **Oct 23**, Dec 21
*(2028 has only 11 listed by drikpanchang's own page — no separate November entry; verify this gap before shipping, it may be an adhika/kshaya-month artifact.)*

## 3. Theipirai Sashti (Krishna Paksha Shashthi — waning moon 6th day), monthly

**2026:** Jan 8, Feb 7, Mar 8, Apr 7, May 7, Jun 6, Jul 5, Aug 3, Sep 2, Oct 1, Oct 30, Nov 29, Dec 28

**2027:** Jan 27, Feb 25, Mar 27, Apr 26, May 26, Jun 24, Jul 24, Aug 22, Sep 21, Oct 20, Nov 18, Dec 18

**2028:** Jan 16, Feb 15, Mar 15, Apr 14, May 13, Jun 12, Jul 12, Aug 11, Sep 9, Oct 9, Nov 7, Dec 7

## 4. Krithigai (Krittika Nakshatra), monthly — 13–14 per year

**2026** (cross-verified against tamildot.com — exact match): Jan 27, Feb 23, Mar 23, Apr 19, May 16, Jun 13, Jul 10, **Aug 6 (Aadi Krithigai)**, Sep 3, Sep 30, Oct 27, **Nov 24 (Karthigai Deepam)**, Dec 21

**2027** (drikpanchang only): Jan 17, Feb 14, Mar 13, Apr 9, May 7, Jun 3, Jun 30, **Jul 28 (Aadi Krithigai — confirmed by 2nd source)**, Aug 24, Sep 20, Oct 18, Nov 14, **Dec 11 (Karthigai Deepam, per dedicated festival page)**

**2028** (drikpanchang only): Jan 8, Feb 4, Mar 2, Mar 30, Apr 26, May 23, Jun 19, Jul 17, Aug 13, Sep 9, Oct 7, Nov 3, Nov 30, Dec 28
*(Karthigai Deepam 2028 = **Dec 1** per the dedicated festival page — note this is one day after the Nov 30 entry in this plain monthly list, due to the Ratrimana rule explained above.)*

## 5. Karthigai Deepam (annual, major)

| Year | Date |
|---|---|
| 2026 | **Tuesday, November 24** |
| 2027 | **Saturday, December 11** |
| 2028 | **Friday, December 1** |

## 6. Aadi Krithigai (annual, Tamil month Aadi)

| Year | Date |
|---|---|
| 2026 | **Thursday, August 6** |
| 2027 | **Wednesday, July 28** |
| 2028 | Not separately confirmed — should be the Krithigai falling in Tamil month Aadi (mid-Jul–mid-Aug); likely **July 17** or **Aug 13** from the list above, needs the same cross-check treatment as 2026/2027 before use.

---

## Before this becomes app data

1. Spot-check 2027/2028 against a second source (a published Tamil Nadu panchangam, or another major Murugan temple's own site — Palani, Tiruttani, Swamimalai, Pazhamudircholai all publish their own Kanda Sashti calendars).
2. Resolve the apparent 2028 Valarpirai Sashti count gap (11 vs. the expected 12–13).
3. Decide the exact scope for the in-app feature (which of the 6 categories above actually ship — probably not the routine monthly Theipirai Sashti for most users, but the Maha Sashti + Krithigai + Karthigai Deepam + Aadi Krithigai are the clear "must have" set).
4. Extend past 2028 once the format/pipeline is settled — these sites support arbitrary future years via the `year=` query parameter.
