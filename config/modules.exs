use Mix.Config
# PRESS PRESS PRESS PRESS PRESS CARDI DON'T NEED MORE PRESS
# KILL EM ALL PUT THEM HOES TO REST WALK IN BULLETPROOF VEST

# Structure
# modules: %{
#   "guilds SCHEMA NAME" => %{   - needed for setting data (POST /set/SCHEMA NAME HERE)
#     function: {Hydrogen.Util, :write_guild}    -- Atoms are not sent to the front-end. Use them to make certain fields avaliable to the back-end only.
#                                                -- The function atom goes in the schema map, not inside modules! It's responsible for all database interactions in the entire schema.
#     "MODULE NAME" => %{   - This is the module name. To update field data, you'll also need this.
#       "FIELD" => %{       - This is the field name. If a field is received and it's not found on the category (or if it doesn't exist at all), hydrogen will just ignore it.
#          You can decide what goes in here.
#          This will be used by the function declared on the schema root.
#          Check the actual configuration being used by Chino below for reference.
#        }
#      }

config :hydrogen,
  modules: %{
    "guilds" => %{
      # The function responsible for database interaction in this schema.
      :function => {Hydrogen.Database, :write_guild},
      "general" => %{
        "prefix" => %{
          "translation_key" => "general.prefix",
          # 8 (admin) + 32 (manage guild) = either 8 or 32, doesn't matter
          "permissions" => 40,
          # input type
          "input_type" => "text",
          # Field location in the DB ({Collection, FieldName})
          :db_path => {"guilds", "prefix"},
          # Used to validate received values. The function indicated must return a bool ({Module, FunctionName})
          :validator => {Kernel, :is_bitstring}
        }
      }
    }
  }
