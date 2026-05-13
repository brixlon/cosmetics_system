defmodule CosmeticsSystem.CRM.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @loyalty_tiers ~w(bronze silver gold platinum)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "customers" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :date_of_birth, :date
    field :loyalty_tier, :string, default: "bronze"
    field :loyalty_points, :integer, default: 0
    field :notes, :string
    field :opted_in_marketing, :boolean, default: false

    belongs_to :user, CosmeticsSystem.Accounts.User
    has_many :addresses, CosmeticsSystem.CRM.Address
    has_many :orders, CosmeticsSystem.Orders.Order

    timestamps()
  end

  def full_name(%__MODULE__{first_name: f, last_name: l}), do: "#{f} #{l}"

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :first_name,
      :last_name,
      :phone,
      :date_of_birth,
      :loyalty_tier,
      :loyalty_points,
      :notes,
      :opted_in_marketing,
      :user_id
    ])
    |> validate_required([:first_name, :last_name, :user_id])
    |> validate_inclusion(:loyalty_tier, @loyalty_tiers)
    |> validate_length(:phone, max: 20)
    |> unique_constraint(:user_id)
  end

  def add_points(customer, points) do
    new_points = customer.loyalty_points + points

    tier =
      cond do
        new_points >= 10_000 -> "platinum"
        new_points >= 5_000 -> "gold"
        new_points >= 1_000 -> "silver"
        true -> "bronze"
      end

    customer
    |> change(%{loyalty_points: new_points, loyalty_tier: tier})
  end
end
