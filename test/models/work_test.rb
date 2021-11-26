require 'test_helper'

class WorkTest < ActiveSupport::TestCase
  test 'works_about returns all works written about given work' do
    work = create(:work)
    about_1 = create(:work)
    create(:aboutness, work: about_1, aboutable: work)
    about_2 = create(:work)
    create(:aboutness, work: about_2, aboutable: work)

    assert_equal [about_1, about_2], work.works_about.order(:id).to_a
  end
end
