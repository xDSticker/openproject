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

describe ::API::V3::Utilities::PathHelper do
  let(:helper) { Class.new.tap { |c| c.extend(::API::V3::Utilities::PathHelper) }.api_v3_paths }

  shared_examples_for 'path' do |url|
    it 'provides the path' do
      is_expected.to match(url)
    end

    it 'prepends the sub uri if configured' do
      allow(OpenProject::Configuration).to receive(:rails_relative_url_root)
        .and_return('/open_project')

      is_expected.to match("/open_project#{url}")
    end
  end

  before(:each) do
    RequestStore.store[:cached_root_path] = nil
  end

  after(:each) do
    RequestStore.clear!
  end

  shared_examples_for 'api v3 path' do |url|
    it_behaves_like 'path', "/api/v3#{url}"
  end

  describe '#root' do
    subject { helper.root }

    it_behaves_like 'api v3 path'
  end

  describe '#activity' do
    subject { helper.activity 1 }

    it_behaves_like 'api v3 path', '/activities/1'
  end

  describe '#attachment' do
    subject { helper.attachment 1 }

    it_behaves_like 'api v3 path', '/attachments/1'
  end

  describe '#attachments' do
    subject { helper.attachments }

    it_behaves_like 'api v3 path', '/attachments'
  end

  describe '#attachment_content' do
    subject { helper.attachment_content 1 }

    it_behaves_like 'api v3 path', '/attachments/1/content'
  end

  describe '#attachments_by_post' do
    subject { helper.attachments_by_post 1 }

    it_behaves_like 'api v3 path', '/posts/1/attachments'
  end

  describe '#attachments_by_work_package' do
    subject { helper.attachments_by_work_package 1 }

    it_behaves_like 'api v3 path', '/work_packages/1/attachments'
  end

  describe '#attachments_by_wiki_page' do
    subject { helper.attachments_by_wiki_page 1 }

    it_behaves_like 'api v3 path', '/wiki_pages/1/attachments'
  end

  describe '#available_assignees' do
    subject { helper.available_assignees 42 }

    it_behaves_like 'api v3 path', '/projects/42/available_assignees'
  end

  describe '#available_responsibles' do
    subject { helper.available_responsibles 42 }

    it_behaves_like 'api v3 path', '/projects/42/available_responsibles'
  end

  describe '#available_watchers' do
    subject { helper.available_watchers 42 }

    it_behaves_like 'api v3 path', '/work_packages/42/available_watchers'
  end

  describe '#available_projects_on_edit' do
    subject { helper.available_projects_on_edit 42 }

    it_behaves_like 'api v3 path', '/work_packages/42/available_projects'
  end

  describe '#available_projects_on_create' do
    subject { helper.available_projects_on_create(nil) }

    it_behaves_like 'api v3 path', '/work_packages/available_projects'
  end

  describe '#available_projects_on_create with type' do
    subject { helper.available_projects_on_create(1) }

    it_behaves_like 'api v3 path', '/work_packages/available_projects?for_type=1'
  end

  describe '#categories' do
    subject { helper.categories 42 }

    it_behaves_like 'api v3 path', '/projects/42/categories'
  end

  describe '#category' do
    subject { helper.category 42 }

    it_behaves_like 'api v3 path', '/categories/42'
  end

  describe '#configuration' do
    subject { helper.configuration }

    it_behaves_like 'api v3 path', '/configuration'
  end

  context 'custom action paths' do
    describe '#custom_action' do
      subject { helper.custom_action 42 }

      it_behaves_like 'api v3 path', '/custom_actions/42'
    end

    describe '#custom_action_execute' do
      subject { helper.custom_action_execute 42 }

      it_behaves_like 'api v3 path', '/custom_actions/42/execute'
    end
  end

  describe '#custom_option' do
    subject { helper.custom_option 42 }

    it_behaves_like 'api v3 path', '/custom_options/42'
  end

  describe '#create_work_package_form' do
    subject { helper.create_work_package_form }

    it_behaves_like 'api v3 path', '/work_packages/form'
  end

  describe '#create_project_work_package_form' do
    subject { helper.create_project_work_package_form 42 }

    it_behaves_like 'api v3 path', '/projects/42/work_packages/form'
  end

  describe '#grids' do
    subject { helper.grids }

    it_behaves_like 'api v3 path', '/grids'
  end

  describe '#create_grid_form' do
    subject { helper.create_grid_form }

    it_behaves_like 'api v3 path', '/grids/form'
  end

  describe '#grid_schema' do
    subject { helper.grid_schema }

    it_behaves_like 'api v3 path', '/grids/schema'
  end

  describe '#grid' do
    subject { helper.grid(42) }

    it_behaves_like 'api v3 path', '/grids/42'
  end

  describe '#grid_form' do
    subject { helper.grid_form(42) }

    it_behaves_like 'api v3 path', '/grids/42/form'
  end

  describe '#memberships' do
    subject { helper.memberships }

    it_behaves_like 'api v3 path', '/memberships'
  end

  describe '#memberships_available_projects' do
    subject { helper.memberships_available_projects }

    it_behaves_like 'api v3 path', '/memberships/available_projects'
  end

  describe '#membership' do
    subject { helper.membership(42) }

    it_behaves_like 'api v3 path', '/memberships/42'
  end

  describe '#membership_schema' do
    subject { helper.membership_schema }

    it_behaves_like 'api v3 path', '/memberships/schema'
  end

  describe '#version_memberships_form' do
    subject { helper.create_memberships_form }

    it_behaves_like 'api v3 path', '/memberships/form'
  end

  describe '#message' do
    subject { helper.message(42) }

    it_behaves_like 'api v3 path', '/messages/42'
  end

  describe '#my_preferences' do
    subject { helper.my_preferences }

    it_behaves_like 'api v3 path', '/my_preferences'
  end

  describe '#newses' do
    subject { helper.newses }

    it_behaves_like 'api v3 path', '/news'
  end

  describe '#news' do
    subject { helper.news(42) }

    it_behaves_like 'api v3 path', '/news/42'
  end

  describe '#render_markup' do
    subject { helper.render_markup(link: 'link-ish') }

    it_behaves_like 'api v3 path', '/render/markdown?context=link-ish'

    context 'no link given' do
      subject { helper.render_markup }

      it { is_expected.to eql('/api/v3/render/markdown') }
    end
  end

  describe '#post' do
    subject { helper.post 1 }

    it_behaves_like 'api v3 path', '/posts/1'
  end

  describe '#principals' do
    subject { helper.principals }

    it_behaves_like 'api v3 path', '/principals'
  end

  describe 'priorities paths' do
    describe '#priorities' do
      subject { helper.priorities }

      it_behaves_like 'api v3 path', '/priorities'
    end

    describe '#priority' do
      subject { helper.priority 1 }

      it_behaves_like 'api v3 path', '/priorities/1'
    end
  end

  describe 'projects paths' do
    describe '#projects' do
      subject { helper.projects }

      it_behaves_like 'api v3 path', '/projects'
    end

    describe '#project' do
      subject { helper.project 1 }

      it_behaves_like 'api v3 path', '/projects/1'
    end
  end

  describe '#queries' do
    subject { helper.queries }

    it_behaves_like 'api v3 path', '/queries'
  end

  describe '#query' do
    subject { helper.query 1 }

    it_behaves_like 'api v3 path', '/queries/1'
  end

  describe '#query_default' do
    subject { helper.query_default }

    it_behaves_like 'api v3 path', '/queries/default'
  end

  describe '#query_project_default' do
    subject { helper.query_project_default(42) }

    it_behaves_like 'api v3 path', '/projects/42/queries/default'
  end

  describe '#create_query_form' do
    subject { helper.create_query_form }

    it_behaves_like 'api v3 path', '/queries/form'
  end

  describe '#query_form' do
    subject { helper.query_form(42) }

    it_behaves_like 'api v3 path', '/queries/42/form'
  end

  describe '#query_star' do
    subject { helper.query_star 1 }

    it_behaves_like 'api v3 path', '/queries/1/star'
  end

  describe '#query_unstar' do
    subject { helper.query_unstar 1 }

    it_behaves_like 'api v3 path', '/queries/1/unstar'
  end

  describe '#query_column' do
    subject { helper.query_column 'updated_on' }

    it_behaves_like 'api v3 path', '/queries/columns/updated_on'
  end

  describe '#query_group_by' do
    subject { helper.query_group_by 'status' }

    it_behaves_like 'api v3 path', '/queries/group_bys/status'
  end

  describe '#query_sort_by' do
    subject { helper.query_sort_by 'status', 'desc' }

    it_behaves_like 'api v3 path', '/queries/sort_bys/status-desc'
  end

  describe '#query_filter' do
    subject { helper.query_filter 'status' }

    it_behaves_like 'api v3 path', '/queries/filters/status'
  end

  describe '#query_filter_instance_schemas' do
    subject { helper.query_filter_instance_schemas }

    it_behaves_like 'api v3 path', '/queries/filter_instance_schemas'
  end

  describe '#query_filter_instance_schema' do
    subject { helper.query_filter_instance_schema('bogus') }

    it_behaves_like 'api v3 path', '/queries/filter_instance_schemas/bogus'
  end

  describe '#query_project_form' do
    subject { helper.query_project_form(42) }

    it_behaves_like 'api v3 path', '/projects/42/queries/form'
  end

  describe '#query_project_filter_instance_schemas' do
    subject { helper.query_project_filter_instance_schemas(42) }

    it_behaves_like 'api v3 path', '/projects/42/queries/filter_instance_schemas'
  end

  describe '#query_operator' do
    subject { helper.query_operator '=' }

    it_behaves_like 'api v3 path', '/queries/operators/='
  end

  describe '#query_schema' do
    subject { helper.query_schema }

    it_behaves_like 'api v3 path', '/queries/schema'
  end

  describe '#query_project_schema' do
    subject { helper.query_project_schema('42') }

    it_behaves_like 'api v3 path', '/projects/42/queries/schema'
  end

  describe '#query_available_projects' do
    subject { helper.query_available_projects }

    it_behaves_like 'api v3 path', '/queries/available_projects'
  end

  describe 'relations paths' do
    describe '#relation' do
      subject { helper.relation 1 }

      it_behaves_like 'api v3 path', '/relations'
    end

    describe '#relation' do
      subject { helper.relation 1 }

      it_behaves_like 'api v3 path', '/relations/1'
    end
  end

  describe 'revisions paths' do
    describe '#revision' do
      subject { helper.revision 1 }

      it_behaves_like 'api v3 path', '/revisions/1'
    end

    describe '#show_revision' do
      subject { helper.show_revision 'foo', 1234 }

      it_behaves_like 'path', '/projects/foo/repository/revision/1234'
    end
  end

  describe '#roles' do
    subject { helper.roles }

    it_behaves_like 'api v3 path', '/roles'
  end

  describe '#role' do
    subject { helper.role 12 }

    it_behaves_like 'api v3 path', '/roles/12'
  end

  describe 'schemas paths' do
    describe '#work_package_schema' do
      subject { helper.work_package_schema 1, 2 }

      it_behaves_like 'api v3 path', '/work_packages/schemas/1-2'
    end

    describe '#work_package_schemas' do
      subject { helper.work_package_schemas }

      it_behaves_like 'api v3 path', '/work_packages/schemas'
    end

    describe '#work_package_schemas with filters' do
      subject { helper.work_package_schemas [1, 2], [3, 4] }

      def self.filter
        CGI.escape([{ id: { operator: '=', values: ['1-2', '3-4'] } }].to_s)
      end

      it_behaves_like 'api v3 path',
                      "/work_packages/schemas?filters=#{filter}"
    end

    describe '#work_package_sums_schema' do
      subject { helper.work_package_sums_schema }

      it_behaves_like 'api v3 path', '/work_packages/schemas/sums'
    end
  end

  describe 'statuses paths' do
    describe '#statuses' do
      subject { helper.statuses }

      it_behaves_like 'api v3 path', '/statuses'
    end

    describe '#status' do
      subject { helper.status 1 }

      it_behaves_like 'api v3 path', '/statuses/1'
    end
  end

  describe 'string object paths' do
    describe '#string_object' do
      subject { helper.string_object 'foo' }

      it_behaves_like 'api v3 path', '/string_objects?value=foo'

      it 'escapes correctly' do
        value = 'foo/bar baz'
        expect(helper.string_object(value)).to eql('/api/v3/string_objects?value=foo%2Fbar%20baz')
      end
    end

    describe '#status' do
      subject { helper.status 1 }

      it_behaves_like 'api v3 path', '/statuses/1'
    end
  end

  context 'time_entry paths' do
    describe '.time_entries' do
      subject { helper.time_entries }

      it_behaves_like 'api v3 path', '/time_entries'
    end

    describe '.time_entry' do
      subject { helper.time_entry 42 }

      it_behaves_like 'api v3 path', '/time_entries/42'
    end

    describe '.time_entries_activity' do
      subject { helper.time_entries_activity 42 }

      it_behaves_like 'api v3 path', '/time_entries/activities/42'
    end
  end

  describe 'types paths' do
    describe '#types' do
      subject { helper.types }

      it_behaves_like 'api v3 path', '/types'
    end

    describe '#types_by_project' do
      subject { helper.types_by_project 12 }

      it_behaves_like 'api v3 path', '/projects/12/types'
    end

    describe '#type' do
      subject { helper.type 1 }

      it_behaves_like 'api v3 path', '/types/1'
    end
  end

  describe 'users paths' do
    describe '#users' do
      subject { helper.users }

      it_behaves_like 'api v3 path', '/users'
    end

    describe '#user' do
      subject { helper.user 1 }

      it_behaves_like 'api v3 path', '/users/1'
    end
  end

  describe 'group paths' do
    describe '#group' do
      subject { helper.group 1 }

      it_behaves_like 'api v3 path', '/groups/1'
    end
  end

  describe '#version' do
    subject { helper.version 42 }

    it_behaves_like 'api v3 path', '/versions/42'
  end

  describe '#version_form' do
    subject { helper.version_form(42) }

    it_behaves_like 'api v3 path', '/versions/42/form'
  end

  describe '#versions' do
    subject { helper.versions }

    it_behaves_like 'api v3 path', '/versions'
  end

  describe '#versions_available_projects' do
    subject { helper.versions_available_projects }

    it_behaves_like 'api v3 path', '/versions/available_projects'
  end

  describe '#versions_by_project' do
    subject { helper.versions_by_project 42 }

    it_behaves_like 'api v3 path', '/projects/42/versions'
  end

  describe '#projects_by_version' do
    subject { helper.projects_by_version 42 }

    it_behaves_like 'api v3 path', '/versions/42/projects'
  end

  describe '#version_schema' do
    subject { helper.version_schema }

    it_behaves_like 'api v3 path', '/versions/schema'
  end

  describe '#version_create_form' do
    subject { helper.create_version_form }

    it_behaves_like 'api v3 path', '/versions/form'
  end

  describe '#work_packages_by_project' do
    subject { helper.work_packages_by_project 42 }

    it_behaves_like 'api v3 path', '/projects/42/work_packages'
  end

  describe 'wiki pages paths' do
    describe '#wiki_page' do
      subject { helper.wiki_page 1 }

      it_behaves_like 'api v3 path', '/wiki_pages/1'
    end
  end

  describe 'work packages paths' do
    describe '#work_packages' do
      subject { helper.work_packages }

      it_behaves_like 'api v3 path', '/work_packages'
    end

    describe '#work_package' do
      subject { helper.work_package 1 }

      it_behaves_like 'api v3 path', '/work_packages/1'
    end

    describe '#work_package_activities' do
      subject { helper.work_package_activities 42 }

      it_behaves_like 'api v3 path', '/work_packages/42/activities'
    end

    describe '#work_package_relations' do
      subject { helper.work_package_relations 42 }

      it_behaves_like 'api v3 path', '/work_packages/42/relations'
    end

    describe '#work_package_relation' do
      subject { helper.work_package_relation 1, 42 }

      it_behaves_like 'api v3 path', '/work_packages/42/relations/1'
    end

    describe '#work_package_revisions' do
      subject { helper.work_package_revisions 42 }

      it_behaves_like 'api v3 path', '/work_packages/42/revisions'
    end

    describe '#work_package_form' do
      subject { helper.work_package_form 1 }

      it_behaves_like 'api v3 path', '/work_packages/1/form'
    end

    describe '#work_package_watchers' do
      subject { helper.work_package_watchers 1 }

      it_behaves_like 'api v3 path', '/work_packages/1/watchers'
    end

    describe '#watcher' do
      subject { helper.watcher 1, 42 }

      it_behaves_like 'api v3 path', '/work_packages/42/watchers/1'
    end
  end
end
