defmodule UserManagementContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Agileparking.{Repo, Accounts.User}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Agileparking.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Agileparking.Repo, {:shared, self()})

    # Register and login new user for BDD tests
    [%{name: "sergi", email: "sergimartinez17@gmail.cat", license_number: "123456789", password: "123456", balance: "12", monthly_bill: "0"}]
    |> Enum.map(fn user_data -> User.changeset(%User{}, user_data) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Agileparking.Repo)
    Hound.end_session
  end

  given_ ~r/^I have the following email "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
    fn state, %{email: email,password: password} ->
      {:ok, state |>Map.put(:email, email)
                  |>Map.put(:password, password)
      }
  end

  and_ ~r/^I am on the login page$/, fn state ->
    navigate_to "/sessions/new"
    {:ok, state}
  end

  and_ ~r/^I fill in the account information$/, fn state ->
    fill_field({:id, "session_email"}, "sergimartinez17@gmail.cat")
        fill_field({:id, "session_password"}, "123456")
    :timer.sleep(1000)
    {:ok, state}
  end

  and_ ~r/^I fill in the account information with incorrect data$/, fn state ->
    fill_field({:id, "session_email"}, "sergimartinez1@gmail.cat")
        fill_field({:id, "session_password"}, "123456")
    :timer.sleep(1000)
    {:ok, state}
  end

  given_ ~r/^I have the incorrect credentials to login$/, fn state ->
    {:ok, state}
  end

  given_ ~r/^I have the correct credentials to login$/, fn state ->
    {:ok, state}
  end

  and_ ~r/^I press "(?<submit>[^"]+)"$/,
  fn state, %{submit: submit} ->
    click({:id, "submit_button"})
    :timer.sleep(1000)
    {:ok, state}
  end

  then_ ~r/^I should receive a confirmation message$/, fn state ->
    assert visible_in_page? ~r/Welcome sergimartinez17@gmail.cat/
    {:ok, state}
  end

  then_ ~r/^I should receive a rejection message  $/, fn state ->
    assert visible_in_page? ~r/Bad User Credentials/
    {:ok, state}
  end
  #Given I have the name "sergi" email "fred@gmail.com" password "parool2334dd56" and license_number "12345678910"

  given_ ~r/^I have the name "(?<argument_one>[^"]+)" email "(?<argument_two>[^"]+)" password "(?<argument_three>[^"]+)" and license_number "(?<argument_four>[^"]+)"$/,
  fn state, %{argument_one: argument_one,argument_two: argument_two,argument_three: argument_three,argument_four: argument_four} ->
    {:ok, state |>Map.put(:name, argument_one)
    |>Map.put(:email, argument_two)
    |>Map.put(:password, argument_three)
    |>Map.put(:license_number, argument_four)}
  end


  and_ ~r/^I am on the registration page$/, fn state ->
    navigate_to "/users/new"
     {:ok, state}
   end

   and_ ~r/^I fill in the registration information with correct data$/, fn state ->
    fill_field({:id, "user_name"}, "sergi")
    fill_field({:id, "user_email"}, "sergisergi@gmail.com")
    fill_field({:id, "user_license_number"}, "123456789")
    fill_field({:id, "user_password"}, "parool")
    {:ok, state}
   end

   when_ ~r/^I confirm my data by pressing "(?<argument_one>[^"]+)"$/,
      fn state, %{argument_one: _argument_one} ->
        click({:id, "submit_button"})
        {:ok, state}
    end

    then_ ~r/^I should receive a register confirmation message$/, fn state ->
      assert visible_in_page? ~r/User created successfully./
      {:ok, state}
    end

    then_ ~r/^I should receive a register error message  $/, fn state ->
      assert visible_in_page? ~r/Oops, something went wrong! Please check the errors below./
      {:ok, state}
    end

    given_ ~r/^I am logged in into the system$/, fn state ->
      navigate_to "/sessions/new"
      fill_field({:id, "session_email"}, "sergimartinez17@gmail.cat")
      fill_field({:id, "session_password"}, "123456")
      click({:id, "submit_button"})
      :timer.sleep(1000)
      {:ok, state}
    end

    when_ ~r/^I press logout$/, fn state ->
      click({:id, "logout_button"})
      {:ok, state}
    end

    then_ ~r/^I should receive a logout confirmation message$/, fn state ->
      assert visible_in_page? ~r/Welcome to Agileparking!/
      {:ok, state}
    end

    and_ ~r/^I fill in the registration information with incorrect data$/, fn state ->
      fill_field({:id, "user_name"}, "sergi")
      fill_field({:id, "user_email"}, "sergisergi")
      fill_field({:id, "user_license_number"}, "123456789")
      fill_field({:id, "user_password"}, "parool")
      {:ok, state}
    end

end
