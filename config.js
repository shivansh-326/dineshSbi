/* Supabase connection. Get both values from: Supabase dashboard > Project Settings > API.
   The anon key is safe to publish: the database is protected by Row Level Security (see supabase/schema.sql).
   Leave the placeholders as they are to run the site in local demo mode (data saved only in your browser). */
window.SITE_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT-ID.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-PUBLIC-KEY"
};
