
var AWS = require('aws-sdk');

const rdsConfig = {
    apiVersion: '2014-10-31',
    accessKeyId: process.env.ACCESS_KEY,
    secretAccessKey: process.env.SECRET_KEY,
    region: process.env.REGION
}

const rds = new AWS.RDS(rdsConfig);

exports.handler = (event, context, callback) => {

  const currentDate = new Date();
  let rds_inctance = process.env.RDS_INSTANCE
  const params = {
      DBInstanceIdentifier: rds_inctance, /* DB instance name */
      DBSnapshotIdentifier: `${rds_inctance}-${currentDate.toDateString().replace(/\s+/g, '-').toLowerCase()}-snapshot-manual-by-lamda`, /* DB Snapshot name */
    };

  rds.createDBSnapshot(params, function(err, data) {
      if (err) {
          console.log(err, err.stack);        // an error occurred
          callback(err)
      }
      else {
        callback(null, data);// successful response
        console.log("Snapshot Created ...");
      }
    });
}