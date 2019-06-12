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
require_relative './attachment_resource_shared_examples'

describe "forum message attachments" do
  it_behaves_like "an APIv3 attachment resource", include_by_container = false do
    let(:attachment_type) { :forum_message }

    let(:create_permission) { nil }
    let(:read_permission) { nil }
    let(:update_permission) { :edit_messages }

    let(:forum) { FactoryBot.create(:forum, project: project) }
    let(:forum_message) { FactoryBot.create(:message, forum: forum) }

    let(:missing_permissions_user) { FactoryBot.create(:user) }
  end
end
