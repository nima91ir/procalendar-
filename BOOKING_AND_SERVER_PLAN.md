# Booking + server plan (draft, not started)

Status: **planning only.** No code has been written for this. Nothing here is committed.

This is the first feature that takes PRO CALENDAR beyond local-first: it needs a server, and a
second, **public** surface that people who are not your users will use.

---

## 0. Guiding principle: the trainer never leaves the app

Stated by the user on 2026-09-28: *"I want the users don't need to change app to do what they
need to."*

- Everything the **trainer** does — define availability, see requests, confirm a booking — happens
  inside this app. No hopping to Telegram, no external booking tool, no second site to manage.
- The **client** needs no app at all: one plain web page, opened from a link, no install, no
  account. That is the entire client-side requirement.
- Consequence: the cheap third-party short-cuts considered earlier (a Calendly/Google link, or a
  Telegram bot carrying the notification) are **out of favour** even where they would be cheaper.
  They survive only as fallbacks, noted in §8.

---

## 1. Scope

**In scope**

- A trainer defines **bookable windows** (a weekly grid, closed by default).
- Each trainer has a **public code** they give to their clients.
- A client opens a page for that code, sees the free times, picks one and submits **name + phone**.
- The trainer sees the request in the app and confirms or ignores it.
- A confirmed booking becomes an appointment on the trainer's calendar.

**Explicitly out of scope** (decide now so it does not creep in)

- **Client accounts.** No sign-up, no login, no password, no OTP for anyone but the trainer.
- **Bidirectional sync.** Booking requests flow one way. There is no merge of two devices' data.
- **Automatic reservation.** A request is not a hold; the trainer confirms it.
- **Group sessions / capacity.** One window = one client, for now.
- **Multi-trainer businesses.** One code = one trainer.

---

## 2. Constraints that shape everything

1. **No schema change in this app.** `schemaVersion` is frozen at 7; live users' databases are
   at v7 and a change forces a migration on their devices. `AGENTS.md` forbids it, and the
   successor app exists for schema work.
2. **Storage is origin-bound.** Moving the app's URL empties every existing user's calendar.
   Whatever we build, **the trainer app's origin must not move.**
3. **Offline stays first-class.** The app must keep working with no connection. Only publishing
   availability and fetching requests need the network, and both must fail quietly.
4. **The hours have nowhere to live.** Plans count days; attendance is keyed by `yyyy/MM/dd`.
   There is no hour column anywhere, and adding one is a schema change.

---

## 3. The design, and why it is small

Your design decisions remove three things I had assumed were mandatory:

| Decision | What it removes |
|---|---|
| A booking is a **request**, not a reservation | Server-side arbitration of double-booking. Two clients can ask for 2pm; you pick one. No slot locking, no race conditions. |
| Notification is **in-app** | Push API, VAPID keys, a push sender, service-worker plumbing, iOS 16.4+ PWA push quirks. |
| **No client accounts** | OTP, passwords, email verification, account recovery, and most of the privacy surface. |

Net: **one serverless function and a key-value store** is enough. No database server, no
sessions, no user management.

### Still open, with my recommendation

| Question | Recommendation |
|---|---|
| Is a window one bookable session (14:00–15:30 = one 90-minute slot), or is it split? | **One window = one session.** Sub-slots add a duration, a capacity and more UI; add them only if a trainer asks. |
| Does a completed booking consume a plan session? | **Yes, at confirmation**, through the existing `addSession` so refunds work. But make it optional per booking — a walk-in may have no plan. |
| Do clients see slots that are already requested/confirmed? | **v1: no** (show the window grid). **v1.1: hide slots with a *confirmed* appointment.** Pending requests stay visible, since they are not holds. |
| Who creates trainer codes? | **The operator, by hand.** This is what keeps "no sign-up" true. |

---

## 4. Data shapes

### Availability — stored locally in `app_settings` (no migration)

One key, e.g. `booking_availability`, holding a small JSON blob:

```json
{
  "enabled": true,
  "slotMinutes": null,
  "windows": [
    { "weekday": 1, "startMinute": 840, "endMinute": 930 },
    { "weekday": 5, "startMinute": 600, "endMinute": 720 }
  ],
  "overrides": [
    { "date": "1405/07/12", "closed": true },
    { "date": "1405/07/20", "windows": [{ "startMinute": 900, "endMinute": 990 }] }
  ]
}
```

- `weekday` is the Jalali week (شنبه = 0 … جمعه = 6). **Closed by default: an absent day is closed.**
- Minutes-of-day as integers, not timestamps: the whole app is local wall-clock, and Iran no
  longer observes DST, so there is no timezone maths to do. Do not introduce UTC here.
- `overrides` is optional for v1 and can be added later without changing the shape.

### Booking request — lives on the server

```json
{
  "id": "…",
  "trainerCode": "K7F2QA",
  "date": "1405/07/12",
  "startMinute": 840,
  "endMinute": 930,
  "name": "…",
  "phone": "…",
  "status": "pending | confirmed | declined",
  "createdAt": "…"
}
```

### Confirmed appointment — stays local

The confirmed request becomes an **existing `attendance` record for its date**, created through
`addSession` so plan consumption and refunds behave exactly as they do today. **The hour stays in
the booking record, not in the database.** That is the compromise the schema freeze forces, and
it is acceptable for one trainer — but it is not a foundation for reporting by hour.

---

## 5. Server

Deliberately minimal.

```
GET  /t/{code}/availability          public   → windows only, no personal data
POST /t/{code}/requests              public   → {date, startMinute, name, phone}
GET  /t/{code}/requests?since=…      trainer  → new requests (pull)
POST /t/{code}/requests/{id}/status  trainer  → confirm / decline

PUT  /t/{code}/availability          trainer  → publish the blob
```

- **Trainer auth:** one secret token per trainer, generated when you create their code and stored
  in `app_settings` on their device. A bearer token. No accounts, no passwords, no sessions.
  (This is the one secret the app holds, so it must never be committed or logged.)
- **Storage:** a KV/document store. `trainers/{code}` → token hash + name + availability blob;
  `requests/{code}/{id}` → the request. That is the whole data model.
- **The public code must be random** (6–8 chars), not the sequential database id. Sequential ids
  let anyone enumerate every trainer's schedule and spam their bookings. This is the single most
  important detail in this document.
- **Abuse:** the public endpoints are unauthenticated by design. Rate-limit per IP and per code;
  cap pending requests per code (e.g. 20) so a flood cannot grow storage without bound. Add a
  captcha only if abuse actually appears — your manual-confirm model already makes junk harmless.
- **Validation:** the server must reject a request for a window that is not actually open for
  that date, otherwise the public form is a free-form write endpoint into someone's calendar.

---

## 6. The two surfaces

### Trainer side (inside this app)

- A new screen: **availability editor** — a weekday × time grid, all closed by default, tap to
  open a range. This is the same shape as the plan editor, which is why it feels familiar.
- A **requests list**, showing pending bookings with confirm / decline.
- A **share row** showing the public code and a copy/share action.
- Everything degrades to read-only when offline; publishing retries when the connection returns.

### Client side (public page)

**Recommendation: a small static page, not a Flutter build.** Someone arriving from a link on a
phone should not download a 2 MB Wasm bundle to see five time slots. A single HTML page that
fetches the availability JSON and posts the form is faster, simpler, and trivially cacheable.

- RTL by default (Persian), one screen: trainer name, the coming week's windows, tap a slot,
  name + phone, done.
- No login, no navigation, no app install prompt.
- It should state **who will see the data they type** — see §7.

---

## 7. Privacy and retention

This is the part that changes your obligations, so decide it up front.

- The server holds **strangers'** names and phone numbers — people who are not your users and
  have agreed to nothing with you.
- You become their data custodian. That means custody, not just hosting.
- **Retention:** delete a request N days after it is confirmed or declined (30 is plenty). Build
  this in from the start; retrofitting deletion is painful.
- **The form must say where the data goes** — e.g. "your name and number go to this trainer".
- **Do not** send client data into your Telegram support channel; the bot in §8 should carry the
  trainer's own data only, or a link back to the app.
- Encryption at rest is worth having, but note it is **not** end-to-end here: the server must read
  the availability to serve it, and read the request to list it. (Unlike the backup feature,
  where the blob can be opaque to the server.)

---

## 8. Notification

Under the §0 principle this stays **inside the app**.

- **v1 — in-app, deliberately.** A pending-requests list plus a badge that is visible the moment
  the app opens — the permanent backup card is the existing pattern for surfacing something on
  open, and can be followed. No push infrastructure, no new secret, nothing new to break.
- **The honest gap:** the trainer learns about a request when they next open the app, so a booking
  made for two hours' time can be missed. Accept that for v1, or close it with §8a.
- **§8a — web push, if that gap matters.** Real-time, and still "in the app" in the sense that it
  arrives as a system notification from the installed app, not a message in some other app. It
  needs a VAPID key pair, a service worker, a sender on the server, per-device subscriptions kept
  server-side — and on iOS it works only on 16.4+ **and only when installed**. Worth doing later,
  not first.
- **A Telegram bot would need none of that** and is the cheaper real-time option, but it makes the
  trainer switch apps, which §0 rules out. Keep it in reserve only.
- Unrelated to `navigator.storage` — do not conflate the two.

---

## 9. Hosting and reachability

- The public page needs a stable URL and **HTTPS** (a service worker and OPFS need a secure
  context). Without a domain, `nip.io` / `sslip.io` or a free DuckDNS name pointed at a VPS works.
- **Reachability, revised by the user (2026-09-28): everyone in Iran is on a VPN**, so a
  US-hosted or filtered provider is **not** the showstopper I first assumed. It still costs
  latency, and the *client's* page is opened by someone who did not choose their connection, so an
  Iranian or European host remains the nicer option — but this is now a cost/convenience trade-off
  to weigh, **not** a make-or-break risk. Confirm before building; do not treat my earlier
  framing as settled.
- Sanctioned providers still deserve care on the **account** side: Google Cloud / Firebase block
  Iranian IPs, which affects sign-up and billing even when your users are on a VPN.
- Keep the **trainer app's origin** where it is. The public page can live anywhere, but the app's
  origin is where every user's database lives.

---

## 10. Phasing

Each phase is independently useful, and none of them touch existing records.

**Phase 0 — availability editor, no server.**
Trainer defines windows; the app renders a shareable summary (text, or an image) to paste into
Telegram. Clients see the times and message the trainer to book.
*Done when:* a trainer can define and share their week, and the summary matches the editor.
*Value:* real, immediate, and it needs none of §5.

**Phase 1 — publish + public page.**
Server, codes, token auth, `PUT/GET availability`, the static public page. No requests yet, so the
public surface is read-only and nothing is written by strangers.
*Done when:* a client can open a link and see the correct week for a code, and the page is RTL and
usable on a phone.

**Phase 2 — requests.**
`POST requests`, rate limiting, the in-app pending list, confirm / decline. Still no writes to the
local database.
*Done when:* a request appears in the app and can be confirmed; junk can be declined; a flood
cannot grow storage without bound.

**Phase 3 — confirmed bookings become appointments.**
Confirm creates the appointment through `addSession`, optionally consuming a plan session.
*Done when:* the assign → deduct → remove cycle is tested for bookings exactly as it is for
manual attendance, so a removal refunds the right source.

**Phase 4 — operational.**
Telegram bot nudge; retention/deletion job; a small admin view listing trainers and codes.

---

## 11. Risks

| Risk | Why it matters | Mitigation |
|---|---|---|
| **Predictable public codes** | Schedules enumerable, bookings spammable | Random 6–8 char codes from day one (§5) |
| **Server unreachable from Iran** | Feature dead on arrival | Settle hosting before writing code (§9) |
| **Hours have no home in the schema** | Booking cannot be a first-class hour | Accept the blob compromise, or move this to the successor app |
| **Trainer misses a request** | Client books, trainer never sees it | Telegram nudge (§8) |
| **Privacy exposure** | Strangers' contact data on your server | Retention policy, minimal fields, clear form wording (§7) |
| **Availability goes stale** | Clients see times the trainer has since blocked | Publish on change; show "updated N days ago" on the public page |
| **Scope creep into sync** | Two-way merge over session accounting is a different project | §1 out-of-scope list |

---

## 12. Testing

- Availability blob: parse/serialise, closed-by-default, weekday mapping, overrides if added.
- The public page renders windows for a code and shows nothing for an unknown one.
- A request for a window that is **not** open is rejected by the server (the validation in §5).
- Rate limiting and the pending cap actually trigger.
- Confirm → appointment consumes one session; removing it refunds the correct source. **This is
  the same assign → deduct → remove cycle as manual attendance and must be proven, not assumed.**
- Offline: the app stays usable, publishing retries, nothing throws.

---

## 13. Open questions for you

1. **Window = one session, or split into sub-slots?** (§3)
2. **Should confirming a booking consume a plan session automatically**, or is that a per-booking
   choice?
3. **Where will the server live?** This needs answering before any code, for reachability (§9).
4. **Do you want Phase 0 first** — a shareable availability summary with no server at all — or
   straight to Phase 1?
5. **Retention window** for requests (§7) — 30 days?

---

## 14. Relationship to the other deferred work

The remote **auto-backup** and this booking feature would share the same infrastructure
(hosting, per-trainer identity, transport). Booking is the feature with demand; backup is
insurance against the failure that cost a user their data.

If both are wanted, build the server for booking and reuse it for backup afterwards — but keep
the backup blob **opaque and encrypted**, since the server has no reason to read it. That is a
different privacy posture from booking, where the server must read what it serves.
