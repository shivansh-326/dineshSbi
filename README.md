# Independent SBI Agent Website

Static website (GitHub Pages) + **Supabase** for the database (Postgres), file storage (photos, PDFs) and admin login. Both have free tiers.

```
index.html           the website + admin dashboard (open /#admin)
config.js            your Supabase URL + anon key
supabase/schema.sql  tables, security rules and storage bucket (run once)
```

## 1. Create the database (Supabase, ~5 min)
1. Sign up at https://supabase.com and create a new project.
2. Open **SQL Editor > New query**, paste `supabase/schema.sql`, change `agent@example.com` to the admin's email, and click **Run**.
3. Go to **Authentication > Users > Add user**, create a user with that same email and a password (tick "Auto confirm").
4. Go to **Authentication > Sign In / Providers** and turn **off** "Allow new users to sign up" (only you can log in).
5. Go to **Project Settings > API** and copy the **Project URL** and the **anon public** key into `config.js`.

## 2. Deploy on GitHub Pages
1. Create a GitHub repository and push these files.
2. In the repo: **Settings > Pages > Source: Deploy from a branch > main / (root)**.
3. The site is live at `https://<username>.github.io/<repo>/` after a minute.

## 3. Use it
- Admin dashboard: open `https://<your-site>/#admin` and sign in.
- On the first admin login the built-in content (profile, services, 3 sample policies) is copied into the database automatically. After that, everything you add, edit, publish or delete is stored in Supabase and visible to all visitors.
- Uploaded photos and PDFs go to the Supabase `media` storage bucket.

## Security notes
- The anon key in `config.js` is meant to be public. Writes are only allowed for emails listed in the `admins` table (Row Level Security).
- Visitors can only read published policies/testimonials and active services.
- To add another admin: `insert into admins (email) values ('other@example.com');` and create that user in Authentication.

## Local testing
Run `python3 -m http.server` in this folder and open http://localhost:8000. If `config.js` still has the placeholders, the site runs in **demo mode** (data saved only in your browser, login `admin@demo.com` / `Admin@123`).
