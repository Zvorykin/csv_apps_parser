require 'rails_helper'
require 'csv'
require 'tempfile'
require 'securerandom'

describe ParseCsvService do
  before :all do
    @csv_file = Tempfile.new('csv_parser_temp')
  end

  after :all do
    @csv_file.close
    @csv_file.unlink

    raise Exception.new('temp_file_was_not_deleted') if @csv_file.path.present? && File.file?(@csv_file.path)
  end

  def write_to_csv_file(data)
    data = [data] unless data.is_a? Array

    CSV.open(@csv_file, "w+") { |csv| csv << data }
  end

  let(:google_store_alias) { described_class.const_get('GOOGLE_STORE_ALIAS') }
  let(:apple_store_alias) { described_class.const_get('APPLE_STORE_ALIAS') }

  subject { described_class.new(@csv_file.path).call }
  let(:status) { subject.first }
  let(:payload) { subject.last }
  let(:result) { payload[:result] }

  it 'should reject invalid strings' do
    write_to_csv_file SecureRandom.base64

    expect(status).to be_nil
    expect(result.size).to be 0
  end

  it 'should reject duplicate ids' do
    write_to_csv_file 'https://apptopia.com/apps/google_play/com.netease.l10'
    write_to_csv_file 'https://apptopia.com/apps/itunes_connect/com.netease.l10'

    expect(status).to be_nil
    expect(result.size).to be 1
    expect(result['com.netease.l10']).to include(id: 'com.netease.l10', store: apple_store_alias)
  end

  describe 'check different links' do
    it 'apptopia Google play' do
      write_to_csv_file 'https://apptopia.com/apps/google_play/com.netease.l10'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['com.netease.l10']).to include(id: 'com.netease.l10', store: google_store_alias)
    end

    it 'apptopia App Store' do
      write_to_csv_file 'https://apptopia.com/apps/itunes_connect/1253537199'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['1253537199']).to include(id: '1253537199', store: apple_store_alias)
    end

    it 'apptopia Google play intelligence' do
      write_to_csv_file 'https://apptopia.com/google-play/app/com.facebook.orca/intelligence'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['com.facebook.orca']).to include(id: 'com.facebook.orca', store: google_store_alias)
    end

    it 'apptopia App Store intelligence' do
      write_to_csv_file 'https://apptopia.com/ios/app/1448852425/intelligence'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['1448852425']).to include(id: '1448852425', store: apple_store_alias)
    end

    it 'Google play' do
      write_to_csv_file 'https://play.google.com/store/apps/details?id=com.roblox.client&hl=en'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['com.roblox.client']).to include(id: 'com.roblox.client', store: google_store_alias)
    end

    it 'App Store' do
      write_to_csv_file 'https://itunes.apple.com/us/app/fortnite/id1261357853?mt=8'

      expect(status).to be_nil
      expect(result.size).to be 1
      expect(result['id1261357853']).to include(id: 'id1261357853', store: apple_store_alias)
    end
  end
end
