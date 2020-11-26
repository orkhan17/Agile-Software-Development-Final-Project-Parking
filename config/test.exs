use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :agileparking, Agileparking.Repo,
  username: "postgres",
<<<<<<< HEAD
  password: "postgres",
  database: "agileparking_test7#{System.get_env("MIX_TEST_PARTITION")}",
=======
  password: "orkhan97",
  database: "agileparking_test#{System.get_env("MIX_TEST_PARTITION")}",
>>>>>>> 1fb819a34ac28e61bf83eb9e9d53c6c3b0476e34
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :agileparking, AgileparkingWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn


config :hound, driver: "chrome_driver"
config :takso, sql_sandbox: true
