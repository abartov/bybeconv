class ReplaceExpressionsWorksTableWithForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :expressions, :work, type: :integer

    execute <<~sql
      update expressions e set
        work_id = (select ew.work_id from expressions_works ew where e.id = ew.expression_id)
    sql

    drop_table :expressions_works

    add_foreign_key :expressions, :works, index: true

    change_column_null :expressions, :work_id, false
  end
end
