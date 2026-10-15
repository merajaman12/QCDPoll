# Picnic Time Poll — one vote per WhatsApp number

## Features
- Required full name and WhatsApp number
- Accepts Pakistani formats such as `03001234567`, `923001234567`, or `+923001234567`, normalizing to `+923001234567`
- Fixed options: `2:30pm - 7pm` and `2:30pm - 9pm`
- Menu opinion and comment fields
- Supabase unique constraint blocks duplicate submissions for the same normalized WhatsApp number
- Only authenticated admin accounts listed in `admin_users` can read response records
- Combined poll totals

## Setup
1. In Supabase SQL Editor, run `supabase.sql` on a **new/empty poll table**.
2. Create the admin account in Supabase Authentication.
3. Copy the admin user's UUID and run the `insert into public.admin_users...` statement at the end of the SQL.
4. In Supabase Project Settings → API, copy the Project URL and anon/public key.
5. Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_PUBLIC_KEY` in `index.html`.
6. Upload `index.html` to your GitHub repository and enable GitHub Pages.

## If you ran the earlier SQL already
Do not blindly rerun the whole SQL. The old table may have responses without names/phone numbers. Review the migration comments in `supabase.sql`; backfill existing records before enforcing `NOT NULL` and unique constraints. Existing duplicate phone numbers must be resolved first.

## Security and privacy
- Database unique constraint, not just frontend logic, prevents duplicate phone submissions.
- RLS protects full response data. Do not create public SELECT access to `picnic_responses`.
- Only use the anon/public key in the frontend. Never use the service_role key.
- This is not strong identity verification: people may use another person's number. For higher assurance, verify the number with an OTP service.
