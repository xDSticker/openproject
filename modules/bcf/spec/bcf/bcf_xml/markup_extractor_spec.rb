#-- copyright
# OpenProject Costs Plugin
#
# Copyright (C) 2009 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

require 'spec_helper'

describe ::OpenProject::Bcf::BcfXml::MarkupExtractor do
  let(:filename) { 'MaximumInformation.bcf' }
  let(:file) do
    Rack::Test::UploadedFile.new(
      File.join(Rails.root, "modules/bcf/spec/fixtures/files/#{filename}"),
      'application/octet-stream'
    )
  end
  let(:entries) do
    Zip::File.open(file) do |zip|
      zip.select { |entry| entry.name.end_with?('markup.bcf') }
    end
  end

  subject { described_class.new(entries.first) }

  it '#initialize' do
    expect(subject).to be_a described_class
    expect(subject.markup).to be_a String
    expect(subject.doc).to be_a Nokogiri::XML::Document
  end

  it '#uuid' do
    expect(subject.uuid).to be_eql '63E78882-7C6A-4BF7-8982-FC478AFB9C97'
  end

  it '#title' do
    expect(subject.title).to be_eql 'Maximum Content'
  end

  it '#priority' do
    expect(subject.priority).to be_eql 'High'
  end

  it '#status' do
    expect(subject.status).to be_eql 'Open'
  end

  it '#description' do
    expect(subject.description).to be_eql 'This is a topic with all informations present.'
  end

  it '#author' do
    expect(subject.author).to be_eql 'mike@example.com'
  end

  it '#modified_author' do
    expect(subject.modified_author).to be_eql 'mike@example.com'
  end

  it '#assignee' do
    expect(subject.assignee).to be_eql 'andy@example.com'
  end

  it '#due_date' do
    expect(subject.due_date).to be_nil
  end

  it '#creation_date' do
    expect(subject.creation_date).to eql Date.iso8601('2015-06-21T12:00:00Z')
  end

  it '#modified_date' do
    expect(subject.modified_date).to eql Date.iso8601('2015-06-21T14:22:47Z')
  end

  it '#viewpoints' do
    expect(subject.viewpoints.size).to eql 3
    expect(subject.viewpoints.first[:uuid]).to eql '8dc86298-9737-40b4-a448-98a9e953293a'
    expect(subject.viewpoints.first[:viewpoint]).to eql 'Viewpoint_8dc86298-9737-40b4-a448-98a9e953293a.bcfv'
    expect(subject.viewpoints.first[:snapshot]).to eql 'Snapshot_8dc86298-9737-40b4-a448-98a9e953293a.png'
  end

  it '#comments' do
    expect(subject.comments.size).to eql 4
    expect(subject.comments.first[:uuid]).to eql '780FAE52-C432-42BE-ADEA-FF3E7A8CD8E1'
    expect(subject.comments.first[:date]).to eql '2015-08-31T12:40:17Z'
    expect(subject.comments.first[:author]).to eql 'mike@example.com'
    expect(subject.comments.first[:comment]).to eql 'This is an unmodified topic at the uppermost hierarchical level.
All times in the XML are marked as UTC times.'
  end

  it '#people' do
    expect(subject.people.size).to eql 2
    expect(subject.people.first).to eql 'andy@example.com'
    expect(subject.people.second).to eql 'mike@example.com'
  end

  it '#mail_addresses' do
    expect(subject.mail_addresses.size).to eql 2
    expect(subject.mail_addresses.first).to eql 'andy@example.com'
    expect(subject.mail_addresses.second).to eql 'mike@example.com'
  end
end
