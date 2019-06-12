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

require 'api/v3/projects/project_representer'

module API
  module V3
    module Projects
      class ProjectsAPI < ::API::OpenProjectAPI
        resources :projects do
          get &::API::V3::Utilities::Endpoints::Index.new(model: Project,
                                                          scope: -> { Project.visible(User.current).includes(:enabled_modules) })
                                                     .mount

          params do
            requires :id, desc: 'Project id'
          end

          route_param :id do
            after_validation do
              @project = Project.find(params[:id])

              authorize(:view_project, context: @project) do
                raise API::Errors::NotFound.new
              end
            end

            get &::API::V3::Utilities::Endpoints::Show.new(model: Project).mount

            mount API::V3::Projects::AvailableAssigneesAPI
            mount API::V3::Projects::AvailableResponsiblesAPI
            mount API::V3::WorkPackages::WorkPackagesByProjectAPI
            mount API::V3::Categories::CategoriesByProjectAPI
            mount API::V3::Versions::VersionsByProjectAPI
            mount API::V3::Types::TypesByProjectAPI
            mount API::V3::Queries::QueriesByProjectAPI
          end
        end
      end
    end
  end
end
