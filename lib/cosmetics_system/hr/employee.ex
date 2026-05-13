defmodule CosmeticsSystem.HR.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  @departments ~w(management sales warehouse marketing finance)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "employees" do
    field :first_name, :string
    field :last_name, :string
    field :employee_number, :string
    field :department, :string
    field :position, :string
    field :salary, :decimal
    field :hired_on, :date
    field :terminated_on, :date
    field :phone, :string
    field :national_id, :string
    field :active, :boolean, default: true

    belongs_to :user, CosmeticsSystem.Accounts.User

    timestamps()
  end

  def full_name(%__MODULE__{first_name: f, last_name: l}), do: "#{f} #{l}"
  def active?(%__MODULE__{active: active}), do: active

  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [
      :first_name,
      :last_name,
      :employee_number,
      :department,
      :position,
      :salary,
      :hired_on,
      :terminated_on,
      :phone,
      :national_id,
      :active,
      :user_id
    ])
    |> validate_required([:first_name, :last_name, :department, :position, :hired_on])
    |> validate_inclusion(:department, @departments)
    |> maybe_generate_employee_number()
    |> unique_constraint(:employee_number)
    |> unique_constraint(:national_id)
  end

  defp maybe_generate_employee_number(changeset) do
    if is_nil(get_field(changeset, :employee_number)) do
      put_change(changeset, :employee_number, generate_number())
    else
      changeset
    end
  end

  defp generate_number do
    suffix = :rand.uniform(9999) |> Integer.to_string() |> String.pad_leading(4, "0")
    "EMP-#{suffix}"
  end
end
