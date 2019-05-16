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

require 'api/v3/work_packages/work_package_representer'
require 'api/v3/work_packages/create_work_packages'

module API
  module V3
    module WorkPackages
      class WorkPackagesAPI < ::API::OpenProjectAPI
        resources :work_packages do
          helpers ::API::V3::WorkPackages::CreateWorkPackages

          # The endpoint needs to be mounted before the GET :work_packages/:id.
          # Otherwise, the matcher for the :id also seems to match available_projects.
          # This is also true when the :id param is declared to be of type: Integer.
          mount ::API::V3::WorkPackages::AvailableProjectsOnCreateAPI
          mount ::API::V3::WorkPackages::Schema::WorkPackageSchemasAPI

          get do
            authorize(:view_work_packages, global: true)
            service = WorkPackageCollectionFromQueryParamsService
                      .new(current_user)
                      .call(params)

            if service.success?
              service.result
            else
              api_errors = service.errors.full_messages.map do |message|
                ::API::Errors::InvalidQuery.new(message)
              end

              raise ::API::Errors::MultipleErrors.create_if_many api_errors
            end
          end

          post do
            create_work_packages(request_body, current_user)
          end

          params do
            requires :id, desc: 'Work package id', type: Integer
          end
          route_param :id do
            helpers WorkPackagesSharedHelpers

            helpers do
              attr_reader :work_package
            end

            before do
              @work_package = WorkPackage.find(params[:id])

              authorize(:view_work_packages, context: @work_package.project) do
                raise API::Errors::NotFound.new
              end
            end

            get do
              work_package_representer
            end

            patch do
              parameters = ::API::V3::WorkPackages::ParseParamsService
                           .new(current_user)
                           .call(request_body)
                           .result

              call = ::WorkPackages::UpdateService
                     .new(
                       user: current_user,
                       work_package: @work_package
                     )
                     .call(attributes: parameters, send_notifications: notify_according_to_params)

              if call.success?
                @work_package.reload

                work_package_representer
              else
                handle_work_package_errors @work_package, call
              end
            end

            delete &::API::V3::Utilities::DefaultDelete.new(model: WorkPackage,
                                                            process_service: ::WorkPackages::DestroyService)
                                                       .mount

            mount ::API::V3::WorkPackages::WatchersAPI
            mount ::API::V3::Activities::ActivitiesByWorkPackageAPI
            mount ::API::V3::Attachments::AttachmentsByWorkPackageAPI
            mount ::API::V3::Repositories::RevisionsByWorkPackageAPI
            mount ::API::V3::WorkPackages::UpdateFormAPI
            mount ::API::V3::WorkPackages::AvailableProjectsOnEditAPI
            mount ::API::V3::WorkPackages::AvailableRelationCandidatesAPI
            mount ::API::V3::WorkPackages::WorkPackageRelationsAPI
          end

          mount ::API::V3::WorkPackages::CreateFormAPI
        end
      end
    end
  end
end
