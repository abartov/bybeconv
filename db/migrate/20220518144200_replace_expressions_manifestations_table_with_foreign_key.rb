class ReplaceExpressionsManifestationsTableWithForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :manifestations, :expression, type: :integer

    execute <<~sql
      update manifestations m set
        expression_id = (select em.expression_id from expressions_manifestations em where m.id = em.manifestation_id)
    sql
    add_foreign_key :manifestations, :expressions, index: true
    change_column_null :manifestations, :expression_id, false
    drop_table :expressions_manifestations
  end
end
