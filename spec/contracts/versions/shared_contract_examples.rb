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

shared_examples_for 'version contract' do
  let(:current_user) do
    FactoryBot.build_stubbed(:user) do |user|
      allow(user)
        .to receive(:allowed_to?) do |permission, permission_project|
        permissions.include?(permission) && version_project == permission_project ||
          root_permissions.include?(permission) && root_project == permission_project
      end
    end
  end
  let(:root_project) { FactoryBot.build_stubbed(:project) }
  let(:version_project) do
    FactoryBot.build_stubbed(:project).tap do |p|
      allow(p)
        .to receive(:root)
        .and_return(root_project)
    end
  end
  let(:version_name) { 'Version name' }
  let(:version_description) { 'Version description' }
  let(:version_start_date) { Date.current - 5.days }
  let(:version_due_date) { Date.current + 5.days }
  let(:version_status) { 'open' }
  let(:version_sharing) { 'none' }
  let(:version_wiki_page_title) { 'some page' }
  let(:permissions) { [:manage_versions] }
  let(:root_permissions) { [:manage_versions] }

  def expect_valid(valid, symbols = {})
    expect(contract.validate).to eq(valid)

    symbols.each do |key, arr|
      expect(contract.errors.symbols_for(key)).to match_array arr
    end
  end

  shared_examples 'is valid' do
    it 'is valid' do
      expect_valid(true)
    end
  end

  it_behaves_like 'is valid'

  context 'if the project is nil' do
    let(:version_project) { nil }

    it 'is invalid' do
      expect_valid(false, project_id: %i(blank))
    end
  end

  context 'if the name is nil' do
    let(:version_name) { nil }

    it 'is invalid' do
      expect_valid(false, name: %i(blank))
    end
  end

  context 'if the description is nil' do
    let(:version_description) { nil }

    it_behaves_like 'is valid'
  end

  context 'if the start_date is nil' do
    let(:version_start_date) { nil }

    it_behaves_like 'is valid'
  end

  context 'if the end_date is nil' do
    let(:version_due_date) { nil }

    it_behaves_like 'is valid'
  end

  context 'if the status is nil' do
    let(:version_status) { nil }

    it 'is invalid' do
      expect_valid(false, status: %i(inclusion))
    end
  end

  context 'if the status is something other than the allowed values' do
    let(:version_status) { 'other_status' }

    it 'is invalid' do
      expect_valid(false, status: %i(inclusion))
    end
  end

  context 'if sharing is nil' do
    before do
      version.sharing = 'nil'
    end

    it 'is invalid' do
      expect_valid(false, sharing: %i(inclusion))
    end
  end

  context 'if sharing is bogus' do
    before do
      version.sharing = 'bogus'
    end

    it 'is invalid' do
      expect_valid(false, sharing: %i(inclusion))
    end
  end

  context 'if sharing is system and the user an admin' do
    let(:current_user) { FactoryBot.build_stubbed(:admin) }

    before do
      version.sharing = 'system'
    end

    it_behaves_like 'is valid'
  end

  context 'if sharing is system and the user no admin' do
    before do
      version.sharing = 'system'
    end

    it 'is invalid' do
      expect_valid(false, sharing: %i(inclusion))
    end
  end

  context 'if sharing is descendants' do
    before do
      version.sharing = 'descendants'
    end

    it_behaves_like 'is valid'
  end

  context 'if sharing is tree and the user has manage permission on the root project' do
    before do
      version.sharing = 'tree'
    end

    it_behaves_like 'is valid'
  end

  context 'if sharing is tree and the user has no manage permission on the root project' do
    let(:root_permissions) { [] }
    before do
      version.sharing = 'tree'
    end

    it 'is invalid' do
      expect_valid(false, sharing: %i(inclusion))
    end
  end

  context 'if sharing is hierarchy and the user has manage permission on the root project' do
    before do
      version.sharing = 'hierarchy'
    end

    it_behaves_like 'is valid'
  end

  context 'if sharing is hierarchy and the user has no manage permission on the root project' do
    let(:root_permissions) { [] }

    before do
      version.sharing = 'hierarchy'
    end

    it 'is invalid' do
      expect_valid(false, sharing: %i(inclusion))
    end
  end

  context 'if the user lacks the manage_versions permission' do
    let(:permissions) { [] }

    it 'is invalid' do
      expect_valid(false, base: %i(error_unauthorized))
    end
  end

  context 'if the start date is after the effective date' do
    let(:version_start_date) { version_due_date + 1.day }

    it 'is invalid' do
      expect_valid(false, effective_date: %i(greater_than_start_date))
    end
  end
end
