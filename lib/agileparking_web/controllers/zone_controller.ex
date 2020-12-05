defmodule AgileparkingWeb.ZoneController do
    use AgileparkingWeb, :controller
    import Ecto.Query
    alias Agileparking.Repo
    alias Agileparking.Sales.Zone
    alias Agileparking.Bookings.Booking
    alias Agileparking.Forms.Zoneform
    alias Ecto.{Changeset, Multi}
    def is_time(time) do
        case Time.from_iso8601(time) do
          {:ok, t} -> true
          _ -> false
        end
    end


    def get_time(time) do
        case Time.from_iso8601(time) do
          {:ok, t} -> t
          _ -> false
        end
    end

    def show(conn, %{"id" => id}) do
        zone = Repo.get!(Zone, id)
        render(conn, "show.html", zone: zone)
    end



    def distance(placeA, placeB) do
        pointA = Agileparking.Geolocation.find_location(placeA)
        pointB = Agileparking.Geolocation.find_location(placeB)
        distance = Agileparking.Geolocation.distance(placeA, placeB)
        Enum.at(distance,0)
    end

    def index(conn, _params) do
        changeset = Zoneform.changeset(%Zoneform{}, %{})
        render(conn, "index.html", type: 3)
    end

    def create(conn, params) do
        type = 0
        zones = Repo.all(Zone)
        address = params["name"]
        time = params["time"]
        milis = "00"
        time = "#{time}:#{milis}"
        now = Time.utc_now()
        now = Time.add(now, 7200, :second)
        p =  Agileparking.Geolocation.find_location(address)
        if Enum.at(p,0) == -1 do
            zones = Enum.map(zones, fn zone  -> {zone, -1,2, 0, 0} end)
            render(conn, "index.html", zones: zones,type: 0)
        end

        if is_time(time) do
            tt = get_time(time)
            if (tt.minute + tt.hour*60) <= (now.minute + now.hour*60) do
                zones = Enum.map(zones, fn zone  -> {zone, distance(params["name"], zone.name),0,0, 0} end)
                render(conn, "index.html", zones: zones, type: 1)
            else
                zones = Enum.map(zones, fn zone  -> {zone, distance(params["name"], zone.name),0,((zone.realTimePrice*((tt.minute + tt.hour*60) - (now.minute + now.hour*60)))/100), zone.hourlyPrice*tt.hour - now.hour} end)
                render(conn, "index.html", zones: zones, type: 2)
            end
        else
            p =  Agileparking.Geolocation.find_location(address)
            IO.puts "CAIC AQUI FIJO JODER"
            zones = Enum.map(zones, fn zone  -> {zone, distance(params["name"], zone.name),0,0, 0} end)
            render(conn, "index.html", zones: zones, type: 1)
        end
    end




      def edit(conn, %{"id" => id}) do
        zone = Repo.get!(Zone, id)
        changeset = Zone.changeset(zone, %{})

        render(conn, "edit.html", zone: zone, changeset: changeset)
      end

      def update(conn, %{"id" => id, "zone" => zone_params}) do
        user = Agileparking.Authentication.load_current_user(conn)
        # map1 = %{}
        # map1 = Map.put(map1, :payment_status, zone_params["payment_status"])
        # map1 = Map.put(map1, :start_date, "1234a")
        # map1 = Map.put(map1, :end_date, "1234a")
        # map1 = Map.put(map1, :zone_type, "1")

        #changeset = Booking.changeset(%Booking{}, map1)
        zone = Repo.get!(Zone, id)


        case zone.available == true do
          true ->
              booking_struct = Ecto.build_assoc(user, :bookings, Enum.map(zone_params, fn({key, value}) -> {String.to_atom(key), value} end))
              changeset1 = Booking.changeset(booking_struct, zone_params)
              map = %{}
              map = Map.put(map, :available, false)
              changeset2 = Zone.changeset(zone, map)
              Multi.new
                |> Multi.insert(:booking, Booking.changeset(changeset1))
                |> Multi.update(:zone, Zone.changeset(changeset2))
                |> Repo.transaction

              conn
              |> put_flash(:info, "Booked successfully.")
              |> redirect(to: Routes.page_path(conn, :index))


            _ -> conn
              |> put_flash(:error, "There is no an available slot. Please choose new parking area")
              |> redirect(to: Routes.zone_path(conn, :index))

        end


      end

  end
