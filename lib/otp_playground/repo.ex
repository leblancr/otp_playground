defmodule OtpPlayground.Repo do
  use Ecto.Repo,
      otp_app: :otp_playground,
      adapter: Ecto.Adapters.Postgres
end