#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'
require './test/support/repository_support'

class GluePulpDistributionTestBase < MiniTest::Rails::ActiveSupport::TestCase
  extend  ActiveRecord::TestFixtures
  include RepositorySupport

  fixtures :all

  def self.before_suite
    load_fixtures

    # TODO: RAILS32 remove top reference to load_fixtures
    if @loaded_fixtures.nil?
      @loaded_fixtures = load_fixtures
    end
    configure_runcible

    services  = ['Candlepin', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'Distribution']
    disable_glue_layers(services, models)

    User.current = User.find(@loaded_fixtures['users']['admin']['id'])
    RepositorySupport.create_and_sync_repo(@loaded_fixtures['repositories']['fedora_17_x86_64']['id'])

    VCR.insert_cassette('glue_pulp_distribution', :match_requests_on => [:path, :params, :method, :body_json])
  end

  def self.after_suite
    RepositorySupport.destroy_repo
    VCR.eject_cassette
  end

end


class GluePulpDistributionTest < GluePulpDistributionTestBase

  def test_find
    distribution = Distribution.find("ks-Test Family-TestVariant-16-x86_64")

    refute_nil      distribution
    assert_kind_of  Distribution, distribution
  end

end
