trello_to_tracker
=================

Discovering Trello isn't your style? Here's a way to export your stories to Pivotal Tracker.

We wrote this to translate our use of Trello to Tracker. To customize to your own,
edit the script to set the following constants appropriately:

`MEMBER_IDS` maps your Trello user ids to your Tracker member names
`ACCEPTED_ALIASES` lists names of Trello lists whose stories should be considered done in Tracker
`STARTED_ALIASES` lists names of Trello lists whose stories should be considered started in Tracker

Only titles and descriptions will carry over, but each Tracker story will include a link back to the original Trello story. All stories will be imported as features.

To use, just run `./trello_to_tracker.rb ~/path/to/trello_export_file.csv`. Tracker-compatible csvs will be generated in a `trello` folder.
