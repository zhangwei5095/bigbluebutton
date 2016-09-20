import sizeOf from 'image-size';
import Slides from '/imports/api/slides';

export function addSlideToCollection(meetingId, presentationId, slideObject) {
  const APP_CONFIG = Meteor.settings.public.app;
  const url = Npm.require('url');

  const imageUri = slideObject.svg_uri != null ? slideObject.svg_uri : slideObject.png_uri;
  if (Slides.findOne({
    meetingId: meetingId,
    'slide.id': slideObject.id,
  }) == null) {
    const options = url.parse(imageUri);

    let addSlideHelper = function (response) {
      let contentType = response.headers['content-type'];

      if (contentType.match(/svg/gi) || contentType.match(/png/gi)) {
        let chunks = [];
        response.on('data', Meteor.bindEnvironment(function (chunk) {
          chunks.push(chunk);
        })).on('end', Meteor.bindEnvironment(function () {
          let buffer = Buffer.concat(chunks);
          const dimensions = sizeOf(buffer);
          const entry = {
            meetingId: meetingId,
            presentationId: presentationId,
            slide: {
              height_ratio: slideObject.height_ratio,
              y_offset: slideObject.y_offset,
              num: slideObject.num,
              x_offset: slideObject.x_offset,
              current: slideObject.current,
              img_uri: slideObject.svg_uri != null ? slideObject.svg_uri : slideObject.png_uri,
              txt_uri: slideObject.txt_uri,
              id: slideObject.id,
              width_ratio: slideObject.width_ratio,
              swf_uri: slideObject.swf_uri,
              thumb_uri: slideObject.thumb_uri,
              width: dimensions.width,
              height: dimensions.height,
            },
          };
          Slides.insert(entry);
        }));
      } else {
        console.log(`Slide file is not accessible or not ready yet`);
        console.log(`response content-type`, response.headers['content-type']);
      }
    };

    // HTTPS connection
    if (APP_CONFIG.httpsConnection) {
      const https = Npm.require('https');

      https.get(options, Meteor.bindEnvironment(function (response) {
        addSlideHelper(response);
      }));
    } else {
      // HTTP connection
      const http = Npm.require('http');

      http.get(options, Meteor.bindEnvironment(function (response) {
        addSlideHelper(response);
      }));
    }

    //logger.info "added slide id =[#{id}]:#{slideObject.id} in #{meetingId}. Now there
    // are #{Slides.find({meetingId: meetingId}).count()} slides in the meeting"
  }
};
