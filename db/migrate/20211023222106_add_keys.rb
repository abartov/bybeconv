class AddKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key "manifestations_people", "manifestations", name: "manifestations_people_manifestation_id_fk"
    add_foreign_key "manifestations_people", "people", name: "manifestations_people_person_id_fk"
    add_foreign_key "people", "tocs", name: "people_toc_id_fk"
    add_foreign_key "proofs", "html_files", name: "proofs_html_file_id_fk"
    add_foreign_key "proofs", "manifestations", name: "proofs_manifestation_id_fk"
    add_foreign_key "proofs", "users", column: "resolved_by", name: "proofs_resolved_by_fk"
    add_foreign_key "recommendations", "users", column: "approved_by", name: "recommendations_approved_by_fk"
    add_foreign_key "taggings", "users", column: "approved_by", name: "taggings_approved_by_fk"
    add_foreign_key "taggings", "manifestations", name: "taggings_manifestation_id_fk"
    add_foreign_key "taggings", "users", column: "suggested_by", name: "taggings_suggested_by_fk"
    add_foreign_key "taggings", "tags", name: "taggings_tag_id_fk"
    add_foreign_key "tags", "users", column: "created_by", name: "tags_created_by_fk"
    add_foreign_key "work_likes", "manifestations", name: "work_likes_manifestation_id_fk"
    add_foreign_key "work_likes", "users", name: "work_likes_user_id_fk"
  end
end
