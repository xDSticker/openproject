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

module API
  module V3
    module Principals
      module AssociatedSubclassLambda
        include ::API::Decorators::LinkedResource

        def self.link(name, getter: "#{name}_id")
          ->(*) {
            instance = represented.send(name)

            v3_path = case instance
                      when User
                        :user
                      when Group
                        :group
                      when NilClass
                        # Fall back to user for unknown principal
                        # since we do not have a principal route.
                        :user
                      else
                        raise "undefined subclass for #{instance}"
                      end

            instance_exec(&self.class.associated_resource_default_link(name,
                                                                       v3_path: v3_path,
                                                                       skip_link: -> { false },
                                                                       title_attribute: :name,
                                                                       getter: getter))
          }
        end

        def self.getter(name)
          ->(*) {
            next unless embed_links

            instance = represented.send(name)

            case instance
            when User
              ::API::V3::Users::UserRepresenter.new(represented.send(name), current_user: current_user)
            when Group
              ::API::V3::Groups::GroupRepresenter.new(represented.send(name), current_user: current_user)
            when NilClass
              nil
            else
              raise "undefined subclass for #{instance}"
            end
          }
        end

        def self.setter(name, property_name: name, namespaces: %i(groups users))
          ->(fragment:, **) {
            link = ::API::Decorators::LinkObject.new(represented,
                                                     property_name: property_name,
                                                     namespace: namespaces,
                                                     getter: :"#{name}_id",
                                                     setter: :"#{name}_id=")

            link.from_hash(fragment)
          }
        end
      end
    end
  end
end
