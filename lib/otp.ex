defmodule MicroMacro.OTP do
  defmacro ginit(opts, body) do
    quote do
      def init(unquote(opts)) do
        {k, state} = unquote(body[:do])
        for p <- k do
          IO.inspect(p)
          :gproc.reg(p)
        end
        {:ok, state}
      end
    end
  end

  defmacro defwrite(req, from, state, body) do
    quote do
      def handle_call(unquote(req), unquote(from), unquote(state)) do
        result = unquote(body[:do])
        state1 =
          case elem(result, 0) do
            :reply   -> elem(result, 2)
            :noreply -> elem(result, 1)
            :stop    -> elem(result, 3)
          end
        ArchJS.Persist.update(otp_id(state1), state1)
        result
      end
    end
  end

  defmacro defwrite(req, state, body) do
    quote do
      def handle_cast(unquote(req), unquote(state)) do
        result = unquote(body[:do])
        state1 =
          case elem(result, 0) do
            :noreply -> elem(result, 1)
            :stop    -> elem(result, 2)
          end
        ArchJS.Persist.update(otp_id(state1), state1)
        result
      end
    end
  end

  defmacro export_state do
    quote do
      def get_state(ref \\ __MODULE__) do
        GenServer.call ref, :get_state
      end

      def handle_call(:get_state, _, state) do
        {:reply, state, state}
      end
    end
  end

end
