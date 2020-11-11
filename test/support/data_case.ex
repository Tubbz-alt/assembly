defmodule Assembly.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Assembly.Factories

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Assembly.DataCase

      alias Assembly.{InventoryRepo, Repo}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Assembly.InventoryRepo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Assembly.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Assembly.InventoryRepo, {:shared, self()})
      Ecto.Adapters.SQL.Sandbox.mode(Assembly.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end