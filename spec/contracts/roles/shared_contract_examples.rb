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

shared_examples_for 'roles contract' do
  let(:current_user) do
    FactoryBot.build_stubbed(:admin)
  end
  let(:role_instance) { Role.new }
  let(:role_name) { 'A role name' }
  let(:role_assignable) { true }
  let(:role_permissions) { [:view_work_packages] }

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

  describe 'validation' do
    it_behaves_like 'is valid'

    context 'if the name is nil' do
      let(:role_name) { nil }

      it 'is invalid' do
        expect_valid(false, name: %i(blank))
      end
    end

    context 'if the permissions do not include their dependency' do
      let(:role_permissions) { [:manage_members] }

      it 'is invalid' do
        expect_valid(false, permissions: %i(dependency_missing))
      end
    end
  end

  describe '#assignable_permissions' do
    let(:all_permissions) { %i[perm1 perm2 perm3] }

    context 'for a standard role' do
      let(:public_permissions) { [:perm1] }
      let(:global_permissions) { [:perm3] }

      before do
        allow(OpenProject::AccessControl)
          .to receive(:permissions)
          .and_return(all_permissions)
        allow(OpenProject::AccessControl)
          .to receive(:global_permissions)
          .and_return(global_permissions)
        allow(OpenProject::AccessControl)
          .to receive(:public_permissions)
          .and_return(public_permissions)
      end

      it 'is all non public, non global permissions' do
        expect(contract.assignable_permissions)
          .to eql [:perm2]
      end
    end

    context 'for a global role' do
      let(:role) { global_role }

      before do
        allow(OpenProject::AccessControl)
          .to receive(:global_permissions)
          .and_return(all_permissions)
      end

      it 'is all the global permissions' do
        expect(contract.assignable_permissions)
          .to eql all_permissions
      end
    end
  end
end
