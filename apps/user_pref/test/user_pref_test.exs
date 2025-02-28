defmodule UserPrefTest do
  use UserPref.DataCase

  describe "&get_user/1" do
    test "errors gracefully with invalid id" do
      expected =
        Error.not_found("not found", %{id: 42})

      {:error, actual} = UserPref.get_user(42)
      assert actual === expected
    end
  end

  describe "&create_user/1" do
    test "errors gracefully with invalid params" do
      expected =
        Error.unprocessable_entity("invalid request data")

      {:error, actual} = UserPref.create_user(%{email: nil})
      assert actual.code === expected.code
      assert actual.message === expected.message
    end
  end

  describe "&create_avatar/1" do
    test "errors gracefully with invalid params" do
      expected =
        Error.unprocessable_entity("invalid request data")

      {:error, actual} = UserPref.create_avatar(%{url: nil})
      assert actual.code === expected.code
      assert actual.message === expected.message
    end

    test "errors gracefully with missing user_id" do
      expected =
        Error.unprocessable_entity("invalid request data")

      {:error, actual} = UserPref.create_avatar(%{url: "https://example.com/avatar.jpg"})
      assert actual.code === expected.code
      assert actual.message === expected.message
    end

    test "creates avatar successfully with valid params" do
      %User{id: user_id} = Fixtures.user_fixture()

      params = %{
        url: "https://example.com/avatar.jpg",
        username: "test_user",
        title: "Profile Picture",
        user_id: user_id
      }

      assert {:ok, %UserPref.Avatar{} = avatar} = UserPref.create_avatar(params)
      assert avatar.url === params.url
      assert avatar.username === params.username
      assert avatar.title === params.title
      assert avatar.user_id === user_id
    end
  end

  describe "&update_user/1" do
    test "errors gracefully with invalid id" do
      expected =
        Error.not_found("not found", %{id: 42})

      {:error, actual} = UserPref.update_user(%{id: 42, email: nil})
      assert actual === expected
    end

    test "errors gracefully with invalid params" do
      %User{id: id} = Fixtures.user_fixture()

      expected =
        Error.unprocessable_entity("invalid request data")

      {:error, actual} = UserPref.update_user(%{id: id, email: nil})
      assert actual.code === expected.code
      assert actual.message === expected.message
    end
  end

  describe "&update_pref/1" do
    test "errors gracefully with empty params" do
      params = %{}

      expected =
        Error.unprocessable_entity("invalid request data", %{params: params})

      {:error, actual} = UserPref.update_pref(params)
      assert actual === expected
    end

    test "errors gracefully with invalid user_id" do
      params = %{user_id: -1}

      expected =
        Error.not_found("no records found", %{params: params, query: UserPref.Pref})

      {:error, actual} = UserPref.update_pref(params)

      assert actual === expected
    end

    test "skip errors with invalid params" do
      %User{id: id} = Fixtures.user_fixture(%{likes_emails: false})

      params = %{user_id: id, invalid_attr: true, likes_emails: true}

      {:ok, actual} = UserPref.update_pref(params)
      assert actual.likes_emails
    end
  end

  describe "&create_many/3" do
    test "errors gracefully when some entries are invalid" do
      %User{id: user_id} = Fixtures.user_fixture()

      valid_entry = %{
        id: "CjmvTCZf2U3p09Cn0h",
        url: "https://example.com/avatar1.jpg",
        username: "user1",
        title: "Avatar 1",
        user_id: user_id
      }

      invalid_entry = %{
        id: "CjmvTCZf2U3p09Cn0c",
        url: nil,
        username: "user2",
        title: "Avatar 2",
        user_id: user_id
      }

      another_valid_entry = %{
        id: "CjmvTCZf2U3p09Cn0r",
        url: "https://example.com/avatar3.jpg",
        username: "user3",
        title: "Avatar 3",
        user_id: user_id
      }

      params = [valid_entry, invalid_entry, another_valid_entry]

      expected_error = %ErrorMessage{
        code: :unprocessable_entity,
        message: "Failed to create_many_user_pref/avatar_0"
      }

      {:error, actual} = UserPref.create_many(UserPref.Avatar, params)

      assert actual.code === expected_error.code
      assert actual.message === expected_error.message
    end

    test "creates multiple avatars successfully with valid params" do
      %User{id: user_id} = Fixtures.user_fixture()

      params = [
        %{
          url: "https://example.com/avatar1.jpg",
          username: "user1",
          title: "Avatar 1",
          user_id: user_id
        },
        %{
          url: "https://example.com/avatar2.jpg",
          username: "user2",
          title: "Avatar 2",
          user_id: user_id
        }
      ]

      assert {:ok, result} = UserPref.create_many(UserPref.Avatar, params)

      for {avatar_params, index} <- Enum.with_index(params) do
        operation_key = "create_many_user_pref/avatar_#{index}"

        assert Map.has_key?(result, operation_key)
        avatar = Map.fetch!(result, operation_key)

        assert avatar.url === avatar_params.url
        assert avatar.username === avatar_params.username
        assert avatar.user_id === user_id
      end
    end
  end
end
