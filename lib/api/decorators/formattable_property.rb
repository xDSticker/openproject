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
  module Decorators
    module FormattableProperty
      def self.included(base)
        base.extend ClassMethods
      end

      def self.prepended(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def formattable_property(name,
                                 plain: false,
                                 getter: default_formattable_getter(name, plain),
                                 setter: default_formattable_setter(name),
                                 **args)

          attributes = {
            exec_context: :decorator,
            getter: getter,
            setter: setter,
            render_nil: true
          }

          property name,
                   attributes.merge(**args)
        end

        private

        def default_formattable_getter(name, plain = false)
          ->(*) {
            ::API::Decorators::Formattable.new(represented.send(name),
                                               object: represented,
                                               plain: plain)
          }
        end

        def default_formattable_setter(name)
          ->(fragment:, **) {
            represented.send(:"#{name}=", fragment['raw'])
          }
        end
      end
    end
  end
end
