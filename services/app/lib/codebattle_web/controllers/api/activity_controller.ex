defmodule CodebattleWeb.Api.V1.ActivityController do
  @all [:index, :show]

  use CodebattleWeb, :controller

  alias Codebattle.{Repo, User, UserGame}
  import Ecto.Query, only: [from: 2]

  defmacro to_char(field, format) do
    quote do
      fragment("to_char(?, ?)", unquote(field), unquote(format))
    end
  end

  plug(CodebattleWeb.Plugs.RequireAuth when action in @all)

  def show(conn, %{"user_id" => user_id}) do
    query =
      from(ug in UserGame,
        where: ug.user_id == ^user_id,
        group_by: to_char(ug.inserted_at, "YYYY-mm-dd"),
        select: %{date: to_char(ug.inserted_at, "YYYY-mm-dd"), count: count(ug.id)}
      )

    activities = Repo.all(query)
    json(conn, %{activities: activities})
  end
end
