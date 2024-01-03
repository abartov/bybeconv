require 'rails_helper'

RSpec.describe "corporate_bodies/edit", type: :view do
  before(:each) do
    @corporate_body = assign(:corporate_body, CorporateBody.create!(
      name: "MyString",
      alternate_names: "MyString",
      location: "MyString",
      inception: "MyString",
      inception_year: 1,
      dissolution: "MyString",
      dissolution_year: 1,
      wikidata_uri: "MyString",
      viaf_id: "MyString",
      comments: "MyText"
    ))
  end

  it "renders the edit corporate_body form" do
    render

    assert_select "form[action=?][method=?]", corporate_body_path(@corporate_body), "post" do

      assert_select "input[name=?]", "corporate_body[name]"

      assert_select "input[name=?]", "corporate_body[alternate_names]"

      assert_select "input[name=?]", "corporate_body[location]"

      assert_select "input[name=?]", "corporate_body[inception]"

      assert_select "input[name=?]", "corporate_body[inception_year]"

      assert_select "input[name=?]", "corporate_body[dissolution]"

      assert_select "input[name=?]", "corporate_body[dissolution_year]"

      assert_select "input[name=?]", "corporate_body[wikidata_uri]"

      assert_select "input[name=?]", "corporate_body[viaf_id]"

      assert_select "textarea[name=?]", "corporate_body[comments]"
    end
  end
end
