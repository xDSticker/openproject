#-- encoding: UTF-8
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

class WorkPackages::BulkController < ApplicationController
  before_action :find_work_packages
  before_action :authorize

  include ProjectsHelper
  include CustomFieldsHelper
  include RelationsHelper
  include QueriesHelper
  include IssuesHelper

  def edit
    setup_edit
  end

  def update
    @call = ::WorkPackages::Bulk::UpdateService
      .new(user: current_user, work_packages: @work_packages)
      .call(params: params)

    if @call.success?
      flash[:notice] = t(:notice_successful_update)
      redirect_back_or_default(controller: '/work_packages', action: :index, project_id: @project)
    else
      @bulk_errors = @call.errors
      setup_edit
      render action: :edit
    end
  end

  def destroy
    unless WorkPackage.cleanup_associated_before_destructing_if_required(@work_packages, current_user, params[:to_do])

      respond_to do |format|
        format.html do
          render locals: { work_packages: @work_packages,
                           associated: WorkPackage.associated_classes_to_address_before_destruction_of(@work_packages) }
        end
        format.json do
          render json: { error_message: 'Clean up of associated objects required' }, status: 420
        end
      end

    else

      destroy_work_packages(@work_packages)

      respond_to do |format|
        format.html do
          redirect_back_or_default(project_work_packages_path(@work_packages.first.project))
        end
        format.json do
          head :ok
        end
      end
    end
  end

  private

  def setup_edit
    @available_statuses = @projects.map { |p| Workflow.available_statuses(p) }.inject { |memo, w| memo & w }
    @custom_fields = @projects.map(&:all_work_package_custom_fields).inject { |memo, c| memo & c }
    @assignables = @projects.map(&:possible_assignees).inject { |memo, a| memo & a }
    @responsibles = @projects.map(&:possible_responsibles).inject { |memo, a| memo & a }
    @types = @projects.map(&:types).inject { |memo, t| memo & t }
  end

  def destroy_work_packages(work_packages)
    work_packages.each do |work_package|
      begin
        WorkPackages::DeleteService
          .new(user: current_user,
               model: work_package.reload)
          .call
      rescue ::ActiveRecord::RecordNotFound
        # raised by #reload if work package no longer exists
        # nothing to do, work package was already deleted (eg. by a parent)
      end
    end
  end

  def user
    current_user
  end

  def default_breadcrumb
    l(:label_work_package_plural)
  end
end
