# This is BetGraph

A ruby on rails application to graph price histories of sports events
(primarily soccer matches)

* regenerate with:
  rails new betgraph -d mysql --webpack=elm --skip-turbolinks --skip-spring --skip-sprockets
  --skip-keeps --skip-git --skip-puma --skip-action-text --skip-test --skip-system-test
  --skip-action-mailbox

TODOs:
------
1. Move editing of team names from TeamsController to TeamNamesController and make test pass

2. Finish off analysis work started in matches.rake

3. Improve test coverage. It's at an appalingly low value (78%)

4. Focus price gathering on match, rather than every minute. Decide how and when to do the next fetch

5. Use the BBC to gather data for scorers in soccer matches. (Example JSON in bbc.scores.json)
   An example URL is
   wget -O bbc.scores.json "https://push.api.bbci.co.uk/batch?t=/data/bbc-morph-football-scores-match-list-data/
   endDate/2022-10-19/startDate/2022-10-19/todayDate/2022-10-22/tournament/full-priority-order/
   version/2.4.6/withPlayerActions/true?timeout=5

Previous note was this which doesn't seem to quite work
https://push.api.bbci.co.uk/batch?t=/data/bbc-morph-football-scores-match-list-data/
endDate/2021-03-31/startDate/2021-03-01/todayDate/2021-03-11/tournament/
league-one/version/2.4.6/withPlayerActions/true?timeout=5
which downloads a JSON file of data about League One matches played between 1st and 31st March 2021

5. Get rid of MenuSubPath - I'm not quite sure what it does, but I think it can be replaced entirely by awesome_nested_set


