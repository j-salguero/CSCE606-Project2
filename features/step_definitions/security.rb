Given("I am on the login page") do
  visit "/"   
end

Given('a user exists with name {string}, email {string}, password {string}') do |name, email, password|
  User.where(email: email).delete_all
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password
  )
end

When('I sign up with name {string}, email {string}, password {string}') do |name, email, password|
  fill_in "Name", with: name
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in "Confirm Password", with: password
  click_button "Create Account"
end

When('I log in with email {string} and password {string}') do |email, password|
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Login"
end

Then('I should be logged in as username {string}') do |username|
  expect(page).to have_content(username)
  expect(page).to have_content("My Vinyl Space")
end

When("I log out") do
  click_link("Log Out") rescue nil
  click_link("Logout") rescue nil
  click_link("Sign Out") rescue nil
  click_link("Log off") rescue nil

  first(:link, /log\s*out|sign\s*out/i)&.click rescue nil

  first('a[href*="logout"], a[href*="sign_out"]', match: :first)&.click rescue nil

  first('a[data-method="delete"]', match: :first)&.click rescue nil
end


