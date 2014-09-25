defmodule MicroMacro.Sup do

  defmacro defsup(name, opts, body) do
    quote do
      defmodule unquote(name) do
        use Supervisor

        if unquote(opts[:link]) do
          def start_link do
            Supervisor.start_link(__MODULE__, [], unquote(opts[:link]))
          end
        else
          def start_link do
            Supervisor.start_link(__MODULE__, [])
          end
        end

        def init([]) do
          unquote(body[:do])
        end

      end
    end
  end

  defmacro defsofo(name, child_module) do
    quote do
      defmodule unquote(name) do
        use Supervisor

        def start_link do
          Supervisor.start_link(__MODULE__, [], name: __MODULE__)
        end

        def init([]) do
          supervise([worker(unquote(child_module), [])],
                    strategy: :simple_one_for_one)
        end
      end
    end
  end

end
