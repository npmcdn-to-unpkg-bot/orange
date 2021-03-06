require 'rails_helper'

RSpec.describe 'exercises overview', type: :feature, js: true do
  before :each do
    @user = create(:user)
    date = Date.new(2016, 1, 1)
    reps = 20
    (1..10).each do |i|
      create(:push_up, user: @user, date: date, repetitions: reps)
      create(:sit_up, user: @user, date: date, repetitions: reps + 10)
      date += 1.day
      reps += i.even? ? rand.to_i : rand.to_i * -1
    end
    login_as(@user, scope: :user)
  end

  it 'does not allow another user to edit a push up entry' do
    real_user = create(:user)
    push_up = real_user.push_ups.create(date: Date.new(2016, 1, 1), repetitions: 15)
    visit exercises_path
    page.accept_alert 'You do not have permissions to edit this entry' do
      page.execute_script %{ $.ajax({ url: '/exercises/#{push_up.id}/edit' }) }
    end
  end

  it 'does not allow another user to edit a sit up entry' do
    real_user = create(:user)
    sit_up = real_user.sit_ups.create(date: Date.new(2016, 1, 1), repetitions: 15)
    visit exercises_path
    page.accept_alert 'You do not have permissions to edit this entry' do
      page.execute_script %{ $.ajax({ url: '/exercises/#{sit_up.id}/edit' }) }
    end
  end

  it 'allows to create a new push-up entry' do
    visit exercises_path
    click_link 'Add Push-Up'
    within('#form') do
      fill_in 'Repetitions', with: 17
      fill_in 'Duration', with: 180
      fill_in 'Date', with: '2016-01-01'
      page.execute_script %{ $("a.ui-state-default:contains('28')").trigger("click") }
      click_button 'Create Exercise'
    end
    wait_for_ajax
    expect(@user.push_ups.count).to eq(11)
    expect(@user.push_ups.last.repetitions).to eq(17)
    expect(@user.push_ups.last.duration).to eq(180)
    expect(@user.push_ups.last.date).to eq(Date.new(2016, 1, 28))
    expect(page).to have_content 'Exercise successfully created.'
    expect(current_path).to eq(exercises_path)
  end

  it 'allows to create a new sit-up entry' do
    visit exercises_path
    click_link 'Add Sit-Up'
    within('#form') do
      fill_in 'Repetitions', with: 27
      fill_in 'Duration', with: 150
      fill_in 'Date', with: '2016-02-01'
      page.execute_script %{ $("a.ui-state-default:contains('27')").trigger("click") }
      click_button 'Create Exercise'
    end
    wait_for_ajax
    expect(@user.sit_ups.count).to eq(11)
    expect(@user.sit_ups.last.repetitions).to eq(27)
    expect(@user.sit_ups.last.duration).to eq(150)
    expect(@user.sit_ups.last.date).to eq(Date.new(2016, 2, 27))
    expect(page).to have_content 'Exercise successfully created.'
    expect(current_path).to eq(exercises_path)
  end

  it 'allows to edit an existing push-up entry' do
    visit exercises_path
    push_up = @user.push_ups.first
    page.execute_script %{ showModal({ options: { url: '/exercises/#{push_up.id}/edit'}}) }
    within('#form') do
      fill_in 'Repetitions', with: 27
      fill_in 'Duration', with: 150
      fill_in 'Date', with: '2016-02-01'
      page.execute_script %{ $("a.ui-state-default:contains('27')").trigger("click") }
      click_button 'Update Exercise'
    end
    wait_for_ajax
    expect(@user.push_ups.count).to eq(10)
    push_up = PushUp.find(push_up.id)
    expect(push_up.repetitions).to eq(27)
    expect(push_up.duration).to eq(150)
    expect(push_up.date).to eq(Date.new(2016, 2, 27))
    expect(page).to have_content 'Exercise successfully updated.'
    expect(current_path).to eq(exercises_path)
  end

  it 'allows to edit an existing sit-up entry' do
    visit exercises_path
    sit_up = @user.sit_ups.first
    page.execute_script %{ showModal({ options: { url: '/exercises/#{sit_up.id}/edit'}}) }
    within('#form') do
      fill_in 'Repetitions', with: 27
      fill_in 'Duration', with: 150
      fill_in 'Date', with: '2016-02-01'
      page.execute_script %{ $("a.ui-state-default:contains('27')").trigger("click") }
      click_button 'Update Exercise'
    end
    wait_for_ajax
    expect(@user.sit_ups.count).to eq(10)
    sit_up = SitUp.find(sit_up.id)
    expect(sit_up.repetitions).to eq(27)
    expect(sit_up.duration).to eq(150)
    expect(sit_up.date).to eq(Date.new(2016, 2, 27))
    expect(page).to have_content 'Exercise successfully updated.'
    expect(current_path).to eq(exercises_path)
  end

  it 'allows to delete an existing push-up entry' do
    visit exercises_path
    push_up = @user.push_ups.first
    page.execute_script %{ showModal({ options: { url: '/exercises/#{push_up.id}/edit'}}) }
    within('#form') do
      click_link 'Delete'
    end
    wait_for_ajax
    expect(@user.push_ups.count).to eq(9)
    expect(page).to have_content 'Exercise successfully deleted.'
    expect(current_path).to eq(exercises_path)
  end

  it 'allows to delete an existing sit-up entry' do
    visit exercises_path
    sit_up = @user.sit_ups.first
    page.execute_script %{ showModal({ options: { url: '/exercises/#{sit_up.id}/edit'}}) }
    within('#form') do
      click_link 'Delete'
    end
    wait_for_ajax
    expect(@user.sit_ups.count).to eq(9)
    expect(page).to have_content 'Exercise successfully deleted.'
    expect(current_path).to eq(exercises_path)
  end
end
