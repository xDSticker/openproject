#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe 'Role creation', type: :feature, js: true do
  let!(:admin) { FactoryBot.create(:admin) }
  let!(:existing_role) { FactoryBot.create(:role) }
  let!(:existing_workflow) { FactoryBot.create(:workflow_with_default_status, role: existing_role, type: type) }
  let!(:type) { FactoryBot.create(:type) }
  let!(:non_member) do
    FactoryBot.create(:non_member, permissions: %i[view_work_packages view_wiki_pages])
  end

  before do
    login_as(admin)
  end

  it 'allows creating roles and handles errors' do
    visit roles_path

    within '.toolbar-item' do
      click_link 'Role'
    end

    fill_in 'Name', with: existing_role.name
    select existing_role.name, from: 'Copy workflow from'
    check 'Edit work packages'
    check 'Edit project'

    click_button 'Create'

    expect(page)
      .to have_selector('.errorExplanation', text: 'Name has already been taken')

    fill_in 'Name', with: 'New role name'

    # This will lead to an error as manage versions requires view versions
    check 'Manage members'

    click_button 'Create'

    expect(page)
      .to have_selector('.errorExplanation',
                        text: "Permissions need to also include 'View members' as 'Manage members' is selected.")

    check 'View members'
    select existing_role.name, from: 'Copy workflow from'

    click_button 'Create'

    expect(page)
      .to have_selector('.notice', text: 'Successful creation.')

    expect(page)
      .to have_current_path(roles_path)

    expect(page)
      .to have_selector('table td', text: 'New role name')

    click_link 'New role name'

    expect(page)
      .to have_checked_field('Edit work packages')
    expect(page)
      .to have_checked_field('Edit project')
    expect(page)
      .to have_checked_field('Manage members')
    expect(page)
      .to have_checked_field('View members')

    # By default as Non Member has that permissions
    expect(page)
      .to have_checked_field('View work packages')
    expect(page)
      .to have_checked_field('View wiki')

    expect(page)
      .to have_unchecked_field('Select types')
    expect(page)
      .to have_unchecked_field('Delete watchers')

    # Workflow should be copied over.
    # Workflow routes are not resource-oriented.
    visit(url_for(controller: :workflows, action: :edit, only_path: true))

    select 'New role name', from: 'Role'
    select type.name, from: 'Type'
    click_button 'Edit'

    from_id = existing_workflow.old_status_id
    to_id = existing_workflow.new_status_id

    checkbox = page.find("input.old-status-#{from_id}.new-status-#{to_id}[value=always]")

    expect(checkbox)
      .to be_checked
  end
end
