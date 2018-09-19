# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.new(name: 'test_user', email: 'asaf.bartov@gmail.com', provider: 'developer', uid: 'asaf.bartov@gmail.com', editor: false, admin: false)
u.save!
u = User.new(name: 'test_editor', email: 'asafbartov@gmail.com', provider: 'developer', uid: 'asafbartov@gmail.com', editor: true, admin: false)
u.save!
u = User.new(name: 'test_admin', email: 'asaf.bartov+admin@gmail.com', provider: 'developer', uid: 'asaf.bartov+admin@gmail.com', editor: true, admin: true)
u.save!

