# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Agent.create!(name:  "Example Agent",
              email: "example@capitolhill.ca",
              password:              "foobarbaz",
              password_confirmation: "foobarbaz",
              admin: true,
              confirmation_token: "SomeToken001",
              confirmed_at: Time.zone.now,
              confirmation_sent_at: Time.zone.now) 

