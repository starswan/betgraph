# This is BetGraph

A ruby on rails application to graph price histories of sports events
(primarily soccer matches)

* regenerate with:
  rails new betgraph -d mysql --webpack=elm --skip-turbolinks --skip-spring --skip-sprockets
  --skip-keeps --skip-git --skip-puma --skip-action-text --skip-test --skip-system-test
  --skip-action-mailbox

TODOs:
------
0. jsbundling-rails and esbuild rather than webpacker/shakapacker
1. Spike graph display using elm-charts. Follow up with cable version.
2. Decide how to extend analysis work in matches.rake
3. Calculate lambda_a and lambda_b for the various market types and graph them
4. Calculate basket values during price gathering and alert when they have a positive payoff value


