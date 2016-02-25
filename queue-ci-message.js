var ironMQ = require('iron_mq'),
  frauPublisher = require('frau-publisher'),
  publishOptions = require('../.publish_options.js');

var queueCiMessage = function(){
  var imq = new ironMQ.Client( {
    token: process.env.IRON_IO_TOKEN,
    project_id: process.env.IRON_IO_ID,
    queue_name: process.env.IRON_QUEUE_NAME
  });

  console.log('Queue Name: ' + process.env.IRON_QUEUE_NAME);
  console.log('Publishing Options: ' + publishOptions);

  var queue = imq.queue(process.env.IRON_QUEUE_NAME),
    appPublisher = frauPublisher.app(publishOptions),
    url = process.env.FRA_LMS_URL || 'https://git.dev.d2l/scm/an/ap.git'
    path = process.env.FRA_LMS_PATH || 'insightsPortal/_config/AppLoader/Apps/' + process.env.FRA_NAME + '.json';

  var message = {
    url: url,
    path: path,
    key: 'urn:d2l:fra:class:' + process.env.FRA_NAME,
    version: appPublisher.getLocation() + 'appconfig.json',
    runMastiff: process.env.RUN_MASTIFF ? true : (process.env.RUN_MASTIFF.toLowerCase() === 'true')
  };

  queue.post( JSON.stringify(message), function( error, body ){
    if (error !== null){
      console.log( 'Error publishing to Iron.io: ' + error );
    }
    if (body !== null ){
      console.log( 'Message back from Iron.io: ' + body );
    }
  });
};

if (process.env.TRAVIS_BRANCH == 'master' && process.env.TRAVIS_PULL_REQUEST == 'false') {
  queueCiMessage();
}
else {
  console.log('This is not a commit to master, not sending message to CI queue.');
}
