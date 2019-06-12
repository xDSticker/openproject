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
    module Utilities
      module Endpoints
        class Modify < Bodied
          def default_instance_generator(model)
            ->(_params, _current_user) do
              instance_variable_get("@#{model.name.demodulize.underscore}")
            end
          end

          private

          def present_success(current_user, call)
            render_representer
              .create(call.result,
                      current_user: current_user,
                      embed_links: true)
          end

          def present_error(call)
            errors = call.errors
            errors = merge_dependent_errors call if errors.empty?

            api_errors = [::API::Errors::ErrorBase.create_and_merge_errors(errors)]

            fail ::API::Errors::MultipleErrors.create_if_many(api_errors)
          end

          def merge_dependent_errors(call)
            errors = ActiveModel::Errors.new call.result

            call.dependent_results.each do |dr|
              dr.errors.keys.each do |field|
                dr.errors.symbols_and_messages_for(field).each do |symbol, full_message, _|
                  errors.add :base, symbol, message: dependent_error_message(dr.result, full_message)
                end
              end
            end

            errors
          end

          def dependent_error_message(result, full_message)
            I18n.t(
              :error_in_dependent,
              dependent_class: result.model_name.human,
              related_id: result.id,
              related_subject: result.name,
              error: full_message
            )
          end

          def deduce_process_service
            "::#{decude_backend_namespace}::#{update_or_create}Service".constantize
          end

          def deduce_render_representer
            "::API::V3::#{deduce_api_namespace}::#{api_name}Representer".constantize
          end

          def deduce_process_contract
            nil
          end
        end
      end
    end
  end
end
