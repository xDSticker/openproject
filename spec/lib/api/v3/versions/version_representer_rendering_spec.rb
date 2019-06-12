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

describe ::API::V3::Versions::VersionRepresenter, 'rendering' do
  let(:version) { FactoryBot.build_stubbed(:version) }
  let(:user) { FactoryBot.build_stubbed(:user) }
  let(:representer) { described_class.create(version, current_user: user) }

  include API::V3::Utilities::PathHelper

  subject(:generated) { representer.to_json }

  it { is_expected.to include_json('Version'.to_json).at_path('_type') }

  before do
    allow(user)
      .to receive(:allowed_to?) do |permission, project|
        project == version.project && permissions.include?(permission)
      end
    end

  let(:permissions) { [:manage_versions] }

  describe 'links' do
    it { is_expected.to have_json_type(Object).at_path('_links') }

    describe 'to self' do
      it_behaves_like 'has a titled link' do
        let(:link) { 'self' }
        let(:href) { api_v3_paths.version(version.id) }
        let(:title) { version.name }
      end
    end

    describe 'to schema' do
      it_behaves_like 'has an untitled link' do
        let(:link) { 'schema' }
        let(:href) { api_v3_paths.version_schema }
      end
    end

    describe 'to update' do
      context 'if manage versions permissions are granted' do
        it_behaves_like 'has an untitled link' do
          let(:link) { 'update' }
          let(:href) { api_v3_paths.version_form(version.id) }
        end
      end

      describe 'if manage versions permissions are lacking' do
        let(:permissions) { [] }

        it_behaves_like 'has no link' do
          let(:link) { 'update' }
        end
      end
    end

    describe 'to updateImmediately' do
      context 'if manage versions permissions are granted' do
        it_behaves_like 'has an untitled link' do
          let(:link) { 'updateImmediately' }
          let(:href) { api_v3_paths.version(version.id) }
        end
      end

      describe 'if manage versions permissions are lacking' do
        let(:permissions) { [] }

        it_behaves_like 'has no link' do
          let(:link) { 'updateImmediately' }
        end
      end
    end

    describe 'to the defining project' do
      context 'if the user has the permission to see the project' do
        before do
          allow(version.project).to receive(:visible?).with(user).and_return(true)
        end

        it_behaves_like 'has a titled link' do
          let(:link) { 'definingProject' }
          let(:href) { api_v3_paths.project(version.project.id) }
          let(:title) { version.project.name }
        end
      end

      context 'if the user lacks the permission to see the project' do
        before do
          allow(version.project).to receive(:visible?).with(user).and_return(false)
        end

        it_behaves_like 'has no link' do
          let(:link) { 'definingProject' }
        end
      end
    end

    describe 'to available projects' do
      it_behaves_like 'has an untitled link' do
        let(:link) { 'availableInProjects' }
        let(:href) { api_v3_paths.projects_by_version(version.id) }
      end
    end

    context 'custom value' do
      let(:custom_field) { FactoryBot.build_stubbed(:list_version_custom_field) }
      let(:custom_value) do
        FactoryBot.build_stubbed(:custom_value, custom_field: custom_field, value: '1')
      end

      before do
        allow(version)
          .to receive(:available_custom_fields)
          .and_return([custom_field])

        allow(version)
          .to receive(:"custom_value_for")
          .with(custom_field)
          .and_return(custom_value)
      end

      it "has property for the custom field" do
        is_expected
          .to be_json_eql(api_v3_paths.custom_option(custom_value.value).to_json)
          .at_path("_links/customField#{custom_field.id}/href")
      end
    end
  end

  describe 'properties' do
    it { is_expected.to be_json_eql(version.id.to_json).at_path('id') }
    it { is_expected.to be_json_eql(version.name.to_json).at_path('name') }

    it_behaves_like 'API V3 formattable', 'description' do
      let(:format) { 'plain' }
      let(:raw) { version.description }
    end

    it_behaves_like 'has ISO 8601 date only' do
      let(:date) { version.start_date }
      let(:json_path) { 'startDate' }
    end

    it_behaves_like 'has ISO 8601 date only' do
      let(:date) { version.due_date }
      let(:json_path) { 'endDate' }
    end

    it 'has a status' do
      is_expected
        .to be_json_eql(version.status.to_json)
        .at_path('status')
    end

    it 'has a sharing' do
      is_expected
        .to be_json_eql(version.sharing.to_json)
        .at_path('sharing')
    end

    it_behaves_like 'has UTC ISO 8601 date and time' do
      let(:date) { version.created_on }
      let(:json_path) { 'createdAt' }
    end

    it_behaves_like 'has UTC ISO 8601 date and time' do
      let(:date) { version.updated_on }
      let(:json_path) { 'updatedAt' }
    end

    context 'custom value' do
      let(:custom_field) { FactoryBot.build_stubbed(:version_custom_field) }
      let(:custom_value) do
        CustomValue.new(custom_field: custom_field,
                        value: '1234',
                        customized: version)
      end

      before do
        allow(version)
          .to receive(:available_custom_fields)
          .and_return([custom_field])

        allow(version)
          .to receive(:"custom_field_#{custom_field.id}")
          .and_return(custom_value.value)
      end

      it "has property for the custom field" do
        expected = {
          format: "markdown",
          html: "<p>#{custom_value.value}</p>",
          raw: custom_value.value
        }

        is_expected
          .to be_json_eql(expected.to_json)
          .at_path("customField#{custom_field.id}")
      end
    end
  end

  describe 'caching' do
    it 'is based on the representer\'s cache_key' do
      expect(OpenProject::Cache)
        .to receive(:fetch)
        .with(representer.json_cache_key)
        .and_call_original

      representer.to_json
    end

    describe '#json_cache_key' do
      let!(:former_cache_key) { representer.json_cache_key }

      it 'includes the name of the representer class' do
        expect(representer.json_cache_key)
          .to include('API', 'V3', 'Versions', 'VersionRepresenter')
      end

      it 'changes when the locale changes' do
        I18n.with_locale(:fr) do
          expect(representer.json_cache_key)
            .not_to eql former_cache_key
        end
      end

      it 'changes when the version is updated' do
        version.updated_on = Time.now + 20.seconds

        expect(representer.json_cache_key)
          .not_to eql former_cache_key
      end

      it 'changes when the version\'s project is updated' do
        version.project.updated_on = Time.now + 20.seconds

        expect(representer.json_cache_key)
          .not_to eql former_cache_key
      end

      context 'custom fields' do
        let(:version) do
          FactoryBot.build_stubbed(:version).tap do |v|
            # Use this to force the custom field to be defined before the former_cache_key is calculated
            custom_field
          end
        end
        let(:custom_field) { FactoryBot.build_stubbed(:version_custom_field, created_at: Time.now, updated_at: Time.now) }

        before do
          allow(version)
            .to receive(:available_custom_fields)
            .and_return([custom_field])

          allow(version)
            .to receive(:"custom_field_#{custom_field.id}")
            .and_return('123')
        end

        it 'changes when a custom field changes' do
          custom_field.updated_at = Time.now + 20.seconds

          expect(representer.json_cache_key)
            .not_to eql former_cache_key
        end
      end
    end
  end
end
