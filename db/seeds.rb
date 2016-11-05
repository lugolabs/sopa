# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Event.create([
  { event_type: 'opened', recipient: 'test1@example.com', country: 'UK', campaign_id: 'CMP_11', campaign_name: 'CMP_NM_11' },
  { event_type: 'opened', recipient: 'test2@example.com', country: 'UK', campaign_id: 'CMP_11', campaign_name: 'CMP_NM_11' },
  { event_type: 'clicked', recipient: 'test3@example.com', country: 'UK', campaign_id: 'CMP_11', campaign_name: 'CMP_NM_11' },
  { event_type: 'clicked', recipient: 'test4@example.com', country: 'UK', campaign_id: 'CMP_11', campaign_name: 'CMP_NM_11' }
])
