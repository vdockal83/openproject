#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
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
# See COPYRIGHT and LICENSE files for more details.
#++

module API
  module PatchableAPI
    def self.included(base)
      base.class_eval do
        prepend ClassMethods
      end
    end

    module ClassMethods
      def inherited(api, base_instance_parent = Grape::API::Instance)
        super

        # run unscoped patches (i.e. patches that are on the class root, not in a namespace)
        api.send(:execute_patches_for, nil)
      end

      def namespace(name, *args, &)
        super(name, *args) do
          instance_eval(&)
          execute_patches_for(name)
        end
      end

      # we need to repeat all the aliases for them to work properly...
      alias_method :group, :namespace
      alias_method :resource, :namespace
      alias_method :resources, :namespace
      alias_method :segment, :namespace

      private

      def execute_patches_for(path)
        if patches[path]
          patches[path].each do |patch|
            instance_eval(&patch)
          end
        end
      end

      def patches
        ::Constants::APIPatchRegistry.patches_for(self)
      end
    end
  end
end
