require 'csv'
require 'json'
require 'active_support/core_ext/date/conversions'

# Maps from Trello member id to pivotal member name
MEMBER_IDS = {
  # "3e8fc21bb4ab9f929a7832fce78170cb" => "Mario",
  # "5eec12a0cdbf12593ea3a24c84eab06a" => "Luigi"
}
ACCEPTED_ALIASES = ['done']
STARTED_ALIASES = ['in-process', 'doing']

def sluggify(string)
  string.downcase.gsub(/[^a-zA-Z0-9 _-]/, '').tr(' ', '-')
end

if MEMBER_IDS.empty?
  raise ArgumentError, "You'll need to edit the script and fill in your MEMBER_IDS"
end

path = ARGV.first
if path.blank?
  puts "Please supply the path to the trello json file as the first argument"
  exit
end

board = JSON.parse(File.open(path).read)
lists = Hash[board['lists'].map do |list|
  [list['id'], sluggify(list['name'])]
end]

Dir.mkdir('trello')

# Available columns: Id,Story,Labels,Story Type,Estimate,Current State,
# Created at,Accepted at,Deadline,Requested By,Owned By,Description,Comment,Comment
board['cards'].each_slice(100).each_with_index do |cards, page|
  CSV.open("trello/#{sluggify(board['name'])}_#{Date.today.to_s(:db)}_#{page}.csv", 'wb') do |csv|
    csv << ['Story', 'Description', 'Owned By', 'Labels', 'Current State', 'Story Type']
    cards.each do |card|
      next if card['closed']
      list = lists[card['idList']]
      current_state =
        if ACCEPTED_ALIASES.include?(list)
          list = ''
          'accepted'
        elsif STARTED_ALIASES.include?(list)
          list = ''
          'started'
        else
          'unscheduled'
        end
      description = card['desc'] if card["desc"].present?
      csv << [
        card['name'],
        [description, "Imported from #{card['url']}"].compact.join("\n"),
        MEMBER_IDS.fetch(card['idMembers'].first, ''),
        list,
        current_state,
        'feature'
      ]
    end
  end
end
