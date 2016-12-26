#!/bin/sh

env > /etc/environment

/usr/local/bin/ruby /usr/src/app/update_cards.rb 2>&1

cat << EOF > /var/spool/cron/crontabs/root
$CRON_UPDATE_SCHEDULE /usr/local/bin/ruby /usr/src/app/update_cards.rb 2>&1
$CRON_TWEET_SCHEDULE /usr/local/bin/ruby /usr/src/app/tweet_random_card.rb 2>&1
# :)
EOF

crond -l 2 -f
