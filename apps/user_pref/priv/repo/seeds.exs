alias UserPref.Repo
alias UserPref.User
alias UserPref.Pref
alias UserPref.Avatar

num_users = 200
avatars_per_user = 30

Repo.delete_all(Avatar, timeout: :infinity)
Repo.delete_all(Pref, timeout: :infinity)
Repo.delete_all(User, timeout: :infinity)
Repo.query!("TRUNCATE TABLE avatars, prefs, users RESTART IDENTITY CASCADE;")

# Insert Users
case Repo.query(
       """
         INSERT INTO users (first_name, last_name, email, inserted_at, updated_at)
         SELECT
           'User_' || i,
           'Test',
           'user_' || i || '@example.com',
           NOW(),
           NOW()
         FROM generate_series(1, $1) as i;
       """,
       [num_users],
       log: false,
       timeout: :infinity
     ) do
  {:ok, result} ->
    IO.puts("✅ Inserting users succeeded! Rows affected: #{result.num_rows}")

  {:error, error} ->
    IO.puts("❌ Inserting users failed: #{inspect(error)}")
end

# Insert Preferences
case Repo.query(
       """
         INSERT INTO prefs (likes_emails, likes_phone_calls, likes_faxes, user_id, inserted_at, updated_at)
         SELECT DISTINCT ON (u.id)
           random() > 0.5,
           random() > 0.5,
           random() > 0.5,
           u.id,
           NOW(),
           NOW()
         FROM users u
         WHERE u.id <= $1
         ORDER BY u.id;
       """,
       [num_users],
       log: false,
       timeout: :infinity
     ) do
  {:ok, result} ->
    IO.puts("✅ Inserting preferences succeeded! Rows affected: #{result.num_rows}")

  {:error, error} ->
    IO.puts("❌ Inserting preferences failed: #{inspect(error)}")
end

# Insert Avatars (Synthetic Data for Each User)
case Repo.query(
       """
         INSERT INTO avatars (remote_id, title, url, username, user_id, inserted_at, updated_at)
         SELECT
           md5(random()::text),  -- Synthetic remote_id
           'Avatar ' || a.i,
           'https://example.com/avatar_' || a.i || '.jpg',
           CASE WHEN random() > 0.7 THEN 'user_' || u.id ELSE '' END, -- Random username
           u.id,
           NOW(),
           NOW()
         FROM users u
         CROSS JOIN generate_series(1, $1) AS a(i)
         WHERE u.id <= $2;
       """,
       [avatars_per_user, num_users],
       log: false,
       timeout: :infinity
     ) do
  {:ok, result} ->
    IO.puts("✅ Inserting avatars succeeded! Rows affected: #{result.num_rows}")

  {:error, error} ->
    IO.puts("❌ Inserting avatars failed: #{inspect(error)}")
end
