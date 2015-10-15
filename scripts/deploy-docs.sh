#!/bin/bash
# Note: Clear cache on $ENV after executing this script

# Define env and site UUID
export ENV=docs
export SITE=e730eb99-acfa-4822-b233-47faeb7e7b5b


# Generate docs production files
rm -rf output_prod/docs
sculpin generate --env=prod

# Create local directory and file to log rsync output (local path: "$HOME/sites/docs-backups"), then open for review in real-time
mkdir ../docs-backups
mkdir ../docs-backups/`date +%F-%I%p`
echo "rsync log - deploy to docs Multidev on `date +%F-%I%p`" > ../docs-backups/`date +%F-%I%p`/rsync-`date +%F-%I%p`.log
open ../docs-backups/`date +%F-%I%p`/rsync-`date +%F-%I%p`.log


# rsync local output_prod/docs to files dir on appserver
rsync -bv --backup-dir=docs-backups/`date +%F-%I%p` --log-file=../docs-backups/`date +%F-%I%p`/rsync-`date +%F-%I%p`.log --human-readable --size-only --delete-after -rlvz --ipv4 --progress -e 'ssh -p 2222' output_prod/docs --temp-dir=../tmp/ $ENV.$SITE@appserver.$ENV.$SITE.drush.in:files/


# Send the rysnc log file to remote directory "/docs-backups/`date +%F-%I%p`/"
rsync -rlvz --temp-dir=../../../tmp/ --size-only --progress -e 'ssh -p 2222' ../docs-backups/`date +%F-%I%p`/rsync-`date +%F-%I%p`.log $ENV.$SITE@appserver.$ENV.$SITE.drush.in:files/docs-backups/`date +%F-%I%p`
open http://docs-static-docs.pantheon.io/docs
