defmodule Auth.Token do
  alias Auth.Token.JWT

  defdelegate validate(token, secret), to: JWT
  defdelegate create(token, secret), to: JWT
end
