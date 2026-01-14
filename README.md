# Record Cleaner Rules

## About
[Record Cleaner online](https://www.brc.ac.uk/record_cleaner) is a web
application for checking species observations against rules drawn up based on
past observations and expert knowledge. The app allows users to upload files
with observation details and download the results of the checks. There is also
a [Record Cleaner API](https://record-cleaner.brc.ac.uk/) to enable other
applications to use the service.

The rules contain information such as where and when species can be observed so
that records falling outside known ranges can be highlighted for additional
checking.

The rules are specified within this repository, derived from rules
originally developed by national recording schemes, and available from the
[National Biodiversity
Network](https://nbn.org.uk/tools-and-resources/tools-for-recording-and-mapping/nbn-toolbox/record-cleaner/).

By editing the rules in this repo, they can be kept up to date with the current
status of wildlife in the UK to help confirm the accuracy of new records.

## Using Git
It is not expected that rule editors will have an understanding of Git, the
program used to manage changes in the repository. It is hoped that tools will
be built to facilitate the editing or rules.

For the developers of those tools, the envisaged workflow is
 - A branch is created when a recording scheme plans to make rule updates.
 - Commits are made within that branch for rule updates with a commit
   message to justify them.
 - A pull request is created when updates are complete allowing the scheme 
   organiser to review changes before merging in to the master branch.

## How to update rule files
Rule file updates are normally overseen by the relevant national recording
scheme, and BRC can support this process as required.

Either
 - Use Git to clone the repository then apply updates to the files in the
   `rules_as_csv` folder before committing and pushing them back to the repo.
 - Edit the files via the github website.
 - Use tools which are under development to assist with editing. Contact BRC for
 the latest information.

## Deploying rule updates
For rule changes to go live the Record Cleaner API must be used to pull in
changes. This can be done via the [Swagger UI for
production](https://record-cleaner.brc.ac.uk/docs)
(or [staging](https://record-cleaner.staging.ceh.ac.uk/docs)) or by a tool
calling the UI.

For deployment to work, the API needs to be pointed at the correct repo, branch,
folder and sub-folder which is set in the Kubernetes cluster repositories for
[staging](https://gitlab.ceh.ac.uk/infrastructure/k8s-clusters/k8s-eds-staging/-/blob/master/workloads/record-cleaner/deploy/client.yaml?ref_type=heads)
and
[production](https://gitlab.ceh.ac.uk/infrastructure/k8s-clusters/k8s-eds-prod/-/blob/main/workloads/record-cleaner/deploy/client.yaml?ref_type=heads)

Typically this would look like
```yml
 - name: RULES_REPO
   value: "https://github.com/BiologicalRecordsCentre/record-cleaner-rules.git"
 - name: RULES_BRANCH
   value: "master"
 - name: RULES_DIR
   value: "record-cleaner-rules"
 - name: RULES_SUBDIR
   value: "rules_as_csv"
 ```
You might want to point staging at a dev branch to test some new rules.

When doing the deployment, put the service in to maintenance mode. This prevents
anyone from record cleaning while the rules are in an uncertain state and gives
the update process sole use of the database. E.g.
```sh
curl -X 'POST' \
  'https://record-cleaner.staging.ceh.ac.uk/maintenance' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{
  "mode": true,
  "message": "14/1/2026. Scheduled down-time to update rules."
}'
```
The `<token>` is replaced by a value obtained from authenticating via the /token 
end point.

Initiate the update with the rules/update endpoint.
```sh
curl -X 'GET' \
  'https://record-cleaner.staging.ceh.ac.uk/rules/update?full=false' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer <token>'
```

You can use the rules/update_result endpoint to monitor progress. When this 
shows the update has finished, remove maintenance mode, e.g.
```sh
curl -X 'POST' \
  'https://record-cleaner.staging.ceh.ac.uk/maintenance' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{
  "mode": false,
  "message": "Operating normally."
}'
```


## Version control
Git tracks every change committed to the rules with a unique reference. Record
Cleaner reports, through the API, the reference of the version of rules it is
currently using. If there are multiple instances of the Record Cleaner API then
they may be operating with different versions of the rules. The BRC version of
Record Cleaner online has a page for reporting its
[status](https://www.brc.ac.uk/record_cleaner/status).
