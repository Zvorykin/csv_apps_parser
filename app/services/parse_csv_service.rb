class ParseCsvService
  attr_reader :csv_file_path

  STORE_REGEXPS = [
    %r(https:\/\/apptopia.com\/apps\/(?<store>.*)\/(?<id>[\w.]*)),
    %r(https:\/\/apptopia.com\/(?<store>.+)\/app\/(?<id>[\w.]+)),
    %r(https:\/\/itunes\.(?<store>\w+)\.com\/.*\/app\/.*\/(?<id>[\w.]+)),
    %r(https:\/\/play\.(?<store>\w+)\.com\/.*\/apps\/.*id=(?<id>[\w.]*))
  ]

  GOOGLE_STORE_ALIAS = 'Google play'.freeze
  APPLE_STORE_ALIAS = 'App Store'.freeze
  STORE_ALIASES = {
    GOOGLE_STORE_ALIAS => %w(google),
    APPLE_STORE_ALIAS => %w(apple ios itunes)
  }

  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
  end

  def call
    result = {}

    IO.foreach(csv_file_path) do |line|
      STORE_REGEXPS.each do |regex|
        matches = line.match(regex)
        next if matches.nil?

        # we can prepend result to array if we need to store first occurrence
        # or we can just replace duplicated records
        id = matches[:id]

        result[id] = {
          id: id,
          store: match_store_alias(matches[:store]),
          link: line.strip
        }
      end
    end

    [nil, result: result]
  end

  private

  def match_store_alias(store)
    STORE_ALIASES.each do |key, aliases|
      aliases.each do |value|
        return key if store.include?(value)
      end
    end

    store
  end
end
