#-- encoding: UTF-8

#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2019 the OpenProject Foundation (OPF)
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
# See doc/COPYRIGHT.rdoc for more details.
#++

class Roles::CreateService < ::BaseServices::Create
  include Roles::NotifyMixin

  private

  def create(params)
    copy_workflow_id = params.delete(:copy_workflow_from)

    super_call = super

    if super_call.success?
      copy_workflows(copy_workflow_id, super_call.result)

      notify_changed_roles(:added, super_call.result)
    end

    super_call
  end

  def new_instance(params)
    if params.delete(:global_role)
      GlobalRole.new
    else
      super
    end
  end

  def copy_workflows(copy_workflow_id, role)
    if copy_workflow_id.present? && (copy_from = Role.find_by(id: copy_workflow_id))
      role.workflows.copy_from_role(copy_from)
    end
  end
end
