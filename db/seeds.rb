# db/seeds.rb
require 'faker'

# Clear tables in order to prevent foreign key constraint errors
Locker.destroy_all
Manager.destroy_all
Metric.destroy_all
User.destroy_all
Predictor.destroy_all


# Create a Default Model for the Superuser


# Create an Admin Superuser
User.create!(
  email: 'admin@example.com',             # Admin email
  username: 'admin',
  first_name: 'Admin',
  last_name: 'User',
  password: '123123',                     # Superuser password
  password_confirmation: '123123',        # Password confirmation
  super_user: true,                       # Mark as superuser
)


# Create Additional Gesture Models










puts "Seeding completed: 3 records created for each entity and an admin user added."
