defmodule URLShortener.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string, null: false
      add :slug, :string, null: false
      add :hits, :integer, null: false, default: 0

      timestamps()
    end

    create index(:links, [:slug], unique: true)
  end
end
