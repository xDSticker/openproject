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

module API
  module V3
    module TimeEntries
      class TimeEntriesAPI < ::API::OpenProjectAPI
        helpers ::API::Utilities::PageSizeHelper

        resources :time_entries do
          get do
            query = ParamsToQueryService
                    .new(TimeEntry, current_user)
                    .call(params)

            if query.valid?
              TimeEntryCollectionRepresenter.new(query.results,
                                                 api_v3_paths.time_entries,
                                                 page: to_i_or_nil(params[:offset]),
                                                 per_page: resolve_page_size(params[:pageSize]),
                                                 current_user: current_user)
            else
              raise ::API::Errors::InvalidQuery.new(query.errors.full_messages)
            end
          end

          post &::API::V3::Utilities::Endpoints::Create.new(model: TimeEntry).mount

          route_param :id, type: Integer, desc: 'Time entry ID' do
            after_validation do
              @time_entry = TimeEntry
                            .visible
                            .find(params[:id])
            end

            get do
              TimeEntryRepresenter.create(@time_entry,
                                          current_user: current_user,
                                          embed_links: true)
            end

            patch &::API::V3::Utilities::Endpoints::Update.new(model: TimeEntry).mount
            delete &::API::V3::Utilities::Endpoints::Delete.new(model: TimeEntry).mount
          end

          mount ::API::V3::TimeEntries::TimeEntriesActivityAPI
        end
      end
    end
  end
end
