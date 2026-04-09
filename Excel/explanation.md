📊 Excel Analysis – Ticket Data

🔹 Objective

Analyze ticket data to:

- Map ticket creation time to feedbacks
- Count tickets closed on same day and same hour
- Generate outlet-wise summary using Pivot Table

---

🔹 1. Populate "ticket_created_at"

We used INDEX + MATCH to fetch "created_at" from ticket sheet:

=INDEX(ticket!B:B, MATCH(A2, ticket!E:E, 0))

- "A2" → cms_id in feedbacks
- "ticket!E:E" → cms_id in ticket sheet
- "ticket!B:B" → created_at

---

🔹 2. Same Day Calculation

=IF(INT(B2)=INT(C2),1,0)

- Compares only date part
- Returns 1 if same day, else 0

---

🔹 3. Same Hour Calculation

=IF(TEXT(B2,"yyyy-mm-dd hh")=TEXT(C2,"yyyy-mm-dd hh"),1,0)

- Compares date + hour
- Returns 1 if same hour

---

🔹 4. Pivot Table

Used Pivot Table to calculate:

- Rows → outlet_id
- Values → SUM(same_day_flag), SUM(same_hour_flag)

This gives outlet-wise ticket counts.

---

🔹 Tools Used

- Microsoft Excel
- INDEX + MATCH
- Pivot Table

---
