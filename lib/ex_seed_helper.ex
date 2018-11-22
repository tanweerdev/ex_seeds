defmodule Ex.SeedHelper do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_) do
    quote do
      use Ecto.Migration

      # TODO: Add docs and examples for ex_doc
      def import_from_csv(
            csv_path,
            callback,
            should_coonvert_empty_to_nil \\ false,
            base_path \\ nil
          ) do
        base_path =
          if base_path == nil,
            do: Application.get_env(:ex_seeds, :repo)[:seed_base_path],
            else: base_path

        (csv_path <> ".csv")
        |> Path.expand(base_path)
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Stream.each(fn row ->
          row
          |> map_escap_sql(should_coonvert_empty_to_nil)
          |> callback.()
        end)
        |> Stream.run()
      end

      # TODO: Add docs and examples for ex_doc
      def map_escap_sql(map, should_coonvert_empty_to_nil) do
        for {key, value} <- map, into: %{} do
          case value do
            "null" ->
              {key, value}

            "" ->
              if should_coonvert_empty_to_nil do
                {key, "null"}
              else
                value =
                  value
                  |> String.replace("'", "''")

                {key, ~s('#{value}')}
              end

            _ ->
              value =
                value
                |> String.replace("'", "''")

              {key, ~s('#{value}')}
          end
        end
      end

      # TODO: Add docs and examples for ex_doc
      def map_to_table(map, table) do
        keys =
          map
          |> Map.keys()
          |> Enum.join(~s(", "))

        values =
          map
          |> Map.values()
          |> Enum.join(", ")

        Ecto.Migration.execute("INSERT INTO #{table} (\"#{keys}\") values (#{values})")
      end

      # TODO: Add docs and examples for ex_doc
      def reset_id_seq(table, id \\ "id") do
        Ecto.Migration.execute(
          "SELECT setval('#{table}_#{id}_seq', (SELECT MAX(#{id}) from \"#{table}\"));"
        )
      end
    end
  end
end
